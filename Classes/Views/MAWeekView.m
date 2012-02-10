/*
 * Copyright (c) 2010-2012 Matias Muhonen <mmu@iki.fi>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MAWeekView.h"
#import "MAHourView.h"
#import "MAGridView.h"
#import "MADayView.h"
#import "MAEventView.h"
#import "MAEventGridView.h"
#import "MAWeekDayView.h"
#import "MAEvent.h"               /* MAEvent */
#import <QuartzCore/QuartzCore.h> /* CALayer */
#import "MAGridView.h"            /* MAGridView */
#import "TapDetectingView.h"      /* TapDetectingView */



@interface MAGridView (MAWeekViewAdditions)
- (void)addEventToOffset:(unsigned int)offset event:(MAEvent *)event weekView:(MAWeekView *)weekView;
@end



@implementation MAWeekView

@synthesize labelFontSize=_labelFontSize;
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setupCustomInitialisation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation {
	self.labelFontSize = DEFAULT_LABEL_FONT_SIZE;
	self.week = [NSDate date];
    
	[self addSubview:self.topBackground];
	[self addSubview:self.leftArrow];
	[self addSubview:self.rightArrow];
	[self addSubview:self.dateLabel];
	[self addSubview:self.weekdayView];
	
	[self addSubview:self.scrollView];
	
	[self.scrollView addSubview:self.allDayEventView];
	[self.scrollView addSubview:self.hourView];
	[self.scrollView addSubview:self.gridView];
	
	[self.gridView addGestureRecognizer:self.swipeLeftRecognizer];
	[self.gridView addGestureRecognizer:self.swipeRightRecognizer];
}

- (void)dealloc {
	_topBackground = nil;
	_leftArrow = nil;
	_rightArrow = nil;
	_dateLabel = nil;
	
	_scrollView = nil;
	_gridView = nil;
	_allDayEventView = nil;
	
	_regularFont = nil;
	_boldFont = nil;
	
	_swipeLeftRecognizer = nil;
	_swipeRightRecognizer = nil;
	
	_week = nil;
}

- (void)layoutSubviews {
	const CGSize sizeNecessary = [TEXT_WHICH_MUST_FIT sizeWithFont:self.regularFont];
	const CGSize sizeNecessaryBold = [TEXT_WHICH_MUST_FIT sizeWithFont:self.boldFont];
    
    self.topBackground.frame = CGRectMake(CGRectGetMinX(self.bounds),
										  CGRectGetMinY(self.bounds),
										  CGRectGetWidth(self.bounds), TOP_BACKGROUND_HEIGHT + 10);
	
	self.leftArrow.frame = CGRectMake(CGRectGetMinX(self.topBackground.bounds),
								  CGRectGetMinY(self.topBackground.bounds),
									  ARROW_WIDTH, ARROW_HEIGHT);
	
	self.rightArrow.frame = CGRectMake(CGRectGetWidth(self.topBackground.bounds) - ARROW_WIDTH,
									CGRectGetMinY(self.topBackground.bounds),
									ARROW_WIDTH, ARROW_HEIGHT);
	
	self.dateLabel.frame = CGRectMake(CGRectGetMaxX(self.leftArrow.bounds),
									  CGRectGetMinY(self.topBackground.bounds),
									  CGRectGetWidth(self.topBackground.bounds) - CGRectGetWidth(self.leftArrow.bounds) - CGRectGetWidth(self.rightArrow.bounds),
									  ARROW_HEIGHT);
	
	self.allDayEventView.frame = CGRectMake(sizeNecessary.width, 0,
											CGRectGetWidth(self.bounds) - sizeNecessary.width,
											ALL_DAY_VIEW_EMPTY_SPACE);
	
	unsigned int hourLabelSpacer;
	if (CGRectGetWidth(self.bounds) > CGRectGetHeight(self.bounds)) {
		hourLabelSpacer = SPACE_BETWEEN_HOUR_LABELS_LANDSCAPE;
	} else {
		hourLabelSpacer = SPACE_BETWEEN_HOUR_LABELS;
	}
	
	self.hourView.frame = CGRectMake(CGRectGetMinX(self.allDayEventView.bounds),
									 CGRectGetMaxY(self.allDayEventView.bounds), 
									 sizeNecessary.width,
									 sizeNecessary.height * HOURS_IN_DAY * hourLabelSpacer);
	
	[self.hourView setNeedsDisplay];
	
	self.weekdayView.frame = CGRectMake(CGRectGetMaxX(self.hourView.bounds),
										CGRectGetMaxY(self.topBackground.bounds) - sizeNecessaryBold.height, 
										CGRectGetWidth(self.topBackground.bounds) - CGRectGetWidth(self.hourView.bounds),
										sizeNecessaryBold.height);
	[self.weekdayView setNeedsDisplay];
	
	self.scrollView.frame = CGRectMake(CGRectGetMinX(self.bounds),
									   CGRectGetMaxY(self.topBackground.bounds),
									   CGRectGetWidth(self.bounds),
									   CGRectGetHeight(self.bounds) - CGRectGetHeight(self.topBackground.bounds));
	
	self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds),
											 CGRectGetHeight(self.allDayEventView.bounds) + CGRectGetHeight(self.hourView.bounds) + VIEW_EMPTY_SPACE);
	
	self.gridView.frame = CGRectMake(CGRectGetMaxX(self.hourView.bounds),
									 CGRectGetMaxY(self.allDayEventView.bounds),
									 CGRectGetWidth(self.bounds) - CGRectGetWidth(self.hourView.bounds),
									 CGRectGetHeight(self.hourView.bounds));
    [self.gridView setNeedsDisplay];
}

- (UIImageView *)topBackground {
	if (!_topBackground) {
		_topBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:TOP_BACKGROUND_IMAGE]];
	}
	return _topBackground;
}

- (UIButton *)leftArrow {
	if (!_leftArrow) {
		_leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		_leftArrow.tag = ARROW_LEFT;
		[_leftArrow setImage:[UIImage imageNamed:LEFT_ARROW_IMAGE] forState:0];
		[_leftArrow addTarget:self action:@selector(changeWeek:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _leftArrow;
}

- (UIButton *)rightArrow {
	if (!_rightArrow) {
		_rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		_rightArrow.tag = ARROW_RIGHT;
		[_rightArrow setImage:[UIImage imageNamed:RIGHT_ARROW_IMAGE] forState:0];
		[_rightArrow addTarget:self action:@selector(changeWeek:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _rightArrow;
}

- (UILabel *)dateLabel {
	if (!_dateLabel) {
		_dateLabel = [[UILabel alloc] init];
		_dateLabel.textAlignment = UITextAlignmentCenter;
		_dateLabel.backgroundColor = [UIColor clearColor];
		_dateLabel.font = [UIFont boldSystemFontOfSize:18];
		_dateLabel.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	}
	return _dateLabel;
}

- (UIScrollView *)scrollView {
	if (!_scrollView) {
		_scrollView = [[UIScrollView alloc] init];
		_scrollView.backgroundColor      = [UIColor whiteColor];
		_scrollView.scrollEnabled        = TRUE;
		_scrollView.alwaysBounceVertical = TRUE;
	}
	return _scrollView;
}

- (MAEventGridView *)allDayEventView {
	if (!_allDayEventView) {
		_allDayEventView = [[MAEventGridView alloc] init];
		_allDayEventView.backgroundColor = [UIColor whiteColor];
		_allDayEventView.weekView = self;
		_allDayEventView.textFont = self.regularFont;
	}
	return _allDayEventView;
}

- (MAHourView *)hourView {
	if (!_hourView) {
		_hourView = [[MAHourView alloc] init];
		_hourView.weekView        = self;
		_hourView.backgroundColor = [UIColor whiteColor];
		_hourView.textColor       = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.f];
		_hourView.textFont        = self.boldFont;
	}
	return _hourView;
}

- (MAWeekdayView *)weekdayView {
	if (!_weekdayView) {
		_weekdayView = [[MAWeekdayView alloc] init];
		_weekdayView.weekView        = self;
		_weekdayView.backgroundColor = [UIColor clearColor];
		_weekdayView.textColor       = [UIColor blackColor];
		_weekdayView.sundayColor     = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1.f];
		_weekdayView.todayColor      = [UIColor colorWithRed:0.1 green:0.5 blue:0.9 alpha:1.f];
		_weekdayView.textFont        = self.regularFont;
	}
	return _weekdayView;
}

- (MAGridView *)gridView {
	if (!_gridView){		
		_gridView = [[MAGridView alloc] init];
		_gridView.backgroundColor = [UIColor whiteColor];
		_gridView.rows            = HOURS_IN_DAY;
		_gridView.columns         = DAYS_IN_WEEK;
		_gridView.outerBorder     = YES;
		_gridView.verticalLines   = YES;
		_gridView.horizontalLines = YES;
		_gridView.lineColor       = [UIColor lightGrayColor];
		_gridView.lineWidth       = 1;
	}
	return _gridView;
}

- (UIFont *)regularFont {
	if (!_regularFont) {
		_regularFont = [UIFont systemFontOfSize:_labelFontSize];
	}
	return _regularFont;
}

- (UIFont *)boldFont {
	if (!_boldFont) {
		_boldFont = [UIFont boldSystemFontOfSize:_labelFontSize];
	}
	return _boldFont;
}

- (UISwipeGestureRecognizer *)swipeLeftRecognizer {
	if (!_swipeLeftRecognizer) {
		_swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
		_swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	}
	return _swipeLeftRecognizer;
}

- (UISwipeGestureRecognizer *)swipeRightRecognizer {
	if (!_swipeRightRecognizer) {
		_swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
		_swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	}
	return _swipeRightRecognizer;
}

- (void)setDataSource:(id <MAWeekViewDataSource>)dataSource {
	_dataSource = dataSource;
	[self reloadData];
}

- (id <MAWeekViewDataSource>)dataSource {
	return _dataSource;
}

- (void)setWeek:(NSDate *)date {
	NSDate *firstOfWeek = [self firstDayOfWeekFromDate:date];
	_week = firstOfWeek;
	self.weekdayView.week = _week;
	[self.weekdayView setNeedsDisplay];
	
	self.allDayEventView.week = _week;
	 
	self.dateLabel.text = [self titleText];
	
	[self reloadData];
	
	if ([self.delegate respondsToSelector:@selector(weekView:weekDidChange:)]) {
        [self.delegate weekView:self weekDidChange:self.week];
	}
}

- (NSDate *)week {
	NSDate *date = [_week copy]; // alloc
	return date;
}

- (void)reloadData {
	for (id view in self.allDayEventView.subviews) {
		if ([NSStringFromClass([view class])isEqualToString:@"MAEventView"]) {
			[view removeFromSuperview];
		}
	}
	
	for (id view in self.gridView.subviews) {
		if ([NSStringFromClass([view class])isEqualToString:@"MAEventView"]) {
			[view removeFromSuperview];
		}
	}
	
	[self.allDayEventView resetCachedData];
	
	size_t d = 0;
	for (NSDate *weekday in self.weekdayView.weekdays) {
		NSArray *events = [self.dataSource weekView:self eventsForDate:weekday];
		
		for (id e in events) {
			MAEvent *event = e;
			event.displayDate = weekday;
		}
		
		for (id e in [events sortedArrayUsingFunction:MAEvent_sortByStartTime context:NULL]) {
			MAEvent *event = e;
			
			if (event.allDay) {
				[self.allDayEventView addEventToOffset:d event:event];
			} else {
				[self.gridView addEventToOffset:d event:event weekView:self];
			}
		}
		d++;
	}
}

- (void)changeWeek:(UIButton *)sender {
	if (ARROW_LEFT == sender.tag) {
		self.week = [self previousWeekFromDate:_week];
	} else if (ARROW_RIGHT == sender.tag) {
		self.week = [self nextWeekFromDate:_week];
	}
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		[self changeWeek:self.rightArrow];
	} else  if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
		[self changeWeek:self.leftArrow];
	}
}

- (NSDate *)firstDayOfWeekFromDate:(NSDate *)date {
	CFCalendarRef currentCalendar = CFCalendarCopyCurrent();
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
	[components setDay:([components day] - ([components weekday] - CFCalendarGetFirstWeekday(currentCalendar)))];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	CFRelease(currentCalendar);
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *)nextWeekFromDate:(NSDate *)date {
	CFCalendarRef currentCalendar = CFCalendarCopyCurrent();
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
	[components setDay:([components day] - ([components weekday] - CFCalendarGetFirstWeekday(currentCalendar) - 7))];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	CFRelease(currentCalendar);
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *)previousWeekFromDate:(NSDate *)date {
	CFCalendarRef currentCalendar = CFCalendarCopyCurrent();
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
	[components setDay:([components day] - ([components weekday] - CFCalendarGetFirstWeekday(currentCalendar) + 7))];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	CFRelease(currentCalendar);
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSString *)titleText {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:_week];
	
	NSArray *monthSymbols = [formatter shortMonthSymbols];
	
	return [NSString stringWithFormat:@"%@, week %i",
			[monthSymbols objectAtIndex:[components month] - 1],
			[components week]];
}

@end


@implementation MAGridView (MAWeekViewAdditions)

- (void)addEventToOffset:(unsigned int)offset event:(MAEvent *)event weekView:(MAWeekView *)weekView {
	MAEventView *eventView = [[MAEventView alloc] init];
	eventView.weekView = weekView;
	eventView.event = event;
	eventView.backgroundColor = event.backgroundColor;
	eventView.title = event.title;
	eventView.textFont = weekView.regularFont;
	eventView.textColor = event.textColor;
	eventView.xOffset = offset;
	
	[self addSubview:eventView];
}

- (void)layoutSubviews {
	CGFloat cellWidth = self.cellWidth;
	CGFloat cellHeight = self.cellHeight;
	
	for (id view in self.subviews) {
		if (![NSStringFromClass([view class])isEqualToString:@"MAEventView"]) {
			continue;
		}
		MAEventView *eventView = (MAEventView *) view;
		eventView.frame = CGRectMake(cellWidth * eventView.xOffset,
									 cellHeight / MINUTES_IN_HOUR * [eventView.event minutesSinceMidnight],
									 cellWidth,
									 cellHeight / MINUTES_IN_HOUR * [eventView.event durationInMinutes]);
		[eventView setNeedsDisplay];
	}
}

@end

