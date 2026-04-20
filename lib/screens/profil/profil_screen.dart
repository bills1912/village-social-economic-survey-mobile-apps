// lib/screens/profil/profil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../services/permissions_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {

  // ── Bottom sheet "Informasi Panduan Aplikasi" ─────────────────────────────
  void _showInfoSheet() {
    final auth = context.read<AuthProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Informasi Panduan Aplikasi',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Saat ini anda berada dalam :',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),

            // Info rows
            _sheetRow('Mode', 'Production'),
            _sheetRow('Halaman', 'Profil'),
            _sheetRow('Versi Aplikasi', AppConstants.version),
            _sheetRow('Nama Desa', 'Desa Suka Makmur'),
            _sheetRow('Dinas', 'Badan Pusat Statistik'),
            _sheetRow('Pengguna', auth.user?.name ?? '-'),
            _sheetRow('Email', auth.user?.email ?? '-'),
            _sheetRow(
              'Role',
              (auth.user?.roles.isNotEmpty == true)
                  ? auth.user!.roles.first.replaceAll('_', ' ').toUpperCase()
                  : '-',
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ada kendala yang ditemukan?',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.primaryBlue),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Fitur laporan kendala akan segera tersedia'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('LAPORKAN DISINI',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary)),
        ),
      ],
    ),
  );

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = context.watch<QuestionnaireProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 175,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            // Tombol ⓘ pojok kanan atas
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: _showInfoSheet,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                      Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        'i',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              title: const Text('Profil',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                  ),
                ),
                child: SafeArea(
                  // SafeArea menghindari overflow di atas
                  child: Padding(
                    padding: const EdgeInsets.only(top: 44),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user?.initials ?? 'U',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.name ?? 'Pengguna',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        if (user?.roles.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user!.roles.first
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsSection(prov),
                  const SizedBox(height: 16),
                  _buildSyncSection(prov),
                  const SizedBox(height: 16),
                  _buildMenuSection(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(auth),
                  const SizedBox(height: 20),
                  Text(
                    '${AppConstants.appName} v${AppConstants.version}',
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Statistik ────────────────────────────────────────────────────────────
  Widget _buildStatsSection(QuestionnaireProvider prov) {
    final stats = prov.computeLocalStats();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistik Saya',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(child: _statItem('KK Didata',
                  stats.totalKK.toString(),
                  Icons.home_outlined, AppTheme.primaryBlue)),
              Expanded(child: _statItem('Total Jiwa',
                  stats.totalPenduduk.toString(),
                  Icons.people_outline, AppTheme.accentGreen)),
              Expanded(child: _statItem('Pending Sync',
                  prov.pendingCount.toString(),
                  Icons.cloud_queue, AppTheme.accentOrange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(
      String label, String value, IconData icon, Color color) =>
      Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
        ],
      );

  // ─── Sinkronisasi ─────────────────────────────────────────────────────────
  Widget _buildSyncSection(QuestionnaireProvider prov) {
    final canSync =
    PermissionsService.instance.can(AppFeatures.syncManage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sinkronisasi Data',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prov.pendingCount > 0
                          ? '${prov.pendingCount} data belum tersinkron'
                          : 'Semua data tersinkron ✓',
                      style: TextStyle(
                        fontSize: 13,
                        color: prov.pendingCount > 0
                            ? AppTheme.accentOrange
                            : AppTheme.accentGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      canSync
                          ? 'Data offline akan otomatis disinkron saat online'
                          : 'Sinkronisasi manual tidak tersedia untuk akun Anda',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (canSync)
                ElevatedButton.icon(
                  onPressed: () async {
                    await prov.syncPending();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sinkronisasi selesai'),
                          backgroundColor: AppTheme.accentGreen,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Sync'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('Terkunci',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[400])),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Menu items (mirip referensi gambar 2 & 3) ────────────────────────────
  Widget _buildMenuSection() {
    final items = [
      _MenuItem(Icons.phone_android_outlined, 'Sistem',
              () => _snack('Sistem')),
      _MenuItem(Icons.cloud_upload_outlined, 'Backup',
              () => _snack('Backup')),
      _MenuItem(Icons.shield_outlined, 'Kebijakan Privasi',
              () => _snack('Kebijakan Privasi')),
      _MenuItem(Icons.help_outline, 'FAQ Aplikasi',
              () => _snack('FAQ Aplikasi')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          final isLast = idx == items.length - 1;
          return InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.vertical(
              top: idx == 0 ? const Radius.circular(12) : Radius.zero,
              bottom: isLast ? const Radius.circular(12) : Radius.zero,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                    bottom: BorderSide(
                        color: Colors.grey[100]!, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon,
                        size: 18, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(item.label,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary)),
                  ),
                  Icon(Icons.chevron_right,
                      size: 20, color: Colors.grey[400]),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _snack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label akan segera tersedia'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ─── Tombol Keluar ────────────────────────────────────────────────────────
  Widget _buildLogoutButton(AuthProvider auth) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: () => _confirmLogout(auth),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.accentRed),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'LOGOUT',
        style: TextStyle(
          color: AppTheme.accentRed,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
    ),
  );

  void _confirmLogout(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar'),
        content: const Text(
          'Apakah Anda yakin ingin keluar?\nData yang belum tersinkron tetap tersimpan di perangkat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// ── Helper data class ─────────────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.onTap);
}