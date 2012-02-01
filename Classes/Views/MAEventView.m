//
//  MAEventView.m
//  CalendarUI
//
//  Created by Evan Rosenfeld on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAEventView.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kAlpha        = 0.8;
static const CGFloat kCornerRadius = 10.0;
static const CGFloat kCorner       = 5.0;

@implementation MAEventView

@synthesize textColor=_textColor;
@synthesize textFont=_textFont;
@synthesize title=_title;
@synthesize weekView=_weekView;
@synthesize event=_event;
@synthesize xOffset=_xOffset;
@synthesize yOffset=_yOffset;


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
	_textRect = CGRectMake(CGRectGetMinX(self.bounds) + kCorner,
						   CGRectGetMinY(self.bounds) + kCorner,
						   CGRectGetWidth(self.bounds) - 2*kCorner,
						   CGRectGetHeight(self.bounds) - 2*kCorner);
}

- (void)drawRect:(CGRect)rect {
	[self.textColor set];
	
	[self.title drawInRect:_textRect
                  withFont:self.textFont
             lineBreakMode:UILineBreakModeTailTruncation
                 alignment:UITextAlignmentLeft];
}

- (void)tapDetectingView:(TapDetectingView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
	if ([self.weekView.delegate respondsToSelector:@selector(weekView:eventTapped:)]) {
        [self.weekView.delegate weekView:self.weekView eventTapped:self.event];
	}
}

@end