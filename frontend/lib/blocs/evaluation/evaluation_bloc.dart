import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/evaluation/evaluation_event.dart';
import 'package:frontend/blocs/evaluation/evaluation_state.dart';
import 'package:frontend/model/evaluation_model.dart';
import 'package:frontend/repositories/evaluation_repository.dart';

class EvaluationBloc extends Bloc<EvaluationEvent, EvaluationState> {
  final EvaluationRepository _evaluationRepository;

  EvaluationBloc({required EvaluationRepository evaluationRepository})
      : _evaluationRepository = evaluationRepository,
        super(const EvaluationState()) {
    on<LoadAllReviews>(_onLoadAllReviews);
    on<LoadReviewById>(_onLoadReviewById);
    on<LoadReviewsByBookId>(_onLoadReviewsByBookId);
    on<LoadBookAverageRating>(_onLoadBookAverageRating);
    on<CreateReview>(_onCreateReview);
    on<UpdateReview>(_onUpdateReview);
    on<DeleteReview>(_onDeleteReview);
  }

  Future<void> _onLoadAllReviews(LoadAllReviews event, Emitter<EvaluationState> emit) async {
    emit(state.copyWith(status: EvaluationStatus.loading));
    try {
      final reviews = await _evaluationRepository.getAllReviews();
      emit(state.copyWith(reviews: reviews, status: EvaluationStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: EvaluationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadReviewById(LoadReviewById event, Emitter<EvaluationState> emit) async {
    emit(state.copyWith(status: EvaluationStatus.loading));
    try {
      final review = await _evaluationRepository.getReviewById(event.id);
      emit(state.copyWith(selectedReview: review, status: EvaluationStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: EvaluationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadReviewsByBookId(LoadReviewsByBookId event, Emitter<EvaluationState> emit) async {
    emit(state.copyWith(status: EvaluationStatus.loading));
    try {
      final reviews = await _evaluationRepository.getReviewsByBookId(event.bookId);
      emit(state.copyWith(bookReviews: reviews, status: EvaluationStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: EvaluationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadBookAverageRating(LoadBookAverageRating event, Emitter<EvaluationState> emit) async {
    emit(state.copyWith(status: EvaluationStatus.loading));
    try {
      final rating = await _evaluationRepository.getBookAverageRating(event.bookId);
      emit(state.copyWith(bookAverageRating: rating, status: EvaluationStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: EvaluationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateReview(CreateReview event, Emitter<EvaluationState> emit) async {
    emit(state.copyWith(status: EvaluationStatus.loading));
    try {
      final response = await _evaluationRepository.createReview(event.review);
      if (response['success']) {
        // Refresh reviews
        if (event.bookId != null) {
          add(LoadReviewsByBookId(event.bookId!));
        } else {
          add(LoadAllReviews());
        }
        emit(state.copyWith(status: EvaluationStatus.loaded));
      } else {
        emit(state.copyWith(
          status: EvaluationStatus.error,
          errorMessage: response['message'] ?? 'Failed to create review',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EvaluationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateReview(UpdateReview event, Emitter<EvaluationState> emit) async {
    emit(state.copyWith(status: EvaluationStatus.loading));
    try {
      final response = await _evaluationRepository.updateReview(event.id, event.review);
      if (response['success']) {
        // Refresh reviews
        if (event.bookId != null) {
          add(LoadReviewsByBookId(event.bookId!));
        } else {
          add(LoadAllReviews());
        }
        emit(state.copyWith(status: EvaluationStatus.loaded));
      } else {
        emit(state.copyWith(
          status: EvaluationStatus.error,
          errorMessage: response['message'] ?? 'Failed to update review',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EvaluationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteReview(DeleteReview event, Emitter<EvaluationState> emit) async {
    emit(state.copyWith(status: EvaluationStatus.loading));
    try {
      final response = await _evaluationRepository.deleteReview(event.id);
      if (response['success']) {
        // Refresh reviews
        if (event.bookId != null) {
          add(LoadReviewsByBookId(event.bookId!));
        } else {
          add(LoadAllReviews());
        }
        emit(state.copyWith(status: EvaluationStatus.loaded));
      } else {
        emit(state.copyWith(
          status: EvaluationStatus.error,
          errorMessage: response['message'] ?? 'Failed to delete review',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EvaluationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
