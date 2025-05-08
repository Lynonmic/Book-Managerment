import 'package:equatable/equatable.dart';
import 'package:frontend/model/book_model.dart';

enum BookStatus { initial, loading, loaded, error }

class BookState extends Equatable {
  final List<Book> books;
  final Book? selectedBook;
  final BookStatus status;
  final String? errorMessage;
  final String? uploadedImageUrl;

  const BookState({
    this.books = const [],
    this.selectedBook,
    this.status = BookStatus.initial,
    this.errorMessage,
    this.uploadedImageUrl,
  });

  BookState copyWith({
    List<Book>? books,
    Book? selectedBook,
    BookStatus? status,
    String? errorMessage,
    String? uploadedImageUrl,
  }) {
    return BookState(
      books: books ?? this.books,
      selectedBook: selectedBook ?? this.selectedBook,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
    );
  }

  @override
  List<Object?> get props => [books, selectedBook, status, errorMessage, uploadedImageUrl];
}
