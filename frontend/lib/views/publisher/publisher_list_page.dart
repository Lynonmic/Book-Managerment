import 'package:flutter/material.dart';
import 'package:frontend/controllers/publisher_controller.dart';
import 'package:frontend/models/PublisherModels.dart';
import 'package:frontend/routes/app_routes.dart';

class PublisherListPage extends StatefulWidget {
  const PublisherListPage({super.key});

  @override
  _PublisherListPageState createState() => _PublisherListPageState();
}

class _PublisherListPageState extends State<PublisherListPage> {
  final PublisherController _controller = PublisherController();
  List<Publishermodels> publishers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPublishers();
    });
  }

  Future<void> _fetchPublishers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await _controller.fetchPublishers();

    if (result["success"]) {
      setState(() {
        publishers = List<Publishermodels>.from(result["data"]);
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result["message"];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publisher List"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.bottomMenu);
          },
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Text(
                  'Lỗi: $errorMessage',
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: publishers.length,
                itemBuilder: (context, index) {
                  final publisher = publishers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          publisher.tenNhaXuatBan?[0] ?? "?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(
                        publisher.tenNhaXuatBan ?? 'Không có tên',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Địa chỉ: ${publisher.diaChi ?? 'Không có'}"),
                          Text("SĐT: ${publisher.soDienThoai ?? 'Không có'}"),
                          Text("Email: ${publisher.email ?? 'Không có'}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
