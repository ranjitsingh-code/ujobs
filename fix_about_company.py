import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Make sure to import the rich text editor if not already there
if "ujob_rich_text_editor.dart" not in content:
    content = content.replace("import '../../../core/widgets/ujob_text_field.dart';", "import '../../../core/widgets/ujob_text_field.dart';\nimport '../../../core/widgets/ujob_rich_text_editor.dart';")

# Find the old UJobTextField for About Company
old_about = """                          UJobTextField(
                            label: "About Company",
                            controller: _aboutController,
                            maxLines: 4,
                          ),"""

new_about = """                          UJobTextField(
                            label: "About Company",
                            hint: context.l10n.tapToOpenEditor,
                            readOnly: true,
                            maxLines: 4,
                            minLines: 4,
                            controller: TextEditingController(
                              text: getPlainTextFromQuillJson(_aboutController.text),
                            ),
                            labelTrailing: HugeIcon(
                              icon: HugeIcons.strokeRoundedMaximize01,
                              color: AppColors.primary,
                              size: 20.r,
                            ),
                            onTap: () => showUJobRichTextEditor(
                              context: context,
                              title: 'About Company',
                              initialValue: _aboutController.text,
                              onSave: (val) {
                                setState(() {
                                  _aboutController.text = val;
                                });
                              },
                            ),
                          ),"""

content = content.replace(old_about, new_about)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

