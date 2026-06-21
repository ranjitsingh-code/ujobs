import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Add onEditLogo to CompanyProfileHeader
old_header_def = """class CompanyProfileHeader extends StatelessWidget {
  final CompanyProfile company;
  final double completeness;

  const CompanyProfileHeader({super.key, required this.company, required this.completeness});"""

new_header_def = """class CompanyProfileHeader extends StatelessWidget {
  final CompanyProfile company;
  final double completeness;
  final VoidCallback onEditLogo;

  const CompanyProfileHeader({super.key, required this.company, required this.completeness, required this.onEditLogo});"""
text = text.replace(old_header_def, new_header_def)

# 2. Add GestureDetector to the camera icon inside CompanyProfileHeader
old_camera_icon = """                  Positioned(
                    bottom: -4.r,
                    right: -4.r,
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: Center(
                        child: Icon(Icons.camera_alt_outlined, size: 16.r, color: AppColors.primary),
                      ),
                    ),
                  ),"""

new_camera_icon = """                  Positioned(
                    bottom: -4.r,
                    right: -4.r,
                    child: GestureDetector(
                      onTap: onEditLogo,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: Center(
                          child: Icon(Icons.camera_alt_outlined, size: 16.r, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),"""
text = text.replace(old_camera_icon, new_camera_icon)

# 3. Pass the callback from the Screen state
old_header_call = """CompanyProfileHeader(company: company, completeness: completeness),"""
new_header_call = """CompanyProfileHeader(
              company: company, 
              completeness: completeness,
              onEditLogo: () => _showEditCompanyInfo(context, ref, company),
            ),"""
text = text.replace(old_header_call, new_header_call)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
