import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# First remove the unwanted additions in _NotificationCard
bad_code = """    final featuresAsync = ref.watch(featureFlagsProvider);
    final chatEnabled = featuresAsync.valueOrNull?.chat ?? false;
    
    final tabs = ['all', 'unread', 'application', if (chatEnabled) 'message', 'system'];
    final labels = ['All', 'Unread', 'Applications', if (chatEnabled) 'Messages', 'System'];
"""
text = text.replace(bad_code, "")

# Pass tabs to _buildTabs
text = text.replace("  Widget _buildTabs() {", "  Widget _buildTabs(List<String> labels) {")

# Call _buildTabs(labels)
text = text.replace("_buildTabs(),", "_buildTabs(labels),")

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

