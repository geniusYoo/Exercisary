package com.example.exercisary.persistence;

import com.example.exercisary.model.ExerciseEntity;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ExerciseRepository extends MongoRepository<ExerciseEntity, String> {
    ExerciseEntity findByKey(String key);
    List<ExerciseEntity> findByUserId(String userId);
}
