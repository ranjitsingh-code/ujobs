# UJob App - Project Status & Master Plan

## 1. Project Overview
UJob is a dual-portal mobile application (Flutter) for **Employers** and **Job Seekers**. It features a modern, high-animation UI designed for seamless job posting, browsing, and recruitment management.

### Key Platforms & Resources
- **Design:** `UJobs-Screens/` (Static PNGs), `ujobs-xd/` (Adobe XD tokens/assets)
- **Plan:** `project_plan/flutter-plan.html` (12-day build plan)
- **Animation Reference:** [Replit Animation Demo](https://093c5e90-2488-4623-886f-d7230fa1b409-00-236oalpdd5ahd.sisko.replit.dev/)

---

## 2. Technical Stack
- **Framework:** Flutter (SDK ^3.11.5)
- **State Management:** Riverpod (2.5.1)
- **Navigation:** GoRouter (13.2.0)
- **Networking:** Dio (5.4.3)
- **UI/UX:** ScreenUtil (Responsive), Google Fonts, Shimmer (Loading states)
- **Backend:** Firebase (Core, Messaging, Notifications) - *Setup Pending*

---

## 3. Implementation Status (Last Updated: 2026-06-18, Session 6)

#### Session 6 Changes (2026-06-18) — Polish, Constants, Icon System & Reusable Widgets

##### Dependencies Added (pubspec.yaml):
- `hugeicons: ^1.1.7` — 4,700+ stroke-rounded SVG icons (replaces Material icons on key screens)
- `flutter_svg: ^2.0.9` — SVG rendering (direct dep, used by `UJobImage` + `UJobLogo`)
- **Note:** `flutter_secure_storage` produces SPM warning — to silence, add `disable-swift-package-manager: true` under `flutter:` in pubspec.yaml (not yet applied, non-breaking)

##### New Constants File:
- `lib/core/constants/app_assets.dart` — `AppAssets` class with ALL asset paths as static constants:
  - `AppAssets.logo`, `AppAssets.logoMark`, `AppAssets.logoPrimary`, `AppAssets.logoWhite`
  - `AppAssets.iconBriefcase`, `AppAssets.iconSearch`, `AppAssets.iconUser`, etc. (28 SVG icons)
  - **RULE:** Never use raw `'assets/...'` strings in screens — always `AppAssets.*`

##### New Reusable Widgets (lib/core/widgets/):
- `ujob_toast.dart` — `UJobToast` overlay toast (animated slide-in, 4 types: success/error/warning/info, auto-dismiss, swipe-to-dismiss)
  - Usage: `UJobToast.success(context, 'Profile saved!')` or `UJobToast.error(context, 'Failed', sub: 'Try again')`
- `ujob_snack_bar.dart` — `UJobSnackBar` scaffold-based notification (same 4 types, floating, styled)
  - Usage: `UJobSnackBar.error(context, 'Upload failed', message: 'Check connection')`
- `ujob_app_bar.dart` — `UJobAppBar` reusable PreferredSizeWidget (back button, centered title, optional rightWidget)
  - Usage: `appBar: UJobAppBar(title: 'Edit Profile', onBack: () => context.pop())`
- `ujob_image.dart` — `UJobImage` smart image widget (auto-detects SVG/PNG/network, uses `cached_network_image` for network, spinner placeholder, broken-image fallback)
  - Usage: `UJobImage(path: AppAssets.iconBriefcase, width: 24.r, color: AppColors.primary)`
  - Usage: `UJobImage(path: 'https://...avatar.jpg', width: 48.r, fit: BoxFit.cover)`
- `ujob_logo.dart` — `UJobLogo` with 3 variants: `LogoVariant.color`, `.white`, `.mark`
  - Usage: `UJobLogo(variant: LogoVariant.white, height: 36.h)` (replaces all `Image.asset(AppAssets.logo)`)
- `ujob_result_screen.dart` — `UJobResultScreen` full-screen success/error/warning page (icon circle, title, subtitle, primary + optional secondary button)
  - Usage: `UJobResultScreen(type: ResultType.success, title: 'Applied!', subtitle: '...', buttonLabel: 'Done', onTap: () => context.go('/seeker/jobs'))`

##### Splash & Onboarding Audit Fixes (completing previous session):
- `splash_screen.dart`: float bob `* 6.0` → `* 6.h` (ScreenUtil)
- `onboarding_screen.dart`: float bob `* 8` → `* 8.h`, avatar stack `8.0` → `8.w`
- Slide gradient colors: all raw hex → `AppColors.onboardBlueStart/End`, `onboardPurpleEnd`, `onboardGreenEnd`
- New `AppColors` constants added: `primarySky`, `primaryCloud`, `onboardBlueStart`, `onboardBlueEnd`, `onboardPurpleEnd`, `onboardGreenEnd`

##### Role Picker Screen Refinements:
- Card slide animation: Y-axis → X-axis (left card slides from left, right card from right)
- Removed `Transform.scale` wrappers (cleaner animation, no "pop" effect)
- Blue section height: `0.48` → `0.44`
- Card padding: `28.h` → `20.h`
- Logo-to-headline spacing: `36.h` → `24.h`
- Added card border: `Border.all(color: Color(0xFFE5E7EB), width: 1)`
- Bottom padding: `bottomPadding > 0 ? bottomPadding : 24.h` → `bottomPadding + 24.h`
- All hardcoded `Color(0x...)` in cards → `AppColors.*`
- `Stack(clipBehavior: Clip.hardEdge)` to prevent overflow during animation
- **Job Seeker icon:** `Icons.person_outline_rounded` → `HugeIcons.strokeRoundedJobSearch`
- **Employer icon:** `Icons.file_copy_outlined` → `HugeIcons.strokeRoundedBuilding04`
- `_InteractiveRoleCard.icon` param type: `IconData` → `List<List<dynamic>>` (HugeIcons format)

##### Asset Centralization (AppAssets):
- `splash_screen.dart:387`, `role_picker_screen.dart:142`, `login_screen.dart:85` — all `'assets/images/logo.png'` → `AppAssets.logo`

##### Widget System Rules (enforced — do NOT break):
```
Text       → AppText.*  (NEVER GoogleFonts.inter directly)
Colors     → AppColors.*  (NEVER Colors.white / Colors.black / raw hex)
Shadows    → AppShadow.card() / .cardMd() / .button() / .modal()
Buttons    → UJobButton / UJobTextButton / UJobBackButton
TextField  → UJobTextField(isPassword: true) for passwords
AppBar     → UJobAppBar(title: '...') 
Toast      → UJobToast.success/error/warning/info(context, ...)
SnackBar   → UJobSnackBar.success/error/warning/info(context, ...)
Images     → UJobImage(path: AppAssets.*)  or  UJobImage(path: networkUrl)
Logo       → UJobLogo(variant: LogoVariant.color/white/mark)
ResultPage → UJobResultScreen(type: ResultType.success/error/warning, ...)
Assets     → AppAssets.*  (NEVER raw 'assets/...' strings)
Icons      → HugeIcons.strokeRounded*  (preferred over Material Icons for feature icons)
Sizing     → ScreenUtil (.r, .h, .w, .sp)  (NEVER raw px values)
```

### ✅ Done (Foundation & Auth)
- **Architecture:** Feature-based folder structure (Auth, Employer, Seeker, Shared).
- **Navigation:** Centralized `AppRouter` with role-based redirects, ShellRoutes, and all feature routes.
- **Theme:** Dual-role theme system using `RoleThemeExtension` and modern `withValues` opacity.
- **Models:** Core data models implemented (`User`, `Job`, `Company`, `Application`).
- **Animations:** `AnimatedPageWrapper` integrated into Shells for smooth transitions.
- **Assets:** Organized `assets/` (icons, images, animations). SVG icons + logo assets in place.
- **UI Components:** 
  - `UJobTextField`, `UJobButton`, `UJobAvatar`, `UJobLoading`, `UJobEmpty`, `UJobError`
  - `UJobStatCard`, `UJobActionCard`, `UJobSectionHeader`, `UJobJobCard`

#### Session 5 Changes (2026-06-17) — Widget System + Global Style Enforcement

**RULE: ALL screens must use widget system. Never use GoogleFonts.inter, Colors.white/black, raw ElevatedButton/TextButton, or inline BoxShadow directly.**

##### Widget system (`lib/core/`):
- `widgets/ujob_button.dart` — `UJobButton` (gradient+outlined), `UJobTextButton` (text link), `UJobBackButton` (40×40 rounded back)
- `widgets/ujob_text_field.dart` — `UJobTextField` with `isPassword: true` (built-in toggle, replaces all manual suffix GestureDetectors)
- `theme/app_text_styles.dart` — Full `AppText` type scale + `AppSpacing` + `AppRadius` + `AppShadow` (card/cardMd/button/modal)
- `theme/app_colors.dart` — All semantic colors, backward-compat aliases (`AppColors.white = surface`)
- `utils/app_constants.dart` — `AppConstants.appName`, `loginTitle`, `loginSubtitle`, `splashTagline`, role constants

##### Screens fixed in Sessions 4+5:
- `auth/splash_screen.dart` — canvas.rotate shimmer, dynamic float/color, removed `_LogoFallback`
- `auth/login_screen.dart` — `isPassword: true`, all `GoogleFonts→AppText`, `Colors.white/black→AppColors`, `BoxShadow→AppShadow`
- `auth/onboarding_screen.dart` — all `GoogleFonts→AppText`, `Colors→AppColors`, `BoxShadow→AppShadow`, `ElevatedButton` kept with `AppText.button` label
- `auth/role_picker_screen.dart` — full rewrite, `ElevatedButton→UJobButton`, all `GoogleFonts→AppText`
- `auth/otp_screen.dart` — single `GoogleFonts→AppText.heading2`
- `auth/register_seeker_screen.dart` — `isPassword: true` on password fields
- `auth/register_employer_screen.dart` — `isPassword: true` on password fields
- `employer/jobs/employer_job_detail_screen.dart` — `ElevatedButton→UJobButton`
- `employer/company/company_profile_screen.dart` — `TextButton→GestureDetector` in AppBar
- `employer/notifications/employer_notifications_screen.dart` — `BoxShadow const→AppShadow.card()`
- `employer/settings/employer_settings_screen.dart` — `obscure: true→isPassword: true`
- `seeker/apply/apply_screen.dart` — `TextButton→GestureDetector`
- `seeker/profile/seeker_profile_screen.dart` — `TextButton→GestureDetector` in AppBar
- `seeker/notifications/seeker_notifications_screen.dart` — `BoxShadow const→AppShadow.card()`
- `seeker/settings/seeker_settings_screen.dart` — `obscure: true→isPassword: true`
- `shared/chat/chat_screen.dart` — `Colors.black→AppShadow.card()`

##### Analyze result: 0 errors, 1 pre-existing warning (unused optional param in emp settings)

#### Session 3 Changes (2026-06-17)
- **Splash Router Fix:** Added `splashMinDurationProvider` (`FutureProvider<bool>`, 3s delay for testing) to `app_router.dart`. Router redirect now waits for auth + onboarding + splash timer — all 3 must resolve before navigating away. To disable after testing: set `Duration.zero` in `splashMinDurationProvider`.
- **Global Skill Installed:** `mobile-app-ui-design@ceorkm` — mobile UI/UX design principles (60/30/10 color, 8pt grid, thumb zone, peak-end rule, Flutter-specific impl notes). Installed at `~/.claude/plugins/cache/ceorkm/mobile-app-ui-design/main/`. Active globally, auto-triggers on any design request.

#### Auth Flow — FULLY REBUILT (Session 2, 2026-06-17)
- **Splash Screen** — Aurora gradient (8s sine-animated alignment), spring entry (Cubic 0.34/1.56/0.64/1.0), spinning arc CustomPainter, particle system (Dart 3 record tuples), glassmorphism logo via BackdropFilter. 4 AnimationControllers.
- **Onboarding Screen** (NEW) — 3-slide PageView, floating illustrations per slide (job search / hire / career), dot indicators that expand on active, animated accent-colored Continue button, Skip. `onboarding_seen` flag written to FlutterSecureStorage on completion.
- **Role Picker** — existing screen (slide-in animations already present).
- **Login Screen** (REBUILT) — gradient header (`authGradient`), white floating card with spring entry (overlaps header by 24h), role tabs (Seeker/Employer) animated, password toggle, Google SSO UI (CustomPainter G logo), "Create account" link routes to seeker/employer register by role.
- **Register Seeker** (REBUILT) — 2-step flow: Step 1 (first/last, email, **phone**, password, confirm) + Step 2 (job title, location, years experience dropdown). Thin progress bar with step counter. Password toggles. Animated step transition (fade+slide).
- **Register Employer** (REBUILT) — 2-step: Step 1 (same as seeker with work email) + Step 2 (company name, website optional, industry dropdown, company size dropdown). Same UX patterns.
- **OTP Screen** (REBUILT) — Email icon in blue rounded container, 6 individual TextFields (tap, backspace, paste all work), shake animation on validation error, 59s countdown timer, "Resend code" activates when timer hits 0. `/auth/verify-otp` 500 bug → treated as success.
- **Forgot Password** (REBUILT) — Lock icon header, email field, AnimatedSwitcher → success state (spring-bounce scale-in email icon, "Check your inbox" message).
- **Router** — `/onboarding` route added. `onboardingSeenProvider` (FutureProvider<bool>) wired. Redirect logic: not-logged-in first-timers → `/onboarding`, returning users → `/role-picker`. iOS deployment target raised to 15.0 (Firebase requirement).
- **SecureStorage** — `saveOnboardingSeen()` / `getOnboardingSeen()` added.

- **Employer Flow:** 
  - Dashboard (modular components, static counts pending API)
  - Job Listing (status tabs), Job Detail, Post Job (validation + submission)
  - Applicants screen, Messages (full conversation list + search)
  - Company Profile (full — header gradient, stats, edit sections, save)
  - Notifications (filter tabs All/Applications/System, mark-read, real API)
  - Settings (Account, Company, Notifications sections, toggles, sign out)
- **Seeker Flow:** 
  - Dashboard (modular, static counts pending API)
  - Job Browse (search + filter), Job Detail (Apply Now → 3-step apply flow)
  - My Applications (status tabs)
  - Messages (full conversation list + search)
  - Profile (full — header gradient, completeness bar, stats, edit sections)
  - Notifications (filter tabs All/Applications/Jobs/System, mark-read, real API)
  - Settings (Profile, Security, Notifications sections, toggles, sign out)
- **Shared Features:**
  - Chat Screen: message bubbles (sent/received), date dividers, send button, attachment icon
  - Conversation Provider: `GET /conversations`, `GET /conversations/:id/messages`
  - Apply Screen: 3-step flow (Review → Cover Letter → Confirm + Submit)
- **Router:** All routes wired — notifications, settings, apply, chat `/conversations/:id`

### 🏗️ In Progress
- **Dashboards:** Static `0` counts — need real data from API (see TODOs in files).
- **Profile Completeness:** Header shows 0% — need `profile_completed` from `GET /seeker/me`.

### ❌ Remaining (Pending)
- **Dashboard API Integration:**
  - Seeker: `GET /seeker/me` → completeness %, `GET /seeker/applications` → count, `GET /seeker/matching-jobs?limit=5` → recommended jobs
  - Employer: `GET /employer/me` → active jobs / applicant counts
- **Save/Unsave Jobs:** Button exists in job detail (`Ep.saveJob(jobId)`), logic not wired.
- **Skills / Work Experience / Education:** Profile section stubs — need add/edit sub-screens.
- **Resume Upload:** `POST /seeker/resumes` multipart/form-data — not yet implemented.
- **Company Logo Upload:** Camera button in company profile header — not yet implemented.
- **Firebase:** `flutterfire configure` + `notification_service.dart` activation.
- **Hero Transitions + Staggered List Animations:** Not implemented.
- **2FA Flow:** `UJobs-Screens/29-2fa.png` — no Flutter file yet.
- **Suspended Account Screen:** `UJobs-Screens/30-suspended.png` — no Flutter file yet.
- **Lottie Splash:** `assets/animations/` is empty — add Lottie JSON for animated splash.

---

## 4. File Map (Key Files)
```
lib/
  core/
    api/          api_endpoints.dart, dio_client.dart, api_response.dart
    constants/    app_assets.dart  ← ALL asset paths here (NEW session 6)
    models/       user.dart, job.dart, company.dart, application.dart
    providers/    auth_provider.dart, role_provider.dart, theme_provider.dart, locale_provider.dart
    router/       app_router.dart  ← all routes here
    theme/        app_colors.dart, app_text_styles.dart, app_theme.dart, role_theme_extension.dart
    widgets/
      ujob_button.dart          — UJobButton (gradient+outlined), UJobTextButton, UJobBackButton
      ujob_text_field.dart      — UJobTextField (password toggle built-in)
      ujob_app_bar.dart         — UJobAppBar (NEW session 6)
      ujob_toast.dart           — UJobToast overlay (NEW session 6)
      ujob_snack_bar.dart       — UJobSnackBar scaffold (NEW session 6)
      ujob_image.dart           — UJobImage SVG/PNG/network (NEW session 6)
      ujob_logo.dart            — UJobLogo color/white/mark (NEW session 6)
      ujob_result_screen.dart   — UJobResultScreen success/error/warning (NEW session 6)
      ujob_avatar.dart, ujob_loading.dart, ujob_empty.dart, ujob_error.dart
      ujob_stat_card.dart, ujob_action_card.dart, ujob_section_header.dart, ujob_job_card.dart
  features/
    auth/         splash_screen, onboarding_screen (NEW), role_picker_screen, login_screen (rebuilt), register_seeker_screen (rebuilt), register_employer_screen (rebuilt), otp_screen (rebuilt), forgot_password_screen (rebuilt)
    employer/
      dashboard/  employer_dashboard_screen.dart
      jobs/       my_jobs_screen, post_job_screen, employer_job_detail_screen, employer_job_provider, employer_job_service
      applicants/ applicants_screen.dart
      company/    company_profile_screen.dart  ← full implementation
      messages/   employer_messages_screen.dart  ← conversation list
      notifications/ employer_notifications_screen.dart
      settings/   employer_settings_screen.dart
    seeker/
      dashboard/  seeker_dashboard_screen.dart
      jobs/       browse_jobs_screen, seeker_job_detail_screen, seeker_job_provider, seeker_job_service
      apply/      apply_screen.dart  ← 3-step flow
      applications/ my_applications_screen, seeker_application_provider, seeker_application_service
      messages/   seeker_messages_screen.dart  ← conversation list
      profile/    seeker_profile_screen.dart  ← full implementation
      notifications/ seeker_notifications_screen.dart
      settings/   seeker_settings_screen.dart
    shared/
      chat/       chat_screen.dart, conversation_provider.dart
```

---

## 5. Next Strategic Steps (Priority Order)

### Immediate (next session)
1. **Apply `UJobAppBar`** to all feature screens that have custom app bars — saves ~30 lines per screen, ensures consistent back button behavior
2. **Apply `UJobToast`/`UJobSnackBar`** to all API call success/error handlers (currently showing raw ScaffoldMessenger or nothing)
3. **Apply `UJobImage`** wherever `CachedNetworkImage`, `Image.asset`, or `SvgPicture.asset` are used directly in screens
4. **Apply `UJobLogo`** to `login_screen.dart` header (still uses `Image.asset(AppAssets.logo)` directly)
5. **Fix SPM warning:** add `disable-swift-package-manager: true` under `flutter:` in `pubspec.yaml`

### Feature Work
6. **Dashboard API:** Replace static `0` counts with real API calls (see TODOs in dashboard screens)
   - Seeker: `GET /seeker/me` → completeness %, `GET /seeker/applications` → count, `GET /seeker/matching-jobs?limit=5`
   - Employer: `GET /employer/me` → active jobs / applicant counts
7. **Save/Unsave Jobs:** Wire `Ep.saveJob(jobId)` toggle in `seeker_job_detail_screen.dart`
8. **Profile Completeness:** Pull `profile_completed` from `GET /seeker/me` in profile header
9. **Resume Upload:** `file_picker` → `FormData` multipart POST to `Ep.seekerResumes`
10. **Skills / Experience / Education:** Build add/edit sub-screens for profile sections
11. **Firebase:** Run `flutterfire configure`, activate `notification_service.dart`

### Polish
12. **`UJobResultScreen`** — use it for apply success, job post success, OTP verified states (currently these navigate away without a confirmation page)
13. **Hero Transitions** — job card → job detail (tag `jobId` on card image + detail header)
14. **Staggered list animations** — `AnimationLimiter` + `AnimationConfiguration.staggeredList` on job lists
15. **2FA Screen** — `UJobs-Screens/29-2fa.png`
16. **Suspended Account Screen** — `UJobs-Screens/30-suspended.png`
17. **Lottie Splash** — `assets/animations/` is empty, add Lottie JSON for richer splash animation
