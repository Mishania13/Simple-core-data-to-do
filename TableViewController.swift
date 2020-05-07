//
//  TableVCTableViewController.swift
//  DemoCoreData
//
//  Created by Mr. Bear on 07.05.2020.
//  Copyright © 2020 Mr. Bear. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var tasks: [Task] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let contex = getContext()
        let fetchReques: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try contex.fetch(fetchReques)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func saveTask () {
        let alertController = UIAlertController(title: "NewTask",
                                                message: "Please, add new task",
                                                preferredStyle: .alert)
        
        let save = UIAlertAction(title: "Save", style: .default) { action in
            
            let textField = alertController.textFields?.first
            if let newTask = textField?.text {
                self.saveTask(with: newTask)
                
                self.tableView.reloadData()
            }
        }
        
        
        let cancel = UIAlertAction(title: "Cancle", style: .destructive, handler: nil)
        
        alertController.addTextField { (_) in }
        
        alertController.addAction(cancel)
        alertController.addAction(save)
        
        present(alertController, animated: true)
    }
    
    @IBAction func deleteAll() {
        
        let context = getContext()
        let fetchRequset:NSFetchRequest<Task> = Task.fetchRequest()
        
        if let result = try? context.fetch(fetchRequset) {
            for object in result {
                context.delete(object)
            }
            do {
                try context.save()
                self.tasks = []
                self.tableView.reloadData()
            } catch let error {
                print("Empty data saving problem: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteOneElement (indexPathrow: Int) {
        
        let context = getContext()
        let fetchRequset:NSFetchRequest<Task> = Task.fetchRequest()
        
        if let result = try? context.fetch(fetchRequset) {
            context.delete(result[indexPathrow])
            tasks.remove(at: indexPathrow)
        }
        do {
           try context.save()
            self.tableView.reloadData()
        }  catch let error {
            print("Deleting element:\(error)")
        }
    }
    private func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    //MARK: - Core data communication
    
    private func saveTask(with task: String) {
        
        let contex = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: contex) else {
            return
        }
        
        let taskObject = Task(entity: entity, insertInto: contex)
        taskObject.title = task
        
        do {
            try contex.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print("Core data saving problem: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = tasks[indexPath.row].title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteOneElement(indexPathrow: indexPath.row)
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
    }
}
