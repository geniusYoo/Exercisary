//
//  Functions.swift
//  Exercisary
//
//  Created by 유영재 on 2023/06/20.
//

import Foundation
import UIKit

func stringFromDate(date: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}

func dateFromString(dateString: String, format: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: dateString) ?? Date()
}

func getStartAndEndDateOfMonth(for date: Date) -> (start: Date, end: Date)? {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)
    
    guard let startOfMonth = calendar.date(from: components),
          let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
        return nil
    }
    
    return (startOfMonth, endOfMonth)
}
// 이미지 크기를 조정하는 함수
func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    return renderer.image { (context) in
        image.draw(in: CGRect(origin: .zero, size: targetSize))
    }
}

