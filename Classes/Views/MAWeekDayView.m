//
//  MAWeekDayView.m
//  CalendarUI
//
//  Created by Evan Rosenfeld on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAWeekDayView.h"
#import "MAGridView.h"

@implementation MAWeekdayView

@synthesize weekView=_weekView;
@synthesize textColor=_textColor, sundayColor=_sundayColor, todayColor=_todayColor;
@synthesize textFont=_textFont;
@synthesize weekdays=_weekdays;

- (void)setWeek:(NSDate *)week {
	_week = week;
	
	NSDate *date = _week;
	NSDateComponents *components;
	NSDateComponents *components2 = [[NSDateComponents alloc] init];
	[components2 setDay:1];
	
	_weekdays = [[NSMutableArray alloc] init];
	
	for (register unsigned int i=0; i < DAYS_IN_WEEK; i++) {
		[_weekdays addObject:date];
		components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
		[components setDay:1];
		date = [CURRENT_CALENDAR dateByAddingComponents:components2 toDate:date options:0];
	}
	
}

- (NSDate *)week {
	return _week;
}

- (void)drawRect:(CGRect)rect {
	register unsigned int i = 0;
	
	const CGFloat cellWidth = self.weekView.gridView.cellWidth;
	
	NSDateComponents *todayComponents = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:[NSDate date]];
	
	NSArray *weekdaySymbols = [self.dateFormatter veryShortWeekdaySymbols];
	CFCalendarRef currentCalendar = CFCalendarCopyCurrent();
	int d = CFCalendarGetFirstWeekday(currentCalendar) - 1;
	CFRelease(currentCalendar);
	
	for (NSDate *date in _weekdays) {
		NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
		NSString *displayText = [NSString stringWithFormat:@"%@ %i", [weekdaySymbols objectAtIndex:d], [components day]];
		
		CGSize sizeNecessary = [displayText sizeWithFont:self.textFont];
		CGRect rect = CGRectMake(cellWidth * i + ((cellWidth - sizeNecessary.width) / 2.f),
								 CGRectGetMinY(self.bounds),
								 sizeNecessary.width,
								 sizeNecessary.height);
		
		if ([todayComponents day] == [components day] &&
			[todayComponents month] == [components month] &&
			[todayComponents year] == [components year]) {
			[self.todayColor set];
		} else if ([components weekday] == 1) {
			[self.sundayColor set];
		} else {
			[self.textColor set];
		}
		
		[displayText drawInRect: rect
                       withFont:self.textFont
                  lineBreakMode:UILineBreakModeTailTruncation
                      alignment:UITextAlignmentLeft];
		
		d = (d+1) % 7;
		i++;
	}
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
	}
	return _dateFormatter;
}

- (void)dealloc {
	self.week = nil;
	_dateFormatter = nil;
	_weekdays = nil;
}

@end