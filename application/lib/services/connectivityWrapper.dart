// lib/services/connectivity_wrapper.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Wrap any subtree to show a red banner whenever there’s **no** internet.
/// Sits safely above MaterialApp now because it supplies its own Directionality.
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  List<ConnectivityResult> _status = [ConnectivityResult.none];
  final _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _sub;

  @override
  void initState() {
    super.initState();
    _init();
    _sub = _connectivity.onConnectivityChanged.listen(_update);
  }

  Future<void> _init() async {
    try {
      final res = await _connectivity.checkConnectivity();
      if (mounted) _update(res);
    } on PlatformException catch (e) {
      developer.log('Could not check connectivity', error: e);
    }
  }

  void _update(List<ConnectivityResult> res) {
    setState(() => _status = res);
    developer.log('Connectivity changed: $res');
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final online = _status.any(
      (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
    );

    // Directionality fixes “No Directionality widget found” assertion
    return Directionality(
      textDirection: TextDirection.ltr, // or use RTL if your default is rtl
      child: Stack(
        children: [
          widget.child,
          if (!online)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.redAccent,
                elevation: 6,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'No Internet Connection',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
