//
//  FBUser.m
//  NGPlatform
//
//  Created by Ashley Martens on 11/17/09.
//  Copyright 2009 ngmoco:). All rights reserved.
//

#import "FBConnect/FBUser.h"
#import "FBConnect/FBSession.h"

static NSString *userFQL = @"SELECT uid, first_name, last_name, name, pic_small, is_app_user, username, proxied_email, pic_small_with_logo FROM user WHERE uid";
static NSString *userDetailsRequest = @"userDetails";
static NSString *userFriendsRequest = @"userFriends";

@interface FBUser()
-(id)parseReturn:(id)value;
-(void)initValues:(NSDictionary *)data;
-(void)addDelegate:(id<FBRequestDelegate>)delegate forRequest:(FBRequest*)request;
-(id<FBRequestDelegate>) delegateForRequest:(FBRequest*)request;
@end


@implementation FBUser

@synthesize uid;
@synthesize isAppUser;
@synthesize firstName;
@synthesize lastName;
@synthesize name;
@synthesize username;
@synthesize picSmall;
@synthesize email;
@synthesize picSmallWithLogo;
@synthesize friends;

- (FBUser *)initWithUID:(FBUID)userid session:(FBSession *)session andDelegate:(id<FBRequestDelegate>)delegate {
    if (self = [super init]) {
        delegates = [[NSMutableDictionary alloc] init];
        uid = [[NSNumber numberWithLongLong:userid] retain];
        NSString* fql = [NSString stringWithFormat:@"%@ = %i", userFQL, userid];
        NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
        FBRequest *request = [FBRequest requestWithSession:session delegate:self];
        request.userInfo = userDetailsRequest;
        [request call:@"facebook.fql.query" params:params];
        [self addDelegate:delegate forRequest:request];
    }
    return self;
}

+ (FBUser *)userForSession:(FBSession *)session andDelegate:(id<FBRequestDelegate>)delegate {
    return [[[FBUser alloc] initWithUID:session.uid session:session andDelegate:delegate] autorelease];
}

- (FBUser *)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        delegates = [[NSMutableDictionary alloc] init];
        uid = [[data objectForKey:@"uid"] retain];
        [self initValues:data];
    }
    return self;
}

- (void)initValues:(NSDictionary *)data {
    isAppUser = [(NSNumber *)[data objectForKey:@"is_app_user"] boolValue];
    firstName = [[self parseReturn:[data objectForKey:@"first_name"]]retain];
    lastName = [[self parseReturn:[data objectForKey:@"last_name"]] retain];
    name = [[self parseReturn:[data objectForKey:@"name"]] retain];
    picSmall = [[self parseReturn:[data objectForKey:@"pic_small"]] retain];
    picSmallWithLogo = [[self parseReturn:[data objectForKey:@"pic_small_with_logo"]] retain];
    username = [[self parseReturn:[data objectForKey:@"username"]] retain];
    email = [[self parseReturn:[data objectForKey:@"proxied_email"]] retain];
}

- (id)parseReturn:(id)value {
    return value != [NSNull null] ? value : nil;
}

- (NSComparisonResult)nameCompare:(FBUser *)user {
    return [name caseInsensitiveCompare:user.name];
}

- (NSComparisonResult)lastFirstCompare:(FBUser *)user {
    NSComparisonResult ret = [lastName caseInsensitiveCompare:user.lastName];
    if (ret == NSOrderedSame) {
        ret = [firstName caseInsensitiveCompare:user.firstName];
    }
    return ret;
}

- (NSComparisonResult)firstLastCompare:(FBUser *)user {
    NSComparisonResult ret = [firstName caseInsensitiveCompare:user.firstName];
    if (ret == NSOrderedSame) {
        ret = [lastName caseInsensitiveCompare:user.lastName];
    }
    return ret;
}

- (void)requestFriends:(FBSession *)session withDelegate:(id<FBRequestDelegate>)delegate {
    NSString* fql = [NSString stringWithFormat:@"%@ in (select uid2 from friend where uid1 = %@)", userFQL, uid];
    NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
    FBRequest* request = [FBRequest requestWithSession:session delegate:self];
	request.userInfo = userFriendsRequest;
    [request call:@"facebook.fql.query" params:params];
    [self addDelegate:delegate forRequest:request];
}

- (void)addDelegate:(id<FBRequestDelegate>)delegate forRequest:(FBRequest*)request {
    if (delegate && request) {
        [delegates setObject:delegate forKey:[NSNumber numberWithInt:[request hash]]];
    }
}

- (id<FBRequestDelegate>)delegateForRequest:(FBRequest*)request {
    id<FBRequestDelegate> delegate = nil;
    if (request) {
        delegate = [delegates objectForKey:[NSNumber numberWithInt:[request hash]]];
    }
    return delegate;
}

- (void)dealloc {
    [uid release], uid = nil;
    [firstName release], firstName = nil;
    [lastName release], lastName = nil;
    [name release], name = nil;
    [username release], username = nil;
	[email release], email = nil;
    [friends release], friends = nil;
    [picSmall release], picSmall = nil;
    [picSmallWithLogo release], picSmallWithLogo = nil;
    [delegates release], delegates = nil;
	[super dealloc];
}

#pragma mark FBRequestDelegate

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response {
    id<FBRequestDelegate> delegate = [delegates objectForKey:request];
    if ([delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [delegate request:request didReceiveResponse:response];
    }
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
    id<FBRequestDelegate> delegate = [delegates objectForKey:request];
    if ([delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [delegate request:request didFailWithError:error];
    }
    [delegates removeObjectForKey:request];
}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on the format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
    if (result) {
        if ([request.userInfo isEqualToString:userDetailsRequest]) {
            [self initValues:[((NSArray*)result) objectAtIndex:0]];
            result = self;
        } else if ([request.userInfo isEqualToString:userFriendsRequest]) {
            NSMutableArray *fbfriends = [[NSMutableArray alloc] init];
            for (id dictionary in result) {
				FBUser *friend = [[FBUser alloc] initWithDictionary:dictionary];
				[fbfriends addObject:friend];
				[friend release];
			}
			[fbfriends sortUsingSelector:@selector(lastFirstCompare:)];
			[friends release];
            friends = [[NSArray alloc] initWithArray:fbfriends];
            result = friends;
            [fbfriends release];
        }
    }
    id<FBRequestDelegate> delegate = [self delegateForRequest:request];
    if ([delegate respondsToSelector:@selector(request:didLoad:)]) {
        [delegate request:request didLoad:result];
    }
    [delegates removeObjectForKey:request];
}

@end
