//
//  HomeController.swift
//  SuiviPred
//
//  Created by Jeremie Chaine on 04/04/2017.
//  Copyright © 2017 Jeremie Chaine. All rights reserved.
//

import UIKit
import CDAlertView
import MessageUI


class HomeController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate,
UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var objectifBtn: UIButton!
    @IBOutlet var monthlyReportCV: UICollectionView!
    @IBOutlet var dateTitle: UILabel!
    @IBOutlet var rapportLinesTV: UITableView!
    @IBOutlet var rapportLineCV: UICollectionView!
    
    let dateOne = NSDate()
    var lastRepport: Rapport!
    var currentRepport: Rapport!
    let moc = Database.shared.viewContext
    var publi = 0
    var vid = 0
    var visit = 0
    var cours = 0
    var rapports = [Rapport]()
    let date = Date()
    var currentDate = Date()
    var previousMonth = Date()
    let dateFormatter = DateFormatter()
    var monthlyEntriesArray = [MonthlyReportModel]()
    var rapportLineEntriesArray = [RapportLineModel]()
    let numberFormatter = NumberFormatter()
    let firstDay = Date().startOfMonth()
    let lastDay = Date().endOfMonth()
    var objectiveInHours = 0
    var currentTimeDoneInMinute = 0
    var objectiveButtonTitle = ""
    let textMessageRecipients = [""]
    var monthName = ""
    let transverseFunc = TransversesFunctions()
    let rapportLineCellIdentifier = "rapportLineCell"

    @IBAction func sendTextMessage(_ sender: Any) {
        selectionOfReportMonth()
    }

    @IBAction func showObjectivePopUp(_ sender: Any) {
        createObjectivePopUp()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.moc.clearTableRapport()
        monthlyReportCV.dataSource = self
        monthlyReportCV.delegate = self
        rapportLinesTV.dataSource = self
        rapportLinesTV.delegate = self
        rapportLineCV.dataSource = self
        rapportLineCV.delegate = self
        objectifBtn.titleLabel?.numberOfLines = 0
        objectifBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        parseReportsModelsFile()
        parseRapportLineModelsFile()
        currentDate = currentDateFormated()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveCurrentDayReportData()
        getDateAndSetTitleLabel()
        getCurrentMonthSum()
        rapportLinesTV.reloadData()
        getAllRapportLines()
        currentDate = currentDateFormated()
        self.remainingTimeToObjective()
    }
    
    func remainingTimeToObjective(){
        print(self.objectiveInHours)
        print(self.currentTimeDoneInMinute/60)
        if let objectif = self.moc.fetchObjectifFromDate(date: currentDateFormated() as NSDate)  {
            self.objectiveInHours = Int(objectif.hour)
            let remainingTimeinMinutes = objectiveInHours*60 - currentTimeDoneInMinute
            objectiveButtonTitle = "Il te reste \(transverseFunc.minutesToHoursMinutesFormatedLabel(minutes: remainingTimeinMinutes)) sur ton objectif de \(self.objectiveInHours)h"
            self.objectifBtn.titleLabel?.text = self.objectiveButtonTitle
        }
        print(self.objectiveButtonTitle)
    }
    
    func selectionOfReportMonth(){
        dateFormatter.dateFormat = "MMMM"
        let currentMonthName = (dateFormatter.string(from: currentDate)).uppercased()
        print(currentMonthName)
        
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)
        let previousMonthName = (dateFormatter.string(from: previousMonth!)).uppercased()
        print(previousMonthName)
        
        let alertController = UIAlertController(title: "Tu souhaites envoyer ton rapport pour quel mois ?", message: "", preferredStyle: .alert)
        let monthOne = UIAlertAction(title: currentMonthName, style: .default) { (action:UIAlertAction) in
            print("You've pressed \(currentMonthName) button")
            self.showTextMessagereportPopUp(date: self.currentDate)
        }
        let monthTwo = UIAlertAction(title: previousMonthName, style: .default) { (action:UIAlertAction) in
            print("You've pressed Month \(previousMonthName) button")
            self.showTextMessagereportPopUp(date: previousMonth!)
        }
        let OKAction = UIAlertAction(title: "Annuler", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed cancel button");
        }
        alertController.addAction(monthOne)
        alertController.addAction(monthTwo)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func createObjectivePopUp(){
        let alertController = UIAlertController(title: "Quel objectif pour ce mois ?", message: "12, 16, 30, 50, 70 ?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Pas cette fois", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        alertController.addAction(UIAlertAction(title: "Je valide", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            self.moc.performAndWait{
            if fNameField.text != "" {
                
                let goal = Int16(fNameField.text!)!
                self.moc.insertObjective(hour: goal, month: NSDate())
                self.moc.saveContext()
                print("Objectif enregistré dans la base")
                self.remainingTimeToObjective()
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Tu as oublié de mettre ton objectif", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
        }))
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.textAlignment = .center
            textField.keyboardType = .decimalPad
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func showTextMessagereportPopUp(date: Date){
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = textMessageRecipients
        dateFormatter.dateFormat = "MMMM"
        monthName = (dateFormatter.string(from: date)).uppercased()
        
        let sumDuration = self.moc.getSumDurationRapportToSend(firstDay: date.startOfMonth() as NSDate, lastDay: date.endOfMonth() as NSDate)
        let duration = transverseFunc.minutesToHoursMinutesFormatedLabel(minutes: Int(sumDuration))
        let sumPublication = self.moc.getSumPublicationRapportToSend(firstDay: date.startOfMonth() as NSDate, lastDay: date.endOfMonth() as NSDate)
        let sumVideo = self.moc.getSumVideoRapportToSend(firstDay: date.startOfMonth() as NSDate, lastDay: date.endOfMonth() as NSDate)
        let sumVisite = self.moc.getSumVisiteRapportToSend(firstDay: date.startOfMonth() as NSDate, lastDay: date.endOfMonth() as NSDate)
        let sumCoursb = self.moc.getSumCoursbRapportToSend(firstDay: date.startOfMonth() as NSDate, lastDay: date.endOfMonth() as NSDate)
        
        // Make sure the device can send text messages
        if (canSendText()) {
            messageComposeVC.body = "Bonjour mon cher frère, voici mon rapport pour le mois de \(monthName) :\n-Heures : \(duration)\n-Publications : \(sumPublication)\n-Vidéos : \(sumVideo)\n-Visites : \(sumVisite)\n-Cours biblique : \(sumCoursb)\nMerci pour ton travail"
            
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                print("You've pressed OK button");
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func getCurrentMonthSum(){
        self.moc.perform {
            self.currentTimeDoneInMinute = Int(self.moc.getSumDurationOnGivenPeriod(firstDay: self.firstDay as NSDate, lastDay: self.lastDay as NSDate))
            
            self.durationLabel.text = self.transverseFunc.minutesToHoursMinutesFormatedLabel(minutes: self.currentTimeDoneInMinute)
            self.publi = Int(self.moc.getSumPublicationsOnGivenPeriod(firstDay: self.firstDay as NSDate, lastDay: self.lastDay as NSDate))
            self.vid = Int(self.moc.getSumVideosOnGivenPeriod(firstDay: self.firstDay as NSDate, lastDay: self.lastDay as NSDate))
            self.visit = Int(self.moc.getSumVisitesOnGivenPeriod(firstDay: self.firstDay as NSDate, lastDay: self.lastDay as NSDate))
            self.cours = Int(self.moc.getSumCoursBOnGivenPeriod(firstDay: self.firstDay as NSDate, lastDay: self.lastDay as NSDate))
            DispatchQueue.main.async {
                self.monthlyReportCV.reloadData()
            }
        }
    }
    
    func getDateAndSetTitleLabel(){
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "MMMM YYYY"
        let dateResult = dateFormatter.string(from: date)
        dateTitle.text = dateResult.capitalized
    }
    
    func currentDateFormated() -> Date {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "FR-fr")
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date as Date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let currentDate = calendar.date(from: components)!
        print("date du jour ==>\(currentDate)")
        return currentDate
    }
    
    func retrieveCurrentDayReportData(){
        moc.performAndWait {
            if let repport = self.moc.fetchRapportFromDate(date: self.currentDate as NSDate) {
                self.currentRepport = repport
            }
        }
    }

    func getAllRapportLines() {
        let moc = Database.shared.backgroundContext
        moc.perform {
            self.rapports = moc.fetchRapports()
            DispatchQueue.main.async {
                self.rapportLinesTV.reloadData()
            }
        }
    }
    
    func parseReportsModelsFile() {
        if let path = Bundle.main.path(forResource: "monthlyReportModel", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                
                if let reportEntries = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                    reportEntries.forEach({ (item) in
                        if let reportEntry = item as? NSDictionary,
                            let picto = reportEntry["picto"] as? String,
                            let title = reportEntry["title"] as? String,
                            let value = reportEntry["value"] as? Int
                            
                        {
                            let entry = MonthlyReportModel(picto: picto, title: title, value: value)
                            self.monthlyEntriesArray.append(entry)
                        }
                    })
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    func parseRapportLineModelsFile() {
        if let path = Bundle.main.path(forResource: "rapportLineModel", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                
                if let reportEntries = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                    reportEntries.forEach({ (item) in
                        if let reportEntry = item as? NSDictionary,
                            let picto = reportEntry["picto"] as? String,
                            let value = reportEntry["value"] as? Int
                            
                        {
                            let entry = RapportLineModel(picto: picto, value: value)
                            self.rapportLineEntriesArray.append(entry)
                        }
                    })
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:
        IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.monthlyReportCV{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reportCell", for: indexPath) as! ReportMonthlyCollectionViewCell
            let entry = self.monthlyEntriesArray[indexPath.item]
            
            cell.picto.image = UIImage(named: entry.picto)
            cell.entryTitle.text = entry.title
            
            if cell.entryTitle.text == "Publication" {
                cell.entryValue.text = String(publi)
            }
                
            else if cell.entryTitle.text == "Vidéo" {
                cell.entryValue.text = String(vid)
            }
                
            else if cell.entryTitle.text == "Visite" {
                cell.entryValue.text = String(visit)
            }
                
            else if cell.entryTitle.text == "Cours B." {
                cell.entryValue.text = String(self.cours)
            }
            return cell
        } else {
        
        let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: rapportLineCellIdentifier, for: indexPath) as! RapportLineCollectionViewCell
            do {
                let rapport = try self.moc.existingObject(with: self.rapports[indexPath.item].objectID) as! Rapport
                print("rrrrrrrrrrrrrrrrr\(rapport)")
                
                let entry = self.rapportLineEntriesArray[indexPath.item]
                cellB.pictoRL.image = UIImage(named: entry.picto)
                
                if cellB.pictoRL.image == UIImage(named: "timerBleuIcon"){
                    cellB.labelRL.text = transverseFunc.minutesToHoursMinutesFormatedLabel(minutes: Int(rapport.duration))
                }
                if cellB.pictoRL.image == UIImage(named: "PublicationsBleuIcon"){
                    cellB.labelRL.text = String(rapport.publication)
                }
                if cellB.pictoRL.image == UIImage(named: "videos2BleuIcon"){
                    cellB.labelRL.text = String(rapport.video)
                }
                if cellB.pictoRL.image == UIImage(named: "smallVisiteIcon"){
                    cellB.labelRL.text = String(rapport.visite)
                }
                if cellB.pictoRL.image == UIImage(named: "smallCoursBIcon"){
                    cellB.labelRL.text = String(rapport.coursb)
                }

            } catch { }
            return cellB
        }
    }

    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.monthlyReportCV {
            return monthlyEntriesArray.count
        } else {
            return rapportLineEntriesArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("test")
        let rapport = self.rapports[indexPath.row]
        self.performSegue(withIdentifier: "goNewEntry", sender: rapport)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            let rapport = self.rapports[indexPath.row]
            moc.removeOneRowFromCoreData(date: rapport.date!)
            moc.saveContext()
            self.rapports.remove(at: indexPath.row)
            rapportLinesTV.reloadData()
        }
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rapportCell", for: indexPath) as! RapportLineTableViewCell
        do {
            let rapport = try self.moc.existingObject(with: self.rapports[indexPath.row].objectID) as! Rapport
            dateFormatter.locale = Locale(identifier: "fr_FR")
            dateFormatter.dateFormat = "EEEE dd MMMM YYYY"
            cell.dateLabel.text = dateFormatter.string(for: rapport.date)
            cell.durationValueTableLabel.text = transverseFunc.minutesToHoursMinutesFormatedLabel(minutes: Int(rapport.duration))
            cell.publicationValueTableLabel.text = "\(rapport.publication)"
            cell.videoValueTableLabel.text = "\(rapport.video)"
            cell.visiteValueTableLabel.text = "\(rapport.visite)"
            cell.coursbValueTableLabel.text = "\(rapport.coursb)"
        }
        catch {
        }
        return cell
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rapports.count
    }
    
    @IBAction func AddNewEntry(_ sender: Any) {
        if currentRepport == nil {
            performSegue(withIdentifier: "goNewEntry", sender: nil)
            print("pas de date")
        } else if dateOne.timeIntervalSince(self.currentRepport.date! as Date) <= 24 * 60 * 60 {
            performSegue(withIdentifier: "goNewEntry", sender: self.currentRepport)
            print("C'est la meme date")
        } else {
            performSegue(withIdentifier: "goNewEntry", sender: nil)
            print("Pas PAREILLLLLL !!!!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goNewEntry") {
            if let repportFectched = sender as? Rapport,
                let dest = segue.destination as? NewEntryViewController {
                dest.rapport = repportFectched
            }
        }
        else if(segue.identifier == "sendSummaryreportInfo") {
            if let repportFectched = sender as? Rapport,
                let dest = segue.destination as? NewEntryViewController {
                dest.rapport = repportFectched
            }
        }
    }
}


extension Date {
    func startOfMonth() -> Date {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "FR-fr")
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))!
    }
    func endOfMonth() -> Date {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "FR-fr")
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}


