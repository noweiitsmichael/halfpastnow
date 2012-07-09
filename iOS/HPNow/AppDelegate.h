//
//  AppDelegate.h
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,UINavigationControllerDelegate>{
    IBOutlet UINavigationController *navController1;
    IBOutlet UINavigationController *navController2;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navController1;
@property (nonatomic, strong) IBOutlet UINavigationController *navController2;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
