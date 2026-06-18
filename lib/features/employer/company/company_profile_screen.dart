import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../employer_shell.dart';

class _Company {
  final String id;
  final String name;
  final String? industry;
  final String? size;
  final String? website;
  final String? location;
  final String? description;
  final String? logo;
  final int? activeJobs;
  final int? applicants;

  const _Company({
    required this.id,
    required this.name,
    this.industry,
    this.size,
    this.website,
    this.location,
    this.description,
    this.logo,
    this.activeJobs,
    this.applicants,
  });

  factory _Company.fromJson(Map<String, dynamic> j) {
    final companies = j['companies'] as List?;
    final c = companies != null && companies.isNotEmpty
        ? companies.first as Map<String, dynamic>
        : j;
    return _Company(
      id: c['id']?.toString() ?? '',
      name: c['name'] as String? ?? c['company_name'] as String? ?? '—',
      industry: c['industry'] as String?,
      size: c['size'] as String? ?? c['company_size'] as String?,
      website: c['website'] as String?,
      location: c['location'] as String?,
      description: c['description'] as String?,
      logo: c['logo'] as String?,
      activeJobs: c['active_jobs'] as int?,
      applicants: c['total_applicants'] as int?,
    );
  }
}

final _companyProvider = FutureProvider.autoDispose<_Company>((ref) async {
  final res = await ref.watch(dioClientProvider).dio.get(Ep.employerMe);
  final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
  return _Company.fromJson(data);
});

class CompanyProfileScreen extends ConsumerWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_companyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        actions: [
          GestureDetector(
            onTap: () => context.push('/employer/settings'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Settings', style: AppText.label.copyWith(color: AppColors.surface)),
            ),
          ),
          const RoleSwitcherButton(),
        ],
      ),
      body: async.when(
        loading: () => const UJobLoading(),
        error: (e, _) => UJobError(
          message: 'Failed to load company profile',
          onRetry: () => ref.refresh(_companyProvider),
        ),
        data: (company) => _CompanyBody(company: company),
      ),
    );
  }
}

class _CompanyBody extends ConsumerWidget {
  final _Company company;
  const _CompanyBody({required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SingleChildScrollView(
        child: Column(children: [
          _CompanyHeader(company: company),
          const SizedBox(height: 16),
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _StatBox(value: company.activeJobs?.toString() ?? '—', label: 'Active Jobs'),
              const SizedBox(width: 12),
              _StatBox(value: company.applicants?.toString() ?? '—', label: 'Applicants'),
              const SizedBox(width: 12),
              _StatBox(value: '—', label: 'Rating'),
            ]),
          ),
          const SizedBox(height: 20),
          _CompanySection(
            title: 'Basic Info',
            subtitle: [company.name, company.industry, company.website].whereType<String>().join(' · '),
            onEdit: () => _showEditBasicInfo(context, ref, company),
          ),
          _CompanySection(
            title: 'About Company',
            subtitle: company.description?.isNotEmpty == true ? company.description! : 'Company description & mission',
            onEdit: () => _showEditDescription(context, ref, company),
          ),
          _CompanySection(
            title: 'Industry & Specialties',
            subtitle: company.industry ?? 'Technology · SaaS · AI / ML',
            onEdit: () {},
          ),
          _CompanySection(
            title: 'Social Links',
            subtitle: 'LinkedIn · Twitter · Facebook',
            onEdit: () {},
          ),
          _CompanySection(
            title: 'Contact Info',
            subtitle: 'Visibility: Public',
            onEdit: () {},
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: UJobButton(label: 'Save Changes', onTap: () {}),
          ),
          const SizedBox(height: 32),
        ]),
      );

  void _showEditBasicInfo(BuildContext context, WidgetRef ref, _Company company) {
    final nameCtrl     = TextEditingController(text: company.name);
    final industryCtrl = TextEditingController(text: company.industry);
    final websiteCtrl  = TextEditingController(text: company.website);
    final locationCtrl = TextEditingController(text: company.location);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Basic Info', style: AppText.heading3),
            const SizedBox(height: 20),
            UJobTextField(label: 'Company Name', controller: nameCtrl),
            UJobTextField(label: 'Industry', controller: industryCtrl),
            UJobTextField(label: 'Website', controller: websiteCtrl, keyboardType: TextInputType.url),
            UJobTextField(label: 'Location', controller: locationCtrl),
            UJobButton(
              label: 'Save Changes',
              onTap: () async {
                if (company.id.isEmpty) return;
                try {
                  await ref.read(dioClientProvider).dio.put(Ep.empCompany(company.id), data: {
                    'name': nameCtrl.text,
                    'industry': industryCtrl.text,
                    'website': websiteCtrl.text,
                    'location': locationCtrl.text,
                  });
                  ref.invalidate(_companyProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (_) {}
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _showEditDescription(BuildContext context, WidgetRef ref, _Company company) {
    final descCtrl = TextEditingController(text: company.description);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('About Company', style: AppText.heading3),
          const SizedBox(height: 20),
          UJobTextField(
            label: 'Description & Mission',
            controller: descCtrl,
            maxLines: 5,
          ),
          UJobButton(
            label: 'Save',
            onTap: () async {
              if (company.id.isEmpty) return;
              try {
                await ref.read(dioClientProvider).dio.put(Ep.empCompany(company.id), data: {
                  'description': descCtrl.text,
                });
                ref.invalidate(_companyProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (_) {}
            },
          ),
        ]),
      ),
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  final _Company company;
  const _CompanyHeader({required this.company});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.empPrimaryDark, AppColors.empPrimary, AppColors.empSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(children: [
          Stack(alignment: Alignment.bottomRight, children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.2),
                borderRadius: AppRadius.lg,
              ),
              child: Center(
                child: Text(
                  company.name.isNotEmpty ? company.name[0].toUpperCase() : 'A',
                  style: AppText.heading1.copyWith(color: AppColors.white),
                ),
              ),
            ),
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: const HugeIcon(icon: HugeIcons.strokeRoundedCamera01, size: 14, color: AppColors.empPrimary),
          ),
          ]),
          const SizedBox(height: 12),
          Text(company.name, style: AppText.heading3.copyWith(color: AppColors.white)),
          if (company.industry != null || company.size != null)
            Text(
              [company.industry, company.size, company.website].whereType<String>().join(' · '),
              style: AppText.small.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
            ),
          if (company.location != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                company.location!,
                style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.7)),
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: AppRadius.md,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Profile Completeness', style: AppText.label.copyWith(color: AppColors.white)),
                Text('0%', style: AppText.label.copyWith(color: AppColors.white)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value: 0.0,
                  backgroundColor: AppColors.white.withValues(alpha: 0.2),
                  color: AppColors.white,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add social links to reach 80%',
                style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.7)),
              ),
            ]),
          ),
        ]),
      );
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(children: [
            Text(value, style: AppText.heading3.copyWith(color: AppColors.empPrimary)),
            const SizedBox(height: 2),
            Text(label, style: AppText.caption.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _CompanySection extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onEdit;

  const _CompanySection({required this.title, required this.subtitle, required this.onEdit});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: AppRadius.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: AppText.bodyBold),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.small.copyWith(color: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              Text(context.l10n.edit, style: AppText.label.copyWith(color: AppColors.empPrimary)),
              const SizedBox(width: 8),
              const HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, color: AppColors.empPrimary, size: 18),
            ]),
          ),
        ),
      );
}
