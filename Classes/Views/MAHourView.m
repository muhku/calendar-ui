//
//  MAHourView.m
//  CalendarUI
//
//  Created by Evan Rosenfeld on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "MAGridView.h"
#import "MAHourView.h"

@implementation MAHourView

@synthesize weekView=_weekView;
@synthesize textColor=_textColor;
@synthesize textFont=_textFont;

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

- (void)drawRect:(CGRect)rect {
	register unsigned int i;
	const CGFloat cellHeight = self.weekView.gridView.cellHeight;
	const NSString *const *HOURS = ([self timeIs24HourFormat] ? HOURS_24 : HOURS_AM_PM);
	
	[self.textColor set];
	
	for (i=1; i < HOURS_IN_DAY; i++) {
		CGSize sizeNecessary = [HOURS[i] sizeWithFont:self.textFont];
		CGRect rect = CGRectMake(CGRectGetMinX(self.bounds),
								 (cellHeight * i) - (sizeNecessary.height / 2.f),
								 sizeNecessary.width,
								 sizeNecessary.height);
		
		[HOURS[i] drawInRect: rect
                    withFont:self.textFont
               lineBreakMode:UILineBreakModeTailTruncation
                   alignment:UITextAlignmentLeft]; 
	}
}


@end
