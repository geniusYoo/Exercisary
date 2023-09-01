package com.example.exercisary.service;

import com.example.exercisary.model.ExerciseEntity;
import com.example.exercisary.persistence.ExerciseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ExerciseService {

    @Autowired
    ExerciseRepository exerciseRepository;

    // Exercisary 생성
    public ExerciseEntity createExercisary(ExerciseEntity entity) {

        // validation
        if(entity == null || entity.getUserId() == null ) {
            throw new RuntimeException("Invalid arguments");
        }

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
}
