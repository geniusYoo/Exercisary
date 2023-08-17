package com.example.exercisary.controller;

import com.example.exercisary.service.ExerciseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

@Slf4j
@Controller
public class ExerciseController {

    @Autowired
    private ExerciseService exerciseService;

    @PostMapping()

}
