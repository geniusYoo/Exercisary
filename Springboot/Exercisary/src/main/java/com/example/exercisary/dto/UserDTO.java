package com.example.exercisary.dto;

import com.example.exercisary.model.UserEntity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class UserDTO {
    private String userId;
    private String password;
    private String userName;

    public UserDTO(final UserEntity entity) {
        this.userId = entity.getUserId();
        this.userName = entity.getUserName();
        this.password = entity.getPassword();
    }

    public static UserEntity toEntity(UserDTO userDTO){
        return UserEntity.builder()
                .userId(userDTO.getUserId())
                .password(userDTO.getPassword())
                .userName(userDTO.getUserName())
                .build();
    }
}

