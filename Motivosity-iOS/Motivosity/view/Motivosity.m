//
//  Motivosity.m
//  Motivosity
//
//  Created by mr on 26.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "Motivosity.h"

@implementation Motivosity


+ (NSString *)getBaseURL{

    // @"https://staging.motivosity.com/"
    //@"https://www.motivosity.com/";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"url.base"];
}

+ (NSString *)getAmazonURL{
    
    // @"https://motivosity-stage.s3.amazonaws.com/"
    // @"https://motivosity.s3.amazonaws.com/";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"url.amazon"];
}

+ (BOOL)isEmailValid:(NSString *)email {
    NSString *pattern = @"^[A-Z0-9\\._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,6}$";
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger matchesNumber = [expression numberOfMatchesInString:email options:0 range:NSMakeRange(0, [email length])];
    if (matchesNumber == 0) {
        return NO;
    }
    return YES;
}

+ (BOOL)isPasswordValid:(NSString *)pass {
    
    if (pass.length < 1) {
        return NO;
    }
    return YES;
}

+ (int)getScreenHeigh{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return (int)screenRect.size.height;
}

+ (int)getScreenWidth{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return (int)screenRect.size.width;
}

+ (UIImage *)iconFromType:(NSString *)type{

    if([type isEqualToString:@"icon-calendar"])
        return [UIImage imageNamed:@"calendarIcon.png"];
    else if([type isEqualToString:@"icon-cake"])
        return [UIImage imageNamed:@"cakeIcon.png"];
    else if([type isEqualToString:@"icon-medal"])
        return [UIImage imageNamed:@"medalIcon.png"];
    else if([type isEqualToString:@"icon-target"])
        return [UIImage imageNamed:@"targetIcon.png"];
    else if([type isEqualToString:@"icon-brain"])
        return [UIImage imageNamed:@"brainIcon.png"];
    else if([type isEqualToString:@"icon-star"])
        return [UIImage imageNamed:@"starIcon.png"];
    else if([type isEqualToString:@"icon-bubbles"])
        return [UIImage imageNamed:@"bubblIcon.png"];
    else if([type isEqualToString:@"icon-info-sign"])
        return [UIImage imageNamed:@"infoIcon.png"];
    else if([type isEqualToString:@"icon-gift"])
        return [UIImage imageNamed:@"giftIcon.png"];
    else if([type isEqualToString:@"icon-light"])
        return [UIImage imageNamed:@"lightIcon.png"];
    else if([type isEqualToString:@"icon-prime"])
        return [UIImage imageNamed:@"primeIcon.png"];
    else if([type isEqualToString:@"icon-trophy"])
        return [UIImage imageNamed:@"trophyIcon.png"];
    else
        return [UIImage imageNamed:@""];
}

+ (UIImage *)getEmptyImage{
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 170), NO, 0.0);
    UIImage *blankIMG = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blankIMG;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSString *)getTitleFromDict:(NSDictionary *)dist{

    NSDictionary *subject = [dist objectForKey:@"subject"];
    
    NSString *realTitle;
    if([[dist objectForKey:@"feedType"]isEqualToString:@"INST"] || [[dist objectForKey:@"feedType"]isEqualToString:@"ANVY"] || [[dist objectForKey:@"feedType"]isEqualToString:@"INTE"]  || [[dist objectForKey:@"feedType"]isEqualToString:@"BDAY"])
    {
        realTitle = [NSString stringWithFormat:@"%@", [dist objectForKey:@"title"]];
    }
    else if([[dist objectForKey:@"feedType"]isEqualToString:@"APPR"])
    {
        realTitle = [NSString stringWithFormat:@"%@ received a thanks for \"%@\" from %@", [subject objectForKey:@"calculatedFirstName"], [NSString stringWithFormat:@"%@", [dist objectForKey:@"title"]], [dist objectForKey:@"createdByName"]];
    }
    else if([[dist objectForKey:@"feedType"]isEqualToString:@"GOAL"])
    {
        realTitle = [NSString stringWithFormat:@"%@", [dist objectForKey:@"title"]];
    }
    else if([[dist objectForKey:@"feedType"]isEqualToString:@"PERS"])
    {
        realTitle = [NSString stringWithFormat:@"%@", [dist objectForKey:@"title"]];
    }
    else
    {
        realTitle = [NSString stringWithFormat:@"%@", [dist objectForKey:@"title"]];
        /*NSDictionary *source = [dist objectForKey:@"source"];
        realTitle = [NSString stringWithFormat:@"%@ received a thanks from %@", [subject objectForKey:@"firstName"], [source objectForKey:@"fullName"]];*/
    }
    
    return realTitle;
}

+ (NSString *)getLikeStrFromDict:(NSDictionary *)dist{
    
    NSArray *likes = [dist objectForKey:@"likes"];
    
    if(likes.count < 1)
        return @"";
    
    NSMutableString *likeStr = [NSMutableString stringWithString:@""];
    
    for (int i=0; i<likes.count; i++) {
        
        NSDictionary *oneLike = [likes objectAtIndex:i];
        
        NSString *and = @"";
        NSString *likesthis = @"likes this.";
        
        if(likes.count > 1) {
            and = @"and ";
            likesthis = @"like this.";
        }
        
        if(i == (likes.count - 1))
        {
            [likeStr appendString:[NSString stringWithFormat:@"%@%@ %@",and, [oneLike objectForKey:@"fullName"],likesthis]];
        }
        else
        {
            if(i == (likes.count - 2))
                [likeStr appendString:[NSString stringWithFormat:@"%@ ",[oneLike objectForKey:@"fullName"]]];
            else
                [likeStr appendString:[NSString stringWithFormat:@"%@, ",[oneLike objectForKey:@"fullName"]]];
        }
    }
    
    return [NSString stringWithString:likeStr];
    
    //"Ann Perkins, Leslie Knope, and Ron Swanson like this.";
}

+ (NSArray *)reloadStoreItems:(NSArray *)storeAr type:(NSString *)storeType{

    NSMutableArray *resultAR = [NSMutableArray arrayWithCapacity:storeAr.count];
    
    for (int i=0; i<storeAr.count; i++)
    {
        NSDictionary *oneItem = [storeAr objectAtIndex:i];
        
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        [newDict addEntriesFromDictionary:oneItem];
        
        //NSLog(@"--- %@",[oneItem objectForKey:@"imageUrl"]);
        
        NSString *absURL;
        
        if ([[oneItem objectForKey:@"imageUrl"]containsString:@"resources/assets/img"])
            absURL = [NSString stringWithFormat:@"%@%@",[Motivosity getBaseURL],[oneItem objectForKey:@"imageUrl"]];
        else
            absURL = [NSString stringWithFormat:@"%@%@",[Motivosity getAmazonURL],[oneItem objectForKey:@"imageUrl"]];
        
        
        [newDict setObject:absURL forKey:@"absURL"];
        [newDict setObject:storeType forKey:@"storeType"];
        
        [resultAR addObject:newDict];
    }
    
    return [NSArray arrayWithArray:resultAR];
    //return storeAr;
}

+ (void)saveUserAvatar:(UIImage *)img {
    
    NSString *savedImagePath = [DOCS stringByAppendingPathComponent:@"userAvatar.png"];
    NSData *imageData = UIImagePNGRepresentation(img);
    [imageData writeToFile:savedImagePath atomically:YES];
}

+ (UIImage *)getUserAvatar {
    
    NSString *avaFile = [DOCS stringByAppendingPathComponent:@"userAvatar.png"];
    NSData *avaData = [[NSData alloc] initWithContentsOfFile:avaFile];
    
    if (avaData  == nil)
        return nil;
    else
        return [UIImage imageWithData:avaData];
}

+ (void)removeUserAvatar{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [DOCS stringByAppendingPathComponent:@"userAvatar.png"];
    [fileManager removeItemAtPath:filePath error:nil];
}


@end
