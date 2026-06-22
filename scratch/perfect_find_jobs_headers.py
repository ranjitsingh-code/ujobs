import os

file_path = 'lib/features/seeker/jobs/find_jobs_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

start_idx = content.find('headerSliverBuilder: (context, innerBoxIsScrolled) {')
end_idx = content.find('body: PageView', start_idx)

if start_idx != -1 and end_idx != -1:
    old_block = content[start_idx:end_idx]
    
    new_block = """headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                floating: false,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Text(
                  l10n.findJobs,
                  style: AppText.bodyBold.copyWith(
                    color: AppColors.text,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              SliverAppBar(
                primary: false,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                pinned: false,
                floating: true,
                snap: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 80.h,
                titleSpacing: 0,
                title: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: UJobTextField(
                          label: '',
                          hint: 'Search jobs, skills...',
                          controller: _searchController,
                          prefix: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.muted, size: 20.r),
                          ),
                          onChanged: (_) {},
                        ),
                      ),
                      if (_tabIndex == 1) ...[
                        SizedBox(width: 12.w),
                        Container(
                          height: 56.h,
                          width: 56.w,
                          decoration: BoxDecoration(
                            color: AppColors.seekPrimary,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: IconButton(
                            icon: HugeIcon(icon: HugeIcons.strokeRoundedFilterHorizontal, color: AppColors.surface, size: 24.r),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => const _FilterSheet(),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverAppBar(
                primary: false,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                floating: false,
                elevation: innerBoxIsScrolled ? 1 : 0,
                scrolledUnderElevation: innerBoxIsScrolled ? 1 : 0,
                forceElevated: innerBoxIsScrolled,
                shadowColor: AppColors.borderLight,
                toolbarHeight: 0, // No title
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(68.h),
                  child: Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                    child: UJobPillTabBar(
                      tabs: const ['For You', 'All Jobs'],
                      selectedIndex: _tabIndex,
                      onTabSelected: (index) {
                        _pageCtrl.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          """
    
    content = content.replace(old_block, new_block)
    
    with open(file_path, 'w') as f:
        f.write(content)
    print("Rewrote FindJobsScreen headers with perfect spacing and styling!")
else:
    print("Could not find boundaries")
