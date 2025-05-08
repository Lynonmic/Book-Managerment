import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:frontend/model/book_model.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

class LoadBooks extends BookEvent {}

class LoadBookById extends BookEvent {
  final int id;

  const LoadBookById(this.id);

  @override
  List<Object?> get props => [id];
}

class AddBook extends BookEvent {
  final Book book;

  const AddBook(this.book);

  @override
  List<Object?> get props => [book];
}

class UpdateBook extends BookEvent {
  final Book book;

  const UpdateBook(this.book);

  @override
  List<Object?> get props => [book];
}

class DeleteBook extends BookEvent {
  final int id;

  const DeleteBook(this.id);

  @override
  List<Object?> get props => [id];
}

class RateBook extends BookEvent {
  final int bookId;
  final int rating;

  const RateBook(this.bookId, this.rating);

  @override
  List<Object?> get props => [bookId, rating];
}

class UploadImage extends BookEvent {
  final File imageFile;

  const UploadImage(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}
