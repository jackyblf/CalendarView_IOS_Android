//
//  CalendarController.h
//  Calendar
//
//  Created by jackyBu on 16-4-29.
//  Copyright (c) 2016年 blf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarView.h"

@protocol CalendarDelegate <NSObject>

-(int)    calcCalendarCount;

-(SDate)  mapIndexToYearMonth : (int) index;
-(int)    mapYearMonthToIndex : (SDate) date;

-(void)   showCalendarAtYearMonth : (SDate) date;

-(BOOL)   isInSelectedDateRange : (SDate) date;
-(void)   setSelectedDateRangeStart : (SDate) start end : (SDate) end;
-(void)   setEndSelectedDate : (SDate) end;
-(void)   repaintCalendarViews;

-(void)   updateHitCounter;
-(int)    getHitCounter;
@end
