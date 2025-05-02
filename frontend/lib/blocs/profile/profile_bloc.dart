import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc(this.userRepository) : super(ProfileLoadingState()) {
    on<ProfileUpdateEvent>((event, emit) async {
      try {
        final updated = await userRepository.updateUser(
          userId: event.updatedData['id'],
          tenKhachHang: event.updatedData['name'],
          email: event.updatedData['email'],
          soDienThoai: event.updatedData['phone'],
          diaChi: event.updatedData['address'],
          avatar: event.updatedData['avatar'],
        );

        if (updated != null) {
          // Emit the ProfileLoadedState with updated data
          emit(ProfileLoadedState({
            'id': updated['id'],
            'name': updated['name'],
            'email': updated['email'],
            'phone': updated['phone'],
            'address': updated['address'],
            'avatar': updated['avatar'],
          }));
        } else {
          // Emit an error state if update fails
          emit(ProfileErrorState("Không thể cập nhật thông tin người dùng"));
        }
      } catch (e) {
        // Emit an error state if any exception occurs
        emit(ProfileErrorState("Cập nhật thất bại"));
      }
    });

    on<ProfileLogoutEvent>((event, emit) {
      // Emit an error state indicating that the user is logged out
      emit(ProfileErrorState("Đã đăng xuất"));
    });
  }
}
