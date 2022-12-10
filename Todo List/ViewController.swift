//
//  ViewController.swift
//  Author's name : Amrik Singh(301296257) and Hafiz Shaikh(301282061)
//  StudentID :
//
//  Todo List App - Part 3 Gesture control
//
//  Created by Amrik on 12/11/22.
// Version: 1.2
 
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tblViwShopList: UITableView!
    //MARK: - Array to store data
    var TodoArr = [ToDoList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if LocalStorage.shared.isTodoListUpdate == false {
            loadItems()
            LocalStorage.shared.saveDataInPersistent(toDoArr: TodoArr)
        } else {
            TodoArr = LocalStorage.shared.GetSavedItems()
        }
    }
    
    //MARK: - Load default data in dictionary
    func loadItems() {
        TodoArr = [ToDoList.init(shorTitle: "Task Name", longDesc: "", isComplete: true, isDueDate: false, strDate: ""), ToDoList.init(shorTitle: "Another Task Name", longDesc: "", isComplete: false, isDueDate: false, strDate: ""), ToDoList.init(shorTitle: "Yet Another Task Name", longDesc: "", isComplete: false, isDueDate: true, strDate: "Sunday, Nov 20,2022")]
    }
    
    //MARK: - Add new item in Todo List
    @IBAction func btnAddNewTodoAct(_ sender: Any) {
        TodoArr.append(ToDoList.init(shorTitle: "", longDesc: "", isComplete: false, isDueDate: false, strDate: ""))
        openEditTodoList(index:IndexPath(row: TodoArr.count - 1, section: 0), addNewItem: true)
    }
    
    //MARK: - tableView datasource and delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TodoArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoCell else {return UITableViewCell()}
        cell.selectionStyle = .none
        let objTodo = TodoArr[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d,yyyy"
        let toDate = dateFormatter.date(from: objTodo.strDate ?? "")
        if objTodo.isComplete ?? false {
            cell.lblShortTitle.attributedText = (objTodo.shorTitle ?? "").strikeThrough()
            cell.lblLongDes.text = "Completed"
            cell.lblShortTitle.textColor = UIColor.black
            cell.lblLongDes.textColor = UIColor.black
        } else if objTodo.isDueDate ?? false {
            if let comp = toDate , comp < Date() {
                cell.lblShortTitle.attributedText = NSAttributedString(string: objTodo.shorTitle ?? "")
                cell.lblShortTitle.textColor = UIColor.red
                cell.lblLongDes.textColor = UIColor.red
                cell.lblLongDes.text = "Overdue! \(objTodo.strDate  ?? "")"
            } else {
                cell.lblShortTitle.attributedText = NSAttributedString(string: objTodo.shorTitle ?? "")
                cell.lblLongDes.text = objTodo.strDate  ?? ""
                cell.lblShortTitle.textColor = UIColor.black
                cell.lblLongDes.textColor = UIColor.black
            }
        } else {
            cell.lblShortTitle.attributedText = NSAttributedString(string: objTodo.shorTitle ?? "")
            cell.lblLongDes.text = objTodo.strDate  ?? "" == "" ? objTodo.longDesc  ?? "": objTodo.strDate  ?? ""
            cell.lblShortTitle.textColor = UIColor.black
            cell.lblLongDes.textColor = UIColor.black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - Cell swipe deletgates
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //MARK: Delete swipe action
        let deleteAction = UIContextualAction(style: .destructive, title:"Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            // handle delete (by removing the data from your array and updating the tableview)
            self.TodoArr.remove(at:indexPath.row)
            self.refreshLocalData()
            success(true)
        })
        deleteAction.backgroundColor = .systemRed
        
        //MARK: Complete swipe action
        let isComplete = self.TodoArr[indexPath.row].isComplete
        let text = isComplete == true ? "Un-Complete" : "Complete"
        let compAction = UIContextualAction(style: .normal, title:text, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.TodoArr[indexPath.row].isComplete = ac.title == "Complete" ? true : false
            self.refreshLocalData()
            success(true)
        })
        compAction.backgroundColor = .systemYellow
        return UISwipeActionsConfiguration(actions: [deleteAction,compAction])
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //MARK: Edit swipe action
        let editAction = UIContextualAction(style: .normal, title:  "Edit", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.openEditTodoList(index: indexPath, addNewItem: false)
            success(true)
        })
        editAction.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    func refreshLocalData() {
        LocalStorage.shared.saveDataInPersistent(toDoArr: self.TodoArr)
        self.tblViwShopList.reloadData()
    }
    
    //MARK: - open Edit Todo List
    func openEditTodoList(index:IndexPath, addNewItem:Bool) {
        if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditToDoVC") as? EditToDoVC {
            vc.Index = index
            vc.toDoDict = TodoArr[index.row]
            vc.isAddNew = addNewItem
            vc.callbackforUpdateTodo = {
                (dict,indexval, isdelete, isSave) in
                if isdelete {
                    self.TodoArr.remove(at: indexval.row)
                } else if isSave {
                    guard let updatedTask = dict else { return }
                    self.TodoArr[indexval.row] = updatedTask
                }
                LocalStorage.shared.saveDataInPersistent(toDoArr: self.TodoArr)
                self.tblViwShopList.reloadData()
                print("TodoArr count:",self.TodoArr.count)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - TableView Cell class
class TodoCell: UITableViewCell {
    //MARK: - connections
    @IBOutlet weak var lblShortTitle: UILabel!
    @IBOutlet weak var lblLongDes: UILabel!
    
}

//MARK: - Json Structure for handel data Todo List
struct ToDoList:Codable {
    var shorTitle : String?
    var longDesc : String?
    var isComplete : Bool?
    var isDueDate : Bool?
    var strDate : String?
}
