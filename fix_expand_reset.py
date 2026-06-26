import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Add _refreshKey to state
content = content.replace("  bool _showContactInfo = false;", "  bool _showContactInfo = false;\n  int _refreshKey = 0;")

# Update _onRefresh to increment _refreshKey
old_on_refresh = """        ref.read(companyProfileProvider.notifier).state =
            CompanyProfile.fromJson(companyData);
        _initFromProvider();
      }
    } catch (e) {"""

new_on_refresh = """        ref.read(companyProfileProvider.notifier).state =
            CompanyProfile.fromJson(companyData);
        _initFromProvider();
        if (mounted) setState(() => _refreshKey++);
      }
    } catch (e) {"""

content = content.replace(old_on_refresh, new_on_refresh)

# Wrap Column with ValueKey(_refreshKey)
old_column = """          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CompanyProfileHeader("""

new_column = """          child: Column(
            key: ValueKey(_refreshKey),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CompanyProfileHeader("""

content = content.replace(old_column, new_column)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

