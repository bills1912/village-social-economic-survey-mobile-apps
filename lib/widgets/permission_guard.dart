// lib/widgets/permission_guard.dart
import 'package:flutter/material.dart';
import '../services/permissions_service.dart';
import '../utils/app_theme.dart';

/// Widget pembungkus yang menyembunyikan [child] jika user tidak punya [feature].
///
/// Contoh penggunaan:
/// ```dart
/// PermissionGuard(
///   feature: AppFeatures.questionnaireCreate,
///   child: FloatingActionButton(onPressed: ..., child: Icon(Icons.add)),
/// )
/// ```
class PermissionGuard extends StatelessWidget {
  final String feature;
  final Widget child;

  /// Widget alternatif jika tidak punya akses (default: SizedBox.shrink)
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.feature,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (PermissionsService.instance.can(feature)) return child;
    return fallback ?? const SizedBox.shrink();
  }
}

/// Versi untuk aksi (button, fab, dll.) — tampilkan snackbar "Akses Ditolak"
/// jika ditekan saat tidak punya izin.
class PermissionButton extends StatelessWidget {
  final String feature;
  final Widget child;
  final VoidCallback onPressed;

  const PermissionButton({
    super.key,
    required this.feature,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (PermissionsService.instance.can(feature)) {
      return GestureDetector(onTap: onPressed, child: child);
    }
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda tidak memiliki akses ke fitur ini'),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Opacity(opacity: 0.4, child: child),
    );
  }
}