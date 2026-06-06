import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/frosted_panel.dart';

class VolumeControl extends StatefulWidget {
  const VolumeControl({
    super.key,
    required this.volume,
    required this.onChanged,
  });

  final double volume;
  final ValueChanged<double> onChanged;

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  final _overlayKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  double? _dragValue;

  double get _sliderValue => (_dragValue ?? widget.volume).clamp(0.0, 1.0);

  void _rebuildOverlay() => _overlayEntry?.markNeedsBuild();

  IconData get _volumeIcon {
    if (widget.volume == 0) return LucideIcons.volumeX;
    if (widget.volume < 0.5) return LucideIcons.volume1;
    return LucideIcons.volume2;
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _closeOverlay();
      return;
    }

    final box = _overlayKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final offset = box.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeOverlay,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: offset.dx - 80,
            top: offset.dy - 130,
            child: Material(
              color: Colors.transparent,
              child: FrostedPanel(
                color: AppColors.surfaceOverlay,
                blurSigma: 16,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    height: 100,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: _sliderValue,
                        onChanged: (value) {
                          _dragValue = value;
                          _rebuildOverlay();
                          widget.onChanged(value);
                        },
                        onChangeEnd: (_) {
                          _dragValue = null;
                          _rebuildOverlay();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void didUpdateWidget(VolumeControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.volume != widget.volume && _dragValue == null) {
      _rebuildOverlay();
    }
  }

  @override
  void dispose() {
    _closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _overlayKey,
      onPressed: _toggleOverlay,
      icon: Icon(_volumeIcon),
      tooltip: 'Громкость',
      color: AppColors.textSecondary,
      hoverColor: AppColors.surfaceElevated,
    );
  }
}
