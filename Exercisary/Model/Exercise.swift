//
//  Exercise.swift
//  Exercisary
//
//  Created by 유영재 on 2023/06/14.
//

import Foundation

class Exercise {
    static let shared = Exercise()
    var exercices: [Format] = []

    private init() {}

    struct Format {
        var key: String
        var date: Date
        var dateString: String
        var exerciseType: String
        var exerciseTime: String
        var memo: String
    }
    
    func updateExerciseData(data: Format) {
        exercices.append(data)
    }
    
}
