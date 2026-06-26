import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Remove the computation in build
build_target = """  Widget build(BuildContext context) {
    final featuresAsync = ref.watch(featureFlagsProvider);
    final chatEnabled = featuresAsync.valueOrNull?.chat ?? false;
    
    final tabs = ['all', 'unread', 'application', if (chatEnabled) 'message', 'system'];
    final labels = ['All', 'Unread', 'Applications', if (chatEnabled) 'Messages', 'System'];"""

build_replacement = """  Widget build(BuildContext context) {"""
text = text.replace(build_target, build_replacement)

# Add getters instead
getter_code = """
  List<String> get _currentTabs {
    final featuresAsync = ref.watch(featureFlagsProvider);
    final chatEnabled = featuresAsync.valueOrNull?.chat ?? false;
    return ['all', 'unread', 'application', if (chatEnabled) 'message', 'system'];
  }

  List<String> get _currentLabels {
    final featuresAsync = ref.watch(featureFlagsProvider);
    final chatEnabled = featuresAsync.valueOrNull?.chat ?? false;
    return ['All', 'Unread', 'Applications', if (chatEnabled) 'Messages', 'System'];
  }
"""

text = text.replace("  void _toggleSelectionMode() {", getter_code + "\n  void _toggleSelectionMode() {")

# Replace undefined variables with getters
text = text.replace("tabs.length", "_currentTabs.length")
text = text.replace("tabs[pageIndex]", "_currentTabs[pageIndex]")
text = text.replace("_buildTabs(labels)", "_buildTabs()")
text = text.replace("Widget _buildTabs(List<String> labels) {", "Widget _buildTabs() {")
text = text.replace("tabs: labels", "tabs: _currentLabels")

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

