//
//  MAHourView.h
//  CalendarUI
//
//  Created by Evan Rosenfeld on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAWeekView.h"

@interface MAHourView : UIView {
	MAWeekView *_weekView;
	UIColor *_textColor;
	UIFont *_textFont;
}

- (BOOL)timeIs24HourFormat;

@property (nonatomic, strong) MAWeekView *weekView;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;

@end