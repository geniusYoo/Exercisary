//
//  Server.swift
//  Exercisary
//
//  Created by 유영재 on 2023/08/24.
//

import Foundation
import UIKit

class Server {
    var baseURL = "http://localhost:9090/"
    var result: String = ""
    
    func signUp(requestURL: String, requestBody:[String:Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void){
        guard let url = URL(string: Server().baseURL + requestURL) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = data
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return } // 응답 데이터가 nil이 아닌지 확인.
            if let responseString = String(data: data, encoding: .utf8) {
                completion(data, response, error)
            }
            
        }
        task.resume()
    }
    
    func signIn(requestURL: String, requestBody: [String:Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = data
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil, nil, nil) // 응답 데이터가 없는 경우 nil 반환
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let token = jsonResponse?["token"] as? String
                completion(data, response, error) // 응답 데이터 중 "token" 값을 반환
            } catch {
                completion(nil, nil, nil) // 파싱 오류 발생 시 nil 반환
            }
        }
        task.resume()
    }
    
    func postDataToServer(requestURL: String, requestData: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            request.httpBody = jsonData
        } catch {
            completion(nil, nil, error) // JSON 데이터 변환 오류 발생 시 completion에 오류 전달
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }
    
    func postDataToServerWithImage(image: UIImage, requestURL: String, requestData: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        let resizeImage = resizeImage(image, targetSize: CGSize(width: 800, height: 600))
        guard let imageData = resizeImage.jpegData(compressionQuality: 1.0) else {
                return
        }
        
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 이미지 데이터 추가
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"jsondata\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(jsonData)
            body.append("\r\n".data(using: .utf8)!)
        } catch {
            completion(nil, nil, error) // JSON 데이터 변환 오류 발생 시 completion에 오류 전달
            return
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let session = URLSession.shared
        let task = session.uploadTask(with: request, from: nil) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }
    
    func getAllData(requestURL: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }
    
    func updateData(requestURL: String, requestData: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            request.httpBody = jsonData
        } catch {
            completion(nil, nil, error) // JSON 데이터 변환 오류 발생 시 completion에 오류 전달
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }
    
    func updateDataWithImage(image: UIImage, requestURL: String, requestData: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 이미지 데이터 추가
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"jsondata\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(jsonData)
            body.append("\r\n".data(using: .utf8)!)
        } catch {
            completion(nil, nil, error) // JSON 데이터 변환 오류 발생 시 completion에 오류 전달
            return
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let session = URLSession.shared
        let task = session.uploadTask(with: request, from: nil) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }
    
    func deleteData(requestURL: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }
    
}
