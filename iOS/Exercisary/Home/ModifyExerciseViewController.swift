//
//  ModifyExerciseViewController.swift
//  Exercisary
//
//  Created by 유영재 on 2023/08/24.
//

import UIKit

class ModifyExerciseViewController: UIViewController {
    
    @IBOutlet weak var kindTextField: UITextField!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var radioButtons: [UIButton]!
    
    var selectedButton = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.layer.cornerRadius = 20
        
        self.radioButtons.forEach {
            $0.addTarget(self, action: #selector(self.radioButton(_ :)), for: .touchUpInside)
            $0.layer.cornerRadius = 15
            $0.layer.backgroundColor = UIColor.lightGray.cgColor
        }
    }
    
    @objc private func radioButton(_ sender: UIButton) {
        self.radioButtons.forEach {
            if $0.tag == sender.tag {
//                $0.backgroundColor = UIColor.systemTeal
                $0.layer.backgroundColor = UIColor.systemTeal.cgColor
                selectedButton = sender.tag
            } else {
                $0.backgroundColor = UIColor.lightGray
            }
        }
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        radioButtons[3].setTitle(kindTextField.text, for: .normal)
        radioButtons[3].isHidden = false
        radioButtons[3].backgroundColor = UIColor.systemTeal

    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let vc = self.navigationController?.viewControllers[1] as? AddExerciseViewController else{
            return
        }
        vc.sendingType(type: radioButtons[selectedButton-1].currentTitle ?? "")

        navigationController?.popViewController(animated: true)
    }
}
