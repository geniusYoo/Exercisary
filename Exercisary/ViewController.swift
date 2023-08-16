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
    @IBOutlet weak var countButton: UIButton!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var calendarView: FSCalendar!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    // Firebase 참조 객체
    
    var selectDate = Date()
    var selectDateString = ""
    
    var backDate = ""
    var data: Exercise?
    
    // 삭제 시 띄울 Alert
    let deleteConfirmAlert = UIAlertController(title: "오운완 삭제", message: "이 오운완을 삭제하시겠습니까?", preferredStyle: .alert)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        detailCollectionView.reloadData()
        calendarView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarConfiguration()
        detailCollectionView.reloadData()
        countButton.tintColor = UIColor.systemTeal
        backgroundView.isHidden = true
//        dateLabel.text = dateToString(dateFormatString: "MM월 dd일", date: selectDate)
    }
    
    @IBAction func changeCalendarMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            calendarView.setScope(.month, animated: true)
            backgroundView.isHidden = true

//            calendarView.frame.size.height = 400.0

        } else {
            calendarView.setScope(.week, animated: true)

            backgroundView.isHidden = false
            detailCollectionView.reloadData()


        }
    }
    
    // 생성 버튼이나 수정 버튼이 눌렸을 때
    @IBAction func addButtonTapped(_ sender: UIButton) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "Add") as! AddExerciseViewController
//        vc.date = dateToString(dateFormatString: "yyyy.MM.dd", date: selectDate)
//
//        if sender.tag == 1 { // 생성
//            navigationController?.pushViewController(vc, animated: true)
//        }
//
//        else if sender.tag == 2 { // 수정
//            let filtered = ExerciseViewModel.shared.exercises.filter { $0.dateString == dateToString(dateFormatString: "yyyy.MM.dd", date: selectDate) }
//            vc.exerciseType = filtered.first?.exerciseType ?? ""
//            vc.exerciseTime = filtered.first?.exerciseTime ?? ""
//            vc.memo = filtered.first?.memo ?? ""
//            print("filtered : \(filtered)")
//
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    // 삭제 버튼이 눌렸을 때
    @IBAction func deleteButtonTapped(_ sender: Any) {
//        self.present(self.deleteConfirmAlert, animated: true, completion: nil)
//        deleteConfirmAlert.addAction(UIAlertAction(title: "삭제", style: .destructive) { action in
//
//            ExerciseViewModel.shared.deleteEvent(exercise: self.data ?? Exercise(key: "", date: Date(), exerciseType: "", exerciseTime: "", memo: "", photoURL: "")) { result in
//                switch result {
//                case .success:
//                    print("delete success")
//                    self.viewWillAppear(true)
//
//                case .failure:
//                    print("delete fail")
//                }
//            }
//        })
//
//        deleteConfirmAlert.addAction(UIAlertAction(title: "취소", style: .cancel) { action in
//        self.dismiss(animated: true)
//        })
    }
    
    func calendarConfiguration() {
        calendarView.delegate = self
        calendarView.dataSource = self
//        
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
        cell.kindLabel.text = "수영"
        cell.timeLabel.text = "2h"
        cell.contentLabel.text = "IM 2바퀴, 운동량 1200M"
        cell.memoLabel.text = "진짜 힘든 날... 운동량 1100 달성! 팔로만 자유영 하는거 너무 힘들어.. 웨이트 병행해야겠다는 생각이 너무 많이 든 날 .. 팔 힘 기르자!"
        
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

        dateLabel.text = dateToString(dateFormatString: "M월 dd일", date: date)
        calendarView.setScope(.week, animated: true)

        // 애니메이션 적용
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
//        calendarView.frame.size.height = 170.0
        detailCollectionView.reloadData()
        backgroundView.isHidden = false
        segmentControl.setEnabled(true, forSegmentAt: 1)
        print("clicked!")
    }
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool){
        calendarViewHeight.constant = bounds.height
        
        self.view.layoutIfNeeded()
    }
//    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
//        let dateString = dateToString(dateFormatString: "yyyy.MM.dd", date: date)
//
//        let eventsCount = ExerciseViewModel.shared.exercises.filter { $0.dateString == dateString }.count
//
//        return eventsCount
//    }
}
//
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
//
