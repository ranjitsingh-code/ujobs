import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Remove static const _tabs and _labels
text = re.sub(r'  static const _tabs = \[.*?\];\n', '', text, flags=re.DOTALL)
text = re.sub(r'  static const _labels = \[\n.*?  \];\n', '', text, flags=re.DOTALL)

# Add import for featureFlagsProvider if missing
if 'feature_flags_provider.dart' not in text:
    text = text.replace(
        "import 'notifications_provider.dart';",
        "import 'notifications_provider.dart';\nimport '../../../core/providers/feature_flags_provider.dart';"
    )

# Compute tabs and labels in build
build_target = "  Widget build(BuildContext context) {"
build_replacement = """  Widget build(BuildContext context) {
    final featuresAsync = ref.watch(featureFlagsProvider);
    final chatEnabled = featuresAsync.valueOrNull?.chat ?? false;
    
    final tabs = ['all', 'unread', 'application', if (chatEnabled) 'message', 'system'];
    final labels = ['All', 'Unread', 'Applications', if (chatEnabled) 'Messages', 'System'];
"""

text = text.replace(build_target, build_replacement)

# Replace _tabs and _labels usages with tabs and labels
text = text.replace("_tabs.length", "tabs.length")
text = text.replace("_tabs[pageIndex]", "tabs[pageIndex]")
text = text.replace("tabs: _labels", "tabs: labels")

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

