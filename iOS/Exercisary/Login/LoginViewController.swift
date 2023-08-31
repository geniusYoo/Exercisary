//
//  LoginViewController.swift
//  Exercisary
//
//  Created by 유영재 on 2023/08/21.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var recheckLabel: UILabel!
    
    let server = Server()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        var id = idTextField.text
        var pw = pwTextField.text
        
        DispatchQueue.global().async { [self] in
            server.signIn(requestURL: "signin", requestBody: ["userId": id, "password": pw]) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                if let data = data {
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                       let json = jsonObject as? [String: Any],
                       let dataArray = json["data"] as? [[String: Any]] {
                        for dataEntry in dataArray {
                            if let userId = dataEntry["userId"] {
                                let userName = dataEntry["userName"] as? String ?? ""
                                DispatchQueue.main.async {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)

                                    let vc = storyboard.instantiateViewController(withIdentifier: "Home") as! ViewController
                                    let navigationController = UINavigationController(rootViewController: vc)
                                    
                                    navigationController.modalPresentationStyle = .fullScreen
                                    vc.userName = userName
                                    vc.userId = userId as? String ?? ""
                                    recheckLabel.isHidden = true
                                    self.present(navigationController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        recheckLabel.isHidden = false
                    }
                }
      
            }
            
        }
    }
    
    @IBAction func signinButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUp") as! SignUpViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
