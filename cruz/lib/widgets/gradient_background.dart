import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0C20), // Deep space blue/black
            Color(0xFF15102A), // Dark purple shadow
            Color(0xFF060410), // Rich obsidian black
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: child,
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.0,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ??
              [
                Colors.white.withOpacity(0.06),
                Colors.white.withOpacity(0.02),
              ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Card(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.deepPurple.withOpacity(0.2),
          highlightColor: Colors.deepPurple.withOpacity(0.1),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
