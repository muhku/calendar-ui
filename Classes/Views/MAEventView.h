//
//  MAEventView.h
//  CalendarUI
//
//  Created by Evan Rosenfeld on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingView.h"
#import "MAEvent.h"
#import "MAWeekView.h"

@interface MAEventView : TapDetectingView <TapDetectingViewDelegate> {
	NSString *_title;
	UIColor *_textColor;
	UIFont *_textFont;
	MAWeekView *_weekView;
	MAEvent *_event;
	CGRect _textRect;
	size_t _xOffset;
	size_t _yOffset;
}

- (void)setupCustomInitialisation;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) MAWeekView *weekView;
@property (nonatomic, strong) MAEvent *event;
@property (nonatomic, assign) size_t xOffset;
@property (nonatomic, assign) size_t yOffset;

@end