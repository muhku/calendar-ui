//
//  MAEventGridView.h
//  CalendarUI
//
//  Created by Evan Rosenfeld on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAWeekView.h"

@interface MAEventGridView : UIView {
	MAWeekView *_weekView;
	int _eventsInOffset[7];
	unsigned int _maxEvents;
	NSDate *_week;
	UIFont *_textFont;
}

@property (nonatomic, strong) MAWeekView *weekView;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic,copy) NSDate *week;

- (void)addEventToOffset:(unsigned int)offset event:(MAEvent *)event;
- (void)resetCachedData;

@end