package com.example.exercisary.model;
//import jakarta.persistence.GeneratedValue;
import lombok.*;
//import org.hibernate.annotations.GenericGenerator;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "user")

public class UserEntity {
    @Id
//    @GeneratedValue(generator = "system-uuid")
//    @GenericGenerator(name = "system-uuid", strategy = "uuid")
//    private String key;

    @NonNull
    private String userId;

    private String password;

    private String userName;

    private String preferredType;
}

