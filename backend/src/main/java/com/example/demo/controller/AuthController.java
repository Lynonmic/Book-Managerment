package com.example.demo.controller;

import java.util.Map;
import java.util.Optional;

import org.springframework.http.MediaType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.dto.LoginRequest;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.UserService;

import io.jsonwebtoken.io.IOException;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private UserService userService;

    @Autowired
    public AuthController(UserService userService, UserRepository userRepository) {
        this.userService = userService;
    }




    @PostMapping(value = "/register", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> register(
            @RequestParam("ten_khach_hang") String tenKhachHang,
            @RequestParam("email") String email,
            @RequestParam("password") String password,
            @RequestParam("phone") String phone,
            @RequestParam("address") String address,
            @RequestPart(value = "avatar", required = false) MultipartFile avatarFile) throws IOException {

        // Kiểm tra dữ liệu đầu vào
        if (tenKhachHang.isEmpty() || email.isEmpty() || password.isEmpty() || phone.isEmpty() || address.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Không được để trống!"));
        }
        // Gọi service để xử lý đăng ký
        String result = userService.registerUser(tenKhachHang, email, password, phone, address, avatarFile);

        if (result.contains("Lỗi")) {
            return ResponseEntity.status(500).body(result);
        }
        if (result.equals("Email đã tồn tại!") || result.equals("Số điện thoại đã tồn tại!")
                || result.equals("Số điện thoại không hợp lệ!") || result.equals("Email không hợp lệ!")) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", result));
        }

        return ResponseEntity.ok(Map.of("success", true, "message", "Đăng ký thành công!"));
    }




    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody LoginRequest request) {
        Optional<String> loginResult = userService.loginUser(request);

        if (loginResult.isEmpty()) {
            return ResponseEntity.status(401)
                    .body(Map.of("success", false, "message", "Email hoặc mật khẩu không đúng!"));
        }

        return ResponseEntity.ok(Map.of("success", true, "token", loginResult.get()));
    }
    
}
