abstract class SearchUserEvent {}

class PerformSearchUserEvent extends SearchUserEvent {
  final String query;
  PerformSearchUserEvent(this.query);
}
