//
//  Exercise.swift
//  Exercisary
//
//  Created by 유영재 on 2023/06/14.
//

import Foundation



class Exercise {
    // exercise 객체
    static let shared = Exercise()
    
    // 로컬에서 데이터를 받아오고, 업데이트할 때 사용할 Exercise 객체 배열
    var exercices: [Format] = []

    private init() {}
    
    struct Format {
        var key: String // 고유 키
        var date: String // 운동한 날짜
        var type: String // 운동 종류
        var time: String // 운동한 시간
        var content: String // 운동 내용
        var memo: String
        var photoUrl: String // GridFs에 저장되는 filename
        var userId: String // 생성한 유저 아이디
        var base64ImageData: String // base64로 인코딩된 이미지 데이터
    }
    
    func appendExerciseData(data: Format) {
        exercices.append(data)
    }
    
    func findAndUpdateExerciseData(data: Format) {
        if let index = Exercise.shared.exercices.firstIndex(where: { $0.key == data.key }) {
            // 특정 식별자를 가진 아이템의 인덱스를 찾음
            exercices[index] = data
        }
    }
    
    func deleteExerciseData(data: Format) -> Int {
        var responseIndex = 0
        if let index = Exercise.shared.exercices.firstIndex(where: { $0.key == data.key }) {
            // 특정 식별자를 가진 아이템의 인덱스를 찾음
            exercices.remove(at: index)
            responseIndex = index
        }
        return responseIndex
    }
    
    

}
