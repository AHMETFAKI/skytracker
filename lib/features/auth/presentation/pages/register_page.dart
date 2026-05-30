import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';

/// Account creation: full name, email, password + confirmation. On success the
/// `users/{uid}` profile document is written by the repository.
@RoutePage()
class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmController = useTextEditingController();

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      FocusScope.of(context).unfocus();
      final ok = await ref.read(authControllerProvider.notifier).register(
            fullName: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
          );
      if (!context.mounted) return;
      if (ok) {
        await context.router.replaceAll([const FlightMapRoute()]);
      } else {
        showFailureSnackBar(context, ref.read(authControllerProvider).error);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('auth.register.title'.tr())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'auth.register.subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 24.h),
                AppTextField(
                  label: 'auth.field.fullName'.tr(),
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => _translate(Validators.fullName(v)),
                ),
                SizedBox(height: 16.h),
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
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) => _translate(Validators.password(v)),
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  label: 'auth.field.confirmPassword'.tr(),
                  controller: confirmController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) => _translate(
                    Validators.confirmPassword(v, passwordController.text),
                  ),
                  onSubmitted: (_) => submit(),
                ),
                SizedBox(height: 24.h),
                AppButton(
                  label: 'auth.register.action'.tr(),
                  isLoading: isLoading,
                  onPressed: submit,
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: isLoading ? null : () => context.router.maybePop(),
                  child: Text('auth.register.toLogin'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _translate(String? key) => key?.tr();
