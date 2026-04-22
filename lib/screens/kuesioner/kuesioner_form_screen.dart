// lib/screens/kuesioner/kuesioner_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/auth_provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../models/questionnaire.dart';
import '../../models/wilayah.dart';
import '../../utils/app_theme.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/wilayah_picker.dart';

class KuesionerFormScreen extends StatefulWidget {
  final Questionnaire? existingData;
  const KuesionerFormScreen({super.key, this.existingData});
  @override
  State<KuesionerFormScreen> createState() => _KuesionerFormScreenState();
}

class _KuesionerFormScreenState extends State<KuesionerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // ── Step 1 ──────────────────────────────────────────────────────────────────
  final _nomorKkCtrl = TextEditingController();
  final _dusunCtrl   = TextEditingController();
  WilayahSnapshot _wilayah = WilayahSnapshot.empty;
  String? _statusKk;
  String? _sudahUrusKk;

  // ── Anggota ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _anggotaList = [];

  // ── Step 3 extras ────────────────────────────────────────────────────────────
  final _keteranganCtrl = TextEditingController();
  DateTime? _waktuMulai;
  DateTime? _waktuAkhir;
  Map<String, dynamic>? _lokasiRumah;
  bool _isLoadingLocation = false;
  double? _mapLat;
  double? _mapLng;

  bool get _isEditing => widget.existingData != null;
  String get _namaDesa => _wilayah.namaDesa ?? 'Desa';

  List<Map<String, String>> get _statusKkOptions => [
    {'value': '1', 'label': 'KK $_namaDesa'},
    {'value': '2', 'label': 'Bukan KK $_namaDesa'},
    {'value': '3', 'label': 'Belum Punya KK'},
  ];

  // ─── Init ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFromExisting();
    } else {
      _anggotaList.add(_emptyAnggota());
    }
  }

  Map<String, dynamic> _emptyAnggota() => {
    'r_201': '', 'r_202': '', 'r_203': null, 'r_204': null,
    'r_205': null, 'r_206': '', 'r_207': null, 'r_207_usia': null,
    'r_208': '', 'r_209': null, 'r_210': null,
    'r_211': <String>[], 'r_212': null, 'r_300_pekerjaan': null,
    'r_301_usaha_buruh_pekerjaBebas': null, 'r_301': null,
    'r_302_a': '', 'r_302_b': null, 'r_302_c': null,
    'r_302_d': '', 'r_302_e': '', 'r_302_f': '', 'r_302_g': '',
    'r_303_a': '', 'r_303_b': null, 'r_303_c': '', 'r_303_d': '', 'r_303_e': '',
    'r_304_a': null, 'r_304_b': '', 'r_304_c': '', 'r_304_d': '',
    'r_305_a': '', 'r_305_b': '', 'r_305_c': '', 'r_305_d': '', 'r_305_e': '', 'r_305_f': '',
    'r_306': null, 'r_301_tambah': null,
    'r_302_a_tambah': '', 'r_302_b_tambah': null, 'r_302_c_tambah': null,
    'r_302_d_tambah': '', 'r_302_e_tambah': '', 'r_302_f_tambah': '', 'r_302_g_tambah': '',
    'r_303_a_tambah': '', 'r_303_b_tambah': null, 'r_303_c_tambah': '', 'r_303_d_tambah': '', 'r_303_e_tambah': '',
    'r_304_a_tambah': null, 'r_304_b_tambah': '', 'r_304_c_tambah': '', 'r_304_d_tambah': '',
    'r_305_a_tambah': '', 'r_305_b_tambah': '', 'r_305_c_tambah': '', 'r_305_d_tambah': '', 'r_305_e_tambah': '', 'r_305_f_tambah': '',
    'r_307': null, 'r_308_a': null, 'r_308_b': '', 'r_309_a': null, 'r_309_b': '',
    'r_310': null, 'r_307_tambah': null,
    'r_308_a_tambah': null, 'r_308_b_tambah': '', 'r_309_a_tambah': null, 'r_309_b_tambah': '',
    'r_311': null, 'r_312_a': null, 'r_312_b': '', 'r_313_a': null, 'r_313_b': '',
    'r_314': null, 'r_311_tambah': null,
    'r_312_a_tambah': null, 'r_312_b_tambah': '', 'r_313_a_tambah': null, 'r_313_b_tambah': '',
  };

  void _populateFromExisting() {
    final q = widget.existingData!;
    _nomorKkCtrl.text = q.r102;
    _dusunCtrl.text = q.dusun ?? '';
    _wilayah = q.wilayah;
    _statusKk = q.r103;
    _sudahUrusKk = q.r104;
    _anggotaList = q.r200.map((a) => a.toJson()).toList();
    if (_anggotaList.isEmpty) _anggotaList.add(_emptyAnggota());
    _keteranganCtrl.text = q.r401 ?? '';
    _lokasiRumah = q.lokasiRumah;
    if (_lokasiRumah != null) {
      _mapLat = (_lokasiRumah!['lat'] as num?)?.toDouble();
      _mapLng = (_lokasiRumah!['lng'] as num?)?.toDouble();
    }
  }

  @override
  void dispose() {
    _nomorKkCtrl.dispose();
    _dusunCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _fmtTanggal(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }
  String _fmtJam(DateTime dt) =>
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  String _fmtDateTime(DateTime dt) => '${_fmtTanggal(dt)}, ${_fmtJam(dt)}';

  void _snack(String msg, {bool err = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: err ? AppTheme.accentRed : AppTheme.accentGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ─── Location ─────────────────────────────────────────────────────────────

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool svc = await Geolocator.isLocationServiceEnabled();
      if (!svc) { _snack('Aktifkan GPS di pengaturan', err: true); return; }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) { _snack('Izin lokasi ditolak', err: true); return; }
      }
      if (perm == LocationPermission.deniedForever) {
        _snack('Izin lokasi ditolak permanen', err: true); return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      setState(() {
        _mapLat = pos.latitude; _mapLng = pos.longitude;
        _lokasiRumah = {'lat': pos.latitude, 'lng': pos.longitude, 'accuracy': pos.accuracy, 'altitude': pos.altitude};
      });
      _snack('Lokasi berhasil diambil ✓');
    } catch (e) {
      _snack('Gagal: $e', err: true);
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showPeta() {
    final lat = _mapLat ?? 3.5952;
    final lng = _mapLng ?? 98.6722;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 440,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16,12,8,8),
              child: Row(children: [
                const Icon(Icons.location_pin, color: AppTheme.accentRed),
                const SizedBox(width: 8),
                const Expanded(child: Text('Lokasi Rumah', style: TextStyle(fontWeight: FontWeight.bold))),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ]),
            ),
            Expanded(child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              child: _MapWidget(lat: lat, lng: lng, onPicked: (newLat, newLng) {
                setState(() {
                  _mapLat = newLat; _mapLng = newLng;
                  _lokasiRumah = {'lat': newLat, 'lng': newLng, 'accuracy': 0, 'altitude': 0};
                });
                Navigator.pop(ctx);
                _snack('Lokasi dipindahkan ✓');
              }),
            )),
          ]),
        ),
      ),
    );
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void _next() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      if (!_wilayah.isComplete) {
        _snack('Lengkapi data wilayah hingga Desa/Kelurahan', err: true);
        return;
      }
    }
    if (_currentStep == 1 && _anggotaList.isEmpty) {
      _snack('Tambahkan minimal 1 anggota', err: true); return;
    }
    if (_currentStep < 2) setState(() => _currentStep++);
  }

  void _prev() { if (_currentStep > 0) setState(() => _currentStep--); }

  Future<void> _submit() async {
    if (_waktuAkhir == null) setState(() => _waktuAkhir = DateTime.now());
    await _save();
  }

  Future<void> _saveDraft() async {
    final user = context.read<AuthProvider>().user;
    final q = _buildQ(user);
    await context.read<QuestionnaireProvider>().saveQuestionnaire(q, offlineFirst: true);
    if (mounted) { _snack('Draft tersimpan ✓'); Navigator.pop(context, true); }
  }

  Questionnaire _buildQ(dynamic user) {
    final anggota = _anggotaList
        .where((a) => (a['r_201'] ?? '').toString().isNotEmpty)
        .map((a) => AnggotaKeluarga.fromJson(Map<String, dynamic>.from(a)))
        .toList();
    final parts = <String>[];
    if (_waktuMulai != null) parts.add('Mulai: ${_fmtDateTime(_waktuMulai!)}');
    if (_waktuAkhir != null) parts.add('Selesai: ${_fmtDateTime(_waktuAkhir!)}');
    if (parts.isEmpty) parts.add(_fmtTanggal(DateTime.now()));

    return Questionnaire(
      id: widget.existingData?.id,
      surveyId: null,
      namaPetugas: user?.name ?? '',
      wilayah: _wilayah,
      dusun: _dusunCtrl.text.trim().isEmpty ? null : _dusunCtrl.text.trim(),
      r102: _nomorKkCtrl.text.trim(),
      r103: _statusKk,
      r104: _sudahUrusKk,
      r200: anggota,
      r401: _keteranganCtrl.text.trim().isEmpty ? null : _keteranganCtrl.text.trim(),
      lokasiRumah: _lokasiRumah,
      waktuPendataan: parts.join(' | '),
    );
  }

  Future<void> _save() async {
    final user = context.read<AuthProvider>().user;
    final q = _buildQ(user);
    final prov = context.read<QuestionnaireProvider>();
    final ok = await prov.saveQuestionnaire(q);
    if (mounted) {
      if (ok) { _snack('Data berhasil disimpan ✓'); Navigator.pop(context, true); }
      else _snack('Gagal: ${prov.error}', err: true);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Pendataan' : 'Pendataan Baru'),
        backgroundColor: AppTheme.primaryBlue,
        actions: [
          TextButton.icon(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save_outlined, color: Colors.white70, size: 18),
            label: const Text('Draft', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: Column(children: [
        _stepBar(),
        Expanded(child: Form(
          key: _formKey,
          child: IndexedStack(
            index: _currentStep,
            children: [_step1(), _step2(), _step3(user)],
          ),
        )),
        _bottomBar(),
      ]),
    );
  }

  Widget _stepBar() {
    const labels = ['Identitas KK', 'Anggota', 'Konfirmasi'];
    return Container(
      color: AppTheme.primaryBlue,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: List.generate(3, (i) {
          final active = i == _currentStep;
          final done = i < _currentStep;
          return Expanded(child: Column(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: active || done ? Colors.white : Colors.white30,
                shape: BoxShape.circle,
              ),
              child: Center(child: done
                  ? const Icon(Icons.check, size: 16, color: AppTheme.primaryBlue)
                  : Text('${i+1}', style: TextStyle(
                  color: active ? AppTheme.primaryBlue : Colors.white70,
                  fontWeight: FontWeight.bold, fontSize: 13))),
            ),
            const SizedBox(height: 4),
            Text(labels[i], style: TextStyle(
              color: active ? Colors.white : Colors.white60, fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            )),
          ]));
        }),
      ),
    );
  }

  // ─── STEP 1 ───────────────────────────────────────────────────────────────

  Widget _step1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // ── Waktu ──────────────────────────────────────────────────────────
        _section('Waktu Wawancara', Icons.schedule_outlined, [
          _waktuButton(
            label: 'Catat Waktu Mulai', icon: Icons.play_circle_outline,
            color: AppTheme.accentGreen, recorded: _waktuMulai,
            onTap: () => setState(() { _waktuMulai = DateTime.now(); _snack('Waktu mulai: ${_fmtDateTime(_waktuMulai!)}'); }),
            onReset: () => setState(() => _waktuMulai = null),
          ),
          const SizedBox(height: 4),
          const Text('Waktu Selesai dicatat di langkah Konfirmasi.',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ]),
        const SizedBox(height: 16),

        // ── Wilayah ────────────────────────────────────────────────────────
        _section('Wilayah Administratif', Icons.map_outlined, [
          WilayahPicker(
            initialSnapshot: _wilayah,
            onChanged: (snap) => setState(() {
              _wilayah = snap;
              _statusKk = null;
            }),
          ),
          const SizedBox(height: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Dusun / Lingkungan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _dusunCtrl,
              decoration: InputDecoration(
                hintText: 'Contoh: Dusun I-A, Lingkungan III (opsional)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: _dusunCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() => _dusunCtrl.clear()),
                )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ]),
        ]),
        const SizedBox(height: 16),

        // ── Identitas KK ───────────────────────────────────────────────────
        _section('Identitas Kepala Keluarga', Icons.home_outlined, [
          FormInput(
            label: 'Nomor KK *',
            hint: 'Nomor Kartu Keluarga (16 digit)',
            initialValue: _nomorKkCtrl.text.isEmpty ? null : _nomorKkCtrl.text,
            keyboardType: TextInputType.number,
            maxLength: 16,
            onChanged: (v) => _nomorKkCtrl.text = v ?? '',
            validator: (v) => (v == null || v.isEmpty) ? 'Nomor KK wajib diisi' : null,
          ),
          const SizedBox(height: 12),

          // ── Status KK — CustomSelectField ──────────────────────────────
          CustomSelectField(
            label: 'Status KK',
            value: _statusKk,
            options: _statusKkOptions,
            onChanged: (v) => setState(() => _statusKk = v),
          ),

          if (_statusKk == '2' || _statusKk == '3') ...[
            const SizedBox(height: 12),
            CustomSelectField(
              label: 'Sudah Urus KK?',
              value: _sudahUrusKk,
              options: const [
                {'value': '1', 'label': 'Sudah'},
                {'value': '2', 'label': 'Belum'},
              ],
              onChanged: (v) => setState(() => _sudahUrusKk = v),
            ),
          ],
        ]),
        const SizedBox(height: 16),

        // ── Lokasi ─────────────────────────────────────────────────────────
        _section('Lokasi Rumah', Icons.location_on_outlined, [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _getLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.my_location, size: 18),
              label: Text(_isLoadingLocation ? 'Mengambil lokasi...' : 'Ambil Lokasi GPS'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13)),
            ),
          ),
          if (_lokasiRumah != null) ...[const SizedBox(height: 12), _lokasiPreview()]
          else Padding(padding: const EdgeInsets.only(top: 8),
              child: Text('Opsional – tekan tombol untuk menandai lokasi', style: TextStyle(fontSize: 11, color: Colors.grey[500]))),
        ]),
      ]),
    );
  }

  Widget _waktuButton({required String label, required IconData icon, required Color color,
    required DateTime? recorded, required VoidCallback onTap, required VoidCallback onReset}) {
    return GestureDetector(
      onTap: recorded == null ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: recorded != null ? color.withOpacity(0.08) : Colors.white,
          border: Border.all(color: recorded != null ? color : Colors.grey[300]!, width: recorded != null ? 1.5 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: recorded != null
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            Text(_fmtDateTime(recorded), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const Text('Tekan untuk mencatat waktu sekarang', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
          if (recorded != null)
            IconButton(icon: const Icon(Icons.refresh, size: 18, color: Colors.grey), onPressed: onReset)
          else Icon(Icons.touch_app_outlined, color: color.withOpacity(0.6), size: 20),
        ]),
      ),
    );
  }

  Widget _lokasiPreview() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(borderRadius: BorderRadius.circular(10),
          child: SizedBox(height: 150, child: _MapWidget(lat: _mapLat!, lng: _mapLng!, interactive: false, onPicked: (_, __) {}))),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.check_circle, size: 14, color: AppTheme.accentGreen),
        const SizedBox(width: 6),
        Expanded(child: Text('Lat: ${_mapLat?.toStringAsFixed(5)},  Lng: ${_mapLng?.toStringAsFixed(5)}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
        TextButton.icon(onPressed: _showPeta, icon: const Icon(Icons.open_in_full, size: 14),
            label: const Text('Perluas', style: TextStyle(fontSize: 11)),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 30))),
        IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.grey),
            onPressed: () => setState(() { _lokasiRumah = null; _mapLat = null; _mapLng = null; })),
      ]),
      if (_lokasiRumah?['accuracy'] != null && (_lokasiRumah!['accuracy'] as num) > 0)
        Text('Akurasi GPS: ±${(_lokasiRumah!['accuracy'] as num).toStringAsFixed(0)} m',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ]);
  }

  // ─── STEP 2 ───────────────────────────────────────────────────────────────

  Widget _step2() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppTheme.primaryBlue.withOpacity(0.06),
        child: const Row(children: [
          Icon(Icons.info_outline, size: 16, color: AppTheme.primaryBlue),
          SizedBox(width: 8),
          Expanded(child: Text('Isian bersifat opsional kecuali Nomor KK. Detail pekerjaan muncul jika status pekerjaan "Sudah Bekerja".',
              style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue))),
        ]),
      ),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _anggotaList.length + 1,
        itemBuilder: (_, i) {
          if (i == _anggotaList.length) return _addBtn();
          return _anggotaCard(i);
        },
      )),
    ]);
  }

  Widget _anggotaCard(int idx) {
    final data = _anggotaList[idx];
    final nama = (data['r_201'] ?? '').toString();
    final kel = data['r_203'];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: idx == 0,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          title: Row(children: [
            Container(width: 32, height: 32,
                decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('${idx+1}', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nama.isEmpty ? 'Anggota ${idx+1}' : nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              if (kel != null) Text(_kelLabel(kel), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ])),
          ]),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (idx > 0)
              IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 20),
                  onPressed: () => setState(() => _anggotaList.removeAt(idx))),
            const Icon(Icons.expand_more),
          ]),
          children: [Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: _anggotaFields(data, context),
          )],
        ),
      ),
    );
  }

  String _kelLabel(String code) {
    const m = {'1':'Kepala Keluarga','2':'Istri/Suami','3':'Anak Kandung','4':'Anak Tiri/Angkat','5':'Orang Tua/Mertua','6':'Famili Lain'};
    return m[code] ?? code;
  }

  Widget _anggotaFields(Map<String, dynamic> data, BuildContext rootContext) {
    final bool sudahBekerja = data['r_300_pekerjaan'] == '2';
    final bool berdomisili = data['r_210'] == '1';
    final int? usia = data['r_207_usia'] as int?;
    final bool usiaKerja = (usia ?? 0) >= 15;
    final bool tampilPekerjaan = berdomisili && usiaKerja && sudahBekerja;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Divider(height: 1), const SizedBox(height: 12),
      FormInput(label: 'Nama Lengkap', hint: 'Nama sesuai KTP', initialValue: data['r_201'], onChanged: (v) => data['r_201'] = v),
      const SizedBox(height: 10),
      FormInput(label: 'NIK', hint: '16 digit', initialValue: data['r_202'], keyboardType: TextInputType.number, maxLength: 16, onChanged: (v) => data['r_202'] = v),
      const SizedBox(height: 10),
      // ── All dropdowns now use CustomSelectField via FormDropdown alias ──
      FormDropdown(label: 'Status dalam Keluarga', value: data['r_203'], options: AppConstants.statusKeluargaOptions, onChanged: (v) => setState(() => data['r_203'] = v)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: FormDropdown(label: 'Jenis Kelamin', value: data['r_205'], options: AppConstants.jenisKelaminOptions, onChanged: (v) => setState(() => data['r_205'] = v))),
        const SizedBox(width: 10),
        Expanded(child: FormDropdown(label: 'Status Perkawinan', value: data['r_204'], options: AppConstants.statusPerkawinanOptions, onChanged: (v) => setState(() => data['r_204'] = v))),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: FormInput(label: 'Tempat Lahir', initialValue: data['r_206'], onChanged: (v) => data['r_206'] = v)),
        const SizedBox(width: 10),
        Expanded(child: _tglLahirPicker(data, rootContext)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: FormInput(label: 'Usia (tahun)', hint: 'Isi jika tgl lahir tidak diketahui', initialValue: data['r_207_usia']?.toString(),
            keyboardType: TextInputType.number, onChanged: (v) => setState(() => data['r_207_usia'] = int.tryParse(v ?? '')))),
        const SizedBox(width: 10),
        Expanded(child: FormInput(label: 'Suku/Etnis', initialValue: data['r_208'], onChanged: (v) => data['r_208'] = v)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: FormDropdown(label: 'Kewarganegaraan', value: data['r_209'],
            options: const [{'value':'1','label':'WNI'},{'value':'2','label':'WNA'}], onChanged: (v) => setState(() => data['r_209'] = v))),
        const SizedBox(width: 10),
        Expanded(child: FormDropdown(label: 'Keberadaan', value: data['r_210'], options: AppConstants.keberadaanOptions, onChanged: (v) => setState(() => data['r_210'] = v))),
      ]),
      const SizedBox(height: 10),
      FormDropdown(label: 'Pendidikan Terakhir', value: data['r_212'], options: AppConstants.pendidikanOptions, onChanged: (v) => setState(() => data['r_212'] = v)),
      const SizedBox(height: 10),
      FormDropdown(label: 'Status Pekerjaan', value: data['r_300_pekerjaan'], options: AppConstants.statusPekerjaanOptions, onChanged: (v) => setState(() => data['r_300_pekerjaan'] = v)),
      const SizedBox(height: 12),
      _disabilitas(data),
      if (tampilPekerjaan) ...[const SizedBox(height: 16), _sectionHeader('Detail Pekerjaan', Icons.work_outline), const SizedBox(height: 8), _pekerjaanFields(data)]
      else if (sudahBekerja && (!berdomisili || !usiaKerja)) ...[
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withOpacity(0.3))),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.orange), const SizedBox(width: 8),
              Expanded(child: Text(!berdomisili ? 'Detail pekerjaan hanya untuk penduduk yang berdomisili.' : 'Detail pekerjaan hanya untuk usia 15 tahun ke atas.',
                  style: const TextStyle(fontSize: 11, color: Colors.orange))),
            ])),
      ],
    ]);
  }

  Widget _pekerjaanFields(Map<String, dynamic> data) {
    return FormDropdown(
      label: 'Bekerja Sebagai *',
      value: data['r_301_usaha_buruh_pekerjaBebas'],
      options: const [
        {'value': '1', 'label': 'Berusaha/Pemilik Usaha'},
        {'value': '2', 'label': 'Buruh/Pegawai'},
        {'value': '3', 'label': 'Pekerja Bebas'},
      ],
      onChanged: (v) => setState(() {
        data['r_301_usaha_buruh_pekerjaBebas'] = v;
        data['r_301'] = null; data['r_307'] = null; data['r_311'] = null;
      }),
      validator: (v) => (data['r_300_pekerjaan'] == '2' && v == null) ? 'Pilih tipe pekerjaan' : null,
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: AppTheme.primaryBlue), const SizedBox(width: 6),
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
    ]),
  );

  Widget _tglLahirPicker(Map<String, dynamic> data, BuildContext rootContext) {
    final tglStr = data['r_207']?.toString();
    DateTime? tgl = tglStr != null ? DateTime.tryParse(tglStr) : null;
    return InkWell(
      onTap: () async {
        final p = await showDatePicker(context: rootContext, initialDate: tgl ?? DateTime(1990), firstDate: DateTime(1900), lastDate: DateTime.now());
        if (p != null) {
          final now = DateTime.now();
          final usia = now.year - p.year - ((now.month < p.month || (now.month == p.month && now.day < p.day)) ? 1 : 0);
          setState(() { data['r_207'] = p.toIso8601String().split('T')[0]; data['r_207_usia'] = usia; });
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tanggal Lahir', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(tgl != null ? _fmtTanggal(tgl) : 'Pilih tanggal',
              style: TextStyle(fontSize: 13, color: tgl != null ? AppTheme.textPrimary : Colors.grey[400])),
        ]),
      ),
    );
  }

  Widget _disabilitas(Map<String, dynamic> data) {
    final sel = List<String>.from(data['r_211'] as List? ?? []);
    const opts = {'1':'Penglihatan','2':'Pendengaran','3':'Berjalan/Naik Tangga','4':'Tangan/Jari','5':'Mengingat/Konsentrasi','6':'Merawat Diri','7':'Komunikasi','8':'Perilaku/Emosi'};
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8), color: Colors.grey[50]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Disabilitas (pilih semua yang sesuai)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 4, children: opts.entries.map((e) {
          final isSel = sel.contains(e.key);
          return FilterChip(
            label: Text(e.value, style: const TextStyle(fontSize: 11)),
            selected: isSel,
            onSelected: (v) => setState(() { v ? sel.add(e.key) : sel.remove(e.key); data['r_211'] = sel; }),
            selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
            checkmarkColor: AppTheme.primaryBlue,
            labelStyle: TextStyle(color: isSel ? AppTheme.primaryBlue : AppTheme.textSecondary),
            padding: EdgeInsets.zero,
          );
        }).toList()),
      ]),
    );
  }

  Widget _addBtn() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: OutlinedButton.icon(
      onPressed: () => setState(() => _anggotaList.add(_emptyAnggota())),
      icon: const Icon(Icons.person_add_outlined),
      label: const Text('Tambah Anggota Keluarga'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppTheme.primaryBlue), foregroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    ),
  );

  // ─── STEP 3 ───────────────────────────────────────────────────────────────

  Widget _step3(dynamic user) {
    final isi = _anggotaList.where((a) => (a['r_201']??'').toString().isNotEmpty).length;
    final totalL = _anggotaList.where((a) => a['r_205']=='1').length;
    final totalP = _anggotaList.where((a) => a['r_205']=='2').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _section('Ringkasan Data', Icons.summarize_outlined, [
          _row('Provinsi',  _wilayah.namaProvinsi ?? '-'),
          _row('Kab/Kota',  _wilayah.namaKabupaten ?? '-'),
          _row('Kecamatan', _wilayah.namaKecamatan ?? '-'),
          _row('Desa',      _wilayah.namaDesa ?? '-'),
          if (_dusunCtrl.text.trim().isNotEmpty) _row('Dusun', _dusunCtrl.text.trim()),
          _row('Nomor KK',  _nomorKkCtrl.text.isEmpty ? '-' : _nomorKkCtrl.text),
          _row('Jumlah Anggota', '$isi orang  ($totalL L / $totalP P)'),
          if (_lokasiRumah != null) _row('Lokasi', 'Lat ${_mapLat?.toStringAsFixed(5)}, Lng ${_mapLng?.toStringAsFixed(5)}'),
        ]),
        const SizedBox(height: 12),

        _section('Waktu Wawancara', Icons.schedule_outlined, [
          if (_waktuMulai != null) _infoChip(Icons.play_circle_outline, AppTheme.accentGreen, 'Mulai', _fmtDateTime(_waktuMulai!)),
          if (_waktuMulai != null) const SizedBox(height: 8),
          _waktuButton(label: 'Catat Waktu Selesai', icon: Icons.stop_circle_outlined,
              color: AppTheme.accentRed, recorded: _waktuAkhir,
              onTap: () => setState(() { _waktuAkhir = DateTime.now(); _snack('Waktu selesai: ${_fmtDateTime(_waktuAkhir!)}'); }),
              onReset: () => setState(() => _waktuAkhir = null)),
          if (_waktuMulai != null && _waktuAkhir != null) ...[const SizedBox(height: 8), _durasiChip()],
        ]),
        const SizedBox(height: 12),

        if (_lokasiRumah != null) ...[
          _section('Lokasi Rumah', Icons.location_on_outlined, [
            ClipRRect(borderRadius: BorderRadius.circular(10),
                child: SizedBox(height: 130, child: _MapWidget(lat: _mapLat!, lng: _mapLng!, interactive: false, onPicked: (_, __) {}))),
            const SizedBox(height: 6),
            TextButton.icon(onPressed: _showPeta, icon: const Icon(Icons.map_outlined, size: 14), label: const Text('Buka di Peta Penuh', style: TextStyle(fontSize: 12))),
          ]),
          const SizedBox(height: 12),
        ],

        _section('Keterangan', Icons.notes_outlined, [
          TextFormField(
            controller: _keteranganCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Catatan tambahan (opsional)',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(12),
              filled: true, fillColor: Colors.white,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _section('Petugas', Icons.person_outline, [
          _row('Nama', user?.name ?? '-'),
          _row('Email', user?.email ?? '-'),
        ]),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _infoChip(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.25))),
      child: Row(children: [
        Icon(icon, size: 16, color: color), const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 12, color: color)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _durasiChip() {
    final durasi = _waktuAkhir!.difference(_waktuMulai!);
    if (durasi.isNegative) return const SizedBox.shrink();
    final jam = durasi.inHours; final menit = durasi.inMinutes % 60;
    final label = jam > 0 ? '${jam}j ${menit}m' : '${menit} menit';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.timer_outlined, size: 14, color: AppTheme.primaryBlue), const SizedBox(width: 4),
        Text('Durasi: $label', style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue)),
      ]),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 16, color: AppTheme.primaryBlue), const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))]),
        const SizedBox(height: 12), ...children,
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
      const Text(': ', style: TextStyle(color: AppTheme.textSecondary)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
    ]),
  );

  Widget _bottomBar() {
    final saving = context.watch<QuestionnaireProvider>().isSaving;
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Row(children: [
        if (_currentStep > 0) ...[
          Expanded(child: OutlinedButton(onPressed: _prev,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Kembali'))),
          const SizedBox(width: 12),
        ],
        Expanded(flex: 2, child: ElevatedButton(
          onPressed: saving ? null : (_currentStep < 2 ? _next : _submit),
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48),
              backgroundColor: _currentStep == 2 ? AppTheme.accentGreen : AppTheme.primaryBlue,
              foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(_currentStep == 0 ? 'Lanjut ke Anggota →' : _currentStep == 1 ? 'Lanjut ke Konfirmasi →' : '✓  Simpan Data',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        )),
      ]),
    );
  }
}

// ─── Map Widget ───────────────────────────────────────────────────────────────

class _MapWidget extends StatefulWidget {
  final double lat; final double lng;
  final Function(double, double) onPicked;
  final bool interactive;
  const _MapWidget({required this.lat, required this.lng, required this.onPicked, this.interactive = true});
  @override
  State<_MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<_MapWidget> {
  late final MapController _mapController;
  late double _markerLat; late double _markerLng;
  static const String _googleHybridUrl = 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _markerLat = widget.lat; _markerLng = widget.lng;
  }

  @override
  void dispose() { _mapController.dispose(); super.dispose(); }

  void _onMapTap(TapPosition tap, LatLng point) {
    if (!widget.interactive) return;
    setState(() { _markerLat = point.latitude; _markerLng = point.longitude; });
    widget.onPicked(point.latitude, point.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(center: LatLng(widget.lat, widget.lng), zoom: widget.interactive ? 18.0 : 17.0,
            maxZoom: 20, minZoom: 5, onTap: widget.interactive ? _onMapTap : null),
        children: [
          TileLayer(urlTemplate: _googleHybridUrl, userAgentPackageName: 'com.example.village_survey', maxZoom: 20),
          MarkerLayer(markers: [
            Marker(point: LatLng(_markerLat, _markerLng), width: 40, height: 40,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40)),
          ]),
        ],
      ),
      Positioned(bottom: 8, left: 0, right: 0, child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
          child: Text('${_markerLat.toStringAsFixed(6)}, ${_markerLng.toStringAsFixed(6)}',
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
      )),
      if (widget.interactive) ...[
        Positioned(top: 8, right: 8, child: ElevatedButton.icon(
          onPressed: () => widget.onPicked(_markerLat, _markerLng),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Pilih Lokasi Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B6BA8), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 3),
        )),
        Positioned(top: 8, left: 8, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(8)),
          child: const Text('Tap peta untuk pindah pin', style: TextStyle(color: Colors.white, fontSize: 10)),
        )),
      ],
    ]);
  }
}