import 'package:frontend/service/api_service.dart';

class PublisherController {
  // Hàm trả về danh sách publisher thay vì cập nhật state
  Future<Map<String, dynamic>> fetchPublishers() async {
    return await ApiService.getAllPublisher();
  }
}
