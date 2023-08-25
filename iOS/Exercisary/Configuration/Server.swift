//
//  Server.swift
//  Exercisary
//
//  Created by 유영재 on 2023/08/24.
//

import Foundation

class Server {
    var baseURL = "http://3.35.149.87:8080/"
    var result: String = ""
    
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
    
    func postDataToServer(requestURL: String, requestData: [String: Any], token: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        var header = "Bearer \(token)"
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
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
    
    func getAllData(requestURL: String, token: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        let header = "Bearer \(token)"
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }

    func deleteData(requestURL: String, token: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        let header = "Bearer \(token)"
        request.httpMethod = "DELETE"
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }
    
    func updateData(requestURL: String, requestData: [String: Any], token: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        var header = "Bearer \(token)"
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
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
    
}