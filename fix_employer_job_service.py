import re

with open("lib/features/employer/jobs/employer_job_service.dart", "r") as f:
    content = f.read()

old_method = """  Future<List<Job>> getMyJobs({
    String? status,
    int limit = 20,
    int page = 1,
  }) async {
    final queryParams = {'status': ?status, 'limit': limit, 'page': page};

    final res = await _client.dio.get(
      Ep.employerJobs,
      queryParameters: queryParams,
    );
    final data = res.data['data'] as List;
    return data.map((json) => Job.fromJson(json)).toList();
  }"""

new_method = """  Future<List<Job>> getMyJobs({
    String? status,
    int limit = 20,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'page': page,
    };
    if (status != null && status != 'all' && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final res = await _client.dio.get(
      Ep.employerJobs,
      queryParameters: queryParams,
    );
    final data = res.data['data'] as List;
    return data.map((json) => Job.fromJson(json as Map<String, dynamic>)).toList();
  }"""

if old_method in content:
    content = content.replace(old_method, new_method)
    with open("lib/features/employer/jobs/employer_job_service.dart", "w") as f:
        f.write(content)
    print("Success")
else:
    print("Not found")
