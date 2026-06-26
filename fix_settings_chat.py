import re

with open('lib/features/shared/settings/settings_screen.dart', 'r') as f:
    text = f.read()

target = """                  _ToggleTile(
                    label: l10n.candidateMessages,
                    subtitle: l10n.candidateMessagesSubtitle,
                    value: _emailCandidateMessage,
                    onChanged: (v) {
                        setState(() => _emailCandidateMessage = v);
                        _updateEmployerPref('notif_messages', v);
                    },
                  ),"""

replacement = """                  if (featureFlags?.chat == true)
                    _ToggleTile(
                      label: l10n.candidateMessages,
                      subtitle: l10n.candidateMessagesSubtitle,
                      value: _emailCandidateMessage,
                      onChanged: (v) {
                          setState(() => _emailCandidateMessage = v);
                          _updateEmployerPref('notif_messages', v);
                      },
                    ),"""

text = text.replace(target, replacement)

with open('lib/features/shared/settings/settings_screen.dart', 'w') as f:
    f.write(text)

