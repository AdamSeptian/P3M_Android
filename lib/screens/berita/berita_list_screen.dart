// lib/screens/berita/berita_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/berita_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';
import 'berita_form_screen.dart';
import 'berita_detail_screen.dart';

class BeritaListScreen extends StatefulWidget {
  const BeritaListScreen({super.key});
  @override
  State<BeritaListScreen> createState() => _BeritaListScreenState();
}

class _BeritaListScreenState extends State<BeritaListScreen> {
  String _filter = 'all';
  String _search = '';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<BeritaProvider>().fetchBeritas();
      context.read<KategoriProvider>().fetchKategoris();
      context.read<TagProvider>().fetchTags();
    }
  }

  List<BeritaModel> _filtered(List<BeritaModel> all) {
    return all.where((b) {
      final matchStatus = _filter == 'all' || b.status == _filter;
      final matchSearch = _search.isEmpty ||
          b.judulBerita.toLowerCase().contains(_search.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BeritaProvider>();
    final auth = context.watch<AuthProvider>();
    final filtered = _filtered(prov.beritas);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Berita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => prov.fetchBeritas(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BeritaFormScreen()),
        ).then((_) => prov.fetchBeritas()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Berita',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          AppSearchBar(
            hint: 'Cari judul berita...',
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
                    ? ErrorState(message: prov.error!, onRetry: prov.fetchBeritas)
                    : filtered.isEmpty
                        ? EmptyState(
                            message: 'Tidak ada berita ditemukan',
                            icon: Icons.newspaper_outlined,
                            onRefresh: prov.fetchBeritas,
                          )
                        : RefreshIndicator(
                            onRefresh: prov.fetchBeritas,
                            color: AppColors.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (ctx, i) => _BeritaCard(
                                berita: filtered[i],
                                isAdmin: auth.isAdmin,
                                onRefresh: prov.fetchBeritas,
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _BeritaCard extends StatelessWidget {
  final BeritaModel berita;
  final bool isAdmin;
  final VoidCallback onRefresh;

  const _BeritaCard({
    required this.berita,
    required this.isAdmin,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.read<BeritaProvider>();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BeritaDetailScreen(berita: berita)),
        ).then((_) => onRefresh()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (berita.url.isNotEmpty)
              AppNetworkImage(
                url: berita.url,
                height: 140,
                width: double.infinity,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppHelpers.statusChip(berita.status),
                      Text(AppHelpers.formatDateTime(berita.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(berita.judulBerita,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (berita.username != null)
                    Text('oleh @${berita.username}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  if (berita.kategoris.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: berita.kategoris.map((k) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(k.namaKategori,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryLight,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  VerificationActionRow(
                    status: berita.status,
                    isAdmin: isAdmin,
                    onVerify: isAdmin ? () async {
                      final ok = await AppHelpers.showConfirmDialog(context,
                        title: 'Verifikasi Berita',
                        content: 'Verifikasi berita "${berita.judulBerita}"?',
                        confirmText: 'Verifikasi',
                        confirmColor: AppColors.verified,
                      );
                      if (ok) {
                        final res = await prov.verifyBerita(berita.uuid);
                        if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    } : null,
                    onReject: isAdmin ? () async {
                      final ok = await AppHelpers.showConfirmDialog(context,
                        title: 'Tolak Berita',
                        content: 'Tolak berita "${berita.judulBerita}"?',
                        confirmText: 'Tolak',
                        confirmColor: AppColors.rejected,
                      );
                      if (ok) {
                        final res = await prov.rejectBerita(berita.uuid);
                        if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    } : null,
                    onCancelVerify: isAdmin ? () async {
                      final ok = await AppHelpers.showConfirmDialog(context,
                        title: 'Batalkan Verifikasi',
                        content: 'Status akan kembali ke Pending.',
                      );
                      if (ok) {
                        final res = await prov.cancelVerifyBerita(berita.uuid);
                        if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    } : null,
                    onCancelReject: isAdmin ? () async {
                      final ok = await AppHelpers.showConfirmDialog(context,
                        title: 'Pulihkan Berita',
                        content: 'Status akan kembali ke Pending.',
                      );
                      if (ok) {
                        final res = await prov.cancelRejectBerita(berita.uuid);
                        if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    } : null,
                    onEdit: berita.status != 'verified' ? () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BeritaFormScreen(berita: berita)),
                    ).then((_) => onRefresh()) : null,
                    onDelete: () async {
                      final ok = await AppHelpers.showConfirmDialog(context,
                        title: 'Hapus Berita',
                        content: 'Berita akan dihapus permanen.',
                        confirmText: 'Hapus',
                        confirmColor: AppColors.rejected,
                      );
                      if (ok) {
                        final res = await prov.deleteBerita(berita.uuid);
                        if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}