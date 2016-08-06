###����IOSʵ�ְ汾��
1������ṹ:
ǧ���������һ��ͼ��������
![CalendarUML.png](http://upload-images.jianshu.io/upload_images/2635028-3345a7dd0aecd174.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    1) ����CalendarController������һ��UITableViewָ�룬���CalendarController��Ҫʵ��UITableDataSource�Լ�UITableViewDelegate��UITableView���н�����
    2) UITableView�������CalendarView��������������UITableView�����ƻ��������Լ�Cell���ù��ܡ�
    3) CalendarView�̳���UIControl����ΪUIControl����Եײ�Ĵ����¼�ת��Ϊ���ײ����Ŀؼ��¼�����ҪΪ��ʹ��UIControlEventTouchUpInside����¼��� 
    4) CalendarDelegate����ios mvcģʽ��������֮��Ľ���(����ӿڱ��)�Լ���֮���ͨ�š�

2�� CalendarDelegate Э��:
```
@protocol CalendarDelegate <NSObject>

//���º�UITableView�Լ�����CalendarView֮���ϵӳ��
//���������������
-(int)    calcCalendarCount;
-(SDate)  mapIndexToYearMonth : (int) index;
-(int)    mapYearMonthToIndex : (SDate) date;

//������ʾ��ָ�������·�Χ
-(void)   showCalendarAtYearMonth : (SDate) date;

//����ʱ�����޹����Լ�ѡ���ж�
-(BOOL)   isInSelectedDateRange : (SDate) date;
-(void)   setSelectedDateRangeStart : (SDate) start end : (SDate) end;
-(void)   setEndSelectedDate : (SDate) end;

//��ʹ����UITableView�ػ�
-(void)   repaintCalendarViews;

//�������������ж�touch����
-(void)   updateHitCounter;
-(int)    getHitCounter;

@end
```
3�� CalendarController: 
![Calendar_IOS.png](http://upload-images.jianshu.io/upload_images/2635028-4e1a5c73928232ae.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
######CalendarController������
```
//.h�ļ��ӿ�����
#import <UIKit/UIKit.h>

@interface ViewController :UIViewController
@end
```
```
//.m�ļ�
#import "ViewController.h"
#import "CalendarDelegate.h"
#import "CalendarView.h"

//ʵ������������delegate
@interface ViewController () <UITableViewDataSource,UITableViewDelegate,CalendarDelegate>
{
    //���ڼ�������ٸ�������������������
    int      _startYear;
    int      _endYear;

    //ÿ�������ؼ��ĸ߶ȣ�����ĸ����ʹ˵صĸ߶ȣ��Ϳ��Լ�������UITableView�ĸ߶��Լ����ж�λ����
    float    _calendarHeight;
    
    //����ѡ�в���ʱ��ʱ�䷶Χ�ıȽϣ�time_tʵ���Ǹ�64λ������ֵ���ʺ����Ƚϲ��������忴ʵ�ִ��룩
    time_t   _startTime;
    time_t   _endTime;
}

//ѡ��ֵ�����±�ʾ��ʽ��������ʾ���ѣ�ʵ�ʲ�����ת����time_t����
@property  (nonatomic,assign)  SDate  begDate;
@property  (nonatomic,assign)  SDate  endDate;

//���������������ȷ����ǰ�������ż�ԣ���˸������ؼ��漰���β�������������ѡ��
@property (nonatomic)  int  hitCounter;

//��ΪCalendar�ĸ����������ڴ������Լ�cell����
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
```
######CalendarDelegate��Э�麯��calcCalendarCount��ʵ�ֺ͵���
```
-(int) calcCalendarCount
{
    SDate date;
    date_get_now(&date);
    
    //�������ǰ�����µ�n��ǰ��1�·ݵ�����
    //���赱ǰΪ2016��8�£�nΪ5�����·ݷ�ΧΪ��2011��1�£�����2016��8�� �ܼ�����Ϊ68��,�����㷨����:
    int diff = _endYear - _startYear + 1;
    diff = diff * 12;
    diff -= 12 - date.month;
    return diff;
}

//UITableView��DatatSource�и�����ʵ�ֵ�Э�麯�������ڷ��ص�ǰUITableView�������ɵ�����:
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int ret = [self calcCalendarCount];
    return ret;
}
```
######UITableViewDelegate��Ҫʵ�ֵ�һ��Э�麯��:
```
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   //���ص��ǵ�ǰ��calendarView�ĸ߶�
   //UITableView��Ҫ֪������(�·�)�ĸ����Լ������ؼ��ĸ߶ȣ��Ϳ��Լ��������UITableView��Content��height��
    return _calendarHeight;
}
```
######CalendarDelegateЭ�����������·�ӳ���ϵ�Լ�UITableView��CalendarView�Ķ�λ����:   
ǧ�������������һ��ͼ��������

![idx_map_pos.jpg](http://upload-images.jianshu.io/upload_images/2635028-7e10c96cb673ee63.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```
-(SDate) mapIndexToYearMonth : (int) index
{
    SDate ret;
    //����c��������������ӳ������£�����UITableView����calendarViewʱ��ʵ��������
    date_map_index_to_year_month(&ret, _startYear, index);
    return ret;
}

//����mapIndexToYearMonth:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* calendarID = @"calendarID";
    
    float width = self.tableView.frame.size.width;
    
    //����������ӳ�䵽����
    SDate date = [self mapIndexToYearMonth:(int)indexPath.row];
    
    //��ȡ���õ�cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:calendarID ];
    
    //���Ϊnull��˵�������ڣ�������cell
    if(cell == nil)
    {
        //�����ڴ˶ϵ㣬�鿴һ�¾��������˶��ٸ�calendarView(������������3����
        //˵��UITableView�ɼ�rect������calendarView�ཻ
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:calendarID];
        [cell setTag:10];
        
        //�ֶ�����CalendarView
        CalendarView* calendarView = [[CalendarView alloc] initWithFrame:CGRectMake(0, 0, width, _calendarHeight)];
        
        //����CalednarDelegate
        calendarView.calendarDelegate = self;
        
        //����һ��tag�ţ���������ʱ��ø�view
        [calendarView setTag:1000];
        
        [cell.contentView addSubview:calendarView];
    }
    
    //ͨ��tag�ţ���ȡview
    CalendarView* view =(CalendarView*) [cell.contentView viewWithTag:1000];
    
    //����CalendarView������
    [view setYearMonth:date.year month:date.month];
    
    //[view setNeedsDisplay];
    
    return cell;
}


-(int) mapYearMonthToIndex:(SDate)date
{
    int yearDiff = date.year - _startYear;
    int index = yearDiff * 12;
    index += date.month;
    index -= 1;
    return index;
}

//����mapYearMonthToIndex
-(void) showCalendarAtYearMonth:(SDate)date
{
    if(date.year < _startYear || date.year > _endYear)
        return;

    //�����±�ʾӳ���UITableView�е������ţ��������������Ҫ��������Ŀ�ĵ�
    int idx = [self mapYearMonthToIndex:date];

    //����ͼ��ʾ:��idx = calendarViews.length-1ʱ�����ܴ��ڳ�������UITableView ContentSize.height�������ʱ��UITableView���Զ�����contentOffset��ֵ��ʹ����϶�λ����׶ˣ�android listviewҲ����ˡ�
    self.tableView.contentOffset = CGPointMake(0.0F, idx * _calendarHeight );
}
```
     1) ����ͼ�Լ����룬Ӧ�ú�������˽���ӳ��Ͷ�λ����Ĺ���
     2) ����ͼ�У�����Ҳ�����˽⵽UITableView�Ĺ���ԭ��,UITableView��Frame��Clip���򣬹��������ݴ����Content�С�
     3) UITableView����˵���ƶ���������ã�����Ҫ��һ���ؼ�������һ����UICollectionView������������Ҫ���ܵ㣺����(UIScrollView����)��cell���á��Ժ��л�����������ͷ��βʵ��һ�������������ܵĿؼ���

######��������Ĵ��룬���ǾͿ��Գ�ʼ��CalendarController:
```
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //��ȡ��ǰ������
    SDate date;
    date_get_now(&date);
    
    //default��3��
    _startYear   = date.year-3;
    _endYear     = date.year;
    
    /*
    //����Ҳ֧��
    _startYear   = date.year;
    _endYear     = date.year;
    */
    
    //touch ������
    _hitCounter  = 0;
    
    float scale = 0.6F;//Ӳ���룬������ⲿ����
    //float scale = 0.5F;//Ӳ���룬������ⲿ����
    _calendarHeight  = self.tableView.frame.size.height * scale;
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //default��λ��ʾ��ǰ�·�
    if (self.begDate.year == 0) {
        self.begDate = date;
        [self showCalendarAtYearMonth:date];
    }else{
         //��Ȼ��Ҳ�������þ����·��ص���ʾ
        [self showCalendarAtYearMonth:self.begDate];
    }
}
```
 ��ĿǰΪֹ��֧��CalendarController���е����з�����������ϣ�����������Ҫ��һ��CalendarView��ص�ʵ�֡���CalendarDelegate����һЩ����û��������Ϊ��Щ��������CalendarView���õģ��ɴ˿ɼ���IOS�е�Delegate��������ӿڱ���⣬����һ�����ܾ���**��֮���ͨ��**)  

4�� CalendarView:
######CalendarView������:
```
//.h�ļ�
@interface CalendarView : UIControl
-(void) setYearMonth : (int) year month : (int) month;
@property (weak, nonatomic) id  calendarDelegate;
@end
```
```
//.m�ļ�
@interface CalendarView()
{
    /*
     blf: 
         ����c�ṹ������������ز���ί�и�SCalendar����غ���
         SCalendar ʹ��ջ�ڴ����
    */
    SCalendar         _calendar;
    
    //����һ������Ҫ�ı���������Դ����˵��
    int               _lastMonthDayCount;
    
    //������������ں������ַ���
    NSMutableArray*   _dayAndWeekStringArray;
    
    //string����ʱ�Ĵ�С
    CGSize            _dayStringDrawingSize;
    CGSize            _weekStringDrawingSize;
}
```
######CalenderView��ʼ��: 
```
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //�����������������Ĵ�С����ǰview�߶ȵı������趨
        float yearMonthHeight = frame.size.height * 0.095F;
        float weekHeight = frame.size.height * 0.089F;
        
        //��ʼ�������ؼ���������������鲿�ֵĴ�С
        calendar_init(&_calendar, frame.size, yearMonthHeight, weekHeight);
        
        
        SDate date = _calendar.date;
        
        //��ʱdate���ϸ���
        date_get_prev_month(&date, 1);
    
        
        self.backgroundColor = [UIColor clearColor];
        
        //������������Ĵ�С
        CGRect rc;
        calendar_get_day_cell_rect(&_calendar,&rc,0,0);
        CGSize size;
        size.height = rc.size.height- 15 ;
        size.width  = rc.size.width - 15;
        
        //Ԥ�ȷ���38���ַ�������������
        _dayAndWeekStringArray = [NSMutableArray arrayWithCapacity:38];
        
        //0-��30��ʾ���31�������ַ���
        for(int i = 0; i < 31; i++)
            [_dayAndWeekStringArray addObject: [NSString stringWithFormat:@"%02d",i+1]];
        
        //31--37�洢�����ַ���
        [_dayAndWeekStringArray addObject:@"����"];
        [_dayAndWeekStringArray addObject:@"��һ"];
        [_dayAndWeekStringArray addObject:@"�ܶ�"];
        [_dayAndWeekStringArray addObject:@"����"];
        [_dayAndWeekStringArray addObject:@"����"];
        [_dayAndWeekStringArray addObject:@"����"];
        [_dayAndWeekStringArray addObject:@"����"];
        
        //����������ַ����Ļ����óߴ�
        _dayStringDrawingSize   = [self getStringDrawingSize: [_dayAndWeekStringArray objectAtIndex:0]];
        //����������ַ����Ļ����óߴ�
        _weekStringDrawingSize  = [self getStringDrawingSize: [_dayAndWeekStringArray objectAtIndex:31]];
        
        //UIControl���ڿؼ����¼�����ϵͳ���ҽ�UIControlEventTouchUpInside�������
        [self addTarget:self action:@selector(handleTouchEvent:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

//����Ҫ�����ַ����ĳߴ�ĺ�������:
-(CGSize) getStringDrawingSize:(NSString*)str
{
    
    NSAttributedString* attStr = [[NSAttributedString alloc] initWithString:str];
    NSRange range = NSMakeRange(0, attStr.length);
    NSDictionary* dic = [attStr attributesAtIndex:0 effectiveRange:&range];
    
    CGRect rect = [str boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    return rect.size;
}
```
�������������ͳ�ʼ�����룬������������:

    1)Ϊʲô�̳���UIControl?
    2)Ϊʲôdelegateʹ��weak?
    3)Ϊʲôdelegate ����Ϊid?
    4)Ϊʲôջ����?
    5)Ϊʲôͬһ��CalendarView����������Ҫ�ֱ���.h��.m�ļ��У����߻���˵��:��������ʲô�ô�?
    6)Ϊʲô��ʼ��ֻʵ����initWithFrame��û��ʵ��initWithCoder������������£�����Ҫoverride initWithCoder����?

####���´ι���������Ȥ�ģ��������Իش𣡺ǺǺǣ�����

######CalendarView�ַ������ж�����ƺ���:
```
-(void) drawStringInRectWithSize : (NSString*) string rect:(CGRect)rect size:(CGSize) size color : (UIColor*) color
{
    CGPoint pos;
    //�����㷨��������λ��Ҫ���Ƶ�Rect��ˮƽ�ʹ�ֱ����
    //Ҳ���Ǿ��ж���
    pos.x = (rect.size.width - size.width) * 0.5F;
    pos.y = (rect.size.height - size.height) * 0.5F;
    pos.x += rect.origin.x;
    pos.y += rect.origin.y;
    
    //�������պ�������ƽ��������ɫ�в�������Ҫcolor
    NSDictionary * attsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               color, NSForegroundColorAttributeName,
                               nil ];
    
    [string drawAtPoint:pos withAttributes:attsDict];
}
```
######CalendarView shape���ƺ���:
        1) opengles API ����gpu���٣��ٶ���죬�Ѷ����������ɶ�Ҳ��ߣ���Ҫ����ר�õ�GL�����Ļ���������״̬��ģʽ����Ҫ���ø��ֻ���״̬�Լ��ָ�״̬������Ҫ���ǿ�ƽ̨��android�Լ�windows��Linux��������(cocos2d-x����opengles)��
        2) quartz API ʹ��cpu��դ��������ҪGL�����Ļ�����ֱ�ӿ��ڿؼ�������л���,��Եײ㣬����״̬��ģʽ����Ҫ���ø��ֻ���״̬�Լ��ָ�״̬
        3) UIKit�ж�quartz API�Ķ��η�װ������UIBezierPath�࣬��װ�˴󲿷ֵ�shape���������ã����Ǿ�������������л��ơ���������API,�Ժ��л������ǿ���ר��������һ�¡�

Բ�ı�����·������(��Բ�ĺͰ뾶����):
```
-(void) drawCircleInRect : (CGRect) rect color : (UIColor*) color isFill : (BOOL) isFill
{
    //ȡwidth��height��С��ֵ��ΪҪ���Ƶ�Բ��ֱ���������Ͳ��ὫԲ���Ʒ�Χ����rect
    float radiu = rect.size.width < rect.size.height ? rect.size.width : rect.size.height;
    
    //��Բ�����ĵ��rect�����Ͻ�ƽ�Ƶ�rect�����ĵ�
    CGPoint center;
    center.x = rect.origin.x  + rect.size.width * 0.5F;
    center.y = rect.origin. y + rect.size.height * 0.5F;
    //Բ����Բ�ĺͰ뾶�����
    radiu *= 0.5F;
    
    //����һ��Բ��bezier·������
    UIBezierPath* circle = [UIBezierPath bezierPathWithArcCenter:center radius:radiu startAngle:0.0F endAngle:2.0F*3.1415926F clockwise:true];
    
    //�����ƣ�����ѡ��״̬��
    if(isFill == YES)
    {
        [color setFill];
        [circle fill];
    }
    else
    {
        //ûѡ��״̬����stroke��ʽ����
        [color setStroke];
        [circle stroke];
    }
}
```
Բ�Ǿ��εı���������(��Rect�Ͱ뾶����):
```
-(void) drawRoundRect : (CGRect) rect  radius : (CGFloat)radius
{
    UIBezierPath* roundRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [[UIColor colorWithRed:52/255.0 green:175/255.0 blue:248/255.0 alpha:1.0] setFill];
    [roundRect fill];
}
```

![calendarDraw.png](http://upload-images.jianshu.io/upload_images/2635028-0f500103b12d237a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

######override drawRect�������ӹ����л�ͼ:
����ܳ������ǲ�ֳɼ�������������
```
//1������ͼ������������Ϣ

    //blf:��ȡԭ����ͼcontextָ�룬����ԭ����ͼapi����c����api��ʽ
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rc;
    calendar_get_year_month_section_rect(&_calendar, &rc);
    //NSString* drawStr = @" " + _calendar.date.year + @"��" + _calendar.date.month + @"��";
    NSString* drawStr = [NSString stringWithFormat:@"%d��%d��",_calendar.date.year,_calendar.date.month];
    
    //����������Ϣ
    [self drawYearMonthStr:drawStr rect:rc];
```
```
//2������ͼ������������Ϣ

    //_dayAndWeekStringArray��31-37����������������ַ���
     for(int i= 0; i < 7; i++)
    {
        //��ȡ����������ĳ��cell��rect
        calendar_get_week_cell_rect(&_calendar, &rc, i);
        if(i == 0 || i == 6)
        {
            //˫���պ�ɫ
            [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex:31 + i] rect:rc size:_weekStringDrawingSize color: [UIColor blackColor]];
        }
        else
        {
            //����ʱ����ɫ
            [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex:31 + i] rect:rc size:_weekStringDrawingSize  color: [UIColor blueColor]];
        }
    }
```
```
//3������ͼ��ɫ�߿򲿷֣������ϸ���������Ϣ
    CGPoint dayRectOffset;
    //��ȡ���������rect
    calendar_get_day_section_rect(&_calendar, &rc);
    //��¼�����������ʼλ��
    dayRectOffset = rc.origin;
    
    //��ǰ�·�1��������cells�е���ʼ������
    int begin = _calendar.dayBeginIdx;
    //��ǰ�·ݽ���������
    int end   = begin + _calendar.dayCount;
    
    //�����ϸ��µ����ڣ�����begin �� 5 i=[4,3,2,1,0]
    for(int i = begin - 1; i >= 0; i--)
    {
        calendar_get_day_cell_rect_by_index(&_calendar, &rc, i);
        
        //�����λ��ƫ����
        rc.origin.x += dayRectOffset.x;
        rc.origin.y += dayRectOffset.y;
        
        //��Сһ�»���rect�ĳߴ����
        rc.origin.x += 5;
        rc.origin.y += 5;
        
        rc.size.width -= 10;
        rc.size.height -= 10;
        
        //����ԲȦ
        [self drawCircleInRect:rc color:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0] isFill:YES];
        
        //���㷽ʽ�漰����_lastMonthDayCount
        //�����ϸ�����30�죬���µ�beginΪ5����
        //��30��(5-4)�� 29 ---->0base--->30��
        //  30- (5-3)= 28 ---->0base--->29��
        //  30- (5-2)= 27 ---->0base--->28��
        //  30- (5-1)= 26 ---->0base--->27��
        //  30- (5-0)= 25 ---->0base--->26��
        int dayIdx = _lastMonthDayCount - (begin - i);
        
        //����ԲȦ�е�����
        [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex: dayIdx] rect:rc size:_dayStringDrawingSize color:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1.0]];
    }
```
```
//4������ͼ��ɫ�߿򲿷֣������¸���������Ϣ
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
        
        //������i-end������������
        [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex: i - end] rect:rc size:_dayStringDrawingSize color:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1.0]];
        
    }
```


![jacky_bu_draw.png](http://upload-images.jianshu.io/upload_images/2635028-cfe7a4734177f8af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
######��ǰ�·ݵĻ��Ʒ�Ϊѡ��״̬�����ڻ��ƺͷ�ѡ��״̬���ڵĻ��ƣ���ͼ��ѡ��״̬���Ƶ�˵��ͼ
```
typedef struct _selectRange
{
    int      rowIdx; //Ϊ�˷��㴦���Ƿ�ͬһ��
    int      columIdx;//����ת��һγ��������
    CGRect   rect; //��¼Ҫ���Ƶ�rect
} selectRange;
```
```
//5�����Ƶ�ǰ�·ݵ����ڣ�����ѡ�У�δѡ���Լ���������

    //ʹ��c�ṹ������ʼ����ر���
    selectRange  ranges[31];
    memset(ranges,0,sizeof(ranges));
    int          rangeCount = 0;
    
    //���Ƶ�ǰ�µ�����
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
        
        //�����ǰ������ѡ��ʱ�䷶Χ�ڣ���batch��������drawSelectRange���л���
        //��Ϊ��Ҫ����������Ч��(drawSelectRange�д�����˻����������δ���ȽϷ��㣩
        //��delegateͨ��
        if([self.calendarDelegate isInSelectedDateRange:date])
        {
            
            ranges[rangeCount].rowIdx = i / 7; //ӳ���������
            ranges[rangeCount].columIdx = i % 7; //ӳ���������
            ranges[rangeCount].rect = rc; //��ǰ���е�rect��¼����
            rangeCount++; //����������1
        }
        else
        {
            
            //û��ѡ�еģ���ֱ�ӻ���ԲȦ�͵��е����ں�
            [self drawCircleInRect:rc color:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1.0] isFill:NO];
            [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex: i - _calendar.dayBeginIdx] rect:rc size:_dayStringDrawingSize color:[UIColor colorWithRed:107/255.0 green:107/255.0 blue:107/255.0 alpha:1.0]];
        }
    }
    
    //NSLog(@"select day count = %d",rangeCount);
    //rangeCount��¼��ѡ�е�������ranges���¼��Ҫ���Ƶ�������Ϣ
    [self drawSelectRange:ranges count:rangeCount];

    //ѡ�е�ȦȦ������������������
    for(int i = 0; i < rangeCount; i++)
    {
        //���½����У���ά��������ӳ��һγ����������
        int idx = ranges[i].rowIdx * 7 + ranges[i].columIdx;
        //idx - begin���ǵ�ǰ��Ҫ���Ƶ��������ֵ�������
        [self drawStringInRectWithSize:[_dayAndWeekStringArray objectAtIndex: idx - begin] rect:ranges[i].rect size:_dayStringDrawingSize  color:[UIColor whiteColor]];
    }
```
######�ؼ���drawSelectRange����:
```
//blf��ע�� ����ranges������������������ʾ������׵�ַ
//         ���о���selectRange��c�ṹ������ָ�����ʱҪ��->������.Ѱַ������
-(void) drawSelectRange : (selectRange* ) ranges count : (int) count
{
    //���������count = 1
    //��һѡ�򣬻��ߵڶ���ѡ�еĺ͵�һ��ѡ�е���ͬһ������cell
    //��ʱ�ǻ���Բ�ζ�����roundedRect
    if(count == 1)
    {
        [self drawCircleInRect : ranges[0].rect color:[UIColor colorWithRed:52/255.0 green:175/255.0 blue:248/255.0 alpha:1.0] isFill:YES];
        
        //�˳�����
        return;
    }
    
    //�����ǵ�һ��ѡ���ҵڶ���ѡ�߲��Ǻ͵�һ��ѡ��һ��ʱ
    
    //��ȡcell rect��width
    CGRect rect;
    calendar_get_day_cell_rect_by_index(&_calendar, &rect, 0);
    float width = rect.size.width;
    
    //���ڼ�¼��һ�ε��кţ���ʼ������¼���ǵ�һ�е�������
    int lastRowIdx = ranges[0].rowIdx;
    //��������������¼��ǰ�е�cell������
    int sameRowCellCount = 0;
    
    for(int i = 0; i < count; i++)
    {
        //��ranges�����л�ȡһ���ṹʱ��ʹ����&ȡ��ַ������
        //��Ϊ��ֹ�����������������ȡ��ַ�Ļ�����ֵ�ᷢ��memcopy��Ϊ
        selectRange* range = &ranges[i];
        //�к���ͬ����ͬһ����
        if(range->rowIdx == lastRowIdx)
        {
            sameRowCellCount++;
        }
        else
        {
            //�кŲ�ͬ��˵�������ˣ����Ҫ���Ƶ�ǰ��
            CGRect rc;
            //i - sameRowCellCount�ҵ���ʼ����
            rc.origin = ranges[i - sameRowCellCount].rect.origin;
            rc.size.height = range->rect.size.height;
            rc.size.width = width* (sameRowCellCount) - 10.0F;
            
            //�ܿ��ܴ��������������ѡ�е���������ʼ�ģ���˻��Ƶ���Բ�ζ�����roundedRect
            if(sameRowCellCount == 1)
            {
                [self drawCircleInRect:rc color:[UIColor colorWithRed:52/255.0 green:175/255.0 blue:248/255.0 alpha:1.0] isFill:YES];
            }
            else
            {
                //һ�����������roundedRect
                [self drawRoundRect:rc radius:rc.size.height];
            }
            
            sameRowCellCount = 1;//���ֵ��Ϊ������������һ�еĴ���ʹ�ã���1��>1Ҫ�ֱ���
            
            //��¼��һ�ε��к�
            lastRowIdx = range->rowIdx;
        }
    }
    
    //�����һ�в�ֳ����������������ͷ��㴦��һЩ�������
    
    //�������һ��
    if(sameRowCellCount > 0)
    {
        CGRect rc;
        rc.origin = ranges[count - sameRowCellCount].rect.origin;
        rc.size.height = ranges[count - sameRowCellCount].rect.size.height;
        rc.size.width  = width* (sameRowCellCount) - 10.0F;
        
        //���һ���ж��cell��ѡ��
        if(sameRowCellCount != 1)
        {
            [self drawRoundRect:rc radius:rc.size.height];
        }
        else//���һ�н����ձ�ѡ�У�ֻ��һ����ԲȦ
            [self drawCircleInRect:rc color:[UIColor colorWithRed:52/255.0 green:175/255.0 blue:248/255.0 alpha:1.0] isFill:YES];
   
    }
}
```
######���ˣ�CalendarView�Ļ�ͼ���ִ���ȫ����ϣ�������������delegateͨ�ŵ�ѡ���жϺ���:
```
//����UITableView������cell���û��ƣ���˽��к���Ļrect�ཻ��cell����
//������cellsһֱ���潻�����������Ǳ�����ÿ���Ի�ʱ���жϵ�ǰ��cell�е�������ÿ�������Ƿ���ѡ��״̬
//�����������������������ã��ж�������ĳ�������Ƿ���ѡ�е����䷶Χ
-(BOOL)isInSelectedDateRange : (SDate) date
{
    time_t curr = date_get_time_t(&date);
    
    if(curr < _startTime || curr > _endTime)
        return NO;
    
    return YES;
}
```
######�ؼ�������������IOS��android����windows���������ڣ�������׾�����4������:  
       �ؼ���״̬��ʼ��  
       �ؼ��Ļ���  
       �ؼ����¼������ʹ���  
       �ؼ��Ĳ���
######���������ǿ�����δ���CalendarView�Ĵ����¼�:
```
-(void) handleTouchEvent:(id) sender forEvent:(UIEvent *)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    
    //��ȡUITouch,����ת������ǰCalendarView�ľֲ�����ϵ��ʾ
    CGPoint upLoc = [touch locationInView:self];
    
    //ͨ���ֲ�����ϵ�ĵ��ȡ�������cell�������ţ��Ż������뿴c�����ʵ��
    //�����ײ���ԭ��ʵ������Ϸ�о���ʹ�ã�������С��Χ��Ȼ����÷�Χ�������������㣨2D��
    //����ߣ�3D���Ƿ�����ײ�����ڴ˴�Ҳ�ǳ��ʺ�
    int hitIdx = calendar_get_hitted_day_cell_index(&_calendar, upLoc);
    
    //ѡ���ˣ���
    if(hitIdx != -1)
    {
        SDate date;
        date_set(&date, _calendar.date.year, _calendar.date.month, hitIdx - _calendar.dayBeginIdx + 1);
        
        //=0Ϊ��һ�ε������ѡ��һ��cell
        //modΪ���ܶ���ʼ�����ڣ�0��1��֮��
        if([self.calendarDelegate getHitCounter] % 2 == 0)
        {
            //��һ�ε�����ÿ�ʼ�ͽ���Date��ͬ
            [self.calendarDelegate setSelectedDateRangeStart:date end:date];
        }
        else//=1Ϊ�ڶ��ε�����γ�ѡ��
        {
            [self.calendarDelegate setEndSelectedDate:date];
        }
        
        //ÿ�ε����delegate�еĵ����������Ҫ������
        [self.calendarDelegate updateHitCounter];
        
        //��Ҫ�����ػ棬��ios�������»��ƣ�����ܹؼ�����һЩϸ�ڣ��������˵����
        [self.calendarDelegate repaintCalendarViews];
    }
    
}
```
######������һ���ػ���룬Ȼ���Ƶ�һЩϸ��:
```
//����CalendarDelegate�Ľӿں�����ʵ�ִ�������:
-(void) repaintCalendarViews
{
    //[self.tableView setNeedsDisplay];

    for(UIView * subview in self.tableView.subviews)
    {
        for(UIView* view2 in subview.subviews)
        {
            UITableViewCell* cell = (UITableViewCell*)view2;
            CalendarView* cview  =(CalendarView*) [cell.contentView.subviews objectAtIndex:0];
            [cview setNeedsDisplay];
        }
    }
}
```
 ######������ĵĴ��룬�����˽⵽��δ�UITableѰַ������CalenderView:  UITableView->UITableViewCell->ContentView->CalendarView->setNeedsDisplay

    1) ����calendarView��ѡ����ܿ�Խ���CalendarView����˲��ܽ�����CalendarView����setNeedsDisplay��������Ҫ������UITableView�Լ�������������ؼ���Ҫ�ػ档
    2) ��������˼·������UITableView�ϵ���setNeedsDisplay����ᷢ����Ч��
    3) �ɴ˿ɼ���IOS�е������ֲ�ˢ�»��Ʋ��õ����Կؼ�Ϊ�����ĺ󱸻���ͼ����������������ĻΪ�����ĺ󱳻���ͼ��
    4) �Կؼ�Ϊ�����ĺ󱸻���ͼ�ڴ����ĸߣ������ܹ�����ظ����ƣ����Ч�ʣ����͵��Կռ任ʱ����ԡ�
        ����һ��΢��Դ��ĿWinObjc���ǳ�ǿ�󣬿�����gitHub��ȥ���ҡ�
        Ϊwin10��Winphoneʵ��������ios sdk��Ŀ������ios��appֱ����winphone���ܡ�
        ���о����������ֲ�ˢ�µĻ��ƣ�������˧�ġ�
        foundation��uikit, glkit,spritekit,gamekit,homekit....����kit��ʵ���ˡ���������Ҫ������Դ�롣
    5) ��������Ļ(����˵����APP��ʾ���ڵ��size)Ϊ��С�ĺ󱸻���������ֻ��Ҫ����һ���ڴ�λͼ��
       ��ȡ�����󣬽����ݹ�������Լ����к͸��ڵ������ཻ���ֵ����� ���и��£���˸���������𽥼�С�����ǲ�����ȫȥ���ظ����ơ�
       ������ʵ����opengl��dx�汾��2D�ֲ�ˢ�»��ƣ����뵽һ��2d UI�����У����ú󱳻������Լ�
       �����޸�ͶӰ����ʽ���ڹ�դ��֮ǰ�ü������в��ɼ��Ķ����
       ����Ⱦ�ٶȷ�����ߣ�����CPUʹ���ʿ�����5%���£��󲿷�ʱ�䶼��
       ��1%)��Դ�벻�ܹ�������Ϊ����ҵ���룬����demo�Ժ������github�����أ���˧��IPhone4����ģ�⡣

######���м���delegate���õ���Э�鷽��:
```
#define MYSWAP(x,y,type)    \
{                           \
    type t = x;             \
    x = y;                  \
    y = t;                  \
}

-(void)setSelectedDateRangeStart:(SDate)start end:(SDate)end
{
  
    //��dateת��Ϊtime_t
    _startTime = date_get_time_t(&start);
    _endTime   = date_get_time_t(&end);
    
    //�����ʼʱ����ڽ���ʱ�䣬˵���ȵ����һ�죬�ٵ��ǰһ�죬����ʱ���߼�����ȷ����Ҫ����һ��ʱ��
    if(_startTime > _endTime)
    {
        MYSWAP(_startTime,_endTime,time_t);
        
        //��¼�����±�ʾ��ʼ����date
        _begDate = end;
        _endDate = start;
        
    }else{
        
        _begDate = start;//��¼����
        _endDate = end;
    }
}

-(void)setEndSelectedDate:(SDate)end
{
    //ͬ�ϣ�ֻ����Եڶ��ε������
    _endTime = date_get_time_t(&end);
    if(_startTime > _endTime)
    {
        MYSWAP(_startTime,_endTime,time_t);
        _endDate = _begDate;
        _begDate = end;
    }else{
        _endDate = end;
    }
}

-(void) updateHitCounter
{
    _hitCounter++;
}

-(int) getHitCounter
{
    return _hitCounter;
}
```
���ˣ�IOS�汾��Դ��ȫ��������ϣ�ϣ���Դ���а����� 

���ڿؼ��Ĳ��֣���DEMO��ûʲô�õ����ؼ��Ĳ��ֿ���˵�ǱȽϸ��ӵĲ��֣��и����㷨�����ַ������Ǹ��Ƚϴ�����⣬�Ժ��л���̽�֡�

������˵��apple��˾��objc������ǰ�˳���Clang֧��Objc,c,c++�Ĵʷ�������AST�Ĳ�����Ȼ�����llvm,���ɶ�ӦCPU��ָ�����IOS�����У����ڶ��Ƕ����ƣ�����Ч�ʷǳ���(ƻ����˾������ʹ����������뷽ʽ��ֻ���Ծ�̬���ӿ⡾�����ơ���ʽ ����app,��Ч��  ���Է����룬�����Էǳ���ȫ��Ψһ��������������������е�js����)��

######IOS������ϣ���һƪ��android�йء�����Ios objc��c��c++֧�ַǳ��ã�����ûʲô�Ѷȣ�����android�ͺܸ����ˣ������Ҹ�����Ϊ���м�ֵ����ƪ�У����ǲ����Դ���Ϊ���������˽�android����η��㣬��Ч�Ľ���JNI������

######���ˣ�ʵ���������Դ�뻹���Ը�����Ż�����ҿ��Խ��飬̽�֡�