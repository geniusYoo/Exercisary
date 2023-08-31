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
    
    let confirmAlert = UIAlertController(title: "회원 정보 확인", message: "아래 정보가 맞습니까?", preferredStyle: .alert)

   
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        idTextField.delegate = self
        pwTextField.delegate = self

    }
        // UITextFieldDelegate 메서드 - 텍스트필드가 터치되었을 때 호출됨
        func textFieldDidBeginEditing(_ textField: UITextField) {
            // 키보드 올리기
            textField.becomeFirstResponder()
        }

        // UITextFieldDelegate 메서드 - Return 키를 누를 때 호출됨
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == self.nameTextField {
                self.idTextField.becomeFirstResponder()
            }
            else if textField == idTextField {
              pwTextField.becomeFirstResponder()
            }
            else if textField == pwTextField {
                pwTextField.resignFirstResponder()
                confirm()
            }
            return true
        }

        // 다른 영역을 터치했을 때 키보드 내리기
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
    
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        confirm()
    }
    
    private func confirm() {
        var userId = idTextField.text
        var userName = nameTextField.text
        var password = pwTextField.text
        
        let msg = "\n이름 : \(userName!) \n\n아이디 : \(userId!)\n"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left

        let messageText = NSMutableAttributedString(
            string: msg,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)
             ]
        )

        confirmAlert.setValue(messageText, forKey: "attributedMessage")
        
        self.present(self.confirmAlert, animated: true, completion: nil)
        confirmAlert.addAction(UIAlertAction(title: "맞아요", style: .default) { action in
            
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)

            let vc = storyboard.instantiateViewController(withIdentifier: "Select") as! SelectViewController
            vc.modalPresentationStyle = .fullScreen
            var user = UserInfo(userId: self.idTextField.text ?? "", userName: self.nameTextField.text ?? "", password: self.pwTextField.text ?? "", preferredType: "")
            vc.user = user
            self.present(vc, animated: true)
        })

        confirmAlert.addAction(UIAlertAction(title: "아니예요", style: .cancel) { action in
            self.dismiss(animated: true)
        })
    }
    
    


}
