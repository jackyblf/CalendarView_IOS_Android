//
//  CalendarView.m
//  Calendar
//
//  Created by jackyBu on 16-4-29.
//  Copyright (c) 2016年 blf. All rights reserved.
//


#import "CalendarView.h"
#import "CalendarDelegate.h"

#ifdef ANDROID
static float GetRectMaxX(CGRect rc) { return rc.origin.x + rc.size.width;  }
static float GetRectMaxY(CGRect rc) { return rc.origin.y + rc.size.height; }

static bool CGRectContainsPoint(CGRect rc, CGPoint pt)
{
    return(pt.x >= rc.origin.x) && (pt.x <= GetRectMaxX(rc)) && (pt.y >= rc.origin.y) && (pt.y <= GetRectMaxY(rc));
}
#endif

void date_set(SDate* ret,int year,int month,int day)
{
    assert(ret);
    ret->year = year;
    ret->month = month;
    ret->day = day;
    
}

void date_get_now(SDate* ret)
{
    assert(ret);
    time_t t;
	time(&t);
	struct tm* timeInfo;
	timeInfo = localtime(&t);
	ret->year  =  timeInfo->tm_year + 1900;
	ret->month =  timeInfo->tm_mon + 1;
	ret->day   =  timeInfo->tm_mday;
}

bool date_is_equal(const SDate* left,const SDate* right)
{
    assert(left&&right);
    return (left->year == right->year &&
            left->month == right->month &&
            left->day == right->day);
}


int date_get_month_count_from_year_range(int startYear,int endYear)
{
    int diff = endYear - startYear + 1;
    return diff * 12;
}

void date_map_index_to_year_month(SDate* to,int startYear,int idx)
{
    assert(to);
    
    to->year = startYear + idx / 12;
    to->month = idx % 12 + 1;
    to->day = -1;
}

int date_get_days(const SDate* date)
{
    assert(date);
    int day_table[13] = {0,31,28,31,30,31,30,31,31,30,31,30,31};
	int i = 0, total = 0;
	for(i = 0; i < date->month; i++)
		total += day_table[i];
	return total + date->day + date_get_leap(date->year);
}

time_t mymktime (unsigned int year, unsigned int mon,
                 unsigned int day, unsigned int hour,
                 unsigned int min, unsigned int sec)
{
    if (0 >= (int) (mon -= 2)) {    /* 1..12 -> 11,12,1..10 */
        mon += 12;      /* Puts Feb last since it has leap day */
        year -= 1;
    }
    
    
    return (((
              (time_t) (year/4 - year/100 + year/400 + 367*mon/12 + day) +
              year*365 - 719499
              )*24 + hour /* now have hours */
             )*60 + min /* now have minutes */
            )*60 + sec; /* finally seconds */
}

time_t date_get_time_t(const SDate* d)
{
    
    assert(d);
    return mymktime(d->year, d->month, d->day, 0, 0, 1);
    
    /*
     struct tm date;
     date.tm_year = d->year - 1900;
     date.tm_mon = d->month - 1;
     date.tm_mday = d->day;
     
     date.tm_hour = 0;
     date.tm_min =0;
     date.tm_sec =1;
     
     time_t seconds = mktime(&date);
     
     NSLog(@"time_t = %d",seconds);
     
     return seconds;
     */
    
    /*
     NSDateComponents *components = [[NSDateComponents alloc] init];
     
     [components setDay:d->day]; // Monday
     [components setMonth:d->month]; // May
     [components setYear:d->year];
     
     NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
     
     NSDate *dt = [gregorian dateFromComponents:components];
     
     return (time_t) [dt timeIntervalSince1970];
     */
}

void date_get_prev_month(SDate* date, int delta)
{
    assert(date);
	if((date->month - delta) < 1)
	{
		date->year--;
		date->month = 12 + date->month - delta;
	}
	else
		date->month = date->month - delta;
}

void date_get_next_month(SDate* date, int delta)
{
    assert(date);
	if((date->month + delta) > 12)
	{
		date->year++;
		date->month = date->month + delta - 12;
	}
	else
		date->month = date->month + delta;
}

int date_get_leap(int year)
{
    if(((year % 4 == 0) && (year % 100) != 0) || (year % 400 == 0))
		return 1;
	return 0;
}



int date_get_week(const SDate* date)
{
    assert(date);
	return ((date->year - 1 + (date->year - 1) / 4 - (date->year - 1) / 100 +
             (date->year - 1) / 400 + date_get_days(date) )% 7);
}

int date_get_month_of_day(int year, int month)
{
	switch(month)
	{
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12: return 31;
        case 4:
        case 6:
        case 9:
        case 11: return 30;
	}
    //blf:2月比较特别，要进行闰年判断
	return 28 + date_get_leap(year);
}

/*
 blf: calendar dayBeginIdx 和 dayCount图示
 
 0   1   2   3   4   5   6       week section
 ---------------------------
 |   |   |   |   |   |   | 1 |     rowIdx = 0
 ---------------------------
 ---------------------------
 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |     rowIdx = 1
 ---------------------------
 ---------------------------
 | 9 | 10| 11| 12| 13| 14| 15|     rowIdx = 2
 ---------------------------
 ---------------------------
 | 16| 17| 18| 19| 20| 21| 22|     rowIdx = 3
 ---------------------------
 ---------------------------
 | 23| 24| 24| 25| 26| 27| 28|     rowIdx = 4
 ---------------------------
 ---------------------------
 | 30| 31|   |   |   |   |   |     rowIdx = 5
 ---------------------------
 
 */

void calendar_set_year_month(SCalendar* calendar,int year,int month)
{
    assert(calendar);
    //if(calendar->date.year != year || calendar->date.month != month)
    {
        calendar->date.year = year;
        calendar->date.month = month;
        calendar->date.day = 1;
        
        //blf:
        //参靠上面图示，dayBeginIdx获得的是某个月1号相对日期区块中的索引，例如本例中1号索引为6
        //而dayCount表示当前月的天数
        //这样通过偏移与长度，我们可以很容易进行某些重要操作
        //例如在碰撞检测某个cell是否被点中时，可以跳过没有日期的cell
        //在绘图时检测某个cell是否没有值，如果没有就不用绘制
        calendar->dayBeginIdx = date_get_week(&calendar->date);
        calendar->dayCount = date_get_month_of_day(calendar->date.year, calendar->date.month);
    }
    
}

void calendar_get_year_month(SCalendar* calendar,int* year,int* month)
{
    assert(calendar);
    if(year)
        *year = calendar->date.year;
    if(month)
        *month = calendar->date.month;
}

void calendar_init(SCalendar* calendar,CGSize ownerSize,float yearMonthHeight,float weekHeight)
{
    assert(calendar && calendar);
    
    memset(calendar, 0, sizeof(SCalendar));
    
    calendar->size = ownerSize;
    calendar->yearMonthSectionHeight = yearMonthHeight;
    calendar->weekSectionHegiht = weekHeight;
    //blf:daySectionHeight是计算出来的
    calendar->daySectionHeight = ownerSize.height - yearMonthHeight - weekHeight;
    //blf:错误检测，简单期间，全部使用assert在debug时候进行中断
    assert(calendar->daySectionHeight > 0);
    
    //blf:初始化时显示本地当前的年月日
    date_get_now(&calendar->date);
    
    calendar_set_year_month(calendar, calendar->date.year, calendar->date.month);
}

void calendar_get_year_month_section_rect(const SCalendar* calendar,CGRect* rect)
{
    assert(rect);
    memset(rect,0,sizeof(CGRect));
    rect->size.width = calendar->size.width;
    rect->size.height = calendar->yearMonthSectionHeight;
}


void calendar_get_week_section_rect(const SCalendar* calendar,CGRect* rect)
{
    assert(rect);
    memset(rect,0,sizeof(CGRect));
    rect->origin.y = calendar->yearMonthSectionHeight;
    rect->size.width = calendar->size.width;
    rect->size.height = calendar->weekSectionHegiht;
}


void calendar_get_day_section_rect(const SCalendar* calendar,CGRect* rect)
{
    assert(calendar && rect);
    memset(rect,0,sizeof(CGRect));
    rect->origin.y = calendar->yearMonthSectionHeight + calendar->weekSectionHegiht;
    rect->size.width = calendar->size.width;
    rect->size.height = calendar->daySectionHeight;
}

/*
 blf:
 获取星期区块中每个索引指向的子区rect位置与尺寸
 ---------------------------
 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
 ---------------------------
 idx = 0时表示星期日
 用于绘图
 */

void calendar_get_week_cell_rect(const SCalendar* calendar,CGRect* rect,int idx)
{
    assert(calendar && rect && idx >= 0 && idx < 7);
    calendar_get_week_section_rect(calendar, rect);
    float cellWidth = rect->size.width / 7.0F;
    rect->origin.x = cellWidth * idx;
    rect->size.width = cellWidth;
}


/*
 blf:
 获取日期区块中行列索引指向的子区rect位置与尺寸
 ---------------------------
 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |     rowIdx = 0
 ---------------------------
 ---------------------------
 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |     rowIdx = 1
 ---------------------------
 ---------------------------
 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |     rowIdx = 2
 ---------------------------
 ---------------------------
 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |     rowIdx = 3
 ---------------------------
 ---------------------------
 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |     rowIdx = 4
 ---------------------------
 ---------------------------
 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |     rowIdx = 5
 ---------------------------
 
 一个月总是在28-－31天之间，由于星期要缩进，因此6行7列足够解决由于星期缩进引起的显示不全问题
 用于绘图以及碰撞检测,共计42个单元格
 
 以二维方式获取日期区块中索引指向的子区的rect位置与尺寸
 */

void calendar_get_day_cell_rect(const SCalendar* calendar,CGRect* rect,int rowIdx,int columIdx)
{
    assert(calendar && rect && rowIdx >= 0 && rowIdx < 6 && columIdx >= 0 && columIdx < 7 );
    float cellWidth = calendar->size.width / 7.0F;
    float cellHeight = calendar->daySectionHeight / 6.0F;
    rect->origin.x = cellWidth  * columIdx;
	rect->origin.y = cellHeight * rowIdx;
	rect->size.width  = cellWidth;
	rect->size.height = cellHeight;
}

/*
 blf:
 以一维方式方式获取日期区块中索引指向的子区的rect位置与尺寸
 */
void calendar_get_day_cell_rect_by_index(const SCalendar* calendar,CGRect* rect,int idx)
{
    assert(calendar && rect && idx >= 0 && idx < 42);
    int rowIdx   = (idx / 7);
	int columIdx = (idx % 7);
    calendar_get_day_cell_rect(calendar, rect, rowIdx, columIdx);
    
}

/*
 blf:
 检测touchPoint是否点击在日期区块的某一个cell中
 如果检测到有cell被点中，返回索引
 否则返回－1
 
 0   1   2   3   4   5   6       week section
 ---------------------------
 |   |   |   |   |   |   | 1 |     rowIdx = 0
 ---------------------------
 ---------------------------
 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |     rowIdx = 1
 ---------------------------
 ---------------------------
 | 9 | 10| 11| 12| 13| 14| 15|     rowIdx = 2
 ---------------------------
 ---------------------------
 | 16| 17| 18| 19| 20| 21| 22|     rowIdx = 3
 ---------------------------
 ---------------------------
 | 23| 24| 24| 25| 26| 27| 28|     rowIdx = 4
 ---------------------------
 ---------------------------
 | 30| 31|   |   |   |   |   |     rowIdx = 5
 ---------------------------
 
 */
int calendar_get_hitted_day_cell_index(const SCalendar* calendar, CGPoint localPt)
{
    //优化1: 如果一个点不在日期区块中，那么肯定没点中，立即返回
    CGRect daySec;
    calendar_get_day_section_rect(calendar, &daySec);
    
    if(!CGRectContainsPoint(daySec,localPt))
        return -1;
    
    localPt.y -= daySec.origin.y;
    
    //触摸点肯定会会点中日期区块中的某个cell
    
    //优化2: 避免使用循环6*7次遍历整个cell，检测是否一点在该cell中,通过下面算法，可以立刻获得当前点所在的cell行列索引号
    
    float cellWidth  =   daySec.size.width  / 7.0F;
	float cellHeight =   daySec.size.height / 6.0F;
    int   columIdx   =   localPt.x / cellWidth;
	int   rowIdx     =   localPt.y / cellHeight;
    
    //检测当前被点中的cell是否允许被选中，具体原理请参考
    //函数void calendar_set_year_month(SCalendar* calendar,int year,int month)的注释
    
    int idx  =  rowIdx * 7 + columIdx;
    if(idx < calendar->dayBeginIdx || idx > calendar->dayBeginIdx  + calendar->dayCount - 1)
		return -1;
    
    //到此说明肯定有点中的cell,返回该cell的索引号
    return idx;
}

@interface CalendarView()
{
    /*
     blf: 
         引用c结构，所有月历相关操作委托给SCalendar的相关函数
         SCalendar 使用栈内存分配
    */
    SCalendar         _calendar;
    
    //这是一个很重要的变量，具体源码中说明
    int               _lastMonthDayCount;
    
    //存放月历的日期和星期字符串
    NSMutableArray*   _dayAndWeekStringArray;
    
    //string绘制时的大小
    CGSize            _dayStringDrawingSize;
    CGSize            _weekStringDrawingSize;
}

@end

@implementation CalendarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //年月区块和星期区块的大小按当前view高度的比例来设定
        float yearMonthHeight = frame.size.height * 0.095F;
        float weekHeight = frame.size.height * 0.089F;
        
        //初始化月历控件，计算出各个区块部分的大小
        calendar_init(&_calendar, frame.size, yearMonthHeight, weekHeight);
        
        
        SDate date = _calendar.date;
        
        //此时date是上个月
        date_get_prev_month(&date, 1);
    
        
        self.backgroundColor = [UIColor clearColor];
        
        //设置日期区块的大小
        CGRect rc;
        calendar_get_day_cell_rect(&_calendar,&rc,0,0);
        CGSize size;
        size.height = rc.size.height- 15 ;
        size.width  = rc.size.width - 15;
        
        //预先分配38个字符串容量的数组
        _dayAndWeekStringArray = [NSMutableArray arrayWithCapacity:38];
        
        //0-－30表示最多31天日期字符串
        for(int i = 0; i < 31; i++)
            [_dayAndWeekStringArray addObject: [NSString stringWithFormat:@"%02d",i+1]];
        
        //31--37存储星期字符串
        [_dayAndWeekStringArray addObject:@"周日"];
        [_dayAndWeekStringArray addObject:@"周一"];
        [_dayAndWeekStringArray addObject:@"周二"];
        [_dayAndWeekStringArray addObject:@"周三"];
        [_dayAndWeekStringArray addObject:@"周四"];
        [_dayAndWeekStringArray addObject:@"周五"];
        [_dayAndWeekStringArray addObject:@"周六"];
        
        //计算出日期字符串的绘制用尺寸
        _dayStringDrawingSize   = [self getStringDrawingSize: [_dayAndWeekStringArray objectAtIndex:0]];
        //计算出星期字符串的绘制用尺寸
        _weekStringDrawingSize  = [self getStringDrawingSize: [_dayAndWeekStringArray objectAtIndex:31]];
        
        //UIControl基于控件的事件处理系统，挂接UIControlEventTouchUpInside处理程序
        [self addTarget:self action:@selector(handleTouchEvent:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(CGSize) getStringDrawingSize:(NSString*)str
{
    
    NSAttributedString* attStr = [[NSAttributedString alloc] initWithString:str];
    NSRange range = NSMakeRange(0, attStr.length);
    NSDictionary* dic = [attStr attributesAtIndex:0 effectiveRange:&range];
    
    CGRect rect = [str boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    return rect.size;
}


-(void) drawStringInRectWithSize : (NSString*) string rect:(CGRect)rect size:(CGSize) size color : (UIColor*) color
{
    CGPoint pos;
    //下面算法是让文字位于要绘制的Rect的水平和垂直中心
    //也就是剧中对齐
    pos.x = (rect.size.width - size.width) * 0.5F;
    pos.y = (rect.size.height - size.height) * 0.5F;
    pos.x += rect.origin.x;
    pos.y += rect.origin.y;
    
    //由于周日和周六与平常文字颜色有差别，因此需要color
    NSDictionary * attsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               color, NSForegroundColorAttributeName,
                               nil ];
    
    [string drawAtPoint:pos withAttributes:attsDict];
}


-(void) setYearMonth:(int)year month:(int)month
{
    calendar_set_year_month(&_calendar, year, month);
    
    _lastMonthDayCount = date_get_month_of_day(_calendar.date.year,_calendar.date.month);
    [self setNeedsDisplay];
}


-(void) drawYearMonthStr : (NSString*) string rect:(CGRect) rect
{
    CGSize sz = [self getStringDrawingSize:string];
    CGPoint pos;
    pos.y = (rect.size.height - sz.height) * 0.5F;
    pos. x = rect.origin.x + 10.0F;
    [string drawAtPoint:pos withAttributes:nil];
}

-(void) drawCircleInRect : (CGRect) rect color : (UIColor*) color isFill : (BOOL) isFill
{
    //取width和height最小的值作为要绘制的圆的直径，这样就不会将圆绘制范围超出rect
    float radiu = rect.size.width < rect.size.height ? rect.size.width : rect.size.height;
    
    //将圆的中心点从rect的左上角平移到rect的中心点
    CGPoint center;
    center.x = rect.origin.x  + rect.size.width * 0.5F;
    center.y = rect.origin. y + rect.size.height * 0.5F;
    //圆是由圆心和半径定义的
    radiu *= 0.5F;
    
    //创建一个圆的bezier路径对象
    UIBezierPath* circle = [UIBezierPath bezierPathWithArcCenter:center radius:radiu startAngle:0.0F endAngle:2.0F*3.1415926F clockwise:true];
    
    //填充绘制（日期选中状态）
    if(isFill == YES)
    {
        [color setFill];
        [circle fill];
    }
    else
    {
        //没选中状态，用stroke方式绘制
        [color setStroke];
        [circle stroke];
    }
}

-(void) drawRoundRect : (CGRect) rect  radius : (CGFloat)radius
{
    UIBezierPath* roundRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [[UIColor colorWithRed:52/255.0 green:175/255.0 blue:248/255.0 alpha:1.0] setFill];
    [roundRect fill];
}


typedef struct _selectRange
{
    int      rowIdx; //为了方便处理是否同一行
    int      columIdx;//行列转换一纬数组索引
    CGRect   rect; //纪录要绘制的rect
} selectRange;


//blf：注意 参数ranges是数组名，数组名表示数组的首地址
//         还有就是selectRange是c结构，当做指针操作时要用->而不是.寻址操作符
-(void) drawSelectRange : (selectRange* ) ranges count : (int) count
{
    //两种情况下count = 1
    //第一选则，或者第二次选中的和第一次选中的是同一个日期cell
    //此时是绘制圆形而不是roundedRect
    if(count == 1)
    {
        [self drawCircleInRect : ranges[0].rect color:[UIColor colorWithRed:52/255.0 green:175/255.0 blue:248/255.0 alpha:1.0] isFill:YES];
        
        //退出函数
        return;
    }
    
    //并不是第一次选者且第二次选者不是和第一次选者一致时
    
    //获取cell rect的width
    CGRect rect;
    calendar_get_day_cell_rect_by_index(&_calendar, &rect, 0);
    float width = rect.size.width;
    
    //用于纪录上一次的行号，初始化，纪录的是第一行的索引号
    int lastRowIdx = ranges[0].rowIdx;
    //计数器，用来纪录当前行的cell的数量
    int sameRowCellCount = 0;
    
    for(int i = 0; i < count; i++)
    {
        //从ranges数组中获取一个结构时候，使用了&取地址操作符
        //因为防止发生拷贝，如果不是取地址的话，赋值会发生memcopy行为
        selectRange* range = &ranges[i];
        //行号相同，则同一行啦
        if(range->rowIdx == lastRowIdx)
        {
            sameRowCellCount++;
        }
        else
        {
            //行号不同，说明换行了，因此要绘制当前行
            CGRect rc;
            //i - sameRowCellCount找到起始索引
            rc.origin = ranges[i - sameRowCellCount].rect.origin;
            rc.size.height = range->rect.size.height;
            rc.size.width = width* (sameRowCellCount) - 10.0F;
            
            //很可能存在这种情况，既选中的是周六开始的，因此绘制的是圆形而不是roundedRect
            if(sameRowCellCount == 1)
            {
                [self drawCircleInRect:rc color:[UIColor colorWithRed:52/255.0 green:175/255.0 blue:248/255.0 alpha:1.0] isFill:YES];
            }
            else
            {
                //一般情况，绘制roundedRect
                [self drawRoundRect:rc radius:rc.size.height];
            }
            
            sameRowCellCount = 1;//标记值，为了下面绘制最后一行的代码使用，＝1和>1要分别处理
            
            //纪录上一次的行号
            lastRowIdx = range->rowIdx;
        }
    }
    
    //将最后一行拆分出来单独处理，这样就方便处理一些特殊情况
    
    //绘制最后一行
    if(sameRowCellCount > 0)
    {
        CGRect rc;
        rc.origin = ranges[count - sameRowCellCount].rect.origin;
        rc.size.height = ranges[count - sameRowCellCount].rect.size.height;
        rc.size.width  = width* (sameRowCellCount) - 10.0F;
        
        //最后一行有多个cell被选中
        if(sameRowCellCount != 1)
        {
            [self drawRoundRect:rc radius:rc.size.height];
        }
        else//最后一行仅周日被选中，只有一个，圆圈
            [self drawCircleInRect:rc color:[UIColor colorWithRed:52/255.0 green:175/255.0 blue:248/255.0 alpha:1.0] isFill:YES];
   
    }
}


//blf:override drawRect函数，接管所有绘图，因为整个月历控件由我们自己绘制出来
- (void)drawRect:(CGRect)rect
{
    
    //blf:获取原生绘图context指针，所有原生绘图api都是c语言api方式
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rc;
    calendar_get_year_month_section_rect(&_calendar, &rc);
    //NSString* drawStr = @" " + _calendar.date.year + @"年" + _calendar.date.month + @"月";
    NSString* drawStr = [NSString stringWithFormat:@"%d年%d月",_calendar.date.year,_calendar.date.month];
    
    //绘制年月信息
    [self drawYearMonthStr:drawStr rect:rc];
    
    //绘制星期信息
    for(int i= 0; i < 7; i++)
    {
        //获取星期区块中某个cell的rect
        calendar_get_week_cell_rect(&_calendar, &rc, i);
        if(i == 0 || i == 6)
        {
            //双休日黑色
            [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex:31 + i] rect:rc size:_weekStringDrawingSize color: [UIColor blackColor]];
        }
        else
        {
            //其他时间蓝色
            [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex:31 + i] rect:rc size:_weekStringDrawingSize  color: [UIColor blueColor]];
        }
    }
    
    
    CGPoint dayRectOffset;
    //获取日期区块的rect
    calendar_get_day_section_rect(&_calendar, &rc);
    //纪录日期区块的起始位置
    dayRectOffset = rc.origin;
    
    //当前月份1号在日期cells中的起始索引号
    int begin = _calendar.dayBeginIdx;
    //当前月份结束索引号
    int end   = begin + _calendar.dayCount;
    
    //绘制上个月的日期，假设begin ＝ 5 i=[4,3,2,1,0]
    for(int i = begin - 1; i >= 0; i--)
    {
        calendar_get_day_cell_rect_by_index(&_calendar, &rc, i);
        
        //计算出位置偏移量
        rc.origin.x += dayRectOffset.x;
        rc.origin.y += dayRectOffset.y;
        
        //缩小一下绘制rect的尺寸而已
        rc.origin.x += 5;
        rc.origin.y += 5;
        
        rc.size.width -= 10;
        rc.size.height -= 10;
        
        //绘制圆圈
        [self drawCircleInRect:rc color:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0] isFill:YES];
        
        
        //计算方式涉及到了_lastMonthDayCount
        //假设上个月有30天，本月的begin为5，则
        //则30－(5-4)＝ 29 ---->0base--->30号
        //  30- (5-3)= 28 ---->0base--->29号
        //  30- (5-2)= 27 ---->0base--->28号
        //  30- (5-1)= 26 ---->0base--->27号
        //  30- (5-0)= 25 ---->0base--->26号
        int dayIdx = _lastMonthDayCount - (begin - i);
        
        //绘制圆圈中的日期
        [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex: dayIdx] rect:rc size:_dayStringDrawingSize color:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1.0]];
    }
    
    //绘制下个月的日期
    for(int i = end; i < 42; i++)
    {
        calendar_get_day_cell_rect_by_index(&_calendar, &rc, i);
        rc.origin.x += dayRectOffset.x;
        rc.origin.y += dayRectOffset.y;
        
        rc.origin.x += 5;
        rc.origin.y += 5;
        
        rc.size.width -= 10;
        rc.size.height -= 10;
        
        [self drawCircleInRect:rc color:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0] isFill:YES];
        
        //索引是i-end，很容易理解的
        [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex: i - end] rect:rc size:_dayStringDrawingSize color:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1.0]];
        
    }
    
    //使用c结构，并初始化相关变量
    selectRange  ranges[31];
    memset(ranges,0,sizeof(ranges));
    int          rangeCount = 0;
    
    //绘制当前月的日期
    for(int i = begin ;  i < end; i++)
    {
        calendar_get_day_cell_rect_by_index(&_calendar, &rc, i);
        rc.origin.x += dayRectOffset.x;
        rc.origin.y += dayRectOffset.y;
        
        rc.origin.x += 5;
        rc.origin.y += 5;
        
        rc.size.width -= 10;
        rc.size.height -= 10;
        
        SDate date;
        date_set(&date, _calendar.date.year, _calendar.date.month, i - begin + 1 );
        
        //如果当前日期在选中时间范围内，则batch起来，由drawSelectRange进行绘制
        //因为需要处理换行这种效果(drawSelectRange中处理，因此缓存起来二次处理比较方便
        //与delegate通信
        if([self.calendarDelegate isInSelectedDateRange:date])
        {
            
            ranges[rangeCount].rowIdx = i / 7; //映射成行索引
            ranges[rangeCount].columIdx = i % 7; //映射成列索引
            ranges[rangeCount].rect = rc; //当前行列的rect纪录下来
            rangeCount++; //计数器增加1
        }
        else
        {
            
            //没有选中的，就直接绘制圆圈和当中的日期号
            [self drawCircleInRect:rc color:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1.0] isFill:NO];
            [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex: i - _calendar.dayBeginIdx] rect:rc size:_dayStringDrawingSize color:[UIColor colorWithRed:107/255.0 green:107/255.0 blue:107/255.0 alpha:1.0]];
        }
    }
    
    //NSLog(@"select day count = %d",rangeCount);
    //rangeCount纪录了选中的数量，ranges则纪录了要绘制的所有信息
    [self drawSelectRange:ranges count:rangeCount];

    //选中的圈圈的文字由下面代码绘制
    for(int i = 0; i < rangeCount; i++)
    {
        //重新将行列（二维）索引号映射一纬数组索引号
        int idx = ranges[i].rowIdx * 7 + ranges[i].columIdx;
        //idx - begin就是当前的要绘制的日期文字的索引号
        [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex: idx - begin] rect:ranges[i].rect size:_dayStringDrawingSize  color:[UIColor whiteColor]];
    }
    
}

-(void) handleTouchEvent:(id) sender forEvent:(UIEvent *)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    
    //获取UITouch,将其转换到当前CalendarView的局部坐标系表示
    CGPoint upLoc = [touch locationInView:self];
    
    //通过局部坐标系的点获取点击处的cell的索引号，优化部分请看c的相关实现
    //这个碰撞检测原理实际在游戏中经常使用，分区缩小范围，然后检测该范围内所有物体的与点（2D）
    //或光线（3D）是否发生碰撞，用于此处也非常适合
    int hitIdx = calendar_get_hitted_day_cell_index(&_calendar, upLoc);
    
    //
    if(hitIdx != -1)
    {
        SDate date;
        date_set(&date, _calendar.date.year, _calendar.date.month, hitIdx - _calendar.dayBeginIdx + 1);
        
        //0为第一次点击，仅选中一个cell
        //mod为了周而复始，并在［0，1］之间
        if([self.calendarDelegate getHitCounter] % 2 == 0)
        {
            [self.calendarDelegate setSelectedDateRangeStart:date end:date];
        }
        else//1为第二次点击，形成选区
        {
            [self.calendarDelegate setEndSelectedDate:date];
        }
        
        //每次点击，delegate中的点击计数器都要递增的
        [self.calendarDelegate updateHitCounter];
        
        //需要触发重绘，让ios进行重新绘制，这个很关键，有一些细节，在下面会说明的
        [self.calendarDelegate repaintCalendarViews];
    }
    
}


@end
