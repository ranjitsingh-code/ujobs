class Ep {
  static const String baseUrl = 'https://ujobapi.gidentex.com/api/v1/mobile';
  static const String sharedBaseUrl = 'https://ujobapi.gidentex.com/api/v1';
  static const String webUrl = 'https://ujobs.com';

  // Auth
  static const login = '/auth/login';
  static const registerEmployer = '/auth/register/employer';
  static const registerSeeker = '/auth/register/seeker';
  static const verifyOtp =
      '/auth/verify-otp'; // ⚠️ returns 500 — handle gracefully
  static const resendOtp = '/auth/resend-otp';
  static const forgotPasswordRequest = '/auth/forgot-password/request';
  static const forgotPasswordReset = '/auth/forgot-password/reset';
  static const me = '/auth/me';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';

  // Employer
  static const employerMe = '/employer/me';
  static const empMe = '/employer/me';
  static const empDashboard = '/employer/dashboard';
  static const employerJobs = '/employer/jobs';
  static String employerJob(String id) => '/employer/jobs/$id';
  static String applicants(String jobId) =>
      '/employer/jobs/$jobId/applicants'; // ⚠️ no global /employer/applications (404)
  static String application(String id) => '/employer/applications/$id';
  static String empCompany(String id) =>
      '/employer/company/$id'; // PUT only — GET from /employer/me
  static const empSettings = '/employer/settings';
  static const empPreferences = '/employer/settings/preferences';
  static const empEmailRequestOtp = '/employer/settings/email/request-otp';
  static const empEmailVerifyOtp = '/employer/settings/email/verify-otp';
  static const empPhone = '/employer/settings/phone';
  static const empPassword = '/employer/settings/password';
  static const emp2FA = '/employer/settings/2fa';
  static const empAuditLog = '/employer/settings/audit-log';
  static const empNotifications = '/employer/notifications';
  static const empUnreadCount = '/employer/notifications/unread-count';
  static String empNotifRead(String id) => '/employer/notifications/$id/read';
  static const empPlans = '/employer/plans';
  static const empSubscriptions = '/employer/subscriptions';
  static const empStripeCheckout = '/employer/stripe/checkout';
  static const empWallet = '/employer/wallet';
  static const empWalletTxs = '/employer/wallet/transactions';
  static const empPayments = '/employer/payments';
  static const empSavedCandidates =
      '/employer/saved-candidates'; // ⚠️ returns 500
  static const employerFeatureFlags = '/employer/features';
  static const publicJobFormOptions = '/public/job-form-options';

  // Seeker
  static const seekerMe = '/seeker/me'; // GET + PUT
  static const seekerDashboard = '/seeker/dashboard';
  static const seekerJobs = '/seeker/jobs';
  static const seekerResumes =
      '/seeker/resumes'; // multipart/form-data — NOT JSON
  static const seekerApplications = '/seeker/applications';
  static const seekerSavedJobs = '/seeker/saved-jobs';
  static const seekerMatching = '/seeker/matching-jobs';
  static const seekerNotifications = '/seeker/notifications';
  static const seekUnreadCount = '/seeker/notifications/unread-count';
  static const empMarkAllRead = '/employer/notifications/read-all';
  static const seekMarkAllRead = '/seeker/notifications/read-all';
  static String seekNotifRead(String id) => '/seeker/notifications/$id/read';
  static String saveJob(String id) => '/seeker/jobs/$id/save';
  static String applyJob(String id) => '/seeker/jobs/$id/apply';
  static String appStatus(String id) => '/seeker/jobs/$id/application-status';
  static String screeningQs(String id) =>
      '/public/jobs/$id/screening-questions';
  static const seekSettings = '/seeker/settings';
  static const seekPreferences = '/seeker/settings/preferences';
  static const seekPassword = '/seeker/settings/password';
  static const seekEmailRequestOtp = '/seeker/settings/email/request-otp';
  static const seekEmailVerifyOtp = '/seeker/settings/email/verify-otp';
  static const seek2FA = '/seeker/settings/2fa';
  static const seekAuditLog = '/seeker/settings/audit-log';
  static const seekAccount = '/seeker/settings/account';
  static const seekSignOutAll = '/seeker/settings/sign-out-all';

  // Public
  static const publicJobs = '/public/jobs';
  static String publicJob(String id) => '/public/jobs/$id';
  static const publicCompanies = '/public/companies';
  static const publicCompaniesHouseSearch =
      '/public/companies-house/search';
  static String publicCompaniesHouseCompany(String number) =>
      '/public/companies-house/company/$number';
  static String publicCompany(String id) => '/public/companies/$id';
  static const publicCategories = '/public/categories';
  static const publicSkills = '/public/skills';
  static const publicCountries = '/public/countries';
  static const publicStats = '/public/stats';
  static const publicHomepage = '/public/homepage';
  static const publicTestimonials = '/public/testimonials';
  static const publicPages = '/public/pages';
  static String publicPage(String slug) => '/public/pages/$slug';

  // Conversations
  static const conversations = '/conversations';
  static String messages(String id) => '/conversations/$id/messages';
}
