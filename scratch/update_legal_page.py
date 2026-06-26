import re

with open('lib/features/shared/legal/legal_page_screen.dart', 'r') as f:
    content = f.read()

orig_enum = """enum LegalPageType {
  terms('terms-and-conditions'),
  privacy('privacy-policy');"""
new_enum = """enum LegalPageType {
  terms('terms-and-conditions'),
  privacy('privacy-policy'),
  about('about-us');"""
content = content.replace(orig_enum, new_enum)

orig_fallback = """    final fallbackTitle = type == LegalPageType.terms
        ? l10n.termsAndConditions
        : l10n.privacyPolicy;"""
new_fallback = """    final fallbackTitle = switch (type) {
      LegalPageType.terms => l10n.termsAndConditions,
      LegalPageType.privacy => l10n.privacyPolicy,
      LegalPageType.about => 'About Us',
    };"""
content = content.replace(orig_fallback, new_fallback)

with open('lib/features/shared/legal/legal_page_screen.dart', 'w') as f:
    f.write(content)
