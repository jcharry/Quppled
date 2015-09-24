//
//  AppDelegate.swift
//  QuppledV5
//
//  Created by Jamie Charry on 7/10/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse
import Bolts

struct ParseKeys {
    static let ParseUserFirstPartnerAgeKey = "firstPartnerAge"
    static let ParseUserSecondPartnerAgeKey = "secondPartnerAge"
    static let ParseUserFirstPartnerNameKey = "firstPartnerName"
    static let ParseUserSecondPartnerNameKey = "secondPartnerName"
    static let ParseUserProfilePhotoKey = "profilePhoto"
    static let ParseUserAlreadyAnsweredQuestionsKey = "alreadyAnsweredQuestions"
    static let ParseUserPreviouslyMatchedUserEmailsKey = "previouslyMatchedUsersEmails"

}

var todaysMatchedUser: PFUser?
let QuppledConstants = Constants()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
//    private struct Constants {
//        static let FetchNewUserNotificationName = "fetchNewUser"
//    }

    var window: UIWindow?

    var currentTime = NSTimer()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
                
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("jiGqelJa1mK7fCdbV7m5YhZj4OOn8NXLqF6ajQPy",
            clientKey: "blFvQWrt9MfNAMZ2FkYNV91ZNHACCrg5rnZUlqEt")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
                
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //TODO: log what time it is
//        let date = NSDate()
//        let calendar = NSCalendar()
//        let components = calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: date)
//        let hour = components.hour
//        let minute = components.minute
//        println("hour is: \(hour)")
//        println("minute is: \(minute)")
//        
//        var todaysDate:NSDate = NSDate()
//        var dateFormatter:NSDateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "HH:mm"
//        var DateInFormat:String = dateFormatter.stringFromDate(todaysDate)
//        println(todaysDate)
//        println(DateInFormat)
        
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // TODO check the time, if the time crossed midnight, run a bunch of code to offer a new match
//        var currentDate:NSDate = NSDate()
//        var dateFormatter:NSDateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "HH:mm"
//        var DateInFormat:String = dateFormatter.stringFromDate(currentDate)
//        
//        if DateInFormat > "13:00" {
//            println("time for a new match")
//            let defaults = NSUserDefaults.standardUserDefaults()
//            defaults.setBool(true, forKey: "newFetchRequired")
//            let notificationCenter = NSNotificationCenter.defaultCenter()
//            notificationCenter.postNotificationName(Constants.FetchNewUserNotificationName, object: self)
//        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func applicationSignificantTimeChange(application: UIApplication) {
        // TODO: should I put the code to update the match here?
        // Time change occurred, new fetch is required...so, set defaults flag
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "newFetchRequired")
    }


}

