package com.example.exercisary.dto;

import java.util.List;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Data;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class ResponseDTO<T> {
    // DTO가 여러개의 형태일 수 있으므로 List 형태로
    private List<T> data;

    // 성공, 실패 시 String으로 succeed, failed 전송
    private String status;

    private String error;

    // 어떠한 response인지에 대한 정보
    private String info;
}
