import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Stack(
        children: [
          // ── Subtle colored orbs for glassmorphism depth ──
          Positioned(
            top: -80,
            right: -60,
            child: _orb(260, const Color(0xFF312E81).withOpacity(0.22)),
          ),
          Positioned(
            bottom: 120,
            left: -90,
            child: _orb(220, const Color(0xFF1E3A5F).withOpacity(0.18)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            right: -50,
            child: _orb(180, const Color(0xFF2D1B69).withOpacity(0.12)),
          ),
          Positioned(
            bottom: -60,
            right: 40,
            child: _orb(150, const Color(0xFF1A3352).withOpacity(0.10)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
