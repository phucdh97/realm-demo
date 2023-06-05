//
//  ViewController.swift
//  RealmDemo
//
//  Created by Do Huu Phuc on 14/02/2023.
//

import UIKit
import RealmSwift
import NaturalLanguage

class ViewController: UIViewController {
    
    var service: RealmServiceProtocol?
    var tasks = [ToDoTask]()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .add, style: .done, target: self, action: #selector(addTask))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .remove, style: .done, target: self, action: #selector(removeAllTasks))
        
        navigationController?.navigationBar.prefersLargeTitles = true

        title = "RealmDB"
        self.setupView()
        
        service = RealmService()
        self.loadData()
    }
    
    private func setupView() {
        self.view.addSubview(tableView)
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
    }
    
    @objc func removeAllTasks() {
        self.removeAll()
        self.tasks = []
        self.tableView.reloadData()
    }
    
    @objc func addTask()
    {
        let ac = UIAlertController(title: "Add Note", message: nil, preferredStyle: .alert)
        
        ac.addTextField(configurationHandler: .none)
        ac.addTextField(configurationHandler: .none)
        
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { (UIAlertAction) in
            
            let task = ToDoTask()
            
            if let text = ac.textFields?.first?.text
            {
                print("Note: \(text)")
                task.tasknote = text

            }
            
            if let text = ac.textFields?[1].text
            {
                print("Status: \(text)")
                task.status = Double(text) ?? 0.0
            }
            
            task.taskid = (task.tasknote ?? "nul")
            
            self.tasks.append(task)
            self.write(tasks: [task])
            
            self.tableView.reloadData()
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = (task.tasknote ?? "nul") + " - " + "\(task.status)"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let ac = UIAlertController(title: "Update task", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()
        let action = UIAlertAction(title: "OK", style: .default) { action in
            guard let text1 = ac.textFields?.first?.text, !text1.isEmpty else {return}
            guard let text2 = ac.textFields?[1].text, !text2.isEmpty else {return}
            self.update(task: task, note: text1, status: text2)
            tableView.reloadData()
        }
        ac.addAction(action)
        
        present(ac, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete {
            return
        }
        let task = tasks[indexPath.row]
        self.delete(tasks: [task])
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

// MARK: RealmDB

extension ViewController {
    
    private func loadData() {
        guard let tasks = service?.getObjects(objectType:ToDoTask.self) else {
            return
        }
//        notificationToken = tasks.observe(on: nil) { (changes: RealmCollectionChange) in
//            switch changes {
//            case .initial:
//                print("Init")
//            case .update(_, let deletions, let insertions, let modifications):
//                print("Deleted indices: ", deletions)
//                print("Inserted indices: ", insertions)
//                print("Modified modifications: ", modifications)
//            case .error(let error):
//                print("error: \(error)")
//            }
//        }
        self.tasks.removeAll()
//        let check = tasks.isFrozen
        
        self.tasks = tasks
        tableView.reloadData()
    }
    
    private func write(tasks: [ToDoTask]) {
        for task in tasks {
            service?.addObject(object: task)
        }
    }
    
    private func update(task: ToDoTask, note: String, status: String) {
        task.tasknote = note
        task.status = Double(status) ?? 0.0
        service?.addObject(object: task)
    }
    
    private func delete(tasks: [ToDoTask]) {
        let predicate = NSPredicate(format: "progressMinutes > 1 AND name == %@", "Ali")
        service?.deleteObject(objectType: ToDoTask.self, query: predicate)
    }
    
    private func removeAll() {
        service?.deleteAllObjects()
    }
}



class ClassCoreBase: NSObject {
    
}

class CoreB: ClassCoreBase {
    
}

class ClassBizBase: NSObject {
    class func toClassCoreType() -> AnyClass {
        return ClassCoreBase.self
    }
}

class BizA: ClassBizBase {
    override class func toClassCoreType() -> AnyClass {
        return CoreB.self
    }
}

class Test: NSObject {
    override init() {
        super.init()
        self.test()
    }
    func test() {
//        let className = "ClassA"
//        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
//        let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!
//        print("class: \(cls)")
        let urls = ["1", "2", "3"]
        let downloadGroup = DispatchGroup()
        for url in urls {
            downloadGroup.enter()
            self.download(url: url) { rs in
                downloadGroup.leave()
            }
        }
        
        downloadGroup.notify(queue: DispatchQueue.global(qos: .default)) {
            //
            print("Done all task")
        }
        
    }
    
    private func download(url: String, completion: @escaping (_ url: String) -> Void)  {
        let seconds = Int.random(in: 3..<10)
        let deadlineTime = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: deadlineTime) {
            print("complete url: \(url)")
            completion(url)
        }
    }
    
    
}

