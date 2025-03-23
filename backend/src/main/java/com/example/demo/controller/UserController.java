package com.example.demo.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.dto.UserRequest;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.persistence.EntityNotFoundException;

@RestController
@RequestMapping("/auth/users")
public class UserController {
    @Autowired
    private UserService userService;
    @Autowired
    private UserRepository userRepository;

    @GetMapping(produces = "application/json; charset=UTF-8")
    public List<User> getUsersWithRole1() {
        return userService.getAllUsersWithRole1();
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile(@RequestHeader("Authorization") String token) {
        return userService.getUserProfile(token);
    }

    @PutMapping(value = "/update/{userId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateProfile(
            @PathVariable Integer userId,
            @RequestParam(required = false) String tenKhachHang,
            @RequestParam(required = false) String soDienThoai,
            @RequestParam(required = false) String diaChi,
            @RequestParam(required = false) String email,
            @RequestPart(value = "avatar", required = false) MultipartFile avatarFile) {

        // In dữ liệu nhận được để debug
        System.out.println("📥 Nhận dữ liệu từ request:");
        System.out.println("📌 userId = " + userId);
        System.out.println("📌 tenKhachHang = " + tenKhachHang);
        System.out.println("📌 soDienThoai = " + soDienThoai);
        System.out.println("📌 diaChi = " + diaChi);
        System.out.println("📌 email = " + email);
        System.out.println(
                "📌 avatarFile = " + (avatarFile != null ? avatarFile.getOriginalFilename() : "Không có file"));

        return userService.updateUserProfile(userId, tenKhachHang, soDienThoai, diaChi, email, avatarFile);
    }

    @PutMapping(value = "/themseltupdate/{userId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> themselfUpdate(
            @PathVariable Integer userId,
            @RequestParam(required = false) String tenKhachHang,
            @RequestParam(required = false) String soDienThoai,
            @RequestParam(required = false) String diaChi,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String password,
            @RequestParam(required = false) MultipartFile avatarFile) {
        return userService.themselfUpdate(userId, tenKhachHang, soDienThoai, diaChi, email, password, avatarFile);
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<Map<String, Object>> deleteUser(@PathVariable Integer userId) {
        Map<String, Object> response = new HashMap<>();

        try {
            userService.deleteUser(userId);
            response.put("success", true);
            response.put("message", "User đã được xóa thành công.");
            return ResponseEntity.ok(response);
        } catch (EntityNotFoundException e) {
            response.put("success", false);
            response.put("message", "Không tìm thấy user!");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Lỗi hệ thống, vui lòng thử lại.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

}
