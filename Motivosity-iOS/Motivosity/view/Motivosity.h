//
//  Motivosity.h
//  Motivosity
//
//  Created by mr on 26.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Motivosity : NSObject

+ (BOOL)isEmailValid:(NSString *)email;
+ (BOOL)isPasswordValid:(NSString *)pass;
+ (int)getScreenHeigh;
+ (int)getScreenWidth;
+ (UIImage *)iconFromType:(NSString *)type;
+ (UIImage *)getEmptyImage;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (NSString *)getTitleFromDict:(NSDictionary *)dist;
+ (NSString *)getLikeStrFromDict:(NSDictionary *)dist;

+ (NSArray *)reloadStoreItems:(NSArray *)storeAr type:(NSString *)storeType;

+ (NSString *)getBaseURL;
+ (NSString *)getAmazonURL;

+ (void)saveUserAvatar:(UIImage *)img;
+ (UIImage *)getUserAvatar;
+ (void)removeUserAvatar;

@end
