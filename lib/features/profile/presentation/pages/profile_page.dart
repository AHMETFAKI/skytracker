import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
    // This tab is kept alive in the shell's IndexedStack, so reading the locale
    // here subscribes the page to easy_localization and re-localizes it the
    // moment the language changes — `.tr()` alone does not establish that
    // dependency.
    final _ = context.locale;
    final signedIn = ref.watch(authStateProvider).value != null;

    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr())),
      body: SafeArea(
        child: signedIn ? const _ProfileBody() : const _SignedOutView(),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Subscribe to the locale so this (const) subtree re-localizes when the
    // language changes — `.tr()` alone establishes no such dependency.
    final _ = context.locale;
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
    // Profile is a nested tab, so `context.router` is the inner TabsRouter;
    // LoginRoute lives on the root stack, hence `.root`.
    await context.router.root.replaceAll([const LoginRoute()]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
      children: [
        _ProfileHeader(user: user),
        SizedBox(height: 28.h),
        _SectionLabel('profile.preferences'.tr()),
        SizedBox(height: 8.h),
        GlassCard(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  children: [
                    Icon(Icons.language,
                        size: 20.sp, color: AppColors.onSurfaceMuted),
                    SizedBox(width: 12.w),
                    Expanded(child: Text('profile.language'.tr())),
                    const LanguageToggle(),
                  ],
                ),
              ),
              Divider(color: AppColors.outline, height: 1.h),
              _NavRow(
                icon: Icons.tune,
                label: 'profile.settings'.tr(),
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.router.push(const SettingsRoute());
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        _SectionLabel('profile.account'.tr()),
        SizedBox(height: 8.h),
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
        SizedBox(height: 28.h),
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
        SizedBox(height: 24.h),
        Center(
          child: Text(
            'SkyTracker v${AppConfig.appVersion}',
            style: AppTextStyles.labelSmall,
          ),
        ),
      ],
    );
  }
}

/// Avatar (user initials on a brand gradient) + name + email.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  String get _initials {
    final name = user.fullName.trim();
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      final letters = parts.take(2).map((p) => p[0]).join();
      return letters.toUpperCase();
    }
    final email = user.email.trim();
    return email.isEmpty ? '?' : email[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88.w,
          height: 88.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.accent],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: AppTextStyles.displayLarge.copyWith(
              color: AppColors.onPrimary,
              fontSize: 32.sp,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          user.fullName.isEmpty ? user.email : user.fullName,
          style: AppTextStyles.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (user.fullName.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(user.email, style: AppTextStyles.bodyMuted),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1),
      ),
    );
  }
}

/// A tappable settings/navigation row with a trailing chevron.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.onSurfaceMuted),
            SizedBox(width: 12.w),
            Expanded(child: Text(label)),
            Icon(Icons.chevron_right,
                size: 20.sp, color: AppColors.onSurfaceMuted),
          ],
        ),
      ),
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
    final _ = context.locale;
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
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _EditNameSheet(currentName: current),
  );
}

/// Edit-name bottom sheet. Owns its [TextEditingController] in state so it is
/// disposed only after the route is fully gone — disposing it synchronously
/// after `showModalBottomSheet` returns left the closing animation rebuilding
/// the field against a dead controller. Scrollable so the keyboard never
/// overflows the content.
class _EditNameSheet extends ConsumerStatefulWidget {
  const _EditNameSheet({required this.currentName});

  final String currentName;

  @override
  ConsumerState<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends ConsumerState<_EditNameSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.currentName);
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final ok = await ref
        .read(profileControllerProvider.notifier)
        .updateFullName(_controller.text.trim());
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
      showFailureSnackBar(context, ref.read(profileControllerProvider).error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'profile.editName'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                label: 'auth.field.fullName'.tr(),
                controller: _controller,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.done,
                validator: (v) => Validators.fullName(v)?.tr(),
                onSubmitted: (_) => _save(),
              ),
              SizedBox(height: 24.h),
              AppButton(
                label: 'common.save'.tr(),
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '—';
  final d = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}
