//
//  UIApplication+PopUp.m
//  Foreclosures
//
//  Created by Igor on 10.03.12.
//  Copyright (c) 2012 BWS. All rights reserved.
//

#import "UIApplication+PopUp.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

#define defaultHideTime 2.0f

@implementation UIApplication(PopUp)

-(void)showPopUpMessage:(NSString *)msg title:(NSString *)title hideTimout:(CGFloat)time animated:(BOOL)animated andImage:(NSString *)image
{
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	UIView *customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:image]] autorelease];
	
	//MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:app.window.rootViewController.view animated:animated];
	MBProgressHUD *hud = [[[MBProgressHUD alloc] initWithWindow:app.window] autorelease];
	[hud show:YES];
	[hud setCustomView:customView];
	[hud setMode:MBProgressHUDModeCustomView];
	[hud setLabelText:(title ? title : @"")];
	[hud setDetailsLabelText:(msg ? msg : @"")];
	[hud hide:YES afterDelay:time];
	[hud setDimBackground:YES];
	[hud setRemoveFromSuperViewOnHide:YES];
	[app.window addSubview:hud];
}

-(void)showPopUpMessageBackground:(NSDictionary *)params
{
	[self showPopUpMessage:[params objectForKey:@"msg"]
					 title:[params objectForKey:@"title"]
				hideTimout:[[params objectForKey:@"timeout"] floatValue]
				  animated:[[params objectForKey:@"animated"] boolValue]
					 andImage:[params objectForKey:@"image"]
	 ];
}

#pragma mark - Static methods

+(void)showPopUpMessage:(NSString *)msg title:(NSString *)title hideTimout:(CGFloat)timeout animated:(BOOL)animated delay:(CGFloat)delay isError:(BOOL)error
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
	if (msg)
		[params setObject:msg forKey:@"msg"];
	
	if (title)
		[params setObject:title forKey:@"title"];
	
	[params setObject:(error ? @"error.png" : @"checkmark.png") forKey:@"image"];
	[params setObject:[NSNumber numberWithFloat:(timeout>0.1f ? timeout : defaultHideTime)] forKey:@"timeout"];
	[params setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];

	[[UIApplication sharedApplication] performSelector:@selector(showPopUpMessageBackground:) withObject:params afterDelay:delay];
}

+(void)showPopUpErrorMessage:(NSString *)msg title:(NSString *)title hideTimout:(CGFloat)timeout animated:(BOOL)animated andDelay:(CGFloat)delay;
{
	[UIApplication showPopUpMessage:msg title:title hideTimout:timeout animated:animated delay:delay isError:YES];
}

+(void)showPopUpOkMessage:(NSString *)msg title:(NSString *)title hideTimout:(CGFloat)timeout animated:(BOOL)animated andDelay:(CGFloat)delay
{
	[UIApplication showPopUpMessage:msg title:title hideTimout:timeout animated:animated delay:delay isError:NO];
}
@end
