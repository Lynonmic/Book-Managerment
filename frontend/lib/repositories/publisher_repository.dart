import 'package:frontend/model/PublisherModels.dart';
import 'package:frontend/service/api_service.dart';

class PublisherRepository {

  Future<List<Publishermodels>> getAllPublishers() async {
    return await ApiService.getAllPublisher();
  }

  Future<Map<String, dynamic>> createPublisher(
    String tenNhaXuatBan,
    String diaChi,
    String sdt,
    String email,
  ) async {
    return await ApiService.createPublisher(tenNhaXuatBan, diaChi, sdt, email);
  }

  Future<Map<String, dynamic>> updatePublisher(
    int maNhaXuatBan,
    String name,
    String address,
    String phone,
    String email,
  ) async {
    return await ApiService.update(maNhaXuatBan, name, address, phone, email);
  }

  Future<Map<String, dynamic>> deletePublisher(int maNhaXuatBan) async {
    return await ApiService.deletePublisher(maNhaXuatBan);
  }
}
