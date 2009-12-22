//
//  FBUser.h
//  NGPlatform
//
//  Created by Ashley Martens on 11/17/09.
//  Copyright 2009 ngmoco:). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect/FBRequest.h"


@interface FBUser : NSObject <FBRequestDelegate> {
@private
    NSMutableDictionary *delegates;
    NSNumber *uid;
    NSString *first_name;
    NSString *last_name;
    NSString *name;
    NSString *username;
    NSString *pic_small;
    NSString *pic_sm_wl;
    NSString *email;
    NSArray  *friends;
    BOOL      is_app_user;
}

@property (readonly) NSNumber *uid;
@property (readonly) NSString *first_name;
@property (readonly) NSString *last_name;
@property (readonly) NSString *name;
@property (readonly) NSString *username;
@property (readonly) NSString *pic_small;
@property (readonly) NSString *pic_small_with_logo;
@property (readonly) NSString *email;
@property (readonly) NSArray  *friends;
@property (readonly) BOOL      is_app_user;

+ (FBUser *) userForSession:(FBSession *)session andDelegate:(id<FBRequestDelegate>)delegate;
- (FBUser *) initWithDictionary:(NSDictionary *)data;
- (NSComparisonResult) nameCompare:(FBUser *) user;
- (NSComparisonResult) lastFirstCompare:(FBUser *) user;
- (NSComparisonResult) firstLastCompare:(FBUser *) user;
- (void) requestFriends:(FBSession *)session withDelegate:(id<FBRequestDelegate>)delegate;

@end
