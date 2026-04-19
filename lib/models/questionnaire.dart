// lib/models/questionnaire.dart
// Model yang sesuai dengan struktur database dari backend PHP/Filament

class AnggotaKeluarga {
  final String? r201;
  final String? r202;
  final String? r203;
  final String? r204;
  final String? r205;
  final String? r206;
  final String? r207;
  final int? r207Usia;
  final String? r208;
  final String? r209;
  final String? r210;
  final List<String>? r211;
  final String? r212;
  final String? r300Pekerjaan;
  final List<PekerjaanData>? pekerjaan;

  // ── Detail pekerjaan (semua field dari form) ──────────────────────────────
  final String? r301UsahaBuruhPekerjaBebas; // tipe: 1=usaha, 2=buruh, 3=pekerja bebas

  // Usaha
  final String? r301;
  final String? r302a; final String? r302b; final String? r302c;
  final String? r302d; final String? r302e; final String? r302f; final String? r302g;
  final String? r303a; final String? r303b; final String? r303c;
  final String? r303d; final String? r303e;
  final String? r304a; final String? r304b; final String? r304c; final String? r304d;
  final String? r305a; final String? r305b; final String? r305c;
  final String? r305d; final String? r305e; final String? r305f;

  // Usaha tambahan
  final String? r306; final String? r301Tambah;
  final String? r302aTambah; final String? r302bTambah; final String? r302cTambah;
  final String? r302dTambah; final String? r302eTambah; final String? r302fTambah; final String? r302gTambah;
  final String? r303aTambah; final String? r303bTambah; final String? r303cTambah;
  final String? r303dTambah; final String? r303eTambah;
  final String? r304aTambah; final String? r304bTambah; final String? r304cTambah; final String? r304dTambah;
  final String? r305aTambah; final String? r305bTambah; final String? r305cTambah;
  final String? r305dTambah; final String? r305eTambah; final String? r305fTambah;

  // Buruh
  final String? r307; final String? r308a; final String? r308b;
  final String? r309a; final String? r309b; final String? r310;
  final String? r307Tambah;
  final String? r308aTambah; final String? r308bTambah;
  final String? r309aTambah; final String? r309bTambah;

  // Pekerja bebas
  final String? r311; final String? r312a; final String? r312b;
  final String? r313a; final String? r313b; final String? r314;
  final String? r311Tambah;
  final String? r312aTambah; final String? r312bTambah;
  final String? r313aTambah; final String? r313bTambah;

  AnggotaKeluarga({
    this.r201, this.r202, this.r203, this.r204, this.r205,
    this.r206, this.r207, this.r207Usia, this.r208, this.r209,
    this.r210, this.r211, this.r212, this.r300Pekerjaan, this.pekerjaan,
    this.r301UsahaBuruhPekerjaBebas,
    this.r301,
    this.r302a, this.r302b, this.r302c, this.r302d, this.r302e, this.r302f, this.r302g,
    this.r303a, this.r303b, this.r303c, this.r303d, this.r303e,
    this.r304a, this.r304b, this.r304c, this.r304d,
    this.r305a, this.r305b, this.r305c, this.r305d, this.r305e, this.r305f,
    this.r306, this.r301Tambah,
    this.r302aTambah, this.r302bTambah, this.r302cTambah,
    this.r302dTambah, this.r302eTambah, this.r302fTambah, this.r302gTambah,
    this.r303aTambah, this.r303bTambah, this.r303cTambah, this.r303dTambah, this.r303eTambah,
    this.r304aTambah, this.r304bTambah, this.r304cTambah, this.r304dTambah,
    this.r305aTambah, this.r305bTambah, this.r305cTambah, this.r305dTambah, this.r305eTambah, this.r305fTambah,
    this.r307, this.r308a, this.r308b, this.r309a, this.r309b, this.r310, this.r307Tambah,
    this.r308aTambah, this.r308bTambah, this.r309aTambah, this.r309bTambah,
    this.r311, this.r312a, this.r312b, this.r313a, this.r313b, this.r314, this.r311Tambah,
    this.r312aTambah, this.r312bTambah, this.r313aTambah, this.r313bTambah,
  });

  factory AnggotaKeluarga.fromJson(Map<String, dynamic> json) {
    return AnggotaKeluarga(
      r201: json['r_201'],
      r202: json['r_202'],
      r203: json['r_203'],
      r204: json['r_204'],
      r205: json['r_205'],
      r206: json['r_206'],
      r207: json['r_207'],
      r207Usia: json['r_207_usia'],
      r208: json['r_208'],
      r209: json['r_209'],
      r210: json['r_210'],
      r211: json['r_211'] != null ? List<String>.from(json['r_211']) : null,
      r212: json['r_212'],
      r300Pekerjaan: json['r_300_pekerjaan'],
      r301UsahaBuruhPekerjaBebas: json['r_301_usaha_buruh_pekerjaBebas'],
      // Usaha
      r301: json['r_301'],
      r302a: json['r_302_a'], r302b: json['r_302_b'], r302c: json['r_302_c'],
      r302d: json['r_302_d'], r302e: json['r_302_e'], r302f: json['r_302_f'], r302g: json['r_302_g'],
      r303a: json['r_303_a'], r303b: json['r_303_b'], r303c: json['r_303_c'],
      r303d: json['r_303_d'], r303e: json['r_303_e'],
      r304a: json['r_304_a'], r304b: json['r_304_b'], r304c: json['r_304_c'], r304d: json['r_304_d'],
      r305a: json['r_305_a'], r305b: json['r_305_b'], r305c: json['r_305_c'],
      r305d: json['r_305_d'], r305e: json['r_305_e'], r305f: json['r_305_f'],
      r306: json['r_306'], r301Tambah: json['r_301_tambah'],
      r302aTambah: json['r_302_a_tambah'], r302bTambah: json['r_302_b_tambah'], r302cTambah: json['r_302_c_tambah'],
      r302dTambah: json['r_302_d_tambah'], r302eTambah: json['r_302_e_tambah'],
      r302fTambah: json['r_302_f_tambah'], r302gTambah: json['r_302_g_tambah'],
      r303aTambah: json['r_303_a_tambah'], r303bTambah: json['r_303_b_tambah'], r303cTambah: json['r_303_c_tambah'],
      r303dTambah: json['r_303_d_tambah'], r303eTambah: json['r_303_e_tambah'],
      r304aTambah: json['r_304_a_tambah'], r304bTambah: json['r_304_b_tambah'],
      r304cTambah: json['r_304_c_tambah'], r304dTambah: json['r_304_d_tambah'],
      r305aTambah: json['r_305_a_tambah'], r305bTambah: json['r_305_b_tambah'], r305cTambah: json['r_305_c_tambah'],
      r305dTambah: json['r_305_d_tambah'], r305eTambah: json['r_305_e_tambah'], r305fTambah: json['r_305_f_tambah'],
      // Buruh
      r307: json['r_307'], r308a: json['r_308_a'], r308b: json['r_308_b'],
      r309a: json['r_309_a'], r309b: json['r_309_b'], r310: json['r_310'],
      r307Tambah: json['r_307_tambah'],
      r308aTambah: json['r_308_a_tambah'], r308bTambah: json['r_308_b_tambah'],
      r309aTambah: json['r_309_a_tambah'], r309bTambah: json['r_309_b_tambah'],
      // Pekerja bebas
      r311: json['r_311'], r312a: json['r_312_a'], r312b: json['r_312_b'],
      r313a: json['r_313_a'], r313b: json['r_313_b'], r314: json['r_314'],
      r311Tambah: json['r_311_tambah'],
      r312aTambah: json['r_312_a_tambah'], r312bTambah: json['r_312_b_tambah'],
      r313aTambah: json['r_313_a_tambah'], r313bTambah: json['r_313_b_tambah'],
    );
  }

  Map<String, dynamic> toJson() => {
    'r_201': r201, 'r_202': r202, 'r_203': r203, 'r_204': r204,
    'r_205': r205, 'r_206': r206, 'r_207': r207, 'r_207_usia': r207Usia,
    'r_208': r208, 'r_209': r209, 'r_210': r210, 'r_211': r211,
    'r_212': r212, 'r_300_pekerjaan': r300Pekerjaan,
    'r_301_usaha_buruh_pekerjaBebas': r301UsahaBuruhPekerjaBebas,
    // Usaha
    'r_301': r301,
    'r_302_a': r302a, 'r_302_b': r302b, 'r_302_c': r302c,
    'r_302_d': r302d, 'r_302_e': r302e, 'r_302_f': r302f, 'r_302_g': r302g,
    'r_303_a': r303a, 'r_303_b': r303b, 'r_303_c': r303c,
    'r_303_d': r303d, 'r_303_e': r303e,
    'r_304_a': r304a, 'r_304_b': r304b, 'r_304_c': r304c, 'r_304_d': r304d,
    'r_305_a': r305a, 'r_305_b': r305b, 'r_305_c': r305c,
    'r_305_d': r305d, 'r_305_e': r305e, 'r_305_f': r305f,
    'r_306': r306, 'r_301_tambah': r301Tambah,
    'r_302_a_tambah': r302aTambah, 'r_302_b_tambah': r302bTambah, 'r_302_c_tambah': r302cTambah,
    'r_302_d_tambah': r302dTambah, 'r_302_e_tambah': r302eTambah,
    'r_302_f_tambah': r302fTambah, 'r_302_g_tambah': r302gTambah,
    'r_303_a_tambah': r303aTambah, 'r_303_b_tambah': r303bTambah, 'r_303_c_tambah': r303cTambah,
    'r_303_d_tambah': r303dTambah, 'r_303_e_tambah': r303eTambah,
    'r_304_a_tambah': r304aTambah, 'r_304_b_tambah': r304bTambah,
    'r_304_c_tambah': r304cTambah, 'r_304_d_tambah': r304dTambah,
    'r_305_a_tambah': r305aTambah, 'r_305_b_tambah': r305bTambah, 'r_305_c_tambah': r305cTambah,
    'r_305_d_tambah': r305dTambah, 'r_305_e_tambah': r305eTambah, 'r_305_f_tambah': r305fTambah,
    // Buruh
    'r_307': r307, 'r_308_a': r308a, 'r_308_b': r308b,
    'r_309_a': r309a, 'r_309_b': r309b, 'r_310': r310,
    'r_307_tambah': r307Tambah,
    'r_308_a_tambah': r308aTambah, 'r_308_b_tambah': r308bTambah,
    'r_309_a_tambah': r309aTambah, 'r_309_b_tambah': r309bTambah,
    // Pekerja bebas
    'r_311': r311, 'r_312_a': r312a, 'r_312_b': r312b,
    'r_313_a': r313a, 'r_313_b': r313b, 'r_314': r314,
    'r_311_tambah': r311Tambah,
    'r_312_a_tambah': r312aTambah, 'r_312_b_tambah': r312bTambah,
    'r_313_a_tambah': r313aTambah, 'r_313_b_tambah': r313bTambah,
  };

  // Helper getters
  String get namaLengkap => r201 ?? '-';
  String get jenisKelaminLabel => r205 == '1' ? 'Laki-laki' : r205 == '2' ? 'Perempuan' : '-';
  String get statusKeluargaLabel {
    switch (r203) {
      case '1': return 'Kepala Keluarga';
      case '2': return 'Istri/Suami';
      case '3': return 'Anak Kandung';
      case '4': return 'Anak Tiri/Angkat';
      case '5': return 'Orang Tua/Mertua';
      case '6': return 'Famili Lain';
      default: return '-';
    }
  }
  String get pendidikanLabel {
    switch (r212) {
      case '1': return 'Tidak Sekolah/Belum Tamat SD';
      case '2': return 'SD/Sederajat';
      case '3': return 'SMP/Sederajat';
      case '4': return 'SMA/Sederajat';
      case '5': return 'D1/D2/D3';
      case '6': return 'S1/S2/S3';
      default: return '-';
    }
  }
}

class PekerjaanData {
  final String? tipe;
  final String? sektor;
  final Map<String, dynamic>? detailData;

  PekerjaanData({this.tipe, this.sektor, this.detailData});

  factory PekerjaanData.fromJson(Map<String, dynamic> json) => PekerjaanData(
    tipe: json['tipe'],
    sektor: json['sektor'],
    detailData: json['detail'],
  );

  Map<String, dynamic> toJson() => {
    'tipe': tipe, 'sektor': sektor, 'detail': detailData,
  };
}

class Questionnaire {
  final String? id;
  final String? surveyId;
  final String namaPetugas;
  final String? kelompokDasaWisma;
  final Map<String, dynamic>? lokasiRumah;
  final String? waktuPendataan;
  final String dusun;
  final String r102;
  final String? r103;
  final String? r104;
  final List<AnggotaKeluarga> r200;
  final String? r401;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Questionnaire({
    this.id,
    this.surveyId,
    required this.namaPetugas,
    this.kelompokDasaWisma,
    this.lokasiRumah,
    this.waktuPendataan,
    required this.dusun,
    required this.r102,
    this.r103,
    this.r104,
    required this.r200,
    this.r401,
    this.createdAt,
    this.updatedAt,
  });

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    List<AnggotaKeluarga> anggota = [];
    if (json['r_200'] != null) {
      if (json['r_200'] is List) {
        anggota = (json['r_200'] as List)
            .map((e) => AnggotaKeluarga.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return Questionnaire(
      id: json["id"]?.toString(),
      surveyId: json['survey_id']?.toString(),
      namaPetugas: json['nama_petugas'] ?? '',
      kelompokDasaWisma: json['kelompok_dasa_wisma'],
      lokasiRumah: json['lokasi_rumah'],
      waktuPendataan: json['waktu_pendataan'],
      dusun: json['dusun'] ?? '',
      r102: json['r_102'] ?? '',
      r103: json['r_103'],
      r104: json['r_104'],
      r200: anggota,
      r401: json['r_401'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'survey_id': surveyId,
    'nama_petugas': namaPetugas,
    'kelompok_dasa_wisma': kelompokDasaWisma,
    'lokasi_rumah': lokasiRumah,
    'waktu_pendataan': waktuPendataan,
    'dusun': dusun,
    'r_102': r102,
    'r_103': r103,
    'r_104': r104,
    'r_200': r200.map((e) => e.toJson()).toList(),
    'r_401': r401,
  };

  // Helpers
  String get dusunLabel {
    switch (dusun) {
      case '1': return 'Dusun I-A';
      case '2': return 'Dusun I-B';
      case '3': return 'Dusun II Timur';
      case '4': return 'Dusun II Barat';
      case '5': return 'Dusun III';
      case '6': return 'Dusun IV';
      default: return 'Dusun $dusun';
    }
  }

  String get statusKkLabel {
    switch (r103) {
      case '1': return 'KK Suka Makmur';
      case '2': return 'Bukan KK Suka Makmur';
      case '3': return 'Belum Punya KK';
      default: return '-';
    }
  }

  AnggotaKeluarga? get kepalaKeluarga =>
      r200.where((a) => a.r203 == '1').isNotEmpty
          ? r200.firstWhere((a) => a.r203 == '1')
          : null;

  int get jumlahAnggota => r200.length;
  int get jumlahLakiLaki => r200.where((a) => a.r205 == '1').length;
  int get jumlahPerempuan => r200.where((a) => a.r205 == '2').length;
}

// Statistik Desa
class StatistikDesa {
  final int totalKK;
  final int totalPenduduk;
  final int totalLakiLaki;
  final int totalPerempuan;
  final Map<String, int> perDusun;
  final Map<String, int> perPendidikan;
  final Map<String, int> perPekerjaan;
  final Map<String, int> perPetugas;

  StatistikDesa({
    required this.totalKK,
    required this.totalPenduduk,
    required this.totalLakiLaki,
    required this.totalPerempuan,
    required this.perDusun,
    required this.perPendidikan,
    required this.perPekerjaan,
    required this.perPetugas,
  });
}