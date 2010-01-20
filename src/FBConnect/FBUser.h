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
    NSString *firstName;
    NSString *lastName;
    NSString *name;
    NSString *username;
    NSString *picSmall;
    NSString *picSmallWithLogo;
    NSString *email;
    NSArray *friends;
    BOOL isAppUser;
}

@property(nonatomic,readonly)NSNumber *uid;
@property(nonatomic,readonly)NSString *firstName;
@property(nonatomic,readonly)NSString *lastName;
@property(nonatomic,readonly)NSString *name;
@property(nonatomic,readonly)NSString *username;
@property(nonatomic,readonly)NSString *picSmall;
@property(nonatomic,readonly)NSString *picSmallWithLogo;
@property(nonatomic,readonly)NSString *email;
@property(nonatomic,readonly)NSArray *friends;
@property(nonatomic,readonly)BOOL isAppUser;

+ (FBUser *)userForSession:(FBSession *)session andDelegate:(id<FBRequestDelegate>)delegate;
- (FBUser *)initWithDictionary:(NSDictionary *)data;
- (NSComparisonResult)nameCompare:(FBUser *)user;
- (NSComparisonResult)lastFirstCompare:(FBUser *)user;
- (NSComparisonResult)firstLastCompare:(FBUser *)user;
- (void)requestFriends:(FBSession *)session withDelegate:(id<FBRequestDelegate>)delegate;

@end
