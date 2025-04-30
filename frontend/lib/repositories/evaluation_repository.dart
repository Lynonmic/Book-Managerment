import 'package:frontend/model/evaluation_model.dart';
import 'package:frontend/service/api_service.dart';

class EvaluationRepository {
  List<EvaluationModel> _evaluations = [];
  
  // Get all reviews
  Future<List<dynamic>> getAllReviews() async {
    try {
      final reviews = await ApiService.getAllReviews();
      return reviews;
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }
  
  // Get review by ID
  Future<dynamic> getReviewById(String id) async {
    try {
      return await ApiService.getReviewById(id);
    } catch (e) {
      throw Exception('Failed to fetch review: $e');
    }
  }
  
  // Get reviews by book ID
  Future<List<dynamic>> getReviewsByBookId(String bookId) async {
    try {
      return await ApiService.getReviewsByBookId(bookId);
    } catch (e) {
      throw Exception('Failed to fetch reviews for book: $e');
    }
  }
  
  // Get book average rating
  Future<double> getBookAverageRating(String bookId) async {
    try {
      return await ApiService.getBookAverageRating(bookId);
    } catch (e) {
      throw Exception('Failed to fetch book rating: $e');
    }
  }
  
  // Create a new review
  Future<Map<String, dynamic>> createReview(EvaluationModel review) async {
    try {
      return await ApiService.createReview(review.toJson());
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }
  
  // Update a review
  Future<Map<String, dynamic>> updateReview(String id, EvaluationModel review) async {
    try {
      return await ApiService.updateReview(id, review.toJson());
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }
  
  // Delete a review
  Future<Map<String, dynamic>> deleteReview(String id) async {
    try {
      return await ApiService.deleteReview(id);
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
