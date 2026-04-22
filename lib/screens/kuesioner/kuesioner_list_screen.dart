// lib/screens/kuesioner/kuesioner_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../models/questionnaire.dart';
import '../../services/permissions_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/permission_guard.dart';
import 'kuesioner_form_screen.dart';
import 'kuesioner_detail_screen.dart';

class KuesionerListScreen extends StatefulWidget {
  const KuesionerListScreen({super.key});

  @override
  State<KuesionerListScreen> createState() => _KuesionerListScreenState();
}

class _KuesionerListScreenState extends State<KuesionerListScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  String _search = '';
  String? _filterDusun;

  static const int _pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshList());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshList() async {
    setState(() => _currentPage = 1);
    await context
        .read<QuestionnaireProvider>()
        .loadQuestionnaires(dusun: _filterDusun);
  }

  List<Questionnaire> _filteredList(List<Questionnaire> all) {
    var list = all;
    if (_filterDusun != null) {
      list = list.where((q) => q.dusun == _filterDusun).toList();
    }
    if (_search.isNotEmpty) {
      list = list.where((q) {
        final kk = q.kepalaKeluarga?.r201?.toLowerCase() ?? '';
        return q.r102.contains(_search) ||
            kk.contains(_search) ||
            q.namaPetugas.toLowerCase().contains(_search);
      }).toList();
    }
    return list;
  }

  int _totalPages(int total) => (total / _pageSize).ceil().clamp(1, 9999);

  List<Questionnaire> _currentPageItems(List<Questionnaire> filtered) {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  void _goToPage(int page, int totalPages) {
    if (page < 1 || page > totalPages) return;
    setState(() => _currentPage = page);
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Daftar Kuesioner'),
        backgroundColor: AppTheme.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilter,
            tooltip: 'Filter Dusun',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshList,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_filterDusun != null) _buildFilterChip(),
          Expanded(
            child: Consumer<QuestionnaireProvider>(
              builder: (_, prov, __) {
                if (prov.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = _filteredList(prov.questionnaires);

                if (filtered.isEmpty) return _buildEmpty();

                final totalPages = _totalPages(filtered.length);

                if (_currentPage > totalPages) {
                  WidgetsBinding.instance.addPostFrameCallback(
                        (_) => setState(() => _currentPage = totalPages),
                  );
                }

                final pageItems = _currentPageItems(filtered);
                final startItem = (_currentPage - 1) * _pageSize + 1;
                final endItem =
                (startItem + pageItems.length - 1).clamp(0, filtered.length);

                return Column(
                  children: [
                    // ── Card list ─────────────────────────────────────────
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshList,
                        color: AppTheme.primaryBlue,
                        child: ListView.builder(
                          controller: _scrollCtrl,
                          // Tambah padding bawah agar card terakhir
                          // tidak tertutup apapun
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          itemCount: pageItems.length,
                          itemBuilder: (_, i) => _buildCard(pageItems[i]),
                        ),
                      ),
                    ),

                    // ── Pagination bar + FAB ──────────────────────────────
                    _buildBottomBar(
                      currentPage: _currentPage,
                      totalPages: totalPages,
                      totalItems: filtered.length,
                      startItem: startItem,
                      endItem: endItem,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // FAB dihapus dari sini — dipindah ke dalam _buildBottomBar
    );
  }

  // ── Bottom bar: pagination + FAB bulat di pojok kanan ─────────────────────

  Widget _buildBottomBar({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required int startItem,
    required int endItem,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Pagination (kiri) ────────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info teks
                Text(
                  '$startItem–$endItem dari $totalItems  |  Hal $currentPage/$totalPages',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 6),
                // Tombol navigasi
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _navBtn(
                      icon: Icons.first_page,
                      onTap: currentPage > 1
                          ? () => _goToPage(1, totalPages)
                          : null,
                    ),
                    _navBtn(
                      icon: Icons.chevron_left,
                      onTap: currentPage > 1
                          ? () => _goToPage(currentPage - 1, totalPages)
                          : null,
                    ),
                    const SizedBox(width: 2),
                    ..._pageChips(currentPage, totalPages),
                    const SizedBox(width: 2),
                    _navBtn(
                      icon: Icons.chevron_right,
                      onTap: currentPage < totalPages
                          ? () => _goToPage(currentPage + 1, totalPages)
                          : null,
                    ),
                    _navBtn(
                      icon: Icons.last_page,
                      onTap: currentPage < totalPages
                          ? () => _goToPage(totalPages, totalPages)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── FAB bulat (kanan) ────────────────────────────────────────────
          PermissionGuard(
            feature: AppFeatures.questionnaireCreate,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const KuesionerFormScreen()),
              ).then((_) => _refreshList()),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Page chips ─────────────────────────────────────────────────────────────

  List<Widget> _pageChips(int current, int total) {
    int start = (current - 2).clamp(1, total);
    int end = (start + 4).clamp(1, total);
    start = (end - 4).clamp(1, total);

    final chips = <Widget>[];

    if (start > 1) {
      chips.add(_pageNumBtn(1, current, total));
      if (start > 2) chips.add(_ellipsis());
    }

    for (int p = start; p <= end; p++) {
      chips.add(_pageNumBtn(p, current, total));
    }

    if (end < total) {
      if (end < total - 1) chips.add(_ellipsis());
      chips.add(_pageNumBtn(total, current, total));
    }

    return chips;
  }

  Widget _ellipsis() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Text('…', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
  );

  Widget _pageNumBtn(int page, int current, int totalPages) {
    final active = page == current;
    return GestureDetector(
      onTap: active ? null : () => _goToPage(page, totalPages),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBlue : Colors.transparent,
          border: Border.all(
            color: active ? AppTheme.primaryBlue : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _navBtn({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(
              color: enabled ? Colors.grey[300]! : Colors.grey[200]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppTheme.textPrimary : Colors.grey[350],
        ),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Cari No. KK atau Nama Kepala Keluarga...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchCtrl.clear();
              setState(() {
                _search = '';
                _currentPage = 1;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (v) => setState(() {
          _search = v.toLowerCase();
          _currentPage = 1;
        }),
      ),
    );
  }

  // ── Filter chip ────────────────────────────────────────────────────────────

  Widget _buildFilterChip() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Wrap(
        children: [
          Chip(
            label: Text('Dusun: $_filterDusun'),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () {
              setState(() {
                _filterDusun = null;
                _currentPage = 1;
              });
              _refreshList();
            },
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            labelStyle:
            const TextStyle(color: AppTheme.primaryBlue, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Card ───────────────────────────────────────────────────────────────────

  Widget _buildCard(Questionnaire q) {
    final kk = q.kepalaKeluarga;
    final ps = PermissionsService.instance;
    final lokasiLabel = (q.dusun != null && q.dusun!.isNotEmpty)
        ? q.dusun!
        : (q.wilayah.namaDesa ?? '-');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(q),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.home_outlined,
                        color: AppTheme.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kk?.r201 ?? 'Tidak ada Kepala Keluarga',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No. KK: ${q.r102}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _buildDusunBadge(lokasiLabel),
                ],
              ),

              const Divider(height: 16),

              // ── Stats ────────────────────────────────────────────────────
              Row(
                children: [
                  _infoChip(
                      Icons.people_outline, '${q.jumlahAnggota} anggota'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.male, '${q.jumlahLakiLaki} L'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.female, '${q.jumlahPerempuan} P'),
                  const Spacer(),
                  Text(q.namaPetugas,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),

              if (q.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(_formatDate(q.createdAt!),
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],

              const SizedBox(height: 10),

              // ── Action buttons ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openDetail(q),
                      icon: const Icon(Icons.visibility_outlined, size: 15),
                      label: const Text('Detail',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  if (ps.can(AppFeatures.questionnaireEdit)) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openEdit(q),
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text('Edit',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                  if (ps.can(AppFeatures.questionnaireDelete) ||
                      ps.can(AppFeatures.questionnaireEdit)) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 36,
                      width: 36,
                      child: OutlinedButton(
                        onPressed: () => _confirmDelete(q),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentRed,
                          side: const BorderSide(color: AppTheme.accentRed),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Icon(Icons.delete_outline, size: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────

  void _openDetail(Questionnaire q) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => KuesionerDetailScreen(questionnaire: q)),
    );
  }

  Future<void> _openEdit(Questionnaire q) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KuesionerFormScreen(existingData: q)),
    );
    if (result == true) _refreshList();
  }

  // ── Delete dialog ──────────────────────────────────────────────────────────

  void _confirmDelete(Questionnaire q) {
    final namaKk = q.kepalaKeluarga?.r201 ?? 'responden ini';
    final lokasiLabel = (q.dusun != null && q.dusun!.isNotEmpty)
        ? q.dusun!
        : (q.wilayah.namaDesa ?? '-');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: AppTheme.accentRed, size: 22),
          SizedBox(width: 8),
          Text('Hapus Data?', style: TextStyle(fontSize: 17)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anda akan menghapus data keluarga:',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
                border:
                Border.all(color: AppTheme.accentRed.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaKk,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    'No. KK: ${q.r102}  ·  $lokasiLabel',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text('Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(
                    color: AppTheme.accentRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final prov = context.read<QuestionnaireProvider>();
              final ok = await prov.deleteQuestionnaire(q);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Data "$namaKk" berhasil dihapus'
                    : 'Gagal menghapus: ${prov.error}'),
                backgroundColor:
                ok ? AppTheme.accentGreen : AppTheme.accentRed,
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
                foregroundColor: Colors.white),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ── Filter bottom sheet ────────────────────────────────────────────────────

  void _showFilter() {
    final dusunList = context
        .read<QuestionnaireProvider>()
        .questionnaires
        .map((q) => q.dusun)
        .whereType<String>()
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Dusun',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Semua Dusun'),
              leading: Radio<String?>(
                value: null,
                groupValue: _filterDusun,
                activeColor: AppTheme.primaryBlue,
                onChanged: (v) {
                  setState(() {
                    _filterDusun = v;
                    _currentPage = 1;
                  });
                  Navigator.pop(ctx);
                  _refreshList();
                },
              ),
            ),
            if (dusunList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Belum ada data dusun',
                    style: TextStyle(color: Colors.grey[400])),
              )
            else
              ...dusunList.map(
                    (d) => ListTile(
                  title: Text(d),
                  leading: Radio<String?>(
                    value: d,
                    groupValue: _filterDusun,
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (v) {
                      setState(() {
                        _filterDusun = v;
                        _currentPage = 1;
                      });
                      Navigator.pop(ctx);
                      _refreshList();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_outlined,
            size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          _search.isNotEmpty
              ? 'Tidak ada hasil pencarian'
              : 'Belum ada data kuesioner',
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Tekan tombol + untuk menambah pendataan baru',
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
      ],
    ),
  );

  // ── Small helpers ──────────────────────────────────────────────────────────

  Widget _buildDusunBadge(String label) {
    if (label == '-' || label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppTheme.textSecondary),
      const SizedBox(width: 3),
      Text(label,
          style: const TextStyle(
              fontSize: 11, color: AppTheme.textSecondary)),
    ],
  );

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year},'
        ' ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}