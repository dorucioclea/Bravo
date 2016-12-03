//
//  Common.swift
//  Bravo
//
//  Created by Unum Sarfraz on 12/1/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import Foundation
import Parse

func transparentNavBar(){
    // Sets background to a blank/empty image
    UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    // Sets shadow (line below the bar) to a blank image
    UINavigationBar.appearance().shadowImage = UIImage()
    // Sets the translucent background color
    UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    // Set translucent. (Default value is already true, so this can be removed if desired.)
    UINavigationBar.appearance().isTranslucent = true
}

func setImageView(imageView: UIImageView, user: PFUser) {
    // Setting image view
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = true
    
    imageView.image = UIImage(named: "noProfilePic")
    let image = user["profileImage"] as? PFFile
    image?.getDataInBackground(block: { (imageData: Data?, error: Error?) in
        if error == nil && imageData != nil {
            imageView.image = UIImage(data:imageData!)
        }
    })
}

func getTabBarController() -> UITabBarController {
    let storyBoard = UIStoryboard(name: "Activity", bundle: nil)
    
    let timelineNavigationController = storyBoard.instantiateViewController(withIdentifier: "TimelineNavigationController") as! UINavigationController
    let timelineViewController = timelineNavigationController.topViewController as! TimelineViewController
    timelineNavigationController.tabBarItem.title = "Timeline"
    //timelineNavigationController.tabBarItem.image = UIImage(named: "NoImage")
    
    
    let storyBoardTC = UIStoryboard(name: "TeamCreation", bundle: nil)
    let teamNavigationController = storyBoardTC.instantiateViewController(withIdentifier: "TeamNavigationController") as! UINavigationController
    //let teamViewController = teamNavigationController.topViewController as! TeamViewController
    teamNavigationController.tabBarItem.title = "Teams"
    //teamNavigationController.tabBarItem.image = UIImage(named: "NoImage")
    
    let leaderboardNavigationController = storyBoard.instantiateViewController(withIdentifier: "LeaderboardNavigationController") as! UINavigationController
    let leaderboardViewController = leaderboardNavigationController.topViewController as! LeaderboardViewController
    leaderboardNavigationController.tabBarItem.title = "Leaderboard"
    //leaderboardNavigationController.tabBarItem.image = UIImage(named: "NoImage")
    
    let profileNavigationController = storyBoard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
    let profileViewController = profileNavigationController.topViewController as! ProfileViewController
    profileNavigationController.tabBarItem.title = "Profile"
    //profileNavigationController.tabBarItem.image = UIImage(named: "NoImage")
    
    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [timelineNavigationController, teamNavigationController, leaderboardNavigationController, profileNavigationController]
    //tabBarController.selectedViewController = teamNavigationController
    
    return tabBarController
}

