//
//  DisplayTaskViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/13/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit
import AudioToolbox
import Spring
import RealmSwift

class DisplayTaskViewController: UIViewController {

	@IBOutlet weak var taskTitleTextField: UITextField!
	@IBOutlet weak var importanceSelector: UISegmentedControl!
	@IBOutlet weak var urgencySelector: UISegmentedControl!
	@IBOutlet weak var dueDatePicker: UIDatePicker!
	
	@IBOutlet weak var dueDateLabel: UILabel!
	
	
	@IBOutlet weak var taskDetails: UITextView!
	
	var priorityIndex: Int!
	var completed: Bool = false
	var timeWorked: Int!
	var previousPriorityIndex: Int!
	var task: Task?
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DisplayTaskViewController.dismissKeyboard))
		view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
		 dueDatePicker.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
		dueDatePicker.minimumDate = NSDate()
		
		// set up the task details if it already exists
		if let task = task {
			taskTitleTextField.text = task.text
			if task.dueDate != nil {
				dueDatePicker.date = task.dueDate!
				dueDateLabel.text = "Due Date: \(formatDateAsString(task.dueDate!))"
			}
			self.previousPriorityIndex = priorityIndex
			switch priorityIndex {
			case 0: // Urgent - Important
				importanceSelector.selectedSegmentIndex = 0
				urgencySelector.selectedSegmentIndex = 0
			case 1: // Urgent - Not Important
				importanceSelector.selectedSegmentIndex = 1
				urgencySelector.selectedSegmentIndex = 0
			case 2: // Not Urgent - Important
				importanceSelector.selectedSegmentIndex = 0
				urgencySelector.selectedSegmentIndex = 1
			case 3: // Not Urgent - Not Important
				importanceSelector.selectedSegmentIndex = 1
				urgencySelector.selectedSegmentIndex = 1
			default:
				importanceSelector.selectedSegmentIndex = 0
				urgencySelector.selectedSegmentIndex = 0
			}
			taskDetails.text = task.details
		}
    }
	
	//Calls this function when the tap is recognized.
	func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		// 1
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func datePickerValueChanged(sender:UIDatePicker) {
		
		dueDateLabel.text = "Due Date:  \(formatDateAsString(dueDatePicker.date))"
		if dueDatePicker.date < dueDatePicker.minimumDate {
			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
			print("incorrect date")
		}
	}
	
	func formatDateAsString(date: NSDate) -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
		dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
		
		let strDate = dateFormatter.stringFromDate(date)
		return strDate
	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: - Segue
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			if identifier == "Save" {
				if let taskToBeEdited = self.task {
					let text = self.taskTitleTextField.text
					let realm = try! Realm()
					try! realm.write {
						taskToBeEdited.text = text!
						taskToBeEdited.completed = self.completed
						taskToBeEdited.details = self.taskDetails.text
						taskToBeEdited.timeWorked = self.timeWorked
						setTaskPriority(taskToBeEdited)
					}
				}
				else {
					task = Task()
					task!.text = self.taskTitleTextField.text!
					task!.completed = self.completed
					task!.details = self.taskDetails.text
					task!.timeWorked = 0
					setTaskPriority(task!)

				}
				
			}
		}
	}
	
	func setTaskPriority(task: Task) {
//		if dueDatePicker.date > NSDate() {
			task.dueDate = dueDatePicker.date
//		}
		
		
		// Important
		if importanceSelector.selectedSegmentIndex == 0 {
			// Important - Urgent
			if urgencySelector.selectedSegmentIndex == 0 {
				task.priorityIndex = 0
				priorityIndex = 0

			}
				// Important - Not Urgent
			else if urgencySelector.selectedSegmentIndex == 1 {
				task.priorityIndex = 2
				priorityIndex = 2
			}
		}
			// Not Important
		else if importanceSelector.selectedSegmentIndex == 1 {
			if urgencySelector.selectedSegmentIndex == 0 {
				task.priorityIndex = 1
				priorityIndex = 1
			}
				// Important - Not Urgent
			else if urgencySelector.selectedSegmentIndex == 1 {
				task.priorityIndex = 3
				priorityIndex = 3

			}
		}
	}
}


