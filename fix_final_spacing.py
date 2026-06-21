import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Remove SizedBox(height: 24.h) in CompanyProfileHeader
old_header = """  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Stack("""

new_header = """  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          Stack("""
text = text.replace(old_header, new_header)

# 2. Reduce the gap between header and child to 0 when expanded
old_inkwell_padding = "padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, _isExpanded ? 12.r : 20.r),"
new_inkwell_padding = "padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, _isExpanded ? 0 : 20.r),"
text = text.replace(old_inkwell_padding, new_inkwell_padding)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
