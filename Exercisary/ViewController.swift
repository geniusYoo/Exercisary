//
//  ViewController.swift
//  Exercisary
//
//  Created by 유영재 on 2023/06/13.
//

import UIKit
import FSCalendar
import Firebase
import FirebaseFirestore

class ViewController: UIViewController {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var calendarView: FSCalendar!
    
    // Firebase 참조 객체
    var reference: CollectionReference!
    
    var selectDate = Date()
    var selectDateString = ""
    
    var backDate = ""
    var data: Exercise?
    
    // 삭제 시 띄울 Alert
    let deleteConfirmAlert = UIAlertController(title: "오운완 삭제", message: "이 오운완을 삭제하시겠습니까?", preferredStyle: .alert)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 뷰가 로드되면 사용자가 갖고 있는 모든 운동 기록 데이터를 fetch, 뷰 리로딩
        ExerciseViewModel.shared.fetchEvents { [self] result in
            switch result {
            case .success(let events):
                // 데이터 가져오기 성공 시 처리
                print("Fetching success") // 예시: events 배열을 출력하거나 다른 작업 수행
            case .failure(let error):
                // 데이터 가져오기 실패 시 처리
                print("Error fetching events: \(error)")
            }
            detailCollectionView.reloadData()
            calendarView.reloadData()
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarConfiguration()
        detailCollectionView.reloadData()
        
        dateLabel.text = dateToString(dateFormatString: "MM월 dd일", date: selectDate)
    }
    
    // 생성 버튼이나 수정 버튼이 눌렸을 때
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Add") as! AddExerciseViewController
        vc.date = dateToString(dateFormatString: "yyyy.MM.dd", date: selectDate)
        
        if sender.tag == 1 { // 생성
            navigationController?.pushViewController(vc, animated: true)
        }
        
        else if sender.tag == 2 { // 수정
            let filtered = ExerciseViewModel.shared.exercises.filter { $0.dateString == dateToString(dateFormatString: "yyyy.MM.dd", date: selectDate) }
            vc.exerciseType = filtered.first?.exerciseType ?? ""
            vc.exerciseTime = filtered.first?.exerciseTime ?? ""
            vc.memo = filtered.first?.memo ?? ""
            print("filtered : \(filtered)")
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // 삭제 버튼이 눌렸을 때
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.present(self.deleteConfirmAlert, animated: true, completion: nil)
        deleteConfirmAlert.addAction(UIAlertAction(title: "삭제", style: .destructive) { action in
            
            ExerciseViewModel.shared.deleteEvent(exercise: self.data ?? Exercise(key: "", date: Date(), exerciseType: "", exerciseTime: "", memo: "", photoURL: "")) { result in
                switch result {
                case .success:
                    print("delete success")
                    self.viewWillAppear(true)
                    
                case .failure:
                    print("delete fail")
                }
            }
        })
        
        deleteConfirmAlert.addAction(UIAlertAction(title: "취소", style: .cancel) { action in
        self.dismiss(animated: true)
        })
    }
    
    func calendarConfiguration() {
        calendarView.delegate = self
        calendarView.dataSource = self
        
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        
        calendarView.layer.cornerRadius = 20

        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0 // header의 이번 달만 표시
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.headerTitleColor = .label
        
        calendarView.appearance.eventDefaultColor = .systemGreen
        calendarView.appearance.eventSelectionColor = .systemGreen
        
        calendarView.appearance.todayColor = .systemGreen
        calendarView.appearance.selectionColor = .white
        calendarView.appearance.titleDefaultColor = .label
        calendarView.appearance.titleTodayColor = .black
        calendarView.appearance.titleSelectionColor = .black
        calendarView.appearance.weekdayTextColor = .label
        
        calendarView.locale = Locale(identifier: "ko_KR")
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! DetailCollectionViewCell
        
        let filtered = ExerciseViewModel.shared.exercises.filter { $0.dateString == dateToString(dateFormatString: "yyyy.MM.dd", date: selectDate) }
        
        if !filtered.isEmpty {
            // 해당 날짜에 등록된 데이터가 있을 때 표시
            cell.markerView.isHidden = false
            addButton.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
            addButton.tag = 2
            cell.kindLabel.text = filtered.first?.exerciseType
            cell.timeLabel.text = filtered.first?.exerciseTime
            cell.memoLabel.text = filtered.first?.memo
            
            // 해당 날짜에 등록된 데이터에 사진이 포함되어있는지 UserDefaults에서 조회
            let urlString = UserDefaults.standard.string(forKey: filtered.first!.dateString) ?? ""
            
            // 있으면 Storage에서 꺼내서 imageView에 적용
            if urlString != "" {
                FirebaseStorageManager.downloadImage(urlString: urlString) { [weak self] image in
                    cell.imageView.isHidden = false
                    cell.imageView.image = image
                }
            }
//            else {
//                cell.imageView.isHidden = true
//            }
            self.data = filtered.first
            
        } else {
            // 해당 날짜에 등록된 데이터가 없을 때 표시
            cell.markerView.isHidden = true
            addButton.setImage(UIImage(systemName: "plus.app"), for: .normal)
            cell.kindLabel.text = "운동 안했으면 얼른 하고! 했으면 얼른 등록하고!"
            cell.timeLabel.text = ""
            cell.memoLabel.text = ""
            cell.imageView.isHidden = true
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
}

extension ViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, weekdayTextColorFor weekday: Int) -> UIColor? {
        if weekday == 1 {
            return .red
        } else if weekday == 7 {
            return .blue
        } else {
            return .black
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 선택한 날짜에 해당하는 데이터 가져오기
        
        let dateString = dateToString(dateFormatString: "yyyy.MM.dd", date: date)

        selectDate = date
        selectDateString = dateString
        
        dateLabel.text = dateToString(dateFormatString: "MM월 dd일", date: date)
        
        detailCollectionView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = dateToString(dateFormatString: "yyyy.MM.dd", date: date)
        
        let eventsCount = ExerciseViewModel.shared.exercises.filter { $0.dateString == dateString }.count
        
        return eventsCount
    }
}

extension ViewController {
    func dateToString(dateFormatString: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatString
        return dateFormatter.string(from: date)
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
}

