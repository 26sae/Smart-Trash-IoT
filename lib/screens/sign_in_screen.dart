import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _showPass   = false;
  bool _loading    = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final err = await context.read<AppProvider>().signIn(email, pass);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error   = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Brand header
              Container(
                color: AppColors.greenDark,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TIP QC · CANTEEN',
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Smart Trash',
                      style: GoogleFonts.syne(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intelligent Waste Management',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sign In',
                      style: GoogleFonts.syne(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _FieldLabel('EMAIL'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.ink),
                      decoration: const InputDecoration(
                        hintText: 'you@tipqc.edu.ph',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _FieldLabel('PASSWORD'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passCtrl,
                      obscureText: !_showPass,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _signIn(),
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.inkLight,
                          ),
                          onPressed: () => setState(() => _showPass = !_showPass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Error
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      ErrorBanner(_error!),
                    ],
                    const SizedBox(height: 18),

                    // Sign in button
                    PrimaryButton(
                      label: _loading ? 'Signing in...' : 'Sign In',
                      onPressed: _loading ? null : _signIn,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmMono(
        fontSize: 9,
        color: AppColors.inkLight,
        letterSpacing: 1.0,
      ),
    );
  }
}
