import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Fix _borderColor
border_target = """  Color _borderColor(String type, Color defaultColor) => switch (type) {
    'application' => const Color(0xFF0D9488),
    'job' => const Color(0xFF8B5CF6),
    'message' => const Color(0xFF3B82F6),
    _ => defaultColor,
  };"""
border_replacement = """  Color _borderColor(String type, Color defaultColor) => switch (type) {
    'application' || 'new_application' => const Color(0xFF0D9488),
    'job' || 'job_approved' => const Color(0xFF8B5CF6),
    'message' => const Color(0xFF3B82F6),
    _ => defaultColor,
  };"""
text = text.replace(border_target, border_replacement)

# Fix _iconFor
icon_target = """  dynamic _iconFor(String type) => switch (type) {
    'application' => HugeIcons.strokeRoundedNote01,
    'job' => HugeIcons.strokeRoundedBriefcase02,
    'message' => HugeIcons.strokeRoundedMessage01,
    _ => HugeIcons.strokeRoundedNotification01,
  };"""
icon_replacement = """  dynamic _iconFor(String type) => switch (type) {
    'application' || 'new_application' => HugeIcons.strokeRoundedNote01,
    'job' || 'job_approved' => HugeIcons.strokeRoundedBriefcase02,
    'message' => HugeIcons.strokeRoundedMessage01,
    _ => HugeIcons.strokeRoundedNotification01,
  };"""
text = text.replace(icon_target, icon_replacement)

# Fix onTap routing
routing_target = """                                      } else if (n.type == 'application') {"""
routing_replacement = """                                      } else if (n.type == 'application' || n.type == 'new_application') {"""
text = text.replace(routing_target, routing_replacement)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

