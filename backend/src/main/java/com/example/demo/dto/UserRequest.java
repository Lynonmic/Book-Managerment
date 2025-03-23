package com.example.demo.dto;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotNull;

import org.springframework.format.annotation.NumberFormat;

import lombok.Data;

@Data
public class UserRequest {
    private String ten_khach_hang;
    @Email
    @NotNull
    private String email;
    @NumberFormat
    private String soDienThoai;
    private String dia_chi;
    private String url_avata;
}
