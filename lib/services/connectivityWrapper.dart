// lib/services/connectivity_wrapper.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps any subtree and shows a red banner whenever there’s **no** internet.
/// - Smooth slide/fade animation
/// - Debounced to avoid flicker on transient changes
/// - Works across connectivity_plus versions (single vs list events)
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  /// Debounce durations to prevent banner flicker
  final Duration offlineDebounce;
  final Duration onlineDebounce;

  /// Optional override colors; defaults are theme-aware
  final Color? bannerColor;
  final Color? textColor;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.offlineDebounce = const Duration(milliseconds: 700),
    this.onlineDebounce = const Duration(milliseconds: 400),
    this.bannerColor,
    this.textColor,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final _connectivity = Connectivity();
  StreamSubscription<dynamic>? _sub;

  bool _online = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _init();
    // Handle both legacy and current stream shapes
    _sub = _connectivity.onConnectivityChanged.listen(_handleChange);
  }

  Future<void> _init() async {
    try {
      final res = await _connectivity.checkConnectivity();
      _handleChange(res);
    } on PlatformException catch (e, st) {
      developer.log('Could not check connectivity', error: e, stackTrace: st);
      _setOnline(true); // fail open: don’t scare users with false "offline"
    }
  }

  // Normalizes api: either ConnectivityResult or List<ConnectivityResult>
  void _handleChange(dynamic value) {
    List<ConnectivityResult> results;
    if (value is ConnectivityResult) {
      results = [value];
    } else if (value is List<ConnectivityResult>) {
      results = value;
    } else {
      results = const [];
    }

    // Treat any non-none result as online (covers wifi/mobile/ethernet/vpn/other)
    final nextOnline = results.any((r) => r != ConnectivityResult.none);
    developer.log('Connectivity changed: $results -> online=$nextOnline');

    // Debounce transitions to avoid flicker
    _debounceTimer?.cancel();
    final delay = nextOnline ? widget.onlineDebounce : widget.offlineDebounce;
    _debounceTimer = Timer(delay, () => _setOnline(nextOnline));
  }

  void _setOnline(bool v) {
    if (!mounted) return;
    if (_online == v) return;
    setState(() => _online = v);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme-aware defaults
    final cs = Theme.of(context).colorScheme;
    final bannerColor = widget.bannerColor ?? cs.error;
    final textColor = widget.textColor ?? cs.onError;

    final banner = _OfflineBanner(
      color: bannerColor,
      textColor: textColor,
      visible: !_online,
    );

    // If there is no Directionality above us (e.g., when wrapping MaterialApp),
    // supply one; otherwise, respect the ambient direction (RTL-safe).
    final dir = Directionality.maybeOf(context);
    final content = Stack(children: [widget.child, banner]);

    if (dir == null) {
      return Directionality(textDirection: TextDirection.ltr, child: content);
    }
    return content;
  }
}

class _OfflineBanner extends StatelessWidget {
  final bool visible;
  final Color color;
  final Color textColor;

  const _OfflineBanner({
    required this.visible,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Semantics(
        liveRegion: true,
        label: visible ? 'Offline: No Internet Connection' : 'Online',
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          offset: visible ? Offset.zero : const Offset(0, -1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            opacity: visible ? 1 : 0,
            child: Material(
              color: color,
              elevation: 6,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No Internet Connection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
