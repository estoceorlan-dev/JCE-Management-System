import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme_mode_controller.dart';

class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final dark = mode == ThemeMode.system
        ? Theme.of(context).brightness == Brightness.dark
        : mode == ThemeMode.dark;
    return IconButton(
      tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: () => ref
          .read(themeModeProvider.notifier)
          .select(dark ? ThemeMode.light : ThemeMode.dark),
      icon: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        transitionBuilder: (child, progress) => FadeTransition(
          opacity: progress,
          child: RotationTransition(
            turns: Tween<double>(begin: -0.10, end: 0).animate(progress),
            child: child,
          ),
        ),
        child: Icon(
          dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(dark),
          size: 20,
        ),
      ),
    );
  }
}
