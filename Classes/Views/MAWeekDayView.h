//
//  MAWeekDayView.h
//  CalendarUI
//
//  Created by Evan Rosenfeld on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAWeekView.h"

@interface MAWeekdayView : UIView {
	MAWeekView *_weekView;
	NSDate *_week;
	UIColor *_textColor, *_sundayColor, *_todayColor;
	UIFont *_textFont;
	NSDateFormatter *_dateFormatter;
	NSMutableArray *_weekdays;
}

@property (nonatomic, strong) MAWeekView *weekView;
@property (nonatomic,copy) NSDate *week;
@property (nonatomic, strong) UIColor *textColor, *sundayColor, *todayColor;
@property (nonatomic, strong) UIFont *textFont;
@property (weak, readonly) NSDateFormatter *dateFormatter;
@property (readonly) NSArray *weekdays;

@end