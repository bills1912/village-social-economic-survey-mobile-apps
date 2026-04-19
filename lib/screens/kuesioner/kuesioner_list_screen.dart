// lib/screens/kuesioner/kuesioner_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../models/questionnaire.dart';
import '../../utils/app_theme.dart';
import 'kuesioner_form_screen.dart';
import 'kuesioner_detail_screen.dart';

class KuesionerListScreen extends StatefulWidget {
  const KuesionerListScreen({super.key});

  @override
  State<KuesionerListScreen> createState() => _KuesionerListScreenState();
}

class _KuesionerListScreenState extends State<KuesionerListScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String? _filterDusun;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionnaireProvider>().loadQuestionnaires();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context
                .read<QuestionnaireProvider>()
                .loadQuestionnaires(dusun: _filterDusun),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
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
                    setState(() => _search = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),

          // Filter chips
          if (_filterDusun != null)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Wrap(
                children: [
                  Chip(
                    label: Text(_getDusunLabel(_filterDusun!)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      setState(() => _filterDusun = null);
                      context
                          .read<QuestionnaireProvider>()
                          .loadQuestionnaires();
                    },
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    labelStyle: const TextStyle(
                        color: AppTheme.primaryBlue, fontSize: 12),
                  ),
                ],
              ),
            ),

          // List
          Expanded(
            child: Consumer<QuestionnaireProvider>(
              builder: (_, prov, __) {
                if (prov.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var list = prov.questionnaires;
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

                if (list.isEmpty) {
                  return _buildEmpty();
                }

                return RefreshIndicator(
                  onRefresh: () => prov.loadQuestionnaires(dusun: _filterDusun),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _buildCard(list[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerFormScreen()),
        ).then((_) => context.read<QuestionnaireProvider>().loadQuestionnaires()),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pendataan'),
      ),
    );
  }

  Widget _buildCard(Questionnaire q) {
    final kk = q.kepalaKeluarga;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KuesionerDetailScreen(questionnaire: q),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDusunBadge(q.dusun),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  _infoChip(Icons.people_outline, '${q.jumlahAnggota} anggota'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.male, '${q.jumlahLakiLaki} L'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.female, '${q.jumlahPerempuan} P'),
                  const Spacer(),
                  Text(
                    q.namaPetugas,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              if (q.createdAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  _formatDate(q.createdAt!),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
              // ── Tombol aksi ──────────────────────────────────────────
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KuesionerDetailScreen(questionnaire: q),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Detail', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: const BorderSide(color: AppTheme.primaryBlue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KuesionerFormScreen(existingData: q),
                      ),
                    ).then((result) {
                      if (result == true) {
                        context.read<QuestionnaireProvider>().loadQuestionnaires(
                          dusun: _filterDusun,
                        );
                      }
                    }),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDusunBadge(String dusun) {
    final idx = int.tryParse(dusun) ?? 1;
    final color = AppTheme.dusunColors[(idx - 1) % AppTheme.dusunColors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getDusunLabel(dusun),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppTheme.textSecondary),
      const SizedBox(width: 3),
      Text(label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ],
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_outlined, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          _search.isNotEmpty ? 'Tidak ada hasil pencarian' : 'Belum ada data kuesioner',
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

  String _getDusunLabel(String dusun) {
    return AppConstants.dusunOptions
        .firstWhere((d) => d['value'] == dusun, orElse: () => {'label': 'Dusun $dusun'})['label']!;
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showFilter() {
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
                  context.read<QuestionnaireProvider>().loadQuestionnaires();
                },
              ),
            ),
            ...AppConstants.dusunOptions.map((d) => ListTile(
              title: Text(d['label']!),
              leading: Radio<String?>(
                value: d['value'],
                groupValue: _filterDusun,
                activeColor: AppTheme.primaryBlue,
                onChanged: (v) {
                  setState(() => _filterDusun = v);
                  Navigator.pop(ctx);
                  context.read<QuestionnaireProvider>()
                      .loadQuestionnaires(dusun: v);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}