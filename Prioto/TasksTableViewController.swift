//
//  TaskTableViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import RealmSwift
import Realm
import AEAccordion
import AudioToolbox
import Spring
import SwiftyUserDefaults


class TasksTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	
	@IBOutlet var tasksTableView: TasksTableView!
		
	@IBAction func fillButtonTapped(sender: AnyObject) {
		RealmHelper.addTask(Task(text: "Complete feature to reorder tasks", priority: 0))
		RealmHelper.addTask(Task(text: "User test app", priority: 0))
		RealmHelper.addTask(Task(text: "Email Mr. Shuen / other instructor", priority: 0))
		RealmHelper.addTask(Task(text: "Integrate time and tasks", priority: 0))
		
		RealmHelper.addTask(Task(text: "Answer emails", priority: 1))
		RealmHelper.addTask(Task(text: "Share app with mom", priority: 1))
		
		RealmHelper.addTask(Task(text: "Go to the gym", priority: 2))
		RealmHelper.addTask(Task(text: "Call grandma", priority: 2))
		RealmHelper.addTask(Task(text: "Research productivity", priority: 2))
		RealmHelper.addTask(Task(text: "Think of long - term marketing strategy", priority: 2))
		
		RealmHelper.addTask(Task(text: "Watch TV", priority: 3))
		RealmHelper.addTask(Task(text: "Play Pokemon GO", priority: 3))
		RealmHelper.addTask(Task(text: "Watch YouTube videos", priority: 3))
		
		RealmHelper.getTaskTitles()
		
		taskExpanded = [[], [], [], []]
		let realm = try! Realm()
		let tasksByPriority = realm.objects(TasksByPriority.self).first!
		let priorities = tasksByPriority.priorities
		var section = 0
		for priority in priorities {
			for task in priority.tasks {
				taskExpanded[section].append(false)
			}
			section += 1
		}

	}
	
	@IBAction func printExpandedButtonTapped(sender: AnyObject) {
		print("------------------------------------------------------------------------")
		for priority in taskExpanded {
			print(priority)
		}
	}
	var realm: Realm!
	var notificationToken: NotificationToken?
	var priorityIndexes = [0, 1, 2, 3]
	var priorityTitles = ["Urgent | Important", "Urgent | Not Important", "Not Urgent | Important", "Not Urgent | Not Important"]
	
	let tasksByPriority: TasksByPriority = {
		// Get the singleton GroupParent() object from the Realm, creating it
		// if needed. In a more complete example with more than one view, this
		// would be supplied as the data source by whatever is displaying this
		// table view
		let realm = try! Realm()
		let obj = realm.objects(TasksByPriority.self).first
		if obj != nil {
			return obj!
		}
		
		let newObj = TasksByPriority()
		try! realm.write { realm.add(newObj) }
		return newObj
	}()
	
	var currentIndexPath: NSIndexPath?
	var selectedIndexPath : NSIndexPath!
	
	var taskExpanded: [[Bool]] = [[],[],[],[]]
		
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		storyboard.instantiateViewControllerWithIdentifier("NewFocusViewController")

		
		let realm = try! Realm()
		
		notificationToken = realm.addNotificationBlock { [unowned self] note, realm in
			self.tasksTableView.reloadData()
			// print("Realm array changed")
		}
		
		
		RealmHelper.addPriorities()
		
		tasksTableView.backgroundColor = UIColor.whiteColor()
//		tasksTableView.estimatedRowHeight = CGFloat(90)
		tasksTableView.rowHeight = UITableViewAutomaticDimension
//		tasksTableView.rowHeight = 90
		
		tasksTableView.layoutMargins = UIEdgeInsetsZero
		tasksTableView.separatorInset = UIEdgeInsetsZero
		
		tasksTableView.delegate = self
		tasksTableView.dataSource = self
		tasksTableView.tableFooterView = UIView()
		
		tasksTableView.setRearrangeOptions([.hover], dataSource: self)
		
		let nib = UINib(nibName: "PriorityHeaderView", bundle: nil)
		tasksTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "PriorityHeaderView")
		
		 tasksTableView.reloadData()
		
		
		let tasksByPriority = realm.objects(TasksByPriority.self).first!
		let priorities = tasksByPriority.priorities
		var section = 0
		for priority in priorities {
			for task in priority.tasks {
				taskExpanded[section].append(false)
			}
			section += 1
		}
		print(taskExpanded)
		
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   //  MARK: - Table view data source
	
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return CGFloat(90)
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
		
		 return priorityIndexes.count
    }
	

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		
		
		if(tasksByPriority.priorities[section].tasks.count == 0) {
				return 1
		}
		else {
			return tasksByPriority.priorities[section].tasks.count
		}

    }
	
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		// return priorityTitles[section]
		switch section {
		case 0:
			return "Section 0"
		case 1:
			return "Section 1"
		case 2:
			return "Section 2"
		default:
			return "Unknown"
		}

	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		// Here, we use NSFetchedResultsController
		// And we simply use the section name as title
		let title = priorityTitles[section]
		
		// Dequeue with the reuse identifier
		let cell = self.tasksTableView.dequeueReusableHeaderFooterViewWithIdentifier("PriorityHeaderView")
		let header = cell as! PriorityHeaderView
		header.priorityLabel.text = title
		
		return cell
	}
	

     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if tasksByPriority.priorities[indexPath.section].tasks.count == 0 {
			let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "placeholderCell")
			//set the data here
			cell.setHeight(1)
			// cell.userInteractionEnabled = false
			return cell
		}
		
		else {
			var cell : TaskTableViewCell!
			if indexPath.section == 0 {
				cell = tasksTableView.dequeueReusableCellWithIdentifier("taskTableViewCellSection0", forIndexPath: indexPath) as! TaskTableViewCell
			} else if indexPath.section == 1 {
				cell = tasksTableView.dequeueReusableCellWithIdentifier("taskTableViewCellSection1", forIndexPath: indexPath) as! TaskTableViewCell
			} else if indexPath.section == 2 {
				cell = tasksTableView.dequeueReusableCellWithIdentifier("taskTableViewCellSection2", forIndexPath: indexPath) as! TaskTableViewCell
			} else if indexPath.section == 3 {
				cell = tasksTableView.dequeueReusableCellWithIdentifier("taskTableViewCellSection3", forIndexPath: indexPath) as! TaskTableViewCell
			}
			// Configure the cell...
			let task = self.taskForIndexPath(indexPath)
			
			//configure left buttons
			cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"completeTask.png"), backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
				(sender: MGSwipeTableCell!) -> Bool in
				try! self.realm.write() {
					let task = self.taskForIndexPath(indexPath)
					self.taskForIndexPath(indexPath)?.completed = !(self.taskForIndexPath(indexPath)?.completed)!
					AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
					self.strikethroughCompleted(indexPath, cell: cell, task: task!)
					if self.taskExpanded[indexPath.section][indexPath.row] {
						self.collapseCellAtIndexPath(indexPath)
					}
				}
				RealmHelper.getTaskTitles()
				return true
			})]
			cell.leftSwipeSettings.transition = MGSwipeTransition.Border
			cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"deleteTask.png"), backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
				(sender: MGSwipeTableCell!) -> Bool in
				if self.taskExpanded[indexPath.section][indexPath.row] {
					self.collapseCellAtIndexPath(indexPath)
				}
				RealmHelper.deleteTask(self.taskForIndexPath(indexPath)!)
				// self.tasksTableView.reloadData()
				self.taskExpanded[indexPath.section].removeAtIndex(indexPath.row)
				
				RealmHelper.getTaskTitles()

				return true
			})]
			
			self.strikethroughCompleted(indexPath, cell: cell, task: task!)
			
			cell.contentView.layer.cornerRadius = 8
			cell.contentView.layer.masksToBounds = true
			cell.layer.borderColor = UIColor.whiteColor().CGColor
			cell.layer.borderWidth = 2
			cell.layer.cornerRadius = 5
			
			cell.selectionCallback = {
				if self.taskExpanded[indexPath.section][indexPath.row] {
					self.collapseCellAtIndexPath(indexPath)
				}
				else if !self.taskExpanded[indexPath.section][indexPath.row] {
					self.expandCellAtIndexPath(indexPath)
				}
				else {
					print("neither of the expansion cases met.")
				}
			}
			
			if taskExpanded[indexPath.section][indexPath.row] {
				expandCellAtIndexPath(indexPath)
			}
			else if !taskExpanded[indexPath.section][indexPath.row] {
					collapseCellAtIndexPath(indexPath)
			}
			
			
			cell.timeTaskCallBack = {
				let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
				if let tabBarController = appDelegate.window!.rootViewController as? UITabBarController {
					tabBarController.selectedIndex = 1
				}
				let taskDataDict:[String: Task] = ["task": task!]
				NSNotificationCenter.defaultCenter().postNotificationName("taskChosen", object: self, userInfo: taskDataDict)

			}
			
//			if indexPath == currentIndexPath {
//				
//				cell.backgroundColor = nil
//			}
//			else {
//				
//				cell.textLabel?.text = taskForIndexPath(indexPath)!.text
//			}
//			
//			cell.separatorInset = UIEdgeInsetsZero
//			cell.layoutMargins = UIEdgeInsetsZero
			
			cell.timeElapsedLabel.text = formatSecondsAsTimeString(Double((task?.timeWorked)!))
			
			return cell
		}

    }
	
	func collapseCellAtIndexPath(indexPath: NSIndexPath) {
		taskExpanded[indexPath.section][indexPath.row] = false
		if let cell = tasksTableView.cellForRowAtIndexPath(indexPath) as? TaskTableViewCell{
			self.tasksTableView.beginUpdates()
			cell.changeCellStatus(true)
			cell.changeCellStatus(false)
			self.tasksTableView.endUpdates()
		}
	}
	
	func expandCellAtIndexPath(indexPath: NSIndexPath) {
		taskExpanded[indexPath.section][indexPath.row] = true
		if let cell = tasksTableView.cellForRowAtIndexPath(indexPath) as? TaskTableViewCell{
			self.tasksTableView.beginUpdates()
			cell.changeCellStatus(false)
			cell.changeCellStatus(true)
			self.tasksTableView.endUpdates()
		}
	}
	
	// Get the Task at a given index path
	func taskForIndexPath(indexPath: NSIndexPath) -> Task? {
		return tasksByPriority.priorities[indexPath.section].tasks[indexPath.row]
	}
	
	func expandedForIndexPath(indexPath: NSIndexPath) -> Bool? {
		return taskExpanded[indexPath.section][indexPath.row]
	}

	
	func strikethroughCompleted(indexPath: NSIndexPath, cell: TaskTableViewCell, task: Task) {
		if let task = taskForIndexPath(indexPath) {
			if task.completed {
				let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: task.text)
				attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
				cell.taskTextLabel.attributedText = attributeString
			}
			else {
				cell.taskTextLabel.text = task.text
			}
		}
	}
	// MARK: - Table view delegate
	
	func colorForIndexRow(row: Int, section: Int) -> UIColor {
		let itemCount = tasksByPriority.priorities[section].tasks.count - 1
		let val = (CGFloat(row) / CGFloat(itemCount)) * 0.5
		
		switch section {
			// urgent | important
			case 0:
				return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
			
			// urgent | not important
			case 1:
				return UIColor(red: 0.0, green: val, blue: 1.0, alpha: 1.0)

			// not urgent | important
			case 2:
				return UIColor(red: 1.0, green: val, blue: 1.0, alpha: 1.0)

			// not urgent | not important
			case 3:
				return UIColor(red: 0.0, green: 1.0, blue: val, alpha: 1.0)
			
			default:
				return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		self.selectedIndexPath = indexPath
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		print("Old task expanded: \(taskExpanded[selectedIndexPath.section][selectedIndexPath.row]) ")

		self.performSegueWithIdentifier("editTaskDetailsSegue", sender: self)
	}
 
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
	                        forRowAtIndexPath indexPath: NSIndexPath) {
		cell.backgroundColor = colorForIndexRow(indexPath.row, section: indexPath.section)
//		if taskExpanded[indexPath.section][indexPath.row] {
//			expandCellAtIndexPath(indexPath)
//		}
//		else if !taskExpanded[indexPath.section][indexPath.row] {
//			collapseCellAtIndexPath(indexPath)
//		}

	}
	
	func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		
		if let taskTableViewCell = cell as? TaskTableViewCell {
			taskTableViewCell.selectionCallback = nil
			taskTableViewCell.timeTaskCallBack = nil
//			self.tasksTableView.beginUpdates()
//			taskTableViewCell.changeCellStatus(true)
//			taskTableViewCell.changeCellStatus(false)
//			self.tasksTableView.endUpdates()
		}
	}
	
	// Override to support conditional editing of the table view.
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	
	// MARK: Segues
	
	@IBAction func unwindToTasksTableViewController(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.sourceViewController as? DisplayTaskViewController, task = sourceViewController.task, priorityIndex = sourceViewController.priorityIndex {
			if let selectedIndexPath = self.selectedIndexPath {
				// Update an existing task.
				if selectedIndexPath.section == priorityIndex { // not changing priority
					RealmHelper.updateTask(taskForIndexPath(selectedIndexPath)!, newTask: task)
					// tasksTableView.reloadData()

				}
				
				else { // changing priority
					collapseCellAtIndexPath(selectedIndexPath)
					let newTask = Task(task: task)
					RealmHelper.addTask(newTask)
					if task.isBeingWorkedOn { // if task from old priority is being worked on, set the new one to also be timed
						let taskDataDict:[String: Task] = ["task": newTask]
						NSNotificationCenter.defaultCenter().postNotificationName("taskChosen", object: self, userInfo: taskDataDict)
					}
					
					
					let oldTaskExpanded = taskExpanded[selectedIndexPath.section][selectedIndexPath.row]
					print("Old task expanded: \(oldTaskExpanded)")
					taskExpanded[priorityIndex].append(oldTaskExpanded)

					
					RealmHelper.deleteTask(taskForIndexPath(selectedIndexPath)!)
					taskExpanded[selectedIndexPath.section].removeAtIndex(selectedIndexPath.row)

					// tasksTableView.reloadData()
				}
				self.selectedIndexPath = nil
			}
			else {
				RealmHelper.addTask(task)
				taskExpanded[priorityIndex].append(false)

				// tasksTableView.reloadData()
			}
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			
			if identifier == "editTaskDetailsSegue" {
				print("Selected index path: \(selectedIndexPath.section), \(selectedIndexPath.row)")

				let displayTaskViewController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! DisplayTaskViewController
				
				// set task of DisplayTaskViewController to task tapped on
//				if let selectedTaskCell = sender as? TaskTableViewCell {
					let selectedTask = taskForIndexPath(self.selectedIndexPath)
					displayTaskViewController.task = selectedTask
					print("Task completed: \(selectedTask!.completed)")
					displayTaskViewController.priorityIndex = self.selectedIndexPath.section
					displayTaskViewController.completed = (selectedTask?.completed)!
					displayTaskViewController.timeWorked = (selectedTask?.timeWorked)!

//				}
			}
			
			else if identifier == "addNewTaskSegue" {
			}
		}
	}
	
	// MARK: Timer integration
	
	func formatSecondsAsTimeString(time: Double) -> String {
		let hours = Int(round(time)) / 3600
		let minutes = Int(round(time)) / 60 % 60
		let seconds = Int(round(time)) % 60
		return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
	}
	
}

extension TasksTableViewController: RearrangeDataSource {
	
	func moveObjectAtCurrentIndexPath(to indexPath: NSIndexPath) {
		
		guard let unwrappedCurrentIndexPath = currentIndexPath else { return }
		if let cell = tasksTableView.cellForRowAtIndexPath(unwrappedCurrentIndexPath) as? TaskTableViewCell{
			if taskExpanded[unwrappedCurrentIndexPath.section][unwrappedCurrentIndexPath.row] {
				collapseCellAtIndexPath(unwrappedCurrentIndexPath)
			}
		}
		
		let oldTask = taskForIndexPath(unwrappedCurrentIndexPath)
		var makeNewTaskActive = false
		if oldTask!.isBeingWorkedOn {
			makeNewTaskActive = true
		}
		
		let newTask = Task(task: oldTask!, index: indexPath.row)
		let realm = try! Realm()
		RealmHelper.deleteTask(oldTask!)
		taskExpanded[unwrappedCurrentIndexPath.section].removeAtIndex(unwrappedCurrentIndexPath.row)
		try! realm.write() {
			tasksByPriority.priorities[indexPath.section].tasks.insert(newTask, atIndex: indexPath.row)
		}
		taskExpanded[indexPath.section].insert(false, atIndex: indexPath.row)
		
		if let cell = tasksTableView.cellForRowAtIndexPath(indexPath) as? TaskTableViewCell{
			collapseCellAtIndexPath(indexPath)
		}
		
		if makeNewTaskActive {
			let taskDataDict:[String: Task] = ["task": newTask]
			NSNotificationCenter.defaultCenter().postNotificationName("taskChosen", object: self, userInfo: taskDataDict)
		}
		
	}
}