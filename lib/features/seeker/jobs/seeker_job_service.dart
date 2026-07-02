import 'package:flutter/foundation.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/job.dart';

class SeekerJobService {
  final DioClient _client;
  SeekerJobService(this._client);

  Future<List<Job>> getJobs({
    String? search,
    int? categoryId,
    String? employmentType,
    String? workplaceType,
    String? experienceLevel,
    String? salaryRange,
    String? datePosted,
    String? sort,
    String? location,
    int? companyId,
    int limit = 20,
    int page = 1,
  }) async {
    final queryParams = {
      if (search != null && search.isNotEmpty) 'search': search,
      'category_id': ?categoryId,
      if (employmentType != null && employmentType.isNotEmpty) 'employment_type': employmentType,
      if (workplaceType != null && workplaceType.isNotEmpty) 'workplace_type': workplaceType,
      if (experienceLevel != null && experienceLevel.isNotEmpty) 'experience_level': experienceLevel,
      if (salaryRange != null && salaryRange.isNotEmpty) 'salary_range': salaryRange,
      if (datePosted != null && datePosted.isNotEmpty) 'date_posted': datePosted,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
      if (location != null && location.isNotEmpty) 'location': location,
      'company_id': ?companyId,
      'limit': limit,
      'page': page,
    };

    debugPrint('--- SEEKER ALL JOBS API QUERY PARAMS ---');
    debugPrint('$queryParams');
    debugPrint('----------------------------------------');

    final res = await _client.dio.get(
      '/seeker/all-jobs',
      queryParameters: queryParams,
    );
    final data = res.data['data'] as List;
    return data.map((json) => Job.fromJson(json)).toList();
  }

  Future<Job> getJobDetails(int id) async {
    final res = await _client.dio.get('${Ep.seekerJobs}/$id');
    return Job.fromJson(res.data['data']);
  }

  Future<void> applyJob(
    int jobId, {
    String? resumeId,
    String? coverLetter,
    List<Map<String, dynamic>>? answers,
  }) async {
    final payload = <String, dynamic>{};
    if (resumeId != null) payload['resume_id'] = resumeId;
    if (coverLetter != null && coverLetter.isNotEmpty) payload['cover_letter'] = coverLetter;
    if (answers != null && answers.isNotEmpty) payload['answers'] = answers;

    await _client.dio.post(
      '${Ep.seekerJobs}/$jobId/apply',
      data: payload,
    );
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
