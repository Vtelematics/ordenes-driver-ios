//
//  CalernderVc.swift
//  FoodesoftDelivery
//
//  Created by Apple on 30/08/19.
//  Copyright © 2019 Adyas Iinfotech. All rights reserved.
//

import UIKit


protocol selectedData {
    func selectedData( dateVal:String)
}

class CalernderVc: UIViewController {
    var dataDelegate:selectedData?

    
    @IBOutlet  var calendarView: CalendarView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        calderviewFunc()
    }
    
    @IBAction func cancel(sender:UIButton) {
       self.dismiss(animated: true, completion: nil)
    }
    
    func calderviewFunc(){
        CalendarView.Style.cellShape                = .bevel(8.0)
        CalendarView.Style.cellColorDefault         = UIColor.clear
        CalendarView.Style.cellSelectedBorderColor  = .green
        CalendarView.Style.cellEventColor           = UIColor(red:1.00, green:0.63, blue:0.24, alpha:1.00)
        CalendarView.Style.headerTextColor          = .green
        CalendarView.Style.cellTextColorDefault     = UIColor.black
        CalendarView.Style.cellTextColorToday       = .green
        CalendarView.Style.firstWeekday             = .sunday
        CalendarView.Style.locale                   = Locale(identifier: "en_US")
        CalendarView.Style.timeZone                 = TimeZone(abbreviation: "UTC")!
        CalendarView.Style.hideCellsOutsideDateRange = false
        CalendarView.Style.changeCellColorOutsideRange = false
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.direction = .horizontal
        calendarView.multipleSelectionEnable = false
        calendarView.marksWeekends = true
        calendarView.backgroundColor = UIColor.white
        CalendarView.Style.cellColorToday   = .green
       
        /*CalendarView.layer.shadowColor = UIColor.lightGray.cgColor
        CalendarView.layer.shadowOpacity = 1
        CalendarView.layer.shadowOffset = CGSize.zero
        CalendarView.layer.shadowRadius = 3
        */
    }


}
/*
func startDate() -> Date {
    var dateComponents = DateComponents()
    let today = Date()
    dateComponents.month = 0
    let threeMonthsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
    
    return threeMonthsAgo
}
func endDate() -> Date {
    var dateComponents = DateComponents()
    dateComponents.year = 2
    let today = Date()
    let twoYearsFromNow = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
    return twoYearsFromNow
    
}
*/

extension CalernderVc : CalendarViewDataSource, CalendarViewDelegate {
    func calendar(_ calendar: CalendarView, didScrollToMonth date: Date) {
    }
    
    func calendar(_ calendar: CalendarView, didSelectDate date: Date, withEvents events: [CalendarEvent]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-M-d"
        let result = formatter.string(from: date)
        dataDelegate?.selectedData(dateVal: result)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func calendar(_ calendar: CalendarView, canSelectDate date: Date) -> Bool {
        return true
    }
    
    func calendar(_ calendar: CalendarView, didDeselectDate date: Date) {
        
    }
    
    func calendar(_ calendar: CalendarView, didLongPressDate date: Date) {
        
        print("date:\(date)")
    }
    
    func calendar(_ calendar: CalendarView, didLongPressDate date : Date, withEvents events: [CalendarEvent]?){
        
        if let events = events {
            for event in events {
                
                print("\t\"\(event.title)\" - Starting at:\(event.startDate)")
            }
        }
        /*
        let alert = UIAlertController(title: "Create New Event", message: "Message", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Event Title"
        }
        let addEventAction = UIAlertAction(title: "Create", style: .default, handler: { (action) -> Void in
            let title = alert.textFields?.first?.text
            //self.calendarView.addEvent(title!, date: date)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(addEventAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        */
        
    }
    

}

