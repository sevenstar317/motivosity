//
//  AppDelegate.h
//  ;
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mrAPI.h"
#import "FeedVC.h"
#import "RecognitionVC.h"
#import "StoreVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>{

    FeedVC *feed;
    RecognitionVC *recognition;
    StoreVC *store;
    NSDateFormatter *dateFormatterServer;
}

@property (strong, nonatomic) NSDateFormatter *dateFormatterServer;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
- (void)makeTabBarHidden:(BOOL)hide;

@property (strong, nonatomic) UINavigationController *feedNavi;

@property (nonatomic, retain) FeedVC *feed;
@property (nonatomic, retain) RecognitionVC *recognition;
@property (nonatomic, retain) StoreVC *store;

- (void)showSplashScreen;
- (void)mrValuesInit;

- (void)goToLogin;
- (void)goToFeed;
- (void)goToRecognition;
- (void)goToStore;
- (void)goToMore;

@end

