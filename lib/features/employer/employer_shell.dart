import 'package:flutter/material.dart';
import '../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/providers/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../shared/notifications/notifications_provider.dart';

class EmployerShell extends ConsumerStatefulWidget {
  final Widget child;
  const EmployerShell({required this.child, super.key});

  @override
  ConsumerState<EmployerShell> createState() => _EmployerShellState();
}

class _EmployerShellState extends ConsumerState<EmployerShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // unreadNotificationCountProvider no longer polls — this shell is mounted
  // for the whole logged-in session, so resuming from background is the
  // right place to catch up the bell badge without a background timer.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(unreadNotificationCountProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final tabs = [
      ('/employer', HugeIcons.strokeRoundedHome01, context.l10n.dashboard),
      ('/employer/jobs', HugeIcons.strokeRoundedBriefcase01, context.l10n.jobsTab),
      ('/employer/applicants', HugeIcons.strokeRoundedUserGroup, context.l10n.applicants),
      // if (featureFlags.chat)
      //   ('/employer/messages', HugeIcons.strokeRoundedBubbleChat, context.l10n.messages),
      ('/employer/profile', HugeIcons.strokeRoundedUser, context.l10n.accountSection),
    ];

    // Calculate current index based on matching the longest path prefix
    int currentIndex = tabs.indexWhere((t) => location.startsWith(t.$1) && t.$1 != '/employer');
    if (currentIndex == -1) currentIndex = 0; // fallback to dashboard if no exact match

    return Scaffold(
      body: AnimatedPageWrapper(child: widget.child),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: currentIndex,
        onTap: (i) => context.go(tabs[i].$1),
        items: tabs.map((t) {
          return BottomNavigationBarItem(
            icon: HugeIcon(icon: t.$2, color: AppColors.muted2, size: 22),
            activeIcon: HugeIcon(icon: t.$2, color: AppColors.primary, size: 22),
            label: t.$3,
          );
        }).toList(),
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
    icon: HugeIcon(
      icon: HugeIcons.strokeRoundedExchange01,
      color: AppColors.seekPrimary,
      size: 18,
    ),
    label: const Text(
      'Switch to Seeker',
      style: TextStyle(color: AppColors.seekPrimary, fontSize: 12),
    ),
  );
}
