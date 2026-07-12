import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class KeyTagLogo extends StatelessWidget {
  final Color holeBackgroundColor;

  const KeyTagLogo({super.key, required this.holeBackgroundColor});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.05,
      child: SizedBox(
        height: 78,
        width: 68,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: holeBackgroundColor,
                  border: Border.all(color: Colors.white70, width: 2.5),
                ),
              ),
            ),
            Positioned(
              top: 15,
              child: Container(
                width: 66,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.accentDark],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.vpn_key_rounded, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}