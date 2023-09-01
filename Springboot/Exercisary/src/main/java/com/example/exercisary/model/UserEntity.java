package com.example.exercisary.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "user")

public class UserEntity {
    @Id
    @NonNull
    private String userId;

    private String password;

    private String userName;

    private String preferredType;
}

