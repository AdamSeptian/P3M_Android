// lib/utils/helpers.dart
import 'package:flutter/material.dart';
import 'constants.dart';

class AppHelpers {
  /// Format tanggal: "12 Jan 2025"
  static String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Ags','Sep','Okt','Nov','Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  /// Format datetime: "12 Jan 2025, 14:30"
  static String formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Ags','Sep','Okt','Nov','Des'
      ];
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
    } catch (_) {
      return isoDate;
    }
  }

  /// Status chip widget
  static Widget statusChip(String? status) {
    Color bg, text;
    String label;
    IconData icon;
    switch (status?.toLowerCase()) {
      case 'verified':
        bg = AppColors.verifiedBg; text = AppColors.verified;
        label = 'Terverifikasi'; icon = Icons.check_circle_outline;
        break;
      case 'pending':
        bg = AppColors.pendingBg; text = AppColors.pending;
        label = 'Menunggu'; icon = Icons.hourglass_empty;
        break;
      case 'rejected':
        bg = AppColors.rejectedBg; text = AppColors.rejected;
        label = 'Ditolak'; icon = Icons.cancel_outlined;
        break;
      default:
        bg = const Color(0xFFF0F0F0); text = Colors.grey;
        label = status ?? '-'; icon = Icons.help_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(label,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  /// Role badge
  static Widget roleBadge(String? role) {
    Color color;
    switch (role?.toLowerCase()) {
      case 'admin': color = AppColors.cardRed; break;
      case 'humas': color = AppColors.cardBlue; break;
      case 'ketua_forum': color = const Color(0xFF6A1B9A); break;
      default: color = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        role ?? '-',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: isError ? AppColors.rejected : AppColors.verified,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Ya',
    Color confirmColor = AppColors.primary,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title,
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text(content,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor, elevation: 0),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText, style: const TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    ) ?? false;
  }
}