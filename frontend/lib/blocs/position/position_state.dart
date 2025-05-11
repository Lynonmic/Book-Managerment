import 'package:equatable/equatable.dart';

abstract class PositionState extends Equatable {
  const PositionState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu
class PositionInitial extends PositionState {}

// Trạng thái đang tải
class PositionLoading extends PositionState {}

// Trạng thái thành công khi lấy danh sách trường vị trí
class PositionFieldsLoaded extends PositionState {
  final List<Map<String, dynamic>> positionFields;

  const PositionFieldsLoaded(this.positionFields);

  @override
  List<Object?> get props => [positionFields];
}

// Trạng thái thành công khi thêm vị trí sách
class BookPositionAdded extends PositionState {
  final Map<String, dynamic> bookPosition;

  const BookPositionAdded(this.bookPosition);

  @override
  List<Object?> get props => [bookPosition];
}

// Trạng thái thành công khi lấy vị trí sách
class BookPositionsLoaded extends PositionState {
  final List<Map<String, dynamic>> bookPositions;

  const BookPositionsLoaded(this.bookPositions);

  @override
  List<Object?> get props => [bookPositions];
}

// Trạng thái thành công khi thêm trường vị trí
class PositionFieldAdded extends PositionState {}

// Trạng thái lỗi
class PositionError extends PositionState {
  final String message;

  const PositionError(this.message);

  @override
  List<Object?> get props => [message];
}
