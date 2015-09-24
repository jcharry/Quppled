//
//  Constants.swift
//  QuppledV5
//
//  Created by Jamie Charry on 8/13/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import Foundation

class Constants
{

    let TodaysUsersEmailKey = "todaysMatchedUserEmail"
    
    // Parse User keys
    let ParseUserFirstPartnerAgeKey = "firstPartnerAge"
    let ParseUserSecondPartnerAgeKey = "secondPartnerAge"
    let ParseUserFirstPartnerNameKey = "firstPartnerName"
    let ParseUserSecondPartnerNameKey = "secondPartnerName"
    let ParseUserFirstPartnerOccupationKey = "firstPartnerOccupation"
    let ParseUserSecondPartnerOccupationKey = "secondPartnerOccupation"
    let ParseUserProfilePhotoKey = "profilePhoto"
    let ParseUserAlreadyAnsweredQuestionsKey = "alreadyAnsweredQuestions"
    let ParseUserPreviouslyMatchedUserEmailsKey = "previouslyMatchedUsersEmails"
    let ParseUserSummaryKey = "profileSummary"
    let ParseUserSavedMatches = "savedMatches"
    
    // Parse Activity Object Keys
    let ParseActivityClassName = "Activity"
    let ParseActivityTimestampKey = "timestamp"
    let ParseActivityFromUserKey = "fromUser"
    let ParseActivityToUserKey = "toUser"
    let ParseActivityMessageTextKey = "messageText"
    let ParseActivityTypeKey = "type"
    
    // Segues
    let ToProfileCreationSegue = "To Profile Creation"
    let ToHomeScreenSegue = "To Home Screen"
    let FirstLaunchDefaultsKey = "FirstLaunch"
    let SegueFromProfileCreation = "From Profile Creation"
    let EmbedSegueNewQuestionsVC = "New Questions VC"
    let ToProfileEdit = "To Profile Edit"
    let ToProfileView = "To Profile View"

    // User Defaults Keys
    let NewFetchRequiredDefaultsKey = "newFetchRequired"
    
    // NSNotification Names
    let MatchIsSetNotificationName = "todaysMatchIsSet"
    let NoMatchNotificationName = "noMatchesAvailable"
    let SavedUsersUpdated = "savedUsersUpdated"
    let AlreadyAnsweredViewControllerBroughtToFront = "alreadyAnsweredBroughtToFront"
    let NewQuestionsViewControllerBroughtToFront = "newQuestionsBroughtToFront"
    
    // View Controller Storyboard ID's
    let QuizViewControllerStoryboardID = "Quiz View Controller"

    
}
