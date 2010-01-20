//
//  FBFriendDialog.m
//  FBConnect
//
//  Created by Dennis Blöte on 20.01.10.
//  Copyright 2010 //dennisbloete. All rights reserved.
//

#import "FBFriendDialog.h"
#import "FBSession.h"
#import "FBUser.h"


@implementation FBFriendDialog

- (id)initWithSession:(FBSession*)theSession {
	return [self initWithSession:theSession andUser:theSession.user];
}

- (id)initWithSession:(FBSession*)theSession andUser:(FBUser *)theUser {
	if (self = [super initWithSession:theSession]) {
		_user = [theUser retain];
		_tableView = [[UITableView alloc] initWithFrame:CGRectZero];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_tableView];
	}
	return self;
}

- (void)dealloc {
	[_user release];
	[_tableView release];
	[super dealloc];
}

- (void)show {
	[super show];
	if (!_user.friends) [_user requestFriends:_session withDelegate:self];
	_tableView.frame = _webView.frame;
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	[_tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	FBUser *friend = [_user.friends objectAtIndex:indexPath.row];
	cell.textLabel.text = friend.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_delegate respondsToSelector:@selector(dialog:didSelectUser:)]) {
		FBUser *friend = [_user.friends objectAtIndex:indexPath.row];
		[_delegate dialog:self didSelectUser:friend];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_user.friends count];
}

@end
