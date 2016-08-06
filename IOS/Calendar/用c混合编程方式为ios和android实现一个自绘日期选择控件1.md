###章节:

???? 1、需求描述以及c/c++实现日期和月历的基本操作

?????2、ios实现自绘日期选择控件

?????3、android实现自绘日期选择控件

###目的:

????通过一个相对复杂的自定义自绘控件来分享:

?????1、ios以及android自定义自绘控件的开发流程

?????2、objc与c/c++混合编程

?????3、android?ndk的环境配置，android?studio?ndk的编译模式，swig在android?ndk开发中的作用
###一、需求描述以及c/c++实现日期和月历的基本操作
1、需求描述:

![QQ图片20160801203350.png](http://upload-images.jianshu.io/upload_images/2635028-8dfe4e101e08150b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

        1)?该日期选择控件主要用于日期过滤查询，一般用于近n年的数据查询。

?       2)?假设你点击某个按钮弹出该日期选择控件时，自动定位到当前月，例如本月是4月，则4月份显示在屏幕最下方。

????????3)?当你手指向上滑动时，向前n个月滚动（月份例如:4-3-2-1），手指向下滑动时，向后n个月滚动（月份例如:1-2-3-4）。

????????4)?日期区分为可选择区或不可选择区（图1），当你第一次点击可选的日期，该日期会被选中(蓝色)。

????????5)?当你第二次点击可选的日期，则会形成一个选区(图2),该选区会跳过所有不可选的日期。

2、为什么使用c/c++：

????? 1) 历史原因：该控件是两年前为某个项目实现的，当时没有移动开发经验，因此最初技术预研时选择了跨平台的cocos2d-x来开发，并为其实现了该控件.但是cocos2d-x存在一些bug，并且其基于游戏开发模式，不停的循环绘制，cpu占用高，耗电量大。如果要用cocos2d-x开发一般的app的话，需要为其加入脏区局部刷新的功能，这样改动量太大。在研究cocos2d-x时，其所见即所得的cocostudio需要使用swig将c/c++代码wrap成c#供其进行平台调用。当时觉得swig真是强大无比，可以自动wrap为c#,java,python,lua,js....等进行相互调用。

????? 2) ios端objc可以非常容易的与c/c++进行相互调用，而android ndk+swig也可以大大减轻c/c++代码在android端的实现和调用难度(具体我们在第三部分中可以体会到)。这样我们就能够重用为cocos2d-x所写的c/c++代码。

????? 3) 基于java的android程序，非常容易进行反编译，因此使用c/c++编译成.so后，都是二进制代码。因此如果对运行速度或代码安全性有比较高的要求的话，可以使用c/c++进行实现，由android java jni进行调用。

????? 4) 还有一个重要原因就是想深入了解一下android ndk以及swig的开发方式。

3、为什么选择自定义自绘控件方式:

不管是android还是ios，自定义控件的实现基本上有三种方式:

?????1)?利用androidStudio或xcode interfaceBuilder中的容器控件以及其他控件组合拼装而成，自定义控件不需要继承自View或子类。你可以进行一些事件的编写就可以完成很多需求。

?????2) 继承自View或子类，再用现有的控件组合拼装而成。

???? 3) 继承自View或子类，所有该自定义View的显示效果由我们来绘制出。 
这里我们采取第三种方式。相对来说，这种方式内存消耗要小很多，并且速度上也有一定优势吧。要知道每个月都是需要42个cell表示日期，并且加上年月和星期这些区块，都用View组合而成，内存也不算小。不管是ios还是android，每个View的成员变量都不少。而使用自绘控件，只要一个View就解决了。至少内存使用上可以减少40多个View的使用，对吧?

4、c/c++实现细节:
1） android中的一些适配结构和函数: 
    因为使用了ios内置的例如CGRect，CGPoint，CGSize等c语言结构，而android ndk中没有这些结构，因此对于android来说，需要实现这些结构以及在整个程序中用到的一些函数。c/c++中要做到这些，可以使用宏来判断和切换当前的环境，具体见代码:
```
/*blf: 使用ios中的一些基础数据结构，android中需要移植过来 。  
       ios的话，请将下面 #define ANDROID_NDK_IMP这句代码注释掉！
*/
#define ANDROID_NDK_IMP
#ifdef ANDROID_NDK_IMP 
    typedef struct _CGPoint {    float x;    float y;}CGPoint;
    typedef struct _CGSize  {    float width;    float height;}CGSize;
    typedef struct _CGRect  {    CGPoint origin;    CGSize size;}CGRect;
#endif
```
```
/*blf: 使用ios中的一些基础数据结构，android中需要移植过来  
       下面是实现代码
*/
#ifdef ANDROID_NDK_IMP  
    static float GetRectMaxX(CGRect rc) { return rc.origin.x + rc.size.width;  }  
    static float GetRectMaxY(CGRect rc) { return rc.origin.y + rc.size.height; }  
    static bool CGRectContainsPoint(CGRect rc, CGPoint pt){return(pt.x >= rc.origin.x) && (pt.x <= GetRectMaxX(rc)) && (pt.y >= rc.origin.y) && (pt.y <= GetRectMaxY(rc));}
#endif
```
2) 日期操作函数:
这些函数都和日期操作相关，具体请参考代码，注释应该比较清楚的。
```
/*
blf: 函数参数都是以指针方式传入(java或c#中就为传引用,swig将指针会转换为类对象，所有类对象在java和c#中都是传引用的.
     c#支持struct，是值类型

    c#还支持参数的ref和out方式，可以将值类型以传引用方式输出到参数中，相当于c中的指针

    经验之谈:除非在c/c++中你使用shared_ptr等智能指针，否则千万不要在函数或成员方法中malloc或new一个新对象然后return出来。
    比较好的方式还是通过参数传指针或引用方式来返回更新的数据。
*/
void date_set(SDate* ret,int year,int month,int day)
{
   assert(ret);
   ret->year = year;
   ret->month = month;
   ret->day = day;
}

/*
blf: 获取当前的年月日
*/
void date_get_now(SDate* ret)
{
   assert(ret);

   //time()此函数会返回从公元 1970 年1 月1 日的UTC 时间从0 时0 分0 秒算起到现在所经过的秒数。
   //记住:是秒数，而不是毫秒数(很多语言返回的是毫秒数，crt中是以秒为单位的)
   //如果t 并非空指针的话，此函数也会将返回值存到t指针所指的内存
   time_t t;
   time(&t);

   //转换到当前系统的本地时间
   struct tm* timeInfo;
   timeInfo = localtime(&t);

   //tm结构中的年份是从1900开始到今天的年数，因此需要加上1900
   ret->year  =  timeInfo->tm_year + 1900;

   //月份是 0 base的，我们按照1-12的方式来计算，因此加1
   ret->month =  timeInfo->tm_mon + 1;

   ret->day   =  timeInfo->tm_mday;
}

/*
blf: 是否相等
*/
bool date_is_equal(const SDate* left,const SDate* right)
{
   assert(left&&right);
   return (left->year == right->year &&
           left->month == right->month &&
           left->day == right->day);
}

/*
blf: 计算两个年份之间的月数
*/
int date_get_month_count_from_year_range(int startYear,int endYear)
{
   int diff = endYear - startYear + 1;
   return diff * 12;
}

/*
blf: 将一维的数据表示映射成二维表示(年和月)
     startYear表示起始年，例如 2010年
     idx表示相对2010年开始的月份偏移量

     我们会在下面和后面代码中看到/ 和 %的多次使用
     可以理解为，将一维数据映射成二维行列表示的数据时，都可以使用这种方式

     下面这个函数用于月历区间选择控件，例如你有个数据库查询需求，可以查询
     当前年月日----五年前的年1月1号之间的数据，此时在UITabelView或ListView时，就需要
     调用本函数来显示年月信息等
*/
void date_map_index_to_year_month(SDate* to,int startYear,int idx)
{
   assert(to);

   //每年有12个月，idx/12你可以看成每12个月进一位，加上startYear基准值，就可以获得当前年份
   to->year = startYear + idx / 12;

   //每年有12个月，idx%12你可以看成【0-11】之间循环，加1是因为我们的SDate结构是1-12表示的
   to->month = idx % 12 + 1;

   //至于day，这里为-1,我们在map中忽略该值，可以设置任意值
   to->day = -1;
}

/*
blf: 下面函数来源于linux实现，计算从某个时间点（年月日时分秒)到1970年0时0分0秒的时间差
参考url: http://blog.csdn.net/axx1611/article/details/1792827
*/
long mymktime (unsigned int year, unsigned int mon,
                      unsigned int day, unsigned int hour,
                      unsigned int min, unsigned int sec)
{
   if (0 >= (int) (mon -= 2)) {    /* 1..12 -> 11,12,1..10 */
      mon += 12;      /* Puts Feb last since it has leap day */
      year -= 1;
   }

   return (((
                    (long) (year/4 - year/100 + year/400 + 367*mon/12 + day) +
                    year*365 - 719499
            )*24 + hour /* now have hours */
           )*60 + min /* now have minutes */
          )*60 + sec; /* finally seconds */
}

/*
blf: 下面函数一共实现了三个版本

     第一版: 不知道是我对c的mktime用法错误还是有bug(理论上不可能，因为ios和android中都存在问题)
             同一个时间点，例如2016年1月1日0时0分1秒与1970年1月1日0时0分0秒的时间差不一样。

     第二版: 使用ios自身的 NSCalendar对象计算时间差，这个计算是正确的，但是只能用在ios中

     第三版: http://blog.csdn.net/axx1611/article/details/1792827中的算法，来自于linux源码，ios/android中运行的很好

     为什么不用time_t而是使用long呢?
     这是因为android中使用swig将c/c++ 代码转换成java jni封装的函数时，time_t被封装成了对象。
     因为java不认识c的typedef结构，Swig将其转换为SWITGYPT_p_XXXXX类型的包装(经典的装箱/拆箱，每次操作都要进行装箱拆箱，很麻烦).
     time_t只是64位整型的typedef而已，因此转换为long后，经Swig转换后，对应为java的整型，这样操作起来比较简单

*/

long date_get_time_t(const SDate* d)
{
    assert(d);

    /*
     1、第一版
    struct tm date;
    //crt函数中year是基于1900年的偏移，因此要减去1900
    date.tm_year = d->year - 1900;

    //crt函数中月份是[0-11]表示的，我们使用[1-12]表示，因此要减去1
    date.tm_mon = d->month - 1;

    date.tm_mday = d->day;
    date.tm_hour = 0;
    date.tm_min = 0;
    date.tm_sec = 1;
    time_t seconds = mktime(&date);

    return (long)seconds;
    */

    /*
     2、第二版 ios NSCalendar对象计算时间差
     NSDateComponents *components = [[NSDateComponents alloc] init];

     [components setDay:d->day]; // Monday
     [components setMonth:d->month]; // May
     [components setYear:d->year];

     NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

     NSDate *date = [gregorian dateFromComponents:components];

     return (time_t) [date timeIntervalSince1970];
     */

     /*
     3、网上Linux版本
     */
     return mymktime(d->year,d->month,d->day,0,0,1);
}

/*
blf: 根据delta计算月份，返回值存储在date结构中
     例如：当前年月为2015年1月份，delta为2，则返回2014年11月
*/
void date_get_prev_month(SDate* date, int delta)
{
   assert(date);

   if((date->month - delta) < 1)
   {
      //条件: 假设为2015年1月,delta = 2
      //因为: 1-2 = -1 < 1
      //所以: 年数 = 2015 - 1 = 2014 月份 = 12 + 1 - 2 = 11
      date->year--;
      date->month = 12 + date->month - delta;
   }
   else
      date->month = date->month - delta;
}

/*
blf: 根据delta计算出月份，返回值存储在date结构中
     例如：当前年月为2015年11月份，delta为2，则返回2016年1月
*/
void date_get_next_month(SDate* date, int delta)
{
   assert(date);
   if((date->month + delta) > 12)
   {
      //条件: 假设为2015年11月,delta = 2
      //因为: 11 + 2 = 13 > 12
      //所以: 年数 = 2015 + 1 = 2016 月份 = 11 + 2 - 12 = 1
      date->year++;
      date->month = date->month + delta - 12;
   }
   else
      date->month = date->month + delta;
}

/*
blf: 根据输入年份，判断是否是闰年
     固定算法：判断闰年的方法是该年能被4整除并且不能被100整除，或者是可以被400整除
*/
int date_get_leap(int year)
{
   if(((year % 4 == 0) && (year % 100) != 0) || (year % 400 == 0))
      return 1;
   return 0;
}

/*
blf: 辅助函数，用于计算某年某月的某天是星期几
*/
int date_get_days(const SDate* date)
{
   assert(date);
   int day_table[13] = {0,31,28,31,30,31,30,31,31,30,31,30,31};
   int i = 0, total = 0;
   for(i = 0; i < date->month; i++)
      total += day_table[i];
   return total + date->day + date_get_leap(date->year);
}

/*
blf: 用于计算某年某月的某天是星期几，调用上面函数
     这些算法比较固定，具体原理也不需要太了解，因为我也不清楚。
*/
int date_get_week(const SDate* date)
{
   assert(date);
   return ((date->year - 1 + (date->year - 1) / 4 - (date->year - 1) / 100 +
            (date->year - 1) / 400 + date_get_days(date) )% 7);
}

/*
blf: 用于计算某个月的天数
*/
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
```
3) 月历操作函数:
```
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
      //每个day设置为1号
      calendar->date.day = 1;

      //blf:
      //参考上面图示，dayBeginIdx获得的是某个月1号相对日期区块中的索引，例如本例中1号索引为6
      //而dayCount表示当前月的天数
      //这样通过偏移与长度，我们可以很容易进行某些重要操作
      //例如在碰撞检测某个cell是否被点中时，可以跳过没有日期的cell
      //在绘图时检测某个cell是否找范围之外，如果之外就用灰色现实等等
      //通过偏移量和count，进行范围判断
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

/*
 blf: 初始化一个月历结构，填充所有成员变量的数据
*/
void calendar_init(SCalendar* calendar,CGSize ownerSize,float yearMonthHeight,float weekHeight)
{
   assert(calendar && calendar);

   //memset(calendar, 0, sizeof(SCalendar));

   calendar->size = ownerSize;
   calendar->yearMonthSectionHeight = yearMonthHeight;
   calendar->weekSectionHegiht = weekHeight;
   //blf:daySectionHeight是计算出来的
   calendar->daySectionHeight = ownerSize.height - yearMonthHeight - weekHeight;
   //blf:错误检测，简单期间，全部使用assert在debug时候进行中断
   assert(calendar->daySectionHeight > 0);

   //blf:初始化时显示本地当前的年月日
   //date_get_now(&calendar->date);

   calendar_set_year_month(calendar, calendar->date.year, calendar->date.month);
}

/*
 blf: 计算出年月区块的rect
*/
void calendar_get_year_month_section_rect(const SCalendar* calendar,CGRect* rect)
{
   assert(rect);
   memset(rect,0,sizeof(CGRect));
   rect->size.width = calendar->size.width;
   rect->size.height = calendar->yearMonthSectionHeight;
}

/*
 blf: 计算出星期区块的rect
*/
void calendar_get_week_section_rect(const SCalendar* calendar,CGRect* rect)
{
   assert(rect);
   memset(rect,0,sizeof(CGRect));
   rect->origin.y = calendar->yearMonthSectionHeight;
   rect->size.width = calendar->size.width;
   rect->size.height = calendar->weekSectionHegiht;
}

/*
 blf: 计算出年日期区块的rect
*/
void calendar_get_day_section_rect(const SCalendar* calendar,CGRect* rect)
{
   assert(calendar && rect);
   memset(rect,0,sizeof(CGRect));
   rect->origin.y = calendar->yearMonthSectionHeight + calendar->weekSectionHegiht;
   rect->size.width = calendar->size.width;
   rect->size.height = calendar->daySectionHeight;
}

/*
blf: 上面计算出来的是三大整体的区块(section)
     下面计算出来的都是某个大区快中的子区(cell)
*/

/*
 blf:
 获取星期区块中每个索引指向的子区rect位置与尺寸
 输出数据在rect参数中
 ---------------------------
 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
 ---------------------------
 idx = 0时表示星期日
 用于绘图
 */

void calendar_get_week_cell_rect(const SCalendar* calendar,CGRect* rect,int idx)
{
   assert(calendar && rect && idx >= 0 && idx < 7);
   //获取星期区块
   calendar_get_week_section_rect(calendar, rect);
   //计算出cell的宽度
   float cellWidth = rect->size.width / 7.0F;
   //计算出x偏移量
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
   // （/ 和 %）符号的应用，用于计算出行列索引号
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
注意: 参数localPt是相对于你所继承的View的左上角[0,0]的偏移量，是定义在View空间坐标系的
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
```