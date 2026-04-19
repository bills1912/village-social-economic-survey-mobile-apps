// lib/models/questionnaire.dart
// Model yang sesuai dengan struktur database dari backend PHP/Filament

class AnggotaKeluarga {
  final String? r201; // Nama
  final String? r202; // NIK
  final String? r203; // Status Keluarga
  final String? r204; // Status Perkawinan
  final String? r205; // Jenis Kelamin
  final String? r206; // Tempat Lahir
  final String? r207; // Tanggal Lahir
  final int? r207Usia;
  final String? r208; // Suku
  final String? r209; // Kewarganegaraan
  final String? r210; // Keberadaan Penduduk
  final List<String>? r211; // Disabilitas
  final String? r212; // Pendidikan Terakhir
  final String? r300Pekerjaan; // Status Pekerjaan
  final List<PekerjaanData>? pekerjaan;

  AnggotaKeluarga({
    this.r201, this.r202, this.r203, this.r204, this.r205,
    this.r206, this.r207, this.r207Usia, this.r208, this.r209,
    this.r210, this.r211, this.r212, this.r300Pekerjaan, this.pekerjaan,
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
      r211: json['r_211'] != null
          ? List<String>.from(json['r_211'])
          : null,
      r212: json['r_212'],
      r300Pekerjaan: json['r_300_pekerjaan'],
    );
  }

  Map<String, dynamic> toJson() => {
    'r_201': r201, 'r_202': r202, 'r_203': r203, 'r_204': r204,
    'r_205': r205, 'r_206': r206, 'r_207': r207, 'r_207_usia': r207Usia,
    'r_208': r208, 'r_209': r209, 'r_210': r210, 'r_211': r211,
    'r_212': r212, 'r_300_pekerjaan': r300Pekerjaan,
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
  final String? tipe; // usaha/buruh/pekerjaBebas
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
  final String r102; // No KK
  final String? r103; // Status KK
  final String? r104;
  final List<AnggotaKeluarga> r200; // Anggota Keluarga
  final String? r401; // Keterangan
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