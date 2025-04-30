import 'package:bloc/bloc.dart';
import 'package:frontend/blocs/publisher/publisher_event.dart';
import 'package:frontend/blocs/publisher/publisher_state.dart';
import 'package:frontend/repositories/publisher_repository.dart';

class PublisherBloc extends Bloc<PublisherEvent, PublisherState> {
  final PublisherRepository publisherRepository;

  PublisherBloc(this.publisherRepository) : super(PublisherInitialState()) {
    on<LoadPublishersEvent>(_onLoadPublishers);
    on<CreatePublisherEvent>(_onCreatePublisher);
    on<UpdatePublisherEvent>(_onUpdatePublisher);
    on<DeletePublisherEvent>(_onDeletePublisher);
  }

  Future<void> _onLoadPublishers(
    LoadPublishersEvent event,
    Emitter<PublisherState> emit,
  ) async {
    emit(PublisherLoadingState());
    try {
      final publishers = await publisherRepository.getAllPublishers();
      emit(PublisherLoadedState(publishers));
    } catch (e) {
      emit(PublisherErrorState("Không thể tải danh sách nhà xuất bản"));
    }
  }

  Future<void> _onCreatePublisher(
    CreatePublisherEvent event,
    Emitter<PublisherState> emit,
  ) async {
    emit(PublisherLoadingState());
    try {
      final result = await publisherRepository.createPublisher(
        event.tenNhaXuatBan,
        event.diaChi,
        event.sdt,
        event.email,
      );
      if (result["success"]) {
        emit(PublisherActionSuccessState(result["message"]));
        add(LoadPublishersEvent());
      } else {
        emit(PublisherActionFailureState(result["message"]));
      }
    } catch (e) {
      emit(PublisherErrorState("Lỗi khi tạo nhà xuất bản"));
    }
  }


  Future<void> _onUpdatePublisher(
    UpdatePublisherEvent event,
    Emitter<PublisherState> emit,
  ) async {
    emit(PublisherLoadingState());
    try {
      final result = await publisherRepository.updatePublisher(
        event.maNhaXuatBan,
        event.name,
        event.address,
        event.phone,
        event.email,
      );
      if (result["success"]) {
        emit(PublisherActionSuccessState(result["message"]));
      } else {
        emit(PublisherActionFailureState(result["message"]));
      }
    } catch (e) {
      emit(PublisherErrorState("Lỗi khi cập nhật nhà xuất bản"));
    }
  }

  Future<void> _onDeletePublisher(
    DeletePublisherEvent event,
    Emitter<PublisherState> emit,
  ) async {
    emit(PublisherLoadingState());
    try {
      final result = await publisherRepository.deletePublisher(
        event.maNhaXuatBan,
      );
      if (result["success"]) {
        emit(PublisherActionSuccessState(result["message"]));
      } else {
        emit(PublisherActionFailureState(result["message"]));
      }
    } catch (e) {
      emit(PublisherErrorState("Lỗi khi xóa nhà xuất bản"));
    }
  }
}
