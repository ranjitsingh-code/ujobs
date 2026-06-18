import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/providers/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_page_wrapper.dart';

class EmployerShell extends ConsumerWidget {
  final Widget child;
  const EmployerShell({required this.child, super.key});

  int _indexFromPath(String path) {
    if (path.startsWith('/employer/jobs'))      return 1;
    if (path.startsWith('/employer/applicants')) return 2;
    if (path.startsWith('/employer/messages'))  return 3;
    if (path.startsWith('/employer/profile'))   return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location     = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexFromPath(location);

    return Scaffold(
      body: AnimatedPageWrapper(
        key: ValueKey(location),
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/employer');             break;
            case 1: context.go('/employer/jobs');        break;
            case 2: context.go('/employer/applicants');  break;
            case 3: context.go('/employer/messages');    break;
            case 4: context.go('/employer/profile');     break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedHome01,     color: AppColors.muted2,  size: 24), activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedHome01,     color: AppColors.primary, size: 24), label: 'Home'),
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedBriefcase01, color: AppColors.muted2,  size: 24), activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedBriefcase01, color: AppColors.primary, size: 24), label: 'Jobs'),
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedUserGroup,   color: AppColors.muted2,  size: 24), activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedUserGroup,   color: AppColors.primary, size: 24), label: 'Applicants'),
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedBubbleChat,  color: AppColors.muted2,  size: 24), activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedBubbleChat,  color: AppColors.primary, size: 24), label: 'Messages'),
          BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedBuilding04,  color: AppColors.muted2,  size: 24), activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedBuilding04,  color: AppColors.primary, size: 24), label: 'Profile'),
        ],
      ),
    );
  }
}

// Role switcher widget — placed in employer profile screen app bar
class RoleSwitcherButton extends ConsumerWidget {
  const RoleSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton.icon(
    onPressed: () {
      ref.read(activeRoleProvider.notifier).switchRole();
      context.go('/seeker');
    },
    icon: HugeIcon(icon: HugeIcons.strokeRoundedExchange01, color: AppColors.seekPrimary, size: 18),
    label: const Text('Switch to Seeker', style: TextStyle(color: AppColors.seekPrimary, fontSize: 12)),
  );
}
