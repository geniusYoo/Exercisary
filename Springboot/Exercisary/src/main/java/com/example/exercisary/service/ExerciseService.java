package com.example.exercisary.service;

import com.example.exercisary.model.ExerciseEntity;
import com.example.exercisary.persistence.ExerciseRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.gridfs.GridFsTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
public class ExerciseService {

    @Autowired
    ExerciseRepository exerciseRepository;

    @Autowired
    private GridFsTemplate gridFsTemplate;

    // Exercisary 생성
    public ExerciseEntity createExercisary(ExerciseEntity entity) {

        // validation
        if(entity == null || entity.getUserId() == null ) {
            throw new RuntimeException("Invalid arguments");
        }

        exerciseRepository.save(entity);

        return retrieveExercisaryByKey(entity.getKey());
    }

    public ExerciseEntity create(ExerciseEntity entity, MultipartFile file) throws IOException {

        // validation
        if(entity == null || entity.getUserId() == null ) {
            throw new RuntimeException("Invalid arguments");
        }

        // GridFs에 저장
        String fileId = UUID.randomUUID().toString();
        gridFsTemplate.store(file.getInputStream(), fileId);

        String photoUrl = "/exercisary/" + fileId;
        entity.setPhotoUrl(photoUrl);

        exerciseRepository.save(entity);

        return retrieveExercisaryByKey(entity.getKey());
    }

    // 고유 키값으로 해당 Exercisary 검색
    public ExerciseEntity retrieveExercisaryByKey(String key) {
        return exerciseRepository.findByKey(key);
    }

    public List<ExerciseEntity> retrieveAllUserExercisaries(String userId) {
        return exerciseRepository.findByUserId(userId);
    }

    // 수정
    public ExerciseEntity updateExercisary(ExerciseEntity entity) {
        log.info("service enter");
        final Optional<ExerciseEntity> original = Optional.ofNullable(exerciseRepository.findByKey(entity.getKey()));

        original.ifPresent(exercise -> {
            exercise.setDate(entity.getDate() != null ? entity.getDate() : exercise.getDate());
            exercise.setType(entity.getType() != null ? entity.getType() : exercise.getType());
            exercise.setTime(entity.getTime() != null ? entity.getTime() : exercise.getTime());
            exercise.setContent(entity.getContent() != null ? entity.getContent() : exercise.getContent());
            exercise.setMemo(entity.getMemo() != null ? entity.getMemo() : exercise.getMemo());
            exercise.setUserId(entity.getUserId()!= null ? entity.getUserId() : exercise.getUserId());
            exercise.setPhotoUrl(entity.getPhotoUrl()!= null ? entity.getPhotoUrl() : exercise.getPhotoUrl());

            exerciseRepository.save(exercise);
            log.info("service save ${}", exercise);
        });

        return retrieveExercisaryByKey(entity.getKey());
    }

    // 삭제
    public List<ExerciseEntity> deleteExercisary(ExerciseEntity entity) {
        try {
            exerciseRepository.delete(entity);
        } catch(Exception e) {
            log.error("error deleting entity", entity.getUserId(), e);

            throw new RuntimeException("error deleting entity " + entity.getUserId());
        }

        return retrieveAllUserExercisaries(entity.getUserId());
    }
}
