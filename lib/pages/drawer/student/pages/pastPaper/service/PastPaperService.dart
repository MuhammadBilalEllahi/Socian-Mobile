import 'package:beyondtheclass/shared/services/api_client.dart';

class PastPaperService {
  final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>> getPastPapersInSubject(String id) async {
    final response = await apiClient.get('/api/pastpapers/all-pastpapers-in-subject/$id');
    return response.data;
    }

    Future<Map<String, dynamic>> getTypeOfPastPaper(String subjectId, String type) async {
      final response = await apiClient.get('/api/pastpapers/$type/$subjectId');
    return response.data;
    }

    Future<Map<String, dynamic>> uploadNewPastpaper(String subjectId, String type, String category, String term, String year, String file) async {
      final response = await apiClient.post('/api/pastpapers/upload', {
        'subjectId': subjectId,
        'type': type,
        'category': category,
        'term': term,
        'year': year,
        'file': file,
        });
    return response;
    }

}
