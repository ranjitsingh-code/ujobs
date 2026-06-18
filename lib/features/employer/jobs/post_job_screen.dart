import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import 'employer_job_provider.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _titleCtrl       = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _cityCtrl        = TextEditingController();
  final _salaryMinCtrl   = TextEditingController();
  final _salaryMaxCtrl   = TextEditingController();
  final _skillsCtrl      = TextEditingController();
  String _employmentType = 'full_time';
  String _workplaceType  = 'on_site';
  String _resumeRequired = 'required';
  bool _isLoading = false;

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorFillTitleDesc)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'title': _titleCtrl.text,
        'description': _descCtrl.text,
        'city': _cityCtrl.text,
        'salary_min': _salaryMinCtrl.text,
        'salary_max': _salaryMaxCtrl.text,
        'preferred_skills': _skillsCtrl.text,
        'employment_type': _employmentType,
        'workplace_type': _workplaceType,
        'resume_required': _resumeRequired,
        'category_id': "9",
        'application_method': 'internal',
      };

      await ref.read(employerJobServiceProvider).postJob(data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.jobPostedSuccess)));
        ref.invalidate(employerJobsProvider(null));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.postJob)),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePad,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          UJobTextField(label: l10n.jobTitle, hint: l10n.jobTitleJobHint, controller: _titleCtrl),
          const SizedBox(height: 16),
          UJobTextField(label: l10n.jobDescription, hint: l10n.descriptionHint, controller: _descCtrl, maxLines: 4),
          const SizedBox(height: 16),
          UJobTextField(label: l10n.city, hint: l10n.cityHint, controller: _cityCtrl),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: UJobTextField(label: l10n.salaryMin, hint: l10n.salaryMinHint, controller: _salaryMinCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: UJobTextField(label: l10n.salaryMax, hint: l10n.salaryMaxHint, controller: _salaryMaxCtrl, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          UJobTextField(label: l10n.skills, hint: l10n.skillsHint, controller: _skillsCtrl),
          const SizedBox(height: 16),
          _DropdownField(
            label: l10n.employmentType,
            value: _employmentType,
            items: {
              'full_time': l10n.fullTime,
              'part_time': l10n.partTime,
              'contract': l10n.contract,
              'internship': l10n.internship
            },
            onChanged: (v) => setState(() => _employmentType = v!),
          ),
          const SizedBox(height: 16),
          _DropdownField(
            label: l10n.workplaceType,
            value: _workplaceType,
            items: {'on_site': l10n.onSite, 'remote': l10n.remote, 'hybrid': l10n.hybrid},
            onChanged: (v) => setState(() => _workplaceType = v!),
          ),
          const SizedBox(height: 16),
          _DropdownField(
            label: l10n.resumeRequired,
            value: _resumeRequired,
            items: {
              'required': l10n.resumeRequiredOption,
              'optional': l10n.resumeOptionalOption,
              'not_required': l10n.resumeNotRequired
            },
            onChanged: (v) => setState(() => _resumeRequired = v!),
          ),
          const SizedBox(height: 24),
          UJobButton(
            label: l10n.postJobButton,
            onTap: _submit,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: AppRadius.sm),
            child: Row(children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, color: AppColors.warning, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.jobApprovalNotice, style: AppText.small.copyWith(color: AppColors.warning))),
            ]),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: AppText.label.copyWith(color: AppColors.muted)),
    const SizedBox(height: 6),
    DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
    ),
  ]);
}
