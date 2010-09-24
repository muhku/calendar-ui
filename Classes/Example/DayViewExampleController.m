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

#import "DayViewExampleController.h"
#import "MAEvent.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface DayViewExampleController(PrivateMethods)
@property (readonly) MAEvent *event;
@end

@implementation DayViewExampleController

/* Implementation for the MADayViewDataSource protocol */

static int counter = 5;

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)startDate {
	counter--;
	
	unsigned int r = arc4random() % 24;
	unsigned int r2 = arc4random() % 10;
	
	NSArray *arr;
	
	if (counter < 0) {
		arr = [NSArray arrayWithObjects: self.event, nil];
	} else {
		arr = (r <= 5 ? [NSArray arrayWithObjects: self.event, self.event, nil] : [NSArray arrayWithObjects: self.event, self.event, self.event, nil]);
		
		((MAEvent *) [arr objectAtIndex:1]).title = @"All-day events test";
		((MAEvent *) [arr objectAtIndex:1]).allDay = YES;
		
		if (r > 5) {
			((MAEvent *) [arr objectAtIndex:2]).title = @"Foo!";
			((MAEvent *) [arr objectAtIndex:2]).backgroundColor = [UIColor brownColor];
			((MAEvent *) [arr objectAtIndex:2]).allDay = YES;
		}
	}
	
	((MAEvent *) [arr objectAtIndex:0]).title = @"Event lorem ipsum es dolor test. This a long text, which should clip the event view bounds.";
	
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:startDate];
	[components setHour:r];
	[components setMinute:0];
	[components setSecond:0];
	
	((MAEvent *) [arr objectAtIndex:0]).start = [CURRENT_CALENDAR dateFromComponents:components];
	
	[components setHour:r+1];
	[components setMinute:0];
	
	((MAEvent *) [arr objectAtIndex:0]).end = [CURRENT_CALENDAR dateFromComponents:components];
	
	if (r2 > 5) {
		((MAEvent *) [arr objectAtIndex:0]).backgroundColor = [UIColor brownColor];
	}
	
	return arr;
}

- (MAEvent *)event {
	static int counter;
	
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	
	[dict setObject:[NSString stringWithFormat:@"number %i", counter++] forKey:@"test"];
	
	MAEvent *event = [[MAEvent alloc] init];
	event.backgroundColor = [UIColor purpleColor];
	event.textColor = [UIColor whiteColor];
	event.allDay = NO;
	event.userInfo = dict;
	return [event autorelease];
}

/* Implementation for the MADayViewDelegate protocol */

- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
	NSString *eventInfo = [NSString stringWithFormat:@"Hour %i. Userinfo: %@", [components hour], [event.userInfo objectForKey:@"test"]];
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:event.title
													 message:eventInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
