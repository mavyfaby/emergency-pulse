import 'package:avatar_glow/avatar_glow.dart';
import 'package:emergency_pulse/controllers/slide.controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlideToConfirm extends StatefulWidget {
  final VoidCallback onConfirmed;
  final VoidCallback onClose;

  const SlideToConfirm({
    super.key,
    required this.onConfirmed,
    required this.onClose,
  });

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  final controller = Get.put(SlideConfirmController());
  final ValueNotifier<double> dragPercent = ValueNotifier(0.0);

  static const double height = 56.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width * 0.8;

    return GetBuilder<SlideConfirmController>(
      builder: (c) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (c.confirmed.value) return;
            dragPercent.value =
                (dragPercent.value + details.primaryDelta! / width).clamp(
                  0.0,
                  1.0,
                );
          },
          onHorizontalDragEnd: (_) async {
            if (c.confirmed.value) return;
            if (dragPercent.value > 0.8) {
              widget.onConfirmed();
              dragPercent.value = 0.0;
              await controller.confirm(widget.onClose);
            } else {
              dragPercent.value = 0.0;
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: c.confirmed.value
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.none,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: AnimatedOpacity(
                    opacity: c.confirmed.value ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      'Slide to confirm',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                if (!c.expanding.value)
                  ValueListenableBuilder<double>(
                    valueListenable: dragPercent,
                    builder: (_, value, __) {
                      return Transform.translate(
                        offset: Offset(value * (width - height), 0),
                        child: AvatarGlow(
                          glowRadiusFactor: 2,
                          glowColor: theme.colorScheme.primary,
                          child: Container(
                            width: height,
                            height: height,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (c.expanding.value)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 1000),
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: theme.colorScheme.onPrimary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
