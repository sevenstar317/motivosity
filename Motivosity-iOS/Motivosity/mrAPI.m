//
//  mrAPI.m
//  OnToday
//
//  Created by mr on 17.05.13.
//  Copyright (c) 2013 smr. All rights reserved.
//


#import "mrAPI.h"

enum mrTags
{
    mrTagPurchase = 100, // use
    mrTagLocationAsync = 101,
    mrTagUpdateUserAsync = 102,
    mrTagDealViewAsync = 103,
    mrTagDealLikeAsync = 104,
    mrTagCouponUseAsync = 105
};

@implementation mrAPI

@synthesize pendingRequests;

+ (mrAPI *)sharedInstance
{
    static mrAPI * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[mrAPI alloc] init];
    });
    
    return _sharedInstance;
}


- (NSString *)createAPIURL:(NSString *)apiURL{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *expires = (NSDate *)[userDefaults objectForKey:@"expires"];
    NSDate *userExpires = (NSDate *)[userDefaults objectForKey:@"user.expires"];
    NSDate *now = [NSDate date];
    
    NSLog(@" now time: %@  -  session expires time: %@", now, expires);
    
    if([expires compare:now] == NSOrderedDescending)
    {
        return [NSString stringWithFormat:@"%@%@?access_token=%@",[Motivosity getBaseURL],apiURL,[userDefaults objectForKey:@"token"]];
    }
    else
    {
        if([userExpires compare:now] == NSOrderedDescending)
        {
            NSLog(@"-- !!! autologin !!! --");
            
            NSString *email =  [userDefaults objectForKey:@"user.login"];
            NSString *password =  [userDefaults objectForKey:@"user.pass"];
                
            NSArray *objects = [NSArray arrayWithObjects:email, password, nil];
            NSArray *keys = [NSArray arrayWithObjects:@"username", @"password", nil];
            
            NSDictionary *loginResponse = [[mrAPI sharedInstance] loginUser:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
            
            if([[loginResponse objectForKey:@"success"]isEqualToString:@"true"])
            {
                [userDefaults setObject:[loginResponse objectForKey:@"token"] forKey:@"token"];
                [userDefaults setObject:email forKey:@"user.login"];
                [userDefaults setObject:password forKey:@"user.pass"];
                    
                //[userDefaults setObject:[APPDELEGATE.dateFormatterServer dateFromString:[loginResponse objectForKey:@"expires"]] forKey:@"expires"];
                
                int expiresInt = [[loginResponse objectForKey:@"expires"]intValue];
                [userDefaults setObject:[[NSDate date]dateByAddingTimeInterval:(expiresInt * 60)] forKey:@"expires"];
                
                NSDate *expDate14 = [[NSDate date] dateByAddingTimeInterval:60*60*24*14];
                [userDefaults setObject:expDate14 forKey:@"user.expires"];
                    
                [userDefaults synchronize];
                    
                return [NSString stringWithFormat:@"%@%@?access_token=%@",[Motivosity getBaseURL],apiURL,[userDefaults objectForKey:@"token"]];
            }
            else
                return [NSString stringWithFormat:@"%@%@?access_token=%@",[Motivosity getBaseURL],apiURL,[userDefaults objectForKey:@"token"]];
         }
         else
             return [NSString stringWithFormat:@"%@%@?access_token=%@",[Motivosity getBaseURL],apiURL,[userDefaults objectForKey:@"token"]];
     }
}

#pragma mark ------------------------------------------------------------------------------- Login request

- (ASIFormDataRequest*) createLoginUserRequest:(NSDictionary*)userRow
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[Motivosity getBaseURL],@"api/v1/auth/token"]];
    //NSLog(@"--- %@",[NSString stringWithFormat:@"%@%@",siteURL,@"api/v1/auth/token"]);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    
    [request setValidatesSecureCertificate:YES];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    NSArray *objects = [NSArray arrayWithObjects:[userRow objectForKey:@"username"],
                       [userRow objectForKey:@"password"], nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"username", @"password", nil];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"--- %@",jsonString);
    
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];

    return request;
}

- (NSDictionary*)loginUser:(NSDictionary*)userRow
{    
    ASIFormDataRequest *request = [self createLoginUserRequest:userRow];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    
    //NSLog(@"----- resp %@",response);
    
    NSDictionary* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Password reset request

- (ASIFormDataRequest*) createPassResetRequest:(NSString*)email
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[Motivosity getBaseURL],@"api/v1/auth/password"]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    
    [request setValidatesSecureCertificate:YES];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    NSArray *objects = [NSArray arrayWithObjects:email, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"username", nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"--- %@",jsonString);
    
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (NSDictionary*)passReset:(NSString*)email
{
    ASIFormDataRequest *request = [self createPassResetRequest:email];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    
    //NSLog(@"----- resp %@",response);
    
    NSDictionary* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Get feed items request

- (ASIHTTPRequest*)createViewAvailableMeetupsRequest:(NSString *)feedScopeLabel page:(int)cPage
{
    NSString *feedScope = @"";
    
    if([feedScopeLabel isEqualToString:@"Company"])
        feedScope = @"CMPY";
    else if([feedScopeLabel isEqualToString:@"Department"])
        feedScope = @"DEPT";
    else if([feedScopeLabel isEqualToString:@"Extended Team"])
        feedScope = @"EXTM";
    else if([feedScopeLabel isEqualToString:@"Team"])
        feedScope = @"TEAM";
    else
        feedScope = @"EXTM";
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@&like=true&comment=true&scope=%@&page=%d",[self createAPIURL:[NSString stringWithFormat:@"api/v1/feed"]],  feedScope, [[NSNumber numberWithInt:cPage]intValue]]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"GET"];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];

    return request;
}

- (NSArray*)getFeedItems:(NSString *)feedScopeLabel page:(int)cPage
{
    ASIHTTPRequest *request = [self createViewAvailableMeetupsRequest:feedScopeLabel page:cPage];
    [request startSynchronous];
    
    NSString *response = [request responseString];

    //NSLog(@"--- %@",response);
    NSArray* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Get one feed item request

- (ASIHTTPRequest*)createOneFeedItemRequest:(NSString *)itemID
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL: [NSString stringWithFormat:@"api/v1/feed/%@",itemID]]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"GET"];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    return request;
}

- (NSDictionary*)getOneFeedItem:(NSString *)itemID
{
    ASIHTTPRequest *request = [self createOneFeedItemRequest:itemID];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    
    //NSLog(@"--- %@",response);
    NSDictionary* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Post comment request

- (ASIFormDataRequest *)createPostCommentRequest:(NSString *)comment feedId:(NSString *)feedId
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:[NSString stringWithFormat:@"api/v1/feed/%@/comment",feedId]]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"PUT"];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    NSArray *objects = [NSArray arrayWithObjects:comment, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"commentText", nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (NSDictionary*)postComment:(NSString*)comment feedId:(NSString *)feedId
{
    [ASIHTTPRequest setSessionCookies:nil];
    
    ASIFormDataRequest *request = [self createPostCommentRequest:comment feedId:feedId];
    [request startSynchronous];
    NSString *response = [request responseString];
    
    //NSLog(@"-- %@",response);
    NSDictionary* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Like request

- (ASIHTTPRequest *)createLiketRequest:(NSString*)feedId
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:[NSString stringWithFormat:@"api/v1/feed/%@/like",feedId]]];
    
    //NSLog(@"---- %@",[self createAPIURL:[NSString stringWithFormat:@"api/v1/feed/%@/like",feedId]]);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"PUT"];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    return request;
}

- (NSDictionary *)postLike:(NSString*)feedId
{
    [ASIHTTPRequest setSessionCookies:nil];
    
    ASIHTTPRequest *request = [self createLiketRequest:feedId];
    [request startSynchronous];
    NSString *response = [request responseString];
    
    //NSLog(@"-- %@",response);
    NSDictionary* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Get Company List request

- (ASIHTTPRequest*)createCompanyListRequest
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:@"api/v1/companyvalue"]];
    
    //NSLog(@"---- %@",[self createAPIURL:@"api/v1/companyvalue/list"]);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"GET"];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    return request;
}

- (NSArray*)getCompanyList
{
    ASIHTTPRequest *request = [self createCompanyListRequest];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    // NSLog(@"--- %@",response);
    NSArray* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Get Users List request

- (ASIHTTPRequest*)createSearchUsersListRequest:(NSString *)searchKey
{
    NSString* urlText = [NSString  stringWithFormat:@"%@&name=%@&ignoreSelf=true",[self createAPIURL:@"api/v1/usertypeahead"], searchKey];
    urlText = [urlText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString: urlText];
    
    //NSLog(@"--- %@", [NSString  stringWithFormat:@"%@&name=%@&ignoreSelf=true",[self createAPIURL:@"api/v1/usertypeahead"], searchKey]);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    
    [request setRequestMethod:@"GET"];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    return request;
}

- (NSArray*)searchUsersList:(NSString *)searchKey
{
    ASIHTTPRequest *request = [self createSearchUsersListRequest:searchKey];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    NSLog(@"--- %@",response);
    NSArray* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Save Appreciation request

- (ASIFormDataRequest *)createSaveAppreciationRequest:(NSDictionary *)appreciationRow
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:[NSString stringWithFormat:@"api/v1/user/%@/appreciation",[appreciationRow objectForKey:@"toUserID"]]]];
    
    //NSLog(@"---- %@", [self createAPIURL:[NSString stringWithFormat:@"api/v1/user/%@/appreciation",[appreciationRow objectForKey:@"toUserID"]]]);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"PUT"];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    NSArray *objects = [NSArray arrayWithObjects: [appreciationRow objectForKey:@"note"],
                                                  [appreciationRow objectForKey:@"companyValueID"],
                                                  [appreciationRow objectForKey:@"amount"], nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"note", @"companyValueID", @"amount", nil];
    
    NSDictionary *appreciationRowToRequest = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:appreciationRowToRequest options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"--- %@",jsonString);
    
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (NSDictionary *)saveAppreciation:(NSDictionary *)appreciationRow
{
    [ASIHTTPRequest setSessionCookies:nil];
    
    ASIFormDataRequest *request = [self createSaveAppreciationRequest:appreciationRow];
    [request startSynchronous];
    NSString *response = [request responseString];
    
    // NSLog(@"-- %@",response);
    NSDictionary* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Get Current User request

- (ASIHTTPRequest*)createGetUserRequest
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:@"api/v1/user"]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    return request;
}

- (NSDictionary*)getUser
{
    ASIHTTPRequest *request = [self createGetUserRequest];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    // NSLog(@"--- %@",response);
    NSDictionary* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Get Current User Cash Giving

- (ASIHTTPRequest*)createGetUserCash
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:@"api/v1/usercash"]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"GET"];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    return request;
}

- (NSDictionary*)getUserCash
{
    ASIHTTPRequest *request = [self createGetUserCash];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    //NSLog(@"--- %@",response);
    NSDictionary* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Get store items request

- (ASIHTTPRequest*)createStoreItemsRequest:(NSString *)type
{
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@&type=%@",[self createAPIURL:[NSString stringWithFormat:@"api/v1/store"]], type]];
    
    //NSLog(@"--- %@", [NSString stringWithFormat:@"%@&type=%@",[self createAPIURL:[NSString stringWithFormat:@"api/v1/store"]], type]);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"GET"];
    
    return request;
}

- (NSArray*)getStoreItems:(NSString *)type
{
    ASIHTTPRequest *request = [self createStoreItemsRequest:type];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    
    //NSLog(@"---- %@",response);
    
    id storeDist = [self processParse:response];
    if ([storeDist isKindOfClass:[NSDictionary class]])
        return [NSArray array];
    
    NSArray* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Purchase Store request

- (ASIFormDataRequest *)createPurchaseItemsRequest:(NSArray*)items
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:@"api/v1/store/purchase"]];
    
    //NSLog(@"--- %@",[self createAPIURL:@"api/v1/store/purchase"]);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"POST"];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
   
    NSMutableArray *arrayForRequest = [NSMutableArray arrayWithCapacity:items.count];
    
    for (int i=0; i<items.count; i++)
    {
        NSDictionary *oneItem = [items objectAtIndex:i];
        
        NSArray *objects = [NSArray arrayWithObjects:[oneItem objectForKey:@"id"], [oneItem objectForKey:@"currentQty"], [oneItem objectForKey:@"userRedeemPrice"], nil];
        NSArray *keys = [NSArray arrayWithObjects:@"id", @"currentQty", @"userRedeemPrice", nil];
        
        [arrayForRequest addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayForRequest options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"-- %@",jsonString);
    
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setTag:mrTagPurchase];
    [request setTimeOutSeconds:20];
    
    //[request setPersistentConnectionTimeoutSeconds:30];
    
    return request;
}

- (void)purchaseItems:(NSArray*)items
{
    [ASIHTTPRequest setSessionCookies:nil];
    
    ASIFormDataRequest *request = [self createPurchaseItemsRequest:items];
    
    [request setDelegate:self];
    [self.pendingRequests addObject:request];
    [request startAsynchronous];
}

#pragma mark ------------------------------------------------------------------------------- Get List Leaderboard request

- (ASIHTTPRequest*)createLeaderboardListRequest
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:@"api/v1/leaderboard/list?pageNo=0"]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    return request;
}

- (NSArray*)getLeaderboardList
{
    ASIHTTPRequest *request = [self createLeaderboardListRequest];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    // NSLog(@"--- %@",response);
    NSArray* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Get List Announcement request

- (ASIHTTPRequest*)createAnnouncementListRequest
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:@"api/v1/announcement/list?pageNo=0"]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    return request;
}

- (NSArray*)getAnnouncementList
{
    ASIHTTPRequest *request = [self createAnnouncementListRequest];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    // NSLog(@"--- %@",response);
    NSArray* result = [self processParse:response];
    return result;
}

#pragma mark ------------------------------------------------------------------------------- Save Announcement request

- (ASIFormDataRequest *)createSaveAnnouncementRequest:(NSString*)title note:(NSString *)note
{
    NSURL *url = [NSURL URLWithString:[self createAPIURL:@"api/v1/announcement/save"]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"charset=UTF-8;"];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    
    [request setShouldAttemptPersistentConnection:NO];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    [request setPostValue:title forKey:@"title"];
    [request setPostValue:note forKey:@"note"];
    
    return request;
}

- (NSDictionary*)saveAnnouncement:(NSString*)title note:(NSString *)note
{
    [ASIHTTPRequest setSessionCookies:nil];
    
    ASIFormDataRequest *request = [self createSaveAnnouncementRequest:title note:note];
    [request startSynchronous];
    NSString *response = [request responseString];
    
    //NSLog(@"-- %@",response);
    NSDictionary* result = [self processParse:response];
    return result;
}



#pragma mark - Async request handlers

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag == mrTagPurchase) {
        
        NSString *response = [request responseString];
        NSDictionary* result = [self processParse:response];
        [APPDELEGATE.store afterPurchaseResponse:result];
        
        //NSLog(@"-- %@",response);
        //
    }
    
    [request clearDelegatesAndCancel];
    [self.pendingRequests removeObject:request];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    NSLog(@"error: %@", error);
    
    switch (request.tag) {
        case mrTagPurchase:
        {
            NSLog(@"mrTagPurchase error: %@", error);
            [APPDELEGATE.store afterPurchaseResponseError];
        }
            break;
            
        default:
            break;
    }
    
    [request clearDelegatesAndCancel]; // !!!
    [self.pendingRequests removeObject:request];
}

#pragma mark - Clean Up

- (void) cancelAllPendingRequests
{
    if ([pendingRequests count]) {
        for (ASIHTTPRequest* request in pendingRequests) {
            [request clearDelegatesAndCancel];
        }
    }
}

- (void) dealloc
{
    if ([pendingRequests count]) {
        for (ASIHTTPRequest* request in pendingRequests) {
            [request clearDelegatesAndCancel];
        }
    }
    pendingRequests = nil;
}

- (id) processParse:(NSString *)response
{
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return jsonObj;
}

@end
