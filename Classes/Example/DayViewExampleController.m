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

#import "DayViewExampleController.h"
#import "MAEvent.h"
#import "MAEventKitDataSource.h"

// Uncomment the following line to use the built in calendar as a source for events:
//#define USE_EVENTKIT_DATA_SOURCE 1

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface DayViewExampleController(PrivateMethods)
@property (readonly) MAEvent *event;
@property (readonly) MAEventKitDataSource *eventKitDataSource;
@end

@implementation DayViewExampleController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidLoad {
	MADayView *dayView = (MADayView *) self.view;
	/* The default is not to autoscroll, so let's override the default here */
	dayView.autoScrollToFirstEvent = YES;
}

/* Implementation for the MADayViewDataSource protocol */

static NSDate *date = nil;

#ifdef USE_EVENTKIT_DATA_SOURCE

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)startDate {
    return [self.eventKitDataSource dayView:dayView eventsForDate:startDate];
}

#else
- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)startDate {
	date = startDate;

	NSArray *arr = [NSArray arrayWithObjects: self.event, self.event, self.event,
					self.event, self.event, self.event, self.event,  self.event, self.event, nil];
	static size_t generateAllDayEvents;
	
	generateAllDayEvents++;
	
	if (generateAllDayEvents % 4 == 0) {
		((MAEvent *) [arr objectAtIndex:0]).title = @"All-day events test";
		((MAEvent *) [arr objectAtIndex:0]).allDay = YES;
		
		((MAEvent *) [arr objectAtIndex:1]).title = @"All-day events test";
		((MAEvent *) [arr objectAtIndex:1]).allDay = YES;
	}
	return arr;
}
#endif

- (MAEvent *)event {
	static int counter;
	static BOOL flag;
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	[dict setObject:[NSString stringWithFormat:@"number %i", counter++] forKey:@"test"];
	
	unsigned int r = arc4random() % 24;
	int rr = arc4random() % 3;
	
	MAEvent *event = [[MAEvent alloc] init];
	event.backgroundColor = ((flag = !flag) ? [UIColor purpleColor] : [UIColor brownColor]);
	event.textColor = [UIColor whiteColor];
	event.allDay = NO;
	event.userInfo = dict;
	
	if (rr == 0) {
		event.title = @"Event lorem ipsum es dolor test. This a long text, which should clip the event view bounds.";
	} else if (rr == 1) {
		event.title = @"Foobar.";
	} else {
		event.title = @"Dolor test.";
	}
	
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
	[components setHour:r];
	[components setMinute:0];
	[components setSecond:0];
	
	event.start = [CURRENT_CALENDAR dateFromComponents:components];
	
	[components setHour:r+rr];
	[components setMinute:0];
	
	event.end = [CURRENT_CALENDAR dateFromComponents:components];
	
	return event;
}

- (MAEventKitDataSource *)eventKitDataSource {
    if (!_eventKitDataSource) {
        _eventKitDataSource = [[MAEventKitDataSource alloc] init];
    }
    return _eventKitDataSource;
}

/* Implementation for the MADayViewDelegate protocol */

- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
	NSString *eventInfo = [NSString stringWithFormat:@"Hour %i. Userinfo: %@", [components hour], [event.userInfo objectForKey:@"test"]];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title
													 message:eventInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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




@end
