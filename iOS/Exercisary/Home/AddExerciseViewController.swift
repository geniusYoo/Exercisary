//
//  AddExerciseViewController.swift
//  Exercisary
//
//  Created by 유영재 on 2023/06/14.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage


class AddExerciseViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var memoTextField: UITextField!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var addImageButton: UIButton!
    
    let imagePickerController = UIImagePickerController()
    var image: UIImage!
    let alertController = UIAlertController(title: "올릴 방식을 선택하세요", message: "사진 찍기 또는 앨범에서 선택", preferredStyle: .actionSheet)
    
    var data = Exercise.Format(key: "", date: "", type: "", time: "", content: "", memo: "", photoUrl: "", userId: "")
    
    var userId = ""
    
    var date = Date()
    
    var flag = 0 // 생성인지, 수정인지 알 수 있는 플래그, 0이면 생성 1이면 수정
    
    var receiveType = ""
    
    let server = Server()
    
    override func viewWillAppear(_ animated: Bool) {
        backgroundView.reloadInputViews()
        self.typeButton.setTitle(receiveType, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        enrollAlertEvent()
        setupUI()
        memoTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
            self.view.endEditing(true)
      }
    
    func sendingType(type: String) {
        self.receiveType = type
        print("type!! \(type), \(receiveType)")
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // 키보드 내리면서 동작
        textField.resignFirstResponder()
        return true
    }
    
    // 이미지 위의 버튼이 눌렸을 때 AlertController 띄우기
    @objc func imageButtonTapped() {
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func keyboardUp(notification:NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
           let keyboardRectangle = keyboardFrame.cgRectValue
       
            UIView.animate(
                withDuration: 0.3
                , animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
    
    // 수정 시, 데이터를 받아서 채워넣기 위한 메소드
    func setupUI() {
        datePicker.date = date
        print("type : \(data.type)")
        contentTextField.text = data.content ?? ""
        memoTextField.text = data.memo ?? ""
        
        if flag == 0 { // 생성이면
            headerLabel.text = "Exercisary 작성하기 💪🏻"
        }
        else {
            headerLabel.text = "Exercisary 수정하기 🦾"
        }
        
        // exerciseTime은 "2h" 같은 형태로 문자열로 오기 때문에 변환해서 timePicker에 넣어줌.
        if data.time == "" {
            timePicker.countDownDuration = 3600
        }
        else {
            timePicker.countDownDuration = stringToTimeInterval(data.time ?? "")
        }
    }
    
    // Alert에 이벤트들 정의
    func enrollAlertEvent() {
        let photoLibraryAlertAction = UIAlertAction(title: "사진 앨범", style: .default) {
            (action) in
            self.openAlbum()
        }
        let cameraAlertAction = UIAlertAction(title: "카메라", style: .default) {(action) in
            self.openCamera()
        }
        let cancelAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        self.alertController.addAction(photoLibraryAlertAction)
        self.alertController.addAction(cameraAlertAction)
        self.alertController.addAction(cancelAlertAction)
        guard let alertControllerPopoverPresentationController
                = alertController.popoverPresentationController
        else {return}
        prepareForPopoverPresentation(alertControllerPopoverPresentationController)
    }
    
    // 앨범 오픈
    func openAlbum() {
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: false, completion: nil)
    }
    
    // 카메라 오픈
    func openCamera() {
       if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
           self.imagePickerController.sourceType = .camera
           present(self.imagePickerController, animated: false, completion: nil)
       }
       else {
           print ("Camera's not available as for now.")
       }
    }
    
    // 저장 버튼을 눌렀을 때 - 생성/수정
    @IBAction func SaveButtonTapped(_ sender: Any) {
        let type = typeButton.currentTitle ?? ""// 사용자 입력에서 운동 종류를 가져옴
        let time = formatDuration(duration: timePicker.countDownDuration) ?? "" // 사용자 입력에서 운동 시간을 가져옴
        let memo = memoTextField.text ?? ""// 사용자 입력에서 메모를 가져옴
        let content = contentTextField.text ?? ""
        let date = dateToString(date: datePicker.date, format: "yyyy.MM.dd")
        
        DispatchQueue.global().async { [self] in
            if flag == 0 { // 생성
                let exerciseData = Exercise.Format(
                    key: UUID().uuidString,
                    date: date,
                    type: type,
                    time: time,
                    content: content,
                    memo: memo,
                    photoUrl: "",
                    userId: userId
                )
                server.postDataToServer(requestURL: "exercise", requestData: [
                    "key" : exerciseData.key,
                    "date" : exerciseData.date,
                    "type" : exerciseData.type,
                    "time" : exerciseData.time,
                    "content" : exerciseData.content,
                    "memo" : exerciseData.memo,
                    "photoUrl" : exerciseData.photoUrl,
                    "userId" : exerciseData.userId
                    
                ], completion: { (data, response, error) in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    print(response)
                })
            }
            
            else { // 수정
                let exerciseData = Exercise.Format(
                    key: data.key,
                    date: date,
                    type: type,
                    time: time,
                    content: content,
                    memo: memo,
                    photoUrl: "",
                    userId: userId
                )
                server.updateData(requestURL: "exercise", requestData: [
                    "key" : exerciseData.key,
                    "date" : exerciseData.date,
                    "type" : exerciseData.type,
                    "time" : exerciseData.time,
                    "content" : exerciseData.content,
                    "memo" : exerciseData.memo,
                    "photoUrl" : exerciseData.photoUrl,
                    "userId" : exerciseData.userId
                ], completion: { (data, response, error) in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    print(response)
                })
            }
            
            DispatchQueue.main.async {
                guard let vc = self.navigationController?.viewControllers[0] as? ViewController else{
                    return
                }

                navigationController?.popViewController(animated: true)
//                print("exercise data : \(exerciseData)")
            }
        }
        
       
    }
        
    @IBAction func TypeButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "Modify") as! ModifyExerciseViewController
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}



extension AddExerciseViewController {
    func formatDuration(duration: TimeInterval) -> String {
        let totalMinutes = Int(duration / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        var formattedString = ""
        
        if hours > 0 {
            formattedString += "\(hours)h"
        }
        
        if minutes > 0 {
            formattedString += "\(minutes)m"
        }
        
        return formattedString
    }
    
    func stringToTimeInterval(_ time: String) -> TimeInterval {
        let numberString = Int(String(time.split(separator: "h")[0])) ?? 0
        let formatted = numberString * 3600
        
        return TimeInterval(formatted)
    }
    
    func dateToString(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    func stringToDate(dateString: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString) ?? Date()
    }
}

extension AddExerciseViewController: UIPopoverPresentationControllerDelegate {
    // 이것을 안하면 AlertController에 Deprecated 오류가 떠서 추가한 코드.
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        if let popoverPresentationController =
      self.alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect
            = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
    }
}

extension AddExerciseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // imagePicker를 사용해서 이미지가 선택되면 imageView에 선택된 이미지를 로드하고 UserDefaults에 저장
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage]
                as? UIImage {
                self.imageView1.image = image
                
                backgroundView.reloadInputViews()
            }
            else {
                print("error detected in didFinishPickinMediaWithInfo method")
            }
            dismiss(animated: true, completion: nil) // 반드시 dismiss 하기.
        }
}
