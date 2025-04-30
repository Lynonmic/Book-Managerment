import 'package:frontend/model/PublisherModels.dart';

abstract class PublisherState {}

class PublisherInitialState extends PublisherState {}

class PublisherLoadingState extends PublisherState {}

class PublisherLoadedState extends PublisherState {
  final List<Publishermodels> publishers;

  PublisherLoadedState(this.publishers);
}

class PublisherErrorState extends PublisherState {
  final String message;

  PublisherErrorState(this.message);
}

class PublisherActionSuccessState extends PublisherState {
  final String message;

  PublisherActionSuccessState(this.message);
}

class PublisherActionFailureState extends PublisherState {
  final String message;

  PublisherActionFailureState(this.message);
}
