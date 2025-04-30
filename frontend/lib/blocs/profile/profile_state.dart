abstract class ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileLoadedState extends ProfileState {
  final Map<String, dynamic> userData;
  ProfileLoadedState(this.userData);
}

class ProfileErrorState extends ProfileState {
  final String error;
  ProfileErrorState(this.error);
}
