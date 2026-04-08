// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/berita_provider.dart';
import '../../providers/agenda_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Menggunakan microtask agar pemanggilan data tidak mengganggu siklus build awal
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadAll());
    }
  }

  /// Memanggil API secara independen. 
  /// Jika satu request lambat/timeout, yang lain tetap bisa tampil.
  Future<void> _loadAll() async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    // Jalankan tanpa Future.wait agar tidak bottleneck
    context.read<BeritaProvider>().fetchBeritas();
    context.read<AgendaProvider>().fetchAgendas();

    // Optimasi: Hanya fetch data user jika yang login adalah admin
    if (auth.isAdmin) {
      context.read<UserProvider>().fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final beritaProv = context.watch<BeritaProvider>();
    final agendaProv = context.watch<AgendaProvider>();
    final userProv = context.watch<UserProvider>();

    // Loading status gabungan
    final isLoading = beritaProv.isLoading || agendaProv.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', 
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(
              AppConstants.appSubtitle,
              style: const TextStyle(
                fontSize: 10, 
                color: Colors.white70, 
                fontWeight: FontWeight.normal
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
          ),
          _ProfileMenu(user: auth.currentUser),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadAll,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header / Greeting ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selamat datang,',
                                  style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins'),
                                ),
                                Text(
                                  auth.currentUser?.displayName ?? 'Admin',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AppHelpers.roleBadge(auth.currentUser?.role),
                              ],
                            ),
                          ),
                          const Icon(Icons.school_rounded, color: Colors.white30, size: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Ringkasan Data (Stats Grid) ---
                    const Text('Ringkasan Data',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.7,
                      children: [
                        _StatCard(
                          label: 'Total Berita',
                          value: beritaProv.beritas.length,
                          pending: beritaProv.pendingBeritas.length,
                          icon: Icons.newspaper_rounded,
                          color: AppColors.cardAmber,
                        ),
                        _StatCard(
                          label: 'Total Agenda',
                          value: agendaProv.agendas.length,
                          pending: agendaProv.pendingAgendas.length,
                          icon: Icons.event_rounded,
                          color: AppColors.cardGreen,
                        ),
                        if (auth.isAdmin) ...[
                          _StatCard(
                            label: 'Total Pengguna',
                            value: userProv.users.length,
                            pending: userProv.pendingUsers.length,
                            icon: Icons.people_rounded,
                            color: AppColors.cardBlue,
                          ),
                          _StatCard(
                            label: 'Terverifikasi',
                            value: userProv.verifiedUsers.length,
                            pending: 0,
                            icon: Icons.verified_user_rounded,
                            color: AppColors.verified,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Pending Sections ---
                    if (auth.isAdmin && userProv.pendingUsers.isNotEmpty) ...[
                      _PendingSection(
                        title: 'Pengguna Menunggu Verifikasi',
                        count: userProv.pendingUsers.length,
                        children: userProv.pendingUsers.take(3).map(
                          (u) => _PendingUserTile(user: u)
                        ).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (beritaProv.pendingBeritas.isNotEmpty) ...[
                      _PendingSection(
                        title: 'Berita Menunggu Verifikasi',
                        count: beritaProv.pendingBeritas.length,
                        children: beritaProv.pendingBeritas.take(3).map(
                          (b) => _PendingItemTile(
                            title: b.judulBerita,
                            subtitle: AppHelpers.formatDateTime(b.createdAt),
                            icon: Icons.newspaper_outlined,
                          )
                        ).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (agendaProv.pendingAgendas.isNotEmpty) ...[
                      _PendingSection(
                        title: 'Agenda Menunggu Verifikasi',
                        count: agendaProv.pendingAgendas.length,
                        children: agendaProv.pendingAgendas.take(3).map(
                          (a) => _PendingItemTile(
                            title: a.namaKegiatan,
                            subtitle: AppHelpers.formatDate(a.jadwal),
                            icon: Icons.event_outlined,
                          )
                        ).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // --- Empty State Check ---
                    if (userProv.pendingUsers.isEmpty &&
                        beritaProv.pendingBeritas.isEmpty &&
                        agendaProv.pendingAgendas.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.verifiedBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.verified.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.verified),
                            SizedBox(width: 12),
                            Text('Tidak ada item yang perlu diverifikasi',
                              style: TextStyle(
                                color: AppColors.verified,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}

// --- SUB-WIDGETS (Sama seperti sebelumnya, ditambahkan proteksi Null Safety) ---

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final int pending;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.pending,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (pending > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.pendingBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$pending pending',
                    style: const TextStyle(fontSize: 9, color: AppColors.pending, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Poppins'),
              ),
              Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _PendingSection extends StatelessWidget {
  final String title;
  final int count;
  final List<Widget> children;
  const _PendingSection({required this.title, required this.count, required this.children});

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppColors.pendingBg, borderRadius: BorderRadius.circular(10)),
                child: Text('$count', style: const TextStyle(fontSize: 11, color: AppColors.pending, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ...children,
      ],
    ),
  );
}

class _PendingUserTile extends StatelessWidget {
  final UserModel user;
  const _PendingUserTile({required this.user});

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    leading: CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.border,
      backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
      child: user.avatarUrl.isEmpty ? const Icon(Icons.person, size: 18, color: AppColors.textHint) : null,
    ),
    title: Text(user.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
    subtitle: Text(user.email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins')),
    trailing: AppHelpers.statusChip(user.status),
  );
}

class _PendingItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _PendingItemTile({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: AppColors.pendingBg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18, color: AppColors.pending),
    ),
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins')),
    trailing: AppHelpers.statusChip('pending'),
  );
}

class _ProfileMenu extends StatelessWidget {
  final UserModel? user;
  const _ProfileMenu({this.user});

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    icon: CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white24,
      backgroundImage: (user?.avatarUrl ?? '').isNotEmpty ? NetworkImage(user!.avatarUrl) : null,
      child: (user?.avatarUrl ?? '').isEmpty ? const Icon(Icons.person, color: Colors.white, size: 18) : null,
    ),
    itemBuilder: (_) => [
      PopupMenuItem(
        enabled: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.displayName ?? '-', style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 13)),
            Text(user?.email ?? '-', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            AppHelpers.roleBadge(user?.role),
          ],
        ),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: 'logout',
        child: Row(
          children: [
            Icon(Icons.logout, size: 18, color: AppColors.rejected),
            SizedBox(width: 10),
            Text('Keluar', style: TextStyle(fontFamily: 'Poppins', color: AppColors.rejected, fontSize: 13)),
          ],
        ),
      ),
    ],
    // Cari bagian ini di lib/screens/dashboard/dashboard_screen.dart

onSelected: (val) async {
  if (val == 'logout') {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Keluar',
      content: 'Apakah Anda yakin ingin keluar?',
      confirmText: 'Keluar',
      confirmColor: AppColors.rejected,
    );
    
    if (confirm == true && context.mounted) {
      // 1. Panggil fungsi logout di provider
      await context.read<AuthProvider>().logout();
      
      // 2. HARD RESET NAVIGASI ke halaman Login
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', // Sesuaikan dengan route login kamu di main.dart
          (route) => false,
        );
      }
    }
  }
},
  );
}