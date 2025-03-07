package com.example.demo.service;

import java.util.Date;
import java.util.Optional;
import io.jsonwebtoken.security.Keys;
import java.security.Key;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.demo.dto.LoginRequest;
import com.example.demo.dto.RegisterRequest;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import jakarta.annotation.PostConstruct;
import java.util.Base64;

@Service

public class UserService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

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

    public String registerUser(RegisterRequest request) {
        // Kiểm tra email đã tồn tại chưa
        if (userRepository.getUserByEmail(request.getEmail()).isPresent()) {
            return "Email đã tồn tại!";
        }

        User newUser = new User();
        newUser.setTen_khach_hang(request.getTen_khach_hang());
        newUser.setEmail(request.getEmail());
        newUser.setPassword(passwordEncoder.encode(request.getPassword()));
        newUser.setSo_dien_thoai(request.getSo_dien_thoai());
        newUser.setDia_chi(request.getDia_chi());
        newUser.setUrl_avata(request.getUrl_avata());

        userRepository.save(newUser);
        return "Đăng ký thành công!";
    }
}
