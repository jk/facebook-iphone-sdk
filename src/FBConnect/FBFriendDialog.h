//
//  FBFriendDialog.h
//  FBConnect
//
//  Created by Dennis Blöte on 20.01.10.
//  Copyright 2010 //dennisbloete. All rights reserved.
//

#import "FBConnect/FBDialog.h"
#import "FBConnect/FBRequest.h"

@class FBUser;

@interface FBFriendDialog : FBDialog <FBRequestDelegate, UITableViewDelegate, UITableViewDataSource> {
	UITableView* _tableView;
	FBUser *_user;
}

- (id)initWithSession:(FBSession*)theSession andUser:(FBUser *)theUser;

@end
