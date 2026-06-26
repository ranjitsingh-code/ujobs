import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Fix unused import
text = text.replace("import '../../../core/widgets/ujob_loading.dart';\n", "")

# Fix curly braces in flow control structures
text = re.sub(r'if \((.*?)\)\n\s+(_selectedIds.*?);', r'if (\1) {\n                                      \2;\n                                    }', text)
text = re.sub(r'if \((.*?)\)\n\s+(_showSingleNotifOptions.*?);', r'if (\1) {\n                                      \2;\n                                    }', text)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

