//
//  NewEntryViewController.swift
//  SuiviPred
//
//  Created by Jeremie Chaine on 04/04/2017.
//  Copyright © 2017 Jeremie Chaine. All rights reserved.
//

import UIKit

class NewEntryViewController: UIViewController, UITextFieldDelegate, CalendarPopUpDelegate {
    
    let moc = Database.shared.viewContext
    let date = Date()
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    let transverseFunc = TransversesFunctions()
    var rapport: Rapport?
    var fetchRepport: Rapport?
    var dateSelected: Date!
    var aPopupContainer: PopupContainer?
    var testCalendar = Calendar(identifier: .gregorian)
    var currentDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    var timeValue: Int = 0 {
        didSet {
            timeTextField.text = "\(timeValue)"
        }
    }
    
    var publicationValue: Int = 0 {
        didSet {
            publicationTextField.text = "\(publicationValue)"
        }
    }
    var videoValue: Int = 0 {
        didSet {
            videoTextField.text = "\(videoValue)"
        }
    }
    var visiteValue: Int = 0 {
        didSet {
            visiteTextField.text = "\(visiteValue)"
        }
    }
    
    var coursBValue: Int = 0 {
        didSet {
            coursBTextField.text = "\(coursBValue)"
        }
    }

    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var scrollViewNewEntry: UIScrollView!
    @IBOutlet var timeTextField: UITextField!
    @IBOutlet var minteTextField: UITextField!
    @IBOutlet var publicationTextField: UITextField!
    @IBOutlet var videoTextField: UITextField!
    @IBOutlet var visiteTextField: UITextField!
    @IBOutlet var coursBTextField: UITextField!
    @IBOutlet var minutesToHoursLabel: UILabel!
    
    @IBAction func showPopup(_ sender: Any) {
        let xibView = Bundle.main.loadNibNamed("CalendarPopUp", owner: nil, options: nil)?[0] as! CalendarPopUp
        xibView.calendarDelegate = self
        xibView.selected = currentDate
        xibView.startDate = Calendar.current.date(byAdding: .month, value: -12, to: currentDate)!
        PopupContainer.generatePopupWithView(xibView).show()
    }
    
    @IBAction func doCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateLabelMinutesToHoursValue(_ sender: Any) {
        updateMinutesToHoursLabelvalue()
    }
    
    
        @IBAction func addMinute(_ sender: Any) {
        timeValue += 10
        updateMinutesToHoursLabelvalue()
    }
    
    @IBAction func suppressMinute(_ sender: Any) {
        timeValue -= 10
        updateMinutesToHoursLabelvalue()
    }
    
    @IBAction func addPublication(_ sender: Any) {
        publicationValue += 1
    }
    
    @IBAction func supressPublication(_ sender: Any) {
        publicationValue -= 1
    }
    
    @IBAction func addVideo(_ sender: Any) {
        videoValue += 1
    }
    
    @IBAction func supressVideo(_ sender: Any) {
        videoValue -= 1
    }
    
    @IBAction func addVisites(_ sender: Any) {
        visiteValue += 1
    }
    
    @IBAction func supressVisites(_ sender: Any) {
        visiteValue -= 1
    }
    
    @IBAction func addCoursB(_ sender: Any) {
        coursBValue += 1
    }
    
    @IBAction func supressCoursB(_ sender: Any) {
        coursBValue -= 1
    }
    
    @IBAction func textFiledChanged(_ sender: Any) {
    }
    
    func dontGoBelowZero(value: Int){
    
        if value >= 0 {
        
        }else {
        
        }
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "EEEE d MMMM YYYY"
        dateLabel.numberOfLines = 0
        dateLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
//        videoTextField.delegate = self
        visiteTextField.delegate = self
        coursBTextField.delegate = self
        minutesToHoursLabel.text = "00h00"
        getTextFieldInfo()
        makeSureTextFieldArentEmpty()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func updateMinutesToHoursLabelvalue(){
        if let valueTxt = timeTextField.text,
            let value = Int(valueTxt) {
            minutesToHoursLabel.text = transverseFunc.minutesToHoursMinutesFormatedLabel(minutes: value)
        }else{
        minutesToHoursLabel.text = "00h00"
        }
    }
    
    func makeSureTextFieldArentEmpty(){
        if let valueTxt = timeTextField.text,
            let value = Int(valueTxt) {
            timeValue = value
        }
        if let valueTxt = publicationTextField.text,
            let value = Int(valueTxt) {
            publicationValue = value
        }
        if let valueTxt = videoTextField.text,
            let value = Int(valueTxt) {
            videoValue = value
        }
        if let valueTxt = visiteTextField.text,
            let value = Int(valueTxt) {
            visiteValue = value
        }
        if let valueTxt = coursBTextField.text,
            let value = Int(valueTxt) {
            coursBValue = value
        }
    }
    
    func getTextFieldInfo() {
        if let rapport = self.rapport {
            dateLabel.text = self.dateFormatter.string(from: rapport.date! as Date).capitalized
            timeTextField.text = String(describing: rapport.duration)
            publicationTextField.text = String(describing: rapport.publication)
            videoTextField.text = String(describing: rapport.video)
            visiteTextField.text = String(describing: rapport.visite)
            coursBTextField.text = String(describing: rapport.coursb)
        } else {
            dateLabel.text = self.dateFormatter.string(from: date).capitalized
            timeTextField.text = String(describing: "")
            publicationTextField.text = String(describing: "")
            videoTextField.text = String(describing: "")
            visiteTextField.text = String(describing: "")
            coursBTextField.text = String(describing: "")
        }
    }
    
    
    @IBAction func doRegisterAndGoBackHome(_ sender: Any) {
        var duration: Int16 = 0
        if let durationTxt = self.timeTextField.text,
            let dur = Int16(durationTxt) {
            duration = dur
        }
        var publication: Int16 = 0
        if let publicationTxt = self.publicationTextField.text,
            let pub = Int16(publicationTxt) {
            publication = pub
        }
        var video: Int16 = 0
        if let videoTxt = self.videoTextField.text,
            let vid = Int16(videoTxt) {
            video = vid
        }
        var visite: Int16 = 0
        if let visiteTxt = self.visiteTextField.text,
            let visit = Int16(visiteTxt) {
            visite = visit
        }
        var coursB: Int16 = 0
        if let coursBTxt = self.coursBTextField.text,
            let cours = Int16(coursBTxt) {
            coursB = cours
        }
        
        let moc = Database.shared.backgroundContext
        moc.perform {
            if let rapport = self.rapport {
                moc.updateRapport(date: rapport.date!, duration: duration,
                                  publication: publication, video: video,
                                  visite: visite, coursB: coursB)
            } else {
                if let date = self.dateSelected {
                    moc.insertRapport(date: date as NSDate, duration: duration, publication: publication,
                                      video: video, visite: visite, coursB: coursB)
                }
                else {
                    moc.insertRapport(date: NSDate(), duration: duration, publication: publication,
                                      video: video, visite: visite, coursB: coursB)
                }
            }
            moc.saveContext()
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollViewNewEntry.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollViewNewEntry.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    //fonction dans la popup calendar
    func setDate() {
        let month = testCalendar.dateComponents([.month], from: currentDate).month!
        let weekday = testCalendar.component(.weekday, from: currentDate)
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)//
        let week = DateFormatter().shortWeekdaySymbols[weekday-1]
        let day = testCalendar.component(.day, from: currentDate)
        print("\(week), " + monthName + " " + String(day))
    }
    
    //fonction dans la popup calendar
    func dateChanged(date: Date) {
        self.dateSelected = date
        print(date, NSDate())
        rapport = moc.fetchRapportFromDate(date: date as NSDate)
        getTextFieldInfo()
        dateLabel.text = dateFormatter.string(from: date)
        print(dateLabel.text!)
        print("totototototootot \(String(describing: rapport))")
    }
   
}
