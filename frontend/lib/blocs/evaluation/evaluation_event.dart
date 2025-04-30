import 'package:equatable/equatable.dart';
import 'package:frontend/model/evaluation_model.dart';

abstract class EvaluationEvent extends Equatable {
  const EvaluationEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllReviews extends EvaluationEvent {}

class LoadReviewById extends EvaluationEvent {
  final String id;

  const LoadReviewById(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadReviewsByBookId extends EvaluationEvent {
  final String bookId;

  const LoadReviewsByBookId(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class LoadBookAverageRating extends EvaluationEvent {
  final String bookId;

  const LoadBookAverageRating(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class CreateReview extends EvaluationEvent {
  final EvaluationModel review;
  final String? bookId; // Optional bookId to refresh reviews for a specific book

  const CreateReview(this.review, {this.bookId});

  @override
  List<Object?> get props => [review, bookId];
}

class UpdateReview extends EvaluationEvent {
  final String id;
  final EvaluationModel review;
  final String? bookId; // Optional bookId to refresh reviews for a specific book

  const UpdateReview(this.id, this.review, {this.bookId});

  @override
  List<Object?> get props => [id, review, bookId];
}

class DeleteReview extends EvaluationEvent {
  final String id;
  final String? bookId; // Optional bookId to refresh reviews for a specific book

  const DeleteReview(this.id, {this.bookId});

  @override
  List<Object?> get props => [id, bookId];
}
