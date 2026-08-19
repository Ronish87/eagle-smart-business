import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../repository/client_repository.dart';
import '../../theme/app_theme.dart';
import 'create_client_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final _repository = ClientRepository();
  final _searchController = TextEditingController();

  List<ClientModel> _clients = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final clients = await _repository.getAllClients();
      if (!mounted) return;
      setState(() => _clients = clients);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Your client directory could not be loaded.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createClient() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateClientScreen()),
    );
    if (created == true) await _loadClients();
  }

  Future<void> _deleteClient(ClientModel client) async {
    if (client.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove client?'),
        content: Text(
          '${client.companyName} will be removed from your client directory. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep client'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC4D5D)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repository.deleteClient(client.id!);
      await _loadClients();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client removed from the directory.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove this client.')),
      );
    }
  }

  void _showClientDetails(ClientModel client) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClientDetailsSheet(client: client),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _clients.where((client) {
      if (query.isEmpty) return true;
      return client.companyName.toLowerCase().contains(query) ||
          client.ownerName.toLowerCase().contains(query) ||
          client.mobile.toLowerCase().contains(query) ||
          client.businessType.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client directory'),
        actions: [
          IconButton(
            tooltip: 'Refresh clients',
            onPressed: _loading ? null : _loadClients,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadClients,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 560;
                      final title = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your client directory',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Keep every client workspace and primary contact in one place.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      );
                      final action = FilledButton.icon(
                        onPressed: _createClient,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('New client'),
                      );

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [title, const SizedBox(height: 16), action],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [Expanded(child: title), action],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search company, owner, mobile or business type',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DirectorySummary(
                    count: _clients.length,
                    activeCount: _clients
                        .where((client) => client.status.toLowerCase() == 'active')
                        .length,
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const _ListLoadingState()
                  else if (_error != null)
                    _LoadError(onRetry: _loadClients)
                  else if (filtered.isEmpty)
                    _EmptyClients(
                      hasSearch: query.isNotEmpty,
                      onCreate: _createClient,
                    )
                  else
                    ...filtered.map(
                      (client) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ClientCard(
                          client: client,
                          onTap: () => _showClientDetails(client),
                          onDelete: () => _deleteClient(client),
                        ),
                      ),
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

class _DirectorySummary extends StatelessWidget {
  const _DirectorySummary({required this.count, required this.activeCount});

  final int count;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.mist.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count ${count == 1 ? 'workspace' : 'workspaces'} in your directory',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '$activeCount active',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ListLoadingState extends StatelessWidget {
  const _ListLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 36, color: AppColors.coral),
          const SizedBox(height: 12),
          const Text('Directory unavailable', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(
            'Check the local database connection and try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyClients extends StatelessWidget {
  const _EmptyClients({required this.hasSearch, required this.onCreate});

  final bool hasSearch;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_business_rounded, color: AppColors.primary, size: 29),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'No matching clients' : 'Your client directory is ready',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            hasSearch
                ? 'Try a different company, owner or mobile number.'
                : 'Create your first workspace to start managing clients from one focused place.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create first client'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.onTap,
    required this.onDelete,
  });

  final ClientModel client;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final active = client.status.toLowerCase() == 'active';
    final name = client.companyName.trim();
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final information = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          client.companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(active: active, label: client.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${client.ownerName}  ·  ${client.businessType}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 7,
                    children: [
                      _TinyDetail(icon: Icons.phone_rounded, label: client.mobile),
                      if (client.email.isNotEmpty)
                        _TinyDetail(icon: Icons.alternate_email_rounded, label: client.email),
                    ],
                  ),
                ],
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: compact ? 22 : 25,
                    backgroundColor: AppColors.mist,
                    foregroundColor: AppColors.primary,
                    child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(child: information),
                  PopupMenuButton<String>(
                    tooltip: 'Client options',
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Color(0xFFDC4D5D)),
                            SizedBox(width: 10),
                            Text('Remove client'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TinyDetail extends StatelessWidget {
  const _TinyDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 190),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.mint : AppColors.coral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label.isEmpty ? (active ? 'Active' : 'Inactive') : label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ClientDetailsSheet extends StatelessWidget {
  const _ClientDetailsSheet({required this.client});

  final ClientModel client;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        margin: const EdgeInsets.only(top: 72),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.mist,
                  foregroundColor: AppColors.primary,
                  child: Text(
                    client.companyName.isEmpty
                        ? '?'
                        : client.companyName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.companyName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 3),
                      Text(client.businessType, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 26),
            _DetailGroup(
              title: 'Contact',
              items: [
                _DetailItem(Icons.person_outline_rounded, 'Owner', client.ownerName),
                _DetailItem(Icons.admin_panel_settings_outlined, 'Admin', client.adminName),
                _DetailItem(Icons.phone_outlined, 'Mobile', client.mobile),
                _DetailItem(Icons.alternate_email_rounded, 'Email', client.email),
              ],
            ),
            const SizedBox(height: 14),
            _DetailGroup(
              title: 'Business details',
              items: [
                _DetailItem(Icons.location_on_outlined, 'Address', _addressValue(client)),
                _DetailItem(Icons.badge_outlined, 'PAN', client.panNo),
                _DetailItem(Icons.receipt_long_outlined, 'VAT', client.vatNo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _addressValue(ClientModel client) {
    return [client.address, client.district, client.province]
        .where((part) => part.trim().isNotEmpty)
        .join(', ');
  }
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.title, required this.items});

  final String title;
  final List<_DetailItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Icon(item.icon, size: 18, color: AppColors.muted),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 74,
                    child: Text(item.label, style: const TextStyle(color: AppColors.muted)),
                  ),
                  Expanded(
                    child: Text(
                      item.value.trim().isEmpty ? 'Not provided' : item.value,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  const _DetailItem(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}
