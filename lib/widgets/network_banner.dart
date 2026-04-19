// lib/widgets/network_banner.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../utils/app_theme.dart';

/// Slim banner shown at the top of the screen when offline.
/// Wrap the Scaffold body (or entire screen) with this widget.
class NetworkBanner extends StatelessWidget {
  final Widget child;
  const NetworkBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (_, conn, __) => Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: conn.isOnline ? 0 : 32,
            color: conn.isOnline
                ? Colors.transparent
                : AppTheme.accentOrange,
            child: conn.isOnline
                ? const SizedBox.shrink()
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off,
                          color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Mode Offline – Data tersimpan lokal',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
