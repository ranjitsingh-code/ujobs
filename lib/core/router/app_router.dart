import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/job.dart';
import '../models/company.dart';
import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';
import '../providers/onboarding_provider.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/role_picker_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/account_suspended_screen.dart';
import '../../features/auth/account_locked_screen.dart';
import '../../features/auth/register_employer_screen.dart';
import '../../features/auth/register_seeker_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/two_factor_auth_screen.dart';
import '../../features/shared/settings/change_email_otp_verify_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/employer/employer_shell.dart';
import '../../features/employer/dashboard/employer_dashboard_screen.dart';
import '../../features/employer/jobs/my_jobs_screen.dart';
import '../../features/employer/jobs/post_job_screen.dart';
import '../../features/employer/jobs/employer_job_detail_screen.dart';
import '../../features/employer/applicants/applicants_screen.dart';
import '../../features/employer/applicants/applicant_detail_screen.dart';
import '../../features/employer/applicants/job_applicants_screen.dart';
import '../../features/employer/company/company_profile_screen.dart';
import '../../features/employer/messages/employer_messages_screen.dart';
import '../../features/shared/notifications/notifications_screen.dart';
import '../../features/seeker/seeker_shell.dart';
import '../../features/seeker/dashboard/seeker_dashboard_screen.dart';
import '../../features/seeker/jobs/find_jobs_screen.dart';
import '../../features/seeker/jobs/saved_jobs_screen.dart';
import '../../features/seeker/jobs/seeker_job_detail_screen.dart';
import '../../features/seeker/company/seeker_company_profile_screen.dart';
import '../../features/seeker/company/seeker_companies_screen.dart';
import '../../features/seeker/applications/my_applications_screen.dart';
import '../../features/seeker/messages/seeker_messages_screen.dart';
import '../../features/seeker/profile/seeker_profile_screen.dart';
import '../../features/shared/settings/settings_screen.dart';
import '../../features/shared/settings/audit_log_screen.dart';
import '../../features/shared/webview/webview_screen.dart';
import '../../features/seeker/apply/apply_screen.dart';
import '../../features/shared/chat/chat_screen.dart';
import '../../features/shared/legal/legal_page_screen.dart';
import '../../features/shared/legal/cms_page_screen.dart';
import '../../features/employer/wallet/wallet_screen.dart';

final _routerNotifier = _AppRouterNotifier();

class _AppRouterNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// Minimum splash display duration — increase for testing, set to 0 to disable
final splashMinDurationProvider = FutureProvider<bool>((ref) async {
  await Future.delayed(const Duration(milliseconds: 4600));
  return true;
});

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  ref.listen<AsyncValue<dynamic>>(
    authProvider,
    (_, _) => _routerNotifier.notify(),
  );
  ref.listen<String>(activeRoleProvider, (_, _) => _routerNotifier.notify());
  ref.listen<AsyncValue<bool>>(
    onboardingSeenProvider,
    (_, _) => _routerNotifier.notify(),
  );
  ref.listen<AsyncValue<bool>>(
    splashMinDurationProvider,
    (_, _) => _routerNotifier.notify(),
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _routerNotifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final onboardingSeen = ref.read(onboardingSeenProvider);
      final role = ref.read(activeRoleProvider);
      final loc = state.matchedLocation;

      final splashDone = ref.read(splashMinDurationProvider);

      // Wait for auth, onboarding, and minimum splash duration
      if (auth.isLoading || onboardingSeen.isLoading || splashDone.isLoading) {
        return null;
      }

      final isLoggedIn = auth.valueOrNull != null;
      final hasSeenIntro = onboardingSeen.valueOrNull ?? false;

      final isPublicRoute =
          loc == '/login' ||
          loc == '/role-picker' ||
          loc == '/onboarding' ||
          loc == '/otp' ||
          loc == '/forgot-password' ||
          loc == '/terms-and-conditions' ||
          loc == '/privacy-policy' ||
          loc == '/locked' ||
          loc == '/suspended' ||
          loc == '/2fa' ||
          loc.startsWith('/register');

      if (!isLoggedIn && !isPublicRoute) {
        return hasSeenIntro ? '/role-picker' : '/onboarding';
      }

      final userStatus = auth.valueOrNull?.status;
      if (isLoggedIn &&
          (userStatus == 'suspended' || userStatus == 'banned') &&
          loc != '/suspended') {
        return '/suspended';
      }

      if (isLoggedIn &&
          (loc == '/' || loc == '/role-picker' || loc == '/onboarding')) {
        return role == 'employer' ? '/employer' : '/seeker';
      }

      if (isLoggedIn && loc.startsWith('/employer') && role != 'employer') {
        return '/seeker';
      }
      if (isLoggedIn &&
          loc.startsWith('/seeker') &&
          role != 'job_seeker' &&
          role != 'seeker') {
        return '/employer';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, _) => _fadeTransition(const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, _) => _fadeTransition(const OnboardingScreen()),
      ),
      GoRoute(
        path: '/role-picker',
        builder: (context, _) => RolePickerScreen(
          onJobSeeker: () => context.push('/login', extra: 'seeker'),
          onEmployer: () => context.push('/login', extra: 'employer'),
          onSignIn: () => context.push('/login', extra: 'seeker'),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) => _fadeTransition(
          LoginScreen(initialRole: state.extra as String? ?? 'seeker'),
        ),
      ),
      GoRoute(
        path: '/suspended',
        pageBuilder: (_, _) => _fadeTransition(const AccountSuspendedScreen()),
      ),
      GoRoute(
        path: '/locked',
        pageBuilder: (_, state) => _fadeTransition(AccountLockedScreen(message: state.extra as String?)),
      ),
      GoRoute(
        path: '/2fa',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TwoFactorAuthScreen(
            userId: extra['userId'] as String? ?? '',
            email: extra['email'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/register/employer',
        builder: (_, _) => const RegisterEmployerScreen(),
      ),
      GoRoute(
        path: '/register/seeker',
        builder: (_, _) => const RegisterSeekerScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return OtpScreen(
              email: extra['email'] as String?,
              userId: extra['userId'] as String?,
            );
          }
          return OtpScreen(userId: extra as String?);
        },
      ),
      GoRoute(
        path: '/change-email-otp',
        builder: (_, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return ChangeEmailOtpVerifyScreen(email: extra['email'] as String?);
          }
          return const ChangeEmailOtpVerifyScreen();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/terms-and-conditions',
        builder: (_, _) => const LegalPageScreen(type: LegalPageType.terms),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (_, _) => const LegalPageScreen(type: LegalPageType.privacy),
      ),
      GoRoute(
        path: '/about-us',
        builder: (_, _) => const LegalPageScreen(type: LegalPageType.about),
      ),
      GoRoute(
        path: '/contact-us',
        builder: (_, _) => const LegalPageScreen(type: LegalPageType.contact),
      ),

      GoRoute(
        path: '/pages/:slug',
        builder: (_, state) => CmsPageScreen(slug: state.pathParameters['slug']!),
      ),

      // Shared chat — outside shells so both roles can access
      GoRoute(
        path: '/conversations/:id',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ChatScreen(
            conversationId: state.pathParameters['id']!,
            otherId: extra['otherId'] as String? ?? '1',
            otherName: extra['name'] as String? ?? 'Chat',
            otherInitials: extra['initials'] as String?,
            otherAvatar: extra['avatar'] as String?,
            jobTitle: extra['jobTitle'] as String?,
            applicantId: extra['applicantId'] as String?,
            jobId: extra['jobId'] as String?,
          );
        },
      ),

      // ── Employer shell ─────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, _, child) => EmployerShell(child: child),
        routes: [
          GoRoute(
            path: '/employer',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: EmployerDashboardScreen()),
          ),
          GoRoute(
            path: '/employer/jobs',
            pageBuilder: (_, state) => NoTransitionPage(
              child: MyJobsScreen(initialIndex: (state.extra as int?) ?? 0),
            ),
          ),
          GoRoute(
            path: '/employer/jobs/:id',
            builder: (_, state) => EmployerJobDetailScreen(
              jobId: int.parse(state.pathParameters['id']!),
              jobData: state.extra as Job?,
            ),
          ),
          GoRoute(
            path: '/employer/jobs/:id/edit',
            builder: (_, state) => PostJobScreen(job: state.extra as Job?),
          ),
          GoRoute(
            path: '/employer/jobs/:id/applicants',
            builder: (_, state) {
              final job = state.extra as Job;
              return JobApplicantsScreen(job: job);
            },
          ),
          GoRoute(
            path: '/employer/post-job',
            builder: (_, _) => const PostJobScreen(),
          ),
          GoRoute(
            path: '/employer/applicants',
            pageBuilder: (_, state) => NoTransitionPage(
              child: ApplicantsScreen(initialIndex: (state.extra as int?) ?? 0),
            ),
          ),
          GoRoute(
            path: '/employer/applicants/:app_id',
            builder: (_, state) => ApplicantDetailScreen(
              applicantId: state.pathParameters['app_id'],
            ),
          ),
          GoRoute(
            path: '/employer/messages',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: EmployerMessagesScreen()),
          ),
          GoRoute(
            path: '/employer/profile',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: CompanyProfileScreen()),
          ),
          GoRoute(
            path: '/employer/notifications',
            builder: (_, _) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/employer/settings',
            builder: (_, _) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/employer/wallet',
            builder: (_, _) => const WalletScreen(),
          ),
          GoRoute(
            path: '/employer/settings/audit-log',
            builder: (_, _) => const AuditLogScreen(),
          ),
          GoRoute(
            path: '/employer/settings/change-email/verify-otp',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ChangeEmailOtpVerifyScreen(email: extra?['email'] as String?);
            },
          ),
        ],
      ),

      // ── Seeker shell ───────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, _, child) => SeekerShell(child: child),
        routes: [
          GoRoute(
            path: '/seeker',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SeekerDashboardScreen()),
          ),
          GoRoute(
            path: '/seeker/jobs',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: FindJobsScreen()),
          ),
          GoRoute(
            path: '/seeker/jobs/:id',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return SeekerJobDetailScreen(
                jobId: int.parse(state.pathParameters['id']!),
                source: extra['source'] as String?,
              );
            },
          ),
          GoRoute(
            path: '/seeker/company',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return SeekerCompanyProfileScreen(
                company: extra['company'] as Company,
              );
            },
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
                source: extra['source'] as String?,
              );
            },
          ),
          GoRoute(
            path: '/seeker/applied',
            pageBuilder: (_, state) {
              final index = state.extra is int ? state.extra as int : 0;
              return NoTransitionPage(
                child: MyApplicationsScreen(initialIndex: index),
              );
            },
          ),
          GoRoute(
            path: '/seeker/saved-jobs',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SavedJobsScreen()),
          ),
          GoRoute(
            path: '/seeker/companies',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SeekerCompaniesScreen()),
          ),
          GoRoute(
            path: '/seeker/messages',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SeekerMessagesScreen()),
          ),
          GoRoute(
            path: '/seeker/profile',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SeekerProfileScreen()),
          ),
          GoRoute(
            path: '/seeker/settings',
            builder: (_, _) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/seeker/settings/audit-log',
            builder: (_, _) => const AuditLogScreen(),
          ),
          GoRoute(
            path: '/seeker/settings/change-email/verify-otp',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ChangeEmailOtpVerifyScreen(email: extra?['email'] as String?);
            },
          ),
          GoRoute(
            path: '/seeker/notifications',
            builder: (_, _) => const NotificationsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return WebViewScreen(
            title: extra['title'] as String? ?? '',
            url: extra['url'] as String? ?? '',
          );
        },
      ),
    ],
  );
});

CustomTransitionPage _fadeTransition(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
