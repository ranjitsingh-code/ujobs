import re

with open("lib/features/shared/settings/settings_screen.dart", "r") as f:
    code = f.read()

# Add import
import_stmt = "import '../../employer/settings/employer_settings_provider.dart';\n"
if "employer_settings_provider.dart" not in code:
    code = code.replace("import '../../../core/widgets/ujob_toast.dart';", "import '../../../core/widgets/ujob_toast.dart';\n" + import_stmt)

# Update _SettingsScreenState
state_block_old = """  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).valueOrNull;
      if (user != null) {
        setState(() {
          _twoFa = user.twoFactorEnabled;
        });
      }
    });
  }"""

state_block_new = """  bool _hasInitializedPrefs = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).valueOrNull;
      if (user != null) {
        setState(() {
          _twoFa = user.twoFactorEnabled;
        });
      }
    });
  }

  Future<void> _updateEmployerPref(String key, bool value) async {
    try {
      await ref.read(employerSettingsServiceProvider).updateSettings({'prefs': {key: value}});
    } catch (_) {
      if (mounted) UJobToast.error(context, 'Failed to update preference');
    }
  }"""

code = code.replace(state_block_old, state_block_new)

# Update build method to watch provider
build_old = """  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = ref.watch(activeRoleProvider);
    final isEmployer = role == 'employer';"""

build_new = """  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = ref.watch(activeRoleProvider);
    final isEmployer = role == 'employer';

    if (isEmployer) {
      final settingsAsync = ref.watch(employerSettingsProvider);
      if (settingsAsync.isLoading) {
         return Scaffold(
           backgroundColor: AppColors.background,
           appBar: UJobAppBar(title: l10n.settings, showBack: true, backgroundColor: AppColors.background),
           body: const Center(child: CircularProgressIndicator()),
         );
      } else if (settingsAsync.hasData && !_hasInitializedPrefs) {
         final prefs = settingsAsync.value!.prefs;
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
             setState(() {
               _emailNewJobApplication = prefs.notifNewApplication;
               _emailCandidateMessage = prefs.notifMessages;
               _emailInterviewResponse = prefs.notifInterview;
               _emailMarketing = prefs.notifMarketing;
               _visibilityMode = prefs.companyProfilePublic ? 'public' : 'private';
               _hasInitializedPrefs = true;
             });
           }
         });
      }
    }"""

code = code.replace(build_old, build_new)

# Update employer toggles to call API
toggle_1 = """                  _ToggleTile(
                    label: l10n.newJobApplication,
                    subtitle: l10n.newJobApplicationSubtitle,
                    value: _emailNewJobApplication,
                    onChanged: (v) =>
                        setState(() => _emailNewJobApplication = v),
                  ),"""
toggle_1_new = """                  _ToggleTile(
                    label: l10n.newJobApplication,
                    subtitle: l10n.newJobApplicationSubtitle,
                    value: _emailNewJobApplication,
                    onChanged: (v) {
                        setState(() => _emailNewJobApplication = v);
                        _updateEmployerPref('notif_new_application', v);
                    },
                  ),"""
code = code.replace(toggle_1, toggle_1_new)

toggle_2 = """                  _ToggleTile(
                    label: l10n.candidateMessages,
                    subtitle: l10n.candidateMessagesSubtitle,
                    value: _emailCandidateMessage,
                    onChanged: (v) =>
                        setState(() => _emailCandidateMessage = v),
                  ),"""
toggle_2_new = """                  _ToggleTile(
                    label: l10n.candidateMessages,
                    subtitle: l10n.candidateMessagesSubtitle,
                    value: _emailCandidateMessage,
                    onChanged: (v) {
                        setState(() => _emailCandidateMessage = v);
                        _updateEmployerPref('notif_messages', v);
                    },
                  ),"""
code = code.replace(toggle_2, toggle_2_new)

toggle_3 = """                  _ToggleTile(
                    label: l10n.interviewResponses,
                    subtitle: l10n.interviewResponsesSubtitle,
                    value: _emailInterviewResponse,
                    onChanged: (v) =>
                        setState(() => _emailInterviewResponse = v),
                  ),"""
toggle_3_new = """                  _ToggleTile(
                    label: l10n.interviewResponses,
                    subtitle: l10n.interviewResponsesSubtitle,
                    value: _emailInterviewResponse,
                    onChanged: (v) {
                        setState(() => _emailInterviewResponse = v);
                        _updateEmployerPref('notif_interview', v);
                    },
                  ),"""
code = code.replace(toggle_3, toggle_3_new)

toggle_4 = """                  _ToggleTile(
                    label: l10n.marketingEmails,
                    subtitle: l10n.marketingEmailsSubtitle,
                    value: _emailMarketing,
                    onChanged: (v) => setState(() => _emailMarketing = v),
                  ),"""
toggle_4_new = """                  _ToggleTile(
                    label: l10n.marketingEmails,
                    subtitle: l10n.marketingEmailsSubtitle,
                    value: _emailMarketing,
                    onChanged: (v) {
                       setState(() => _emailMarketing = v);
                       _updateEmployerPref('notif_marketing', v);
                    },
                  ),"""
code = code.replace(toggle_4, toggle_4_new)

visibility = """                UJobRadioCard(
                  title: l10n.publicProfile,
                  subtitle: l10n.publicProfileSubtitle,
                  value: 'public',
                  groupValue: _visibilityMode,
                  onChanged: (v) => setState(() => _visibilityMode = v),
                ),"""
visibility_new = """                UJobRadioCard(
                  title: l10n.publicProfile,
                  subtitle: l10n.publicProfileSubtitle,
                  value: 'public',
                  groupValue: _visibilityMode,
                  onChanged: (v) {
                     setState(() => _visibilityMode = v);
                     _updateEmployerPref('company_profile_public', v == 'public');
                  },
                ),"""
code = code.replace(visibility, visibility_new)

with open("lib/features/shared/settings/settings_screen.dart", "w") as f:
    f.write(code)

