import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

pattern = re.compile(r"    return Scaffold\([\s\S]*?padding: EdgeInsets\.fromLTRB\(20\.w, 0, 20\.w, 24\.h\),", re.MULTILINE)

new_code = """    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompanyProfileHeader(
              company: company, 
              completeness: completeness,
              onEditLogo: () => _showEditCompanyInfo(context, ref, company),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),"""

text = pattern.sub(new_code, text)

# Now I must re-add the removed closing brackets at the end!
old_end = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

new_end = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

# Wait, they were already 7 closing brackets. And since I just simplified the Scaffold, it only needs:
# 1. inner Column children ]
# 2. inner Column )
# 3. Padding )
# 4. outer Column children ]
# 5. outer Column )
# 6. SingleChildScrollView )
# 7. Scaffold )
# So 7 closing brackets is EXACTLY right for the NEW structure! I don't need to change the end at all, it's already 7 brackets because I removed the extra ones earlier.

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
