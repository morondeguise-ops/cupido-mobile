import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  String _countryCode = '+1';
  bool _isLogin = true;
  String? _sponsorPhone;

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone = _countryCode + _phoneNumber;
    final purpose = _isLogin ? 'login' : 'registration';

    final success = await ref.read(authProvider.notifier).sendOtp(
          phone: fullPhone,
          purpose: purpose,
          sponsorPhone: _sponsorPhone,
        );

    if (!mounted) return;

    if (success) {
      Navigator.pushNamed(
        context,
        AppRouter.otpVerification,
        arguments: {
          'phone': fullPhone,
          'purpose': purpose,
        },
      );
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to send OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Title
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your phone number to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Phone Number Input
                IntlPhoneField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                  ),
                  initialCountryCode: 'US',
                  onChanged: (phone) {
                    setState(() {
                      _phoneNumber = phone.number;
                      _countryCode = '+${phone.countryCode}';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.number.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Sponsor Phone (for registration)
                if (!_isLogin) ...[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Sponsor Phone Number',
                      hintText: 'Enter your sponsor\'s phone number',
                      helperText: 'Required for exclusive access',
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        _sponsorPhone = value;
                      });
                    },
                    validator: (value) {
                      if (!_isLogin && (value == null || value.isEmpty)) {
                        return 'Sponsor phone is required for registration';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                // Continue Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _sendOtp,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue'),
                ),
                const SizedBox(height: 24),
                // Toggle Login/Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin ? 'Sign Up' : 'Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
