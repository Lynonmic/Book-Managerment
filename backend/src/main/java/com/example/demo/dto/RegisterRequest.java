package com.example.demo.dto;

import lombok.Data;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotNull;
@Data
public class RegisterRequest {
    private String ten_khach_hang;
    @Email
    @NotNull
    private String email;
    private String password;
    private String so_dien_thoai;
    private String dia_chi;
    private String url_avata;
}
