package com.example.exercisary.service;

import com.example.exercisary.dto.ExerciseDTO;
import com.example.exercisary.model.ExerciseEntity;
import com.example.exercisary.persistence.ExerciseRepository;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.gridfs.GridFsResource;
import org.springframework.data.mongodb.gridfs.GridFsTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;

@Slf4j
@Service
public class ExerciseService {

    @Autowired
    ExerciseRepository exerciseRepository;

    @Autowired
    private GridFsTemplate gridFsTemplate;

    public ExerciseEntity create(ExerciseEntity entity, MultipartFile file) throws IOException {

        // validation
        if(entity == null || entity.getUserId() == null ) {
            throw new RuntimeException("Invalid arguments");
        }

        // 새 ObjectId 생성
        ObjectId objectId = new ObjectId();

        // ObjectId를 문자열로 변환
        String id = objectId.toHexString();

        // 24자리 UUID + userId 형식. 예) 651d58645f3b0630f3c4ca04_geniuus
        String fileName = id + "_" + entity.getUserId();

        // GridFs에 저장, 두번째 파라미터는 filename 지정하는 거임
        gridFsTemplate.store(file.getInputStream(), fileName);

        entity.setPhotoUrl(fileName);

        log.info("fileId is : {}", fileName);

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

    // 사용자가 가지고 있는 Exercisary들 모두 검색 + 해당 데이터의 이미지까지 모두 검색해서 붙여야 함 (어디다가? => DTO에!)
    public List<ExerciseDTO> retrieve(String userId) {

        // 사용자의 모든 Exercisary 검색
        List<ExerciseEntity> entities = exerciseRepository.findByUserId(userId);
        List<ExerciseDTO> dtos = new ArrayList<>();
        // 모든 entity에 대한 Loop
        for (ExerciseEntity entity: entities) {
            // 각 entity의 photoUrl에 아이디를 저장해뒀으니, 그걸로 쿼리 만들어서 resource 반환
            if (entity.getPhotoUrl().equals("")) {
                continue;
            }
//            Query query = Query.query(Criteria.where("filename").is(entity.getPhotoUrl()));

//            GridFsResource resource = gridFsTemplate.getResource(entity.getPhotoUrl());
            GridFsResource [] resources = gridFsTemplate.getResources("*_" + userId);
            if (resources != null) {
                try {
                    for (GridFsResource resource : resources) {
                        // 리소스와 엔티티를 매칭해야 함
                        if (resource.getFilename().equals(entity.getPhotoUrl())) {

                            // 그 리소스로 바이너리 파일 로드 후 DTO에 세팅, DTO List에 add
                            byte[] data = resource.getInputStream().readAllBytes();

                            // Base64로 인코딩해 DTO에 주입
                            String base64ImageData = Base64.getEncoder().encodeToString(data);
                            ExerciseDTO dto = new ExerciseDTO(entity);
                            dto.setBase64ImageData(base64ImageData);
                            dtos.add(dto);
                        }

                        else continue;

                    }

                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        return dtos;

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
