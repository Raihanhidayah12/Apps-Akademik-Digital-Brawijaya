import 'dart:async';
import 'package:flutter/material.dart';
import 'app_navigator.dart';

/// Show a modern in-app announcement banner using an OverlayEntry.
/// It slides from the top, matches theme colors, and auto-dismisses.
void showInAppAnnouncement({
  required String title,
  required String body,
  Duration duration = const Duration(seconds: 6),
  VoidCallback? onTap,
}) {
  final navState = appNavigatorKey.currentState;
  if (navState == null) return;
  final overlay = navState.overlay;
  if (overlay == null) return;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _InAppBanner(
      entry: entry,
      title: title,
      body: body,
      duration: duration,
      onTap: onTap,
    ),
  );

  overlay.insert(entry);
}

class _InAppBanner extends StatefulWidget {
  final OverlayEntry entry;
  final String title;
  final String body;
  final Duration duration;
  final VoidCallback? onTap;

  const _InAppBanner({
    Key? key,
    required this.entry,
    required this.title,
    required this.body,
    required this.duration,
    this.onTap,
  }) : super(key: key);

  @override
  State<_InAppBanner> createState() => _InAppBannerState();
}

class _InAppBannerState extends State<_InAppBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offsetAnim;
  late final Animation<double> _fadeAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    _timer = Timer(widget.duration, () => _dismiss());
  }

  void _dismiss() {
    _timer?.cancel();
    _ctrl.reverse().then((_) {
      try {
        widget.entry.remove();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.blueGrey[900] : Colors.white;
    final accentStart = Colors.teal.shade400;
    final accentEnd = Colors.greenAccent.shade100;

    return Positioned(
      top: 24,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: GestureDetector(
                  onTap: () {
                    _dismiss();
                    widget.onTap?.call();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg?.withOpacity(isDark ? 0.95 : 0.98),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentStart, accentEnd],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.campaign,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.cyan[100]
                                      : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.body,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _dismiss,
                          style: TextButton.styleFrom(
                            backgroundColor:
                                isDark ? Colors.white12 : Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Tutup',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
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