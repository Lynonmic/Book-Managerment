class UserModels {
  final int? maKhachHang;
  final String? tenKhachHang;
  final String? urlAvata;
  final String? email;
  final String? password;
  final String? soDienThoai;
  final String? diaChi;
  final DateTime? ngayTao;

  UserModels({
    this.maKhachHang,
    this.tenKhachHang,
    this.urlAvata,
    this.email,
    this.password,
    this.soDienThoai,
    this.diaChi,
    this.ngayTao,
  });

  factory UserModels.fromJson(Map<String, dynamic> json) {
    return UserModels(
      maKhachHang: json['ma_khach_hang'],
      tenKhachHang: json['ten_khach_hang'] ?? 'Không có tên',
      urlAvata: json['url_avata'] ?? '',
      email: json['email'],
      password: json['password'],
      soDienThoai: json['so_dien_thoai'],
      diaChi: json['dia_chi'],
      ngayTao: json['ngay_tao'] != null ? DateTime.tryParse(json['ngay_tao']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ma_khach_hang": maKhachHang,
      "ten_khach_hang": tenKhachHang,
      "url_avata": urlAvata,
      "email": email,
      "password": password,
      "so_dien_thoai": soDienThoai,
      "dia_chi": diaChi,
      "ngay_tao": ngayTao?.toIso8601String(),
    };
  }
}
