import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/brand_mark.dart';
import '../role_selection/role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _keepSignedIn = true;

  void _continueToWorkspace() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 920;
            final form = _LoginForm(
              obscurePassword: _obscurePassword,
              keepSignedIn: _keepSignedIn,
              onPasswordVisibilityChanged: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              onKeepSignedInChanged: (value) {
                setState(() => _keepSignedIn = value ?? false);
              },
              onContinue: _continueToWorkspace,
            );

            if (isDesktop) {
              return Row(
                children: [
                  const Expanded(flex: 11, child: _LoginShowcase()),
                  Expanded(
                    flex: 9,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: form,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                const Positioned.fill(child: _MobileLoginBackdrop()),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: form,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoginShowcase extends StatelessWidget {
  const _LoginShowcase();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, Color(0xFF1A3563), Color(0xFF3861BC)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -125,
            left: -120,
            child: _Orb(size: 350, color: Color(0xFF7898FF)),
          ),
          Positioned(
            bottom: -170,
            right: -125,
            child: _Orb(size: 390, color: Color(0xFF23C5A0)),
          ),
          Positioned(
            top: 64,
            left: 58,
            child: Row(
              children: [
                const EagleMark(size: 42, compact: true),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Eagle',
                      style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'SMART BUSINESS',
                      style: TextStyle(
                        color: Color(0xFFAFC1EC),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 58),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ShowcaseBadge(),
                    const SizedBox(height: 24),
                    Text(
                      'Every decision,\nclearer at a glance.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 43,
                            height: 1.02,
                          ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Bring client workspaces, stock operations and business signals into one calm command centre.',
                      style: TextStyle(color: Color(0xFFD3DDFB), fontSize: 16, height: 1.55),
                    ),
                    const SizedBox(height: 38),
                    const _ShowcaseDashboardPreview(),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 58,
            bottom: 42,
            child: Text(
              'MADE FOR MODERN NEPALI BUSINESSES',
              style: TextStyle(
                color: Color(0xFFAFC1EC),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLoginBackdrop extends StatelessWidget {
  const _MobileLoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8EEFF), AppColors.canvas],
          stops: [0, .4],
        ),
      ),
      child: const Stack(
        children: [
          Positioned(top: -130, right: -100, child: _Orb(size: 280, color: Color(0xFF8EA9FF))),
          Positioned(top: 50, left: -140, child: _Orb(size: 230, color: Color(0xFF71DAC3))),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .17),
      ),
    );
  }
}

class _ShowcaseBadge extends StatelessWidget {
  const _ShowcaseBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFF9CEBD9), size: 14),
          SizedBox(width: 7),
          Text(
            'BUSINESS, IN ONE VIEW',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseDashboardPreview extends StatelessWidget {
  const _ShowcaseDashboardPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              _PreviewDot(color: Color(0xFFFFA69A)),
              SizedBox(width: 5),
              _PreviewDot(color: Color(0xFFFAD577)),
              SizedBox(width: 5),
              _PreviewDot(color: Color(0xFF8DE6D3)),
              Spacer(),
              Text('LIVE WORKSPACE', style: TextStyle(color: Color(0xFFBDD0FA), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: const [
              Expanded(child: _PreviewMetric(label: 'CLIENTS', value: 'ONE VIEW')),
              SizedBox(width: 10),
              Expanded(child: _PreviewMetric(label: 'STOCK', value: 'IN CONTROL')),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                SizedBox(width: 13),
                Icon(Icons.insights_rounded, color: Color(0xFF9CEBD9), size: 19),
                SizedBox(width: 10),
                Expanded(
                  child: Text('A focused dashboard awaits', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                Icon(Icons.arrow_forward_rounded, color: Color(0xFFBDD0FA), size: 18),
                SizedBox(width: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewDot extends StatelessWidget {
  const _PreviewDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFBDD0FA), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.obscurePassword,
    required this.keepSignedIn,
    required this.onPasswordVisibilityChanged,
    required this.onKeepSignedInChanged,
    required this.onContinue,
  });

  final bool obscurePassword;
  final bool keepSignedIn;
  final VoidCallback onPasswordVisibilityChanged;
  final ValueChanged<bool?> onKeepSignedInChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .08),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EagleMark(size: 45),
          const SizedBox(height: 31),
          Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 29)),
          const SizedBox(height: 7),
          Text(
            'Sign in to enter your Eagle workspace.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 26),
          Text('EMAIL ADDRESS', style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          )),
          const SizedBox(height: 8),
          const TextField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'you@business.com',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 18),
          Text('PASSWORD', style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          )),
          const SizedBox(height: 8),
          TextField(
            obscureText: obscurePassword,
            onSubmitted: (_) => onContinue(),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                onPressed: onPasswordVisibilityChanged,
                icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Transform.scale(
                scale: .92,
                child: Checkbox(value: keepSignedIn, onChanged: onKeepSignedInChanged),
              ),
              const SizedBox(width: 1),
              const Expanded(
                child: Text('Keep me signed in', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact your Super Admin to reset access.')),
                  );
                },
                child: const Text('Forgot password?'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue to workspace'),
            ),
          ),
          const SizedBox(height: 18),
          const _LocalDemoNotice(),
        ],
      ),
    );
  }
}


class _LocalDemoNotice extends StatelessWidget {
  const _LocalDemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.mist.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your workspace data stays on this device.',
              style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
