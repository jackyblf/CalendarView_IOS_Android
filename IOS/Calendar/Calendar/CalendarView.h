//
//  CalendarView.h
//  Calendar
//
//  Created by jackyBu on 16-4-29.
//  Copyright (c) 2016年 blf. All rights reserved.
//

#import <UIKit/UIKit.h>

//c语言实现
//为什么用c
//为了通用性，将日期操作以及月历操作全部使用c函数，有利于移植到android系统
//因为ios和android都支持c函数

#ifdef ANDROID_VERSION

struct _CGPoint {
    float x;
    float y;
}CGPoint;


/* Sizes. */
struct _CGSize {
    float width;
    float height;
}CGSize;

/* Rectangles. */
struct _CGRect {
    CGPoint origin;
    CGSize size;
}CGRect;

#endif


typedef struct _date
{
    int year;
    int month;
    int day;
} SDate;

void date_set(SDate* date,int year,int month,int day);
void date_get_now(SDate* date);
bool date_is_equal(const SDate* left,const SDate* right);
time_t date_get_time_t(const SDate* d);
void date_get_next_month(SDate* date, int delta);
void date_get_prev_month(SDate* date, int delta);
int  date_get_week(const SDate* date);
int  date_get_month_of_day(int year, int month);

int  date_get_leap(int year);
int  date_get_month_count_from_year_range(int startYear,int endYear);
void date_map_index_to_year_month(SDate* to,int startYear,int idx);


typedef struct _calendar
{
    CGRect  inset;
    CGSize  size;
    SDate   date;
    
    float   yearMonthSectionHeight;
    float   weekSectionHegiht;
    
    //blf:计算出来的结果，第三方不要设置这些变量
    float daySectionHeight;
    int   dayBeginIdx;
    int   dayCount;
    
}SCalendar;

void calendar_init(SCalendar* calendar,CGSize ownerSize,float yearMonthHeight,float weekHeight);
void calendar_set_year_month(SCalendar* calendar,int year,int month);
void calendar_get_year_month(SCalendar* calendar,int* year,int* month);
void calendar_get_year_month_section_rect(const SCalendar* calendar,CGRect* rect);
void calendar_get_week_section_rect(const SCalendar* calendar,CGRect* rect);
void calendar_get_day_section_rect(const SCalendar* calendar,CGRect* rect);
void calendar_get_week_cell_rect(const SCalendar* calendar,CGRect* rect,int idx);
void calendar_get_day_cell_rect(const SCalendar* calendar,CGRect* rect,int rowIdx,int columIdx);
void calendar_get_day_cell_rect_by_index(const SCalendar* calendar,CGRect* rect,int idx);
int  calendar_get_hitted_day_cell_index(const SCalendar* calendar, CGPoint localPt);



@interface CalendarView : UIControl
-(void) setYearMonth : (int) year month : (int) month;
@property (weak, nonatomic) id  calendarDelegate;
@end
