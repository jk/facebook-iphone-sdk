//
//  FacebookCell.h
//  Bredbandskollen
//
//  Created by Aleks Nesterow on 2/18/10.
//	aleks.nesterow@gmail.com
//	
//  Copyright © 2010 Screen Customs s.r.o.
//	All rights reserved.
//	
//	Purpose
//	Represents UITableViewCell with FBLoginButton.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"

@interface FBCell : UITableViewCell {

@private
	UILabel *_titleLabel;
	FBLoginButton *_loginButton;
}

@property (nonatomic, readonly) UILabel *titleLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
