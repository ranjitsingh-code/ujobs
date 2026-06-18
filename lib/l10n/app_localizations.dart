import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'UJob'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @selectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select...'**
  String get selectPlaceholder;

  /// No description provided for @negotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get negotiable;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? '**
  String get haveAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountLink;

  /// No description provided for @errorPasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordsMatch;

  /// No description provided for @resetSentSub.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to'**
  String get resetSentSub;

  /// No description provided for @spamCheckSub.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it? Check your spam folder.'**
  String get spamCheckSub;

  /// No description provided for @errorCompleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the complete 6-digit code'**
  String get errorCompleteOtp;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to'**
  String get otpSubtitle;

  /// No description provided for @resendCodeLink.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCodeLink;

  /// No description provided for @newApplicantsNotif.
  ///
  /// In en, this message translates to:
  /// **'New Applicants'**
  String get newApplicantsNotif;

  /// No description provided for @applicationUpdatesNotif.
  ///
  /// In en, this message translates to:
  /// **'Application Updates'**
  String get applicationUpdatesNotif;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageSection;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Search Smarter · Apply Faster · Get Hired'**
  String get splashTagline;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Find Your\nDream Job'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Sub.
  ///
  /// In en, this message translates to:
  /// **'AI matches you with thousands of opportunities based on your skills, experience and location.'**
  String get onboardingSlide1Sub;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Hire Top\nTalent Fast'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Sub.
  ///
  /// In en, this message translates to:
  /// **'Post jobs in minutes and connect with pre-vetted candidates. Smart filters save you hours.'**
  String get onboardingSlide2Sub;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Powered by\nArtificial Intelligence'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Sub.
  ///
  /// In en, this message translates to:
  /// **'Smart job matching, real-time salary insights and personalised recommendations — updated daily.'**
  String get onboardingSlide3Sub;

  /// No description provided for @rolePickerTagline.
  ///
  /// In en, this message translates to:
  /// **'The smarter way\nto find work & hire'**
  String get rolePickerTagline;

  /// No description provided for @rolePickerSub.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of job seekers and employers\nalready using UJobs.'**
  String get rolePickerSub;

  /// No description provided for @lookingTo.
  ///
  /// In en, this message translates to:
  /// **'I\'m looking to...'**
  String get lookingTo;

  /// No description provided for @findWork.
  ///
  /// In en, this message translates to:
  /// **'Find Work'**
  String get findWork;

  /// No description provided for @findWorkSub.
  ///
  /// In en, this message translates to:
  /// **'Browse & apply\nto jobs'**
  String get findWorkSub;

  /// No description provided for @hireTalent.
  ///
  /// In en, this message translates to:
  /// **'Hire Talent'**
  String get hireTalent;

  /// No description provided for @hireTalentSub.
  ///
  /// In en, this message translates to:
  /// **'Post jobs &\nfind candidates'**
  String get hireTalentSub;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @jobSeekerTab.
  ///
  /// In en, this message translates to:
  /// **'Job Seeker'**
  String get jobSeekerTab;

  /// No description provided for @employerTab.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get employerTab;

  /// No description provided for @errorEnterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get errorEnterEmailPassword;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorInvalidCredentials;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get errorLoginFailed;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Find your next opportunity'**
  String get createAccountSub;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Alex'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Johnson'**
  String get lastNameHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 000-0000'**
  String get phoneHint;

  /// No description provided for @passwordCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get passwordCreateHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get confirmPasswordHint;

  /// No description provided for @profileBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Your background'**
  String get profileBackgroundTitle;

  /// No description provided for @profileBackgroundSub.
  ///
  /// In en, this message translates to:
  /// **'Help us match you with the right roles'**
  String get profileBackgroundSub;

  /// No description provided for @jobTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Current or desired job title'**
  String get jobTitleLabel;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. UX Designer'**
  String get jobTitleHint;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'City, Country'**
  String get locationHint;

  /// No description provided for @experienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get experienceLabel;

  /// No description provided for @exp1Year.
  ///
  /// In en, this message translates to:
  /// **'< 1 year'**
  String get exp1Year;

  /// No description provided for @exp12Years.
  ///
  /// In en, this message translates to:
  /// **'1–2 years'**
  String get exp12Years;

  /// No description provided for @exp35Years.
  ///
  /// In en, this message translates to:
  /// **'3–5 years'**
  String get exp35Years;

  /// No description provided for @exp610Years.
  ///
  /// In en, this message translates to:
  /// **'6–10 years'**
  String get exp610Years;

  /// No description provided for @exp10PlusYears.
  ///
  /// In en, this message translates to:
  /// **'10+ years'**
  String get exp10PlusYears;

  /// No description provided for @errorFirstLast.
  ///
  /// In en, this message translates to:
  /// **'Enter first and last name'**
  String get errorFirstLast;

  /// No description provided for @errorValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get errorValidEmail;

  /// No description provided for @errorValidWorkEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid work email'**
  String get errorValidWorkEmail;

  /// No description provided for @errorPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPasswordLength;

  /// No description provided for @errorPasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordMatch;

  /// No description provided for @errorCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get errorCompanyName;

  /// No description provided for @errorRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Try again.'**
  String get errorRegistrationFailed;

  /// No description provided for @employerAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Employer account'**
  String get employerAccountTitle;

  /// No description provided for @employerAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Start hiring great talent today'**
  String get employerAccountSub;

  /// No description provided for @firstNameEmpHint.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get firstNameEmpHint;

  /// No description provided for @lastNameEmpHint.
  ///
  /// In en, this message translates to:
  /// **'Smith'**
  String get lastNameEmpHint;

  /// No description provided for @workEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Work email'**
  String get workEmailLabel;

  /// No description provided for @workEmailHint.
  ///
  /// In en, this message translates to:
  /// **'john@company.com'**
  String get workEmailHint;

  /// No description provided for @companyDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Company details'**
  String get companyDetailsTitle;

  /// No description provided for @companyDetailsSub.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your organisation'**
  String get companyDetailsSub;

  /// No description provided for @companyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyNameLabel;

  /// No description provided for @companyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Acme Inc.'**
  String get companyNameHint;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website (optional)'**
  String get websiteLabel;

  /// No description provided for @websiteHint.
  ///
  /// In en, this message translates to:
  /// **'https://company.com'**
  String get websiteHint;

  /// No description provided for @industryLabel.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industryLabel;

  /// No description provided for @industryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get industryTechnology;

  /// No description provided for @industryDesign.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get industryDesign;

  /// No description provided for @industryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get industryFinance;

  /// No description provided for @industryHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get industryHealthcare;

  /// No description provided for @industryMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get industryMarketing;

  /// No description provided for @industryOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get industryOperations;

  /// No description provided for @industryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get industryEducation;

  /// No description provided for @industrySales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get industrySales;

  /// No description provided for @industryRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get industryRealEstate;

  /// No description provided for @companySizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Company size'**
  String get companySizeLabel;

  /// No description provided for @companySize1.
  ///
  /// In en, this message translates to:
  /// **'1–10'**
  String get companySize1;

  /// No description provided for @companySize2.
  ///
  /// In en, this message translates to:
  /// **'11–50'**
  String get companySize2;

  /// No description provided for @companySize3.
  ///
  /// In en, this message translates to:
  /// **'51–200'**
  String get companySize3;

  /// No description provided for @companySize4.
  ///
  /// In en, this message translates to:
  /// **'201–500'**
  String get companySize4;

  /// No description provided for @companySize5.
  ///
  /// In en, this message translates to:
  /// **'500+'**
  String get companySize5;

  /// No description provided for @createEmployerAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Employer Account'**
  String get createEmployerAccount;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSub.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link'**
  String get resetPasswordSub;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @errorEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get errorEnterEmail;

  /// No description provided for @checkInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkInboxTitle;

  /// No description provided for @resetLinkSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to'**
  String get resetLinkSentTo;

  /// No description provided for @checkSpam.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it? Check your spam folder.'**
  String get checkSpam;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @checkEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmailTitle;

  /// No description provided for @otpInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to'**
  String get otpInstructions;

  /// No description provided for @otpErrorComplete.
  ///
  /// In en, this message translates to:
  /// **'Enter the complete 6-digit code'**
  String get otpErrorComplete;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in '**
  String get resendCodeIn;

  /// No description provided for @resendCodeSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String resendCodeSeconds(int seconds);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmail;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your email'**
  String get enterOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOtp;

  /// No description provided for @greetingName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name} 👋'**
  String greetingName(String name);

  /// No description provided for @greetingFallback.
  ///
  /// In en, this message translates to:
  /// **'Hello there 👋'**
  String get greetingFallback;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @profileCompletionHint.
  ///
  /// In en, this message translates to:
  /// **'Add skills, experience and resume to get better matches'**
  String get profileCompletionHint;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @browseJobs.
  ///
  /// In en, this message translates to:
  /// **'Browse Jobs'**
  String get browseJobs;

  /// No description provided for @myApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplications;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @recommendedJobs.
  ///
  /// In en, this message translates to:
  /// **'Recommended Jobs'**
  String get recommendedJobs;

  /// No description provided for @recentJobs.
  ///
  /// In en, this message translates to:
  /// **'Recent Jobs'**
  String get recentJobs;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @applicants.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get applicants;

  /// No description provided for @postJob.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get postJob;

  /// No description provided for @postJobSub.
  ///
  /// In en, this message translates to:
  /// **'Create a new job listing'**
  String get postJobSub;

  /// No description provided for @myJobs.
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get myJobs;

  /// No description provided for @activeJobs.
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get activeJobs;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @viewApplicants.
  ///
  /// In en, this message translates to:
  /// **'View Applicants'**
  String get viewApplicants;

  /// No description provided for @viewApplicantsSub.
  ///
  /// In en, this message translates to:
  /// **'Review candidates for your jobs'**
  String get viewApplicantsSub;

  /// No description provided for @companyProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get companyProfileTitle;

  /// No description provided for @companyProfileSub.
  ///
  /// In en, this message translates to:
  /// **'Update your company information'**
  String get companyProfileSub;

  /// No description provided for @postJobButton.
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get postJobButton;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @jobTitleJobHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Senior Flutter Developer'**
  String get jobTitleJobHint;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get jobDescription;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the role...'**
  String get descriptionHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'London'**
  String get cityHint;

  /// No description provided for @salaryMin.
  ///
  /// In en, this message translates to:
  /// **'Salary Min (£)'**
  String get salaryMin;

  /// No description provided for @salaryMinHint.
  ///
  /// In en, this message translates to:
  /// **'30000'**
  String get salaryMinHint;

  /// No description provided for @salaryMax.
  ///
  /// In en, this message translates to:
  /// **'Salary Max (£)'**
  String get salaryMax;

  /// No description provided for @salaryMaxHint.
  ///
  /// In en, this message translates to:
  /// **'60000'**
  String get salaryMaxHint;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @skillsHint.
  ///
  /// In en, this message translates to:
  /// **'Flutter, Dart, Firebase'**
  String get skillsHint;

  /// No description provided for @employmentType.
  ///
  /// In en, this message translates to:
  /// **'Employment Type'**
  String get employmentType;

  /// No description provided for @fullTime.
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get fullTime;

  /// No description provided for @partTime.
  ///
  /// In en, this message translates to:
  /// **'Part Time'**
  String get partTime;

  /// No description provided for @contract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contract;

  /// No description provided for @internship.
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get internship;

  /// No description provided for @workplaceType.
  ///
  /// In en, this message translates to:
  /// **'Workplace Type'**
  String get workplaceType;

  /// No description provided for @onSite.
  ///
  /// In en, this message translates to:
  /// **'On Site'**
  String get onSite;

  /// No description provided for @remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @resumeRequired.
  ///
  /// In en, this message translates to:
  /// **'Resume Required'**
  String get resumeRequired;

  /// No description provided for @resumeRequiredOption.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get resumeRequiredOption;

  /// No description provided for @resumeOptionalOption.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get resumeOptionalOption;

  /// No description provided for @resumeNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Not Required'**
  String get resumeNotRequired;

  /// No description provided for @jobPostedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Job posted successfully!'**
  String get jobPostedSuccess;

  /// No description provided for @errorFillTitleDesc.
  ///
  /// In en, this message translates to:
  /// **'Please fill in title and description'**
  String get errorFillTitleDesc;

  /// No description provided for @jobApprovalNotice.
  ///
  /// In en, this message translates to:
  /// **'Jobs are set to pending after posting — admin must approve before going live.'**
  String get jobApprovalNotice;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @savedJobs.
  ///
  /// In en, this message translates to:
  /// **'Saved Jobs'**
  String get savedJobs;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @uploadResume.
  ///
  /// In en, this message translates to:
  /// **'Upload Resume'**
  String get uploadResume;

  /// No description provided for @allTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTab;

  /// No description provided for @activeTab.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeTab;

  /// No description provided for @pendingTab.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTab;

  /// No description provided for @draftTab.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftTab;

  /// No description provided for @closedTab.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedTab;

  /// No description provided for @reviewingTab.
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get reviewingTab;

  /// No description provided for @shortlistedTab.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get shortlistedTab;

  /// No description provided for @rejectedTab.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedTab;

  /// No description provided for @selectJobFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a job first'**
  String get selectJobFirst;

  /// No description provided for @selectJobFirstSub.
  ///
  /// In en, this message translates to:
  /// **'Go to My Jobs → tap a job → View Applicants'**
  String get selectJobFirstSub;

  /// No description provided for @reviewApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Application'**
  String get reviewApplicationTitle;

  /// No description provided for @coverLetterTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover Letter'**
  String get coverLetterTitle;

  /// No description provided for @coverLetterOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional — introduce yourself and explain why you\'re a great fit.'**
  String get coverLetterOptional;

  /// No description provided for @coverLetterHint.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m excited to apply for this role because...'**
  String get coverLetterHint;

  /// No description provided for @reviewAndSubmit.
  ///
  /// In en, this message translates to:
  /// **'Review & Submit'**
  String get reviewAndSubmit;

  /// No description provided for @doubleCheckEverything.
  ///
  /// In en, this message translates to:
  /// **'Double-check everything before submitting.'**
  String get doubleCheckEverything;

  /// No description provided for @positionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get positionLabel;

  /// No description provided for @companyLabel.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get companyLabel;

  /// No description provided for @resumeAttached.
  ///
  /// In en, this message translates to:
  /// **'Attached'**
  String get resumeAttached;

  /// No description provided for @profileShareWarning.
  ///
  /// In en, this message translates to:
  /// **'Your profile, skills, and resume will be shared with the employer.'**
  String get profileShareWarning;

  /// No description provided for @profileShareFull.
  ///
  /// In en, this message translates to:
  /// **'Your full profile and resume will be shared with the employer upon submission.'**
  String get profileShareFull;

  /// No description provided for @nextCoverLetter.
  ///
  /// In en, this message translates to:
  /// **'Next: Cover Letter'**
  String get nextCoverLetter;

  /// No description provided for @nextReview.
  ///
  /// In en, this message translates to:
  /// **'Next: Review'**
  String get nextReview;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @resumeFilename.
  ///
  /// In en, this message translates to:
  /// **'Resume.pdf'**
  String get resumeFilename;

  /// No description provided for @uploadToAttach.
  ///
  /// In en, this message translates to:
  /// **'Upload to attach your resume'**
  String get uploadToAttach;

  /// No description provided for @applyingFor.
  ///
  /// In en, this message translates to:
  /// **'APPLYING FOR'**
  String get applyingFor;

  /// No description provided for @applicationSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted!'**
  String get applicationSubmittedTitle;

  /// No description provided for @applicationSubmittedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your application has been sent. We\'ll notify you when the employer responds.'**
  String get applicationSubmittedMsg;

  /// No description provided for @backToJob.
  ///
  /// In en, this message translates to:
  /// **'Back to Job'**
  String get backToJob;

  /// No description provided for @failedToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit. Please try again.'**
  String get failedToSubmit;

  /// No description provided for @profileViews.
  ///
  /// In en, this message translates to:
  /// **'Profile Views'**
  String get profileViews;

  /// No description provided for @applications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @professionalSummary.
  ///
  /// In en, this message translates to:
  /// **'Professional Summary'**
  String get professionalSummary;

  /// No description provided for @aboutBio.
  ///
  /// In en, this message translates to:
  /// **'About / Bio'**
  String get aboutBio;

  /// No description provided for @skillsSection.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skillsSection;

  /// No description provided for @skillsEmpty.
  ///
  /// In en, this message translates to:
  /// **'0 skills added'**
  String get skillsEmpty;

  /// No description provided for @workExperience.
  ///
  /// In en, this message translates to:
  /// **'Work Experience'**
  String get workExperience;

  /// No description provided for @workExperienceEmpty.
  ///
  /// In en, this message translates to:
  /// **'0 positions'**
  String get workExperienceEmpty;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @educationEmpty.
  ///
  /// In en, this message translates to:
  /// **'0 qualifications'**
  String get educationEmpty;

  /// No description provided for @certifications.
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get certifications;

  /// No description provided for @addCertifications.
  ///
  /// In en, this message translates to:
  /// **'Add certifications'**
  String get addCertifications;

  /// No description provided for @editPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Info'**
  String get editPersonalInfo;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your experience, skills, and what you\'re looking for...'**
  String get bioHint;

  /// No description provided for @profileCompleteness.
  ///
  /// In en, this message translates to:
  /// **'Profile Completeness'**
  String get profileCompleteness;

  /// No description provided for @seekerImproveTip.
  ///
  /// In en, this message translates to:
  /// **'Add skills & experience to improve matches'**
  String get seekerImproveTip;

  /// No description provided for @employerImproveTip.
  ///
  /// In en, this message translates to:
  /// **'Add social links to reach 80%'**
  String get employerImproveTip;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @aboutCompany.
  ///
  /// In en, this message translates to:
  /// **'About Company'**
  String get aboutCompany;

  /// No description provided for @aboutCompanySub.
  ///
  /// In en, this message translates to:
  /// **'Company description & mission'**
  String get aboutCompanySub;

  /// No description provided for @industrySpecialties.
  ///
  /// In en, this message translates to:
  /// **'Industry & Specialties'**
  String get industrySpecialties;

  /// No description provided for @socialLinks.
  ///
  /// In en, this message translates to:
  /// **'Social Links'**
  String get socialLinks;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfo;

  /// No description provided for @contactInfoSub.
  ///
  /// In en, this message translates to:
  /// **'Visibility: Public'**
  String get contactInfoSub;

  /// No description provided for @descriptionMission.
  ///
  /// In en, this message translates to:
  /// **'Description & Mission'**
  String get descriptionMission;

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get activeNow;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @noMessagesSeekerSub.
  ///
  /// In en, this message translates to:
  /// **'Employers will reach out here after reviewing your application'**
  String get noMessagesSeekerSub;

  /// No description provided for @noMessagesEmployerSub.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with a candidate'**
  String get noMessagesEmployerSub;

  /// No description provided for @sayHello.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello!'**
  String get sayHello;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @applicationsTab.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applicationsTab;

  /// No description provided for @jobsTab.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobsTab;

  /// No description provided for @systemTab.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTab;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get allCaughtUp;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileSection;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @resumeManagement.
  ///
  /// In en, this message translates to:
  /// **'Resume Management'**
  String get resumeManagement;

  /// No description provided for @jobPreferences.
  ///
  /// In en, this message translates to:
  /// **'Job Preferences'**
  String get jobPreferences;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get securitySection;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @changePhone.
  ///
  /// In en, this message translates to:
  /// **'Change Phone Number'**
  String get changePhone;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notificationsSection;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailAlerts.
  ///
  /// In en, this message translates to:
  /// **'Email Alerts'**
  String get emailAlerts;

  /// No description provided for @jobRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Job Recommendations'**
  String get jobRecommendations;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountSection;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMsgSeeker.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all data. This cannot be undone.'**
  String get deleteAccountMsgSeeker;

  /// No description provided for @deleteAccountMsgEmployer.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and company data. This cannot be undone.'**
  String get deleteAccountMsgEmployer;

  /// No description provided for @editPersonalInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Info'**
  String get editPersonalInfoLabel;

  /// No description provided for @editCompanyProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Company Profile'**
  String get editCompanyProfile;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @contactVisibility.
  ///
  /// In en, this message translates to:
  /// **'Contact Info Visibility'**
  String get contactVisibility;

  /// No description provided for @companySection.
  ///
  /// In en, this message translates to:
  /// **'COMPANY'**
  String get companySection;

  /// No description provided for @newApplicants.
  ///
  /// In en, this message translates to:
  /// **'New Applicants'**
  String get newApplicants;

  /// No description provided for @applicationUpdates.
  ///
  /// In en, this message translates to:
  /// **'Application Updates'**
  String get applicationUpdates;

  /// No description provided for @changePhoneEmp.
  ///
  /// In en, this message translates to:
  /// **'Change Phone'**
  String get changePhoneEmp;

  /// No description provided for @noJobsFound.
  ///
  /// In en, this message translates to:
  /// **'No jobs found'**
  String get noJobsFound;

  /// No description provided for @noJobsFoundSub.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or category'**
  String get noJobsFoundSub;

  /// No description provided for @noJobsPosted.
  ///
  /// In en, this message translates to:
  /// **'No jobs posted'**
  String get noJobsPosted;

  /// No description provided for @noJobsPostedSub.
  ///
  /// In en, this message translates to:
  /// **'Try posting a new job or changing the filter'**
  String get noJobsPostedSub;

  /// No description provided for @noApplications.
  ///
  /// In en, this message translates to:
  /// **'No applications'**
  String get noApplications;

  /// No description provided for @noApplicationsSub.
  ///
  /// In en, this message translates to:
  /// **'Start applying for jobs to see them here'**
  String get noApplicationsSub;

  /// No description provided for @failedLoadJobDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load job details'**
  String get failedLoadJobDetails;

  /// No description provided for @failedLoadCompanyProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load company profile'**
  String get failedLoadCompanyProfile;

  /// No description provided for @failedLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedLoadNotifications;

  /// No description provided for @failedLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get failedLoadMessages;

  /// No description provided for @failedLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get failedLoadProfile;

  /// No description provided for @switchRole.
  ///
  /// In en, this message translates to:
  /// **'Switch Role'**
  String get switchRole;

  /// No description provided for @switchToEmployer.
  ///
  /// In en, this message translates to:
  /// **'Switch to Employer'**
  String get switchToEmployer;

  /// No description provided for @switchToSeeker.
  ///
  /// In en, this message translates to:
  /// **'Switch to Job Seeker'**
  String get switchToSeeker;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noJobsYet.
  ///
  /// In en, this message translates to:
  /// **'No jobs yet'**
  String get noJobsYet;

  /// No description provided for @noApplicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get noApplicationsYet;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get systemTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @plansFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get plansFree;

  /// No description provided for @plansBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get plansBasic;

  /// No description provided for @plansPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get plansPro;

  /// No description provided for @plansEnterprise.
  ///
  /// In en, this message translates to:
  /// **'Enterprise'**
  String get plansEnterprise;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @statusApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get statusApplied;

  /// No description provided for @statusReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get statusReviewed;

  /// No description provided for @statusShortlisted.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get statusShortlisted;

  /// No description provided for @statusInterviewed.
  ///
  /// In en, this message translates to:
  /// **'Interviewed'**
  String get statusInterviewed;

  /// No description provided for @statusOffered.
  ///
  /// In en, this message translates to:
  /// **'Offered'**
  String get statusOffered;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get statusWithdrawn;

  /// No description provided for @iAmHiring.
  ///
  /// In en, this message translates to:
  /// **'I\'m Hiring'**
  String get iAmHiring;

  /// No description provided for @iAmLookingForWork.
  ///
  /// In en, this message translates to:
  /// **'Find Work'**
  String get iAmLookingForWork;

  /// No description provided for @employerTagline.
  ///
  /// In en, this message translates to:
  /// **'Post jobs and find top talent'**
  String get employerTagline;

  /// No description provided for @seekerTagline.
  ///
  /// In en, this message translates to:
  /// **'Discover your next opportunity'**
  String get seekerTagline;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Connecting Talent\nwith Opportunity'**
  String get appTagline;

  /// No description provided for @rolePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to get started'**
  String get rolePickerSubtitle;

  /// No description provided for @roleJobSeekerSub.
  ///
  /// In en, this message translates to:
  /// **'Find jobs & apply'**
  String get roleJobSeekerSub;

  /// No description provided for @roleEmployerSub.
  ///
  /// In en, this message translates to:
  /// **'Post jobs & hire'**
  String get roleEmployerSub;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
