//
//  Common.swift
//  Bravo
//
//  Created by Unum Sarfraz on 12/1/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import Foundation
import Parse
import SCLAlertView

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width:size.width, height:size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}

func afterSuccessLogin() -> UITabBarController{
    // if you change things here, don't forget to change things in the success callback of the new account signup
    
    print("--- LOGIN success")
    let storyBoard = UIStoryboard(name: "Activity", bundle: nil)
    
    let defaults = UserDefaults.standard
    if let deviceTokenString = defaults.object(forKey: "deviceTokenString") as? String {
        // if user permitted push notifications, save deviceTokenString to their profile
        let user = PFUser.current()
        user?["deviceTokenString"] = deviceTokenString
        user?.saveInBackground()
    }
    
    return getTabBarController()
    
} // after success login


func sendPushNotification(recipient: PFUser, message: String) -> Void {
    
    guard recipient["deviceTokenString"] != nil && message != "" else {
        print("!!!-- not sending push because no token or empty message")
        return
    }
    
    let deviceTokenString = recipient["deviceTokenString"] as! String
    
    let url = "http://coffeemaybe.com/bravo"
    let separator = "/"
    
    let message2 = message.addingPercentEncodingForURLQueryValue()!
    
    //let parameterString = parameters.stringFromHttpParameters()
    
    let requestURL = URL(string:"\(url)\(separator)\(deviceTokenString)\(separator)\(message2)\(separator)")!
    
    print("--- PUSHING TO: \(requestURL)")
    var request = URLRequest(url: requestURL)
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(d: Data?, ur: URLResponse?, e: Error?) in
        print("--- \(d) ||| \(ur) ||| \(e)")
    })
    
    task.resume()
    
    //return task
}

extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}

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
    imageView.asCircle()
    
    imageView.image = UIImage(named: "noProfilePic")
    let image = user["profileImage"] as? PFFile
    image?.getDataInBackground(block: { (imageData: Data?, error: Error?) in
        if error == nil && imageData != nil {
            imageView.image = UIImage(data:imageData!)
        }
    })
}

func setTeamImageView(imageView: UIImageView, team: PFObject) {
    // Setting image view
    imageView.asCircle()
    
    imageView.image = UIImage(named: "noTeamPic")
    let image = team["teamImage"] as? PFFile
    image?.getDataInBackground(block: { (imageData: Data?, error: Error?) in
        if error == nil && imageData != nil {
            imageView.image = UIImage(data:imageData!)
        }
    })
}

extension UIImageView{
    
    func asCircle(){
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0;
        /*
         self.backgroundColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 1.0)
         self.isOpaque = true
         self.alpha = 1.0
         */
    }
    
}

func postHeaderTextCreate(recipient : BravoUser, sender : BravoUser, team : PFObject ,headerLabel : UILabel){
    let RECEIVED_TEXT = "received a reward from"
    let IN_TEXT = "in"
    let postHeaderRecepient = "\(recipient["firstName"]!) \(recipient["lastName"]!) "
    let postHeaderSender = " \(sender["firstName"]!) \(sender["lastName"]!) "
    let postTeamName = " \(team["name"]!)"
    let postHeaderText = postHeaderRecepient + RECEIVED_TEXT + postHeaderSender + IN_TEXT + postTeamName
    
    let offsetStart = postHeaderRecepient.characters.count
    let offsetEnd = RECEIVED_TEXT.characters.count
    
    let offsetStart2 = postHeaderRecepient.characters.count + RECEIVED_TEXT.characters.count + postHeaderSender.characters.count
    let offsetEnd2 = IN_TEXT.characters.count
    
    let range = NSMakeRange(offsetStart, offsetEnd)
    let range2 = NSMakeRange(offsetStart2, offsetEnd2)
    
    headerLabel.attributedText = attributedString(from: postHeaderText, nonBoldRange: range, nonBoldRange2: range2)
}

func attributedString(from string: String, nonBoldRange: NSRange?, nonBoldRange2: NSRange? ) -> NSAttributedString {
    let fontSize = CGFloat(15.0)
    let attrs = [
        NSFontAttributeName: UIFont(name: "Avenir-Medium", size: fontSize),
        NSForegroundColorAttributeName: customBlack
    ]
    let nonBoldAttribute = [
        NSFontAttributeName: UIFont(name: "Avenir-Light", size: fontSize),
        NSForegroundColorAttributeName: customBlack
        ]
    let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
    if let range = nonBoldRange {
        attrStr.setAttributes(nonBoldAttribute, range: range)
    }
    if let range = nonBoldRange2 {
        attrStr.setAttributes(nonBoldAttribute, range: range)
    }
    return attrStr
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
    
    
    
    
    
    // set red as selected background color
    let numberOfItems = CGFloat(tabBarController.tabBar.items!.count)
    let tabBarItemSize = CGSize(width: tabBarController.tabBar.frame.width / numberOfItems, height: tabBarController.tabBar.frame.height)
    tabBarController.tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: purpleColor, size: tabBarItemSize).resizableImage(withCapInsets: UIEdgeInsets.zero)
    
    // remove default border
    tabBarController.tabBar.frame.size.width = tabBarController.tabBar.frame.width + 4
    tabBarController.tabBar.frame.origin.x = -2

    
    let tabBarImages = [#imageLiteral(resourceName: "timeline"), #imageLiteral(resourceName: "teams"), #imageLiteral(resourceName: "leaderboard"), #imageLiteral(resourceName: "profile")]
    if let items = tabBarController.tabBar.items {
        
        for i in 0..<items.count {
            let tabBarItem = items[i]
            let tabBarImage = tabBarImages[i]
            tabBarItem.image = tabBarImage.withRenderingMode(.alwaysOriginal)
            //tabBarItem.selectedImage = tabBarImage
        }
    }
    
    return tabBarController
}

func displayMessage(title: String, subTitle: String, duration: TimeInterval, showCloseButton: Bool, messageStyle: SCLAlertViewStyle) {
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "Avenir-Light", size: 20)!,
        kTextFont: UIFont(name: "Avenir-Light", size: 14)!,
        kButtonFont: UIFont(name: "Avenir-Medium", size: 14)!,
        showCloseButton: true
    )
    
    let colorStyle: UInt = messageStyle == .success ? 0x50D2C2 : 0xFCAB53
    SCLAlertView(appearance: appearance).showTitle(
        title, // Title of view
        subTitle: subTitle, // String of view
        duration: duration, // Duration to show before closing automatically, default: 0.0
        completeText: "OK", // Optional button value, default: ""
        style: messageStyle, // Styles - see below.
        colorStyle: colorStyle,
        colorTextButton: 0xFFFFFF
    )
}

func configureAppearanceProxies() {
    // App-wide fonts for bar button item, tab bar, text field and text view
    UINavigationBar.appearance().tintColor = UIColor.white
    UINavigationBar.appearance().backgroundColor = greenColor
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().barTintColor = greenColor
    UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18)!, NSForegroundColorAttributeName : UIColor.white]
    
    
    UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor.white], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor.white], for: .selected)
    UITabBar.appearance().barTintColor = greenColor
    UITabBar.appearance().tintColor = UIColor.white
    
    UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16)!], for: .normal)
    UITextField.appearance().font = UIFont(name: "Avenir-Light", size: 14)
    UITextView.appearance().font = UIFont(name: "Avenir-Light", size: 14)
    
    UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
}

