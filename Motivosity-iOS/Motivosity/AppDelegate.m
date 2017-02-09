//
//  AppDelegate.m
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginVC.h"
#import "RecognitionVC.h"
#import "StoreVC.h"
#import "MoreVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


@synthesize feed, recognition, store;
@synthesize dateFormatterServer;

- (void)showSplashScreen
{
    const float animationDelay = 1.0f;
    const float animationDuration = 0.5;
    
    UIImageView* splashView;
    UIActivityIndicatorView *act;
    
    if (isIPhone6Plus()) {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default@hdPlus.png"]];
        [splashView setFrame:CGRectMake(0, 0, 414, 736)];
        act = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(197, 534, 20, 20)];
    }
    else if (isIPhone6()) {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default@hd.png"]];
        [splashView setFrame:CGRectMake(0, 0, 375, 667)];
        act = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(177.5, 478, 20, 20)];
    }
    else if(isIPhone5())
    {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
        [splashView setFrame:CGRectMake(0, 0, 320,568)];
        act = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 406, 20, 20)];
    }
    else
    {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
        [splashView setFrame:CGRectMake(0, 0, 320, 480)];
        act = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 340, 20, 20)];
    }
    
    [act startAnimating];
    [act setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [splashView addSubview:act];
    
    [self.window addSubview:splashView];
    
    [UIView animateWithDuration:animationDuration
                          delay:animationDelay
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         [splashView setAlpha:0.0];
                     } completion:^(BOOL finished) {
                         [splashView removeFromSuperview];
                     }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self mrValuesInit];
    
    if(isIOS7or8())
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LoginVC *login = [[LoginVC alloc]initWithNibName:@"LoginVC" bundle:nil];
    self.feed = [[FeedVC alloc]initWithNibName:@"FeedVC" bundle:nil];
    self.recognition = [[RecognitionVC alloc]initWithNibName:@"RecognitionVC" bundle:nil];
    self.store = [[StoreVC alloc]initWithNibName:@"StoreVC" bundle:nil];
    MoreVC *more = [[MoreVC alloc]initWithNibName:@"MoreVC" bundle:nil];
    
    self.feedNavi = [[UINavigationController alloc] initWithRootViewController:self.feed];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects: login,                 // 0
                                                                       self.feedNavi,         // 1
                                                                       self.recognition,      // 2
                                                                       self.store,            // 3
                                                                       more,                  // 4
                                                                       nil];
    
    [self makeTabBarHidden:YES];
    self.tabBarController.delegate = self;
    
    self.window.rootViewController = self.tabBarController;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(![[userDefaults objectForKey:@"token"]isEqualToString:@""])
    {
        NSDate *expires = (NSDate *)[userDefaults objectForKey:@"expires"];
        NSDate *userExpires = (NSDate *)[userDefaults objectForKey:@"user.expires"];
        NSDate *now = [NSDate date];
        
        //NSLog(@"---- %@ --- %@",expires,now);
        
        if([expires compare:now] == NSOrderedDescending)
        {
            //NSLog(@"Checkpoint_1 --- %@ - %@ - %@", expires, userExpires, now);
            [APPDELEGATE goToFeed];
        }
        else
        {
            if([userExpires compare:now] == NSOrderedDescending)
            {
                //NSLog(@"Checkpoint_2 --- %@ - %@ - %@", expires, userExpires, now);
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                
                NSString *email =  [userDefaults objectForKey:@"user.login"];
                NSString *password =  [userDefaults objectForKey:@"user.pass"];
                
                NSArray *objects = [NSArray arrayWithObjects:email, password, nil];
                NSArray *keys = [NSArray arrayWithObjects:@"username", @"password", nil];
                
                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSDictionary *loginResponse = [[mrAPI sharedInstance] loginUser:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
                
                    //NSLog(@"Checkpoint_2.1 --- %@ -", loginResponse);
                    
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if([[loginResponse objectForKey:@"success"]isEqualToString:@"true"])
                        {
                            [userDefaults setObject:[loginResponse objectForKey:@"token"] forKey:@"token"];
                            [userDefaults setObject:email forKey:@"user.login"];
                            [userDefaults setObject:password forKey:@"user.pass"];
                            
                            int expiresInt = [[loginResponse objectForKey:@"expires"]intValue];
                            [userDefaults setObject:[[NSDate date]dateByAddingTimeInterval:(expiresInt * 60)] forKey:@"expires"];
                            
                            /*[userDefaults setObject:[[APPDELEGATE.dateFormatterServer dateFromString:[loginResponse objectForKey:@"expires"]]dateByAddingTimeInterval:-4*60] forKey:@"expires"];*/
                            
                            NSDate *expDate14 = [[NSDate date] dateByAddingTimeInterval:60*60*24*14];
                            [userDefaults setObject:expDate14 forKey:@"user.expires"];
                            
                            [userDefaults synchronize];
                            
                            //NSLog(@"Checkpoint_3 %@ - %@ - %@", expires, userExpires, now);
                            
                            [APPDELEGATE goToFeed];
                        }
                        else
                        {
                            [[NSFileManager defaultManager] removeItemAtPath:[DOCS stringByAppendingPathComponent:@"currentUser.plist"] error:NULL];
                            [Motivosity removeUserAvatar];
                        }
                    //});
               // });
            }
            else
            {
                [[NSFileManager defaultManager] removeItemAtPath:[DOCS stringByAppendingPathComponent:@"currentUser.plist"] error:NULL];
                [Motivosity removeUserAvatar];
            }
        }
    }
    
    [self.window makeKeyAndVisible];
    [self showSplashScreen];
    
    return YES;
}

- (void)mrValuesInit
{
    dateFormatterServer = [[NSDateFormatter alloc] init];
    [dateFormatterServer setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatterServer setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults objectForKey:@"settings55"];
    
    if (![result length])
    {
        [userDefaults setObject:@"" forKey:@"token"];
        [userDefaults setObject:@"" forKey:@"user.login"];
        [userDefaults setObject:@"" forKey:@"user.pass"];
        [userDefaults setObject:[NSDate date] forKey:@"expires"];
        [userDefaults setObject:[NSDate date] forKey:@"user.expires"];
        
        [userDefaults setObject:@"https://www.motivosity.com/" forKey:@"url.base"];
        [userDefaults setObject:@"https://motivosity.s3.amazonaws.com/" forKey:@"url.amazon"];
        
        /*[userDefaults setObject:@"https://staging.motivosity.com/" forKey:@"url.base"];
        [userDefaults setObject:@"https://motivosity-stage.s3.amazonaws.com/" forKey:@"url.amazon"];*/
        
        NSArray *emptyArray = [NSArray arrayWithObjects:nil];
        [emptyArray writeToFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"] atomically:YES];
        
        [userDefaults setObject:@"Team" forKey:@"scope.selected"];
        
        [userDefaults setObject:@"SETUP" forKey:@"settings55"];
        [userDefaults synchronize];
    }
}

- (void)goToLogin{
    [self.tabBarController setSelectedIndex:0];
}

- (void)goToFeed{
     [self.tabBarController setSelectedIndex:1];
}

- (void)goToRecognition{
    [self.tabBarController setSelectedIndex:2];
}

- (void)goToStore{
    [self.tabBarController setSelectedIndex:3];
}

- (void)goToMore{
    [self.tabBarController setSelectedIndex:4];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}

/* hide standart tabBar, because we use custom tabBar layout  */
- (void)makeTabBarHidden:(BOOL)hide
{
    // Custom code to hide TabBar
    if ( [self.tabBarController.view.subviews count] < 2 ) {
        return;
    }
    
    UIView *contentView;
    
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] ) {
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    } else {
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    }
    
    if (hide) {
        contentView.frame = self.tabBarController.view.bounds;
    }
    else {
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x,
                                       self.tabBarController.view.bounds.origin.y,
                                       self.tabBarController.view.bounds.size.width,
                                       self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    }
    
    self.tabBarController.tabBar.hidden = hide;
}


@end
