package com.example.exercisary.service;

import com.example.exercisary.model.UserEntity;
import com.example.exercisary.persistence.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class UserService {

    @Autowired
    UserRepository userRepository;

    // 회원가입 시
    public UserEntity create(UserEntity userEntity) {

        if(userEntity == null || userEntity.getUserId() == null ) {
            throw new RuntimeException("Invalid arguments");
        }

        // id 중복 확인
        final String id = userEntity.getUserId();
        if(userRepository.existsById(id)) {
            log.warn("id already exists {}", id);
            throw new RuntimeException("id already exists");
        }

        log.info("id 생성 완료! " + userEntity);
        return userRepository.save(userEntity);
    }

    // 로그인 시, userId와 password 매칭해서 확인해주는 함수
    public UserEntity getByCredentials(final String userId, final String password, final PasswordEncoder encoder) {
        final UserEntity originalUser = userRepository.findByUserId(userId);
        log.info("id 검색 완료! " + originalUser);
        if(originalUser != null && encoder.matches(password, originalUser.getPassword())) {
            return originalUser;
        }
        return null;
    }



}