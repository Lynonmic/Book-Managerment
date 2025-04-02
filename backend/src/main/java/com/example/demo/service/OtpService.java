package com.example.demo.service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import com.example.demo.entity.OtpCode;
import com.example.demo.repository.OtpCodeRepository;

@Service
public class OtpService {
    @Autowired
    private OtpCodeRepository otpCodeRepository;
    @Autowired
    private JavaMailSender mailSender;

    private static final int OTP_EXPIRATION_MINUTES = 5;

    public String generateOtp() {
        return String.valueOf(new Random().nextInt(900000) + 100000); // OTP 6 chữ số
    }

    public void sendOtp(String email) {
        String otp = generateOtp();
        LocalDateTime expirationTime = LocalDateTime.now().plusMinutes(OTP_EXPIRATION_MINUTES);

        otpCodeRepository.deleteByEmail(email); // Xóa OTP cũ trước khi tạo OTP mới

        OtpCode otpCode = new OtpCode();
        otpCode.setEmail(email);
        otpCode.setOtp(otp);
        otpCode.setExpiration_time(expirationTime);
        otpCodeRepository.save(otpCode);

        sendEmail(email, otp);
    }

    private void sendEmail(String to, String otp) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("Mã OTP đặt lại mật khẩu");
        message.setText("Mã OTP của bạn là: " + otp + ". OTP hết hạn sau 5 phút.");
        mailSender.send(message);
    }

    public boolean validateOtp(String email, String otp) {
        Optional<OtpCode> otpCodeOpt = otpCodeRepository.findByEmailAndOtp(email, otp);
        return otpCodeOpt.isPresent() && otpCodeOpt.get().getExpiration_time().isAfter(LocalDateTime.now());
    }
}
