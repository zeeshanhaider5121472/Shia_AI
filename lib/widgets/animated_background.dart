import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Force rebuild when theme changes
    context.watch<SettingsService>();
    final orbOpacity = AppColors.isDark ? 0.20 : 0.05;

    return Container(
      color: AppColors.bg,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _orb(260,
                const Color(0xFF312E81).withOpacity(orbOpacity)),
          ),
          Positioned(
            bottom: 120,
            left: -90,
            child: _orb(220,
                const Color(0xFF1E3A5F).withOpacity(orbOpacity * 0.8)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            right: -50,
            child: _orb(180,
                const Color(0xFF2D1B69).withOpacity(orbOpacity * 0.6)),
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
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
