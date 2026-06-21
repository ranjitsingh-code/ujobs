import 'package:flutter/material.dart';
import '../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/providers/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_page_wrapper.dart';

class SeekerShell extends ConsumerWidget {
  final Widget child;
  const SeekerShell({required this.child, super.key});

  int _indexFromPath(String path) {
    if (path.startsWith('/seeker/jobs'))         return 1;
    if (path.startsWith('/seeker/applied'))       return 2;
    if (path.startsWith('/seeker/messages'))      return 3;
    if (path.startsWith('/seeker/profile'))       return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location     = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexFromPath(location);

    return Scaffold(
      body: AnimatedPageWrapper(
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/seeker');           break;
            case 1: context.go('/seeker/jobs');      break;
            case 2: context.go('/seeker/applied');   break;
            case 3: context.go('/seeker/messages');  break;
            case 4: context.go('/seeker/profile');   break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedHome01, color: AppColors.muted2, size: 24),         activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedHome01, color: AppColors.primary, size: 24),              label: context.l10n.home),
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.muted2, size: 24),        activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.primary, size: 24),            label: context.l10n.jobsTab),
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedTask01, color: AppColors.muted2, size: 24),    activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedTask01, color: AppColors.primary, size: 24),        label: context.l10n.statusApplied),
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedBubbleChat, color: AppColors.muted2, size: 24),    activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedBubbleChat, color: AppColors.primary, size: 24),       label: context.l10n.messages),
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedUser03, color: AppColors.muted2, size: 24),         activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedUser03, color: AppColors.primary, size: 24),            label: context.l10n.profile),
        ],
      ),
    );
  }
}

// Role switcher widget — placed in seeker profile screen app bar
class SeekerRoleSwitcherButton extends ConsumerWidget {
  const SeekerRoleSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton.icon(
    onPressed: () {
      ref.read(activeRoleProvider.notifier).switchRole();
      context.go('/employer');
    },
    icon: HugeIcon(icon: HugeIcons.strokeRoundedExchange01, color: AppColors.empPrimary, size: 18),
    label: const Text('Switch to Employer', style: TextStyle(color: AppColors.empPrimary, fontSize: 12)),
  );
}
