import 'package:flutter/material.dart';

/// The supplied logout glyph used consistently across the app.
class LogoutIcon extends StatelessWidget {
  final double size;

  const LogoutIcon({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        'assets/logout.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
