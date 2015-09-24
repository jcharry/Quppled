//
//  QuestionModel.swift
//  Quppled v3
//
//  Created by Jamie Charry on 5/11/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import Foundation
import Parse

class QuestionModel {
    
//    class Question
//    {
//        var questionNumber: String = ""
//        var answers: [String] = [""]
//        
//    }
    
    // TODO: Update to fetch data from Parse
    
    /*
    This class fetches question data, and presents it back to the question view controller.  It 
    will perform any analysis to determine of the user has already answered a question and only
    pass back a list of 10 new questions at a time.  To create the array of questions
    it must look through user data, and check for flags that say that question has already been answered.
    If so, ignore that question, and move onto the next.  If a question has not been answered, add it to the
    question array, until we hit items in the array.  If the user wants to answer more than 10 at a time,
    a request will be sent back to the model to fetch more questions.
    */
    
    private func getLocalJsonFile () -> [NSDictionary] {
        // Get app bundle path
        let appBundlePath:String? = NSBundle.mainBundle().pathForResource("quppledQuizQuestions", ofType: "JSON")
        
        // ensure path exists, if it does get NSURL that points to the file
        if let path = appBundlePath {
            
            let url = NSURL(fileURLWithPath: path)
            let data = NSData(contentsOfURL: url)
            // Path exsits, the url was created, and data was fetched properly
            // now parse json dictionary
            let arrayOfDictionaries:[NSDictionary]? = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! [NSDictionary]?
                // array of dictionaires created, now return it
            if let dictionaries = arrayOfDictionaries {
                return dictionaries
                
                
            }
        }
        return [NSDictionary]()
    }
    
    func getQuestions(questionsAlreadyAnswered answered: [String: String], removeQuestions: Bool) -> [Question] {
        
        var questions = [Question]()
        // separate keys out of answers dict into separate array
        var arrayOfAnsweredQuestionKeys = [String]()
        for (key, _) in answered {
            arrayOfAnsweredQuestionKeys.append(key)
        }
//        println(arrayOfAnsweredQuestionKeys)
        
        
        let arrayOfDictionaries = getLocalJsonFile()
        
        var index = 0
        for index = 0; index < arrayOfDictionaries.count; index++ {
            let dictItem = arrayOfDictionaries[index]
            let question = Question()
            question.answers = dictItem["answers"] as! [String]
            question.questionNumber = dictItem["questionIndex"] as! String
            
            if removeQuestions {
                // IF the index is contained in the array of already answered questions, omit this question altogether
                if arrayOfAnsweredQuestionKeys.contains(question.questionNumber) {
                    // the question is contained within the array of already answered questions, so do nothing
//                    println("question already answered")
                } else {
                    // the question hasn't been answered yet, so append the question to the questions array
                    questions.append(question)
                }
            } else {
                // don't remove any questions, so just append all questions
                questions.append(question)
            }
        }
        return questions
    }
    
    
}