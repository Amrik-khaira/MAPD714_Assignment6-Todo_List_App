//
//  LocalStorage.swift
//  Author's name : Amrik Singh
//  StudentID : 301296257
//
//  Todo List App - Part 3 Gesture control
//
//  Created by Amrik on 25/11/22.
// Version: 1.1

import Foundation
import UIKit

class LocalStorage {
    
    //MARK: - shared instance for Local Storage class
    static let shared = LocalStorage()
    
    //MARK: - User Defaults to check app load first time
     var isTodoListUpdate: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "isTodoListUpdate")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isTodoListUpdate")
        }
    }
    //MARK: - Save Data In Local storage
    func saveDataInPersistent(toDoArr:[ToDoList]) {
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(toDoArr), forKey:"TodoList")
        isTodoListUpdate = true
    }
    
    //MARK: - Get Saved Items
    func GetSavedItems() -> [ToDoList] {
        if let data = UserDefaults.standard.value(forKey:"TodoList") as? Data {
         do
         {
             return try PropertyListDecoder().decode(Array<ToDoList>.self, from: data)
         } catch {
            return [ToDoList]()
         }
        }
        else {
            return [ToDoList]()
        }
    }
}
//MARK: - Extension for strike Through on label
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: 1,
                   range:NSMakeRange(0,attributeString.length))
        return attributeString
    }
}


//MARK: - Display alert with completion
extension UIViewController
{
func displayAlertWithCompletion(title:String,message:String,control:[String],completion:@escaping (String)->()){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    for str in control{
        let alertAction = UIAlertAction(title: str, style: .default, handler: { (action) in
            completion(str)
        })
        alertController.addAction(alertAction)
    }
    self.present(alertController, animated: true, completion: nil)
}
}
