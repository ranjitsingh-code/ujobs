import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

# Replace instantiation
text = text.replace(
    "_NotificationButton(onTap: onNotificationsTap)",
    "UJobNotificationButton(onTap: onNotificationsTap, borderColor: AppColors.primary)"
)

# Import UJobNotificationButton if missing
if "ujob_notification_button.dart" not in text:
    text = text.replace(
        "import '../../../core/widgets/ujob_avatar.dart';",
        "import '../../../core/widgets/ujob_avatar.dart';\nimport '../../../core/widgets/ujob_notification_button.dart';"
    )

# Remove _NotificationButton class
text = re.sub(r'class _NotificationButton extends StatelessWidget \{.*?\n\}\n', '', text, flags=re.DOTALL)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)

