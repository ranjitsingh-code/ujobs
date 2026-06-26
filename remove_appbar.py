import re

with open('lib/features/employer/applicants/applicants_screen.dart', 'r') as f:
    text = f.read()

target = """    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Applicants', showBack: false),
      body: asyncApplicants.when("""

replacement = """    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: asyncApplicants.when("""

text = text.replace(target, replacement)

target2 = """          }).toList(),
        ),
      );
        }
      ),
    );
  }
}"""

replacement2 = """          }).toList(),
        ),
      );
        }
      ),
      ),
    );
  }
}"""

text = text.replace(target2, replacement2)

with open('lib/features/employer/applicants/applicants_screen.dart', 'w') as f:
    f.write(text)
