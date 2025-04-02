package com.example.demo.dto;

import javax.validation.constraints.Email;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

@Data
public class UserUpdateDTO {
    @Size(max = 100, message = "Tên khách hàng quá dài")
    private String tenKhachHang;

    @Pattern(regexp = "^[0-9]{10}$", message = "Số điện thoại không hợp lệ")
    private String soDienThoai;

    @Email(message = "Email không hợp lệ")
    private String email;

    private String diaChi;
    private String password;
    private MultipartFile avatarFile;
}

