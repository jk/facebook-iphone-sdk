//
//  FBUser.m
//  NGPlatform
//
//  Created by Ashley Martens on 11/17/09.
//  Copyright 2009 ngmoco:). All rights reserved.
//

#import "FBConnect/FBUser.h"
#import "FBConnect/FBSession.h"

static const NSString *userFQL = @"select uid, first_name, last_name, name, pic_small, is_app_user, username, proxied_email from user where uid";

@interface FBUser()
-(id) parseReturn:(id)value;
-(void) initValues:(NSDictionary *)data;
@end


@implementation FBUser

@synthesize uid;
@synthesize is_app_user;
@synthesize first_name, last_name, name, username, pic_small, email;
@synthesize friends;

enum REQUEST_TYPE {
    INIT_REQUEST,
    FRIEND_REQUEST
};

- (FBUser *) initWithUID:(FBUID)userid session:(FBSession *)session andDelegate:(id<FBRequestDelegate>)delegate {
//    NSLog(@"FBUser uid: %i", userid);
    if (self = [super init]) {
        uid = [[NSNumber numberWithLongLong:userid] retain];
        NSString* fql = [NSString stringWithFormat:@"%@ = %i", userFQL, userid];
//        NSLog(@"FBUser query: %@", fql);
        NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
        FBRequest *request = [FBRequest requestWithSession:session delegate:self];
        request.userInfo = self;
        [request call:@"facebook.fql.query" params:params];
        _delegate = delegate;
        _request  = INIT_REQUEST;
    }
    
    return self;
}

+ (FBUser *) userForSession:(FBSession *)session andDelegate:(id<FBRequestDelegate>)delegate {
    return [[[FBUser alloc] initWithUID:session.uid session:session andDelegate:delegate] autorelease];
}

- (FBUser *) initWithDictionary:(NSDictionary *)data {
    NSLog(@"FBUser dictionary: %@", data);
    if (self = [super init]) {
        uid = [[data objectForKey:@"uid"] retain];
        [self initValues:data];
    }

    return self;
}

- (void) initValues:(NSDictionary *)data {
    is_app_user = [(NSNumber *)[data objectForKey:@"is_app_user"] boolValue];
    first_name  = [[self parseReturn:[data objectForKey:@"first_name"]] retain];
    last_name   = [[self parseReturn:[data objectForKey:@"last_name"]] retain];
    name        = [[self parseReturn:[data objectForKey:@"name"]] retain];
    pic_small   = [[self parseReturn:[data objectForKey:@"pic_small"]] retain];
    username    = [[self parseReturn:[data objectForKey:@"username"]] retain];
    email       = [[self parseReturn:[data objectForKey:@"proxied_email"]] retain];
}

- (id) parseReturn:(id)value {
    return value != [NSNull null] ? value : nil;
}

- (NSComparisonResult) nameCompare:(FBUser *) user {
    return [name caseInsensitiveCompare:user.name];
}

- (NSComparisonResult) lastFirstCompare:(FBUser *) user {
    NSComparisonResult ret = [last_name caseInsensitiveCompare:user.last_name];
    if (ret == NSOrderedSame) {
        ret = [first_name caseInsensitiveCompare:user.first_name];
    }
    return ret;
}

- (NSComparisonResult) firstLastCompare:(FBUser *) user {
    NSComparisonResult ret = [first_name caseInsensitiveCompare:user.first_name];
    if (ret == NSOrderedSame) {
        ret = [last_name caseInsensitiveCompare:user.last_name];
    }
    return ret;
}

- (void) requestFriends:(FBSession *)session withDelegate:(id<FBRequestDelegate>)delegate {
    NSString* fql = [NSString stringWithFormat:@"%@ in (select uid2 from friend where uid1 = %i)", userFQL, uid];
    NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
    [[FBRequest requestWithSession:session delegate:self] call:@"facebook.fql.query" params:params];
    _delegate = delegate;
    _request  = FRIEND_REQUEST;
}

- (void) dealloc {
    [uid release];
    uid = nil;
    
    [first_name release];
    first_name = nil;
    
    [last_name release];
    last_name = nil;
    
    [name release];
    name = nil;
    
    [pic_small release];
    pic_small = nil;
    
    [username release];
    username = nil;
    
    [email release];
    email = nil;
    
    [friends release];
    friends = nil;

    [super dealloc];
}

#pragma mark FBRequestDelegate

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response {
    NSLog(@"Facebook user didReceiveResponse");
    if ([_delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [_delegate request:request didReceiveResponse:response];
    }
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
    NSLog(@"Facebook user didFailWithError: %@", error);
    if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [_delegate request:request didFailWithError:error];
    }
}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
    NSLog(@"Facebook user request didLoad: %@", result);

    if (result) {
        if (request.userInfo && request.userInfo == self) {
            if ([result count] == 1) {
                [self initValues:[((NSArray*)result) objectAtIndex:0]];
            }
        } else {
            NSMutableArray *fbfriends;

            if ([result count] > 0) {
                NSLog(@"%d result count", [result count]);
                fbfriends = [[[NSMutableArray alloc] initWithCapacity:[result count]] autorelease];
                
                for (id dictionary in result) {
                    [fbfriends addObject:[[[FBUser alloc] initWithDictionary:dictionary] autorelease]];
                }
            }
            
            friends = [NSArray arrayWithArray:fbfriends];
        }
    }

    if ([_delegate respondsToSelector:@selector(request:didLoad:)]) {
        [_delegate request:request didLoad:result];
    }
}

@end
