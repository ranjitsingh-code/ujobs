import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/role_picker_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_employer_screen.dart';
import '../../features/auth/register_seeker_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/employer/employer_shell.dart';
import '../../features/employer/dashboard/employer_dashboard_screen.dart';
import '../../features/employer/jobs/my_jobs_screen.dart';
import '../../features/employer/jobs/post_job_screen.dart';
import '../../features/employer/jobs/employer_job_detail_screen.dart';
import '../../features/employer/applicants/applicants_screen.dart';
import '../../features/employer/company/company_profile_screen.dart';
import '../../features/employer/messages/employer_messages_screen.dart';
import '../../features/employer/notifications/employer_notifications_screen.dart';
import '../../features/employer/settings/employer_settings_screen.dart';
import '../../features/seeker/seeker_shell.dart';
import '../../features/seeker/dashboard/seeker_dashboard_screen.dart';
import '../../features/seeker/jobs/browse_jobs_screen.dart';
import '../../features/seeker/jobs/seeker_job_detail_screen.dart';
import '../../features/seeker/applications/my_applications_screen.dart';
import '../../features/seeker/messages/seeker_messages_screen.dart';
import '../../features/seeker/profile/seeker_profile_screen.dart';
import '../../features/seeker/notifications/seeker_notifications_screen.dart';
import '../../features/seeker/settings/seeker_settings_screen.dart';
import '../../features/seeker/apply/apply_screen.dart';
import '../../features/shared/chat/chat_screen.dart';

final _routerNotifier = _AppRouterNotifier();

class _AppRouterNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// Tracks whether first-time onboarding was seen
final onboardingSeenProvider = FutureProvider<bool>((ref) =>
    ref.read(secureStorageProvider).getOnboardingSeen());

// Minimum splash display duration — increase for testing, set to 0 to disable
final splashMinDurationProvider = FutureProvider<bool>((ref) async {
  await Future.delayed(const Duration(milliseconds: 4600));
  return true;
});

final routerProvider = Provider<GoRouter>((ref) {
  ref.listen<AsyncValue<dynamic>>(authProvider, (_, _) => _routerNotifier.notify());
  ref.listen<String>(activeRoleProvider, (_, _) => _routerNotifier.notify());
  ref.listen<AsyncValue<bool>>(onboardingSeenProvider, (_, _) => _routerNotifier.notify());
  ref.listen<AsyncValue<bool>>(splashMinDurationProvider, (_, _) => _routerNotifier.notify());

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _routerNotifier,
    redirect: (context, state) {
      final auth         = ref.read(authProvider);
      final onboardingSeen = ref.read(onboardingSeenProvider);
      final role         = ref.read(activeRoleProvider);
      final loc          = state.matchedLocation;

      final splashDone = ref.read(splashMinDurationProvider);

      // Wait for auth, onboarding, and minimum splash duration
      if (auth.isLoading || onboardingSeen.isLoading || splashDone.isLoading) return null;

      final isLoggedIn   = auth.valueOrNull != null;
      final hasSeenIntro = onboardingSeen.valueOrNull ?? false;

      final isPublicRoute =
          loc == '/login'         ||
          loc == '/role-picker'   ||
          loc == '/onboarding'    ||
          loc == '/otp'           ||
          loc == '/forgot-password' ||
          loc.startsWith('/register');

      if (!isLoggedIn && !isPublicRoute) {
        return hasSeenIntro ? '/role-picker' : '/onboarding';
      }

      if (isLoggedIn && (loc == '/' || loc == '/role-picker' || loc == '/onboarding')) {
        return role == 'employer' ? '/employer' : '/seeker';
      }

      if (isLoggedIn && loc.startsWith('/employer') && role != 'employer') return '/seeker';
      if (isLoggedIn && loc.startsWith('/seeker') && role != 'job_seeker') return '/employer';

      return null;
    },
    routes: [
      GoRoute(path: '/',                   builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding',           builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/role-picker',
        builder: (context, _) => RolePickerScreen(
          onJobSeeker: () => context.push('/login', extra: 'seeker'),
          onEmployer:  () => context.push('/login', extra: 'employer'),
          onSignIn:    () => context.push('/login', extra: 'seeker'),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginScreen(
          initialRole: state.extra as String? ?? 'seeker',
        ),
      ),
      GoRoute(path: '/register/employer',   builder: (_, _) => const RegisterEmployerScreen()),
      GoRoute(path: '/register/seeker',     builder: (_, _) => const RegisterSeekerScreen()),
      GoRoute(path: '/otp',                 builder: (_, _) => const OtpScreen()),
      GoRoute(path: '/forgot-password',     builder: (_, _) => const ForgotPasswordScreen()),

      // Shared chat — outside shells so both roles can access
      GoRoute(
        path: '/conversations/:id',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ChatScreen(
            conversationId: state.pathParameters['id']!,
            otherName: extra['name'] as String? ?? 'Chat',
            otherInitials: extra['initials'] as String?,
            otherAvatar: extra['avatar'] as String?,
          );
        },
      ),

      // ── Employer shell ─────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, _, child) => EmployerShell(child: child),
        routes: [
          GoRoute(path: '/employer',              builder: (_, _) => const EmployerDashboardScreen()),
          GoRoute(path: '/employer/jobs',         builder: (_, _) => const MyJobsScreen()),
          GoRoute(
            path: '/employer/jobs/:id',
            builder: (_, state) => EmployerJobDetailScreen(
              jobId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(path: '/employer/post-job',     builder: (_, _) => const PostJobScreen()),
          GoRoute(path: '/employer/applicants',   builder: (_, _) => const ApplicantsScreen()),
          GoRoute(path: '/employer/messages',     builder: (_, _) => const EmployerMessagesScreen()),
          GoRoute(path: '/employer/profile',      builder: (_, _) => const CompanyProfileScreen()),
          GoRoute(path: '/employer/notifications', builder: (_, _) => const EmployerNotificationsScreen()),
          GoRoute(path: '/employer/settings',     builder: (_, _) => const EmployerSettingsScreen()),
        ],
      ),

      // ── Seeker shell ───────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, _, child) => SeekerShell(child: child),
        routes: [
          GoRoute(path: '/seeker',                builder: (_, _) => const SeekerDashboardScreen()),
          GoRoute(path: '/seeker/jobs',           builder: (_, _) => const BrowseJobsScreen()),
          GoRoute(
            path: '/seeker/jobs/:id',
            builder: (_, state) => SeekerJobDetailScreen(
              jobId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/seeker/jobs/:id/apply',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return ApplyScreen(
                jobId: int.parse(state.pathParameters['id']!),
                jobTitle: extra['title'] as String? ?? 'Job',
                companyName: extra['company'] as String?,
                location: extra['location'] as String?,
              );
            },
          ),
          GoRoute(path: '/seeker/applied',        builder: (_, _) => const MyApplicationsScreen()),
          GoRoute(path: '/seeker/messages',       builder: (_, _) => const SeekerMessagesScreen()),
          GoRoute(path: '/seeker/profile',        builder: (_, _) => const SeekerProfileScreen()),
          GoRoute(path: '/seeker/notifications',  builder: (_, _) => const SeekerNotificationsScreen()),
          GoRoute(path: '/seeker/settings',       builder: (_, _) => const SeekerSettingsScreen()),
        ],
      ),
    ],
  );
});
