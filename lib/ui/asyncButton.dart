import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class AsyncButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final Widget? busyChild;
  final ButtonStyle? style;
  final Duration minBusy;         // keep spinner visible briefly (nice UX)
  final void Function(Object error, StackTrace st)? onError;

  const AsyncButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.busyChild,
    this.style,
    this.minBusy = const Duration(milliseconds: 350),
    this.onError,
  });

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: widget.style,
      onPressed: _busy ? null : _handlePressed,
      child: _busy
          ? (widget.busyChild ?? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)))
          : widget.child,
    );
  }

  Future<void> _handlePressed() async {
    setState(() => _busy = true);
    final start = DateTime.now();
    try {
      await widget.onPressed();
    } catch (e, st) {
      widget.onError?.call(e, st);
      showSimpleNotification(
        const Text('Something went wrong'),
        background: Colors.red,
        position: NotificationPosition.top,
        slideDismissDirection: DismissDirection.up,
      );
    } finally {
      final elapsed = DateTime.now().difference(start);
      final wait = elapsed >= widget.minBusy ? Duration.zero : widget.minBusy - elapsed;
      await Future.delayed(wait);
      if (mounted) setState(() => _busy = false);
    }
  }
}
