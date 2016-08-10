//
// Created by 步亦凡 on 2016/4/8.
//

#ifndef CALENDAR_CALENDARCORE_H
#define CALENDAR_CALENDARCORE_H
#include <time.h>
//c语言实现
//为什么用c
//为了通用性，将日期操作以及月历操作全部使用c函数，有利于移植到android系统
//因为ios和android都支持c函数

/*
blf: 使用ios中的一些基础数据结构，android中需要移植过来
     ios的话，请将下面 #define ANDROID_NDK_IMP这句代码注释掉
*/
#define ANDROID_NDK_IMP
#ifdef ANDROID_NDK_IMP
typedef struct _CGPoint {
    float x;
    float y;
}CGPoint;

/* Sizes. */
typedef struct _CGSize {
    float width;
    float height;
}CGSize;

/* Rectangles. */
typedef struct _CGRect {
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
long date_get_time_t(const SDate* d);

void date_get_next_month(SDate* date, int delta);
void date_get_prev_month(SDate* date, int delta);

int  date_get_week(const SDate* date);
int  date_get_month_of_day(int year, int month);

int  date_get_leap(int year);
int  date_get_month_count_from_year_range(int startYear,int endYear);
void date_map_index_to_year_month(SDate* to,int startYear,int idx);

typedef struct _calendar
{
    CGSize  size; //大小尺寸
    SDate   date; //该月历代表的年月

    float   yearMonthSectionHeight; //年月区块的高度
    float   weekSectionHegiht;      //星期区块的高度

    //blf:计算出来的结果，第三方不要设置这些变量
    float daySectionHeight;  //已知size.height以及yearMonthSectionHeight和weekSectionHegiht，就能计算出日期区块的高度

    int   dayBeginIdx; //1号的偏移索引，具体描述参考实现代码
    int   dayCount;    //当前月份一共多少天

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

#endif //CALENDAR_CALENDARCORE_H
