//
//  MoreVC.m
//  Motivosity
//
//  Created by mr on 07.01.15.
//  Copyright (c) 2015 MM. All rights reserved.
//

#import "MoreVC.h"

#import "MoreCell.h"

#import "UIImageView+WebCache.h"

@interface MoreVC ()

@end

@implementation MoreVC

@synthesize userAvaUrl, userFullName, userAvatar;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.userAvatar = nil;
    self.userAvaUrl = @"";
    self.userFullName = @"";

    for (UIButton *oneB in self.menuButtons){
        [oneB.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:oneB.titleLabel.font.pointSize]];
    }

    self.receivedLabel.text = @"";
    self.givingLabel.text = @"";
    
    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
    
    for (UILabel *oneL in self.oswaldLabels){
        [oneL setFont:[UIFont fontWithName:@"Oswald" size:oneL.font.pointSize]];
    }
    
    [self.moreTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.receivedLabel.text = @"";
    self.givingLabel.text = @"";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *cash = [[mrAPI sharedInstance] getUserCash];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGFloat cashGivingBalance = [[NSString stringWithFormat:@"%@",[cash objectForKey:@"cashGiving"]]floatValue];
            CGFloat cashReceivedBalance = [[NSString stringWithFormat:@"%@",[cash objectForKey:@"cashReceiving"]]floatValue];
            
            self.receivedLabel.text = [NSString stringWithFormat:@"$%.0f",cashReceivedBalance];
            self.givingLabel.text = [NSString stringWithFormat:@"$%.0f",cashGivingBalance];
        });
    });
    
    UIImage *userAvatarLocal = [Motivosity getUserAvatar];
    NSDictionary *userRow = [[NSDictionary alloc] initWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentUser.plist"]];
    
    if(userAvatarLocal == nil || userRow == nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSDictionary *currentUser = [[mrAPI sharedInstance] getUser];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSArray *mainObjects = [NSArray arrayWithObjects:[currentUser objectForKey:@"avatarUrl"],
                                        [currentUser objectForKey:@"fullName"],
                                        [currentUser objectForKey:@"calculatedFirstName"],
                                        [currentUser objectForKey:@"id"], nil];
                
                NSArray *mainKeys = [NSArray arrayWithObjects:@"avatarUrl", @"fullName", @"calculatedFirstName", @"id", nil];
                NSDictionary *mainDictionary = [NSDictionary dictionaryWithObjects:mainObjects forKeys:mainKeys];
                
                [mainDictionary writeToFile:[DOCS stringByAppendingPathComponent:@"currentUser.plist"] atomically:YES];
                
                self.userAvaUrl = [NSString stringWithFormat:@"%@%@",[Motivosity getAmazonURL],[currentUser objectForKey:@"avatarUrl"]];
                self.userFullName = [NSString stringWithFormat:@"%@",[currentUser objectForKey:@"fullName"]];
                [self.moreTable reloadData];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[Motivosity getAmazonURL],[currentUser objectForKey:@"avatarUrl"]]];
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    UIImage *image = [UIImage imageWithData:imageData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Motivosity saveUserAvatar:image];
                    });
                });
            });
        });
    }
    else
    {
        self.userAvatar = userAvatarLocal;
        self.userFullName = [NSString stringWithFormat:@"%@",[userRow objectForKey:@"fullName"]];
        [self.moreTable reloadData];
    }
}

/* table delegate functions */

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section == 1)
    {
        id copyOfView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.tableHeader]];
        UIView *header = (UIView *)copyOfView;
    
        for (id subview in [header subviews]) {
        
            if([subview isKindOfClass:[UILabel class]])
            {
                UILabel *labelSubview = (UILabel *)subview;
                [labelSubview setFont:[UIFont fontWithName:@"Lato-Bold" size:labelSubview.font.pointSize]];
            }
        }
    
        return header;
    }
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == 1)
    {
        return 20.0f;
    }
    else
        return 0.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:return 1;break;
        case 1:return 1;break;
        default:return 0;break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MoreCellID";
    
    MoreCell *cell = (MoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MoreCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if(indexPath.section == 0)
    {
        [cell.imgBG setBackgroundColor:[UIColor clearColor]];
        cell.cellTitle.text = self.userFullName;
        
        if(self.userAvatar == nil)
            [cell.img sd_setImageWithURL:[NSURL URLWithString:self.userAvaUrl] placeholderImage:nil];
        else
            [cell.img setImage:self.userAvatar];
        
        cell.img.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.img.layer.borderWidth = 1.0f;
    }
    else
    {
        [cell.imgBG setBackgroundColor:[UIColor colorWithRed:255/255.0f green:113/255.0f blue:82/255.0f alpha:1.0f]];
        cell.cellTitle.text = @"Logout";
        [cell.img setImage:[UIImage imageNamed:@"logoutIcon.png"]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"" forKey:@"token"];
        [userDefaults setObject:@"" forKey:@"user.login"];
        [userDefaults setObject:@"" forKey:@"user.pass"];
        [userDefaults setObject:[NSDate date] forKey:@"expires"];
        [userDefaults setObject:[NSDate date] forKey:@"user.expires"];
        [userDefaults synchronize];
        
        [[NSFileManager defaultManager] removeItemAtPath:[DOCS stringByAppendingPathComponent:@"currentUser.plist"] error:NULL];
        [Motivosity removeUserAvatar];
        [APPDELEGATE goToLogin];
    }
}

- (IBAction)goToHomeAction:(id)sender {
    [APPDELEGATE goToFeed];
}

- (IBAction)goToRecognitionAction:(id)sender {
    [APPDELEGATE goToRecognition];
}

- (IBAction)goToCartAction:(id)sender {
    [APPDELEGATE goToStore];
}

- (IBAction)goToMoreAction:(id)sender {
    [APPDELEGATE goToMore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
