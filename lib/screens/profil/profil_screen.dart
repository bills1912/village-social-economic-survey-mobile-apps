// lib/screens/profil/profil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = context.watch<QuestionnaireProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Avatar
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user?.initials ?? 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user?.name ?? 'Pengguna',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        if (user?.roles.isNotEmpty == true) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user!.roles.first.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text('Profil', style: TextStyle(color: Colors.white)),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats section
                  _buildStatsSection(prov),
                  const SizedBox(height: 16),

                  // Sync section
                  _buildSyncSection(context, prov),
                  const SizedBox(height: 16),

                  // Offline section
                  _buildInfoSection(),
                  const SizedBox(height: 16),

                  // Logout
                  _buildLogoutButton(context, auth),
                  const SizedBox(height: 20),

                  Text(
                    '${AppConstants.appName} v${AppConstants.version}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistik Saya',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: _statItem(
                    'KK Didata', stats.totalKK.toString(), Icons.home_outlined,
                    AppTheme.primaryBlue),
              ),
              Expanded(
                child: _statItem(
                    'Total Jiwa', stats.totalPenduduk.toString(),
                    Icons.people_outline, AppTheme.accentGreen),
              ),
              Expanded(
                child: _statItem(
                    'Pending Sync', prov.pendingCount.toString(),
                    Icons.cloud_queue, AppTheme.accentOrange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildSyncSection(
      BuildContext context, QuestionnaireProvider prov) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sinkronisasi Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                    Text(
                      'Data offline akan otomatis disinkron saat online',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await prov.syncPending();
                  if (context.mounted) {
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
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Aplikasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const Divider(height: 16),
          _infoRow(Icons.location_city, 'Nama Desa', 'Desa Suka Makmur'),
          _infoRow(Icons.business, 'Dinas', 'Badan Pusat Statistik'),
          _infoRow(Icons.apps, 'Versi Aplikasi', AppConstants.version),
          _infoRow(Icons.wifi_off, 'Mode Offline',
              'Mendukung penggunaan tanpa internet'),
          _infoRow(Icons.security, 'Keamanan', 'Data terenkripsi lokal'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500)),
      ],
    ),
  );

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context, auth),
        icon: const Icon(Icons.logout, color: AppTheme.accentRed),
        label: const Text('Keluar',
            style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.accentRed),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
