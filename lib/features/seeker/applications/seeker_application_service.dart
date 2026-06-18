import '../../../core/api/dio_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/application.dart';

class SeekerApplicationService {
  final DioClient _client;
  SeekerApplicationService(this._client);

  Future<List<Application>> getMyApplications({String? status, int limit = 20, int page = 1}) async {
    final queryParams = {
      if (status != null) 'status': status,
      'limit': limit,
      'page': page,
    };

    final res = await _client.dio.get(Ep.seekerApplications, queryParameters: queryParams);
    final data = res.data['data'] as List;
    return data.map((json) => Application.fromJson(json)).toList();
  }

  Future<Application> applyToJob({
    required int jobId,
    String? coverLetter,
    String? resumePath,
  }) async {
    final data = {
      'job_id': jobId,
      if (coverLetter != null) 'cover_letter': coverLetter,
      // Resume upload logic usually requires FormData, skipping for now
    };

    final res = await _client.dio.post(Ep.seekerApplications, data: data);
    return Application.fromJson(res.data['data']);
  }
}
