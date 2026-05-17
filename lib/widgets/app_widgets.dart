// lib/widgets/app_widgets.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart'; // Asumsi helpers sudah ada

// ─── LOADING OVERLAY ──────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black26,
    child: const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Memproses...', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
            ],
          ),
        ),
      ),
    ),
  );
}

// ─── EMPTY STATE ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ]
        ],
      ),
    ),
  );
}

// ─── ERROR STATE ──────────────────────────────────────────────────────────────
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.rejected),
          const SizedBox(height: 16),
          Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ]
        ],
      ),
    ),
  );
}

// ─── NETWORK IMAGE ────────────────────────────────────────────────────────────
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius,
  });

  // Fungsi untuk mengambil token dari storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getToken(),
      builder: (context, snapshot) {
        // Siapkan Header
        final headers = <String, String>{};
        if (snapshot.hasData && snapshot.data != null) {
          headers['Authorization'] = 'Bearer ${snapshot.data}'; // Kirim Token ke Backend!
        }

        final img = Image.network(
          url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          headers: headers, // Pasang header di sini
          errorBuilder: (context, error, stackTrace) {
            // Tampilkan icon jika gambar ditolak backend (403) atau tidak ketemu (404)
            return Container(
              width: width ?? 50,
              height: height ?? 50,
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.5),
                borderRadius: borderRadius,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.textHint,
                size: 24,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: width ?? 50,
              height: height ?? 50,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            );
          },
        );

        if (borderRadius != null) {
          return ClipRRect(borderRadius: borderRadius!, child: img);
        }
        return img;
      },
    );
  }
}
// ─── SECTION HEADER ──────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            fontFamily: 'Poppins',
            letterSpacing: 0.8,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

// ─── ACTION BUTTONS ROW ───────────────────────────────────────────────────────
class VerificationActionRow extends StatelessWidget {
  final String status;
  final VoidCallback? onVerify;
  final VoidCallback? onReject;
  final VoidCallback? onCancelVerify;
  final VoidCallback? onCancelReject;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool isAdmin;

  const VerificationActionRow({
    super.key,
    required this.status,
    this.onVerify,
    this.onReject,
    this.onCancelVerify,
    this.onCancelReject,
    this.onDelete,
    this.onEdit,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (status == 'pending' && isAdmin) ...[
          _ActionBtn('Verifikasi', Icons.check_circle_outline,
              AppColors.verified, AppColors.verifiedBg, onVerify),
          _ActionBtn('Tolak', Icons.cancel_outlined,
              AppColors.rejected, AppColors.rejectedBg, onReject),
        ],
        if (status == 'verified' && isAdmin)
          _ActionBtn('Batalkan', Icons.undo, AppColors.pending,
              AppColors.pendingBg, onCancelVerify),
        if (status == 'rejected' && isAdmin)
          _ActionBtn('Pulihkan', Icons.restore, AppColors.pending,
              AppColors.pendingBg, onCancelReject),
        if (status != 'verified' && onEdit != null)
          _ActionBtn('Edit', Icons.edit_outlined, AppColors.primaryLight,
              AppColors.primaryLight.withOpacity(0.1), onEdit),
        if (onDelete != null)
          _ActionBtn('Hapus', Icons.delete_outline, AppColors.rejected,
              AppColors.rejectedBg, onDelete),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback? onTap;

  const _ActionBtn(this.label, this.icon, this.color, this.bg, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'Poppins',
          )),
        ],
      ),
    ),
  );
}

// ─── SEARCH BAR ───────────────────────────────────────────────────────────────
class AppSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hint;

  const AppSearchBar({super.key, required this.onChanged, this.hint = 'Cari...'});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
      ),
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
    ),
  );
}

// ─── FILTER CHIPS ────────────────────────────────────────────────────────────
class StatusFilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const StatusFilterChips({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      ('Semua', 'all'),
      ('Pending', 'pending'),
      ('Terverifikasi', 'verified'),
      ('Ditolak', 'rejected'),
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: statuses.map((s) {
          final isSelected = selected == s.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(s.$1,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              onSelected: (_) => onSelect(s.$2),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}