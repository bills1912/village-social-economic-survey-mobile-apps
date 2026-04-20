// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/questionnaire.dart';
import '../../providers/auth_provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../services/permissions_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/chart_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _filterDusun;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final prov = context.read<QuestionnaireProvider>();
    await prov.loadQuestionnaires(dusun: _filterDusun);
    await prov.loadStats(dusun: _filterDusun);
  }

  @override
  Widget build(BuildContext context) {
    // ── Permission guard: jika dashboard dimatikan, tampilkan layar akses ditolak
    if (!PermissionsService.instance.can(AppFeatures.dashboard)) {
      return Scaffold(
        backgroundColor: AppTheme.bgLight,
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: AppTheme.primaryBlue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 72, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Akses Ditolak',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda tidak memiliki izin\nuntuk mengakses Dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primaryBlue,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
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
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
          child: Consumer2<AuthProvider, QuestionnaireProvider>(
            builder: (_, auth, prov, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${auth.user?.name.split(' ').first ?? 'Petugas'}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Desa Suka Makmur',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    if (prov.pendingCount > 0)
                      GestureDetector(
                        onTap: () => prov.syncPending(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sync, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${prov.pendingCount} pending',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterDialog,
          tooltip: 'Filter Dusun',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _load,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Consumer<QuestionnaireProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading && prov.questionnaires.isEmpty) {
          return const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final stats = prov.computeLocalStats();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_filterDusun != null) _buildFilterChip(),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total KK',
                      value: stats.totalKK.toString(),
                      icon: Icons.home_outlined,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Total Penduduk',
                      value: stats.totalPenduduk.toString(),
                      icon: Icons.people_outline,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Laki-laki',
                      value: stats.totalLakiLaki.toString(),
                      icon: Icons.male,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Perempuan',
                      value: stats.totalPerempuan.toString(),
                      icon: Icons.female,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Progress Pendataan per Dusun'),
              const SizedBox(height: 12),
              _buildDusunProgressCards(stats),
              const SizedBox(height: 20),
              _buildSectionTitle('Distribusi Jenis Kelamin'),
              const SizedBox(height: 12),
              GenderPieChart(
                lakiLaki: stats.totalLakiLaki,
                perempuan: stats.totalPerempuan,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Progress per Petugas'),
              const SizedBox(height: 12),
              OfficerProgressChart(perPetugas: stats.perPetugas),
              const SizedBox(height: 20),
              if (stats.perPendidikan.isNotEmpty) ...[
                _buildSectionTitle('Distribusi Pendidikan'),
                const SizedBox(height: 12),
                EducationBarChart(perPendidikan: stats.perPendidikan),
                const SizedBox(height: 20),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip() {
    final label = AppConstants.dusunOptions
        .firstWhere((d) => d['value'] == _filterDusun,
        orElse: () => {'label': 'Semua'})['label']!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Chip(
        label: Text('Filter: $label'),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () {
          setState(() => _filterDusun = null);
          _load();
        },
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
        labelStyle: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppTheme.textPrimary,
    ),
  );

  Widget _buildDusunProgressCards(StatistikDesa stats) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.dusunOptions.map((d) {
        final label = d['label']!;
        final count = stats.perDusun[label] ?? 0;
        final idx = AppConstants.dusunOptions.indexOf(d);
        final color = AppTheme.dusunColors[idx % AppTheme.dusunColors.length];

        return Container(
          width: (MediaQuery.of(context).size.width - 52) / 2,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$count KK',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Dusun',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Semua Dusun'),
              leading: Radio<String?>(
                value: null,
                groupValue: _filterDusun,
                onChanged: (v) {
                  setState(() => _filterDusun = v);
                  Navigator.pop(ctx);
                  _load();
                },
              ),
            ),
            ...AppConstants.dusunOptions.map(
                  (d) => ListTile(
                title: Text(d['label']!),
                leading: Radio<String?>(
                  value: d['value'],
                  groupValue: _filterDusun,
                  onChanged: (v) {
                    setState(() => _filterDusun = v);
                    Navigator.pop(ctx);
                    _load();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}