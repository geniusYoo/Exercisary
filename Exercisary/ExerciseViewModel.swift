//
//  ExerciseViewModel.swift
//  Exercisary
//
//  Created by 유영재 on 2023/06/20.
//

import Foundation
import Firebase

// Exercise를 이용해 Firebase에 데이터를 집어넣고, 빼는 메소드들 정의
class ExerciseViewModel {
    static let shared = ExerciseViewModel()
    
    var exercises: [Exercise] = []
    
    private var db: Firestore
    
    private var listener: ListenerRegistration?
    
    init() {
        // Firebase 초기화
        FirebaseApp.configure()
        db = Firestore.firestore()
    }
    
    // 데이터를 전부 받아옴
    func fetchEvents(completion: @escaping (Result<[Exercise], Error>) -> Void) {
        // 컬렉션에서 데이터 fetch
        db.collection("exerciseRecords").getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            var events: [Exercise] = []
            
            // 데이터 parsing
            for document in snapshot!.documents {
                guard let exerciseDict = document.data() as? [String: Any?] else {
                    continue
                }
                
                var exercise = Exercise(key: "", date: Date(), exerciseType: "", exerciseTime: "", memo: "", photoURL: "")
                exercise.toExercise(dict: exerciseDict)
                events.append(exercise)
            }
            self.exercises = events
            completion(.success(events))
        }
    }
    
    // 생성
    func addEvent(exercise: Exercise, completion: @escaping (Result<Void, Error>) -> Void) {
        var event = exercise
        
        // Firestore에 데이터 추가
        db.collection("exerciseRecords").document(exercise.key).setData(exercise.toDict()) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    // 수정
    func updateEvent(exercise: Exercise, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection("exerciseRecords").document(exercise.key)
        
        // Firestore에 데이터 업데이트
        reference.updateData(exercise.toDict()) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    // 삭제
    func deleteEvent(exercise: Exercise, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection("exerciseRecords").document(exercise.key)
        
        // Firestore에서 데이터 삭제
        reference.delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    // 실시간 업데이트 리스너 등록
    func startListening(completion: @escaping (Result<[Exercise], Error>) -> Void) {
        // 리스너가 이미 등록된 경우 중복 등록 방지
        guard listener == nil else {
            return
        }
        
        // 파이어베이스 실시간 업데이트 리스너 등록
        listener = db.collection("exerciseRecords").addSnapshotListener { (snapshot, error) in
            if let error = error {
                // 에러 처리
                completion(.failure(error))
                return
            }
            
            var events: [Exercise] = []
            
            // 스냅샷을 이용해 데이터 파싱
            for document in snapshot!.documents {
                guard let eventDict = document.data() as? [String: Any?] else {
                    continue
                }
                
                var event = Exercise(key: "", date: Date(), exerciseType: "", exerciseTime: "", memo: "", photoURL: "")
                event.toExercise(dict: eventDict)
                events.append(event)
            }
            
            self.exercises = events
            
            // 완료 처리
            completion(.success(events))
        }
    }
    
    // 실시간 업데이트 리스너 중지
    func stopListening() {
        // 리스너가 등록된 경우에만 중지
        guard let listener = listener else {
            return
        }
        
        listener.remove()
        self.listener = nil
    }
}

