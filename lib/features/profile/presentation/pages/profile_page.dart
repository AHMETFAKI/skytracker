import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_provider.dart';

/// Profile tab: shows the signed-in user's name / email / join date, allows
/// editing the full name, and signs out. Falls back to a sign-in prompt when
/// no user is present (mock-first / Firebase not configured).
@RoutePage()
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(authStateProvider).value != null;

    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr())),
      body: SafeArea(
        child: signedIn
            ? const _ProfileBody()
            : const _SignedOutView(),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return profileAsync.when(
      loading: () => LoadingView(message: 'common.loading'.tr()),
      error: (error, _) => AppErrorView(
        message: failureMessage(error),
        retryLabel: 'common.retry'.tr(),
        onRetry: () => ref.invalidate(profileControllerProvider),
      ),
      data: (user) => _ProfileContent(user: user),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user});

  final AppUser user;

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) return;
    await context.router.replaceAll([const LoginRoute()]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.all(24.w),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40.r,
            backgroundColor: AppColors.surfaceVariant,
            child: Icon(Icons.person, size: 40.sp, color: AppColors.primary),
          ),
        ),
        SizedBox(height: 24.h),
        GlassCard(
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.badge_outlined,
                label: 'profile.fullName'.tr(),
                value: user.fullName.isEmpty ? '—' : user.fullName,
              ),
              Divider(color: AppColors.outline, height: 24.h),
              _InfoRow(
                icon: Icons.alternate_email,
                label: 'profile.email'.tr(),
                value: user.email,
              ),
              Divider(color: AppColors.outline, height: 24.h),
              _InfoRow(
                icon: Icons.event_outlined,
                label: 'profile.memberSince'.tr(),
                value: _formatDate(user.createdAt),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        GlassCard(
          child: Row(
            children: [
              Icon(Icons.language, size: 20.sp, color: AppColors.onSurfaceMuted),
              SizedBox(width: 12.w),
              Expanded(child: Text('profile.language'.tr())),
              const LanguageToggle(),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        AppButton(
          label: 'profile.editName'.tr(),
          icon: Icons.edit_outlined,
          onPressed: () => _showEditNameSheet(context, ref, user.fullName),
        ),
        SizedBox(height: 12.h),
        OutlinedButton.icon(
          onPressed: () => _logout(context, ref),
          icon: const Icon(Icons.logout),
          label: Text('profile.logout'.tr()),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.onSurfaceMuted),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48.sp, color: AppColors.onSurfaceMuted),
            SizedBox(height: 16.h),
            Text(
              'profile.signedOut'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24.h),
            AppButton(
              label: 'auth.login.action'.tr(),
              expanded: false,
              onPressed: () => context.router.push(const LoginRoute()),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showEditNameSheet(
  BuildContext context,
  WidgetRef ref,
  String current,
) async {
  final controller = TextEditingController(text: current);
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.h,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'profile.editName'.tr(),
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                label: 'auth.field.fullName'.tr(),
                controller: controller,
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.fullName(v)?.tr(),
              ),
              SizedBox(height: 24.h),
              AppButton(
                label: 'common.save'.tr(),
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final ok = await ref
                      .read(profileControllerProvider.notifier)
                      .updateFullName(controller.text.trim());
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                  if (!ok) {
                    showFailureSnackBar(
                      context,
                      ref.read(profileControllerProvider).error,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
  controller.dispose();
}

String _formatDate(DateTime? date) {
  if (date == null) return '—';
  final d = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}
