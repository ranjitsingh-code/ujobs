import os

file_path = 'lib/features/seeker/jobs/find_jobs_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Remove the Scaffold's appBar property
scaffold_start = content.find('return Scaffold(')
if scaffold_start != -1:
    appbar_start = content.find('appBar: UJobAppBar(', scaffold_start)
    appbar_end = content.find('),', appbar_start) + 2
    if appbar_start != -1 and appbar_start < content.find('body: DefaultTabController', scaffold_start):
        content = content[:appbar_start] + content[appbar_end:].lstrip()

# 2. Add the SliverAppBar for "Find Jobs" inside headerSliverBuilder
header_builder_start = content.find('headerSliverBuilder: (context, innerBoxIsScrolled) {')
if header_builder_start != -1:
    return_array_start = content.find('return [', header_builder_start) + len('return [')
    
    find_jobs_sliver = """
              SliverAppBar(
                backgroundColor: AppColors.surface,
                pinned: true,
                floating: false,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  l10n.findJobs,
                  style: AppText.bodyBold.copyWith(
                    color: AppColors.text,
                    fontSize: 18.sp,
                  ),
                ),
              ),"""
    
    content = content[:return_array_start] + find_jobs_sliver + content[return_array_start:]

with open(file_path, 'w') as f:
    f.write(content)
print("Rewrote FindJobsScreen to put Find Jobs header inside NestedScrollView!")
