package com.example.exercisary.persistence;

import com.example.exercisary.model.UserEntity;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface UserRepository extends MongoRepository<UserEntity, String> {
    UserEntity findByUserId(String name);
}
