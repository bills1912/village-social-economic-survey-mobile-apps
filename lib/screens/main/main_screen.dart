// lib/screens/main/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/network_banner.dart';
import '../dashboard/dashboard_screen.dart';
import '../kuesioner/kuesioner_list_screen.dart';
import '../laporan/laporan_screen.dart';
import '../profil/profil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    KuesionerListScreen(),
    LaporanScreen(),
    ProfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _initData() async {
    final prov = context.read<QuestionnaireProvider>();
    await prov.loadQuestionnaires();
    if (prov.pendingCount > 0) await prov.syncPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NetworkBanner(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Consumer2<QuestionnaireProvider, ConnectivityProvider>(
          builder: (_, prov, conn, __) => BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryBlue,
            unselectedItemColor: Colors.grey[500],
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.assignment_outlined),
                    if (prov.pendingCount > 0)
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
                            prov.pendingCount > 9 ? '9+' : '${prov.pendingCount}',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 8,
                              fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: const Icon(Icons.assignment),
                label: 'Kuesioner',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Laporan',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
