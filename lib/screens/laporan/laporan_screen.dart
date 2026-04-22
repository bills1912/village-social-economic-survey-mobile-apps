// lib/screens/laporan/laporan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../models/questionnaire.dart';
import '../../services/permissions_service.dart';
import '../../widgets/age_chart.dart';
import '../../utils/app_theme.dart';
import '../../widgets/chart_widgets.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _filterDusun;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionnaireProvider>().loadQuestionnaires();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!PermissionsService.instance.can(AppFeatures.reports)) {
      return Scaffold(
        backgroundColor: AppTheme.bgLight,
        appBar: AppBar(
          title: const Text('Laporan & Statistik'),
          backgroundColor: AppTheme.primaryBlue,
        ),
        body: _buildAccessDenied('Laporan & Statistik'),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Laporan & Statistik'),
        backgroundColor: AppTheme.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterSheet,
            tooltip: 'Filter Dusun',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Demografi'),
            Tab(text: 'Pendidikan'),
            Tab(text: 'Per Dusun'),
          ],
        ),
      ),
      body: Consumer<QuestionnaireProvider>(
        builder: (_, prov, __) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Questionnaire> data = prov.questionnaires;
          if (_filterDusun != null) {
            data = data.where((q) => q.dusun == _filterDusun).toList();
          }

          final stats = _computeStats(data);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRingkasanTab(stats, data),
              _buildDemografiTab(stats),
              _buildPendidikanTab(stats),
              _buildPerDusunTab(prov.questionnaires),
            ],
          );
        },
      ),
    );
  }

  // ── Access denied ─────────────────────────────────────────────────────────
  Widget _buildAccessDenied(String feature) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Akses Ditolak',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(
          'Anda tidak memiliki izin\nuntuk mengakses $feature.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
        ),
      ],
    ),
  );

  // ─── TAB 1 : Ringkasan ───────────────────────────────────────────────────
  Widget _buildRingkasanTab(_Stats s, List<Questionnaire> data) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<QuestionnaireProvider>().loadQuestionnaires(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_filterDusun != null) _filterChip(),
          _sectionTitle('Ringkasan Pendataan'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _bigStatCard('Total KK', '${s.totalKK}',
                  Icons.home_outlined, AppTheme.primaryBlue),
              _bigStatCard('Total Jiwa', '${s.totalJiwa}',
                  Icons.people_outline, AppTheme.accentGreen),
              _bigStatCard('Laki-laki', '${s.totalL}',
                  Icons.male, const Color(0xFF1565C0)),
              _bigStatCard('Perempuan', '${s.totalP}',
                  Icons.female, Colors.pink),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('Distribusi KK per Dusun'),
          const SizedBox(height: 10),
          _buildDusunSummaryCards(s),
          const SizedBox(height: 20),
          _sectionTitle('Rasio Jenis Kelamin'),
          const SizedBox(height: 10),
          GenderPieChart(lakiLaki: s.totalL, perempuan: s.totalP),
          const SizedBox(height: 20),
          _sectionTitle('Distribusi Status KK'),
          const SizedBox(height: 10),
          _buildStatusKkChart(s),
          const SizedBox(height: 20),
          _sectionTitle('Kinerja Petugas'),
          const SizedBox(height: 10),
          OfficerProgressChart(perPetugas: s.perPetugas),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── TAB 2 : Demografi ───────────────────────────────────────────────────
  Widget _buildDemografiTab(_Stats s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_filterDusun != null) _filterChip(),
        _sectionTitle('Distribusi Usia'),
        const SizedBox(height: 10),
        AgeDistributionChart(ageGroups: s.kelompokUsia),
        const SizedBox(height: 20),
        _sectionTitle('Status Perkawinan'),
        const SizedBox(height: 10),
        _buildHorizontalBar(
          data: s.perStatusKawin,
          colorMap: {
            'Kawin': AppTheme.primaryBlue,
            'Belum Kawin': AppTheme.accentGreen,
            'Cerai Hidup': AppTheme.accentOrange,
            'Cerai Mati': AppTheme.accentRed,
          },
        ),
        const SizedBox(height: 20),
        _sectionTitle('Kewarganegaraan'),
        const SizedBox(height: 10),
        _buildHorizontalBar(
          data: s.perKewarganegaraan,
          colorMap: {
            'WNI': AppTheme.primaryBlue,
            'WNA': AppTheme.accentOrange,
          },
        ),
        const SizedBox(height: 20),
        _sectionTitle('Keberadaan Penduduk'),
        const SizedBox(height: 10),
        _buildHorizontalBar(
          data: s.perKeberadaan,
          colorMap: {
            'Berdomisili': AppTheme.accentGreen,
            'Sudah Pindah': AppTheme.accentOrange,
            'KK Baru': AppTheme.primaryLight,
            'Meninggal': AppTheme.accentRed,
          },
        ),
        const SizedBox(height: 20),
        _sectionTitle('Disabilitas'),
        const SizedBox(height: 10),
        _buildDisabilitasCard(s),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── TAB 3 : Pendidikan ──────────────────────────────────────────────────
  Widget _buildPendidikanTab(_Stats s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_filterDusun != null) _filterChip(),
        _sectionTitle('Distribusi Pendidikan Terakhir'),
        const SizedBox(height: 10),
        EducationBarChart(perPendidikan: s.perPendidikan),
        const SizedBox(height: 20),
        _sectionTitle('Tingkat Pendidikan'),
        const SizedBox(height: 10),
        _buildEducationDetailTable(s),
        const SizedBox(height: 20),
        _sectionTitle('Status Pekerjaan'),
        const SizedBox(height: 10),
        _buildHorizontalBar(
          data: s.perPekerjaan,
          colorMap: {
            'Masih Bersekolah': AppTheme.primaryBlue,
            'Sudah Bekerja': AppTheme.accentGreen,
            'Tidak Bekerja': Colors.grey,
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── TAB 4 : Per Dusun ───────────────────────────────────────────────────
  // Dusun sekarang teks bebas — kumpulkan dari data aktual, tidak pakai
  // AppConstants.dusunOptions lagi
  Widget _buildPerDusunTab(List<Questionnaire> allData) {
    // Kelompokkan berdasarkan dusun (teks bebas) atau nama desa jika dusun kosong
    final dusunMap = <String, List<Questionnaire>>{};
    for (final q in allData) {
      final key = (q.dusun != null && q.dusun!.isNotEmpty)
          ? q.dusun!
          : (q.wilayah.namaDesa ?? 'Tidak Diketahui');
      dusunMap.putIfAbsent(key, () => []).add(q);
    }

    if (dusunMap.isEmpty) {
      return Center(
        child: Text('Belum ada data',
            style: TextStyle(color: Colors.grey[400])),
      );
    }

    final sortedKeys = dusunMap.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Detail per Dusun'),
        const SizedBox(height: 10),
        ...sortedKeys.asMap().entries.map((entry) {
          final idx = entry.key;
          final key = entry.value;
          final dusunData = dusunMap[key]!;
          final color =
          AppTheme.dusunColors[idx % AppTheme.dusunColors.length];
          final ds = _computeStats(dusunData);
          return _buildDusunDetailCard(key, ds, dusunData, color);
        }),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _filterChip() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Chip(
        label: Text('Filter: ${_filterDusun!}'),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: () => setState(() => _filterDusun = null),
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
        labelStyle:
        const TextStyle(color: AppTheme.primaryBlue, fontSize: 12),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary)),
  );

  Widget _bigStatCard(
      String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const Spacer(),
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      );

  // Distribusi KK per dusun — key dari _computeStats sudah teks bebas
  Widget _buildDusunSummaryCards(_Stats s) {
    final total = s.totalKK;
    final sortedEntries = s.perDusun.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
        ],
      ),
      child: sortedEntries.isEmpty
          ? const Text('Belum ada data',
          style: TextStyle(color: AppTheme.textSecondary))
          : Column(
        children: sortedEntries.asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          final ratio = total > 0 ? entry.value / total : 0.0;
          final color =
          AppTheme.dusunColors[idx % AppTheme.dusunColors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(entry.key,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textPrimary))),
                    Text('${entry.value} KK',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    const SizedBox(width: 6),
                    Text('(${(ratio * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusKkChart(_Stats s) {
    final labels = {
      '1': 'KK Desa',
      '2': 'Bukan KK Desa',
      '3': 'Belum Punya KK',
    };
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.accentOrange,
      AppTheme.accentRed,
    ];
    final total = s.totalKK;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: labels.entries.toList().asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          final count = s.perStatusKk[entry.key] ?? 0;
          final ratio = total > 0 ? count / total : 0.0;
          final color = colors[idx % colors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(entry.value,
                            style: const TextStyle(fontSize: 12))),
                    Text('$count',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalBar(
      {required Map<String, int> data,
        required Map<String, Color> colorMap}) {
    if (data.isEmpty) return _emptyCard();
    final max =
    data.values.reduce((a, b) => a > b ? a : b).toDouble();
    final total = data.values.fold(0, (a, b) => a + b);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: data.entries.map((e) {
          final ratio = max > 0 ? e.value / max : 0.0;
          final pct = total > 0
              ? (e.value / total * 100).toStringAsFixed(1)
              : '0';
          final color = colorMap[e.key] ?? AppTheme.primaryBlue;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(e.key,
                            style: const TextStyle(fontSize: 12))),
                    Text('${e.value}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 12)),
                    const SizedBox(width: 4),
                    Text('($pct%)',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisabilitasCard(_Stats s) {
    final total = s.totalJiwa;
    final totalDisab =
    s.perDisabilitas.values.fold(0, (a, b) => a + b);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _infoBubble('Total Penyandang', '$totalDisab',
                  AppTheme.accentOrange),
              const SizedBox(width: 12),
              _infoBubble(
                  'Persentase',
                  total > 0
                      ? '${(totalDisab / total * 100).toStringAsFixed(1)}%'
                      : '0%',
                  AppTheme.primaryBlue),
            ],
          ),
          if (s.perDisabilitas.isNotEmpty) ...[
            const Divider(height: 16),
            ...s.perDisabilitas.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.accessible_outlined,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(e.key,
                          style: const TextStyle(fontSize: 12))),
                  Text('${e.value}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentOrange)),
                ],
              ),
            )),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Tidak ada data disabilitas',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _infoBubble(String label, String value, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );

  Widget _buildEducationDetailTable(_Stats s) {
    final total =
    s.perPendidikan.values.fold(0, (a, b) => a + b);
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        children: [
          _tableHeader(),
          ...s.perPendidikan.entries.map((e) {
            final pct = total > 0
                ? (e.value / total * 100).toStringAsFixed(1)
                : '0';
            return TableRow(children: [
              _tableCell(e.key),
              _tableCell('${e.value}', isNum: true),
              _tableCell('$pct%', isNum: true),
            ]);
          }),
        ],
      ),
    );
  }

  TableRow _tableHeader() => TableRow(
    decoration: const BoxDecoration(
      color: AppTheme.primaryBlue,
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    children: [
      _tableCell('Pendidikan', isHeader: true, color: Colors.white),
      _tableCell('Jiwa', isHeader: true, color: Colors.white),
      _tableCell('%', isHeader: true, color: Colors.white),
    ],
  );

  Widget _tableCell(String text,
      {bool isHeader = false, bool isNum = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isHeader ? 12 : 11,
            fontWeight:
            isHeader ? FontWeight.bold : FontWeight.normal,
            color: color ??
                (isNum ? AppTheme.primaryBlue : AppTheme.textPrimary),
          ),
          textAlign: isNum ? TextAlign.center : TextAlign.left,
        ),
      );

  Widget _buildDusunDetailCard(String dusunLabel, _Stats s,
      List<Questionnaire> data, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          title: Row(
            children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(dusunLabel,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14)),
              ),
            ],
          ),
          subtitle: Text(
            '${s.totalKK} KK · ${s.totalJiwa} jiwa · ${s.totalL}L ${s.totalP}P',
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child:
                          _miniStat('KK', '${s.totalKK}', color)),
                      Expanded(
                          child: _miniStat(
                              'Jiwa', '${s.totalJiwa}', color)),
                      Expanded(
                          child:
                          _miniStat('Laki', '${s.totalL}', color)),
                      Expanded(
                          child: _miniStat(
                              'Perempuan', '${s.totalP}', color)),
                    ],
                  ),
                  if (s.perPetugas.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Petugas Pendata:',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    ...s.perPetugas.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 12, color: color),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(e.key,
                                  style: const TextStyle(
                                      fontSize: 11))),
                          Text('${e.value} KK',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) => Column(
    children: [
      Text(value,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color)),
      Text(label,
          style: const TextStyle(
              fontSize: 10, color: AppTheme.textSecondary)),
    ],
  );

  Widget _emptyCard() => Container(
    height: 60,
    alignment: Alignment.center,
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: const Text('Belum ada data',
        style: TextStyle(color: AppTheme.textSecondary)),
  );

  // Filter sheet — daftar dusun diambil dari data aktual, bukan hardcode
  void _showFilterSheet() {
    final allData =
        context.read<QuestionnaireProvider>().questionnaires;
    final dusunList = allData
        .map((q) => q.dusun)
        .whereType<String>()
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Dusun',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Semua Dusun'),
              leading: Radio<String?>(
                value: null,
                groupValue: _filterDusun,
                activeColor: AppTheme.primaryBlue,
                onChanged: (v) {
                  setState(() => _filterDusun = v);
                  Navigator.pop(ctx);
                },
              ),
            ),
            ...dusunList.map((d) => ListTile(
              title: Text(d),
              leading: Radio<String?>(
                value: d,
                groupValue: _filterDusun,
                activeColor: AppTheme.primaryBlue,
                onChanged: (v) {
                  setState(() => _filterDusun = v);
                  Navigator.pop(ctx);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ─── Stats computation ───────────────────────────────────────────────────
  _Stats _computeStats(List<Questionnaire> data) {
    int jiwa = 0, l = 0, p = 0;
    final perDusun = <String, int>{};
    final perPetugas = <String, int>{};
    final perStatusKk = <String, int>{};
    final perPendidikan = <String, int>{};
    final perPekerjaan = <String, int>{};
    final perStatusKawin = <String, int>{};
    final perKewarganegaraan = <String, int>{};
    final perKeberadaan = <String, int>{};
    final perDisabilitas = <String, int>{};
    final kelompokUsia = <String, int>{};

    const pdkLabels = {
      '1': 'Tidak Sekolah/Belum Tamat SD',
      '2': 'SD/Sederajat',
      '3': 'SMP/Sederajat',
      '4': 'SMA/Sederajat',
      '5': 'D1/D2/D3',
      '6': 'S1/S2/S3',
    };
    const kawinLabels = {
      '1': 'Kawin',
      '2': 'Belum Kawin',
      '3': 'Cerai Hidup',
      '4': 'Cerai Mati',
    };
    const keberadaanLabels = {
      '1': 'Berdomisili',
      '2': 'Sudah Pindah',
      '3': 'KK Baru',
      '4': 'Meninggal',
    };
    const disabLabels = {
      '1': 'Penglihatan',
      '2': 'Pendengaran',
      '3': 'Berjalan/Naik Tangga',
      '4': 'Tangan/Jari',
      '5': 'Mengingat/Konsentrasi',
      '6': 'Merawat Diri',
      '7': 'Komunikasi',
      '8': 'Perilaku/Emosi',
    };

    for (final q in data) {
      // dusun sekarang teks bebas — gunakan langsung sebagai key,
      // fallback ke nama desa jika kosong
      final dusunKey = (q.dusun != null && q.dusun!.isNotEmpty)
          ? q.dusun!
          : (q.wilayah.namaDesa ?? 'Tidak Diketahui');
      perDusun[dusunKey] = (perDusun[dusunKey] ?? 0) + 1;

      perPetugas[q.namaPetugas] =
          (perPetugas[q.namaPetugas] ?? 0) + 1;
      if (q.r103 != null) {
        perStatusKk[q.r103!] = (perStatusKk[q.r103!] ?? 0) + 1;
      }
      for (final a in q.r200) {
        jiwa++;
        if (a.r205 == '1') l++;
        if (a.r205 == '2') p++;
        if (a.r212 != null) {
          final label = pdkLabels[a.r212] ?? a.r212!;
          perPendidikan[label] = (perPendidikan[label] ?? 0) + 1;
        }
        if (a.r300Pekerjaan != null) {
          final pkLabel = a.r300Pekerjaan == '1'
              ? 'Masih Bersekolah'
              : a.r300Pekerjaan == '2'
              ? 'Sudah Bekerja'
              : 'Tidak Bekerja';
          perPekerjaan[pkLabel] =
              (perPekerjaan[pkLabel] ?? 0) + 1;
        }
        if (a.r204 != null) {
          final kLabel = kawinLabels[a.r204] ?? a.r204!;
          perStatusKawin[kLabel] =
              (perStatusKawin[kLabel] ?? 0) + 1;
        }
        if (a.r209 != null) {
          final kwLabel = a.r209 == '1' ? 'WNI' : 'WNA';
          perKewarganegaraan[kwLabel] =
              (perKewarganegaraan[kwLabel] ?? 0) + 1;
        }
        if (a.r210 != null) {
          final kbLabel = keberadaanLabels[a.r210] ?? a.r210!;
          perKeberadaan[kbLabel] =
              (perKeberadaan[kbLabel] ?? 0) + 1;
        }
        if (a.r211 != null) {
          for (final code in a.r211!) {
            final dLabel = disabLabels[code] ?? code;
            perDisabilitas[dLabel] =
                (perDisabilitas[dLabel] ?? 0) + 1;
          }
        }
        if (a.r207Usia != null) {
          final usia = a.r207Usia!;
          final bucket = usia < 5
              ? '0–4'
              : usia < 15
              ? '5–14'
              : usia < 25
              ? '15–24'
              : usia < 40
              ? '25–39'
              : usia < 60
              ? '40–59'
              : '60+';
          kelompokUsia[bucket] =
              (kelompokUsia[bucket] ?? 0) + 1;
        }
      }
    }

    return _Stats(
      totalKK: data.length,
      totalJiwa: jiwa,
      totalL: l,
      totalP: p,
      perDusun: perDusun,
      perPetugas: perPetugas,
      perStatusKk: perStatusKk,
      perPendidikan: perPendidikan,
      perPekerjaan: perPekerjaan,
      perStatusKawin: perStatusKawin,
      perKewarganegaraan: perKewarganegaraan,
      perKeberadaan: perKeberadaan,
      perDisabilitas: perDisabilitas,
      kelompokUsia: kelompokUsia,
    );
  }
}

class _Stats {
  final int totalKK, totalJiwa, totalL, totalP;
  final Map<String, int> perDusun;
  final Map<String, int> perPetugas;
  final Map<String, int> perStatusKk;
  final Map<String, int> perPendidikan;
  final Map<String, int> perPekerjaan;
  final Map<String, int> perStatusKawin;
  final Map<String, int> perKewarganegaraan;
  final Map<String, int> perKeberadaan;
  final Map<String, int> perDisabilitas;
  final Map<String, int> kelompokUsia;

  _Stats({
    required this.totalKK,
    required this.totalJiwa,
    required this.totalL,
    required this.totalP,
    required this.perDusun,
    required this.perPetugas,
    required this.perStatusKk,
    required this.perPendidikan,
    required this.perPekerjaan,
    required this.perStatusKawin,
    required this.perKewarganegaraan,
    required this.perKeberadaan,
    required this.perDisabilitas,
    required this.kelompokUsia,
  });
}