//
//  UIApplication+PopUp.h
//  Foreclosures
//
//  Created by Igor on 10.03.12.
//  Copyright (c) 2012 BWS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (PopUp)

+(void)showPopUpErrorMessage:(NSString *)msg title:(NSString *)title hideTimout:(CGFloat)timeout animated:(BOOL)animated andDelay:(CGFloat)delay;
+(void)showPopUpOkMessage:(NSString *)msg title:(NSString *)title hideTimout:(CGFloat)timeout animated:(BOOL)animated andDelay:(CGFloat)delay;

@end
