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

#import "MAEventKitDataSource.h"

#import "MAEvent.h"
#import <EventKit/EventKit.h>

#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface MAEventKitDataSource(PrivateMethods)

- (NSDate *)nextDayForDate:(NSDate *)date;
- (NSArray *)eventKitEventsForDate:(NSDate *)date;
- (NSArray *)eventKitEventsToMAEvents:(NSArray *)eventKitEvents;

@property (readonly) EKEventStore *eventStore;

@end

@implementation MAEventKitDataSource

/*
 * =======================================
 * MADayViewDataSource
 * =======================================
 */

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)date
{
    return [self eventKitEventsToMAEvents:[self eventKitEventsForDate:date]];
}

/*
 * =======================================
 * MAWeekViewDataSource
 * =======================================
 */

- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)date
{
    return [self eventKitEventsToMAEvents:[self eventKitEventsForDate:date]];
}

/*
 * =======================================
 * Properties
 * =======================================
 */

- (EKEventStore *)eventStore
{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

/*
 * =======================================
 * Private
 * =======================================
 */

- (NSDate *)nextDayForDate:(NSDate *)date
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    
    return [CURRENT_CALENDAR dateByAddingComponents:components toDate:date options:0];
}

- (NSArray *)eventKitEventsForDate:(NSDate *)startDate
{
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:[self nextDayForDate:startDate]
                                                                    calendars:nil];
    
    NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    return events;
}

- (NSArray *)eventKitEventsToMAEvents:(NSArray *)eventKitEvents
{
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for (EKEvent *event in eventKitEvents) {
        MAEvent *maEvent = [[MAEvent alloc] init];
        maEvent.title  = event.title;
        maEvent.start  = event.startDate;
        maEvent.end    = event.endDate;
        maEvent.allDay = event.allDay;
        
        maEvent.backgroundColor = [UIColor colorWithCGColor:event.calendar.CGColor];
        maEvent.textColor       = [UIColor whiteColor];
        
        [events addObject:maEvent];
    }
    return events;
}

@end