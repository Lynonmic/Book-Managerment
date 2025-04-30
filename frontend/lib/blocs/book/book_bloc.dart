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
      final newBook = await _bookRepository.createBook(event.book);
      final updatedBooks = List<Book>.from(state.books)..add(newBook);
      emit(state.copyWith(
        books: updatedBooks,
        status: BookStatus.loaded,
      ));
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
      final updatedBook = await _bookRepository.updateBook(event.book);
      final updatedBooks = state.books.map((book) {
        return book.id == updatedBook.id ? updatedBook : book;
      }).toList();
      emit(state.copyWith(
        books: updatedBooks,
        selectedBook: updatedBook,
        status: BookStatus.loaded,
      ));
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
        final updatedBooks = state.books.where((book) => book.id != event.id).toList();
        emit(state.copyWith(
          books: updatedBooks,
          status: BookStatus.loaded,
        ));
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
}
