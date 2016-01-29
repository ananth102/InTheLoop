

func getGrades(periodID: String) {
        let url = NSURL(string: "https://montavista.schoolloop.com/mapi/progress_report?studentID=\(studentID)&periodID=\(periodID)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let plainString = "\(username):\(password)"
        let base64Data = (plainString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        let base64String = base64Data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        request.addValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request) {(data, response, error) in
            print("Got response assignments")
            //print(String(data: data!, encoding: NSUTF8StringEncoding))
            let course = self.courseForPeriodID(periodID)
            
            var dataJSON: AnyObject!
            do {
                dataJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch let error {
                assertionFailure("Error parsing JSON: \(error)")
            }
//            dataJSON = dataJSON as! [String:AnyObject]
            if let gradesJSON = dataJSON[0]["grades"] {
                for var json in gradesJSON as! [AnyObject] {
                    json = json as! [String:AnyObject]
                    let percentScore = json["percentScore"] as! String
                    let score = json["score"] as! String
                    if var assignmentJSON = json["assignment"]! {
                        assignmentJSON = assignmentJSON as! [String:AnyObject]
                        let title = assignmentJSON["title"] as! String
                        let categoryName = assignmentJSON["categoryName"] as! String
                        let maxPoints = assignmentJSON["maxPoints"] as! String
                        let grade = SchoolLoopGrade(title: title, categoryName: categoryName, percentScore: percentScore, score: score, maxPoints: maxPoints)
                        course!.grades.append(grade)
                    }
                }
            }
            
            self.gradeDelegate?.gotGrades(self)
            }.resume()
    }
