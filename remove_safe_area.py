import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Replace SafeArea with just SingleChildScrollView
old_safe_area = """    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView("""

new_no_safe_area = """    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView("""

content = content.replace(old_safe_area, new_no_safe_area)

# Also remove the extra closing parenthesis that belonged to SafeArea
old_end = """        ),
      ),
    );
  }
}

class _SectionCard"""

new_end = """        ),
    );
  }
}

class _SectionCard"""

content = content.replace(old_end, new_end)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

