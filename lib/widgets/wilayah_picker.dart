// lib/widgets/wilayah_picker.dart
import 'package:flutter/material.dart';
import '../models/wilayah.dart';
import '../services/wilayah_service.dart';
import '../utils/app_theme.dart';
import 'form_widgets.dart';

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

  // ── Konversi WilayahItem → format options CustomSelectField ──────────────
  List<Map<String, String>> _toOptions(List<WilayahItem> items) =>
      items.map((e) => {'value': e.kode, 'label': e.nama}).toList();

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
        await _loadKabupaten(snap.kodeProvinsi!,
            restoreKode: snap.kodeKabupaten);
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
        await _loadKecamatan(restoreKode,
            restoreKode: snap.kodeKecamatan);
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

  // ── Helpers mencari WilayahItem dari kode ─────────────────────────────────
  WilayahItem? _findByKode(List<WilayahItem> list, String? kode) =>
      kode == null
          ? null
          : list.cast<WilayahItem?>().firstWhere(
            (i) => i?.kode == kode,
        orElse: () => null,
      );

  void _emitChange() {
    widget.onChanged(WilayahSnapshot(
      kodeProvinsi: _selProvinsi?.kode,
      namaProvinsi: _selProvinsi?.nama,
      kodeKabupaten: _selKabupaten?.kode,
      namaKabupaten: _selKabupaten?.nama,
      kodeKecamatan: _selKecamatan?.kode,
      namaKecamatan: _selKecamatan?.nama,
      kodeDesa: _selDesa?.kode,
      namaDesa: _selDesa?.nama,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Provinsi ────────────────────────────────────────────────────────
        _loadingProv
            ? _loadingField('Provinsi')
            : CustomSelectField(
          label: 'Provinsi',
          value: _selProvinsi?.kode,
          options: _toOptions(_provinsi),
          isRequired: widget.required,
          onChanged: (kode) {
            final item = _findByKode(_provinsi, kode);
            setState(() => _selProvinsi = item);
            if (item != null) _loadKabupaten(item.kode);
            _emitChange();
          },
          validator: widget.required
              ? (v) => v == null ? 'Pilih provinsi' : null
              : null,
        ),
        const SizedBox(height: 12),

        // ── Kabupaten / Kota ─────────────────────────────────────────────────
        _loadingKab
            ? _loadingField('Kabupaten / Kota')
            : _DisabledWrapper(
          disabled: _selProvinsi == null,
          hint: 'Pilih provinsi dulu',
          child: CustomSelectField(
            label: 'Kabupaten / Kota',
            value: _selKabupaten?.kode,
            options: _toOptions(_kabupaten),
            isRequired: widget.required,
            onChanged: _selProvinsi == null
                ? (_) {}
                : (kode) {
              final item = _findByKode(_kabupaten, kode);
              setState(() => _selKabupaten = item);
              if (item != null) _loadKecamatan(item.kode);
              _emitChange();
            },
            validator: widget.required
                ? (v) => v == null ? 'Pilih kabupaten/kota' : null
                : null,
          ),
        ),
        const SizedBox(height: 12),

        // ── Kecamatan ────────────────────────────────────────────────────────
        _loadingKec
            ? _loadingField('Kecamatan')
            : _DisabledWrapper(
          disabled: _selKabupaten == null,
          hint: 'Pilih kabupaten dulu',
          child: CustomSelectField(
            label: 'Kecamatan',
            value: _selKecamatan?.kode,
            options: _toOptions(_kecamatan),
            isRequired: widget.required,
            onChanged: _selKabupaten == null
                ? (_) {}
                : (kode) {
              final item = _findByKode(_kecamatan, kode);
              setState(() => _selKecamatan = item);
              if (item != null) _loadDesa(item.kode);
              _emitChange();
            },
            validator: widget.required
                ? (v) => v == null ? 'Pilih kecamatan' : null
                : null,
          ),
        ),
        const SizedBox(height: 12),

        // ── Desa / Kelurahan ─────────────────────────────────────────────────
        _loadingDesa
            ? _loadingField('Desa / Kelurahan')
            : _DisabledWrapper(
          disabled: _selKecamatan == null,
          hint: 'Pilih kecamatan dulu',
          child: CustomSelectField(
            label: 'Desa / Kelurahan',
            value: _selDesa?.kode,
            options: _toOptions(_desa),
            isRequired: widget.required,
            onChanged: _selKecamatan == null
                ? (_) {}
                : (kode) {
              final item = _findByKode(_desa, kode);
              setState(() => _selDesa = item);
              _emitChange();
            },
            validator: widget.required
                ? (v) => v == null ? 'Pilih desa/kelurahan' : null
                : null,
          ),
        ),
      ],
    );
  }

  /// Skeleton field saat data sedang di-fetch
  Widget _loadingField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
            children: widget.required
                ? const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppTheme.accentRed),
              )
            ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        Container(
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
              Text(
                'Memuat...',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Helper: tampilkan placeholder jika parent belum dipilih ─────────────────

class _DisabledWrapper extends StatelessWidget {
  final bool disabled;
  final String hint;
  final Widget child;

  const _DisabledWrapper({
    required this.disabled,
    required this.hint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!disabled) return child;

    // Ambil label dari child (CustomSelectField selalu punya label)
    // Tampilkan field tidak aktif dengan hint "Pilih X dulu"
    return IgnorePointer(
      child: Opacity(
        opacity: 1,
        child: AbsorbPointer(
          child: _DisabledField(hint: hint, child: child),
        ),
      ),
    );
  }
}

/// Overlay field disabled — menimpa trigger CustomSelectField dengan
/// warna & hint yang menunjukkan ia belum bisa dipilih
class _DisabledField extends StatelessWidget {
  final String hint;
  final Widget child;

  const _DisabledField({required this.hint, required this.child});

  @override
  Widget build(BuildContext context) {
    // Render child dulu, lalu stack overlay di atas trigger-nya
    // Cara paling sederhana: ganti seluruh trigger dengan container abu-abu
    return Stack(
      children: [
        child,
        // Overlay transparan di atas trigger field (48 px height, skip label)
        Positioned(
          top: 13 + 6, // label height ≈ 13 + SizedBox(height:6)
          left: 0,
          right: 0,
          height: 48,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Colors.grey[350],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}