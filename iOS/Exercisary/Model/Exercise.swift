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

    struct Format {
        var key: String
        var date: Date
        var dateString: String
        var type: String
        var time: String
        var content: String
        var memo: String
        var photoUrl: String
    }
    
    func updateExerciseData(data: Format) {
        exercices.append(data)
    }
    
}
