package com.example.exercisary.dto;

import com.example.exercisary.model.ExerciseEntity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class ExerciseDTO {
    private String key;
    private String date;
    private String type;
    private String time;
    private String content;
    private String memo;
    private String userId;
    private String photoUrl;

    public ExerciseDTO(final ExerciseEntity entity) {
        this.key = entity.getKey();
        this.date = entity.getDate();
        this.type = entity.getType();
        this.time = entity.getTime();
        this.content = entity.getContent();
        this.memo = entity.getMemo();
        this.userId = entity.getUserId();
        this.photoUrl = entity.getPhotoUrl();
    }

    public static ExerciseEntity toEntity(ExerciseDTO exerciseDTO){
        return ExerciseEntity.builder()
                .key(exerciseDTO.getKey())
                .date(exerciseDTO.getDate())
                .type(exerciseDTO.getType())
                .time(exerciseDTO.getTime())
                .content(exerciseDTO.getContent())
                .memo(exerciseDTO.getMemo())
                .userId(exerciseDTO.getUserId())
                .photoUrl(exerciseDTO.getPhotoUrl())
                .build();
    }
}
