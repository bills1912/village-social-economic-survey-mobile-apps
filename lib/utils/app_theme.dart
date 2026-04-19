// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama - terinspirasi dari Field-Tracker (biru BPS)
  static const Color primaryBlue = Color(0xFF0B6BA8);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFF44336);
  static const Color accentOrange = Color(0xFFFF9800);

  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color bgCard = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF666666);
  static const Color divider = Color(0xFFE0E0E0);

  // Warna per dusun
  static const List<Color> dusunColors = [
    Color(0xFF2196F3), // I-A
    Color(0xFF4CAF50), // I-B
    Color(0xFFFF9800), // II Timur
    Color(0xFFE91E63), // II Barat
    Color(0xFF9C27B0), // III
    Color(0xFF00BCD4), // IV
  ];

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: bgLight,
    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: bgCard,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accentRed, width: 1),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: Colors.grey[400]),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Color(0xFF9E9E9E),
      elevation: 8,
    ),

    dividerTheme: const DividerThemeData(
      thickness: 1,
      color: divider,
    ),
  );
}

class AppConstants {
  static const String appName = 'Pendataan Suka Makmur';
  static const String version = '1.0.0';

  // API Base URL - ganti sesuai server
  static const String apiBaseUrl = 'https://village-survey.up.railway.app/api';

  static const List<Map<String, String>> dusunOptions = [
    {'value': '1', 'label': 'Dusun I-A'},
    {'value': '2', 'label': 'Dusun I-B'},
    {'value': '3', 'label': 'Dusun II Timur'},
    {'value': '4', 'label': 'Dusun II Barat'},
    {'value': '5', 'label': 'Dusun III'},
    {'value': '6', 'label': 'Dusun IV'},
  ];

  static const List<Map<String, String>> statusKkOptions = [
    {'value': '1', 'label': 'KK Suka Makmur'},
    {'value': '2', 'label': 'Bukan KK Suka Makmur'},
    {'value': '3', 'label': 'Belum Punya KK'},
  ];

  static const List<Map<String, String>> statusKeluargaOptions = [
    {'value': '1', 'label': 'Kepala Keluarga'},
    {'value': '2', 'label': 'Istri/Suami'},
    {'value': '3', 'label': 'Anak Kandung'},
    {'value': '4', 'label': 'Anak Tiri/Angkat'},
    {'value': '5', 'label': 'Orang Tua/Mertua'},
    {'value': '6', 'label': 'Famili Lain'},
  ];

  static const List<Map<String, String>> statusPerkawinanOptions = [
    {'value': '1', 'label': 'Kawin'},
    {'value': '2', 'label': 'Belum Kawin'},
    {'value': '3', 'label': 'Cerai Hidup'},
    {'value': '4', 'label': 'Cerai Mati'},
  ];

  static const List<Map<String, String>> jenisKelaminOptions = [
    {'value': '1', 'label': 'Laki-laki'},
    {'value': '2', 'label': 'Perempuan'},
  ];

  static const List<Map<String, String>> kewarganegaraanOptions = [
    {'value': '1', 'label': 'WNI'},
    {'value': '2', 'label': 'WNA'},
  ];

  static const List<Map<String, String>> keberadaanOptions = [
    {'value': '1', 'label': 'Berdomisili di Desa Suka Makmur'},
    {'value': '2', 'label': 'Sudah Pindah ke luar Desa Suka Makmur'},
    {'value': '3', 'label': 'Membentuk Keluarga Baru di Desa Suka Makmur'},
    {'value': '4', 'label': 'Sudah Meninggal'},
  ];

  static const List<Map<String, String>> pendidikanOptions = [
    {'value': '1', 'label': 'Tidak Sekolah/Belum Tamat SD'},
    {'value': '2', 'label': 'SD/Sederajat'},
    {'value': '3', 'label': 'SMP/Sederajat'},
    {'value': '4', 'label': 'SMA/Sederajat'},
    {'value': '5', 'label': 'D1/D2/D3'},
    {'value': '6', 'label': 'S1/S2/S3'},
  ];

  static const List<Map<String, String>> statusPekerjaanOptions = [
    {'value': '1', 'label': 'Masih Bersekolah'},
    {'value': '2', 'label': 'Sudah Bekerja'},
    {'value': '3', 'label': 'Tidak Bekerja'},
  ];

  static const List<Map<String, String>> disabilitasOptions = [
    {'value': '1', 'label': 'Penglihatan'},
    {'value': '2', 'label': 'Pendengaran'},
    {'value': '3', 'label': 'Berjalan/Naik Tangga'},
    {'value': '4', 'label': 'Menggunakan/Menggerakkan Tangan/Jari'},
    {'value': '5', 'label': 'Mengingat/Konsentrasi'},
    {'value': '6', 'label': 'Merawat Diri'},
    {'value': '7', 'label': 'Komunikasi'},
    {'value': '8', 'label': 'Perilaku/Emosi'},
  ];
}