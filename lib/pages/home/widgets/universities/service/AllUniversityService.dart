import 'package:socian/shared/services/api_client.dart';
import 'package:flutter/material.dart';

class AllUniversityService {
  static final ApiClient apiClient = ApiClient();
  
  static Future<List<Map<String, dynamic>>> getAllUniversityPosts() async {
    final response = await apiClient.getList('/api/posts/universities/all');

    debugPrint("[AllUniversityService] response: $response");
    return response.map((item) => item as Map<String, dynamic>).toList();
  }

  static Future<void> votePost(String postId, String voteType) async {
    final response = await apiClient.post('/api/posts/vote-post', {
      'postId': postId,
      'voteType': voteType,
    });
  }

  static Future<Map<String, dynamic>> getSinglePost(String postId) async {
    final response = await apiClient.get('/api/posts/single/post?postId=$postId');
    return response;
  }

  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final response = await apiClient.get('/api/posts/post/comments?postId=$postId');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> repliesComments(String commentId) async {
    final response = await apiClient.get('/api/posts/post/comment/replies?commentId=$commentId');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> createComment(String postId, String comment) async {
    final response = await apiClient.post('/api/posts/post/comment', {
      'postId': postId,
      'comment': comment,
    });
    return response;
  }

  static Future<Map<String, dynamic>> replyToComment(String postId, String commentId, String reply) async {
    final response = await apiClient.post('/api/posts/post/reply/comment', {
      'postId': postId,
      'commentId': commentId,
      'reply': reply,
    });
    return response;
  }

  static Future<Map<String, dynamic>> voteComment(String commentId, String voteType) async {
    final response = await apiClient.post('/api/posts/post/comment/vote', {
      'commentId': commentId,
      'voteType': voteType,
    });
    return response;
  }
  
  static Future<Map<String, dynamic>> deleteComment(String commentId) async {
    final response = await apiClient.delete('/api/posts/post/comment?commentId=$commentId');
    return response;
  }

  static Future<Map<String, dynamic>> deleteReply(String replyId) async {
    final response = await apiClient.delete('/api/posts/post/reply/comment?replyId=$replyId');
    return response;
  }

  static Future<Map<String, dynamic>> updateComment(String commentId, String comment) async {
    final response = await apiClient.patch('/api/posts/post/comment', {
      'commentId': commentId,
      'comment': comment,
    });
    return response;
  }
  // can post without title and body if repostWithoutTitleAndBody is true
  static Future<Map<String, dynamic>> repostPersonalPost(String postId, String title, String body, {bool repostWithoutTitleAndBody = false}) async {
    final response = await apiClient.post('/api/posts/post/repost/personal', {
      'postId': postId,
      'title': title,
      'body': body,
      'repostWithoutTitleAndBody': repostWithoutTitleAndBody,
    });
    return response;
  }

  // can post without title and body if repostWithoutTitleAndBody is true
  static Future<Map<String, dynamic>> repostSocietyPost(String postId, String title, String body, String societyId, bool postInSameSociety, {bool repostWithoutTitleAndBody = false}) async {
    final response = await apiClient.post('/api/posts/post/repost/society', {
      'postId': postId,
      'title': title,
      'body': body,
      'repostWithoutTitleAndBody': repostWithoutTitleAndBody,
      'societyId': postInSameSociety ? null :  societyId,
    });
    return response;
  }

}