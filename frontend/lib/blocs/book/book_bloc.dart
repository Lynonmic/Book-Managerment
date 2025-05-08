import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/book/book_event.dart';
import 'package:frontend/blocs/book/book_state.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/repositories/book_repository.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository _bookRepository;

  BookBloc({required BookRepository bookRepository})
      : _bookRepository = bookRepository,
        super(const BookState()) {
    on<LoadBooks>(_onLoadBooks);
    on<LoadBookById>(_onLoadBookById);
    on<AddBook>(_onAddBook);
    on<UpdateBook>(_onUpdateBook);
    on<DeleteBook>(_onDeleteBook);
    on<RateBook>(_onRateBook);
    on<UploadImage>(_onUploadImage);
  }

  Future<void> _onLoadBooks(LoadBooks event, Emitter<BookState> emit) async {
    emit(state.copyWith(status: BookStatus.loading));
    try {
      final books = await _bookRepository.getBooks();
      emit(state.copyWith(books: books, status: BookStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: BookStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadBookById(
      LoadBookById event, Emitter<BookState> emit) async {
    emit(state.copyWith(status: BookStatus.loading));
    try {
      final book = await _bookRepository.getBookById(event.id);
      emit(state.copyWith(selectedBook: book, status: BookStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: BookStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddBook(AddBook event, Emitter<BookState> emit) async {
    emit(state.copyWith(status: BookStatus.loading));
    try {
      await _bookRepository.createBook(event.book);
      add(LoadBooks());
    } catch (e) {
      emit(state.copyWith(
        status: BookStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateBook(UpdateBook event, Emitter<BookState> emit) async {
    emit(state.copyWith(status: BookStatus.loading));
    try {
      await _bookRepository.updateBook(event.book);
      add(LoadBooks());
    } catch (e) {
      emit(state.copyWith(
        status: BookStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteBook(DeleteBook event, Emitter<BookState> emit) async {
    emit(state.copyWith(status: BookStatus.loading));
    try {
      final success = await _bookRepository.deleteBook(event.id);
      if (success) {
        add(LoadBooks());
      } else {
        emit(state.copyWith(
          status: BookStatus.error,
          errorMessage: 'Failed to delete book',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRateBook(RateBook event, Emitter<BookState> emit) async {
    emit(state.copyWith(status: BookStatus.loading));
    try {
      final success = await _bookRepository.rateBook(event.bookId, event.rating.toDouble());
      if (success) {
        // Refresh the book list to get updated ratings
        await _onLoadBooks(LoadBooks(), emit);
      } else {
        emit(state.copyWith(
          status: BookStatus.error,
          errorMessage: 'Failed to rate book',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> _onUploadImage(UploadImage event, Emitter<BookState> emit) async {
    emit(state.copyWith(status: BookStatus.loading));
    try {
      final imageUrl = await _bookRepository.uploadImage(event.imageFile);
      if (imageUrl != null) {
        emit(state.copyWith(
          status: BookStatus.loaded,
          uploadedImageUrl: imageUrl,
        ));
      } else {
        emit(state.copyWith(
          status: BookStatus.error,
          errorMessage: 'Failed to upload image',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
