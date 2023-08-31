package com.example.exercisary.controller;

import com.example.exercisary.dto.ResponseDTO;
import com.example.exercisary.dto.UserDTO;
import com.example.exercisary.model.UserEntity;
import com.example.exercisary.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
//import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
//import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;

@RestController
@Slf4j
public class UserController {

    @Autowired
    private UserService userService;

//    private PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<?> register(@RequestBody UserDTO userDTO) {
        try {

            log.info("enter signup");
            if (userDTO == null || userDTO.getPassword() == null) {
                throw new RuntimeException("Invaild access");
            }

            UserEntity userEntity = userDTO.toEntity(userDTO);

            userService.create(userEntity);

            // 회원가입 시, 클라이언트에게 이러한 정보로 사용자가 회원가입 했다는 것을 알려주기 위한 데이터
            final UserDTO responseUserDTO = UserDTO.builder()
                    .userId(userDTO.getUserId())
                    .userName(userDTO.getUserName())
                    .preferredType(userDTO.getPreferredType())
                    .build();

            ResponseDTO responseDTO = ResponseDTO.builder()
                    .info("sign up")
                    .data(Collections.singletonList(responseUserDTO))
                    .status("succeed")
                    .build();

            return ResponseEntity.ok().body(responseDTO);

        } catch (Exception e) {
            ResponseDTO responseDTO = ResponseDTO.builder()
                    .info("sign up")
                    .error(e.getMessage())
                    .status("failed")
                    .build();
            return ResponseEntity.badRequest().body(responseDTO);
        }
    }

    // 로그인
    @PostMapping("/signin")
    public ResponseEntity<?> authenticate(@RequestBody UserDTO userDTO) {

        // 클라이언트에서 넘겨진 정보를 통해 아이디와 비밀번호를 매칭
//        UserEntity user = userService.getByCredentials(userDTO.getUserId(), userDTO.getPassword(), passwordEncoder);
        UserEntity user = new UserEntity();
        if (user != null) {
            //이때만 특별히 toEntity()를 사용하지 않고 빌더를 사용해 토큰을 붙여서 보내줌
            final UserDTO responseUserDTO = UserDTO.builder()
                    .userId(user.getUserId())
                    .userName(user.getUserName())
                    .build();

            ResponseDTO responseDTO = ResponseDTO.builder()
                    .info("sign in")
                    .data(Collections.singletonList(responseUserDTO))
                    .status("succeed")
                    .build();

            return ResponseEntity.ok().body(responseDTO);
        } else {
            ResponseDTO responseDTO = ResponseDTO.builder()
                    .info("sign in")
                    .error("Login Failed")
                    .status("failed")
                    .build();
            return ResponseEntity.badRequest().body(responseDTO);
        }
    }


}
