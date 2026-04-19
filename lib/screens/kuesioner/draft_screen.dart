// lib/screens/kuesioner/draft_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/storage_service.dart';
import '../../models/questionnaire.dart';
import '../../utils/app_theme.dart';
import 'kuesioner_form_screen.dart';

class DraftScreen extends StatefulWidget {
  const DraftScreen({super.key});

  @override
  State<DraftScreen> createState() => _DraftScreenState();
}

class _DraftScreenState extends State<DraftScreen> {
  List<Map<String, dynamic>> _drafts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _drafts = await StorageService.instance.getAllDrafts();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Draft Pendataan'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _drafts.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _drafts.length,
          itemBuilder: (_, i) => _buildCard(_drafts[i]),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> draft) {
    Questionnaire? q;
    try {
      q = Questionnaire.fromJson(
          jsonDecode(draft['data'] as String));
    } catch (_) {}

    final updatedAt = draft['updated_at'] as String?;
    final id = draft['id'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.accentOrange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.edit_note,
              color: AppTheme.accentOrange),
        ),
        title: Text(
          q?.kepalaKeluarga?.r201 ??
              draft['nama_petugas'] as String? ??
              'Draft',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              'No. KK: ${q?.r102 ?? draft['r_102'] ?? '-'}  ·  ${q?.dusunLabel ?? '-'}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
            if (updatedAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'Terakhir diubah: ${_formatDate(updatedAt)}',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppTheme.primaryBlue),
              onPressed: () async {
                final existing =
                await StorageService.instance.getDraft(id);
                if (existing != null && mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KuesionerFormScreen(
                          existingData: existing),
                    ),
                  );
                  await StorageService.instance.deleteDraft(id);
                  _load();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.accentRed),
              onPressed: () => _confirmDelete(id),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Text('Hapus Draft?'),
        content: const Text('Draft ini akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await StorageService.instance.deleteDraft(id);
              Navigator.pop(ctx);
              _load();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.drafts_outlined, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 14),
        Text('Tidak ada draft tersimpan',
            style: TextStyle(
                color: Colors.grey[500], fontSize: 16)),
        const SizedBox(height: 6),
        Text('Draft dibuat otomatis saat mengisi form',
            style: TextStyle(
                color: Colors.grey[400], fontSize: 13)),
      ],
    ),
  );

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year},'
          ' ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
