// lib/models/wilayah.dart

/// Satu entri wilayah administratif (provinsi / kab/kota / kecamatan / desa).
class WilayahItem {
  final String kode;
  final String nama;
  final String tipe;
  final String? parentKode;

  const WilayahItem({
    required this.kode,
    required this.nama,
    required this.tipe,
    this.parentKode,
  });

  factory WilayahItem.fromJson(Map<String, dynamic> json) => WilayahItem(
    kode: json['kode']?.toString() ?? '',
    nama: json['nama']?.toString() ?? '',
    tipe: json['tipe']?.toString() ?? '',
    parentKode: json['parent_kode']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'kode': kode,
    'nama': nama,
    'tipe': tipe,
    if (parentKode != null) 'parent_kode': parentKode,
  };

  @override
  String toString() => nama;

  @override
  bool operator ==(Object other) =>
      other is WilayahItem && other.kode == kode;

  @override
  int get hashCode => kode.hashCode;
}

/// Snapshot wilayah lengkap yang disimpan bersama kuesioner.
class WilayahSnapshot {
  final String? kodeProvinsi;
  final String? namaProvinsi;
  final String? kodeKabupaten;
  final String? namaKabupaten;
  final String? kodeKecamatan;
  final String? namaKecamatan;
  final String? kodeDesa;
  final String? namaDesa;

  const WilayahSnapshot({
    this.kodeProvinsi,
    this.namaProvinsi,
    this.kodeKabupaten,
    this.namaKabupaten,
    this.kodeKecamatan,
    this.namaKecamatan,
    this.kodeDesa,
    this.namaDesa,
  });

  bool get isComplete =>
      kodeProvinsi != null &&
          kodeKabupaten != null &&
          kodeKecamatan != null &&
          kodeDesa != null;

  /// Label ringkas untuk ditampilkan di card/list
  String get shortLabel => namaDesa ?? '-';

  /// Label lengkap: Desa, Kecamatan, Kabupaten, Provinsi
  String get fullLabel {
    final parts = <String>[
      if (namaDesa != null) namaDesa!,
      if (namaKecamatan != null) namaKecamatan!,
      if (namaKabupaten != null) namaKabupaten!,
      if (namaProvinsi != null) namaProvinsi!,
    ];
    return parts.join(', ');
  }

  factory WilayahSnapshot.fromJson(Map<String, dynamic> json) =>
      WilayahSnapshot(
        kodeProvinsi: json['kode_provinsi']?.toString(),
        namaProvinsi: json['nama_provinsi']?.toString(),
        kodeKabupaten: json['kode_kabupaten']?.toString(),
        namaKabupaten: json['nama_kabupaten']?.toString(),
        kodeKecamatan: json['kode_kecamatan']?.toString(),
        namaKecamatan: json['nama_kecamatan']?.toString(),
        kodeDesa: json['kode_desa']?.toString(),
        namaDesa: json['nama_desa']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    if (kodeProvinsi != null) 'kode_provinsi': kodeProvinsi,
    if (namaProvinsi != null) 'nama_provinsi': namaProvinsi,
    if (kodeKabupaten != null) 'kode_kabupaten': kodeKabupaten,
    if (namaKabupaten != null) 'nama_kabupaten': namaKabupaten,
    if (kodeKecamatan != null) 'kode_kecamatan': kodeKecamatan,
    if (namaKecamatan != null) 'nama_kecamatan': namaKecamatan,
    if (kodeDesa != null) 'kode_desa': kodeDesa,
    if (namaDesa != null) 'nama_desa': namaDesa,
  };

  WilayahSnapshot copyWith({
    String? kodeProvinsi,
    String? namaProvinsi,
    String? kodeKabupaten,
    String? namaKabupaten,
    String? kodeKecamatan,
    String? namaKecamatan,
    String? kodeDesa,
    String? namaDesa,
  }) =>
      WilayahSnapshot(
        kodeProvinsi: kodeProvinsi ?? this.kodeProvinsi,
        namaProvinsi: namaProvinsi ?? this.namaProvinsi,
        kodeKabupaten: kodeKabupaten ?? this.kodeKabupaten,
        namaKabupaten: namaKabupaten ?? this.namaKabupaten,
        kodeKecamatan: kodeKecamatan ?? this.kodeKecamatan,
        namaKecamatan: namaKecamatan ?? this.namaKecamatan,
        kodeDesa: kodeDesa ?? this.kodeDesa,
        namaDesa: namaDesa ?? this.namaDesa,
      );

  /// Snapshot kosong
  static const empty = WilayahSnapshot();
}