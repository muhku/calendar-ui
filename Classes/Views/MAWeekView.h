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

#import <UIKit/UIKit.h>

@class MAGridView;
@class MAHourView;
@class MAWeekdayBarView;
@class MAAllDayEventView;
@class MAEvent;

@protocol MAWeekViewDataSource, MAWeekViewDelegate;

@interface MAWeekView : UIView {
	UIImageView *_topBackground;
	UIButton *_leftArrow, *_rightArrow;
	UILabel *_dateLabel;
	
	MAAllDayEventView *_allDayEventView;
	UIScrollView *_scrollView;
	MAGridView *_gridView;
	MAHourView *_hourView;
	MAWeekdayBarView *_weekdayBarView;
	
	unsigned int _labelFontSize;
	UIFont *_regularFont;
	UIFont *_boldFont;
	
	NSDate *_week;
	
	UISwipeGestureRecognizer *_swipeLeftRecognizer, *_swipeRightRecognizer;
	
	id<MAWeekViewDataSource> _dataSource;
	id<MAWeekViewDelegate> __unsafe_unretained _delegate;
}

@property (readwrite,assign) BOOL eventDraggingEnabled;
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
- (void)weekView:(MAWeekView *)weekView eventDragged:(MAEvent *)event;
- (BOOL)weekView:(MAWeekView *)weekView eventDraggingEnabled:(MAEvent *)event;

@end