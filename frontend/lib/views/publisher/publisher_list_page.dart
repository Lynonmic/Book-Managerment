import 'package:flutter/material.dart';
import 'package:frontend/controllers/publisher_controller.dart';
import 'package:frontend/models/PublisherModels.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/views/publisher/publisher_edit_page.dart';

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

  void _delete(int index) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn xóa nhà xuất bản này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      final result = await _controller.deletePublisher(publishers[index].maNhaXuatBan!);
      if (result["success"]) {
        setState(() {
          publishers.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xóa nhà xuất bản thành công")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${result["message"]}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _edit(Publishermodels publisher) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublisherEditPage(
          isEditing: true,
          publisherData: {
            "tenNhaXuatBan": publisher.tenNhaXuatBan,
            "diaChi": publisher.diaChi,
            "soDienThoai": publisher.soDienThoai,
            "email": publisher.email,
          },
        ),
      ),
    );
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
      body: isLoading
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
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: ListTile(
                        onTap: () => _edit(publisher),
                        onLongPress: () => _delete(index),
                        leading: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 213, 187, 246),
                          child: Text(
                            publisher.tenNhaXuatBan?[0] ?? "?",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 186, 14, 216),
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          publisher.tenNhaXuatBan ?? 'Không có tên',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _edit(publisher);
                            } else if (value == 'delete') {
                              _delete(index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit, color: Colors.blue),
                                title: Text("Sửa"),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text("Xóa"),
                              ),
                            ),
                          ],
                          icon: const Icon(Icons.more_horiz),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublisherEditPage(isEditing: false),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.purple),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
