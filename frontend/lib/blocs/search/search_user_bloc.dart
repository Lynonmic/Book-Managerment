import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/service/api_service.dart';
import 'search_user_event.dart';
import 'search_user_state.dart';

class SearchUserBloc extends Bloc<SearchUserEvent, SearchUserState> {
  final ApiService _apiService;

  SearchUserBloc(this._apiService) : super(SearchUserInitial()) {
    on<PerformSearchUserEvent>((event, emit) async {
      emit(SearchUserLoading());
      try {
        if (event.query.trim().isEmpty) {
          final allUsers = await ApiService.getAllUser();
          emit(SearchUserSuccess(allUsers));
        } else {
          final List<UserModels> results = await _apiService.searchUsers(
            event.query,
          );
          emit(SearchUserSuccess(results));
        }
      } catch (e) {
        emit(SearchUserError("Lỗi khi tìm kiếm người dùng: $e"));
      }
    });
  }
}
