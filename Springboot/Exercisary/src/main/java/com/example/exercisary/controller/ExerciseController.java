//package com.example.exercisary.controller;
//
//import com.example.exercisary.dto.ExerciseDTO;
//import com.example.exercisary.dto.ResponseDTO;
//import com.example.exercisary.model.ExerciseEntity;
//import com.example.exercisary.service.ExerciseService;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.http.ResponseEntity;
//import org.springframework.security.core.annotation.AuthenticationPrincipal;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.PostMapping;
//import org.springframework.web.bind.annotation.RequestBody;
//import org.springframework.web.bind.annotation.RequestMapping;
//
//import java.util.Collections;
//
//@Slf4j
//@Controller
//@RequestMapping("/exercise")
//public class ExerciseController {
//
//    @Autowired
//    private ExerciseService exerciseService;
//
//    @PostMapping
//    public ResponseEntity<?> createExercisary(@AuthenticationPrincipal String userId, @RequestBody ExerciseDTO dto) {
//        try {
//            ExerciseEntity entity = ExerciseDTO.toEntity(dto);
//
//            entity.setUserId(userId);
//
//            entity = exerciseService.createExercisary(entity);
//
//            ExerciseDTO dtos = new ExerciseDTO(entity);
//
//            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder().data(Collections.singletonList(dtos)).status("succeed").build();
//
//            return ResponseEntity.ok().body(response);
//
//        } catch(Exception e) {
//            String error = e.getMessage();
//            ResponseDTO<ExerciseDTO> response = ResponseDTO.<ExerciseDTO>builder().error(error).build();
//            return ResponseEntity.badRequest().body(response);
//        }
//    }
//}
