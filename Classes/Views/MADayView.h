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

@class MA_AllDayGridView;
@class MADayHourView;
@class MADayGridView;
@class MAEvent;

@protocol MADayViewDataSource, MADayViewDelegate;

@interface MADayView : UIView {
	UIImageView *_topBackground;
	UIButton *_leftArrow, *_rightArrow;
	UILabel *_dateLabel;
	
	UIScrollView *_scrollView;
	MA_AllDayGridView *_allDayGridView;
	MADayHourView *_hourView;
	MADayGridView *_gridView;	
	
	BOOL _autoScrollToFirstEvent;
	unsigned int _labelFontSize;
	UIFont *_regularFont;
	UIFont *_boldFont;
	
	NSDate *_day;
	
	UISwipeGestureRecognizer *_swipeLeftRecognizer, *_swipeRightRecognizer;
	
	id<MADayViewDataSource> __unsafe_unretained _dataSource;
	id<MADayViewDelegate> __unsafe_unretained _delegate;
}

@property (nonatomic,assign) BOOL autoScrollToFirstEvent;
@property (readwrite,assign) unsigned int labelFontSize;
@property (nonatomic,copy) NSDate *day;
@property (nonatomic,unsafe_unretained) IBOutlet id<MADayViewDataSource> dataSource;
@property (nonatomic,unsafe_unretained) IBOutlet id<MADayViewDelegate> delegate;

- (void)reloadData;

@end

@protocol MADayViewDataSource <NSObject>

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)date;

@end

@protocol MADayViewDelegate <NSObject>

@optional
- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event;

@end
