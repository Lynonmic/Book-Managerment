import 'package:frontend/service/api_service.dart';

class PublisherController {
  Future<Map<String, dynamic>> fetchPublishers() async {
    return await ApiService.getAllPublisher();
  }

  Future<Map<String,dynamic>> createPublisher(String name, String address, String phone,String email) async {
    return await ApiService.createPublisher(name, address, phone,email);
  }

  Future<Map<String, dynamic>> deletePublisher(int maNhaXuatBan) async {
    return await ApiService.deletePublisher(maNhaXuatBan);
  }

  updatePublisher(param0, String name, String address, String phone, String email) {}

}
