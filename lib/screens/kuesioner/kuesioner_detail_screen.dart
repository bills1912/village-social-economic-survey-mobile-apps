// lib/screens/kuesioner/kuesioner_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/questionnaire.dart';
import '../../utils/app_theme.dart';

class KuesionerDetailScreen extends StatelessWidget {
  final Questionnaire questionnaire;

  const KuesionerDetailScreen({super.key, required this.questionnaire});

  @override
  Widget build(BuildContext context) {
    final q = questionnaire;
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Detail Kuesioner'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard(q),
            const SizedBox(height: 16),

            // KK Info
            _buildSection('Informasi Kartu Keluarga', [
              _infoRow('No. KK', q.r102),
              _infoRow('Dusun', q.dusunLabel),
              _infoRow('Status KK', q.statusKkLabel),
              if (q.r104 != null)
                _infoRow('Proses KK', q.r104 == '1' ? 'Sudah' : 'Belum'),
              _infoRow('Nama Petugas', q.namaPetugas),
              if (q.waktuPendataan != null)
                _infoRow('Waktu Pendataan', q.waktuPendataan!),
            ]),
            const SizedBox(height: 16),

            // Anggota Keluarga
            _buildSectionTitle(
              'Anggota Keluarga (${q.jumlahAnggota} orang)',
              icon: Icons.people_outline,
            ),
            const SizedBox(height: 8),
            ...q.r200.asMap().entries.map(
                  (e) => _buildAnggotaCard(e.key + 1, e.value),
            ),

            if (q.r401 != null && q.r401!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection('Keterangan', [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(q.r401!,
                      style: const TextStyle(color: AppTheme.textPrimary)),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Questionnaire q) {
    final kk = q.kepalaKeluarga;
    final dusunIdx = (int.tryParse(q.dusun) ?? 1) - 1;
    final color = AppTheme.dusunColors[dusunIdx % AppTheme.dusunColors.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBlue, color],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kk?.r201 ?? 'Tidak ada KK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      q.dusunLabel,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statsChip(Icons.tag, q.r102, Colors.white),
              const SizedBox(width: 12),
              _statsChip(Icons.people, '${q.jumlahAnggota} anggota', Colors.white),
              const SizedBox(width: 12),
              _statsChip(Icons.male, '${q.jumlahLakiLaki}L ${q.jumlahPerempuan}P', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsChip(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color.withOpacity(0.85)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.9))),
    ],
  );

  Widget _buildSection(String title, List<Widget> children) => Container(
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
        Text(title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.primaryBlue,
            )),
        const Divider(height: 16),
        ...children,
      ],
    ),
  );

  Widget _buildSectionTitle(String title, {IconData? icon}) => Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(width: 6),
      ],
      Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    ],
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
        const Text(': ', style: TextStyle(color: AppTheme.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary),
          ),
        ),
      ],
    ),
  );

  Widget _buildAnggotaCard(int no, AnggotaKeluarga a) {
    final isKK = a.r203 == '1';
    final isL = a.r205 == '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isKK
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isL
                      ? AppTheme.primaryBlue.withOpacity(0.1)
                      : Colors.pink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$no',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isL ? AppTheme.primaryBlue : Colors.pink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.namaLengkap,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${a.statusKeluargaLabel} · ${a.jenisKelaminLabel}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isKK)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('KK',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (a.r207Usia != null || a.r212 != null) ...[
            const Divider(height: 14),
            Wrap(
              spacing: 12,
              children: [
                if (a.r207Usia != null)
                  _detailChip(Icons.cake_outlined, '${a.r207Usia} tahun'),
                if (a.r212 != null)
                  _detailChip(Icons.school_outlined, a.pendidikanLabel),
                if (a.r210 != null && a.r210 != '1')
                  _detailChip(
                    Icons.location_off_outlined,
                    a.r210 == '2'
                        ? 'Pindah'
                        : a.r210 == '4'
                        ? 'Meninggal'
                        : 'KK Baru',
                    color: Colors.orange,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, {Color? color}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: color ?? AppTheme.textSecondary),
      const SizedBox(width: 3),
      Text(label,
          style: TextStyle(
              fontSize: 11, color: color ?? AppTheme.textSecondary)),
    ],
  );
}