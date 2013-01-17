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

#import "MADayView.h"

#import "MAEvent.h"               /* MAEvent */
#import <QuartzCore/QuartzCore.h> /* CALayer */
#import "TapDetectingView.h"      /* TapDetectingView */

static const unsigned int HOURS_IN_DAY                   = 25; // Beginning and end of day is include twice
static const unsigned int MINUTES_IN_HOUR                = 60;
static const unsigned int SPACE_BETWEEN_HOUR_LABELS      = 3;
static const unsigned int DEFAULT_LABEL_FONT_SIZE        = 12;
static const unsigned int ALL_DAY_VIEW_EMPTY_SPACE       = 3;

static NSString *TOP_BACKGROUND_IMAGE                    = @"ma_topBackground.png";
static NSString *LEFT_ARROW_IMAGE                        = @"ma_leftArrow.png";
static NSString *RIGHT_ARROW_IMAGE                       = @"ma_rightArrow.png";
static const unsigned int ARROW_LEFT                     = 0;
static const unsigned int ARROW_RIGHT                    = 1;
static const unsigned int ARROW_WIDTH                    = 48;
static const unsigned int ARROW_HEIGHT                   = 38;
static const unsigned int TOP_BACKGROUND_HEIGHT          = 35;

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface MADayEventView : TapDetectingView <TapDetectingViewDelegate> {
	NSString *_title;
	UIColor *_textColor;
	UIFont *_textFont;
	__unsafe_unretained MADayView *_dayView;
	MAEvent *_event;
	CGRect _textRect;
}

- (void)setupCustomInitialisation;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, unsafe_unretained) MADayView *dayView;
@property (nonatomic, strong) MAEvent *event;

@end

@interface MA_AllDayGridView : UIView {
	__unsafe_unretained MADayView *_dayView;
	unsigned int _eventCount;
	NSDate *_day;
	CGFloat _eventHeight;
	UIFont *_textFont;
}

@property (nonatomic, assign) CGFloat eventHeight;
@property (nonatomic, unsafe_unretained) MADayView *dayView;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic,copy) NSDate *day;
@property (readonly) BOOL hasAllDayEvents;

- (void)addEvent:(MAEvent *)event;
- (void)resetCachedData;

@end

@interface MADayGridView : UIView {
	UIColor *_textColor;
	UIFont *_textFont;
	__unsafe_unretained MADayView *_dayView;
	CGFloat _lineX;
	CGFloat _lineY[25], _dashedLineY[25];
	CGRect _textRect[25];
}

- (BOOL)timeIs24HourFormat;
- (void)addEvent:(MAEvent *)event;

@property (nonatomic, unsafe_unretained) MADayView *dayView;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (readonly) CGFloat lineX;

@end

@interface MADayView (PrivateMethods)
- (void)setupCustomInitialisation;
- (void)changeDay:(UIButton *)sender;
- (NSDate *)nextDayFromDate:(NSDate *)date;
- (NSDate *)previousDayFromDate:(NSDate *)date;
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;

@property (readonly) UIImageView *topBackground;
@property (readonly) UIButton *leftArrow;
@property (readonly) UIButton *rightArrow;
@property (readonly) UILabel *dateLabel;
@property (readonly) UIScrollView *scrollView;
@property (readonly) MA_AllDayGridView *allDayGridView;
@property (readonly) MADayGridView *gridView;
@property (readonly) UIFont *regularFont;
@property (readonly) UIFont *boldFont;
@property (readonly) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (readonly) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (readonly) NSString *titleText;
@end

@implementation MADayView

@synthesize autoScrollToFirstEvent=_autoScrollToFirstEvent;
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
	self.day = [NSDate date];
	
	[self addSubview:self.topBackground];
	[self addSubview:self.leftArrow];
	[self addSubview:self.rightArrow];
	[self addSubview:self.dateLabel];
	
	[self addSubview:self.scrollView];
	
	[self.scrollView addSubview:self.allDayGridView];
	[self.scrollView addSubview:self.gridView];
	
	[self.gridView addGestureRecognizer:self.swipeLeftRecognizer];
	[self.gridView addGestureRecognizer:self.swipeRightRecognizer];
}

- (void)layoutSubviews {
	self.topBackground.frame = CGRectMake(CGRectGetMinX(self.bounds),
										  CGRectGetMinY(self.bounds),
										  CGRectGetWidth(self.bounds), TOP_BACKGROUND_HEIGHT + 10);
	self.leftArrow.frame = CGRectMake(CGRectGetMinX(self.topBackground.bounds),
									  (int) (CGRectGetHeight(self.topBackground.bounds) - ARROW_HEIGHT) / 2,
									  ARROW_WIDTH, ARROW_HEIGHT);
	self.rightArrow.frame = CGRectMake(CGRectGetWidth(self.topBackground.bounds) - ARROW_WIDTH,
									   (int) (CGRectGetHeight(self.topBackground.bounds) - ARROW_HEIGHT) / 2,
									   ARROW_WIDTH, ARROW_HEIGHT);
	self.dateLabel.frame = CGRectMake(CGRectGetMaxX(self.leftArrow.bounds),
									  (int) (CGRectGetHeight(self.topBackground.bounds) - ARROW_HEIGHT) / 2,
									  CGRectGetWidth(self.topBackground.bounds) - CGRectGetWidth(self.leftArrow.bounds) - CGRectGetWidth(self.rightArrow.bounds),
									  ARROW_HEIGHT);
	
	self.allDayGridView.frame = CGRectMake(0, 0, // Top left corner of the scroll view
										   CGRectGetWidth(self.bounds),
										   ALL_DAY_VIEW_EMPTY_SPACE);
	self.gridView.frame = CGRectMake(CGRectGetMinX(self.allDayGridView.bounds),
									 CGRectGetMaxY(self.allDayGridView.bounds),
									 CGRectGetWidth(self.bounds),
									 [@"FOO" sizeWithFont:self.boldFont].height * SPACE_BETWEEN_HOUR_LABELS * HOURS_IN_DAY);
	
	self.scrollView.frame = CGRectMake(CGRectGetMinX(self.bounds),
									   CGRectGetMaxY(self.topBackground.bounds),
									   CGRectGetWidth(self.bounds),
									   CGRectGetHeight(self.bounds) - CGRectGetHeight(self.topBackground.bounds));
	self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds),
											 CGRectGetHeight(self.allDayGridView.bounds) + CGRectGetHeight(self.gridView.bounds));
	
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
		[_leftArrow addTarget:self action:@selector(changeDay:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _leftArrow;
}

- (UIButton *)rightArrow {
	if (!_rightArrow) {
		_rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		_rightArrow.tag = ARROW_RIGHT;
		[_rightArrow setImage:[UIImage imageNamed:RIGHT_ARROW_IMAGE] forState:0];
		[_rightArrow addTarget:self action:@selector(changeDay:) forControlEvents:UIControlEventTouchUpInside];
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

- (MA_AllDayGridView *)allDayGridView {
	if (!_allDayGridView) {
		_allDayGridView = [[MA_AllDayGridView alloc] init];
		_allDayGridView.backgroundColor = [UIColor whiteColor];
		_allDayGridView.dayView = self;
		_allDayGridView.textFont = self.boldFont;
		_allDayGridView.eventHeight = [@"FOO" sizeWithFont:self.regularFont].height * 2.f;
	}
	return _allDayGridView;
}

- (MADayGridView *)gridView {
	if (!_gridView){
		_gridView = [[MADayGridView alloc] init];
		_gridView.backgroundColor = [UIColor whiteColor];
		_gridView.textFont = self.boldFont;
		_gridView.textColor = [UIColor blackColor];
		_gridView.dayView = self;
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

- (void)setDataSource:(id <MADayViewDataSource>)dataSource {
	_dataSource = dataSource;
	[self reloadData];
}

- (id <MADayViewDataSource>)dataSource {
	return _dataSource;
}

- (void)setDay:(NSDate *)date {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	_day = [CURRENT_CALENDAR dateFromComponents:components];
	
	self.allDayGridView.day = _day;
	self.dateLabel.text = [self titleText];
	
	[self reloadData];
}

- (NSDate *)day {
	NSDate *date = [_day copy];
	return date;
}

- (void)reloadData {
	for (id view in self.allDayGridView.subviews) {
		if ([NSStringFromClass([view class])isEqualToString:@"MADayEventView"]) {
			[view removeFromSuperview];
		}
	}
	
	for (id view in self.gridView.subviews) {
		if ([NSStringFromClass([view class])isEqualToString:@"MADayEventView"]) {
			[view removeFromSuperview];
		}
	}
	
	[self.allDayGridView resetCachedData];
	
	NSArray *events = [self.dataSource dayView:self eventsForDate:self.day];
	
	for (id e in events) {
		MAEvent *event = e;
		event.displayDate = self.day;
	}
	
	for (id e in [events sortedArrayUsingFunction:MAEvent_sortByStartTime context:NULL]) {
		MAEvent *event = e;
		event.displayDate = self.day;
		
		if (event.allDay) {
			[self.allDayGridView addEvent:event];
		} else {
			[self.gridView addEvent:event];
		}
	}
}

- (void)changeDay:(UIButton *)sender {
	if (ARROW_LEFT == sender.tag) {
		self.day = [self previousDayFromDate:_day];
	} else if (ARROW_RIGHT == sender.tag) {
		self.day = [self nextDayFromDate:_day];
	}
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		[self changeDay:self.rightArrow];
	} else  if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
		[self changeDay:self.leftArrow];
	}
}

- (NSDate *)nextDayFromDate:(NSDate *)date {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
	[components setDay:[components day] + 1];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *)previousDayFromDate:(NSDate *)date {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
	[components setDay:[components day] - 1];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSString *)titleText {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:_day];
	
	NSArray *weekdaySymbols = [formatter shortWeekdaySymbols];
	
	return [NSString stringWithFormat:@"%@ %@",
			[weekdaySymbols objectAtIndex:[components weekday] - 1], [formatter stringFromDate:_day]];
}

@end

static const CGFloat kAlpha        = 0.8;
static const CGFloat kCornerRadius = 10.0;
static const CGFloat kCorner       = 5.0;

@implementation MADayEventView

@synthesize textColor=_textColor;
@synthesize textFont=_textFont;
@synthesize title=_title;
@synthesize dayView=_dayView;
@synthesize event=_event;


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
	twoFingerTapIsPossible = NO;
	multipleTouches = NO;
	delegate = self;
	
	self.alpha = kAlpha;
	CALayer *layer = [self layer];
	layer.masksToBounds = YES;
	[layer setCornerRadius:kCornerRadius];
}

- (void)layoutSubviews {
	_textRect = CGRectMake((int) (CGRectGetMinX(self.bounds) + kCorner),
						   (int) (CGRectGetMinY(self.bounds) + kCorner),
						   (int) (CGRectGetWidth(self.bounds) - 2*kCorner),
						   (int) (CGRectGetHeight(self.bounds) - 2*kCorner));
	
	CGSize sizeNeeded = [self.title sizeWithFont:self.textFont];
	
	if (_textRect.size.height > sizeNeeded.height) {
		_textRect.origin.y = (int) ((_textRect.size.height - sizeNeeded.height) / 2 + kCorner);
	}
}

- (void)drawRect:(CGRect)rect {
	[self.textColor set];
	
	[self.title drawInRect:_textRect
				  withFont:self.textFont
			 lineBreakMode:UILineBreakModeTailTruncation
				 alignment:UITextAlignmentLeft];
}

- (void)tapDetectingView:(TapDetectingView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
	if ([self.dayView.delegate respondsToSelector:@selector(dayView:eventTapped:)]) {
        [self.dayView.delegate dayView:self.dayView eventTapped:self.event];
	}
}

@end

@implementation MA_AllDayGridView

@synthesize dayView=_dayView;
@synthesize eventHeight=_eventHeight;
@synthesize textFont=_textFont;

- (BOOL)hasAllDayEvents {
	for (id view in self.subviews) {
		if ([NSStringFromClass([view class])isEqualToString:@"MADayEventView"]) {
			return YES;
		}
	}
	return NO;
}

- (void)resetCachedData {
	_eventCount = 0;
}

- (void)setDay:(NSDate *)day {
	[self resetCachedData];
	
	_day = [day copy];
	
	[self setNeedsLayout];
	[self.dayView.gridView setNeedsLayout];
}

- (NSDate *)day {
	return _day;
}

- (void)layoutSubviews {	
	self.frame = CGRectMake(self.frame.origin.x,
							self.frame.origin.y,
							self.frame.size.width,
							ALL_DAY_VIEW_EMPTY_SPACE + (ALL_DAY_VIEW_EMPTY_SPACE + self.eventHeight) * _eventCount);
	
	self.dayView.gridView.frame =  CGRectMake(self.dayView.gridView.frame.origin.x, self.frame.size.height,
											  self.dayView.gridView.frame.size.width, self.dayView.gridView.frame.size.height);
	
	self.dayView.scrollView.contentSize = CGSizeMake(self.dayView.scrollView.contentSize.width,
													 CGRectGetHeight(self.bounds) + CGRectGetHeight(self.dayView.gridView.bounds));
	
	for (id view in self.subviews) {
		if ([NSStringFromClass([view class])isEqualToString:@"MADayEventView"]) {
			MADayEventView *ev = view;
			
			CGFloat x = (int)self.dayView.gridView.lineX,
					y = (int)ev.frame.origin.y,
					w = (int)((self.frame.size.width - self.dayView.gridView.lineX) * 0.99),
					h = (int)ev.frame.size.height;
			
			ev.frame = CGRectMake(x, y, w, h);
			[ev setNeedsDisplay];
		}
	}
}

- (void)addEvent:(MAEvent *)event {
	MADayEventView *eventView = [[MADayEventView alloc] initWithFrame: CGRectMake(0, ALL_DAY_VIEW_EMPTY_SPACE + (ALL_DAY_VIEW_EMPTY_SPACE + self.eventHeight) * _eventCount,
																				  self.bounds.size.width, self.eventHeight)];
	eventView.dayView = self.dayView;
	eventView.event = event;
	eventView.backgroundColor = event.backgroundColor;
	eventView.title = event.title;
	eventView.textFont = self.textFont;
	eventView.textColor = event.textColor;
	
	[self addSubview:eventView];
	
	_eventCount++;
	
	[self setNeedsLayout];
	[self.dayView.gridView setNeedsLayout];
}

@end

static NSString const * const HOURS_AM_PM[] = {
	@" 12 AM", @" 1 AM", @" 2 AM", @" 3 AM", @" 4 AM", @" 5 AM", @" 6 AM", @" 7 AM", @" 8 AM", @" 9 AM", @" 10 AM", @" 11 AM",
	@" Noon", @" 1 PM", @" 2 PM", @" 3 PM", @" 4 PM", @" 5 PM", @" 6 PM", @" 7 PM", @" 8 PM", @" 9 PM", @" 10 PM", @" 11 PM", @" 12 PM"
};

static NSString const * const HOURS_24[] = {
	@" 0:00", @" 1:00", @" 2:00", @" 3:00", @" 4:00", @" 5:00", @" 6:00", @" 7:00", @" 8:00", @" 9:00", @" 10:00", @" 11:00",
	@" 12:00", @" 13:00", @" 14:00", @" 15:00", @" 16:00", @" 17:00", @" 18:00", @" 19:00", @" 20:00", @" 21:00", @" 22:00", @" 23:00", @" 0:00"
};

@implementation MADayGridView

@synthesize dayView=_dayView;
@synthesize textColor=_textColor;
@synthesize textFont=_textFont;

- (CGFloat)lineX
{
	return _lineX;
}

- (void)addEvent:(MAEvent *)event {
	MADayEventView *eventView = [[MADayEventView alloc] initWithFrame:CGRectZero];
	eventView.dayView = self.dayView;
	eventView.event = event;
	eventView.backgroundColor = event.backgroundColor;
	eventView.title = event.title;
	eventView.textFont = self.dayView.boldFont;
	eventView.textColor = event.textColor;
	
	[self addSubview:eventView];
	
	[self setNeedsLayout];
}

- (BOOL)timeIs24HourFormat {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterNoStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [formatter stringFromDate:[NSDate date]];
	NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
	NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
	BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;
	return is24Hour;
}

- (void)layoutSubviews {
	CGFloat maxTextWidth = 0, totalTextHeight = 0;
	CGSize hourSize[25];
	
	const NSString *const *HOURS = ([self timeIs24HourFormat] ? HOURS_24 : HOURS_AM_PM);
	register unsigned int i;
	
	for (i=0; i < HOURS_IN_DAY; i++) {
		hourSize[i] = [HOURS[i] sizeWithFont:self.textFont];
		totalTextHeight += hourSize[i].height;
		
		if (hourSize[i].width > maxTextWidth) {
			maxTextWidth = hourSize[i].width;
		}
	}
	
	CGFloat y;
	const CGFloat spaceBetweenHours = (self.bounds.size.height - totalTextHeight) / (HOURS_IN_DAY - 1);
	CGFloat rowY = 0;
	
	for (i=0; i < HOURS_IN_DAY; i++) {
		_textRect[i] = CGRectMake(CGRectGetMinX(self.bounds),
								  rowY,
								  maxTextWidth,
								  hourSize[i].height);
		
		y = rowY + ((CGRectGetMaxY(_textRect[i]) - CGRectGetMinY(_textRect[i])) / 2.f);
		_lineY[i] = y;
		_dashedLineY[i] = CGRectGetMaxY(_textRect[i]) + (spaceBetweenHours / 2.f);
		
		rowY += hourSize[i].height + spaceBetweenHours;
	}
	
	_lineX = maxTextWidth + (maxTextWidth * 0.3);
	
	NSArray *subviews = self.subviews;
	int max = [subviews count];
	MADayEventView *curEv = nil, *prevEv = nil, *firstEvent = nil;
	const CGFloat spacePerMinute = (_lineY[1] - _lineY[0]) / 60.f;
	
	for (i=0; i < max; i++) {
		if (![NSStringFromClass([[subviews objectAtIndex:i] class])isEqualToString:@"MADayEventView"]) {
			continue;
		}
		
		prevEv = curEv;
		curEv = [subviews objectAtIndex:i];
						
		curEv.frame = CGRectMake((int) _lineX,
								 (int) (spacePerMinute * [curEv.event minutesSinceMidnight] + _lineY[0]),
								 (int) (self.bounds.size.width - _lineX),
								 (int) (spacePerMinute * [curEv.event durationInMinutes]));
		
		/*
		 * Layout intersecting events to two columns.
		 */
		if (CGRectIntersectsRect(curEv.frame, prevEv.frame))
		{
			prevEv.frame = CGRectMake((int) (prevEv.frame.origin.x),
									  (int) (prevEv.frame.origin.y),
									  (int) (prevEv.frame.size.width / 2.f),
									  (int) (prevEv.frame.size.height));
				
			curEv.frame = CGRectMake((int) (curEv.frame.origin.x + (curEv.frame.size.width / 2.f)),
									 (int) (curEv.frame.origin.y),
									 (int) (curEv.frame.size.width / 2.f),
									 (int) (curEv.frame.size.height));
		}
		
		[curEv setNeedsDisplay];
		
		if (!firstEvent || curEv.frame.origin.y < firstEvent.frame.origin.y) {
			firstEvent = curEv;
		}
	}
	
	if (self.dayView.autoScrollToFirstEvent) {
		CGPoint autoScrollPoint;
		
		if (!firstEvent || self.dayView.allDayGridView.hasAllDayEvents) {
			autoScrollPoint = CGPointMake(0, 0);
		} else {
			int minutesSinceLastHour = ([firstEvent.event minutesSinceMidnight] % 60);
			CGFloat padding = minutesSinceLastHour * spacePerMinute + 7.5;
			
			autoScrollPoint = CGPointMake(0, firstEvent.frame.origin.y - padding);
			CGFloat maxY = self.dayView.scrollView.contentSize.height - CGRectGetHeight(self.dayView.scrollView.bounds);
			
			if (autoScrollPoint.y > maxY) {
				autoScrollPoint.y = maxY;
			}
		}
		
		[self.dayView.scrollView setContentOffset:autoScrollPoint animated:YES];
	}
}

- (void)drawRect:(CGRect)rect {
	const NSString *const *HOURS = ([self timeIs24HourFormat] ? HOURS_24 : HOURS_AM_PM);
	register unsigned int i;
	
	const CGContextRef c = UIGraphicsGetCurrentContext();

	CGContextSetStrokeColorWithColor(c, [[UIColor lightGrayColor] CGColor]);
	CGContextSetLineWidth(c, 0.5);
	CGContextBeginPath(c);
	
	for (i=0; i < HOURS_IN_DAY; i++) {
		[HOURS[i] drawInRect: _textRect[i]
					withFont:self.textFont
			   lineBreakMode:UILineBreakModeTailTruncation
				   alignment:UITextAlignmentRight];
		
		CGContextMoveToPoint(c, _lineX, _lineY[i]);
		CGContextAddLineToPoint(c, self.bounds.size.width, _lineY[i]);
	}
	
	CGContextClosePath(c);
	CGContextSaveGState(c);
	CGContextDrawPath(c, kCGPathFillStroke);
	CGContextRestoreGState(c);
	
	CGContextSetLineWidth(c, 0.5);
	CGFloat dash1[] = {2.0, 1.0};
	CGContextSetLineDash(c, 0.0, dash1, 2);
	
	CGContextBeginPath(c);

	for (i=0; i < (HOURS_IN_DAY - 1); i++) {		
		CGContextMoveToPoint(c, _lineX, _dashedLineY[i]);
		CGContextAddLineToPoint(c, self.bounds.size.width, _dashedLineY[i]);
	}
	
	CGContextClosePath(c);
	CGContextSaveGState(c);
	CGContextDrawPath(c, kCGPathFillStroke);
	CGContextRestoreGState(c);
}

@end
