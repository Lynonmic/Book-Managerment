import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/position_repo.dart';
import 'position_event.dart';
import 'position_state.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {
  PositionBloc() : super(PositionInitial());

  @override
  Stream<PositionState> mapEventToState(PositionEvent event) async* {
    if (event is FetchPositionFields) {
      yield PositionLoading();
      try {
        final positionFields = await PositionRepo.getPositionFields();
        yield PositionFieldsLoaded(positionFields);
      } catch (e) {
        yield PositionError('Failed to load position fields: $e');
      }
    }

    if (event is FetchBookPositions) {
      yield PositionLoading();
      try {
        final bookPositions = await PositionRepo.getBookPositions(event.bookId);
        yield BookPositionsLoaded(bookPositions);
      } catch (e) {
        yield PositionError('Failed to load book positions: $e');
      }
    }
  }
}
