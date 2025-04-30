import 'package:equatable/equatable.dart';

enum EvaluationStatus { initial, loading, loaded, error }

class EvaluationState extends Equatable {
  final List<dynamic> reviews;
  final List<dynamic> bookReviews;
  final dynamic selectedReview;
  final double? bookAverageRating;
  final EvaluationStatus status;
  final String? errorMessage;

  const EvaluationState({
    this.reviews = const [],
    this.bookReviews = const [],
    this.selectedReview,
    this.bookAverageRating,
    this.status = EvaluationStatus.initial,
    this.errorMessage,
  });

  EvaluationState copyWith({
    List<dynamic>? reviews,
    List<dynamic>? bookReviews,
    dynamic selectedReview,
    double? bookAverageRating,
    EvaluationStatus? status,
    String? errorMessage,
  }) {
    return EvaluationState(
      reviews: reviews ?? this.reviews,
      bookReviews: bookReviews ?? this.bookReviews,
      selectedReview: selectedReview ?? this.selectedReview,
      bookAverageRating: bookAverageRating ?? this.bookAverageRating,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [reviews, bookReviews, selectedReview, bookAverageRating, status, errorMessage];
}
