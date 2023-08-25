//
//  SignUpViewController.swift
//  Exercisary
//
//  Created by 유영재 on 2023/08/21.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    let confirmAlert = UIAlertController(title: "Exercisary 회원 가입", message: "아래 정보가 맞습니까?", preferredStyle: .alert)

   
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        idTextField.delegate = self
        pwTextField.delegate = self

    }
    // UITextFieldDelegate 메서드 - 텍스트필드가 터치되었을 때 호출됨
        func textFieldDidBeginEditing(_ textField: UITextField) {
            // 키보드 올리기
            print("call")
            textField.becomeFirstResponder()
        }

        // UITextFieldDelegate 메서드 - Return 키를 누를 때 호출됨
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // 편집 완료 후 키보드 내리기
            textField.resignFirstResponder()

            return true
        }

        // 다른 영역을 터치했을 때 키보드 내리기
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
    
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        var id = idTextField.text
        var name = nameTextField.text
        var pw = pwTextField.text
        
        confirmAlert.message = "아래 정보가 맞습니까? \n 아이디 : \(id) \n 이름 : \(name)"
        self.present(self.confirmAlert, animated: true, completion: nil)
        confirmAlert.addAction(UIAlertAction(title: "맞아요", style: .default) { action in
            
            
        })

        confirmAlert.addAction(UIAlertAction(title: "아니예요", style: .cancel) { action in
            self.dismiss(animated: true)
        })
    }
    


}
