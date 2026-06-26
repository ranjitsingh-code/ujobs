class EmployerSettings {
  final Map<String, dynamic> user;
  final EmployerPrefs prefs;
  final Map<String, dynamic> exportUrls;

  EmployerSettings({required this.user, required this.prefs, required this.exportUrls});

  factory EmployerSettings.fromJson(Map<String, dynamic> json) {
    return EmployerSettings(
      user: Map<String, dynamic>.from(json['user'] ?? {}),
      prefs: EmployerPrefs.fromJson(json['prefs'] ?? {}),
      exportUrls: Map<String, dynamic>.from(json['export_urls'] ?? {}),
    );
  }
}

class EmployerPrefs {
  final bool notifNewApplication;
  final bool notifMessages;
  final bool notifInterview;
  final bool notifSecurity;
  final bool notifMarketing;
  final bool notifBrowser;
  final bool companyProfilePublic;
  final bool showEmailToCandidates;
  final bool showPhoneToCandidates;
  final String language;
  final String timezone;
  final String dateFormat;

  EmployerPrefs({
    this.notifNewApplication = true,
    this.notifMessages = true,
    this.notifInterview = true,
    this.notifSecurity = true,
    this.notifMarketing = false,
    this.notifBrowser = false,
    this.companyProfilePublic = true,
    this.showEmailToCandidates = false,
    this.showPhoneToCandidates = false,
    this.language = 'en',
    this.timezone = 'UTC',
    this.dateFormat = 'DD/MM/YYYY',
  });

  factory EmployerPrefs.fromJson(Map<String, dynamic> json) {
    return EmployerPrefs(
      notifNewApplication: json['notif_new_application'] ?? true,
      notifMessages: json['notif_messages'] ?? true,
      notifInterview: json['notif_interview'] ?? true,
      notifSecurity: json['notif_security'] ?? true,
      notifMarketing: json['notif_marketing'] ?? false,
      notifBrowser: json['notif_browser'] ?? false,
      companyProfilePublic: json['company_profile_public'] ?? true,
      showEmailToCandidates: json['show_email_to_candidates'] ?? false,
      showPhoneToCandidates: json['show_phone_to_candidates'] ?? false,
      language: json['language'] ?? 'en',
      timezone: json['timezone'] ?? 'UTC',
      dateFormat: json['date_format'] ?? 'DD/MM/YYYY',
    );
  }
}
