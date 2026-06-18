import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_avatar.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../seeker_shell.dart';

// GET /seeker/me → PUT /seeker/me
// Endpoints: Ep.seekerMe
class SeekerProfileScreen extends ConsumerWidget {
  const SeekerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          GestureDetector(
            onTap: () => context.push('/seeker/settings'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Settings', style: AppText.label.copyWith(color: AppColors.surface)),
            ),
          ),
          const SeekerRoleSwitcherButton(),
        ],
      ),
      body: auth.when(
        loading: () => const UJobLoading(),
        error: (e, _) => UJobError(message: 'Error loading profile', onRetry: () => ref.refresh(authProvider)),
        data: (user) => _ProfileBody(user: user),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final User? user;
  const _ProfileBody({this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SingleChildScrollView(
        child: Column(children: [
          // Header — gradient with avatar, name, title, location
          _ProfileHeader(user: user),
          const SizedBox(height: 16),
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _StatBox(value: '—', label: 'Profile Views'),
              const SizedBox(width: 12),
              _StatBox(value: '—', label: 'Saved Jobs'),
              const SizedBox(width: 12),
              _StatBox(value: '—', label: 'Applications'),
            ]),
          ),
          const SizedBox(height: 20),
          // Profile sections
          _ProfileSection(
            title: 'Personal Info',
            subtitle: user?.fullName ?? '—',
            onEdit: () => _showEditPersonalInfo(context, ref, user),
          ),
          _ProfileSection(
            title: 'Professional Summary',
            subtitle: 'About / Bio',
            onEdit: () => _showEditBio(context, ref),
          ),
          _ProfileSection(
            title: 'Skills',
            subtitle: '0 skills added',
            onEdit: () {},
          ),
          _ProfileSection(
            title: 'Work Experience',
            subtitle: '0 positions',
            onEdit: () {},
          ),
          _ProfileSection(
            title: 'Education',
            subtitle: '0 qualifications',
            onEdit: () {},
          ),
          _ProfileSection(
            title: 'Certifications',
            subtitle: 'Add certifications',
            onEdit: () {},
          ),
          const SizedBox(height: 32),
        ]),
      );

  void _showEditPersonalInfo(BuildContext context, WidgetRef ref, User? user) {
    final firstCtrl = TextEditingController(text: user?.firstName);
    final lastCtrl  = TextEditingController(text: user?.lastName);
    final phoneCtrl = TextEditingController(text: user?.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Edit Personal Info', style: AppText.heading3),
          const SizedBox(height: 20),
          UJobTextField(label: 'First Name', controller: firstCtrl),
          UJobTextField(label: 'Last Name', controller: lastCtrl),
          UJobTextField(label: 'Phone', controller: phoneCtrl, keyboardType: TextInputType.phone),
          UJobButton(
            label: 'Save Changes',
            onTap: () async {
              try {
                await ref.read(dioClientProvider).dio.put(Ep.seekerMe, data: {
                  'first_name': firstCtrl.text,
                  'last_name': lastCtrl.text,
                  'phone': phoneCtrl.text,
                });
                ref.invalidate(authProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (_) {}
            },
          ),
        ]),
      ),
    );
  }

  void _showEditBio(BuildContext context, WidgetRef ref) {
    final bioCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Professional Summary', style: AppText.heading3),
          const SizedBox(height: 20),
          UJobTextField(
            label: 'About / Bio',
            hint: 'Describe your experience, skills, and what you\'re looking for...',
            controller: bioCtrl,
            maxLines: 5,
          ),
          UJobButton(
            label: 'Save',
            onTap: () async {
              try {
                await ref.read(dioClientProvider).dio.put(Ep.seekerMe, data: {'bio': bioCtrl.text});
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (_) {}
            },
          ),
        ]),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User? user;
  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(children: [
          Stack(alignment: Alignment.bottomRight, children: [
            UJobAvatar(initials: user?.initials ?? '?', size: 72),
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: const HugeIcon(icon: HugeIcons.strokeRoundedCamera01, size: 14, color: AppColors.primary),
          ),
          ]),
          const SizedBox(height: 12),
          Text(user?.fullName ?? '—', style: AppText.heading3.copyWith(color: AppColors.white)),
          const SizedBox(height: 4),
          Text(user?.email ?? '', style: AppText.small.copyWith(color: AppColors.white.withValues(alpha: 0.8))),
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
                'Add skills & experience to improve matches',
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
            Text(value, style: AppText.heading3.copyWith(color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label, style: AppText.caption.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onEdit;

  const _ProfileSection({required this.title, required this.subtitle, required this.onEdit});

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
                  Text(subtitle, style: AppText.small.copyWith(color: AppColors.muted)),
                ]),
              ),
              Text(context.l10n.edit, style: AppText.label.copyWith(color: AppColors.primary)),
              const SizedBox(width: 8),
              const HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, color: AppColors.primary, size: 18),
            ]),
          ),
        ),
      );
}
