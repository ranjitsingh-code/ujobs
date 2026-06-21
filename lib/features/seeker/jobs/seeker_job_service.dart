import '../../../core/api/dio_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/job.dart';

class SeekerJobService {
  final DioClient _client;
  SeekerJobService(this._client);

  Future<List<Job>> getJobs({
    String? search,
    String? category,
    String? employmentType,
    String? workplaceType,
    String? experienceLevel,
    int? salaryMin,
    int limit = 20,
    int page = 1,
  }) async {
    final queryParams = {
      'search': ?search,
      'category': ?category,
      'employment_type': ?employmentType,
      'workplace_type': ?workplaceType,
      'experience_level': ?experienceLevel,
      'salary_min': ?salaryMin,
      'limit': limit,
      'page': page,
    };

    final res = await _client.dio.get(
      Ep.publicJobs,
      queryParameters: queryParams,
    );
    final data = res.data['data'] as List;
    return data.map((json) => Job.fromJson(json)).toList();
  }

  Future<Job> getJobDetails(int id) async {
    final res = await _client.dio.get('${Ep.publicJobs}/$id');
    return Job.fromJson(res.data['data']);
  }

  Future<void> saveJob(int id) async {
    await _client.dio.post(Ep.saveJob(id.toString()));
  }

  Future<void> unsaveJob(int id) async {
    // API might not have a dedicated unsave, or it might be same as save (toggle)
    // Based on Ep, we only have saveJob. Let's assume it's a toggle or check if delete exists.
    // Actually Ep doesn't have unsaveJob. I'll stick to what Ep provides.
    await _client.dio.delete(Ep.saveJob(id.toString()));
  }

  Future<Map<String, dynamic>> getApplicationStatus(int id) async {
    final res = await _client.dio.get(Ep.appStatus(id.toString()));
    return res.data['data'] as Map<String, dynamic>;
  }
}
