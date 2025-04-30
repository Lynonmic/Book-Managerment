abstract class ProfileEvent {}

class ProfileLoadEvent extends ProfileEvent {
  final int userId;
  ProfileLoadEvent(this.userId);
}

class ProfileUpdateEvent extends ProfileEvent {
  final Map<String, dynamic> updatedData;
  ProfileUpdateEvent(this.updatedData);
}

class ProfileLogoutEvent extends ProfileEvent {}
