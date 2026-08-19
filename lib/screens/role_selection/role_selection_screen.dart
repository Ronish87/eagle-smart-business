import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/brand_mark.dart';
import '../inventory/inventory_screen.dart';
import '../super_admin/super_admin_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _openWorkspace(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(top: -150, right: -110, child: _BackgroundOrb(size: 330, color: AppColors.sky)),
            const Positioned(bottom: -180, left: -145, child: _BackgroundOrb(size: 360, color: AppColors.mint)),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1140),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Back to sign in',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 8),
                          const EagleMark(size: 38),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.mist,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'WORKSPACE ACCESS',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Choose your command centre',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 35),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Every role gets a focused view of the work that matters most.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 34),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 920
                              ? 3
                              : constraints.maxWidth >= 610
                                  ? 2
                                  : 1;
                          final width = (constraints.maxWidth - (columns - 1) * 16) / columns;

                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              SizedBox(
                                width: width,
                                child: _RoleCard(
                                  featured: true,
                                  icon: Icons.auto_graph_rounded,
                                  title: 'Super Admin',
                                  eyebrow: 'COMMAND CENTRE',
                                  description: 'See every client workspace, business signal and platform setting.',
                                  capabilities: const ['Client portfolio', 'Insights', 'Platform settings'],
                                  onTap: () => _openWorkspace(context, const SuperAdminScreen()),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: _RoleCard(
                                  icon: Icons.account_balance_rounded,
                                  title: 'Business Admin',
                                  eyebrow: 'OPERATIONS',
                                  description: 'Run day-to-day products, stock movement and inventory decisions.',
                                  capabilities: const ['Inventory', 'Stock flow', 'Products'],
                                  onTap: () => _openWorkspace(context, const InventoryScreen()),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: _RoleCard(
                                  icon: Icons.inventory_2_rounded,
                                  title: 'Staff',
                                  eyebrow: 'FIELD WORKSPACE',
                                  description: 'Keep essential stock activity accurate and move work forward.',
                                  capabilities: const ['Stock in', 'Stock out', 'Transactions'],
                                  onTap: () => _openWorkspace(context, const InventoryScreen()),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const Spacer(flex: 2),
                      const Center(
                        child: Text(
                          'You can switch workspaces from your organisation settings.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.capabilities,
    required this.onTap,
    this.featured = false,
  });

  final IconData icon;
  final String title;
  final String eyebrow;
  final String description;
  final List<String> capabilities;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final foreground = featured ? Colors.white : AppColors.ink;
    final muted = featured ? const Color(0xFFD3DDFB) : AppColors.muted;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 330,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: featured ? null : Colors.white,
            gradient: featured
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navy, Color(0xFF244A90)],
                  )
                : null,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: featured ? Colors.transparent : AppColors.line,
            ),
            boxShadow: [
              BoxShadow(
                color: (featured ? AppColors.navy : AppColors.ink).withValues(alpha: featured ? .20 : .06),
                blurRadius: featured ? 24 : 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: featured ? Colors.white.withValues(alpha: .13) : AppColors.mist,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: featured ? const Color(0xFF9CEBD9) : AppColors.primary),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_outward_rounded, color: featured ? Colors.white : AppColors.muted),
                ],
              ),
              const Spacer(),
              Text(
                eyebrow,
                style: TextStyle(
                  color: featured ? const Color(0xFF9CEBD9) : AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 7),
              Text(title, style: TextStyle(color: foreground, fontSize: 23, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(description, style: TextStyle(color: muted, height: 1.45, fontSize: 13)),
              const SizedBox(height: 17),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: capabilities
                    .map(
                      (capability) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: featured ? Colors.white.withValues(alpha: .11) : AppColors.canvas,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          capability,
                          style: TextStyle(color: featured ? Colors.white : AppColors.muted, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
