abstract class PublisherEvent {}

class LoadPublishersEvent extends PublisherEvent {}

class CreatePublisherEvent extends PublisherEvent {
  final String tenNhaXuatBan;
  final String diaChi;
  final String sdt;
  final String email;

  CreatePublisherEvent({
    required this.tenNhaXuatBan,
    required this.diaChi,
    required this.sdt,
    required this.email,
  });
}

class UpdatePublisherEvent extends PublisherEvent {
  final int maNhaXuatBan;
  final String name;
  final String address;
  final String phone;
  final String email;

  UpdatePublisherEvent({
    required this.maNhaXuatBan,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });
}

class DeletePublisherEvent extends PublisherEvent {
  final int maNhaXuatBan;

  DeletePublisherEvent({required this.maNhaXuatBan});
}
