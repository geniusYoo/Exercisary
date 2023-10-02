package com.example.exercisary.controller;

import com.example.exercisary.dto.ExerciseDTO;
import com.example.exercisary.dto.ResponseDTO;
import com.example.exercisary.model.ExerciseEntity;
import com.example.exercisary.service.ExerciseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Controller
@RequestMapping("/exercise")
public class ExerciseController {

    @Autowired
    private ExerciseService exerciseService;

    // CREATE
    @PostMapping
    public ResponseEntity<?> createExercisary(@RequestPart("file") MultipartFile file, @RequestPart ExerciseDTO dto) {
        try {
            ExerciseEntity entity = ExerciseDTO.toEntity(dto);

            entity = exerciseService.create(entity, file);

            ExerciseDTO dtos = new ExerciseDTO(entity);

            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder()
                    .info("create exercisary")
                    .data(Collections.singletonList(dtos))
                    .status("succeed")
                    .build();

            return ResponseEntity.ok().body(response);

        } catch(Exception e) {
            String error = e.getMessage();
            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder()
                    .info("create exercisary")
                    .error(error)
                    .status("failed")
                    .build();
            return ResponseEntity.badRequest().body(response);
        }
    }

    // RETRIEVE
    @GetMapping("/{userId}")
    public ResponseEntity<?> retrieveAllUserExercisaries(@PathVariable("userId") String userId) {
        log.info("response retrieve");

        try {
            List<ExerciseEntity> entities = exerciseService.retrieveAllUserExercisaries(userId);

            List<ExerciseDTO> exerciseDTOS = entities.stream().map(ExerciseDTO::new).collect(Collectors.toList());

            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder()
                    .info("retrieve all user exercisaries")
                    .data(exerciseDTOS)
                    .status("succeed")
                    .build();
            log.info("response retrieve : {}", response);
            return ResponseEntity.ok().body(response);

        } catch(Exception e) {
            String error = e.getMessage();
            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder()
                    .info("retrieve all user exercisaries")
                    .error(error)
                    .status("failed")
                    .build();
            return ResponseEntity.badRequest().body(response);
        }
    }

    // UPDATE
    @PutMapping
    public ResponseEntity<?> updateExercisary(@RequestBody ExerciseDTO dto) {
        try {
            log.info("update! ${}", dto);
            ExerciseEntity entity = ExerciseDTO.toEntity(dto);

            ExerciseEntity responseEntity = exerciseService.updateExercisary(entity);

            ExerciseDTO dtos = new ExerciseDTO(responseEntity);
            log.info("update dto is : ${}", dtos);
            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder()
                    .info("update exercisary")
                    .data(Collections.singletonList(dtos))
                    .status("succeed")
                    .build();

            return ResponseEntity.ok().body(response);

        } catch(Exception e) {
            String error = e.getMessage();
            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder()
                    .info("update exercisary")
                    .error(error)
                    .status("failed")
                    .build();
            return ResponseEntity.badRequest().body(response);
        }
    }

    @DeleteMapping("/{key}")
    public ResponseEntity<?> deleteSchedule(@PathVariable("key") String key) {
        try {
            ExerciseEntity entity = exerciseService.retrieveExercisaryByKey(key);

            List<ExerciseEntity> entities = exerciseService.deleteExercisary(entity);

            List<ExerciseDTO> exerciseDTOS = entities.stream().map(ExerciseDTO::new).collect(Collectors.toList());

            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder()
                    .info("delete exercisary")
                    .data(exerciseDTOS)
                    .status("succeed")
                    .build();
            log.info("response delete : {}", response);
            return ResponseEntity.ok().body(response);

        } catch(Exception e) {
            String error = e.getMessage();
            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder()
                    .info("delete exercisary")
                    .error(error)
                    .status("failed")
                    .build();
            return ResponseEntity.badRequest().body(response);
        }
    }

}
