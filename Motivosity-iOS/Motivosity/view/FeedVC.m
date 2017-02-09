//
//  FeedVC.m
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "FeedVC.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface FeedVC ()

@end

@implementation FeedVC

@synthesize feed;
@synthesize menuTypes;
@synthesize selectedMenu;
@synthesize currentPage;
@synthesize currentUserRow;

- (void)handleRefresh:(UIRefreshControl *)sender{
    
    self.currentPage = 0;
    self.feed = [NSMutableArray arrayWithCapacity:0];
    [self.feedTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self.feedTable reloadData];
    
    [self reloadData:NO];
    [refreshControl endRefreshing];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    for (UIButton *oneB in self.menuButtons){
        [oneB.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:oneB.titleLabel.font.pointSize]];
    }
    
    self.currentPage = 0;
    self.feed = [NSMutableArray arrayWithCapacity:0];
    
    [self.userImg setImage:[Motivosity getEmptyImage]];
    self.receivedLabel.text = @"";
    self.givingLabel.text = @"";
    self.currentUserRow = nil;
    
    self.navigationController.navigationBar.hidden = YES;
    [self.feedTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor whiteColor]];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.feedTable addSubview:refreshControl];
    
    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
    
    [self.titleLabel setFont: [UIFont latoLightFontOfSize:self.titleLabel.font.pointSize]];
    self.menuTypes = [NSArray arrayWithObjects:@"Company", @"Department", @"Extended Team", @"Team", nil];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.selectedMenu = [userDefaults objectForKey:@"scope.selected"];
    NSString *allText = [NSString stringWithFormat:@"What's new on my %@",self.selectedMenu];
    
    NSString * type = self.selectedMenu;
    [self.titleLabel setText:allText afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
    
        NSRange typeRange = [[mutableAttributedString string] rangeOfString:type options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:[UIFont fontWithName:@"Lato-Bold" size:16.0f] range:typeRange];
        return mutableAttributedString;
    }];
    
    for (UILabel *oneL in self.oswaldLabels){
        [oneL setFont:[UIFont fontWithName:@"Oswald" size:oneL.font.pointSize]];
    }
    
    self.userImg.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userImg.layer.borderWidth = 1.0f;
    self.userImg.layer.cornerRadius = 2;
    self.userImg.layer.masksToBounds = YES;
    
    [self.view addSubview:self.typeSelectView];
    self.typeSelectView.hidden = YES;
    
    [self reloadData:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    
    /*self.currentPage = 0;
    self.feed = [NSMutableArray arrayWithCapacity:0];
    [self reloadData:YES];*/

    [self reloadCashAndUser];
    [super viewWillAppear:animated];
}

- (void)reloadCashAndUser
{
    [self.userImg setImage:[Motivosity getEmptyImage]];
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
    
    UIImage *userAvatar = [Motivosity getUserAvatar];
    NSDictionary *userRow = [[NSDictionary alloc] initWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentUser.plist"]];
    
    if(userAvatar == nil || userRow == nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            NSDictionary *currentUser = [[mrAPI sharedInstance] getUser];
            
            //NSLog(@"--- %@", currentUser);
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSArray *mainObjects = [NSArray arrayWithObjects:[currentUser objectForKey:@"avatarUrl"],
                                                                 [currentUser objectForKey:@"fullName"],
                                                                 [currentUser objectForKey:@"calculatedFirstName"],
                                                                 [currentUser objectForKey:@"id"], nil];
                
                NSArray *mainKeys = [NSArray arrayWithObjects:@"avatarUrl", @"fullName", @"calculatedFirstName", @"id", nil];
                NSDictionary *mainDictionary = [NSDictionary dictionaryWithObjects:mainObjects forKeys:mainKeys];
                
                [mainDictionary writeToFile:[DOCS stringByAppendingPathComponent:@"currentUser.plist"] atomically:YES];
                
                self.currentUserRow = mainDictionary;
                [self.userImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[Motivosity getAmazonURL],[currentUser objectForKey:@"avatarUrl"]]] placeholderImage:nil];
                
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
        [self.userImg setImage:userAvatar];
        self.currentUserRow = userRow;
    }
}

- (IBAction)selectMenuAction:(id)sender {
    
    [self.menuPicker reloadAllComponents];
    
    int selectedRow = 0;
    
    for (int i=0; i<self.menuTypes.count; i++) {
        
        if([[self.menuTypes objectAtIndex:i]isEqualToString:self.selectedMenu])
            selectedRow = i;
    }
    
    [self.menuPicker selectRow:selectedRow inComponent:0 animated:NO];
    
    self.typeSelectView.hidden = NO;
}

- (IBAction)menuCancelAction:(id)sender {
    self.typeSelectView.hidden = YES;
}

- (IBAction)menuSetAction:(id)sender {
    
    self.selectedMenu = [self.menuTypes objectAtIndex:[self.menuPicker selectedRowInComponent:0]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.selectedMenu forKey:@"scope.selected"];
    [userDefaults synchronize];
    
    NSString *allText = [NSString stringWithFormat:@"What's new on my %@",self.selectedMenu];
    
    NSString * type = self.selectedMenu;
    [self.titleLabel setText:allText afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange typeRange = [[mutableAttributedString string] rangeOfString:type options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:[UIFont fontWithName:@"Lato-Bold" size:16.0f] range:typeRange];
        return mutableAttributedString;
    }];
    
    [self menuCancelAction:nil];
    
    /*NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.feedTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];*/
    
    self.currentPage = 0;
    self.feed = [NSMutableArray arrayWithCapacity:0];
    
    [self.feedTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self.feedTable reloadData];
    
    [self reloadData:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.menuTypes.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [self.menuTypes objectAtIndex:row];
}

- (void)reloadAfterAppreciation{

    self.currentPage = 0;
    self.feed = [NSMutableArray arrayWithCapacity:0];
    [self reloadData:NO];
}

- (void)reloadAfterLogin{
    
    self.selectedMenu = @"Team";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.selectedMenu forKey:@"scope.selected"];
    [userDefaults synchronize];
    
    NSString *allText = [NSString stringWithFormat:@"What's new on my %@",self.selectedMenu];
    
    NSString * type = self.selectedMenu;
    [self.titleLabel setText:allText afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange typeRange = [[mutableAttributedString string] rangeOfString:type options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:[UIFont fontWithName:@"Lato-Bold" size:16.0f] range:typeRange];
        return mutableAttributedString;
    }];
    
    
    self.currentPage = 0;
    self.feed = [NSMutableArray arrayWithCapacity:0];
    
    [self.feedTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self.feedTable reloadData];
    
    [self reloadData:YES];
}

- (void)reloadData:(BOOL)andCache{

    MBProgressHUD *p;
    if(!andCache)
    {
        p = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
        [p setDimBackground:YES];
        [p setLabelText:@"Loading"];
        [p setMode:MBProgressHUDModeIndeterminate];
        [p show:YES];
        [p setRemoveFromSuperViewOnHide:YES];
        [[[UIApplication sharedApplication] keyWindow] addSubview:p];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *arrayFromServer = [[mrAPI sharedInstance] getFeedItems:self.selectedMenu page:self.currentPage];
         dispatch_async(dispatch_get_main_queue(), ^{
            
            //NSLog(@"arrayFromServer --- %@",arrayFromServer);
            
            if(andCache)
                [self reloadCashAndUser];
            else
                [p hide:YES];
            
            if(arrayFromServer.count > 0)
            {
                if([arrayFromServer isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *tempResp = (NSDictionary *)arrayFromServer;
                
                    //NSLog(@"Checkpoint_4 ---- %@",tempResp);
                
                    //NSLog(@"-- %@",tempResp);
                
                    if([[tempResp objectForKey:@"message"]isEqualToString:@"access is denied"])
                    {
                        /*NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:@"" forKey:@"token"];
                        [userDefaults setObject:@"" forKey:@"user.login"];
                        [userDefaults setObject:@"" forKey:@"user.pass"];
                        [userDefaults setObject:[NSDate date] forKey:@"expires"];
                        [userDefaults setObject:[NSDate date] forKey:@"user.expires"];
                        [userDefaults synchronize];*/
                    
                        [APPDELEGATE.tabBarController setSelectedIndex:0];
                        return;
                    }
                }
            
                for (int i=0; i<arrayFromServer.count; i++)
                {
                    id oneItem = [arrayFromServer objectAtIndex:i];
                    if (![[oneItem objectForKey:@"id"] isEqual:[NSNull null]])
                        [self.feed addObject:oneItem];
                }
            
                [self.feedTable reloadData];
            
                /*if(self.feed.count > 0)
                 [self.feedTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];*/
                //NSLog(@"-- %@",self.feed);
            }
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/* table delegate functions */

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return self.feedTableHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 80.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize maximumLabelSize = CGSizeMake(312,9999);
    
    //NSLog(@"--- %@", [self.feed objectAtIndex:indexPath.row]);
    
    NSDictionary *oneItem = [self.feed objectAtIndex:indexPath.row];
    
    NSString *contentStr = @"";
    if ([oneItem objectForKey:@"note"] != nil && ![[oneItem objectForKey:@"note"] isEqual:[NSNull null]]) {
        contentStr = [NSString stringWithFormat:@"%@",[oneItem objectForKey:@"note"]];
    }
    
    CGSize expectedLabelSize = [contentStr sizeWithFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]
                                      constrainedToSize:maximumLabelSize
                                   lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat featureH = expectedLabelSize.height + 8.0f;
    
    CGSize expectedLabelSizeTitle = [[Motivosity getTitleFromDict:oneItem] sizeWithFont:[UIFont fontWithName:@"Lato-Bold" size:14.0f]
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat featureHTitle = expectedLabelSizeTitle.height;
    
    return featureH + 116.0f + featureHTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedCellID";
    
    FeedCell *cell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeedCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.oneItem = [self.feed objectAtIndex:indexPath.row];
    [cell setCellInfo];
    
    if (indexPath.row == [self.feed count] - 1)
    {
        self.currentPage = self.currentPage + 1;
        [self reloadData:NO];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (void)likeCountInc:(NSDictionary *)newItem
{
    for (int i=0; i<self.feed.count; i++)
    {
        NSDictionary *oneItem = [self.feed objectAtIndex:i];
        
        if([[oneItem objectForKey:@"id"]isEqualToString:[newItem objectForKey:@"id"]])
        {
            [self.feed replaceObjectAtIndex:i withObject:newItem];
        }
    }

    [self.feedTable reloadData];
}

- (void)addCommentToFeed:(NSString *)itemID commentDist:(NSDictionary *)commentResp{

    for (int i=0; i<self.feed.count; i++)
    {
        NSDictionary *oneItem = [self.feed objectAtIndex:i];
        
        if([[oneItem objectForKey:@"id"]isEqualToString:itemID])
        {
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
            [newDict addEntriesFromDictionary:oneItem];
    
            if([newDict valueForKey:@"commentList"] != nil)
            {
                NSMutableArray *comments = [NSMutableArray arrayWithArray:[newDict objectForKey:@"commentList"] ];
                [comments addObject:commentResp];
                [newDict setObject:comments forKey:@"commentList"];
            }
            else
            {
                [newDict setObject:[NSArray arrayWithObjects:commentResp, nil] forKey:@"commentList"];
            }
            
            [self.feed replaceObjectAtIndex:i withObject:newDict];
        }
    }
    
    [self.feedTable reloadData];

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

@end
