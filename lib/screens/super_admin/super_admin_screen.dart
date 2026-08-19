import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../repository/client_repository.dart';
import '../../repository/product_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_mark.dart';
import '../inventory/inventory_screen.dart';
import 'admin_management_screen.dart';
import 'business_profile_screen.dart';
import 'client_list_screen.dart';
import 'create_client_screen.dart';
import 'renewal_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

/// The primary operational workspace for Eagle Smart Business.
///
/// It deliberately uses real local repository data rather than sample numbers,
/// so an empty installation gives a useful call-to-action instead of a fake
/// dashboard.
class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _clientRepository = ClientRepository();
  final _productRepository = ProductRepository();

  _DashboardSnapshot _snapshot = const _DashboardSnapshot();
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      // Start all reads together so the dashboard is quick even as data grows.
      final clientsFuture = _clientRepository.getAllClients();
      final productsFuture = _productRepository.getAll();
      final lowStockFuture = _productRepository.getLowStockProducts();

      final clients = await clientsFuture;
      final products = await productsFuture;
      final lowStockProducts = await lowStockFuture;

      if (!mounted) return;
      setState(() {
        _snapshot = _DashboardSnapshot(
          totalClients: clients.length,
          activeClients: clients
              .where((client) => client.status.trim().toLowerCase() == 'active')
              .length,
          productCount: products.length,
          lowStockCount: lowStockProducts.length,
          recentClients: clients.take(4).toList(),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Live workspace data is temporarily unavailable.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDestination(
    int index, {
    bool closeDrawer = false,
  }) async {
    if (closeDrawer && _scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }

    Widget? page;
    switch (index) {
      case 1:
        page = const ClientListScreen();
        break;
      case 2:
        page = const AdminManagementScreen();
        break;
      case 3:
        page = const BusinessProfileScreen();
        break;
      case 4:
        page = const RenewalScreen();
        break;
      case 5:
        page = const ReportScreen();
        break;
      case 6:
        page = const SettingsScreen();
        break;
    }

    if (page == null) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => page!),
    );

    if (mounted) _refreshDashboard();
  }

  Future<void> _createClient() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateClientScreen()),
    );
    if (created == true && mounted) _refreshDashboard();
  }

  Future<void> _openInventory() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const InventoryScreen()),
    );
    if (mounted) _refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth >= 1080;

        return Scaffold(
          key: _scaffoldKey,
          drawer: showSidebar
              ? null
              : Drawer(
                  child: SafeArea(
                    child: _Sidebar(
                      selectedIndex: 0,
                      onDestinationSelected: (index) =>
                          _openDestination(index, closeDrawer: true),
                    ),
                  ),
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (showSidebar)
                  SizedBox(
                    width: 272,
                    child: _Sidebar(
                      selectedIndex: 0,
                      onDestinationSelected: (index) => _openDestination(index),
                    ),
                  ),
                Expanded(
                  child: _DashboardBody(
                    snapshot: _snapshot,
                    loading: _loading,
                    loadError: _loadError,
                    hasSidebar: showSidebar,
                    onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                    onRefresh: _refreshDashboard,
                    onCreateClient: _createClient,
                    onOpenClients: () => _openDestination(1),
                    onOpenInventory: _openInventory,
                    onOpenReports: () => _openDestination(5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardSnapshot {
  const _DashboardSnapshot({
    this.totalClients = 0,
    this.activeClients = 0,
    this.productCount = 0,
    this.lowStockCount = 0,
    this.recentClients = const [],
  });

  final int totalClients;
  final int activeClients;
  final int productCount;
  final int lowStockCount;
  final List<ClientModel> recentClients;

  double get activeClientRatio {
    if (totalClients == 0) return 0;
    return activeClients / totalClients;
  }

  double get catalogHealth {
    if (productCount == 0) return 0;
    return ((productCount - lowStockCount).clamp(0, productCount) / productCount).toDouble();
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.snapshot,
    required this.loading,
    required this.loadError,
    required this.hasSidebar,
    required this.onMenu,
    required this.onRefresh,
    required this.onCreateClient,
    required this.onOpenClients,
    required this.onOpenInventory,
    required this.onOpenReports,
  });

  final _DashboardSnapshot snapshot;
  final bool loading;
  final String? loadError;
  final bool hasSidebar;
  final VoidCallback onMenu;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreateClient;
  final VoidCallback onOpenClients;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenReports;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        final horizontalPadding = compact ? 16.0 : 30.0;

        return RefreshIndicator(
          onRefresh: onRefresh,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 36),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DashboardTopbar(
                        compact: compact,
                        hasSidebar: hasSidebar,
                        onMenu: onMenu,
                        onRefresh: loading ? null : () { onRefresh(); },
                      ),
                      const SizedBox(height: 24),
                      _IntelligenceHero(
                        snapshot: snapshot,
                        loading: loading,
                        onCreateClient: onCreateClient,
                      ),
                      if (loadError != null) ...[
                        const SizedBox(height: 14),
                        _DataNotice(message: loadError!, onRetry: onRefresh),
                      ],
                      const SizedBox(height: 26),
                      _SectionHeading(
                        eyebrow: 'AT A GLANCE',
                        title: 'The numbers that matter',
                        action: TextButton.icon(
                          onPressed: loading ? null : () { onRefresh(); },
                          icon: const Icon(Icons.sync_rounded, size: 18),
                          label: const Text('Refresh data'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MetricGrid(snapshot: snapshot, loading: loading),
                      const SizedBox(height: 26),
                      LayoutBuilder(
                        builder: (context, area) {
                          final twoColumns = area.maxWidth >= 930;
                          final recentClients = _RecentClientsCard(
                            clients: snapshot.recentClients,
                            loading: loading,
                            onCreateClient: onCreateClient,
                            onOpenClients: onOpenClients,
                          );
                          final actionPanel = _ActionAndHealthCard(
                            snapshot: snapshot,
                            loading: loading,
                            onCreateClient: onCreateClient,
                            onOpenClients: onOpenClients,
                            onOpenInventory: onOpenInventory,
                            onOpenReports: onOpenReports,
                          );

                          if (twoColumns) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 12, child: recentClients),
                                const SizedBox(width: 20),
                                Expanded(flex: 8, child: actionPanel),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              recentClients,
                              const SizedBox(height: 20),
                              actionPanel,
                            ],
                          );
                        },
                      ),
                      if (!loading && snapshot.lowStockCount > 0) ...[
                        const SizedBox(height: 20),
                        _InventoryAttentionCard(
                          count: snapshot.lowStockCount,
                          onOpenInventory: onOpenInventory,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardTopbar extends StatelessWidget {
  const _DashboardTopbar({
    required this.compact,
    required this.hasSidebar,
    required this.onMenu,
    required this.onRefresh,
  });

  final bool compact;
  final bool hasSidebar;
  final VoidCallback onMenu;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _greetingFor(now);

    if (compact) {
      return Row(
        children: [
          if (!hasSidebar) ...[
            _TopIconButton(
              tooltip: 'Open navigation',
              icon: Icons.menu_rounded,
              onPressed: onMenu,
            ),
            const SizedBox(width: 10),
          ],
          const EagleMark(size: 38, compact: true),
          const Spacer(),
          _TopIconButton(
            tooltip: 'Refresh dashboard',
            icon: Icons.refresh_rounded,
            onPressed: onRefresh,
          ),
          const SizedBox(width: 9),
          const _ProfileAvatar(),
        ],
      );
    }

    return Row(
      children: [
        if (!hasSidebar) ...[
          _TopIconButton(
            tooltip: 'Open navigation',
            icon: Icons.menu_rounded,
            onPressed: onMenu,
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, Super Admin',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 25),
              ),
              const SizedBox(height: 4),
              Text(
                'Here is your business pulse for ${_friendlyDate(now)}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        _DatePill(date: now),
        const SizedBox(width: 12),
        _TopIconButton(
          tooltip: 'Refresh dashboard',
          icon: Icons.refresh_rounded,
          onPressed: onRefresh,
        ),
        const SizedBox(width: 10),
        const _ProfileAvatar(),
      ],
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Icon(icon, color: onPressed == null ? AppColors.line : AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            _shortDate(date),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Super Admin',
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8EA9FF), AppColors.primary],
          ),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'SA',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _IntelligenceHero extends StatelessWidget {
  const _IntelligenceHero({
    required this.snapshot,
    required this.loading,
    required this.onCreateClient,
  });

  final _DashboardSnapshot snapshot;
  final bool loading;
  final VoidCallback onCreateClient;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final clientsLabel = loading ? 'Syncing' : '${snapshot.totalClients} clients';
        final activeLabel = loading ? 'Updating' : '${snapshot.activeClients} active';

        return Container(
          clipBehavior: Clip.antiAlias,
          constraints: BoxConstraints(minHeight: isWide ? 232 : 290),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navy, Color(0xFF1A3564), Color(0xFF3159A5)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: .20),
                blurRadius: 26,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -70,
                top: -92,
                child: _GlowOrb(size: 250, color: const Color(0xFF89A3FF).withValues(alpha: .22)),
              ),
              Positioned(
                right: isWide ? 70 : -25,
                bottom: -88,
                child: _GlowOrb(size: 230, color: AppColors.mint.withValues(alpha: .13)),
              ),
              Positioned(
                right: isWide ? 34 : -2,
                top: isWide ? 34 : 132,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: isWide ? 1 : .66,
                    child: SizedBox(
                      width: isWide ? 308 : 258,
                      height: 145,
                      child: CustomPaint(painter: const _PulseChartPainter()),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isWide ? 28 : 22),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 560 : 330),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _LiveBadge(),
                      const SizedBox(height: 16),
                      Text(
                        'A calmer way to run every workspace.',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontSize: isWide ? 28 : 24,
                              height: 1.08,
                            ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'See clients, inventory and priority actions from one focused command centre.',
                        style: TextStyle(color: Color(0xFFD9E3FF), height: 1.45),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _HeroMetric(icon: Icons.groups_rounded, label: clientsLabel),
                          _HeroMetric(icon: Icons.verified_rounded, label: activeLabel),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        ),
                        onPressed: onCreateClient,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create a client'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(),
          SizedBox(width: 7),
          Text(
            'EAGLE INTELLIGENCE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFBFD1FF)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _PulseChartPainter extends CustomPainter {
  const _PulseChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: .12)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path()
      ..moveTo(0, size.height * .76)
      ..cubicTo(size.width * .10, size.height * .70, size.width * .14, size.height * .35,
          size.width * .25, size.height * .49)
      ..cubicTo(size.width * .35, size.height * .64, size.width * .41, size.height * .53,
          size.width * .50, size.height * .58)
      ..cubicTo(size.width * .63, size.height * .65, size.width * .67, size.height * .16,
          size.width * .77, size.height * .32)
      ..cubicTo(size.width * .85, size.height * .44, size.width * .91, size.height * .20,
          size.width, size.height * .12);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: .22), Colors.white.withValues(alpha: 0)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF9CEBD9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    final end = Offset(size.width, size.height * .12);
    canvas.drawCircle(end, 6, Paint()..color = Colors.white.withValues(alpha: .30));
    canvas.drawCircle(end, 3.2, Paint()..color = const Color(0xFF9CEBD9));
  }

  @override
  bool shouldRepaint(covariant _PulseChartPainter oldDelegate) => false;
}

class _DataNotice extends StatelessWidget {
  const _DataNotice({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amber.withValues(alpha: .38)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFB9790D), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF7E5A17), fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(onPressed: () { onRetry(); }, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    this.action,
  });

  final String eyebrow;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.snapshot, required this.loading});

  final _DashboardSnapshot snapshot;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        title: 'Client workspaces',
        value: loading ? '—' : '${snapshot.totalClients}',
        subtitle: loading ? 'Loading directory' : 'In your directory',
        icon: Icons.groups_rounded,
        color: AppColors.primary,
      ),
      _MetricData(
        title: 'Active clients',
        value: loading ? '—' : '${snapshot.activeClients}',
        subtitle: loading ? 'Checking status' : 'Ready to operate',
        icon: Icons.verified_rounded,
        color: AppColors.mint,
      ),
      _MetricData(
        title: 'Product catalogue',
        value: loading ? '—' : '${snapshot.productCount}',
        subtitle: loading ? 'Loading inventory' : 'Tracked inventory items',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFF8B6DDF),
      ),
      _MetricData(
        title: 'Stock attention',
        value: loading ? '—' : '${snapshot.lowStockCount}',
        subtitle: loading
            ? 'Reviewing stock levels'
            : snapshot.lowStockCount == 0
                ? 'Everything is well stocked'
                : 'Items need a restock',
        icon: Icons.inventory_rounded,
        color: snapshot.lowStockCount == 0 ? AppColors.sky : AppColors.coral,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1150
            ? 4
            : constraints.maxWidth >= 610
                ? 2
                : 1;
        final ratio = columns == 1
            ? 2.45
            : columns == 2
                ? 1.75
                : 1.58;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: ratio,
          ),
          itemBuilder: (context, index) => _MetricCard(data: metrics[index]),
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(data.icon, color: data.color, size: 21),
              ),
              const Spacer(),
              Icon(Icons.north_east_rounded, color: data.color.withValues(alpha: .70), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.title, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 3),
          Text(
            data.value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RecentClientsCard extends StatelessWidget {
  const _RecentClientsCard({
    required this.clients,
    required this.loading,
    required this.onCreateClient,
    required this.onOpenClients,
  });

  final List<ClientModel> clients;
  final bool loading;
  final VoidCallback onCreateClient;
  final VoidCallback onOpenClients;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionMiniIcon(icon: Icons.groups_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recently added clients', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    const Text('Newest workspaces in your directory', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              TextButton(onPressed: onOpenClients, child: const Text('View all')),
            ],
          ),
          const SizedBox(height: 18),
          if (loading)
            const _CardLoading(height: 208)
          else if (clients.isEmpty)
            _ClientEmptyState(onCreateClient: onCreateClient)
          else
            ...List.generate(
              clients.length,
              (index) => Column(
                children: [
                  _RecentClientRow(client: clients[index], onTap: onOpenClients),
                  if (index != clients.length - 1) const Divider(height: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentClientRow extends StatelessWidget {
  const _RecentClientRow({required this.client, required this.onTap});

  final ClientModel client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final businessName = client.companyName.trim();
    final initial = businessName.isEmpty ? '?' : businessName.substring(0, 1).toUpperCase();
    final active = client.status.trim().toLowerCase() == 'active';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.mist,
              foregroundColor: AppColors.primary,
              child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${client.ownerName} · ${client.businessType}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CompactStatus(active: active),
          ],
        ),
      ),
    );
  }
}

class _CompactStatus extends StatelessWidget {
  const _CompactStatus({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.mint : AppColors.coral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        active ? 'Active' : 'Paused',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ClientEmptyState extends StatelessWidget {
  const _ClientEmptyState({required this.onCreateClient});

  final VoidCallback onCreateClient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 29),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(color: AppColors.mist, shape: BoxShape.circle),
            child: const Icon(Icons.add_business_rounded, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text('Build your first client workspace', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text(
            'Start with a client profile, then keep their business operations in view.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreateClient,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create first client'),
          ),
        ],
      ),
    );
  }
}

class _ActionAndHealthCard extends StatelessWidget {
  const _ActionAndHealthCard({
    required this.snapshot,
    required this.loading,
    required this.onCreateClient,
    required this.onOpenClients,
    required this.onOpenInventory,
    required this.onOpenReports,
  });

  final _DashboardSnapshot snapshot;
  final bool loading;
  final VoidCallback onCreateClient;
  final VoidCallback onOpenClients;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenReports;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionMiniIcon(icon: Icons.bolt_rounded, color: AppColors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Command shortcuts', style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _ActionRow(
            icon: Icons.add_business_rounded,
            iconColor: AppColors.primary,
            title: 'Create client',
            subtitle: 'Open a new workspace',
            onTap: onCreateClient,
          ),
          _ActionRow(
            icon: Icons.groups_rounded,
            iconColor: AppColors.mint,
            title: 'Client directory',
            subtitle: 'Browse all workspaces',
            onTap: onOpenClients,
          ),
          _ActionRow(
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFF8B6DDF),
            title: 'Inventory centre',
            subtitle: 'Products and stock flow',
            onTap: onOpenInventory,
          ),
          _ActionRow(
            icon: Icons.insights_rounded,
            iconColor: AppColors.coral,
            title: 'Reports',
            subtitle: 'Review business signals',
            onTap: onOpenReports,
            showDivider: false,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 18),
          Row(
            children: [
              const _SectionMiniIcon(icon: Icons.health_and_safety_rounded, color: AppColors.mint),
              const SizedBox(width: 10),
              Text('Workspace health', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          _HealthRow(
            title: 'Client activity',
            value: loading
                ? 'Syncing'
                : snapshot.totalClients == 0
                    ? 'Ready to begin'
                    : '${snapshot.activeClients}/${snapshot.totalClients} active',
            progress: loading ? .18 : snapshot.activeClientRatio,
            color: AppColors.mint,
          ),
          const SizedBox(height: 15),
          _HealthRow(
            title: 'Inventory coverage',
            value: loading
                ? 'Syncing'
                : snapshot.productCount == 0
                    ? 'No products yet'
                    : snapshot.lowStockCount == 0
                        ? 'Stock levels look good'
                        : '${snapshot.lowStockCount} needs attention',
            progress: loading ? .18 : snapshot.catalogHealth,
            color: snapshot.lowStockCount == 0 ? AppColors.primary : AppColors.coral,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 19, color: iconColor),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.muted, size: 18),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String title;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1).toDouble(),
            minHeight: 7,
            backgroundColor: AppColors.mist,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _InventoryAttentionCard extends StatelessWidget {
  const _InventoryAttentionCard({required this.count, required this.onOpenInventory});

  final int count;
  final VoidCallback onOpenInventory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F2),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.coral.withValues(alpha: .28)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 560;
          final message = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_rounded, color: AppColors.coral),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$count ${count == 1 ? 'item needs' : 'items need'} stock attention',
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    const Text(
                      'Review low stock levels before they interrupt a client operation.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
          final action = OutlinedButton.icon(
            onPressed: onOpenInventory,
            icon: const Icon(Icons.arrow_forward_rounded, size: 17),
            label: const Text('Review inventory'),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [message, const SizedBox(height: 14), action],
            );
          }
          return Row(children: [Expanded(child: message), const SizedBox(width: 18), action]);
        },
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _SectionMiniIcon extends StatelessWidget {
  const _SectionMiniIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(11)),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _CardLoading extends StatelessWidget {
  const _CardLoading({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(18)),
      child: const CircularProgressIndicator(strokeWidth: 2.5),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _items = [
    _NavigationItem('Overview', Icons.grid_view_rounded),
    _NavigationItem('Clients', Icons.groups_rounded),
    _NavigationItem('Team access', Icons.admin_panel_settings_rounded),
    _NavigationItem('Business profiles', Icons.business_center_rounded),
    _NavigationItem('Renewals', Icons.autorenew_rounded),
    _NavigationItem('Reports', Icons.insights_rounded),
    _NavigationItem('Settings', Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SidebarBrand(),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'WORKSPACE',
                style: TextStyle(
                  color: Color(0xFF91A5CA),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _SidebarTile(
                    item: item,
                    selected: index == selectedIndex,
                    onTap: () => onDestinationSelected(index),
                  );
                },
              ),
            ),
            const _SidebarFooter(),
          ],
        ),
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const EagleMark(size: 40, compact: true),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Eagle',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: .95),
              ),
              SizedBox(height: 4),
              Text(
                'SMART BUSINESS',
                style: TextStyle(
                  color: Color(0xFF9EB4E4),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavigationItem {
  const _NavigationItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white.withValues(alpha: .12) : Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(item.icon, color: selected ? Colors.white : const Color(0xFFB1C0DD), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFB1C0DD),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (selected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFF577CE7),
            child: Text('SA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Super Admin', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('Control centre', style: TextStyle(color: Color(0xFF9EB4E4), fontSize: 10)),
              ],
            ),
          ),
          Icon(Icons.more_horiz_rounded, color: Color(0xFFB1C0DD), size: 19),
        ],
      ),
    );
  }
}

String _greetingFor(DateTime date) {
  if (date.hour < 12) return 'Good morning';
  if (date.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _friendlyDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

String _shortDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
