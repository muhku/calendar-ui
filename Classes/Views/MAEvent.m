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

#import "MAEvent.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

static const unsigned int MINUTES_IN_HOUR                = 60;
static const unsigned int DAY_IN_MINUTES                 = 1440;
static const unsigned int MIN_EVENT_DURATION_IN_MINUTES  = 30;

NSInteger MAEvent_sortByStartTime(id ev1, id ev2, void *keyForSorting) {
	MAEvent *event1 = (MAEvent *)ev1;
	MAEvent *event2 = (MAEvent *)ev2;
				   
	int v1 = [event1 minutesSinceMidnight];
	int v2 = [event2 minutesSinceMidnight];
	
	if (v1 < v2) {
		return NSOrderedAscending;
	} else if (v1 > v2) {
		return NSOrderedDescending;
	} else {
		/* Event start time is the same, compare by duration.
		 */
		int d1 = [event1 durationInMinutes];
		int d2 = [event2 durationInMinutes];
		
		if (d1 < d2) {
			/*
			 * Event with a shorter duration is after an event
			 * with a longer duration. Looks nicer when drawing the events.
			 */
			return NSOrderedDescending;
		} else if (d1 > d2) {
			return NSOrderedAscending;
		} else {
			/*
			 * The last resort: compare by title.
			 */
			return [event1.title compare:event2.title];
		}
	}
}

@implementation MAEvent

@synthesize title=_title;
@synthesize start=_start;
@synthesize end=_end;
@synthesize displayDate=_displayDate;
@synthesize allDay=_allDay;
@synthesize backgroundColor=_backgroundColor;
@synthesize textColor=_textColor;
@synthesize userInfo=_userInfo;

#define DATE_CMP(X, Y) ([X year] == [Y year] && [X month] == [Y month] && [X day] == [Y day])

- (unsigned int)minutesSinceMidnight {
	unsigned int fromMidnight = 0;
	
	NSDateComponents *displayComponents = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:_displayDate];
	NSDateComponents *startComponents = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:_start];
	
	if (DATE_CMP(startComponents, displayComponents)) {
		fromMidnight = [startComponents hour] * MINUTES_IN_HOUR + [startComponents minute];
	}
	
	/* The minimum duration for an event is 30 minutes because of the grid size.
	 * If the event starts, say, 23:59, adjust the start time to 23:30.
	 */
	int d = DAY_IN_MINUTES - MIN_EVENT_DURATION_IN_MINUTES;
	if (fromMidnight > d) {
		fromMidnight = d;
	}
	return fromMidnight;
}

- (unsigned int)durationInMinutes {
	unsigned int duration = 0;
	
	NSDateComponents *displayComponents = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:_displayDate];
	NSDateComponents *startComponents = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:_start];
	NSDateComponents *endComponents = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:_end];
	
	if (DATE_CMP(endComponents, displayComponents)) {
		if (DATE_CMP(startComponents, displayComponents)) {
			duration = (int) (([_end timeIntervalSince1970] - [_start timeIntervalSince1970]) / (double) MINUTES_IN_HOUR);
		} else {
			duration = [endComponents hour] * MINUTES_IN_HOUR + [endComponents minute];
		}
		
		// The minimum duration is 30 minutes because of the grid size.
		if (duration < MIN_EVENT_DURATION_IN_MINUTES)
			duration = MIN_EVENT_DURATION_IN_MINUTES;
	} else {
		// No need to check the minimum duration here because minutesSinceMidnight adjusts the start time.
		duration = DAY_IN_MINUTES - [self minutesSinceMidnight];
	}
	return duration;
}

#undef DATE_CMP


@end