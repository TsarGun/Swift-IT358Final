//
//  ClassRoomDetailsViewController.swift
//  PollSession
//
//  Created by Maksim  on 08/05/20.
//  Copyright © 2020 maksim. All rights reserved.
//

import UIKit

class ClassRoomDetailsViewController: UIViewController {


var classRoomData = DataManager.shared.classRoom!

@IBOutlet weak var basicBarChart: BasicBarChart!
    
@IBOutlet weak var classRoomTitle: UILabel!

@IBOutlet weak var dataAvailableTitle: UILabel!
    

    @IBOutlet weak var gotButton: UIButton!
    @IBOutlet weak var unsureButton: UIButton!
    @IBOutlet weak var lostButton: UIButton!
    
var gotCount = 0
var lostCount = 0
var unsureCount = 0
var isVoted = false

override func viewDidLoad() {
    super.viewDidLoad()
    self.processGraphData()
    self.setUpUI()
    self.eableButton()
}
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateGraph()
     }
    
    func updateGraph() {
        let dataEntries = generateDataEntries()
        basicBarChart.dataEntries = dataEntries
    }
     

func setUpUI() {
    if (classRoomData.gotCount == "0" && classRoomData.lostCount == "0" && classRoomData.unsureCount == "0") {
        
        basicBarChart.isHidden = true
    } else {
        basicBarChart.isHidden = false
    }
    classRoomTitle.text = classRoomData.classRoomId
}
    
func processGraphData() {
          if let classRoom = DataManager.shared.classRoom {
                gotCount = Int(classRoom.gotCount!)!
                unsureCount = Int(classRoom.unsureCount!)!
                lostCount = Int(classRoom.lostCount!)!
          }
        
    }
      
    
    
func generateDataEntries() -> [BarEntry] {
    let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)]
    var result: [BarEntry] = []
    for i in 0..<3 {
        let value = self.getVoteCount(condition: i)
        let height: Float = Float(value) / 100.0
        
        var title = "";
        switch (i) {
            case 0:
                title = "GOT VOTE"
                break;
            case 1:
                title = "UNSURE VOTE"
                break;
            case 2:
                title = "LOST VOTE"
                break;
        default:
                break;
        }
        result.append(BarEntry(color: colors[i % colors.count], height: height, textValue: "\(value)", title: title))
    }
    return result
}
    
func getVoteCount(condition: Int) -> Int {
     var countOfVote = 0
     switch (condition) {
         case 0:
            countOfVote = self.gotCount
         break;
         case 1:
            countOfVote = self.unsureCount
         break;
         case 2:
            countOfVote = self.lostCount
         break;
        
         default:
         break;
     }
     return countOfVote
 }

@IBAction func gotItPressed(_ sender: UIButton) {
    if (isVoted) {
        self.disableButton()
        return
    }
    self.basicBarChart.isHidden = false

    var gotValue =  Int(classRoomData.gotCount!)!
    gotValue = gotValue + 1
    
    let parameter = [ "classRoomId": classRoomData.classRoomId!, "gotCount": String(gotValue)]
    voteClassRoom(param: parameter, endpoint: WebServiceConstants.gotVote)
    self.isVoted = true
    gotCount = gotCount + 1
    self.updateGraph()
    

}

@IBAction func unsurePressed(_ sender: UIButton) {
    if (isVoted) {
           self.disableButton()
           return
       }
    self.basicBarChart.isHidden = false

    var unsureValue =  Int(classRoomData.unsureCount!)!
    unsureValue = unsureValue + 1
    let parameter = [ "classRoomId": classRoomData.classRoomId!, "unsureCount": String(unsureValue)]
    voteClassRoom(param: parameter, endpoint: WebServiceConstants.unsureVote)
    self.isVoted = true
    unsureCount = unsureCount + 1
    self.updateGraph()


}

@IBAction func lostPressed(_ sender: UIButton) {
    if (isVoted) {
           self.disableButton()
           return
       }
    self.basicBarChart.isHidden = false

    var lostValue =  Int(classRoomData.lostCount!)!
    lostValue = lostValue + 1
    let parameter = [ "classRoomId": classRoomData.classRoomId!, "lostCount": String(lostValue)]
    voteClassRoom(param: parameter, endpoint: WebServiceConstants.lostVote)
    self.isVoted = true
    lostCount = lostCount + 1
    self.updateGraph()

}


    func voteClassRoom(param: [String: String], endpoint: String) {
    WebService.POSTrequest(with: "\(WebServiceConstants.baseUrl)\(endpoint)", body: param ) { (data, error) in
        if let successData = data {
                    if let errorMessage = WebService.errorInResponse(data: successData) {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Server Message", message: errorMessage , actionTitle: "OK")
                        }
                    } else {
                  DispatchQueue.main.async {
                    self.showAlert(title: "Server  Error", message: "Server Error" , actionTitle: "OK")
              }
   }
}
}
}

    func disableButton() {
        self.showAlert(title: "Notify", message: "No more votes...You Have already Voted...Thanks!", actionTitle: "OK")
        
//        self.gotButton.isEnabled = false
//        self.unsureButton.isEnabled = false
//        self.lostButton.isEnabled = false
    }
    
    
    func eableButton() {
        self.gotButton.isEnabled = true
        self.unsureButton.isEnabled = true
        self.lostButton.isEnabled = true
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
