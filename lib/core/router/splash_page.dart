import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Temporary launch route. Real routes (auth, shell, map, profile) replace this
/// from Phase 4 onward; for now it confirms the router + theme are wired up.
@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.radarGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.radar, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('SkyTracker', style: AppTextStyles.displayLarge),
            ],
          ),
        ),
      ),
    );
  }
}
