package com.example.demo.service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;

import io.jsonwebtoken.security.Keys;
import java.security.Key;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.dto.LoginRequest;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.IOException;
import jakarta.annotation.PostConstruct;
import jakarta.persistence.EntityNotFoundException;

import java.util.Base64;

@Service

public class UserService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private CloudinaryService cloudinaryService;

    @Value("${jwt.secret}")
    private String secretKey;
    @Autowired
    private JwtService jwtService;

    private String SECRET_KEY;

    @PostConstruct
    public void init() {
        this.SECRET_KEY = Base64.getEncoder().encodeToString(secretKey.getBytes());
    }

    public Optional<Map<String, Object>> loginUser(LoginRequest request) {
        Optional<User> userOpt = userRepository.getUserByEmail(request.getEmail());

        if (userOpt.isEmpty()) {
            return Optional.empty();
        }

        User user = userOpt.get();
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            System.out.println("❌ Sai mật khẩu, không tạo token!");
            return Optional.empty();
        }

        String token = generateAuthToken(user);

        // Trả về token + role để frontend điều hướng
        Map<String, Object> response = new HashMap<>();
        response.put("token", token);
        response.put("role", user.getRoles());

        return Optional.of(response);
    }

    private String generateAuthToken(User user) {
        Key key = Keys.hmacShaKeyFor(SECRET_KEY.getBytes()); // Dùng key chuẩn từ config
        return Jwts.builder()
                .setSubject(user.getEmail())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 1 ngày
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(secretKey).build().parseClaimsJws(token);
            return true;
        } catch (JwtException e) {
            return false;
        }
    }

    public String extractEmail(String token) {
        return extractClaims(token).getSubject();
    }


    private Claims extractClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(secretKey)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public String registerUser(
            String tenKhachHang,
            String email,
            String password,
            String so_dien_thoai,
            String address,
            MultipartFile avatarFile,
            Integer roles) {

        // 🔥 Kiểm tra Email hợp lệ
        if (!isValidEmail(email)) {
            return "Email không hợp lệ!";
        }

        // 🔥 Kiểm tra Số điện thoại hợp lệ
        if (!isValidPhone(so_dien_thoai)) {
            return "Số điện thoại không hợp lệ!";
        }
        // Kiểm tra email đã tồn tại chưa
        if (userRepository.getUserByEmail(email).isPresent()) {
            return "Email đã tồn tại!";
        }
        if (userRepository.getUserBySoDienThoai(so_dien_thoai).isPresent()) {
            return "Số điện thoại đã tồn tại!";
        }

        String avatarUrl = "https://res.cloudinary.com/duthhwipq/image/upload/v1741449466/w6nxcdrb23fvtzeda3aj.webp";

        if (avatarFile != null && !avatarFile.isEmpty()) {
            try {
                avatarUrl = cloudinaryService.uploadFile(avatarFile);
            } catch (IOException e) {
                return "Lỗi khi tải ảnh lên Cloudinary!";
            }
        }

        User newUser = new User();
        newUser.setTen_khach_hang(tenKhachHang);
        newUser.setEmail(email);
        newUser.setPassword(passwordEncoder.encode(password));
        newUser.setSoDienThoai(so_dien_thoai);
        newUser.setDia_chi(address);
        newUser.setUrl_avata(avatarUrl);
        newUser.setRoles(1);

        userRepository.save(newUser);
        return "Đăng ký thành công!";
    }

    public boolean isValidEmail(String email) {
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        return Pattern.matches(emailRegex, email);
    }

    public boolean isValidPhone(String so_dien_thoai) {
        String phoneRegex = "^(0[0-9]{9})$";
        return Pattern.matches(phoneRegex, so_dien_thoai);
    }

    public List<User> getAllUsersWithRole1() {
        return userRepository.findByRoles(1);
    }

    public ResponseEntity<?> getUserProfile(String token) {
        String email = jwtService.extractEmail(token.replace("Bearer ", ""));
        Optional<User> userOpt = userRepository.getUserByEmail(email);

        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "Không tìm thấy user!"));
        }

        return ResponseEntity.ok(userOpt.get());
    }

    public ResponseEntity<?> themselfUpdate(
            Integer userId,
            String tenKhachHang,
            String soDienThoai,
            String diaChi,
            String email,
            String password,
            MultipartFile avatarFile) {
        Optional<User> userOpt = userRepository.findById(userId);

        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "Không tìm thấy người dùng!"));
        }

        User user = userOpt.get();

        // Cập nhật tên khách hàng
        if (tenKhachHang != null && !tenKhachHang.isBlank()) {
            user.setTen_khach_hang(tenKhachHang);
        }

        if (soDienThoai != null && !soDienThoai.isBlank()) {
            Optional<User> existingUserWithPhone = userRepository.getUserBySoDienThoai(soDienThoai);
            if (existingUserWithPhone.isPresent() && !existingUserWithPhone.get().getMa_khach_hang().equals(userId)) {
                return ResponseEntity.status(400)
                        .body(Map.of("success", false, "message", "Số điện thoại đã được sử dụng!"));
            }
            user.setSoDienThoai(soDienThoai);
        }

        // Cập nhật địa chỉ
        if (diaChi != null && !diaChi.isBlank()) {
            user.setDia_chi(diaChi);
        }

        // Cập nhật email
        if (email != null && !email.isBlank()) {
            Optional<User> existingUser = userRepository.getUserByEmail(email);
            if (existingUser.isPresent() && !existingUser.get().getMa_khach_hang().equals(userId)) {
                return ResponseEntity.status(400).body(Map.of("success", false, "message", "Email đã được sử dụng!"));
            }
            user.setEmail(email);
        }

        // Cập nhật mật khẩu (nếu có)
        if (password != null && !password.isBlank()) {
            String hashedPassword = passwordEncoder.encode(password);
            user.setPassword(hashedPassword);
        }

        // Cập nhật avatar
        if (avatarFile != null && !avatarFile.isEmpty()) {
            try {
                String avatarUrl = cloudinaryService.uploadFile(avatarFile);
                user.setUrl_avata(avatarUrl);
            } catch (Exception e) {
                return ResponseEntity.status(500)
                        .body(Map.of("success", false, "message", "Lỗi tải ảnh lên Cloudinary!"));
            }
        }

        userRepository.save(user);
        return ResponseEntity.ok(Map.of("success", true, "message", "Cập nhật thông tin thành công!", "user", user));
    }

    public ResponseEntity<?> updateUserProfile(
            Integer userId,
            String tenKhachHang,
            String soDienThoai,
            String diaChi,
            String email,
            MultipartFile avatarFile) {
        Optional<User> userOpt = userRepository.findById(userId);

        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "Không tìm thấy người dùng!"));
        }

        User user = userOpt.get();

        // Cập nhật tên khách hàng
        if (tenKhachHang != null && !tenKhachHang.isBlank()) {
            user.setTen_khach_hang(tenKhachHang);
        }

        if (soDienThoai != null && !soDienThoai.isBlank()) {
            Optional<User> existingUserWithPhone = userRepository.getUserBySoDienThoai(soDienThoai);
            if (existingUserWithPhone.isPresent() && !existingUserWithPhone.get().getMa_khach_hang().equals(userId)) {
                return ResponseEntity.status(400)
                        .body(Map.of("success", false, "message", "Số điện thoại đã được sử dụng!"));
            }
            user.setSoDienThoai(soDienThoai);
        }

        // Cập nhật địa chỉ
        if (diaChi != null && !diaChi.isBlank()) {
            user.setDia_chi(diaChi);
        }

        // Cập nhật email
        if (email != null && !email.isBlank()) {
            Optional<User> existingUser = userRepository.getUserByEmail(email);
            if (existingUser.isPresent() && !existingUser.get().getMa_khach_hang().equals(userId)) {
                return ResponseEntity.status(400).body(Map.of("success", false, "message", "Email đã được sử dụng!"));
            }
            user.setEmail(email);
        }

        // Cập nhật avatar
        if (avatarFile != null && !avatarFile.isEmpty()) {
            try {
                String avatarUrl = cloudinaryService.uploadFile(avatarFile);
                user.setUrl_avata(avatarUrl);
            } catch (Exception e) {
                return ResponseEntity.status(500)
                        .body(Map.of("success", false, "message", "Lỗi tải ảnh lên Cloudinary!"));
            }
        }

        userRepository.save(user);
        return ResponseEntity.ok(Map.of("success", true, "message", "Cập nhật thông tin thành công!", "user", user));
    }


    public void deleteUser(Integer id) {
        System.out.println("Kiểm tra ID: " + id);

        if (!userRepository.existsById(id)) {
            System.out.println("Lỗi: Không tìm thấy user ID = " + id);
            throw new EntityNotFoundException("Không tìm thấy user ID = " + id);
        }

        userRepository.deleteById(id);
        System.out.println("Đã xóa nhà xuất bản ID: " + id);
    }
}