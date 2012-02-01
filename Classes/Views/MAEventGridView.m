//
//  MAEventGridView.m
//  CalendarUI
//
//  Created by Evan Rosenfeld on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAEventGridView.h"
#import "MAGridView.h"
#import "MAWeekView.h"
#import "MAHourView.h"
#import "MAEventView.h"
#import "MADayView.h"
#import "MAWeekDayView.h"

@implementation MAEventGridView

@synthesize weekView=_weekView;
@synthesize textFont=_textFont;

- (void)dealloc {
	_week = nil;
}

#define ARR_SET(X) _eventsInOffset[X] = 0;

- (void)resetCachedData {
	_maxEvents = 0;
	ARR_SET(0)
	ARR_SET(1)
	ARR_SET(2)
	ARR_SET(3)
	ARR_SET(4)
	ARR_SET(5)
	ARR_SET(6)
}

#undef ARR_SET

- (void)setWeek:(NSDate *)week {
	[self resetCachedData];
	
	_week = [week copy];
	
	[self setNeedsLayout];
}

- (NSDate *)week {
	return _week;
}

- (void)layoutSubviews {
	const CGFloat cellHeight = self.weekView.gridView.cellHeight;
	
	self.frame = CGRectMake(self.frame.origin.x,
							self.frame.origin.y,
							self.frame.size.width,
							ALL_DAY_VIEW_EMPTY_SPACE + (ALL_DAY_VIEW_EMPTY_SPACE + cellHeight) * _maxEvents);
	
	self.weekView.hourView.frame =  CGRectMake(self.weekView.hourView.frame.origin.x, self.frame.size.height,
											   self.weekView.hourView.frame.size.width, self.weekView.hourView.frame.size.height);
	
	self.weekView.gridView.frame =  CGRectMake(self.weekView.gridView.frame.origin.x, self.frame.size.height,
											   self.weekView.gridView.frame.size.width, self.weekView.gridView.frame.size.height);
	
	self.weekView.scrollView.contentSize = CGSizeMake(self.weekView.scrollView.contentSize.width,
													  CGRectGetHeight(self.bounds) + CGRectGetHeight(self.weekView.hourView.bounds));
	
	const CGFloat eventWidth = self.weekView.gridView.cellWidth * 0.95;
	
	for (id view in self.subviews) {
		if (![NSStringFromClass([view class])isEqualToString:@"MAEventView"]) {
			continue;
		}
		MAEventView *eventView = (MAEventView *) view;
		eventView.frame = CGRectMake(self.weekView.gridView.cellWidth * eventView.xOffset,
									 ALL_DAY_VIEW_EMPTY_SPACE + (ALL_DAY_VIEW_EMPTY_SPACE + cellHeight) * eventView.yOffset,
									 eventWidth, cellHeight);
		[eventView setNeedsDisplay];
	}
}

- (void)addEventToOffset:(unsigned int)offset event:(MAEvent *)event {	
	MAEventView *eventView = [[MAEventView alloc] init];
	
	eventView.weekView = self.weekView;
	eventView.event = event;
	eventView.backgroundColor = event.backgroundColor;
	eventView.title = event.title;
	eventView.textFont = self.textFont;
	eventView.textColor = event.textColor;
	eventView.xOffset = offset;
	eventView.yOffset = _eventsInOffset[offset]++;
	
	[self addSubview:eventView];
	
	if (_eventsInOffset[offset] > _maxEvents) {
		_maxEvents = _eventsInOffset[offset];
		[self setNeedsLayout];
	}
}

@end
