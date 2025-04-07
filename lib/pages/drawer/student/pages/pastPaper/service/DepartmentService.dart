import 'package:beyondtheclass/shared/services/api_client.dart';

class DepartmentService {
  final ApiClient apiClient = ApiClient();


  getDepartmentsForSpecificCampus() async {
    final response = await apiClient.get('/api/departments/campus/subjects');
    return response;
  }

  getPastpapersInSubject(String subjectId) async {
    final response = await apiClient.get('/api/pastpaper/all-pastpapers-in-subject/$subjectId');
    return response;
  }


  createOrGetPastpaperItemWithComments(String toBeDisccusedId) async {
    final response = await apiClient.post('/api/pastpapers/create-get?toBeDisccusedId=$toBeDisccusedId', {});
    return response;
  }

  getTypesOfPastpaper(String type,String subjectId) async {
    final response = await apiClient.get('/api/pastpapers/$type/$subjectId');
    return response;
  }

  addCommentToPastpaperItem(String toBeDisccusedId, String commentContent, String type) async {
    final response = await apiClient.post('/api/pastpapers/comment/add-comment', {
      'toBeDisccusedId': toBeDisccusedId,
      'commentContent': commentContent,
      'type': type,
    });
    return response;
  }

  replyToComment(String commentId, String replyContent) async {
    final response = await apiClient.post('/api/pastpapers/comment/reply', {
      'commentId': commentId,
      'replyContent': replyContent,
    });
    return response;
  }


  // updateCommentTag(String commentId, String questionNumber, String part, String isAnswer) async {
  //   final response = await apiClient.post('/api/pastpapers/comment/update-tag', {
  //     'commentId': commentId,
  //     'questionNumber': questionNumber,
  //   });   
  //   return response;
  // }

  getAnswersForSpecificQuestion(String commentId, String questionNumber, String part) async {
    final response = await apiClient.get('/api/pastpapers/comment/answers/$commentId?questionNumber=$questionNumber&part=$part');
    return response;
  }
  

  deleteComment(String commentId) async {
    final response = await apiClient.delete('/api/pastpapers/comment/$commentId');
    return response;
  }

  getExistingQuestionTags(String discussionId) async {
    final response = await apiClient.get('/api/pastpapers/comment/tags/$discussionId');
    return response;
  }

  voteOnComment(String commentId, String voteType) async {
    final response = await apiClient.post('/api/pastpapers/comment/vote', {
      'commentId': commentId,
      'voteType': voteType,
    });
    return response;
  }

  getPaginatedComments(String discussionId, int page, int limit) async {
    final response = await apiClient.get('/api/pastpapers/comments/$discussionId?page=$page&limit=$limit');
    return response;
  }

  getPaginatedReplies(String commentId, int page, int limit) async {
    final response = await apiClient.get('/api/pastpapers/replies/$commentId?page=$page&limit=$limit');
    return response;
  }


}
