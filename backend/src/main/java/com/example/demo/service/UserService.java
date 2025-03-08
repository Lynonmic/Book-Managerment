package com.example.demo.service;

import java.util.Date;
import java.util.Optional;
import java.util.regex.Pattern;

import io.jsonwebtoken.security.Keys;
import java.security.Key;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.dto.LoginRequest;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.IOException;
import jakarta.annotation.PostConstruct;
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

    private String SECRET_KEY;

    @PostConstruct
    public void init() {
        this.SECRET_KEY = Base64.getEncoder().encodeToString(secretKey.getBytes());
    }

    public Optional<String> loginUser(LoginRequest request) {
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
        return Optional.of(token);
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

    public String registerUser(
            String tenKhachHang,
            String email,
            String password,
            String so_dien_thoai,
            String address,
            MultipartFile avatarFile) {

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
        newUser.setUrl_avata(avatarUrl); // Lưu đường dẫn ảnh vào database

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
}
