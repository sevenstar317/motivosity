//
//  LoginVC.h
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface LoginVC : UIViewController<UIAlertViewDelegate>{

    UITextField *_activeField;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (strong, nonatomic) IBOutlet UIImageView *logoImg;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIView *whiteBox;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

- (IBAction)editingBegin:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)rememberAction:(id)sender;
- (IBAction)fieldChange:(id)sender;
- (IBAction)passwordResetAction:(id)sender;
- (void)sendResetPassword:(NSString *)email;

@property (strong, nonatomic) IBOutlet UIView *temp_Box;
@property (strong, nonatomic) IBOutlet UITextField *temp_baseUrl;
@property (strong, nonatomic) IBOutlet UITextField *temp_amazonUrl;
@end
