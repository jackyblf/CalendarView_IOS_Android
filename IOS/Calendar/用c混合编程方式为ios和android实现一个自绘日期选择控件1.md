###�½�:

???? 1�����������Լ�c/c++ʵ�����ں������Ļ�������

?????2��iosʵ���Ի�����ѡ��ؼ�

?????3��androidʵ���Ի�����ѡ��ؼ�

###Ŀ��:

????ͨ��һ����Ը��ӵ��Զ����Ի�ؼ�������:

?????1��ios�Լ�android�Զ����Ի�ؼ��Ŀ�������

?????2��objc��c/c++��ϱ��

?????3��android?ndk�Ļ������ã�android?studio?ndk�ı���ģʽ��swig��android?ndk�����е�����
###һ�����������Լ�c/c++ʵ�����ں������Ļ�������
1����������:

![QQͼƬ20160801203350.png](http://upload-images.jianshu.io/upload_images/2635028-8dfe4e101e08150b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

        1)?������ѡ��ؼ���Ҫ�������ڹ��˲�ѯ��һ�����ڽ�n������ݲ�ѯ��

?       2)?��������ĳ����ť����������ѡ��ؼ�ʱ���Զ���λ����ǰ�£����籾����4�£���4�·���ʾ����Ļ���·���

????????3)?������ָ���ϻ���ʱ����ǰn���¹������·�����:4-3-2-1������ָ���»���ʱ�����n���¹������·�����:1-2-3-4����

????????4)?��������Ϊ��ѡ�����򲻿�ѡ������ͼ1���������һ�ε����ѡ�����ڣ������ڻᱻѡ��(��ɫ)��

????????5)?����ڶ��ε����ѡ�����ڣ�����γ�һ��ѡ��(ͼ2),��ѡ�����������в���ѡ�����ڡ�

2��Ϊʲôʹ��c/c++��

????? 1) ��ʷԭ�򣺸ÿؼ�������ǰΪĳ����Ŀʵ�ֵģ���ʱû���ƶ��������飬����������Ԥ��ʱѡ���˿�ƽ̨��cocos2d-x����������Ϊ��ʵ���˸ÿؼ�.����cocos2d-x����һЩbug�������������Ϸ����ģʽ����ͣ��ѭ�����ƣ�cpuռ�øߣ��ĵ��������Ҫ��cocos2d-x����һ���app�Ļ�����ҪΪ����������ֲ�ˢ�µĹ��ܣ������Ķ���̫�����о�cocos2d-xʱ�������������õ�cocostudio��Ҫʹ��swig��c/c++����wrap��c#�������ƽ̨���á���ʱ����swig����ǿ���ޱȣ������Զ�wrapΪc#,java,python,lua,js....�Ƚ����໥���á�

????? 2) ios��objc���Էǳ����׵���c/c++�����໥���ã���android ndk+swigҲ���Դ�����c/c++������android�˵�ʵ�ֺ͵����Ѷ�(���������ڵ��������п�����ᵽ)���������Ǿ��ܹ�����Ϊcocos2d-x��д��c/c++���롣

????? 3) ����java��android���򣬷ǳ����׽��з����룬���ʹ��c/c++�����.so�󣬶��Ƕ����ƴ��롣�������������ٶȻ���밲ȫ���бȽϸߵ�Ҫ��Ļ�������ʹ��c/c++����ʵ�֣���android java jni���е��á�

????? 4) ����һ����Ҫԭ������������˽�һ��android ndk�Լ�swig�Ŀ�����ʽ��

3��Ϊʲôѡ���Զ����Ի�ؼ���ʽ:

������android����ios���Զ���ؼ���ʵ�ֻ����������ַ�ʽ:

?????1)?����androidStudio��xcode interfaceBuilder�е������ؼ��Լ������ؼ����ƴװ���ɣ��Զ���ؼ�����Ҫ�̳���View�����ࡣ����Խ���һЩ�¼��ı�д�Ϳ�����ɺܶ�����

?????2) �̳���View�����࣬�������еĿؼ����ƴװ���ɡ�

???? 3) �̳���View�����࣬���и��Զ���View����ʾЧ�������������Ƴ��� 
�������ǲ�ȡ�����ַ�ʽ�������˵�����ַ�ʽ�ڴ�����ҪС�ܶ࣬�����ٶ���Ҳ��һ�����ưɡ�Ҫ֪��ÿ���¶�����Ҫ42��cell��ʾ���ڣ����Ҽ������º�������Щ���飬����View��϶��ɣ��ڴ�Ҳ����С��������ios����android��ÿ��View�ĳ�Ա���������١���ʹ���Ի�ؼ���ֻҪһ��View�ͽ���ˡ������ڴ�ʹ���Ͽ��Լ���40���View��ʹ�ã��԰�?

4��c/c++ʵ��ϸ��:
1�� android�е�һЩ����ṹ�ͺ���: 
    ��Ϊʹ����ios���õ�����CGRect��CGPoint��CGSize��c���Խṹ����android ndk��û����Щ�ṹ����˶���android��˵����Ҫʵ����Щ�ṹ�Լ��������������õ���һЩ������c/c++��Ҫ������Щ������ʹ�ú����жϺ��л���ǰ�Ļ��������������:
```
/*blf: ʹ��ios�е�һЩ�������ݽṹ��android����Ҫ��ֲ���� ��  
       ios�Ļ����뽫���� #define ANDROID_NDK_IMP������ע�͵���
*/
#define ANDROID_NDK_IMP
#ifdef ANDROID_NDK_IMP 
    typedef struct _CGPoint {    float x;    float y;}CGPoint;
    typedef struct _CGSize  {    float width;    float height;}CGSize;
    typedef struct _CGRect  {    CGPoint origin;    CGSize size;}CGRect;
#endif
```
```
/*blf: ʹ��ios�е�һЩ�������ݽṹ��android����Ҫ��ֲ����  
       ������ʵ�ִ���
*/
#ifdef ANDROID_NDK_IMP  
    static float GetRectMaxX(CGRect rc) { return rc.origin.x + rc.size.width;  }  
    static float GetRectMaxY(CGRect rc) { return rc.origin.y + rc.size.height; }  
    static bool CGRectContainsPoint(CGRect rc, CGPoint pt){return(pt.x >= rc.origin.x) && (pt.x <= GetRectMaxX(rc)) && (pt.y >= rc.origin.y) && (pt.y <= GetRectMaxY(rc));}
#endif
```
2) ���ڲ�������:
��Щ�����������ڲ�����أ�������ο����룬ע��Ӧ�ñȽ�����ġ�
```
/*
blf: ��������������ָ�뷽ʽ����(java��c#�о�Ϊ������,swig��ָ���ת��Ϊ����������������java��c#�ж��Ǵ����õ�.
     c#֧��struct����ֵ����

    c#��֧�ֲ�����ref��out��ʽ�����Խ�ֵ�����Դ����÷�ʽ����������У��൱��c�е�ָ��

    ����̸֮:������c/c++����ʹ��shared_ptr������ָ�룬����ǧ��Ҫ�ں������Ա������malloc��newһ���¶���Ȼ��return������
    �ȽϺõķ�ʽ����ͨ��������ָ������÷�ʽ�����ظ��µ����ݡ�
*/
void date_set(SDate* ret,int year,int month,int day)
{
   assert(ret);
   ret->year = year;
   ret->month = month;
   ret->day = day;
}

/*
blf: ��ȡ��ǰ��������
*/
void date_get_now(SDate* ret)
{
   assert(ret);

   //time()�˺����᷵�شӹ�Ԫ 1970 ��1 ��1 �յ�UTC ʱ���0 ʱ0 ��0 ������������������������
   //��ס:�������������Ǻ�����(�ܶ����Է��ص��Ǻ�������crt��������Ϊ��λ��)
   //���t ���ǿ�ָ��Ļ����˺���Ҳ�Ὣ����ֵ�浽tָ����ָ���ڴ�
   time_t t;
   time(&t);

   //ת������ǰϵͳ�ı���ʱ��
   struct tm* timeInfo;
   timeInfo = localtime(&t);

   //tm�ṹ�е�����Ǵ�1900��ʼ������������������Ҫ����1900
   ret->year  =  timeInfo->tm_year + 1900;

   //�·��� 0 base�ģ����ǰ���1-12�ķ�ʽ�����㣬��˼�1
   ret->month =  timeInfo->tm_mon + 1;

   ret->day   =  timeInfo->tm_mday;
}

/*
blf: �Ƿ����
*/
bool date_is_equal(const SDate* left,const SDate* right)
{
   assert(left&&right);
   return (left->year == right->year &&
           left->month == right->month &&
           left->day == right->day);
}

/*
blf: �����������֮�������
*/
int date_get_month_count_from_year_range(int startYear,int endYear)
{
   int diff = endYear - startYear + 1;
   return diff * 12;
}

/*
blf: ��һά�����ݱ�ʾӳ��ɶ�ά��ʾ(�����)
     startYear��ʾ��ʼ�꣬���� 2010��
     idx��ʾ���2010�꿪ʼ���·�ƫ����

     ���ǻ�������ͺ�������п���/ �� %�Ķ��ʹ��
     �������Ϊ����һά����ӳ��ɶ�ά���б�ʾ������ʱ��������ʹ�����ַ�ʽ

     �����������������������ѡ��ؼ����������и����ݿ��ѯ���󣬿��Բ�ѯ
     ��ǰ������----����ǰ����1��1��֮������ݣ���ʱ��UITabelView��ListViewʱ������Ҫ
     ���ñ���������ʾ������Ϣ��
*/
void date_map_index_to_year_month(SDate* to,int startYear,int idx)
{
   assert(to);

   //ÿ����12���£�idx/12����Կ���ÿ12���½�һλ������startYear��׼ֵ���Ϳ��Ի�õ�ǰ���
   to->year = startYear + idx / 12;

   //ÿ����12���£�idx%12����Կ��ɡ�0-11��֮��ѭ������1����Ϊ���ǵ�SDate�ṹ��1-12��ʾ��
   to->month = idx % 12 + 1;

   //����day������Ϊ-1,������map�к��Ը�ֵ��������������ֵ
   to->day = -1;
}

/*
blf: ���溯����Դ��linuxʵ�֣������ĳ��ʱ��㣨������ʱ����)��1970��0ʱ0��0���ʱ���
�ο�url: http://blog.csdn.net/axx1611/article/details/1792827
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
blf: ���溯��һ��ʵ���������汾

     ��һ��: ��֪�����Ҷ�c��mktime�÷���������bug(�����ϲ����ܣ���Ϊios��android�ж���������)
             ͬһ��ʱ��㣬����2016��1��1��0ʱ0��1����1970��1��1��0ʱ0��0���ʱ��һ����

     �ڶ���: ʹ��ios����� NSCalendar�������ʱ�������������ȷ�ģ�����ֻ������ios��

     ������: http://blog.csdn.net/axx1611/article/details/1792827�е��㷨��������linuxԴ�룬ios/android�����еĺܺ�

     Ϊʲô����time_t����ʹ��long��?
     ������Ϊandroid��ʹ��swig��c/c++ ����ת����java jni��װ�ĺ���ʱ��time_t����װ���˶���
     ��Ϊjava����ʶc��typedef�ṹ��Swig����ת��ΪSWITGYPT_p_XXXXX���͵İ�װ(�����װ��/���䣬ÿ�β�����Ҫ����װ����䣬���鷳).
     time_tֻ��64λ���͵�typedef���ѣ����ת��Ϊlong�󣬾�Swigת���󣬶�ӦΪjava�����ͣ��������������Ƚϼ�

*/

long date_get_time_t(const SDate* d)
{
    assert(d);

    /*
     1����һ��
    struct tm date;
    //crt������year�ǻ���1900���ƫ�ƣ����Ҫ��ȥ1900
    date.tm_year = d->year - 1900;

    //crt�������·���[0-11]��ʾ�ģ�����ʹ��[1-12]��ʾ�����Ҫ��ȥ1
    date.tm_mon = d->month - 1;

    date.tm_mday = d->day;
    date.tm_hour = 0;
    date.tm_min = 0;
    date.tm_sec = 1;
    time_t seconds = mktime(&date);

    return (long)seconds;
    */

    /*
     2���ڶ��� ios NSCalendar�������ʱ���
     NSDateComponents *components = [[NSDateComponents alloc] init];

     [components setDay:d->day]; // Monday
     [components setMonth:d->month]; // May
     [components setYear:d->year];

     NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

     NSDate *date = [gregorian dateFromComponents:components];

     return (time_t) [date timeIntervalSince1970];
     */

     /*
     3������Linux�汾
     */
     return mymktime(d->year,d->month,d->day,0,0,1);
}

/*
blf: ����delta�����·ݣ�����ֵ�洢��date�ṹ��
     ���磺��ǰ����Ϊ2015��1�·ݣ�deltaΪ2���򷵻�2014��11��
*/
void date_get_prev_month(SDate* date, int delta)
{
   assert(date);

   if((date->month - delta) < 1)
   {
      //����: ����Ϊ2015��1��,delta = 2
      //��Ϊ: 1-2 = -1 < 1
      //����: ���� = 2015 - 1 = 2014 �·� = 12 + 1 - 2 = 11
      date->year--;
      date->month = 12 + date->month - delta;
   }
   else
      date->month = date->month - delta;
}

/*
blf: ����delta������·ݣ�����ֵ�洢��date�ṹ��
     ���磺��ǰ����Ϊ2015��11�·ݣ�deltaΪ2���򷵻�2016��1��
*/
void date_get_next_month(SDate* date, int delta)
{
   assert(date);
   if((date->month + delta) > 12)
   {
      //����: ����Ϊ2015��11��,delta = 2
      //��Ϊ: 11 + 2 = 13 > 12
      //����: ���� = 2015 + 1 = 2016 �·� = 11 + 2 - 12 = 1
      date->year++;
      date->month = date->month + delta - 12;
   }
   else
      date->month = date->month + delta;
}

/*
blf: ����������ݣ��ж��Ƿ�������
     �̶��㷨���ж�����ķ����Ǹ����ܱ�4�������Ҳ��ܱ�100�����������ǿ��Ա�400����
*/
int date_get_leap(int year)
{
   if(((year % 4 == 0) && (year % 100) != 0) || (year % 400 == 0))
      return 1;
   return 0;
}

/*
blf: �������������ڼ���ĳ��ĳ�µ�ĳ�������ڼ�
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
blf: ���ڼ���ĳ��ĳ�µ�ĳ�������ڼ����������溯��
     ��Щ�㷨�ȽϹ̶�������ԭ��Ҳ����Ҫ̫�˽⣬��Ϊ��Ҳ�������
*/
int date_get_week(const SDate* date)
{
   assert(date);
   return ((date->year - 1 + (date->year - 1) / 4 - (date->year - 1) / 100 +
            (date->year - 1) / 400 + date_get_days(date) )% 7);
}

/*
blf: ���ڼ���ĳ���µ�����
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
   //blf:2�±Ƚ��ر�Ҫ���������ж�
   return 28 + date_get_leap(year);
}
```
3) ������������:
```
/*
 blf: calendar dayBeginIdx �� dayCountͼʾ

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
      //ÿ��day����Ϊ1��
      calendar->date.day = 1;

      //blf:
      //�ο�����ͼʾ��dayBeginIdx��õ���ĳ����1��������������е����������籾����1������Ϊ6
      //��dayCount��ʾ��ǰ�µ�����
      //����ͨ��ƫ���볤�ȣ����ǿ��Ժ����׽���ĳЩ��Ҫ����
      //��������ײ���ĳ��cell�Ƿ񱻵���ʱ����������û�����ڵ�cell
      //�ڻ�ͼʱ���ĳ��cell�Ƿ��ҷ�Χ֮�⣬���֮����û�ɫ��ʵ�ȵ�
      //ͨ��ƫ������count�����з�Χ�ж�
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
 blf: ��ʼ��һ�������ṹ��������г�Ա����������
*/
void calendar_init(SCalendar* calendar,CGSize ownerSize,float yearMonthHeight,float weekHeight)
{
   assert(calendar && calendar);

   //memset(calendar, 0, sizeof(SCalendar));

   calendar->size = ownerSize;
   calendar->yearMonthSectionHeight = yearMonthHeight;
   calendar->weekSectionHegiht = weekHeight;
   //blf:daySectionHeight�Ǽ��������
   calendar->daySectionHeight = ownerSize.height - yearMonthHeight - weekHeight;
   //blf:�����⣬���ڼ䣬ȫ��ʹ��assert��debugʱ������ж�
   assert(calendar->daySectionHeight > 0);

   //blf:��ʼ��ʱ��ʾ���ص�ǰ��������
   //date_get_now(&calendar->date);

   calendar_set_year_month(calendar, calendar->date.year, calendar->date.month);
}

/*
 blf: ��������������rect
*/
void calendar_get_year_month_section_rect(const SCalendar* calendar,CGRect* rect)
{
   assert(rect);
   memset(rect,0,sizeof(CGRect));
   rect->size.width = calendar->size.width;
   rect->size.height = calendar->yearMonthSectionHeight;
}

/*
 blf: ��������������rect
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
 blf: ����������������rect
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
blf: ���������������������������(section)
     �����������Ķ���ĳ���������е�����(cell)
*/

/*
 blf:
 ��ȡ����������ÿ������ָ�������rectλ����ߴ�
 ���������rect������
 ---------------------------
 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
 ---------------------------
 idx = 0ʱ��ʾ������
 ���ڻ�ͼ
 */

void calendar_get_week_cell_rect(const SCalendar* calendar,CGRect* rect,int idx)
{
   assert(calendar && rect && idx >= 0 && idx < 7);
   //��ȡ��������
   calendar_get_week_section_rect(calendar, rect);
   //�����cell�Ŀ��
   float cellWidth = rect->size.width / 7.0F;
   //�����xƫ����
   rect->origin.x = cellWidth * idx;
   rect->size.width = cellWidth;
}


/*
 blf:
 ��ȡ������������������ָ�������rectλ����ߴ�
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

 һ����������28-��31��֮�䣬��������Ҫ���������6��7���㹻����������������������ʾ��ȫ����
 ���ڻ�ͼ�Լ���ײ���,����42����Ԫ��

 �Զ�ά��ʽ��ȡ��������������ָ���������rectλ����ߴ�
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
 ��һά��ʽ��ʽ��ȡ��������������ָ���������rectλ����ߴ�
 */
void calendar_get_day_cell_rect_by_index(const SCalendar* calendar,CGRect* rect,int idx)
{
   assert(calendar && rect && idx >= 0 && idx < 42);
   // ��/ �� %�����ŵ�Ӧ�ã����ڼ��������������
   int rowIdx   = (idx / 7);
   int columIdx = (idx % 7);
   calendar_get_day_cell_rect(calendar, rect, rowIdx, columIdx);

}

/*
 blf:
 ���touchPoint�Ƿ��������������ĳһ��cell��
 �����⵽��cell�����У���������
 ���򷵻أ�1

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
ע��: ����localPt������������̳е�View�����Ͻ�[0,0]��ƫ�������Ƕ�����View�ռ�����ϵ��
 */
int calendar_get_hitted_day_cell_index(const SCalendar* calendar, CGPoint localPt)
{
   //�Ż�1: ���һ���㲻�����������У���ô�϶�û���У���������
   CGRect daySec;
   calendar_get_day_section_rect(calendar, &daySec);

   if(!CGRectContainsPoint(daySec,localPt))
      return -1;

   localPt.y -= daySec.origin.y;

   //������϶����������������е�ĳ��cell

   //�Ż�2: ����ʹ��ѭ��6*7�α�������cell������Ƿ�һ���ڸ�cell��,ͨ�������㷨���������̻�õ�ǰ�����ڵ�cell����������

   float cellWidth  =   daySec.size.width  / 7.0F;
   float cellHeight =   daySec.size.height / 6.0F;
   int   columIdx   =   localPt.x / cellWidth;
   int   rowIdx     =   localPt.y / cellHeight;

   //��⵱ǰ�����е�cell�Ƿ�����ѡ�У�����ԭ����ο�
   //����void calendar_set_year_month(SCalendar* calendar,int year,int month)��ע��

   int idx  =  rowIdx * 7 + columIdx;
   if(idx < calendar->dayBeginIdx || idx > calendar->dayBeginIdx  + calendar->dayCount - 1)
      return -1;

   //����˵���϶��е��е�cell,���ظ�cell��������
   return idx;
}
```