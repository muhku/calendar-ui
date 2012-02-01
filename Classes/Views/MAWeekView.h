/*
 * Copyright (c) 2010 Matias Muhonen <mmu@iki.fi>
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

#import <UIKit/UIKit.h>

static NSString const * const HOURS_AM_PM[] = {
	@" 12 AM", @" 1 AM", @" 2 AM", @" 3 AM", @" 4 AM", @" 5 AM", @" 6 AM", @" 7 AM", @" 8 AM", @" 9 AM", @" 10 AM", @" 11 AM",
	@" Noon", @" 1 PM", @" 2 PM", @" 3 PM", @" 4 PM", @" 5 PM", @" 6 PM", @" 7 PM", @" 8 PM", @" 9 PM", @" 10 PM", @" 11 PM", @" 12 PM"
};

static NSString const * const HOURS_24[] = {
	@" 0:00", @" 1:00", @" 2:00", @" 3:00", @" 4:00", @" 5:00", @" 6:00", @" 7:00", @" 8:00", @" 9:00", @" 10:00", @" 11:00",
	@" 12:00", @" 13:00", @" 14:00", @" 15:00", @" 16:00", @" 17:00", @" 18:00", @" 19:00", @" 20:00", @" 21:00", @" 22:00", @" 23:00", @" 24:00"
};
#define HOURS_IN_DAY                        24
#define DAYS_IN_WEEK                        7
#define MINUTES_IN_HOUR                     60
#define SPACE_BETWEEN_HOUR_LABELS           3
#define SPACE_BETWEEN_HOUR_LABELS_LANDSCAPE 2
#define DEFAULT_LABEL_FONT_SIZE             10
#define VIEW_EMPTY_SPACE                    10
#define ALL_DAY_VIEW_EMPTY_SPACE            3
#define TEXT_WHICH_MUST_FIT                 @"Noon123"

#define TOP_BACKGROUND_IMAGE                @"ma_topBackground.png"
#define LEFT_ARROW_IMAGE                    @"ma_leftArrow.png"
#define RIGHT_ARROW_IMAGE                   @"ma_rightArrow.png"
#define ARROW_LEFT                          0
#define ARROW_RIGHT                         1
#define ARROW_WIDTH                         48
#define ARROW_HEIGHT                        38
#define TOP_BACKGROUND_HEIGHT               35

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@class MAGridView;
@class MAHourView;
@class MAWeekdayView;
@class MAEventGridView;
@class MAEvent;

@protocol MAWeekViewDataSource, MAWeekViewDelegate;

@interface MAWeekView : UIView {
	UIImageView *_topBackground;
	UIButton *_leftArrow, *_rightArrow;
	UILabel *_dateLabel;
	
	MAEventGridView *_allDayEventView;
	UIScrollView *_scrollView;
	MAGridView *_gridView;
	MAHourView *_hourView;
	MAWeekdayView *_weekdayView;
	
	unsigned int _labelFontSize;
	UIFont *_regularFont;
	UIFont *_boldFont;
	
	NSDate *_week;
	
	UISwipeGestureRecognizer *_swipeLeftRecognizer, *_swipeRightRecognizer;
	
	id<MAWeekViewDataSource> _dataSource;
	id<MAWeekViewDelegate> __unsafe_unretained _delegate;
}

@property (readwrite,assign) unsigned int labelFontSize;
@property (nonatomic,copy) NSDate *week;
@property (nonatomic,unsafe_unretained) IBOutlet id<MAWeekViewDataSource> dataSource;
@property (nonatomic,unsafe_unretained) IBOutlet id<MAWeekViewDelegate> delegate;

- (void)reloadData;

@end

@protocol MAWeekViewDataSource <NSObject>

- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)date;

@end

@protocol MAWeekViewDelegate <NSObject>

@optional
- (void)weekView:(MAWeekView *)weekView eventTapped:(MAEvent *)event;
- (void)weekView:(MAWeekView *)weekView weekDidChange:(NSDate *)week;

@end


@interface MAWeekView (PrivateMethods)
- (void)setupCustomInitialisation;
- (void)changeWeek:(UIButton *)sender;
- (NSDate *)firstDayOfWeekFromDate:(NSDate *)date;
- (NSDate *)nextWeekFromDate:(NSDate *)date;
- (NSDate *)previousWeekFromDate:(NSDate *)date;
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;

@property (readonly) UIImageView *topBackground;
@property (readonly) UIButton *leftArrow;
@property (readonly) UIButton *rightArrow;
@property (readonly) UILabel *dateLabel;
@property (readonly) MAGridView *gridView;
@property (readonly) UIScrollView *scrollView;
@property (readonly) UIFont *regularFont;
@property (readonly) UIFont *boldFont;
@property (readonly) MAHourView *hourView;
@property (readonly) MAWeekdayView *weekdayView;
@property (readonly) MAEventGridView *allDayEventView;
@property (readonly) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (readonly) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (readonly) NSString *titleText;
@end