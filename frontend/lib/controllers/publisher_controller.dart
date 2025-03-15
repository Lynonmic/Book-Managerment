import 'package:frontend/service/api_service.dart';

class PublisherController {
  Future<Map<String, dynamic>> fetchPublishers() async {
    return await ApiService.getAllPublisher();
  }

  Future<Map<String, dynamic>> createPublisher(
    String name,
    String address,
    String phone,
    String email,
  ) async {
    return await ApiService.createPublisher(name, address, phone, email);
  }

  Future<Map<String, dynamic>> deletePublisher(int maNhaXuatBan) async {
    return await ApiService.deletePublisher(maNhaXuatBan);
  }

  Future<Map<String, dynamic>> update(
    int manxb,
    String name,
    String address,
    String phone,
    String email,
  ) async {
    return await ApiService.update(manxb,name,address,phone,email);
  }
}
