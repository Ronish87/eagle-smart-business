import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../repository/client_repository.dart';
import '../../theme/app_theme.dart';

class CreateClientScreen extends StatefulWidget {
  const CreateClientScreen({super.key});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ClientRepository();

  final _companyController = TextEditingController();
  final _ownerController = TextEditingController();
  final _adminController = TextEditingController();
  final _mobileController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessTypeController = TextEditingController(text: 'Retail');
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _provinceController = TextEditingController();
  final _panController = TextEditingController();
  final _vatController = TextEditingController();
  final _registrationController = TextEditingController();

  bool _webAccess = true;
  bool _mobileAccess = true;
  bool _saving = false;

  @override
  void dispose() {
    _companyController.dispose();
    _ownerController.dispose();
    _adminController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _businessTypeController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _panController.dispose();
    _vatController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final ownerName = _ownerController.text.trim();
    final adminName = _adminController.text.trim();

    try {
      await _repository.insertClient(
        ClientModel(
          companyName: _companyController.text.trim(),
          ownerName: ownerName,
          adminName: adminName.isEmpty ? ownerName : adminName,
          mobile: _mobileController.text.trim(),
          whatsapp: _whatsappController.text.trim(),
          email: _emailController.text.trim(),
          businessType: _businessTypeController.text.trim(),
          address: _addressController.text.trim(),
          district: _districtController.text.trim(),
          province: _provinceController.text.trim(),
          country: 'Nepal',
          panNo: _panController.text.trim(),
          vatNo: _vatController.text.trim(),
          registrationNo: _registrationController.text.trim(),
          webAccess: _webAccess,
          mobileAccess: _mobileAccess,
          status: 'Active',
          createdDate: DateTime.now().toIso8601String(),
        ),
      );

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        const SnackBar(content: Text('Client workspace created successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not create this client. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create client'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  const _FormIntro(),
                  const SizedBox(height: 24),
                  _FormSection(
                    number: '01',
                    title: 'Business profile',
                    subtitle: 'The essentials for this new client workspace.',
                    child: _ResponsiveFields(
                      children: [
                        _FieldSpec(
                          controller: _companyController,
                          label: 'Company name',
                          hint: 'e.g. Himalayan Traders',
                          icon: Icons.business_rounded,
                          validator: _required('Enter the company name'),
                        ),
                        _FieldSpec(
                          controller: _businessTypeController,
                          label: 'Business type',
                          hint: 'e.g. Retail',
                          icon: Icons.category_rounded,
                          validator: _required('Enter the business type'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormSection(
                    number: '02',
                    title: 'Primary contacts',
                    subtitle: 'Who should we contact about this workspace?',
                    child: _ResponsiveFields(
                      children: [
                        _FieldSpec(
                          controller: _ownerController,
                          label: 'Owner name',
                          hint: 'Full name',
                          icon: Icons.person_rounded,
                          validator: _required('Enter the owner name'),
                        ),
                        _FieldSpec(
                          controller: _adminController,
                          label: 'Workspace admin',
                          hint: 'Defaults to the owner',
                          icon: Icons.admin_panel_settings_rounded,
                        ),
                        _FieldSpec(
                          controller: _mobileController,
                          label: 'Mobile number',
                          hint: '98XXXXXXXX',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: _required('Enter a mobile number'),
                        ),
                        _FieldSpec(
                          controller: _emailController,
                          label: 'Email address',
                          hint: 'name@company.com',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                        ),
                        _FieldSpec(
                          controller: _whatsappController,
                          label: 'WhatsApp number',
                          hint: 'Optional',
                          icon: Icons.chat_bubble_outline_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormSection(
                    number: '03',
                    title: 'Location & registration',
                    subtitle: 'Optional details that keep records complete.',
                    child: _ResponsiveFields(
                      children: [
                        _FieldSpec(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'Street / locality',
                          icon: Icons.location_on_outlined,
                        ),
                        _FieldSpec(
                          controller: _districtController,
                          label: 'District',
                          hint: 'e.g. Kathmandu',
                          icon: Icons.map_outlined,
                        ),
                        _FieldSpec(
                          controller: _provinceController,
                          label: 'Province',
                          hint: 'e.g. Bagmati',
                          icon: Icons.public_rounded,
                        ),
                        _FieldSpec(
                          controller: _panController,
                          label: 'PAN number',
                          hint: 'Optional',
                          icon: Icons.badge_outlined,
                        ),
                        _FieldSpec(
                          controller: _vatController,
                          label: 'VAT number',
                          hint: 'Optional',
                          icon: Icons.receipt_long_rounded,
                        ),
                        _FieldSpec(
                          controller: _registrationController,
                          label: 'Registration number',
                          hint: 'Optional',
                          icon: Icons.verified_user_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormSection(
                    number: '04',
                    title: 'Access package',
                    subtitle: 'Choose where this team can use Eagle Smart Business.',
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 560;
                        final web = _AccessToggle(
                          icon: Icons.language_rounded,
                          title: 'Web workspace',
                          subtitle: 'Browser access for the office team',
                          value: _webAccess,
                          onChanged: (value) => setState(() => _webAccess = value),
                        );
                        final mobile = _AccessToggle(
                          icon: Icons.phone_iphone_rounded,
                          title: 'Mobile companion',
                          subtitle: 'Access on the go for the field team',
                          value: _mobileAccess,
                          onChanged: (value) =>
                              setState(() => _mobileAccess = value),
                        );

                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(child: web),
                              const SizedBox(width: 12),
                              Expanded(child: mobile),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            web,
                            const SizedBox(height: 12),
                            mobile,
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_business_rounded),
                      label: Text(_saving ? 'Creating workspace...' : 'Create client workspace'),
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

  String? Function(String?) _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}

class _FormIntro extends StatelessWidget {
  const _FormIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, Color(0xFF1B3562)],
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IntroIcon(),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set up a new workspace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Start with the essentials. You can enrich this profile anytime from the client directory.',
                  style: TextStyle(color: Color(0xFFD3DDFB), height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroIcon extends StatelessWidget {
  const _IntroIcon();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SizedBox(
        width: 48,
        height: 48,
        child: Icon(Icons.rocket_launch_rounded, color: Colors.white),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String number;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _FieldSpec {
  const _FieldSpec({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<_FieldSpec> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 2 : 1;
        final fieldWidth =
            (constraints.maxWidth - (columns - 1) * 14) / columns;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: children
              .map(
                (field) => SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: field.controller,
                    keyboardType: field.keyboardType,
                    validator: field.validator,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: field.label,
                      hintText: field.hint,
                      prefixIcon: Icon(field.icon, size: 20),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AccessToggle extends StatelessWidget {
  const _AccessToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: value ? AppColors.mist.withValues(alpha: .6) : AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? AppColors.primary.withValues(alpha: .26) : AppColors.line,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: value ? Colors.white : AppColors.muted, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
