class SeekerSettings {
  final Map<String, dynamic> user;
  final SeekerPrefs prefs;
  final Map<String, dynamic> exportUrls;

  SeekerSettings({
    required this.user,
    required this.prefs,
    this.exportUrls = const {},
  });

  factory SeekerSettings.fromJson(Map<String, dynamic> json) {
    return SeekerSettings(
      user: json['user'] ?? {},
      prefs: SeekerPrefs.fromJson(json['prefs'] ?? {}),
      exportUrls: json['export_urls'] ?? {},
    );
  }
}

class SeekerPrefs {
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

  SeekerPrefs({
    required this.notifNewApplication,
    required this.notifMessages,
    required this.notifInterview,
    required this.notifSecurity,
    required this.notifMarketing,
    required this.notifBrowser,
    required this.companyProfilePublic,
    required this.showEmailToCandidates,
    required this.showPhoneToCandidates,
    required this.language,
    required this.timezone,
    required this.dateFormat,
  });

  factory SeekerPrefs.fromJson(Map<String, dynamic> json) {
    return SeekerPrefs(
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

  Map<String, dynamic> toJson() {
    return {
      'notif_new_application': notifNewApplication,
      'notif_messages': notifMessages,
      'notif_interview': notifInterview,
      'notif_security': notifSecurity,
      'notif_marketing': notifMarketing,
      'notif_browser': notifBrowser,
      'company_profile_public': companyProfilePublic,
      'show_email_to_candidates': showEmailToCandidates,
      'show_phone_to_candidates': showPhoneToCandidates,
      'language': language,
      'timezone': timezone,
      'date_format': dateFormat,
    };
  }
}
