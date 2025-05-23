import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/publisher/publisher_bloc.dart';
import 'package:frontend/blocs/publisher/publisher_event.dart';
import 'package:frontend/blocs/publisher/publisher_state.dart';

class PublisherEditPage extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? publisherData;

  const PublisherEditPage({
    super.key,
    required this.isEditing,
    this.publisherData,
  });

  @override
  _PublisherEditPageState createState() => _PublisherEditPageState();
}

class _PublisherEditPageState extends State<PublisherEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.publisherData != null) {
      _nameController.text = widget.publisherData!['tenNhaXuatBan'] ?? '';
      _addressController.text = widget.publisherData!['diaChi'] ?? '';
      _phoneController.text = widget.publisherData!['soDienThoai'] ?? '';
      _emailController.text = widget.publisherData!['email'] ?? '';
    }
  }

  Future<void> _savePublisher() async {
    String name = _nameController.text.trim();
    String address = _addressController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();

    if (name.isEmpty || address.isEmpty || phone.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")),
      );
      return;
    }

    BlocProvider.of<PublisherBloc>(context).add(
      widget.isEditing
          ? UpdatePublisherEvent(
              maNhaXuatBan: widget.publisherData!['maNhaXuatBan'],
              name: name,
              address: address,
              phone: phone,
              email: email,
            )
          : CreatePublisherEvent(
              tenNhaXuatBan: name,
              diaChi: address,
              sdt: phone,
              email: email,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Publisher" : "Add Publisher"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocListener<PublisherBloc, PublisherState>(
        listener: (context, state) {
          if (state is PublisherLoadingState) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is PublisherActionSuccessState) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is PublisherActionFailureState) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PublisherErrorState) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.deepPurpleAccent,
                          child: Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        "Publisher name",
                        _nameController,
                        "Input publisher name...",
                      ),
                      _buildTextField(
                        "Address",
                        _addressController,
                        "Input address...",
                      ),
                      _buildTextField(
                        "Phone number",
                        _phoneController,
                        "Input phone number...",
                      ),
                      _buildTextField(
                        "Email",
                        _emailController,
                        "Input email...",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePublisher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(controller: controller, decoration: _inputDecoration(hint)),
        const SizedBox(height: 20),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.transparent,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    );
  }
}
