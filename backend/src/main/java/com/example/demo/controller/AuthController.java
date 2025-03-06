package com.example.demo.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.dto.LoginRequest;
import com.example.demo.dto.RegisterRequest;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.UserService;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private UserService userService;

    @Autowired
    public AuthController(UserService userService, UserRepository userRepository) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest userDTO) {
        if (userDTO.getTen_khach_hang() == null || userDTO.getTen_khach_hang().isEmpty()) {
            return ResponseEntity.badRequest().body("Tên khách hàng không được để trống");
        }
        if (userDTO.getEmail() == null || userDTO.getEmail().isEmpty()) {
            return ResponseEntity.badRequest().body("Email không được để trống");
        }

        String result = userService.registerUser(userDTO);
        if (result.equals("Email đã tồn tại!")) {
            return ResponseEntity.badRequest().body(result);
        }
        return ResponseEntity.ok(result);
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody LoginRequest request) {
        Optional<String> loginResult = userService.loginUser(request);

        if (loginResult.isEmpty()) {
            return ResponseEntity.status(401).body("Email hoặc mật khẩu không đúng");
        }

        return ResponseEntity.ok(loginResult.get()); // Trả về token
    }

}
