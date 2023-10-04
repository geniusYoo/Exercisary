//
//  ViewController.swift
//  Exercisary
//
//  Created by 유영재 on 2023/06/13.
//

import UIKit
import FSCalendar

class ViewController: UIViewController {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countButton: UIButton!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var calendarView: FSCalendar!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!

    @IBOutlet weak var userNameLabel: UILabel!
    
    var selectDate = Date()
    var selectDateString = ""
    
    var backDate = ""
    
    var data : [Exercise.Format] = []
    var filtered : [Exercise.Format] = []
    
    var userName: String! // 회원가입할 때 사용자가 지정한 이름으로 메인 뷰에 표시하기 위한 변수
    var userId: String! // 유저의 아이디를 key로 데이터를 로딩하기 위해
    
    let deleteConfirmAlert = UIAlertController(title: "Exercisary 삭제", message: "이 기록을 삭제하시겠습니까?", preferredStyle: .alert) // 삭제 시 띄울 Alert

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Exercise.shared.exercices = []
        filtered = []
        data = []
        serverCall()
        calendarView.reloadData()
        detailCollectionView.reloadData()
        backgroundView.reloadInputViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarConfiguration()
        backgroundView.isHidden = true
        backgroundView.layer.borderColor = UIColor.systemTeal.cgColor
        backgroundView.layer.borderWidth = 2
        backgroundView.layer.cornerRadius = 20
        userNameLabel.text = userName
        calendarView.reloadData()
    }
    
    // segmentControl로 주간/월간 전환할 때
    @IBAction func changeCalendarMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            changeCalendarScope("month")
        } else {
            changeCalendarScope("week")
            selectDateString = dateToString(format: "MM월 dd일", date: selectDate)
            dateLabel.text = selectDateString
        }
    }
    
    // 생성 버튼이 눌렸을 때
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Add") as! AddExerciseViewController
        
        vc.date = selectDate
        vc.flag = 0
        vc.userId = userId
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func modifyButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Add") as! AddExerciseViewController
        
        vc.userId = userId
        if data.isEmpty { // 수정이 아닌 생성일 때
            vc.date = selectDate
            vc.flag = 0
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            vc.date = selectDate
            vc.data = data[0]
            vc.receiveType = data[0].type
            vc.flag = 1
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // 삭제 버튼이 눌렸을 때
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.present(self.deleteConfirmAlert, animated: true, completion: nil)
        deleteConfirmAlert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [self] action in
            let server = Server()
            DispatchQueue.global().async {
                server.deleteData(requestURL: "exercise/\(data[0].key)") { [self] (data, response, error) in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    if let data = data {
                        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                           let json = jsonObject as? [String: Any],
                           let dataArray = json["data"] as? [[String: Any]] {
                            for dataEntry in dataArray {
                                if let key = dataEntry["key"] as? String {
                                    let date = dataEntry["date"] as? String ?? ""
                                    let type = dataEntry["type"] as? String ?? ""
                                    let time = dataEntry["time"] as? String ?? ""
                                    let content = dataEntry["content"] as? String ?? ""
                                    let memo = dataEntry["memo"] as? String ?? ""
                                    let userId = dataEntry["userId"] as? String ?? ""
                                    let photoUrl = dataEntry["photoUrl"] as? String ?? ""
                                    let base64ImageData = dataEntry["base64ImageData"] as? String ?? ""
                                    
                                    let exerciseData = Exercise.Format(
                                        key: key,
                                        date: date,
                                        type: type,
                                        time: time,
                                        content: content,
                                        memo: memo,
                                        photoUrl: "",
                                        userId: userId,
                                        base64ImageData: ""
                                    )
                                    let index = Exercise.shared.deleteExerciseData(data :exerciseData)
                                    DispatchQueue.main.async {
                                        self.filtered.remove(at: index)
                                        self.updateCollectionView()
                                        self.calendarView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        })
        deleteConfirmAlert.addAction(UIAlertAction(title: "취소", style: .cancel) { action in
            self.dismiss(animated: true)
        })
    }
    
    func serverCall() {
            print("userid \(userId!)")
            let server = Server()
            
            server.getAllData(requestURL: "exercise/\(userId!)") { [self] (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let response = response {
                    print(response)
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        
                        if let dataArray = json?["data"] as? [[String: Any]] {
                            for dataEntry in dataArray {
                                parseEntry(dataEntry)
                            }
                        }
                        DispatchQueue.main.async {
                            self.updateCollectionView()
                            self.calendarView.reloadData()
                        }
                    }
                    catch {
                        print("JSON serialization error: \(error)")
                    }
                }
            }
    }
    
    func parseEntry(_ dataEntry: [String: Any]) {
        if let key = dataEntry["key"] as? String {
            let date = dataEntry["date"] as? String ?? ""
            let type = dataEntry["type"] as? String ?? ""
            let time = dataEntry["time"] as? String ?? ""
            let content = dataEntry["content"] as? String ?? ""
            let memo = dataEntry["memo"] as? String ?? ""
            let userId = dataEntry["userId"] as? String ?? ""
            let photoUrl = dataEntry["photoUrl"] as? String ?? ""
            let base64ImageData = dataEntry["base64ImageData"] as? String ?? ""
            
            let exerciseData = Exercise.Format(
                key: key,
                date: date,
                type: type,
                time: time,
                content: content,
                memo: memo,
                photoUrl: photoUrl,
                userId: userId,
                base64ImageData: base64ImageData
            )
            Exercise.shared.appendExerciseData(data :exerciseData)
            self.filtered.append(exerciseData)
//            print("filtered : \(filtered)")
        }
    }
    
    func updateCollectionView() {
        data = filtered.filter { schedule in
            return schedule.date.contains(dateToString(format: "yyyy.MM.dd", date: selectDate))
        }
        print("filtered after : \(filtered)")
        if data.isEmpty {
            countButton.isHidden = true
        }
        else {
            countButton.isHidden = false
        }
        detailCollectionView.reloadData()
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! DetailCollectionViewCell
        
        let exercises = data[indexPath.item]
        print("index : \(indexPath)")
        print("exercises filter : \(exercises)")
        cell.typeLabel.text = exercises.type
        cell.timeLabel.text = exercises.time
        cell.contentLabel.text = exercises.content
        cell.memoLabel.text = exercises.memo
        cell.stampLabel.text = String(exercises.type.prefix(1))
        
        let imageData = Data(base64Encoded: exercises.base64ImageData)
        cell.imageView1.image = UIImage(data: imageData ?? Data())

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

}

extension ViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let day = Calendar.current.component(.weekday, from: date) - 1
        
        if Calendar.current.shortWeekdaySymbols[day] == "일" {
            return .red
        } else if Calendar.current.shortWeekdaySymbols[day] == "토" {
            return .blue
        } else {
            return .black
        }
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 선택한 날짜에 해당하는 데이터 가져오기
        
        self.selectDate = date
        print("date select : \(selectDate)")

        dateLabel.text = dateToString(format: "M월 dd일", date: date)
        updateCollectionView()
        changeCalendarScope("week")
        segmentControl.selectedSegmentIndex = 1

        // 애니메이션 적용
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool){
        calendarViewHeight.constant = bounds.height
        
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let dateString = dateToString(format: "yyyy.MM.dd", date: date)
            
            // filtered 배열에서 해당 날짜와 일치하는 데이터 찾기
            if let matchingData = filtered.first(where: { $0.date == dateString }) {
                // 일치하는 데이터의 type을 subtitle로 반환
                return matchingData.type
            }
            
            // 해당 날짜에 일치하는 데이터가 없을 경우 nil 반환
            return nil
    }
}

extension ViewController {
    func dateToString(format: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func dateToDate(format: String, date: Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = .current
        let dateString = dateToString(format: format, date: date)
        return dateFormatter.date(from: dateString)!
    }

    func changeCalendarScope(_ scope: String) {
        if scope == "month" {
            calendarView.setScope(.month, animated: true)
            backgroundView.isHidden = true
            // 애니메이션 적용
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        else if scope == "week" {
            calendarView.setScope(.week, animated: true)
            backgroundView.isHidden = false
            detailCollectionView.reloadData()
            // 애니메이션 적용
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func fixOrientation(img: UIImage) -> UIImage {

        if (img.imageOrientation == .up) {
            return img
        }

        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
    
    func calendarConfiguration() {
        calendarView.delegate = self
        calendarView.dataSource = self
        
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        
        calendarView.layer.cornerRadius = 20
        
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.placeholderType = .fillHeadTail

        // 상단 헤더 관련
        calendarView.appearance.headerMinimumDissolvedAlpha = 0 // header의 이번 달만 표시
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.headerTitleColor = .label
        calendarView.headerHeight = 80 // YYYY년 M월 표시부 영역 높이
        calendarView.weekdayHeight = 20 // 날짜 표시부 행의 높이
        calendarView.rowHeight = 10
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 24) //타이틀 폰트 크기

        // 캘린더(날짜 부분) 관련
        calendarView.backgroundColor = .white
        calendarView.appearance.selectionColor = .systemTeal.withAlphaComponent(0.4)
        calendarView.appearance.weekdayTextColor = .label
//        calendarView.appearance.titleDefaultColor = .label  // 평일
//        calendarView.appearance.titleWeekendColor = .red    // 주말
        

        // 오늘 날짜 관련
        calendarView.appearance.todayColor = .systemTeal.withAlphaComponent(0.9) // 오늘 날짜에 표시되는 선택 전 동그라미 색
        calendarView.appearance.titleTodayColor = .black // 오늘 날짜에 표시되는 특정 글자 색
        calendarView.appearance.titleSelectionColor = .black
        
        // Month 폰트 설정
        calendarView.appearance.headerTitleFont = UIFont(name: "NotoSansCJKKR-Medium", size: 16)
                
        // day 폰트 설정
        calendarView.appearance.titleFont = UIFont(name: "Roboto-Regular", size: 14)
        }
}
