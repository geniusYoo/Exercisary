//
//  Exercise.swift
//  Exercisary
//
//  Created by 유영재 on 2023/06/14.
//

import Foundation

struct ExerciseInfo {
    var key: String // 고유 키
    var date: String // 운동한 날짜
    var type: String // 운동 종류
    var time: String // 운동한 시간
    var content: String // 운동 내용
    var memo: String
    var photoUrl: String
    var userId: String // 생성한 유저 아이디
}

class Exercise {
    // exercise 객체
    static let exercise = Exercise()
    
    // 로컬에서 데이터를 받아오고, 업데이트할 때 사용할 Exercise 객체 배열
    var exercices: [ExerciseInfo] = []

    func appendExerciseData(data: ExerciseInfo) {
        exercices.append(data)
    }
    
    func findAndUpdateExerciseData(data: ExerciseInfo) {
        if let index = Exercise.exercise.exercices.firstIndex(where: { $0.key == data.key }) {
            // 특정 식별자를 가진 아이템의 인덱스를 찾음
            exercices[index] = data
        }
    }
    
    func deleteExerciseData(data: ExerciseInfo) {
        if let index = Exercise.exercise.exercices.firstIndex(where: { $0.key == data.key }) {
            // 특정 식별자를 가진 아이템의 인덱스를 찾음
            exercices.remove(at: index)
        }
    }

}
