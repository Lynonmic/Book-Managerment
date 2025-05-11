import 'package:equatable/equatable.dart';

abstract class PositionEvent extends Equatable {
  const PositionEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện lấy danh sách trường vị trí
class FetchPositionFields extends PositionEvent {}

// Sự kiện thêm vị trí cho sách
class AddBookPosition extends PositionEvent {
  final int bookId;
  final int positionFieldId;
  final String positionValue;

  const AddBookPosition(this.bookId, this.positionFieldId, this.positionValue);

  @override
  List<Object?> get props => [bookId, positionFieldId, positionValue];
}

// Sự kiện lấy các vị trí của sách
class FetchBookPositions extends PositionEvent {
  final int bookId;

  const FetchBookPositions(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

// Sự kiện thêm trường vị trí mới
class AddPositionField extends PositionEvent {
  final String positionName;

  const AddPositionField(this.positionName);

  @override
  List<Object?> get props => [positionName];
}
