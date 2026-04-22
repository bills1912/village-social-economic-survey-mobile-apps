// lib/widgets/wilayah_picker.dart
import 'package:flutter/material.dart';
import '../models/wilayah.dart';
import '../services/wilayah_service.dart';
import '../utils/app_theme.dart';

/// Widget cascading dropdown: Provinsi → Kabupaten/Kota → Kecamatan → Desa.
///
/// Usage:
/// ```dart
/// WilayahPicker(
///   initialSnapshot: _wilayah,
///   onChanged: (snapshot) => setState(() => _wilayah = snapshot),
/// )
/// ```
class WilayahPicker extends StatefulWidget {
  final WilayahSnapshot initialSnapshot;
  final ValueChanged<WilayahSnapshot> onChanged;
  final bool required;

  const WilayahPicker({
    super.key,
    required this.initialSnapshot,
    required this.onChanged,
    this.required = true,
  });

  @override
  State<WilayahPicker> createState() => _WilayahPickerState();
}

class _WilayahPickerState extends State<WilayahPicker> {
  final _svc = WilayahService.instance;

  List<WilayahItem> _provinsi = [];
  List<WilayahItem> _kabupaten = [];
  List<WilayahItem> _kecamatan = [];
  List<WilayahItem> _desa = [];

  WilayahItem? _selProvinsi;
  WilayahItem? _selKabupaten;
  WilayahItem? _selKecamatan;
  WilayahItem? _selDesa;

  bool _loadingProv = false;
  bool _loadingKab = false;
  bool _loadingKec = false;
  bool _loadingDesa = false;

  @override
  void initState() {
    super.initState();
    _loadProvinsi();
  }

  Future<void> _loadProvinsi() async {
    setState(() => _loadingProv = true);
    _provinsi = await _svc.fetchProvinsi();
    // Restore initial selection
    final snap = widget.initialSnapshot;
    if (snap.kodeProvinsi != null) {
      _selProvinsi = _provinsi.cast<WilayahItem?>().firstWhere(
            (p) => p?.kode == snap.kodeProvinsi,
        orElse: () => null,
      );
      if (_selProvinsi != null) {
        await _loadKabupaten(snap.kodeProvinsi!, restoreKode: snap.kodeKabupaten);
      }
    }
    if (mounted) setState(() => _loadingProv = false);
  }

  Future<void> _loadKabupaten(String kodeProv,
      {String? restoreKode}) async {
    setState(() {
      _loadingKab = true;
      _kabupaten = [];
      _kecamatan = [];
      _desa = [];
      _selKabupaten = null;
      _selKecamatan = null;
      _selDesa = null;
    });
    _kabupaten = await _svc.fetchKabupaten(kodeProv);
    if (restoreKode != null) {
      _selKabupaten = _kabupaten.cast<WilayahItem?>().firstWhere(
            (k) => k?.kode == restoreKode,
        orElse: () => null,
      );
      if (_selKabupaten != null) {
        final snap = widget.initialSnapshot;
        await _loadKecamatan(restoreKode, restoreKode: snap.kodeKecamatan);
      }
    }
    if (mounted) setState(() => _loadingKab = false);
  }

  Future<void> _loadKecamatan(String kodeKab,
      {String? restoreKode}) async {
    setState(() {
      _loadingKec = true;
      _kecamatan = [];
      _desa = [];
      _selKecamatan = null;
      _selDesa = null;
    });
    _kecamatan = await _svc.fetchKecamatan(kodeKab);
    if (restoreKode != null) {
      _selKecamatan = _kecamatan.cast<WilayahItem?>().firstWhere(
            (k) => k?.kode == restoreKode,
        orElse: () => null,
      );
      if (_selKecamatan != null) {
        final snap = widget.initialSnapshot;
        await _loadDesa(restoreKode, restoreKode: snap.kodeDesa);
      }
    }
    if (mounted) setState(() => _loadingKec = false);
  }

  Future<void> _loadDesa(String kodeKec, {String? restoreKode}) async {
    setState(() {
      _loadingDesa = true;
      _desa = [];
      _selDesa = null;
    });
    _desa = await _svc.fetchDesa(kodeKec);
    if (restoreKode != null) {
      _selDesa = _desa.cast<WilayahItem?>().firstWhere(
            (d) => d?.kode == restoreKode,
        orElse: () => null,
      );
    }
    if (mounted) setState(() => _loadingDesa = false);
  }

  void _onDesaChanged(WilayahItem? desa) {
    setState(() => _selDesa = desa);
    widget.onChanged(WilayahSnapshot(
      kodeProvinsi: _selProvinsi?.kode,
      namaProvinsi: _selProvinsi?.nama,
      kodeKabupaten: _selKabupaten?.kode,
      namaKabupaten: _selKabupaten?.nama,
      kodeKecamatan: _selKecamatan?.kode,
      namaKecamatan: _selKecamatan?.nama,
      kodeDesa: desa?.kode,
      namaDesa: desa?.nama,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Provinsi', required: widget.required),
        const SizedBox(height: 6),
        _buildDropdown<WilayahItem>(
          items: _provinsi,
          value: _selProvinsi,
          hint: 'Pilih Provinsi',
          loading: _loadingProv,
          validator: widget.required
              ? (v) => v == null ? 'Pilih provinsi' : null
              : null,
          onChanged: (val) {
            setState(() => _selProvinsi = val);
            if (val != null) {
              _loadKabupaten(val.kode);
            }
          },
        ),
        const SizedBox(height: 12),

        _buildLabel('Kabupaten / Kota', required: widget.required),
        const SizedBox(height: 6),
        _buildDropdown<WilayahItem>(
          items: _kabupaten,
          value: _selKabupaten,
          hint: _selProvinsi == null ? 'Pilih provinsi dulu' : 'Pilih Kabupaten/Kota',
          loading: _loadingKab,
          enabled: _selProvinsi != null,
          validator: widget.required
              ? (v) => v == null ? 'Pilih kabupaten/kota' : null
              : null,
          onChanged: (val) {
            setState(() => _selKabupaten = val);
            if (val != null) _loadKecamatan(val.kode);
          },
        ),
        const SizedBox(height: 12),

        _buildLabel('Kecamatan', required: widget.required),
        const SizedBox(height: 6),
        _buildDropdown<WilayahItem>(
          items: _kecamatan,
          value: _selKecamatan,
          hint: _selKabupaten == null ? 'Pilih kabupaten dulu' : 'Pilih Kecamatan',
          loading: _loadingKec,
          enabled: _selKabupaten != null,
          validator: widget.required
              ? (v) => v == null ? 'Pilih kecamatan' : null
              : null,
          onChanged: (val) {
            setState(() => _selKecamatan = val);
            if (val != null) _loadDesa(val.kode);
          },
        ),
        const SizedBox(height: 12),

        _buildLabel('Desa / Kelurahan', required: widget.required),
        const SizedBox(height: 6),
        _buildDropdown<WilayahItem>(
          items: _desa,
          value: _selDesa,
          hint: _selKecamatan == null ? 'Pilih kecamatan dulu' : 'Pilih Desa/Kelurahan',
          loading: _loadingDesa,
          enabled: _selKecamatan != null,
          validator: widget.required
              ? (v) => v == null ? 'Pilih desa/kelurahan' : null
              : null,
          onChanged: _onDesaChanged,
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = false}) => RichText(
    text: TextSpan(
      text: text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppTheme.textPrimary,
      ),
      children: [
        if (required)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: AppTheme.accentRed),
          ),
      ],
    ),
  );

  Widget _buildDropdown<T>({
    required List<T> items,
    required T? value,
    required String hint,
    required ValueChanged<T?> onChanged,
    bool loading = false,
    bool enabled = true,
    String? Function(T?)? validator,
  }) {
    if (loading) {
      return Container(
        height: 48,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Memuat...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      validator: validator,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabled: enabled,
        fillColor: enabled ? Colors.white : Colors.grey[50],
        filled: true,
      ),
      hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
      items: items
          .map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(item.toString(), style: const TextStyle(fontSize: 13)),
      ))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}