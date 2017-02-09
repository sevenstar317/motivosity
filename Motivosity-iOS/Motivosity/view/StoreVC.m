//
//  StoreVC.m
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "StoreVC.h"

@interface StoreVC ()

@end

@implementation StoreVC

@synthesize storeDigital, storeLocal, storeCharity;
@synthesize selectedCartItem;
@synthesize countFields;
@synthesize cashReceivedBalance;

- (void)handleTap:(UITapGestureRecognizer*)recognizer {
    
    if(![self.cartView isHidden])
    {
        for (int i = 0; i < self.countFields.count; i++) {
            UITextField *oneFld = [self.countFields objectAtIndex:i];
            [oneFld resignFirstResponder];
        }
        self.cartView.hidden = YES;
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    for (UIButton *oneB in self.menuButtons){
        [oneB.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:oneB.titleLabel.font.pointSize]];
    }
    
    self.countFields = [NSMutableArray arrayWithCapacity:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:tap];
    
    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
    
    for (UILabel *oneL in self.oswaldLabels){
        [oneL setFont:[UIFont fontWithName:@"Oswald" size:oneL.font.pointSize]];
    }
    
    for (UIButton *oneB in self.latoBtns){
        [oneB.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:oneB.titleLabel.font.pointSize]];
    }
    
    for (UIImageView *oneS in self.cartTableSeparators){
        oneS.frame = CGRectMake(oneS.frame.origin.x, oneS.frame.origin.y, oneS.frame.size.width, 0.5f);
    }
    
    [self.cartTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.storeTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
 
    self.receivedLabel.text = @"";
    self.givingLabel.text = @"";
    
    [self.cartBtn.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:self.cartBtn.titleLabel.font.pointSize]];
    
    self.storeDigital = nil;
    self.storeLocal = nil;
    self.storeCharity = nil;
    
    self.cartView.layer.borderColor = [UIColor colorWithRed:189/255.0f green:189/255.0f blue:189/255.0f alpha:1.0f].CGColor;
    self.cartView.layer.borderWidth = 1.0f;
    self.cartView.layer.cornerRadius = 2;
    self.cartView.layer.masksToBounds = YES;
    self.cartView.hidden = YES;
    
    self.orderBtn.layer.cornerRadius = 6;
    self.orderBtn.layer.masksToBounds = YES;
    
    self.cashReceivedBalance = 0.0f;
    
    [self reloadCartInformation];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self reloadCartInformation];
    
    [self reloadData];
    
    [self reloadCashInfo];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    for (int i = 0; i < self.countFields.count; i++) {
        UITextField *oneFld = [self.countFields objectAtIndex:i];
        [oneFld resignFirstResponder];
    }
    
    self.cartView.hidden = YES;
}

- (void)reloadCashInfo{

    self.receivedLabel.text = @"";
    self.givingLabel.text = @"";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *cash = [[mrAPI sharedInstance] getUserCash];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGFloat cashGivingBalance = [[NSString stringWithFormat:@"%@",[cash objectForKey:@"cashGiving"]]floatValue];
            self.cashReceivedBalance = [[NSString stringWithFormat:@"%@",[cash objectForKey:@"cashReceiving"]]floatValue];
            
            self.receivedLabel.text = [NSString stringWithFormat:@"$%.0f",self.cashReceivedBalance];
            self.givingLabel.text = [NSString stringWithFormat:@"$%.0f",cashGivingBalance];
        });
    });
}

- (void)reloadData{
    
    self.storeTable.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *storeFromServer1 = [[mrAPI sharedInstance] getStoreItems:@"digital"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.storeDigital = [Motivosity reloadStoreItems:storeFromServer1 type:@"digital"];
            //NSLog(@"---- %@",storeFromServer1);
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *storeFromServer2 = [[mrAPI sharedInstance] getStoreItems:@"local"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.storeLocal = [Motivosity reloadStoreItems:storeFromServer2 type:@"local"];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSArray *storeFromServer3 = [[mrAPI sharedInstance] getStoreItems:@"charity"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            self.storeCharity = [Motivosity reloadStoreItems:storeFromServer3 type:@"charity"];
                            
                            [self.storeTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                            [self.storeTable reloadData];
                            self.storeTable.hidden = NO;
                        });
                    });
                });
            });
        });
    });
}

/* table delegate functions */

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(tableView == self.storeTable)
        return self.storeTableHeader;
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(tableView == self.storeTable)
        return 40.0f;

    else
        return 0.0f;}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.storeTable)
        return 200.0f;
    else
        return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.storeTable)
    {
        int cCount = 0;
        
        if(self.storeDigital.count > 0)
            cCount ++;
        
        if(self.storeLocal.count > 0)
            cCount ++;
        
        if(self.storeCharity.count > 0)
            cCount ++;
        
        return cCount;
    }
    else
    {
        NSArray *currentCart = [NSArray arrayWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"]];
        return currentCart.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.storeTable)
    {
        static NSString *CellIdentifier = @"StoreCellID";
    
        StoreCell *cell = (StoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StoreCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
    
        [cell.scroll setTag:(100 + (int)indexPath.row)];
        [cell.pageControl setTag:(1000 + (int)indexPath.row)];
        
        
        if((int)indexPath.row == 0)
        {
            if(self.storeDigital.count > 0)
            {
                [cell loadStoreItemsForCell:self.storeDigital index:(int)indexPath.row sv:self];
                [cell setTitleForCell:@"Digital Gifts"];
            }
            else if(self.storeLocal.count > 0)
            {
                [cell loadStoreItemsForCell:self.storeLocal index:(int)indexPath.row sv:self];
                [cell setTitleForCell:@"Local Gifts"];
            }
            else
            {
                [cell loadStoreItemsForCell:self.storeCharity index:(int)indexPath.row sv:self];
                [cell setTitleForCell:@"For a Cause"];
            }
        }
        else if((int)indexPath.row == 1)
        {
            if(self.storeLocal.count > 0)
            {
                [cell loadStoreItemsForCell:self.storeLocal index:(int)indexPath.row sv:self];
                [cell setTitleForCell:@"Local Gifts"];
            }
            else
            {
                [cell loadStoreItemsForCell:self.storeLocal index:(int)indexPath.row sv:self];
                [cell setTitleForCell:@"Local Gifts"];
            }
        }
        else
        {
            [cell loadStoreItemsForCell:self.storeCharity index:(int)indexPath.row sv:self];
            [cell setTitleForCell:@"For a Cause"];
        }
    
        cell.separator.frame = CGRectMake(cell.separator.frame.origin.x, cell.separator.frame.origin.y + 0.5f, cell.separator.frame.size.width, 0.5f);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"CartCellID";
        
        CartCell *cell = (CartCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CartCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        NSArray *currentCart = [NSArray arrayWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"]];
        cell.oneItem = [currentCart objectAtIndex:indexPath.row];
        [cell loadCartItemsForCell];
        
        cell.store = self;
        
        [self.countFields addObject:cell.countField];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/* scroll action */
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    if(sender != self.storeTable && sender != self.cartTable)
    {
        UIScrollView *oneScroll = (UIScrollView *)sender;
        
        StoreCell *cell;
        
        if(isIOS8())
            cell = (StoreCell *)[[oneScroll superview]superview];
        else
            cell = (StoreCell *)[[[oneScroll superview]superview]superview];
    
        if (!cell.pageControlBeingUsed) {
        
            CGFloat pageWidth = cell.scroll.frame.size.width;
            int page = floor((cell.scroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            cell.pageControl.currentPage = page;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if(scrollView != self.storeTable && scrollView != self.cartTable)
    {
        UIScrollView *oneScroll = (UIScrollView *)scrollView;
        
        StoreCell *cell;
        
        if(isIOS8())
            cell = (StoreCell *)[[oneScroll superview]superview];
        else
            cell = (StoreCell *)[[[oneScroll superview]superview]superview];
        
        cell.pageControlBeingUsed = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if(scrollView != self.storeTable && scrollView != self.cartTable)
    {
        UIScrollView *oneScroll = (UIScrollView *)scrollView;
        
        StoreCell *cell;
        
        if(isIOS8())
            cell = (StoreCell *)[[oneScroll superview]superview];
        else
            cell = (StoreCell *)[[[oneScroll superview]superview]superview];
        
        cell.pageControlBeingUsed = NO;
    }
}

- (void)addToCartDigitalAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    self.selectedCartItem =[self.storeDigital objectAtIndex:btn.tag];
    [self showCartAlert];
}

- (void)addToCartLocalAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    self.selectedCartItem = [self.storeLocal objectAtIndex:btn.tag];
    [self showCartAlert];
}

- (void)addToCartCauseAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    self.selectedCartItem = [self.storeCharity objectAtIndex:btn.tag];
    [self showCartAlert];
}

- (void)showCartAlert{

    for (int i = 0; i < self.countFields.count; i++) {
        UITextField *oneFld = [self.countFields objectAtIndex:i];
        [oneFld resignFirstResponder];
    }
    
    self.cartView.hidden = YES;
    
    //NSLog(@"--%@",self.selectedCartItem);

    NSArray *children = [self.selectedCartItem objectForKey:@"children"];
    
    //NSLog(@"---- %@",prices);
    
    if(children.count == 0)
    {
        CGFloat price = [[self.selectedCartItem objectForKey:@"price"]floatValue];
    
        if(price == 0)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add to Cart"
                                                             message:@"Please enter amount $"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Add", nil];
            
            [alert setDelegate:self];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = 10002;
            [alert show];
        }
        else
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                              message:@"Add to Cart?"
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                                    otherButtonTitles:@"Yes",nil];
            message.tag = 10001;
            [message show];
        }
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                          message:@"Add to Cart?"
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:nil];
        
        for (int i=0; i<children.count; i++)
        {
            NSDictionary *oneChildren = [children objectAtIndex:i];
            [message addButtonWithTitle:[NSString stringWithFormat:@"$%d",[[oneChildren objectForKey:@"price"]intValue]]];
        }
        
        message.tag = 10003;
        [message show];
    }
}

- (void)addItemToCart:(CGFloat)price itemID:(NSString *)storeItemID
{
    CGFloat userRedeemPrice = 0.0f;
    
    if(([self getCartTotal] + price) > self.cashReceivedBalance)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:[NSString stringWithFormat:@"You only have $%.2f available to redeem right now", self.cashReceivedBalance]
                                                        delegate:self cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    NSArray *children = [self.selectedCartItem objectForKey:@"children"];
    
    if(children.count == 0)
    {
        CGFloat priceOne = [[self.selectedCartItem objectForKey:@"price"]floatValue];
        if(priceOne == 0)
        {
            CGFloat maxPrice = [[self.selectedCartItem objectForKey:@"maxPrice"]floatValue];
            CGFloat minPrice = [[self.selectedCartItem objectForKey:@"minPrice"]floatValue];
            
            if(price < minPrice)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:[NSString stringWithFormat:@"Minimum price for this item - $%.2f", minPrice]
                                                                delegate:self cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                
                [alert show];
                return;
            }
            
            if(price > maxPrice && maxPrice > 0.0f)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:[NSString stringWithFormat:@"Maximum price for this item - $%.2f", maxPrice]
                                                                delegate:self cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                
                [alert show];
                return;
            }
            
            userRedeemPrice = price;
        }
    }
    
    NSArray *currentCart = [NSArray arrayWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"]];
    
    NSMutableArray *mutableCart = [NSMutableArray arrayWithArray:currentCart];
    
    BOOL alreadyHaveItem = NO;
    for (int i=0; i<mutableCart.count; i++)
    {
        NSDictionary *oneItem = [mutableCart objectAtIndex:i];
        
        if([[oneItem objectForKey:@"id"]isEqualToString:storeItemID] && [[oneItem objectForKey:@"price"]floatValue] == price)
        {
            NSArray *objects = [NSArray arrayWithObjects:[oneItem objectForKey:@"id"],
                                                         [oneItem objectForKey:@"price"],
                                                         [oneItem objectForKey:@"userRedeemPrice"],
                                                         [NSNumber numberWithInt:(int)([[oneItem objectForKey:@"currentQty"] intValue] + 1)],
                                                         [oneItem objectForKey:@"name"],
                                                         [oneItem objectForKey:@"image"], nil];
            
            NSArray *keys = [NSArray arrayWithObjects:@"id", @"price", @"userRedeemPrice", @"currentQty", @"name", @"image", nil];
            
            [mutableCart replaceObjectAtIndex:i withObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
            
            alreadyHaveItem = YES;
        }
    }
    
    if(alreadyHaveItem == NO)
    {
        NSArray *objects = [NSArray arrayWithObjects: storeItemID,
                                                      [NSNumber numberWithFloat:price],
                                                      [NSNumber numberWithFloat:userRedeemPrice],
                                                      [NSNumber numberWithInt:1],
                                                      [self.selectedCartItem objectForKey:@"name"],
                                                      [self.selectedCartItem objectForKey:@"absURL"], nil];
        
        NSArray *keys = [NSArray arrayWithObjects:@"id", @"price", @"userRedeemPrice", @"currentQty", @"name", @"image", nil];
        [mutableCart addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
    }
    
    [[NSArray arrayWithArray:mutableCart] writeToFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"] atomically:YES];
    
    [self reloadCartInformation];
}

- (IBAction)viewCartAction:(id)sender {
    
    if([self.cartView isHidden])
    {
        [self reloadCartInformation];
         self.cartView.hidden = NO;
    }
    else
    {
        for (int i = 0; i < self.countFields.count; i++) {
            UITextField *oneFld = [self.countFields objectAtIndex:i];
            [oneFld resignFirstResponder];
        }
        
        self.cartView.hidden = YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    @try {
        switch ([alertView tag])
        {
            case 10001:
                if (buttonIndex == 1)
                {
                    [self addItemToCart:[[self.selectedCartItem objectForKey:@"price"]floatValue] itemID:[self.selectedCartItem objectForKey:@"id"]];
                }
                break;
            case 10002:
            {
                if (buttonIndex == 1)
                {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    int price = [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]intValue];
                
                    //NSLog(@"price ----- %d",price);
                    
                    if(price < 1)
                    {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:@"Please enter positive number consisting of one or more digits"
                                                                    delegate:self cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                    
                        [alert show];
                    }
                    else
                        [self addItemToCart:[[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]floatValue] itemID:[self.selectedCartItem objectForKey:@"id"]];
                }
                break;
            }
            case 10003:
            {

                NSArray *children = [self.selectedCartItem objectForKey:@"children"];
                
                if((buttonIndex - 1) < children.count)
                {
                    NSDictionary *oneChildren = [children objectAtIndex:(buttonIndex - 1)];
                
                    int price = [[oneChildren objectForKey:@"price"]intValue];
               
                
                    if(price < 1)
                    {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:@"Please enter positive number consisting of one or more digits"
                                                                    delegate:self cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                    
                        [alert show];
                    }
                    else
                        [self addItemToCart:[[oneChildren objectForKey:@"price"]floatValue] itemID:[oneChildren objectForKey:@"id"]];
                }
                break;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception occurred in alertView: %@, %@", exception, [exception userInfo]);
    }
}

- (IBAction)clearCartAction:(id)sender {
    
    NSArray *emptyArray = [NSArray arrayWithObjects:nil];
    [emptyArray writeToFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"] atomically:YES];
    
    [self reloadCartInformation];
    
    for (int i = 0; i < self.countFields.count; i++) {
        UITextField *oneFld = [self.countFields objectAtIndex:i];
        [oneFld resignFirstResponder];
    }
    
    self.cartView.hidden = YES;
}

- (void)reloadCartInformation{

    NSArray *currentCart = [NSArray arrayWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"]];
    
    if(currentCart != nil)
        [self.cartBtn setTitle:[NSString stringWithFormat:@"%d items", (int)currentCart.count] forState:UIControlStateNormal];
    else
        [self.cartBtn setTitle:[NSString stringWithFormat:@"%d items", 0] forState:UIControlStateNormal];
    
    self.cartTotal.text = [NSString stringWithFormat:@"$%.1f",[self getCartTotal]];
    self.countFields = [NSMutableArray arrayWithCapacity:0];
    [self.cartTable reloadData];
    
    if(currentCart.count > 0)
    {
        self.cartTable.hidden = NO;
        self.noItemsLabel.hidden = YES;
    }
    else
    {
        self.cartTable.hidden = YES;
        self.noItemsLabel.hidden = NO;
    }
}

- (CGFloat)getCartTotal{

    NSArray *currentCart = [NSArray arrayWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"]];
    CGFloat cartTotal = 0.0f;
    
    for (int i = 0; i < currentCart.count; i++)
    {
        NSDictionary *oneItem = [currentCart objectAtIndex:i];
        CGFloat oneItemTotal = (float)[[oneItem objectForKey:@"price"] floatValue] * (int)[[oneItem objectForKey:@"currentQty"] intValue];
        
        cartTotal = cartTotal + oneItemTotal;
    }
    
    return cartTotal;
}

- (void)removeCartItemByID:(NSString *)itemID{

    NSArray *currentCart = [NSArray arrayWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"]];
    
    NSMutableArray *mutableCart = [NSMutableArray arrayWithArray:currentCart];
    
    for (int i=0; i<mutableCart.count; i++)
    {
        NSDictionary *oneItem = [mutableCart objectAtIndex:i];
        
        if([[oneItem objectForKey:@"id"]isEqualToString:itemID])
           [mutableCart removeObjectAtIndex:i];
    }
    
    [[NSArray arrayWithArray:mutableCart] writeToFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"] atomically:YES];
    [self reloadCartInformation];
}

- (void)updateCountForItem:(NSString *)itemID count:(int)count{

    NSArray *currentCart = [NSArray arrayWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"]];
    
    NSMutableArray *mutableCart = [NSMutableArray arrayWithArray:currentCart];
    
    for (int i=0; i<mutableCart.count; i++)
    {
        NSDictionary *oneItem = [mutableCart objectAtIndex:i];
        
        if([[oneItem objectForKey:@"id"]isEqualToString:itemID])
        {
            NSArray *objects = [NSArray arrayWithObjects:[oneItem objectForKey:@"id"],
                                [oneItem objectForKey:@"price"],
                                [NSNumber numberWithInt:count],
                                [oneItem objectForKey:@"name"],
                                [oneItem objectForKey:@"image"], nil];
            
            NSArray *keys = [NSArray arrayWithObjects:@"id", @"price", @"currentQty", @"name", @"image", nil];
            
            
            if(([self getCartTotal] + ((float)[[oneItem objectForKey:@"price"]floatValue] * count) - ((float)[[oneItem objectForKey:@"price"]floatValue] * [[oneItem objectForKey:@"currentQty"]intValue])) > self.cashReceivedBalance)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:[NSString stringWithFormat:@"You only have $%.2f available to redeem right now", self.cashReceivedBalance]
                                                                delegate:self cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                
                [alert show];
            }
            else
            {
                [mutableCart replaceObjectAtIndex:i withObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
            }
        }
    }
    
    [[NSArray arrayWithArray:mutableCart] writeToFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"] atomically:YES];
    [self reloadCartInformation];
}

- (IBAction)placeOrderAction:(id)sender {
    
    for (int i = 0; i < self.countFields.count; i++) {
        UITextField *oneFld = [self.countFields objectAtIndex:i];
        [oneFld resignFirstResponder];
    }
    
    p = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    [p setDimBackground:YES];
    [p setLabelText:@"Loading"];
    [p setMode:MBProgressHUDModeIndeterminate];
    [p show:YES];
    [p setRemoveFromSuperViewOnHide:YES];
    [self.view.window addSubview:p];
    
    NSArray *currentCart = [NSArray arrayWithContentsOfFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"]];
    
    [[mrAPI sharedInstance] purchaseItems:currentCart];
}

- (void)afterPurchaseResponse:(NSDictionary *)resp{

    //NSLog(@"--- %@",resp);
    
    [p hide:YES];
    
    if([[resp objectForKey:@"success"]isEqualToString:@"true"])
    {
        NSArray *emptyArray = [NSArray arrayWithObjects:nil];
        [emptyArray writeToFile:[DOCS stringByAppendingPathComponent:@"currentCart.plist"] atomically:YES];
        
        [self reloadCashInfo];
        [self reloadCartInformation];
        
        self.cartView.hidden = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success"
                                                        message:[resp objectForKey:@"message"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[resp objectForKey:@"message"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    
    }
}

- (void)afterPurchaseResponseError{
    
    [p hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Server side error"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
