import 'package:flutter/material.dart';
import 'package:frontend/repositories/position_repo.dart';

class AddPositionFieldScreen extends StatefulWidget {
  @override
  _AddPositionFieldScreenState createState() => _AddPositionFieldScreenState();
}

class _AddPositionFieldScreenState extends State<AddPositionFieldScreen> {
  final TextEditingController _positionNameController = TextEditingController();
  List<String> _positionNames = []; // Danh sách mới thêm (chưa lưu)
  List<String> _existingPositionFields = []; // Danh sách từ DB
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExistingPositionFields();
  }

  Future<void> _fetchExistingPositionFields() async {
    try {
      final fields = await PositionRepo.getPositionFields();
      setState(() {
        _existingPositionFields = fields.map((e) => e['name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching position fields: $e');
      setState(() {
        _errorMessage = 'Lỗi khi tải danh sách vị trí có sẵn.';
      });
    }
  }

  void _addPositionName() {
    final positionName = _positionNameController.text.trim();
    if (positionName.isEmpty) {
      setState(() {
        _errorMessage = "Tên vị trí không thể để trống!";
      });
      return;
    }

    setState(() {
      _positionNames.add(positionName);
      _positionNameController.clear();
      _errorMessage = null;
    });
  }

  void _editPositionName(int index) {
    // Chỉnh sửa tên vị trí tại vị trí index
    _positionNameController.text = _positionNames[index];
    // Xóa tên vị trí cũ khỏi danh sách
    setState(() {
      _positionNames.removeAt(index);
    });
  }

  void _removePositionName(int index) {
    setState(() {
      _positionNames.removeAt(index);
    });
  }

  void _savePositionFields() async {
    if (_positionNames.isEmpty) {
      setState(() {
        _errorMessage = "Vui lòng thêm ít nhất một trường vị trí!";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      for (var name in _positionNames) {
        // Truyền context vào để hiển thị lỗi trên giao diện
        await PositionRepo.addPositionField(name, context);
      }

      setState(() {
        _positionNames.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã lưu các trường vị trí!')));
      _fetchExistingPositionFields(); // Cập nhật lại danh sách từ DB
    } catch (e) {
      setState(() {
        _errorMessage = "Lỗi khi lưu trường vị trí: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _positionNameController,
              decoration: InputDecoration(
                labelText: 'Tên Vị Trí',
                errorText: _errorMessage,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPositionName,
              child: Text('Thêm Thành Phần Vị Trí'),
            ),
            SizedBox(height: 20),
            Text('📝 Danh sách chờ lưu:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._positionNames.map((name) {
              int index = _positionNames.indexOf(name);
              return ListTile(
                title: Text(name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editPositionName(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removePositionName(index),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePositionFields,
              child: Text('Lưu Tất Cả'),
            ),
            Divider(height: 40),
            Text('📦 Các trường vị trí đã có:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _existingPositionFields.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text(_existingPositionFields[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
