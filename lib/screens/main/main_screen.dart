// lib/screens/main/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/permissions_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/network_banner.dart';
import '../dashboard/dashboard_screen.dart';
import '../kuesioner/kuesioner_list_screen.dart';
import '../laporan/laporan_screen.dart';
import '../profil/profil_screen.dart';

// ── Data class untuk satu definisi tab ────────────────────────────────────────
class _TabDef {
  final String? feature;   // null = selalu tampil
  final Widget screen;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabDef({
    this.feature,
    required this.screen,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ── Semua tab yang mungkin ada ─────────────────────────────────────────────────
const List<_TabDef> _allTabs = [
  _TabDef(
    feature: AppFeatures.dashboard,
    screen: DashboardScreen(),
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    label: 'Dashboard',
  ),
  _TabDef(
    feature: AppFeatures.questionnaireView,
    screen: KuesionerListScreen(),
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    label: 'Kuesioner',
  ),
  _TabDef(
    feature: AppFeatures.reports,
    screen: LaporanScreen(),
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
    label: 'Laporan',
  ),
  _TabDef(
    feature: null,           // Profil selalu tampil
    screen: ProfilScreen(),
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profil',
  ),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  /// Index mengacu pada _visibleTabs, bukan _allTabs
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermissions();
  }

  Future<void> _initData() async {
    final prov = context.read<QuestionnaireProvider>();
    await prov.loadQuestionnaires();
    if (prov.pendingCount > 0) await prov.syncPending();
    await _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final token = await StorageService.instance.getToken();
    if (token == null) return;
    await PermissionsService.instance.fetchAndCache(token);
    if (!mounted) return;
    setState(() {
      // Pastikan index tidak keluar batas setelah tab hilang/muncul
      final visible = _visibleTabs;
      if (_currentIndex >= visible.length) {
        _currentIndex = visible.length - 1;
      }
    });
  }

  /// Tab yang benar-benar ditampilkan berdasarkan permissions saat ini
  List<_TabDef> get _visibleTabs {
    final ps = PermissionsService.instance;
    return _allTabs
        .where((t) => t.feature == null || ps.can(t.feature!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTabs;

    // Pastikan index valid
    final safeIndex = _currentIndex.clamp(0, visible.length - 1);

    return Scaffold(
      body: NetworkBanner(
        // IndexedStack atas semua tab yang visible saja
        child: IndexedStack(
          index: safeIndex,
          children: visible.map((t) => t.screen).toList(),
        ),
      ),
      bottomNavigationBar: Consumer2<QuestionnaireProvider, ConnectivityProvider>(
        builder: (_, prov, __, ___) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: safeIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppTheme.primaryBlue,
              unselectedItemColor: Colors.grey[500],
              selectedFontSize: 11,
              unselectedFontSize: 11,
              elevation: 0,
              items: visible.map((t) {
                // Tab Kuesioner: tampilkan badge pending jika ada
                if (t.feature == AppFeatures.questionnaireView &&
                    prov.pendingCount > 0) {
                  return BottomNavigationBarItem(
                    label: t.label,
                    activeIcon: Icon(t.activeIcon),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(t.icon),
                        Positioned(
                          right: -5, top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppTheme.accentOrange,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 15, minHeight: 15),
                            child: Text(
                              prov.pendingCount > 9
                                  ? '9+' : '${prov.pendingCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                // Tab biasa
                return BottomNavigationBarItem(
                  label: t.label,
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}