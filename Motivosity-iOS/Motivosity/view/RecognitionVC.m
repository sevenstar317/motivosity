//
//  RecognitionVC.m
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "RecognitionVC.h"

#import "UserCell.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface RecognitionVC ()

@end

@implementation RecognitionVC

@synthesize listTimer;
@synthesize companies;
@synthesize companyValueID;
@synthesize users;
@synthesize toUser;
@synthesize cashGivingBalance;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    for (UIButton *oneB in self.menuButtons){
        [oneB.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:oneB.titleLabel.font.pointSize]];
    }

    self.postBtn.enabled = NO;
    self.cashGivingBalance = 0.0f;
    
    self.receivedLabel.text = @"";
    self.givingLabel.text = @"";
    
    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
    
    for (UILabel *oneL in self.oswaldLabels){
        [oneL setFont:[UIFont fontWithName:@"Oswald" size:oneL.font.pointSize]];
    }
    
    for (UIView *oneV in self.roundedBoxes){
        oneV.layer.cornerRadius = 6;
        oneV.layer.masksToBounds = YES;
    }
    
    [self.searchField setFont:[UIFont fontWithName:@"Lato-Light" size:self.searchField.font.pointSize]];
    [self.commentField setFont:[UIFont fontWithName:@"Lato-Bold" size:self.commentField.font.pointSize]];
    [self.postBtn.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:self.postBtn.titleLabel.font.pointSize]];
    [self.amount setFont:[UIFont fontWithName:@"Lato-Bold" size:self.amount.font.pointSize]];
    
    self.searchBox.layer.borderColor = [UIColor colorWithRed:161/255.0f green:161/255.0f blue:161/255.0f alpha:1.0f].CGColor;
    self.searchBox.layer.borderWidth = 1.0f;
    self.searchBox.layer.cornerRadius = 6;
    self.searchBox.layer.masksToBounds = YES;
    
    self.commentBox.layer.borderColor = [UIColor colorWithRed:215/255.0f green:215/255.0f blue:215/255.0f alpha:1.0f].CGColor;
    self.commentBox.layer.borderWidth = 1.0f;
    self.commentBox.layer.cornerRadius = 6;
    self.commentBox.layer.masksToBounds = YES;
    
    CGRect ri = [self.contentView frame];
    CGRect rs = [self.mainScroll frame];
    
    [self.mainScroll addSubview:self.contentView];
    [self.mainScroll setContentSize:CGSizeMake(rs.size.width, ri.size.height)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:@"UIKeyboardWillShowNotification"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:@"UIKeyboardWillHideNotification"
                                               object:nil];

    [self.view addSubview:self.companySelectView];
    self.companySelectView.hidden = YES;
    self.usersTable.hidden = YES;
    
    self.toUser = nil;
    
    [self dataRefresh];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    self.receivedLabel.text = @"";
    self.givingLabel.text = @"";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *cash = [[mrAPI sharedInstance] getUserCash];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.postBtn.enabled = YES;
            
            self.cashGivingBalance = [[NSString stringWithFormat:@"%@",[cash objectForKey:@"cashGiving"]]floatValue];
            CGFloat cashReceivedBalance = [[NSString stringWithFormat:@"%@",[cash objectForKey:@"cashReceiving"]]floatValue];
            
            self.receivedLabel.text = [NSString stringWithFormat:@"$%.0f",cashReceivedBalance];
            self.givingLabel.text = [NSString stringWithFormat:@"$%.0f",self.cashGivingBalance];
        });
    });
}

- (void)dataRefresh{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *compnanyResp = [[mrAPI sharedInstance] getCompanyList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.companies = compnanyResp;
            
            if(self.companies.count > 0)
            {
                NSDictionary *oneItem = [self.companies objectAtIndex:0];
                self.selectedCompanyLabel.text = [NSString stringWithFormat:@"%@",[oneItem objectForKey:@"name"]];
                self.companyValueID = [oneItem objectForKey:@"id"];
            }
            
            //NSLog(@"--- %@",compnanyResp);
        });
    });
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self.commentField becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [self.searchField resignFirstResponder];
    [self.commentField resignFirstResponder];
    [self.amount resignFirstResponder];
    
    [self stopTimer];
    if ([listTimer isValid]) {
        [listTimer invalidate];
    }
    
    self.listTimer = nil;
    
    [super viewWillDisappear:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*if (textField == self.searchField)
    {
        [self.commentField becomeFirstResponder];
        
        if(isIPhone6() || isIPhone6Plus())
            [self.mainScroll setContentOffset:CGPointMake(0, 0.0f) animated:YES];
        else if(isIPhone5())
            [self.mainScroll setContentOffset:CGPointMake(0, 38.0f) animated:YES];
        else
            [self.mainScroll setContentOffset:CGPointMake(0, 124.0f) animated:YES];
    }
    else
    {
        [self.searchField becomeFirstResponder];
        [self.mainScroll setContentOffset:CGPointMake(0, 0.0f) animated:YES];
    }*/
    
    [textField resignFirstResponder];
    [self.mainScroll setContentOffset:CGPointMake(0, 0.0f) animated:YES];
    return NO;
}

- (IBAction)editingBegin:(id)sender
{
    _activeField = sender;
    
   if(_activeField == self.searchField)
   {
       [self.mainScroll setContentOffset:CGPointMake(0, 0.0f) animated:YES];
   }
   else
   {
       if(isIPhone6() || isIPhone6Plus())
           [self.mainScroll setContentOffset:CGPointMake(0, 0.0f) animated:YES];
       else if(isIPhone5())
           [self.mainScroll setContentOffset:CGPointMake(0, 58.0f) animated:YES];
       else
           [self.mainScroll setContentOffset:CGPointMake(0, 124.0f) animated:YES];
   }
}

- (IBAction)postAction:(id)sender {
    
    NSString *comment =  [self.commentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    float amountVal =  (float)[[self.amount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]floatValue];
    
    [self.commentField resignFirstResponder];
    [self.searchField resignFirstResponder];
    [self.amount resignFirstResponder];
    
    if(amountVal > self.cashGivingBalance)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:[NSString stringWithFormat:@"You can give up to $%.2f right now", self.cashGivingBalance]
                                                        delegate:self cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    if(self.toUser == nil)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:@"Please select user"
                                                        delegate:self cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    /*if(amountVal == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:@"Please enter amount"
                                                        delegate:self cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        
        [alert show];
        return;
    }*/

    if(comment.length < 1)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:@"Please enter your comment"
                                                        delegate:self cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    MBProgressHUD *p = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    [p setDimBackground:YES];
    [p setLabelText:@"Loading"];
    [p setMode:MBProgressHUDModeIndeterminate];
    [p show:YES];
    [p setRemoveFromSuperViewOnHide:YES];
    [self.view.window addSubview:p];
    
    //NSLog(@"--- %@",self.toUser);
    
    NSArray *objects = [NSArray arrayWithObjects:[self.toUser objectForKey:@"fullName"],
                                                 [self.toUser objectForKey:@"id"],
                                                 comment,
                                                 self.companyValueID,
                                                 [NSNumber numberWithFloat:amountVal], nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"toUserName", @"toUserID", @"note", @"companyValueID", @"amount", nil];
    
    NSDictionary *appreciationRow = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *appreciationResp = [[mrAPI sharedInstance] saveAppreciation:appreciationRow];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //NSLog(@"appreciationResp ---- %@",appreciationResp);
            
            [p hide:YES];
            
            if (![[appreciationResp objectForKey:@"id"] isEqual:[NSNull null]])
            {
                self.commentField.text = @"";
                self.searchField.text = @"";
                self.amount.text = @"";
                
                [self.userToAvatar setImage:[Motivosity getEmptyImage]];
                self.toUser = nil;
               
                [APPDELEGATE goToFeed];
                [APPDELEGATE.feed reloadAfterAppreciation];
            }
            
        });
    });
}

- (IBAction)companySelectAction:(id)sender {
    
    [self.commentField resignFirstResponder];
    [self.amount resignFirstResponder];
    [self.searchField resignFirstResponder];
    
    [self.companyPicker reloadAllComponents];
    
    int selectedRow = 0;
    
    for (int i=0; i<self.companies.count; i++) {
        
        if([[[self.companies objectAtIndex:i]objectForKey:@"name"]isEqualToString:self.selectedCompanyLabel.text])
            selectedRow = i;
    }
    
    [self.companyPicker selectRow:selectedRow inComponent:0 animated:NO];
    
    self.companySelectView.hidden = NO;
}

- (IBAction)companyCancelAction:(id)sender {
    
    self.companySelectView.hidden = YES;
}

- (IBAction)companySetAction:(id)sender {
    
    self.companyValueID = [[self.companies objectAtIndex:[self.companyPicker selectedRowInComponent:0]] objectForKey:@"id"];
    self.selectedCompanyLabel.text = [NSString stringWithFormat:@"%@",[[self.companies objectAtIndex:[self.companyPicker selectedRowInComponent:0]]objectForKey:@"name"]];
    [self companyCancelAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)fieldChange:(id)sender{
    
    UITextField *field = (UITextField *)sender;
    
    if(field == self.searchField)
    {
        [self.userToAvatar setImage:[Motivosity getEmptyImage]];
        self.toUser = nil;
        [self startTimer];
    }
}

- (void)startTimer {
    
    [self stopTimer];
    
    self.listTimer = nil;
    self.listTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                    target:self
                                                  selector:@selector(tick)
                                                  userInfo:nil
                                                   repeats:NO];
    
    [[NSRunLoop currentRunLoop ] addTimer:self.listTimer forMode:NSDefaultRunLoopMode];
}

- (void)tick {
   
    NSString *chars = [NSString stringWithFormat:@"%@",[self.searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

    if(chars.length > 0)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *usersResp = [[mrAPI sharedInstance] searchUsersList:chars];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.users = usersResp;
                
                if(self.users.count > 0)
                {
                    [self.usersTable reloadData];
                    [self.usersTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    self.usersTable.hidden = NO;
                }
                else
                {
                    [self.userToAvatar setImage:[Motivosity getEmptyImage]];
                    self.toUser = nil;
                     self.usersTable.hidden = YES;
                }
                
                //NSLog(@"--- %@",usersResp);
            });
        });
    }
}

- (void)stopTimer
{
    if ([listTimer isValid]) {
        [listTimer invalidate];
    }
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.companies.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [[self.companies objectAtIndex:row]objectForKey:@"name"];
}

- (void) keyboardWillShow:(NSNotification *)note {
    
    if(self.bottomInputBox.frame.origin.y == [Motivosity getScreenHeigh] - self.bottomMenuBar.frame.size.height - self.bottomInputBox.frame.size.height - self.mainCanteiner.frame.origin.y)
    {
        NSDictionary *userInfo = [note userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        //NSLog(@"Keyboard Height: %f Width: %f", kbSize.height, kbSize.width);
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.bottomInputBox setFrame:CGRectMake(self.bottomInputBox.frame.origin.x, [Motivosity getScreenHeigh] - self.bottomInputBox.frame.size.height - self.mainCanteiner.frame.origin.y - self.bottomMenuBar.frame.size.height - kbSize.height, self.bottomInputBox.frame.size.width, self.bottomInputBox.frame.size.height)];
            
            [self.bottomMenuBar setFrame:CGRectMake(self.bottomMenuBar.frame.origin.x, [Motivosity getScreenHeigh] - self.mainCanteiner.frame.origin.y - self.bottomMenuBar.frame.size.height - kbSize.height, self.bottomMenuBar.frame.size.width, self.bottomMenuBar.frame.size.height)];
        }];
    }
}

- (void) keyboardWillHide:(NSNotification *)note {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.bottomInputBox setFrame:CGRectMake(self.bottomInputBox.frame.origin.x, [Motivosity getScreenHeigh] - self.bottomMenuBar.frame.size.height - self.bottomInputBox.frame.size.height - self.mainCanteiner.frame.origin.y, self.bottomInputBox.frame.size.width, self.bottomInputBox.frame.size.height)];
        
        [self.bottomMenuBar setFrame:CGRectMake(self.bottomMenuBar.frame.origin.x, [Motivosity getScreenHeigh] - self.bottomMenuBar.frame.size.height - self.mainCanteiner.frame.origin.y, self.bottomMenuBar.frame.size.width, self.bottomMenuBar.frame.size.height)];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"---- %f",scrollView.contentOffset.y);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  32.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCellID";
    
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.oneItem = [self.users objectAtIndex:indexPath.row];
    [cell setCellInfo];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *oneItem = [self.users objectAtIndex:indexPath.row];
    
    self.toUser = oneItem;
    [self.searchField setText:[NSString stringWithFormat:@"%@",[oneItem objectForKey:@"fullName"]]];
    [self.userToAvatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[Motivosity getAmazonURL],[oneItem objectForKey:@"avatarUrl"]]] placeholderImage:nil];
    self.usersTable.hidden = YES;
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
