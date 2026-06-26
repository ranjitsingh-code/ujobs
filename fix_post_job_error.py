import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

target = """    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) UJobToast.error(context, 'Failed to save job. Please try again.');
    }"""
replacement = """    } catch (e) {
      EasyLoading.dismiss();
      String errorMsg = 'Failed to save job. Please try again.';
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'];
        }
      }
      print('Post Job Error: $e');
      if (mounted) UJobToast.error(context, errorMsg);
    }"""

text = text.replace(target, replacement)
if "import 'package:dio/dio.dart';" not in text:
    text = text.replace("import '../../../core/api/dio_client.dart';", "import '../../../core/api/dio_client.dart';\nimport 'package:dio/dio.dart';")

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

