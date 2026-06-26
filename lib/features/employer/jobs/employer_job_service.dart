import '../../../core/api/dio_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/job.dart';

class EmployerJobService {
  final DioClient _client;
  EmployerJobService(this._client);

  Future<List<Job>> getMyJobs({
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
  }

  Future<Job> postJob(Map<String, dynamic> jobData) async {
    final res = await _client.dio.post(Ep.employerJobs, data: jobData);
    return Job.fromJson(res.data['data']);
  }

  Future<Job> getJobDetails(int id) async {
    final res = await _client.dio.get('${Ep.employerJobs}/$id');
    return Job.fromJson(res.data['data']);
  }

  Future<Job> updateJob(int id, Map<String, dynamic> jobData) async {
    final res = await _client.dio.put('${Ep.employerJobs}/$id', data: jobData);
    return Job.fromJson(res.data['data']);
  }

  Future<void> updateJobStatus(int id, String status) async {
    await _client.dio.patch('${Ep.employerJobs}/$id/status', data: {'status': status});
  }

  Future<void> deleteJob(int id) async {
    await _client.dio.delete('${Ep.employerJobs}/$id');
  }
}
