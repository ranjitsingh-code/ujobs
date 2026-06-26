import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Remove appBar
content = re.sub(r"      appBar: AppBar\([\s\S]*?\),\n      body: SingleChildScrollView\(", "      body: SafeArea(\n        child: SingleChildScrollView(", content)
# Add closing parenthesis for SafeArea
content = content.replace("""        ),
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {""", """        ),
      ),
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {""")

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

with open("lib/features/shared/settings/settings_screen.dart", "r") as f:
    content2 = f.read()

# Update settings appbar to show settings back button for employer too
content2 = content2.replace("""      appBar: isEmployer
          ? null
          : UJobAppBar(
              title: l10n.settings,
              showBack: true,
              backgroundColor: AppColors.background,
            ),""", """      appBar: UJobAppBar(
        title: l10n.settings,
        showBack: true,
        backgroundColor: AppColors.background,
      ),""")

content2 = content2.replace("""      body: SafeArea(
        top: isEmployer,""", """      body: SafeArea(
        top: false,""")

with open("lib/features/shared/settings/settings_screen.dart", "w") as f:
    f.write(content2)

