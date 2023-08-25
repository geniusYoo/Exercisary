//
//  SelectViewController.swift
//  Exercisary
//
//  Created by 유영재 on 2023/08/24.
//

import UIKit

class SelectViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet var radioButtons: [UIButton]!
    
    var userName: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        typeTextField.delegate = self
        self.radioButtons.forEach {
            $0.addTarget(self, action: #selector(self.radioButton(_ :)), for: .touchUpInside)
            $0.layer.cornerRadius = 15
            $0.layer.backgroundColor = UIColor.lightGray.cgColor
        }
    }
    
    // UITextFieldDelegate 메서드 - 텍스트필드가 터치되었을 때 호출됨
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 키보드 올리기
        textField.becomeFirstResponder()
    }
    
    // 다른 영역을 터치했을 때 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc private func radioButton(_ sender: UIButton) {
        self.radioButtons.forEach {
            if $0.tag == sender.tag {
//                $0.backgroundColor = UIColor.systemTeal
                $0.layer.backgroundColor = UIColor.systemTeal.cgColor
            } else {
                $0.backgroundColor = UIColor.lightGray
            }
        }
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        var extraType = typeTextField.text
        radioButtons[3].isHidden = false
        radioButtons[3].setTitle(extraType, for: .normal)
        radioButtons[3].backgroundColor = UIColor.systemTeal
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "Home") as! ViewController
        let navigationController = UINavigationController(rootViewController: vc)
        
        navigationController.modalPresentationStyle = .fullScreen
        vc.userName = userName

        self.present(navigationController, animated: true, completion: nil)
    }
}
