//
//  StoreCell.m
//  Motivosity
//
//  Created by mr on 25.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "StoreCell.h"

#import "UIImageView+WebCache.h"

@implementation StoreCell

@synthesize pageControlBeingUsed;

- (void)awakeFromNib {
    // Initialization code
    pageControlBeingUsed = NO;

    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

- (IBAction)changePage:(id)sender {
    
    CGRect frame;
    frame.origin.x = self.scroll.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scroll.frame.size;
    [self.scroll scrollRectToVisible:frame animated:YES];
    
    [self setPageControlBeingUsed:YES];
}

- (void)setTitleForCell:(NSString *)mrTitle{
    self.cellTitle.text = mrTitle;
}

- (void)loadStoreItemsForCell:(NSArray *)storeArray index:(int)mrIndex sv:(StoreVC *)store{
    
    self.scroll.contentSize = CGSizeMake(0.0f, 0.0f);
    
    for (UIView *v in self.scroll.subviews){
        [v removeFromSuperview];
    }

    //NSLog(@"--- %@",storeArray);
    
    int pages = (int)storeArray.count / 2 + (storeArray.count%2);
    
    self.scroll.contentSize = CGSizeMake(pages * [[UIScreen mainScreen] bounds].size.width, self.scroll.frame.size.height);
    [self.scroll setScrollEnabled:YES];
    
    self.pageControl.numberOfPages = pages;
    self.pageControl.currentPage = 0;
    
    for (int i = 0; i < pages; i++)
    {
        CGRect frame;
        
        frame.origin.x = self.scroll.frame.size.width * i;
        frame.origin.y = 0;
        frame.size.width = self.scroll.frame.size.width;
        frame.size.height = self.scroll.frame.size.height;
        
        // first item
        
        if((storeArray.count - 1) >= (i*2))
        {
            NSDictionary *firstItem = [storeArray objectAtIndex:(i*2)];
            
            UIView *oneItemBoxFirst = [[UIView alloc]initWithFrame:CGRectMake(frame.origin.x +  5.0f, frame.origin.y +  5.0f, (self.frame.size.width/2) - 10.0f, 100.0f)];
            //NSLog(@"---- %@",NSStringFromCGRect(oneItemBoxFirst.frame));
            oneItemBoxFirst.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        
            oneItemBoxFirst.layer.borderColor = [UIColor colorWithRed:189/255.0f green:189/255.0f blue:189/255.0f alpha:1.0f].CGColor;
            oneItemBoxFirst.layer.borderWidth = 1.0f;
            oneItemBoxFirst.layer.cornerRadius = 6;
            oneItemBoxFirst.layer.masksToBounds = YES;
        
            UIImageView *itemImageFirst = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, oneItemBoxFirst.frame.size.width, oneItemBoxFirst.frame.size.height)];
            itemImageFirst.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [itemImageFirst sd_setImageWithURL:[NSURL URLWithString:[firstItem objectForKey:@"absURL"]] placeholderImage:nil];
            itemImageFirst.contentMode = UIViewContentModeScaleAspectFit;
            [oneItemBoxFirst addSubview:itemImageFirst];
        
            [self.scroll addSubview:oneItemBoxFirst];
        
            UILabel *oneNameFirst = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x +  5.0f, frame.origin.y +  5.0f + 100.0f, (self.frame.size.width/2) - 10.0f, 28.0f)];
            oneNameFirst.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [oneNameFirst setText:[NSString stringWithFormat:@"%@",[firstItem objectForKey:@"name"]]];
            [oneNameFirst setTextAlignment:NSTextAlignmentCenter];
            [oneNameFirst setTextColor:[UIColor colorWithRed:0/255.0f green:64/255.0f blue:125/255.0f alpha:1.0f]];
            [oneNameFirst setFont:[UIFont fontWithName:@"Lato-Bold" size:11.0f]];
        
            [self.scroll addSubview:oneNameFirst];
            
            NSArray *children = [firstItem objectForKey:@"children"];
            if(children.count == 0)
            {
                CGFloat priceFirst  = [[firstItem objectForKey:@"price"]floatValue];
                if(priceFirst  > 0)
                {
                    UILabel *onePriceFirst = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x +  10.0f, frame.origin.y +  5.0f + 100.0f - 28.0f, (self.frame.size.width/2) - 20.0f, 28.0f)];
                    onePriceFirst.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
                    [onePriceFirst setText:[NSString stringWithFormat:@"$%.1f",priceFirst]];
                    [onePriceFirst setTextAlignment:NSTextAlignmentCenter];
                    [onePriceFirst setTextColor:[UIColor colorWithRed:87/255.0f green:191/255.0f blue:227/255.0f alpha:1.0f]];
                    [onePriceFirst setFont:[UIFont fontWithName:@"Lato-Bold" size:13.0f]];
                    onePriceFirst.textAlignment = NSTextAlignmentRight;
                    
                    [self.scroll addSubview:onePriceFirst];
                }
            }
            
            UIButton *actionButtonFirst = [UIButton buttonWithType:UIButtonTypeCustom];
            actionButtonFirst.frame = CGRectMake(frame.origin.x +  5.0f, frame.origin.y +  5.0f, (self.frame.size.width/2) - 10.0f, 133.0f);
            actionButtonFirst.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [actionButtonFirst setTag:(i*2)];
            
            [actionButtonFirst setEnabled:YES];
            [actionButtonFirst setUserInteractionEnabled:YES];
            
            if(mrIndex == 0)
                [actionButtonFirst addTarget:store action: @selector(addToCartDigitalAction:) forControlEvents: UIControlEventTouchDown];
            else if(mrIndex == 1)
                [actionButtonFirst addTarget:store action: @selector(addToCartLocalAction:) forControlEvents: UIControlEventTouchDown];
            else
                [actionButtonFirst addTarget:store action: @selector(addToCartCauseAction:) forControlEvents: UIControlEventTouchDown];
            
            [self.scroll addSubview:actionButtonFirst];
        }
        
        // second item
        if((storeArray.count - 1) >= ((i*2) + 1))
        {
            NSDictionary *secondItem = [storeArray objectAtIndex:((i*2) + 1)];
        
            UIView *oneItemBoxSecond = [[UIView alloc]initWithFrame:CGRectMake(frame.origin.x + 5.0f + (self.frame.size.width/2), frame.origin.y +  5.0f, (self.frame.size.width/2) - 10.0f, 100.0f)];
        
            oneItemBoxSecond.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        
            oneItemBoxSecond.layer.borderColor = [UIColor colorWithRed:189/255.0f green:189/255.0f blue:189/255.0f alpha:1.0f].CGColor;
            oneItemBoxSecond.layer.borderWidth = 1.0f;
            oneItemBoxSecond.layer.cornerRadius = 6;
            oneItemBoxSecond.layer.masksToBounds = YES;
        
            UIImageView *itemImageSecond = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, oneItemBoxSecond.frame.size.width, oneItemBoxSecond.frame.size.height)];
            itemImageSecond.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [itemImageSecond sd_setImageWithURL:[NSURL URLWithString:[secondItem objectForKey:@"absURL"]] placeholderImage:nil];
            itemImageSecond.contentMode = UIViewContentModeScaleAspectFit;
            [oneItemBoxSecond addSubview:itemImageSecond];
        
            [self.scroll addSubview:oneItemBoxSecond];
        
            UILabel *oneNameSecond = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x +  5.0f + (self.frame.size.width/2), frame.origin.y +  5.0f + 100.0f, (self.frame.size.width/2) - 10.0f, 28.0f)];
            oneNameSecond.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [oneNameSecond setText:[NSString stringWithFormat:@"%@",[secondItem objectForKey:@"name"]]];
            [oneNameSecond setTextAlignment:NSTextAlignmentCenter];
            [oneNameSecond setTextColor:[UIColor colorWithRed:0/255.0f green:64/255.0f blue:125/255.0f alpha:1.0f]];
            [oneNameSecond setFont:[UIFont fontWithName:@"Lato-Bold" size:11.0f]];
        
            [self.scroll addSubview:oneNameSecond];
            
            NSArray *children = [secondItem objectForKey:@"children"];
            if(children.count == 0)
            {
                CGFloat priceSecond  = [[secondItem objectForKey:@"price"]floatValue];
                if(priceSecond  > 0)
                {
                    UILabel *onePriceFirst = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x +  10.0f + (self.frame.size.width/2), frame.origin.y +  5.0f + 100.0f - 28.0f, (self.frame.size.width/2) - 20.0f, 28.0f)];
                    onePriceFirst.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
                    [onePriceFirst setText:[NSString stringWithFormat:@"$%.1f",priceSecond]];
                    [onePriceFirst setTextAlignment:NSTextAlignmentCenter];
                    [onePriceFirst setTextColor:[UIColor colorWithRed:87/255.0f green:191/255.0f blue:227/255.0f alpha:1.0f]];
                    [onePriceFirst setFont:[UIFont fontWithName:@"Lato-Bold" size:13.0f]];
                    onePriceFirst.textAlignment = NSTextAlignmentRight;
                    
                    [self.scroll addSubview:onePriceFirst];
                }
            }
            
            UIButton *actionButtonSecond = [UIButton buttonWithType:UIButtonTypeCustom];
            actionButtonSecond.frame = CGRectMake(frame.origin.x +  5.0f + (self.frame.size.width/2), frame.origin.y +  5.0f, (self.frame.size.width/2) - 10.0f, 133.0f);
            actionButtonSecond.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            [actionButtonSecond setTag:((i*2) + 1)];
            
            [actionButtonSecond setEnabled:YES];
            [actionButtonSecond setUserInteractionEnabled:YES];
            
            if(mrIndex == 0)
                [actionButtonSecond addTarget:store action: @selector(addToCartDigitalAction:) forControlEvents: UIControlEventTouchDown];
            else if(mrIndex == 1)
                [actionButtonSecond addTarget:store action: @selector(addToCartLocalAction:) forControlEvents: UIControlEventTouchDown];
            else
                [actionButtonSecond addTarget:store action: @selector(addToCartCauseAction:) forControlEvents: UIControlEventTouchDown];
            
            [self.scroll addSubview:actionButtonSecond];
        }
    }
}


@end
