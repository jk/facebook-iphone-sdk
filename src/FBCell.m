//
//  FacebookCell.m
//  Bredbandskollen
//
//  Created by Aleks Nesterow on 2/18/10.
//	aleks.nesterow@gmail.com
//	
//  Copyright © 2010 Screen Customs s.r.o.
//	All rights reserved.
//

#import "FBCell.h"

@interface FBCell (/* Private methods */)

- (CGRect)calculateTitleLabelRect;
- (CGRect)calculateLoginButtonRect;
- (void)initializeComponent;

@end

@implementation FBCell

#define kOffset				10
#define kTitleFontSize		17
#define kLoginButtonWidth	90
#define kLoginButtonHeight	30

@synthesize titleLabel = _titleLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		[self initializeComponent];
    }
	
    return self;
}

- (void)initializeComponent {

	_titleLabel = [[UILabel alloc] initWithFrame:[self calculateTitleLabelRect]];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
	[self.contentView addSubview:_titleLabel];
	
	_loginButton = [[FBLoginButton alloc] initWithFrame:[self calculateLoginButtonRect]];
	[self.contentView addSubview:_loginButton];
}

- (void)dealloc {
	
	[_titleLabel release];
	[_loginButton release];
	
    [super dealloc];
}

- (CGRect)calculateTitleLabelRect {
	
	CGFloat width = CGRectGetWidth(self.contentView.frame);
	CGFloat height = CGRectGetHeight(self.contentView.frame);
	
	CGRect rect = CGRectMake(kOffset, 0, width - kOffset * 3 - kLoginButtonWidth, height);
	return rect;
}

- (CGRect)calculateLoginButtonRect {
	
	CGFloat width = CGRectGetWidth(self.contentView.frame);
	CGFloat height = CGRectGetHeight(self.contentView.frame);
	
	CGRect rect = CGRectMake(width - kOffset - kLoginButtonWidth, (height - kLoginButtonHeight) / 2., kLoginButtonWidth, kLoginButtonHeight);
	return rect;
}
				
- (void)layoutSubviews {

	[super layoutSubviews];
	
	_titleLabel.frame = [self calculateTitleLabelRect];
	_loginButton.frame = [self calculateLoginButtonRect];
}

@end
