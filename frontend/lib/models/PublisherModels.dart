class Publishermodels {
  final int? maNhaXuatBan;
  final String? tenNhaXuatBan;
  final String? diaChi;
  final String? soDienThoai;
  final String? email;

  Publishermodels({
    this.maNhaXuatBan,
    this.tenNhaXuatBan,
    this.diaChi,
    this.soDienThoai,
    this.email,
  });

  factory Publishermodels.fromJson(Map<String, dynamic> json) {
    return Publishermodels(
      maNhaXuatBan: json['ma_nha_xuat_ban'] as int?,
      tenNhaXuatBan: json['ten_nha_xuat_ban'] as String?,
      diaChi: json['dia_chi'] as String?,
      soDienThoai: json['so_dien_thoai'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ma_nha_xuat_ban": maNhaXuatBan,
      "ten_nha_xuat_ban": tenNhaXuatBan,
      "dia_chi": diaChi,
      "so_dien_thoai": soDienThoai,
      "email": email,
    };
  }
}
