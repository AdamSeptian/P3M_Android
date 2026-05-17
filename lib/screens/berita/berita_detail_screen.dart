// lib/screens/berita/berita_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/berita_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';
import 'berita_form_screen.dart';

class BeritaDetailScreen extends StatelessWidget {
  final BeritaModel berita;
  
  const BeritaDetailScreen({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final prov = context.read<BeritaProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── HEADER GAMBAR ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: berita.url.isNotEmpty
                  ? AppNetworkImage(url: berita.url, width: double.infinity)
                  : Container(color: AppColors.border),
            ),
          ),
          
          // ─── KONTEN DETAIL ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Tanggal
                  Row(
                    children: [
                      AppHelpers.statusChip(berita.status),
                      const Spacer(),
                      Text(
                        AppHelpers.formatDateTime(berita.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Judul Berita
                  Text(
                    berita.judulBerita,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Pembuat Berita (Username)
                  if (berita.username != null)
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          '@${berita.username}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  
                  // Kategori
                  if (berita.kategoris.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: berita.kategoris.map((k) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                        ),
                        child: Text(
                          k.namaKategori,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryLight,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Tags
                  if (berita.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: berita.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${t.namaTag}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.accent,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  // Isi Berita
                  Text(
                    berita.isiBerita,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  // ─── ACTION BUTTONS ──────────────────────────────────────────
                  VerificationActionRow(
                    status: berita.status,
                    isAdmin: auth.isAdmin,
                    onVerify: auth.isAdmin ? () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context,
                        title: 'Verifikasi Berita',
                        content: 'Verifikasi berita ini?',
                        confirmText: 'Verifikasi',
                        confirmColor: AppColors.verified,
                      );
                      if (ok) {
                        final res = await prov.verifyBerita(berita.uuid);
                        if (context.mounted) {
                          AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                          if (res.isSuccess) Navigator.pop(context);
                        }
                      }
                    } : null,
                    onReject: auth.isAdmin ? () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context,
                        title: 'Tolak Berita',
                        content: 'Tolak berita ini?',
                        confirmText: 'Tolak',
                        confirmColor: AppColors.rejected,
                      );
                      if (ok) {
                        final res = await prov.rejectBerita(berita.uuid);
                        if (context.mounted) {
                          AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                          if (res.isSuccess) Navigator.pop(context);
                        }
                      }
                    } : null,
                    onCancelVerify: auth.isAdmin ? () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context,
                        title: 'Batalkan Verifikasi',
                        content: 'Status akan kembali ke Pending.',
                      );
                      if (ok) {
                        final res = await prov.cancelVerifyBerita(berita.uuid);
                        if (context.mounted) {
                          AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                          if (res.isSuccess) Navigator.pop(context);
                        }
                      }
                    } : null,
                    onCancelReject: auth.isAdmin ? () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context,
                        title: 'Pulihkan Berita',
                        content: 'Status akan kembali ke Pending.',
                      );
                      if (ok) {
                        final res = await prov.cancelRejectBerita(berita.uuid);
                        if (context.mounted) {
                          AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                          if (res.isSuccess) Navigator.pop(context);
                        }
                      }
                    } : null,
                    onEdit: berita.status != 'verified' ? () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => BeritaFormScreen(berita: berita)),
                    ) : null,
                    onDelete: () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context,
                        title: 'Hapus Berita',
                        content: 'Berita akan dihapus permanen.',
                        confirmText: 'Hapus',
                        confirmColor: AppColors.rejected,
                      );
                      if (ok) {
                        final res = await prov.deleteBerita(berita.uuid);
                        if (context.mounted) {
                          AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                          if (res.isSuccess) Navigator.pop(context);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}