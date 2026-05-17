// lib/screens/users/users_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart'; // Tambahkan import AuthProvider
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  String _filter = 'all';
  String _search = '';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserProvider>().fetchUsers();
      });
    }
  }

  // Tambahkan parameter currentUserUuid untuk mengecualikan akun yang sedang login
  List<UserModel> _filtered(List<UserModel> all, UserModel? currentUser) {
    return all.where((u) {
      // PENGECEKAN GANDA: Sembunyikan jika UUID atau Email sama dengan Admin yang login
      if (currentUser != null) {
        if (u.uuid == currentUser.uuid || u.email == currentUser.email) {
          return false;
        }
      }

      final matchStatus = _filter == 'all' || u.status == _filter;
      final searchLower = _search.toLowerCase();
      final matchSearch = _search.isEmpty ||
          u.username.toLowerCase().contains(searchLower) ||
          u.email.toLowerCase().contains(searchLower) ||
          (u.anggota?.namaLengkap?.toLowerCase().contains(searchLower) ?? false);
          
      return matchStatus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UserProvider>();
    final auth = context.watch<AuthProvider>();
    
    // Ambil full object currentUser
    final currentUser = auth.currentUser;
    
    // Terapkan filter
    final filtered = _filtered(prov.users, currentUser);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: prov.fetchUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          AppSearchBar(
            hint: 'Cari username, email, atau nama...',
            onChanged: (v) => setState(() => _search = v),
          ),
          StatusFilterChips(
            selected: _filter,
            onSelect: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: prov.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : prov.error != null
                    ? ErrorState(message: prov.error!, onRetry: prov.fetchUsers)
                    : filtered.isEmpty
                        ? EmptyState(
                            message: 'Tidak ada pengguna ditemukan',
                            icon: Icons.people_outline,
                            onRefresh: prov.fetchUsers,
                          )
                        : RefreshIndicator(
                            onRefresh: prov.fetchUsers,
                            color: AppColors.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (ctx, i) => _UserCard(
                                user: filtered[i],
                                onRefresh: prov.fetchUsers,
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRefresh;

  const _UserCard({required this.user, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<UserProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar Pengguna
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: user.avatarUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: AppNetworkImage(url: user.avatarUrl, width: 50, height: 50),
                        )
                      : const Icon(Icons.person, color: AppColors.primaryLight, size: 28),
                ),
                const SizedBox(width: 12),
                
                // Info Pengguna
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            user.role == 'admin' ? Icons.shield : Icons.badge_outlined,
                            size: 14,
                            color: user.role == 'admin' ? AppColors.accent : AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: user.role == 'admin' ? AppColors.accent : AppColors.textHint,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Chip
                AppHelpers.statusChip(user.status),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            
            // ─── ACTION BUTTONS ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (user.status == 'pending') ...[
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context,
                        title: 'Tolak Pengguna',
                        content: 'Tolak akses untuk pengguna ini?',
                        confirmText: 'Tolak',
                        confirmColor: AppColors.rejected,
                      );
                      if (ok) {
                        final res = await prov.rejectUser(user.uuid);
                        if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    },
                    icon: const Icon(Icons.close, size: 16, color: AppColors.rejected),
                    label: const Text('Tolak', style: TextStyle(color: AppColors.rejected, fontFamily: 'Poppins')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context,
                        title: 'Verifikasi Pengguna',
                        content: 'Berikan akses untuk pengguna ini?',
                        confirmText: 'Verifikasi',
                        confirmColor: AppColors.verified,
                      );
                      if (ok) {
                        final res = await prov.verifyUser(user.uuid);
                        if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verified,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Verifikasi', style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ] else ...[
                  // Tombol Hapus untuk semua status selain pending
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context,
                        title: 'Hapus Pengguna',
                        content: 'Hapus pengguna ini secara permanen?',
                        confirmText: 'Hapus',
                        confirmColor: AppColors.rejected,
                      );
                      if (ok) {
                        final res = await prov.deleteUser(user.uuid);
                        if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    },
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.rejected),
                    label: const Text('Hapus', style: TextStyle(color: AppColors.rejected, fontFamily: 'Poppins')),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}