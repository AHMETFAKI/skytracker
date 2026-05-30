import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';

/// Email/password sign-in with a "Remember Me" toggle. On success the
/// [AuthController] resolves and the auth guard (Phase 6) routes onward.
@RoutePage()
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final rememberMe = useState(true);

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      FocusScope.of(context).unfocus();
      final ok = await ref.read(authControllerProvider.notifier).login(
            email: emailController.text.trim(),
            password: passwordController.text,
            rememberMe: rememberMe.value,
          );
      if (!context.mounted) return;
      if (ok) {
        await context.router.replaceAll([const HomeShellRoute()]);
      } else {
        showFailureSnackBar(context, ref.read(authControllerProvider).error);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: LanguageToggle(),
                  ),
                  SizedBox(height: 8.h),
                  Icon(Icons.radar, size: 64.sp, color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text(
                    'auth.login.title'.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'auth.login.subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 32.h),
                  AppTextField(
                    label: 'auth.field.email'.tr(),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.alternate_email,
                    validator: (v) => _translate(Validators.email(v)),
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    label: 'auth.field.password'.tr(),
                    controller: passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outline,
                    validator: (v) => _translate(Validators.password(v)),
                    onSubmitted: (_) => submit(),
                  ),
                  SizedBox(height: 8.h),
                  _RememberMeRow(
                    value: rememberMe.value,
                    onChanged: (v) => rememberMe.value = v,
                  ),
                  SizedBox(height: 16.h),
                  AppButton(
                    label: 'auth.login.action'.tr(),
                    isLoading: isLoading,
                    onPressed: submit,
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.router.push(const RegisterRoute()),
                    child: Text('auth.login.toRegister'.tr()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RememberMeRow extends StatelessWidget {
  const _RememberMeRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text('auth.login.rememberMe'.tr()),
          ),
        ),
      ],
    );
  }
}

String? _translate(String? key) => key?.tr();
