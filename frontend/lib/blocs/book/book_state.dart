import 'package:equatable/equatable.dart';
import 'package:frontend/model/book_model.dart';

enum BookStatus { initial, loading, loaded, error }

class BookState extends Equatable {
  final List<Book> books;
  final Book? selectedBook;
  final BookStatus status;
  final String? errorMessage;

  const BookState({
    this.books = const [],
    this.selectedBook,
    this.status = BookStatus.initial,
    this.errorMessage,
  });

  BookState copyWith({
    List<Book>? books,
    Book? selectedBook,
    BookStatus? status,
    String? errorMessage,
  }) {
    return BookState(
      books: books ?? this.books,
      selectedBook: selectedBook ?? this.selectedBook,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [books, selectedBook, status, errorMessage];
}
