import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<DeleteUserEvent>(_onDeleteUser);
    on<UpdateUserEvent>(_onUpdateUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final users = await userRepository.fetchAllUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError("Không thể tải danh sách người dùng"));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserDeleting());
    try {
      final response = await userRepository.deleteUser(event.userId);
      if (response["success"] == true) {
        emit(UserDeleted(message: "Xóa người dùng thành công"));
        add(LoadUsersEvent());
      } else {
        emit(UserError("Xóa người dùng thất bại"));
      }
    } catch (e) {
      emit(UserError("Lỗi khi xóa người dùng"));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserUpdating());
    try {
      final updated = await userRepository.updateUser(
        userId: event.userId,
        tenKhachHang: event.tenKhachHang,
        soDienThoai: event.soDienThoai,
        diaChi: event.diaChi,
        email: event.email,
        avatar: event.avatar,
      );
      print("Kết quả từ API (UserBloc): $updated");

     if (updated != null && updated['success'] == true && updated['user'] != null)  {
       final updatedUser = updated['user'];
        emit(UserUpdated(message: "Cập nhật người dùng thành công"));
        add(LoadUsersEvent());
      } else {
        emit(UserError("Cập nhật người dùng thất bại"));  
      }
    } catch (e) {
      emit(UserError("Lỗi khi cập nhật người dùng"));
    }
  }
}
