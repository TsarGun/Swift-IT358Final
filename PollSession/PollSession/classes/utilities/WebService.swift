import UIKit
import Foundation

typealias JSONdictionary = [String: Any?]
typealias JSONArray = [Any?]

enum PostBodyType {
    case none
    case formData
    case urlEncoded
    case raw
}

typealias Parameters = [String: String]

class WebService{
    
    typealias serviceConstants = WebServiceConstants

    
    static func POSTrequest(with urlString: String, body: Dictionary<String, String>, completion: @escaping (_ data: Data?, _ error: String?) -> Void) {
    
    

    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = "POST"
    request.httpBody = data(body: body)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
        
        guard let successData = data else {
            
                completion(nil, "NO DATA")
            return
        }
        
            completion(successData, nil)
        
    })

    task.resume()
    }
    
    
    
    static func errorInResponse(data: Data) -> String? {
        if let dict = parseDictionary(data: data) {
            //todo-
                //TO DO:- As server end is now sending data in case of exception also, like in case of login api
                if(dict.keys.count > 1){
                    return nil
                }
                if let msg = dict["error"] as? String{
                    return msg
                }else if let msg = dict["success"] as? String{
                    return msg
                } else {
                  return  "There is some issue, try again or later"
            }
        }
        return "There is some issue, try again or later"
    }
    

    
    static func parseDictionary(data: Data) -> JSONdictionary? {
           do {
               let parsedDict = try JSONSerialization.jsonObject(with: data, options: []) as? JSONdictionary
               return parsedDict
           } catch let parseError as NSError {
               print("parsing error : \(parseError)")
               return nil
           }
       }




//MARK:- Utility methods.
private static func data( body: JSONdictionary) -> Data? {
           do{
               let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
               let resquestJson = String(data: jsonData, encoding: .utf8)
               print("API Request:-\(resquestJson ?? "")")
               return jsonData
           }
           catch{
               print(error)
               return nil
           }
      
   }

}
 
