import re

with open('lib/features/shared/settings/settings_screen.dart', 'r') as f:
    text = f.read()

target = """            if (isEmployer) ...[
              SizedBox(height: 24.h),
              _SectionTitle('BILLING'),"""
replacement = """            if (isEmployer && featureFlags?.plansWallet == true) ...[
              SizedBox(height: 24.h),
              _SectionTitle('BILLING'),"""

text = text.replace(target, replacement)

with open('lib/features/shared/settings/settings_screen.dart', 'w') as f:
    f.write(text)

