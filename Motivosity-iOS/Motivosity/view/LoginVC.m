//
//  LoginVC.m
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "LoginVC.h"

#import "MBProgressHUD.h"

@interface LoginVC ()

@end

@implementation LoginVC

- (void)handleTap:(UITapGestureRecognizer*)recognizer {
    
    _activeField = nil;
    [self.mainScroll setContentOffset:CGPointMake(0, 0.0f) animated:YES];
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {
    self.temp_Box.hidden = NO;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 5.0f;
    [self.logoImg addGestureRecognizer:longPress];
    
    // temp
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.temp_baseUrl.text = [userDefaults objectForKey:@"url.base"];
    self.temp_amazonUrl.text = [userDefaults objectForKey:@"url.amazon"];
    
    self.checkBtn.tag = 1;
    [self.checkBtn setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
    
    self.checkBtn.layer.cornerRadius = 4;
    self.checkBtn.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:tap];
    
    self.logoImg.layer.cornerRadius = 2;
    self.logoImg.layer.masksToBounds = YES;
    
    self.loginBtn.layer.cornerRadius = 4;
    self.loginBtn.layer.masksToBounds = YES;
    
    self.whiteBox.layer.cornerRadius = 4;
    self.whiteBox.layer.masksToBounds = YES;
    
    self.temp_Box.layer.cornerRadius = 4;
    self.temp_Box.layer.masksToBounds = YES;
    
    self.temp_Box.hidden = YES;
    
    CGRect ri = [self.contentView frame];
    CGRect rs = [self.mainScroll frame];
    
    [self.mainScroll addSubview:self.contentView];
    [self.mainScroll setContentSize:CGSizeMake(rs.size.width, ri.size.height)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //NSLog(@"---- %f",scrollView.contentOffset.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)fieldChange:(id)sender{
  
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    UITextField *tf = (UITextField *)sender;
    
    if(tf == self.temp_baseUrl)
        [userDefaults setObject:tf.text forKey:@"url.base"];
    
    if(tf == self.temp_amazonUrl)
        [userDefaults setObject:tf.text forKey:@"url.amazon"];
    
    [userDefaults synchronize];
}


- (IBAction)editingBegin:(id)sender
{
    _activeField = sender;
    
    if(isIPhone6() || isIPhone6Plus())
        [self.mainScroll setContentOffset:CGPointMake(0, 140.0f) animated:YES];
    else if(isIPhone5())
        [self.mainScroll setContentOffset:CGPointMake(0, 132.0f) animated:YES];
    else
        [self.mainScroll setContentOffset:CGPointMake(0, 160.0f) animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.email)
        [self.password becomeFirstResponder];
    else
    {
        [textField resignFirstResponder], _activeField = nil;
        [self.mainScroll setContentOffset:CGPointMake(0, 0.0f) animated:YES];
    }
    
    return NO;
}

- (IBAction)loginAction:(id)sender {
    
    _activeField = nil;
    
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
    if([self fieldsIsValid])
    {
        MBProgressHUD *p = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [p setDimBackground:YES];
        [p setLabelText:@"Loading"];
        [p setMode:MBProgressHUDModeIndeterminate];
        [p show:YES];
        [p setRemoveFromSuperViewOnHide:YES];
        [self.view.window addSubview:p];
       
        NSString *email =  [NSString stringWithFormat:@"%@",[self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        NSString *password =  [NSString stringWithFormat:@"%@",[self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        
        NSArray *objects = [NSArray arrayWithObjects:email, password, nil];
        NSArray *keys = [NSArray arrayWithObjects:@"username", @"password", nil];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSDictionary *loginResponse = [[mrAPI sharedInstance] loginUser:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [p hide:YES];
                
                NSLog(@"---- %@",loginResponse);
                
                if([[loginResponse objectForKey:@"success"]isEqualToString:@"true"])
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:[loginResponse objectForKey:@"token"] forKey:@"token"];
                    [userDefaults setObject:email forKey:@"user.login"];
                    [userDefaults setObject:password forKey:@"user.pass"];
                    
                    /*[userDefaults setObject:[[APPDELEGATE.dateFormatterServer dateFromString:[loginResponse objectForKey:@"expires"]]dateByAddingTimeInterval:-4*60] forKey:@"expires"];*/
                    //NSLog(@"expires save after login ---%@",[APPDELEGATE.dateFormatterServer dateFromString:[loginResponse objectForKey:@"expires"]]);
                    //[userDefaults setObject:[APPDELEGATE.dateFormatterServer dateFromString:[loginResponse objectForKey:@"expires"]] forKey:@"expires"];
                    
                    int expiresInt = [[loginResponse objectForKey:@"expires"]intValue];
                    [userDefaults setObject:[[NSDate date]dateByAddingTimeInterval:(expiresInt * 60)] forKey:@"expires"];
                    
                    if(self.checkBtn.tag > 0)
                    {
                        NSDate *expDate14 = [[NSDate date] dateByAddingTimeInterval:60*60*24*14];
                        [userDefaults setObject:expDate14 forKey:@"user.expires"];
                    }
                    else
                        [userDefaults setObject:[NSDate date] forKey:@"user.expires"];
                    
                    [userDefaults synchronize];
                    
                    
                    self.email.text = @"";
                    self.password.text = @"";
                    
                    self.checkBtn.tag = 1;
                    [self.checkBtn setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
                    
                    // clear cart
                    NSArray *emptyArray = [NSArray arrayWithObjects:nil];
                    [emptyArray writeToFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"] atomically:YES];
                    
                    [APPDELEGATE.recognition dataRefresh];
                    [APPDELEGATE.feed reloadAfterLogin];
                    [APPDELEGATE goToFeed];
                    //[APPDELEGATE.feed reloadData:YES];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[loginResponse objectForKey:@"message"]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            });
        });
    }
}

- (IBAction)rememberAction:(id)sender {
    
    if(self.checkBtn.tag > 0)
    {
        self.checkBtn.tag = 0;
        [self.checkBtn setImage:[Motivosity getEmptyImage] forState:UIControlStateNormal];
    }
    else
    {
        self.checkBtn.tag = 1;
        [self.checkBtn setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
    }
}

- (BOOL)fieldsIsValid{
    
    BOOL formValid = YES;
    
    NSString *email =  [self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password =  [self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(![Motivosity isEmailValid:email])
    {
        formValid = NO;
        
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Please enter your correct email."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]show];
    }
    else if(![Motivosity isPasswordValid:password])
    {
        formValid = NO;
        
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Please enter your password."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]show];
        
    }
    
    return formValid;
}

- (IBAction)passwordResetAction:(id)sender{
    
    NSString *email =  [self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([Motivosity isEmailValid:email])
    {
        [self sendResetPassword:email];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Request a new password"
                                                         message:@"Please enter your email"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Request", nil];
        
        [alert setDelegate:self];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 10010;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    @try {
        switch ([alertView tag])
        {
            case 10010:
            {
                if (buttonIndex == 1)
                {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    NSString *email =  [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    
                    if(![Motivosity isEmailValid:email])
                    {
                        
                        [[[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Please enter your correct email."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil]show];
                    }
                    else
                    {
                        [self sendResetPassword:email];
                    }
                }
                break;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception occurred in alertView: %@, %@", exception, [exception userInfo]);
    }
}


- (void)sendResetPassword:(NSString *)email
{
    MBProgressHUD *p = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    [p setDimBackground:YES];
    [p setLabelText:@"Loading"];
    [p setMode:MBProgressHUDModeIndeterminate];
    [p show:YES];
    [p setRemoveFromSuperViewOnHide:YES];
    [self.view.window addSubview:p];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *resetResponse = [[mrAPI sharedInstance] passReset:email];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [p hide:YES];
            
            //NSLog(@"---- %@",resetResponse);
            
            if([[resetResponse objectForKey:@"success"]isEqualToString:@"true"])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success"
                                                                message:[resetResponse objectForKey:@"message"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[resetResponse objectForKey:@"message"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        });
    });

}

@end
