//
//  mrAPI.h
//  OnToday
//
//  Created by mr on 17.05.13.
//  Copyright (c) 2013 smr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@interface mrAPI : NSObject <ASIHTTPRequestDelegate>

@property (strong) NSMutableArray *pendingRequests;

+ (mrAPI *)sharedInstance;

- (NSString *)createAPIURL:(NSString *)apiURL;
- (id) processParse:(NSString *)response;

- (NSDictionary*)loginUser:(NSDictionary*)userRow;
- (NSDictionary*)passReset:(NSString*)email;

- (NSArray*)getFeedItems:(NSString *)feedScopeLabel page:(int)cPage;
- (NSDictionary*)postComment:(NSString*)comment feedId:(NSString *)feedId;
- (NSDictionary *)postLike:(NSString*)feedId;
- (NSArray*)getLeaderboardList;
- (NSArray*)getAnnouncementList;
- (NSDictionary*)saveAnnouncement:(NSString*)title note:(NSString *)note;
- (NSDictionary *)saveAppreciation:(NSDictionary *)appreciationRow;
- (NSArray*)getCompanyList;
- (NSArray*)searchUsersList:(NSString *)searchKey;
- (NSDictionary*)getUser;
- (NSDictionary*)getUserCash;
- (NSArray*)getStoreItems:(NSString *)type;
- (void)purchaseItems:(NSArray*)items;
- (NSDictionary*)getOneFeedItem:(NSString *)itemID;

@end
