
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc(this.userRepository) : super(ProfileLoadingState()) {
    on<ProfileLoadEvent>((event, emit) async {
      emit(ProfileLoadingState());
      try {
        final user = await userRepository.getUserById(event.userId);
        emit(ProfileLoadedState({
          'id': user.maKhachHang,
          'name': user.tenKhachHang,
          'email': user.email,
          'phone': user.soDienThoai,
          'address': user.diaChi,
          'avatar': user.urlAvata,
        }));
      } catch (e) {
        emit(ProfileErrorState("Không thể tải thông tin người dùng"));
      }
    });

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

        emit(ProfileLoadedState(updated ?? {}));
      } catch (e) {
        emit(ProfileErrorState("Cập nhật thất bại"));
      }
    });

    on<ProfileLogoutEvent>((event, emit) {
      emit(ProfileErrorState("Đã đăng xuất"));
    });
  }
}
