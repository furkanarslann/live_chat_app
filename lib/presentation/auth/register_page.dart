import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/auth/auth_cubit.dart';
import 'package:live_chat_app/application/auth/auth_state.dart';
import 'package:live_chat_app/domain/core/failures.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/router/app_router.dart';
import 'package:live_chat_app/presentation/core/widgets/custom_button.dart';
import 'package:live_chat_app/presentation/core/widgets/custom_text_field.dart';
import 'package:live_chat_app/presentation/core/widgets/glassy_snackbar.dart';
import 'package:live_chat_app/presentation/core/widgets/password_requirements.dart';
import 'package:live_chat_app/presentation/settings/widgets/language_selector.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Email validation regex
  final _emailRegex = RegExp(
    r'^(?:[A-Za-z0-9_-]+(?:\.[A-Za-z0-9_-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?!yok\.com$)((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  @override
  void initState() {
    super.initState();
    // Add listeners for real-time validation
    _passwordController.addListener(() {
      setState(() {});
    });
    _emailController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  bool _isPasswordStrong(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumbers &&
        hasSpecialCharacters;
  }

  bool get _isEmailValid {
    final email = _emailController.text;
    if (email.isEmpty) return true; // Don't show error when empty
    return _emailRegex.hasMatch(email);
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthCubit>().register(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.createAccount),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.failureOption != current.failureOption,
        listener: (context, state) {
          // Handle failures
          state.failureOption.fold(
            () {
              // If no failure and authenticated, navigate to home
              if (state.status == AuthStatus.authenticated) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.home,
                  (route) => false,
                );
              }
            },
            (failure) {
              final message = switch (failure) {
                EmailAlreadyInUseFailure() => context.tr.emailAlreadyInUse,
                UnexpectedFailure() => context.tr.unknownError,
                _ => context.tr.unknownError,
              };

              GlassySnackBar.show(
                context,
                message: message,
                type: GlassySnackBarType.failure,
              );
            },
          );
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 40,
                          color: context.colors.primary,
                        ),
                        Text(
                          context.tr.joinUs,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr.createAccountToStart,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      label: context.tr.fullName,
                      hint: context.tr.enterFullName,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr.pleaseEnterName;
                        }
                        if (value.trim().split(' ').length < 2) {
                          return context.tr.pleaseEnterFullName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: context.tr.email,
                      hint: context.tr.enterEmail,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      errorText:
                          !_isEmailValid ? context.tr.pleaseEnterEmail : null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr.pleaseEnterEmail;
                        }
                        if (!_emailRegex.hasMatch(value)) {
                          return context.tr.emailInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: context.tr.password,
                      hint: context.tr.enterPassword,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr.pleaseEnterPassword;
                        }
                        if (!_isPasswordStrong(value)) {
                          return context.tr.passwordRequirements;
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    PasswordRequirements(
                      password: _passwordController.text,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: context.tr.confirmPassword,
                      hint: context.tr.confirmYourPassword,
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onSubmit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr.pleaseConfirmPassword;
                        }
                        if (value != _passwordController.text) {
                          return context.tr.passwordsDoNotMatch;
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (previous, current) {
                        return previous.isSubmitting != current.isSubmitting;
                      },
                      builder: (context, state) {
                        return CustomButton(
                          text: context.tr.createAccount,
                          onPressed: _onSubmit,
                          isLoading: state.isSubmitting,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr.alreadyHaveAccount,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(
                              AppRouter.login,
                            );
                          },
                          child: Text(context.tr.signIn),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
