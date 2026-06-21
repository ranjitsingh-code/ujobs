with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_header_avatar = """              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.lg,
                ),
                child: Center(
                  child: Text(
                    company.name.isNotEmpty ? company.name[0].toUpperCase() : 'A',
                    style: AppText.heading1.copyWith(color: AppColors.white),
                  ),
                ),
              ),"""

new_header_avatar = """              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.lg,
                ),
                clipBehavior: Clip.hardEdge,
                child: company.logo != null && company.logo!.isNotEmpty
                    ? (company.logo!.startsWith('http') 
                        ? Image.network(company.logo!, fit: BoxFit.cover)
                        : Image.file(File(company.logo!), fit: BoxFit.cover))
                    : Center(
                        child: Text(
                          company.name.isNotEmpty ? company.name[0].toUpperCase() : 'A',
                          style: AppText.heading1.copyWith(color: AppColors.white),
                        ),
                      ),
              ),"""

text = text.replace(old_header_avatar, new_header_avatar)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
