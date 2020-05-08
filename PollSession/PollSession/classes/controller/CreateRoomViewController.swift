//
//  ViewController.swift
//  PollSession
//
//  Created by Maksim  on 06/05/20.
//  Copyright © 2020 maksim. All rights reserved.
//

import UIKit

class CreateRoomViewController: UIViewController {
    
    @IBOutlet weak var classRoomNameTxtField: UITextField!
    
    var classRoomName = ""
    var sessionData: ClassRoomModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func goPressed(_ sender: UIButton) {
        
        if(isClassRoomNameValid()) {
            loadOrFetchSession()
        }
    
    }
    
    //MARK:- Validation of classroom name
    func isClassRoomNameValid() -> Bool {
        if let value = classRoomNameTxtField.text, value != "" {
            classRoomName = value
            return true;
        }
        return false
    }
    
    //MARK:- Connecting with AWS API to fetch or load classroom
    func loadOrFetchSession() {
          WebService.POSTrequest(with: "\(WebServiceConstants.baseUrl)\(WebServiceConstants.createOrLoadSession)", body: [ "classRoomId": classRoomName]) { (data, error) in
                     
                     
                     if let successData = data {
                         
                         if let errorMessage = WebService.errorInResponse(data: successData) {
                             DispatchQueue.main.async {

                             self.showAlert(title: "Server Validation Error", message: errorMessage , actionTitle: "OK")                        }
                         }
                             
                         else {
                             do {
                                 let newData = try JSONDecoder().decode(ClassRoomModel.self, from: successData)
                                 // print(newData)
                                 self.sessionData = newData
                               DataManager.shared.classRoom = self.sessionData
                                
                              DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "classRoomDetail", sender: self)
                                self.showAlert(title: "ClassRoom Details", message: "Here is ClassRoom", actionTitle: "Ok")
                              }
                             } catch {
                                 print(error)
                             }
                         }
                         
                     }
                     }
      }
    
    //MARK:- ALERT MESSAGE setup to show pop messages
    
    func showAlert(title: String?, message: String?, actionTitle: String?) {
          let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
          let alert = createAlert(title: title, message: message, actions: [action])
          self.present(alert, animated: true, completion: nil)
      }
     
    func createAlert(title: String?, message: String?, actions: [UIAlertAction]) -> UIAlertController {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         for action in actions {
             alert.addAction(action)
         }
         
         return alert
     }
    
    
}

