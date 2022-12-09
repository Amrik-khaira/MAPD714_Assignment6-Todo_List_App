//
//  EditToDoVC.swift
//  Author's name : Amrik Singh
//  StudentID : 301296257
//
//  Todo List App - Part 3 Gesture control
//
//  Created by Amrik on 13/11/22.
// Version: 1.1

import UIKit

class EditToDoVC: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    //MARK: - variables and connections
  var Index = IndexPath()
  var toDoDict = ToDoList()
  var callbackforUpdateTodo:((ToDoList?,IndexPath,Bool,Bool) -> Void)?
    @IBOutlet weak var PickerSelectDate: UIDatePicker!
    @IBOutlet weak var ViwPicker: UIView!
    @IBOutlet weak var txtFieldTaskName: UITextField!
    @IBOutlet weak var TxtViewLongDesc: UITextView!
    @IBOutlet weak var SwitchDueDate: UISwitch!
    @IBOutlet weak var SwitchIsCompleted: UISwitch!
    
    @IBOutlet weak var ViwNotes: UIView!
    @IBOutlet weak var ViwDue: UIView!
    @IBOutlet weak var ViwIsComplete: UIView!
    @IBOutlet weak var ViwSave: UIView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnStoreTodoAct: UIButton!
    
    var placeholderLabel : UILabel!
    var dateStr = ""
    var iscomplete = Bool()
    var isdue = Bool()
    var isAddNew = Bool()
    var isAnyModification = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpUIForAddNewTodo(visible: isAddNew)
        }
    
    //MARK: - UI Setup
    func setupUI() {
        print(toDoDict)
        TxtViewLongDesc.layer.borderColor = UIColor.gray.cgColor
        TxtViewLongDesc.layer.borderWidth = 0.2
        TxtViewLongDesc.layer.cornerRadius = 5.0
        iscomplete = toDoDict.isComplete ?? false
        isdue = toDoDict.isDueDate ?? false
        dateStr = toDoDict.strDate ?? ""
        txtFieldTaskName.text = toDoDict.shorTitle ?? ""
        SwitchDueDate.setOn(toDoDict.isDueDate ?? false, animated: false)
        SwitchIsCompleted.setOn(toDoDict.isComplete ?? false, animated: false)
        TxtViewLongDesc.textColor = UIColor.lightGray
        btnStoreTodoAct.setTitle("\(isAddNew ? "Save" : "Update")", for: .normal)
        
        if toDoDict.isComplete ?? false
        {
            ViwPicker.isHidden = true
        }
        else if toDoDict.isDueDate ?? false == false
        {
            ViwPicker.isHidden = true
        }
        
        if toDoDict.longDesc ?? "" == ""
        {
        TxtViewLongDesc.text = "Long Description of the Todo \nNotes can also be included here."
        TxtViewLongDesc.textColor = UIColor.lightGray
        }
        else
        {
        TxtViewLongDesc.text = toDoDict.longDesc ?? ""
        TxtViewLongDesc.textColor = UIColor.black
        }
        if let strdate = toDoDict.strDate, strdate != ""
        {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d,yyyy"
        PickerSelectDate.date = dateFormatter.date(from: strdate) ?? Date()
        }
        txtFieldTaskName.becomeFirstResponder()
    }
        //MARK: - setUp View For Add New Todo Item
    func setUpUIForAddNewTodo(visible:Bool)
        {
            ViwDue.isHidden = visible
            ViwIsComplete.isHidden = visible
            ViwSave.isHidden = visible
            btnDelete.isHidden = visible
        }
    
    //MARK: - Btn Edit Action for Todo List
    @IBAction func BtnEditAct(_ sender: Any) {
        displayAlertWithCompletion(title: "ToDo!", message: "Are sure wish to \(isAddNew ? "save" : "update") the Todo.", control: ["Cancel","\(isAddNew ? "Save" : "Update")"]) { str in
            if str ==  "Save" || str == "Update"
            {
            self.saveTodo()
         }
     }
    }
    
    //MARK: - Save Todo clouser
    func saveTodo() {
        toDoDict = ToDoList.init(shorTitle: txtFieldTaskName.text, longDesc: TxtViewLongDesc.text, isComplete: iscomplete, isDueDate:isdue , strDate: dateStr)
        callbackforUpdateTodo?(toDoDict,Index,false,true)
        self.navigationController?.popViewController(animated: true)
        }
    
    //MARK: - Btn Delete Action for Todo List
    @IBAction func BtnDeleteAct(_ sender: Any) {
        displayAlertWithCompletion(title: "ToDo!", message: "Are sure wish to delete the Todo.", control: ["Cancel","Delete"]) { str in
        if str == "Delete"
            {
            self.callbackforUpdateTodo?(self.toDoDict,self.Index,true,false)
            self.navigationController?.popViewController(animated: true)
           }
        }
    }
    
    //MARK: - Btn Back Action for Todo detais screen
    @IBAction func BtnBackAct(_ sender: Any){
        if isAnyModification
        {
        displayAlertWithCompletion(title: "ToDo!", message: "Are sure wish to discard the changes.", control: ["Cancel","Save"]) { str in
        if str == "Save"
            {
            self.saveTodo()
           }
        }
        }
        else{
            self.callbackforUpdateTodo?(self.toDoDict,self.Index,self.isAddNew,false)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    //MARK: - Picker Change Date Act(Picker handler)
    @IBAction func PickerChangeDateAct(_ sender: UIDatePicker) {
        self.isAnyModification = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d,yyyy"
        dateStr = dateFormatter.string(from: sender.date)
    }
    
    //MARK: - Todo Compelte Switch Act
    @IBAction func CompelteSwitchAct(_ sender: UISwitch) {
        self.isAnyModification = true
        if sender.isOn
        {
            ViwPicker.isHidden = true
            SwitchDueDate.setOn(false, animated: true)
            iscomplete = true
            isdue = false
        }
        else{
            iscomplete = false
        }
    }
    
    //MARK: - Set Due date
    @IBAction func DueSwitchAct(_ sender: UISwitch) {
        self.isAnyModification = true
        if sender.isOn
        {
            ViwPicker.isHidden = false
            SwitchIsCompleted.setOn(false, animated: true)
            iscomplete = false
            isdue = true
        }
        else
        {
            ViwPicker.isHidden = true
            isdue = false
        }
        
    }
    

    //MARK: - UITextView Delegates for placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            self.isAnyModification = true
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text == "" {
            textView.text = "Long Description of the Todo Notes can also be included here."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text != ""
        {
            self.isAnyModification = true
            setUpUIForAddNewTodo(visible: false)
        }
        
    }
    
    //MARK: - keyboard done button tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
       return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
