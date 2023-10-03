package com.example.exercisary.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;

@Data
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "exercise")
public class ExerciseEntity {
    @Id
    private String key;

    private String date;

    private String type;

    private String time;

    private String content;

    private String memo;

    private String userId;

    private String photoUrl;

//    private MultipartFile photo;
}