import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

target_start = """        data: (applicant) => Column(
        children: [
          Expanded(
            child: NestedScrollView("""

replacement_start = """        data: (applicant) => Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(singleApplicantProvider(initialApplicant));
                try {
                  await ref.read(singleApplicantProvider(initialApplicant).future);
                } catch (_) {}
              },
              child: NestedScrollView("""

# Find the end of NestedScrollView which ends exactly before `          ), // End of Expanded`
# Let's locate the end of NestedScrollView. 
# It's inside an Expanded.
target_end = """              ),
            ),
          ),
          
          // Sticky Bottom Action Bar"""

replacement_end = """              ),
            ),
            ),
          ),
          
          // Sticky Bottom Action Bar"""

if target_start in text:
    text = text.replace(target_start, replacement_start)
    if target_end in text:
        text = text.replace(target_end, replacement_end)
        with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
            f.write(text)
        print("Success")
    else:
        print("End target not found")
else:
    print("Start target not found")

