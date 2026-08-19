import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EagleMark extends StatelessWidget {
  const EagleMark({
    super.key,
    this.size = 42,
    this.compact = false,
  });

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * .52;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * .31),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.sky, AppColors.primary, AppColors.navy],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: size * .14,
                right: size * .13,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white.withValues(alpha: .35),
                  size: size * .29,
                ),
              ),
              Icon(
                Icons.north_east_rounded,
                color: Colors.white,
                size: iconSize,
              ),
            ],
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 11),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Eagle',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: .96,
                  letterSpacing: -.6,
                ),
              ),
              Text(
                'SMART BUSINESS',
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: .9),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.35,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
