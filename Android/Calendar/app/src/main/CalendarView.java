package com.blf.calendar;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.text.TextPaint;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

import java.util.ArrayList;

/**
 * TODO: document your custom view class.
 */

/*
blf:由于需要点击处的坐标，因此使用用OnTouchListener而不是OnClickListener
*/
public class CalendarView extends View implements View.OnTouchListener {

    private SCalendar mCalendar;
    private CGSize    mCalendarSize;

    private CalendarController mController = null;

    private int mLastMonthDayCount = 0;

    private CGSize _dayStringDrawingSize;
    private CGSize _weekStringDrawingSize;

    private ArrayList<String> _dayAndWeekStringArray = new ArrayList<String>(38);

    private CGRect mTempRC = new CGRect();
    private RectF  mTempAndroidRC = new RectF();
    private Rect   mTempAndroidRCInt = new Rect();
    private SDate  mTempDate = new SDate();
    private CGPoint mTempPoint = new CGPoint();

    private TextPaint.FontMetrics mFontMetrics;
    private TextPaint mTextPaint;
    private Paint mColorPaint;

    private int mDayNormalCellFontColor = Color.rgb(223,223,223);
    private int mDayNormalCellCircleColor = Color.rgb(245,245,245);

    public void setController(CalendarController ctrl)
    {
        mController = ctrl;
    }

    public CalendarController getController()
    {
        return mController;
    }

    private class SelectRange
    {
        int rowIdx;
        int columnIdx;
        RectF rect;
    }

    SelectRange[] mRanges = null;

    public CalendarView(Context context) {
        super(context);
        init(null, 0);
    }

    public CalendarView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(null, 0);
    }

    public CalendarView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(null, 0);
    }

    private void init(AttributeSet attrs, int defStyle) {
        // Load attributes
        /*
        final TypedArray a = getContext().obtainStyledAttributes(
                attrs, R.styleable.CalendarView, defStyle, 0);

        mCurrentYear = a.getInteger(
                R.styleable.CalendarView_currentYear,2016);
        mCurrentMonth = a.getInteger(
                R.styleable.CalendarView_currentMonth,5);

        a.recycle();
        */

        this.setBackgroundColor(Color.TRANSPARENT);

        // Set up a default TextPaint object
        mTextPaint = new TextPaint();
        mTextPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        mTextPaint.setTextAlign(Paint.Align.LEFT);

        mColorPaint = new Paint();
        mColorPaint.setAntiAlias(true);
       // mColorPaint.setColor(Color.GRAY);

        // Update TextPaint and text measurements from attributes
        invalidateTextPaintAndMeasurements();

        for(int i = 0; i < 31; i++)
        {
           _dayAndWeekStringArray.add( String.format("%02d",i+1));
        }

        _dayAndWeekStringArray.add("周日");
        _dayAndWeekStringArray.add("周一");
        _dayAndWeekStringArray.add("周二");
        _dayAndWeekStringArray.add("周三");
        _dayAndWeekStringArray.add("周四");
        _dayAndWeekStringArray.add("周五");
        _dayAndWeekStringArray.add("周六");

        _dayStringDrawingSize = getStringDrawingSize(_dayAndWeekStringArray.get(0));
        _weekStringDrawingSize = getStringDrawingSize(_dayAndWeekStringArray.get(31));

        SDate date = new SDate();
        calendarCore.date_get_now(date);
        mCalendar = new SCalendar();
        mCalendar.setDate(date);

        calendarCore.date_get_prev_month(date,1);
        mLastMonthDayCount = calendarCore.date_get_month_of_day(date.getYear(),date.getMonth());

        //Log.v("debug","init SCalendar "+mCalendar.getDate().getYear() + "  "+mCalendar.getDate().getMonth());

        //blf: java和c/c++以及objc c中结构体最大的不同就是只要是结构或类，都是堆分配
        //     对于习惯c/c++编程的道友来说，一定要牢记啊
        //     1、 new 一个数组
        //     2、 数组中的每个对象都要new一下
        //     3、 new一下对象中的RectF类，其实这一步可以写在SelectRange构造函数中或声明时直接new一下
        //     c# java javascript数组或容器中存储的都是指针(按照c/c++语言的观点)
        //     我们在这里预先分配31个range对象的内存，这样就可以如内存池般操作，因为一个月最多也就31天
        mRanges = new SelectRange[31];
        for(int i = 0; i < 31; i++)
        {
            mRanges[i] = new SelectRange();
            mRanges[i].rect = new RectF();
        }

        setOnTouchListener(this);

    }

    private CGPoint copyPoint(CGPoint src)
    {
        CGPoint ret = new CGPoint();
        ret.setX(src.getX());
        ret.setY(src.getY());
        return ret;
    }

    private void toAndroidRectF(CGRect src,RectF dest)
    {
        float left = src.getOrigin().getX();
        float top =  src.getOrigin().getY();
        float right = src.getOrigin().getX() + src.getSize().getWidth();
        float bottom = src.getOrigin().getY()+src.getSize().getHeight();
        dest.set(left,top,right,bottom);
    }

    private void invalidateTextPaintAndMeasurements() {
         mTextPaint.setTextSize(22);
         mTextPaint.setColor(Color.BLUE);
         mFontMetrics = mTextPaint.getFontMetrics();
    }

    private CGSize getStringDrawingSize(String str)
    {
        mTextPaint.getTextBounds(str, 0, str.length(), mTempAndroidRCInt);
        CGSize size = new CGSize();
        size.setWidth(mTempAndroidRCInt.width());
        size.setHeight(mTempAndroidRCInt.height());
        return size;
    }

    @Override
    protected  void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {

        int specModeWidth = MeasureSpec.getMode(widthMeasureSpec);
        int specSizeWidth = MeasureSpec.getSize(widthMeasureSpec);

        int specModeHeigth = MeasureSpec.getMode(heightMeasureSpec);
        int specSizeHeight = MeasureSpec.getSize(heightMeasureSpec);


        if(mCalendarSize == null)
            mCalendarSize = new CGSize();

        mCalendarSize.setWidth((float)specSizeWidth);
        mCalendarSize.setHeight((float)specSizeHeight);

        float yearMonthHeight = specSizeHeight * 0.09F;
        float weekHeight = specSizeHeight * 0.09F;

        calendarCore.calendar_init(mCalendar,mCalendarSize,yearMonthHeight,weekHeight);

       // Log.v("debug","height["+yearMonthHeight+","+weekHeight+"]");
        setMeasuredDimension(specSizeWidth, specSizeHeight);

        invalidate();
    }

    private void drawStringCenter(String str,Canvas canvas,CGRect rc,CGSize size,int color)
    {
        mTextPaint.setColor(color);
        float x = (rc.getSize().getWidth() - size.getWidth()) * 0.5F;

        //blf:android文字绘制时，y坐标和ios有很大区别，android是基于字体的baseline的
        float y = (rc.getSize().getHeight() - mFontMetrics.bottom + mFontMetrics.top)*0.5F - mFontMetrics.top;

        x += rc.getOrigin().getX();
        y += rc.getOrigin().getY();

        canvas.drawText(str,x,y,mTextPaint);
    }

    private void drawStringCenter(String str,Canvas canvas,RectF rc,CGSize size,int color)
    {
        mTextPaint.setColor(color);
        float x = (rc.width() - size.getWidth()) * 0.5F;

        //blf:android文字绘制时，y坐标和ios有很大区别，android是基于字体的baseline的
        float y = (rc.height() - mFontMetrics.bottom + mFontMetrics.top)*0.5F - mFontMetrics.top;

        x += rc.left;
        y += rc.top;

        canvas.drawText(str,x,y,mTextPaint);
    }

    private void drawCircleInRect(Canvas canvas,CGRect rc,int color)
    {
        //取width和height中最小的值的一半为半径
        float width = rc.getSize().getWidth();
        float height = rc.getSize().getHeight();
        float radius = (width < height ? width : height) * 0.5F;

        //计算出偏移量
        float x = rc.getOrigin().getX() + width * 0.5F;
        float y = rc.getOrigin().getY() + height * 0.5F;

        mColorPaint.setColor(color);
        canvas.drawCircle(x,y,radius,mColorPaint);
    }

    private void drawCircleInRect(Canvas canvas,RectF rc,int color)
    {
        //取width和height中最小的值的一半为半径
        float width = rc.width();
        float height = rc.height();
        float radius = (width < height ? width : height) * 0.5F;

        //计算出偏移量
        float x = rc.left + width * 0.5F;
        float y = rc.top + height * 0.5F;

        mColorPaint.setColor(color);
        canvas.drawCircle(x,y,radius,mColorPaint);
    }

    private void drawSelectRanges(Canvas canvas,int count)
    {
        if(count == 1)
        {
           drawCircleInRect(canvas,mRanges[0].rect,Color.RED);
        }
        else
        {
            calendarCore.calendar_get_day_cell_rect_by_index(mCalendar,mTempRC,0);
            int sameRowCellCount = 0;
            //blf:用来跟踪换行
            int lastRowIdx = mRanges[0].rowIdx;
            float width = mTempRC.getSize().getWidth();

            for(int i = 0; i < count; i++) {
                SelectRange range = mRanges[i];
                if(range.rowIdx == lastRowIdx)//blf:仍旧在同一行，因此同行计数
                {
                    sameRowCellCount++;
                }
                else//blf:一行结束，因此要将该行绘制出来，然后进行换行操作
                {
                    mTempRC.getOrigin().setX(mRanges[i - sameRowCellCount].rect.left);
                    mTempRC.getOrigin().setY(mRanges[i - sameRowCellCount].rect.top);
                    mTempRC.getSize().setHeight(range.rect.height());
                    mTempRC.getSize().setWidth(width * sameRowCellCount - 10.0F);

                    if(sameRowCellCount == 1)
                    {
                        drawCircleInRect(canvas,mTempRC,Color.RED);
                    }
                    else
                    {
                        toAndroidRectF(mTempRC,mTempAndroidRC);
                        mColorPaint.setColor(Color.RED);
                        canvas.drawRoundRect(mTempAndroidRC,mTempAndroidRC.height()*0.5F,mTempAndroidRC.height()*0.5F,mColorPaint);
                    }

                    sameRowCellCount = 1;
                    lastRowIdx = range.rowIdx;
                }
            }

            if(sameRowCellCount > 0)
            {
                mTempRC.getOrigin().setX(mRanges[count - sameRowCellCount].rect.left);
                mTempRC.getOrigin().setY(mRanges[count - sameRowCellCount].rect.top);
                mTempRC.getSize().setHeight(mRanges[count - sameRowCellCount].rect.height());
                mTempRC.getSize().setWidth(width * sameRowCellCount - 10.0F);

                if(sameRowCellCount != 1)
                {
                    toAndroidRectF(mTempRC,mTempAndroidRC);
                    mColorPaint.setColor(Color.RED);
                    canvas.drawRoundRect(mTempAndroidRC,mTempAndroidRC.height()*0.5F,mTempAndroidRC.height()*0.5F,mColorPaint);
                }
                else
                {
                    drawCircleInRect(canvas,mTempRC,Color.RED);
                }
            }
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        calendarCore.calendar_get_year_month_section_rect(mCalendar,mTempRC);
        toAndroidRectF(mTempRC,mTempAndroidRC);
        canvas.drawRect(mTempAndroidRC,mColorPaint);

        String drawStr = String.format("%d年%d月",mCalendar.getDate().getYear(),mCalendar.getDate().getMonth());

        CGSize sz = getStringDrawingSize(drawStr);

        drawStringCenter(drawStr,canvas,mTempRC,sz,Color.RED);

        for(int i= 0; i < 7; i++)
        {
            calendarCore.calendar_get_week_cell_rect(mCalendar,mTempRC,i);
            if(i == 0 || i == 6)
            {
                drawStringCenter(_dayAndWeekStringArray.get(31+i),canvas,mTempRC,_weekStringDrawingSize,Color.BLUE);
            }
            else
            {
                drawStringCenter(_dayAndWeekStringArray.get(31+i),canvas,mTempRC,_weekStringDrawingSize,Color.RED);
            }
        }

        calendarCore.calendar_get_day_section_rect(mCalendar,mTempRC);

        //是重新分配内存复制操作，java和objc的区别是objc支持c语言的结构栈内存分配，而Java中，都是堆内存分配，相当于全是c的指针
        CGPoint dayRectOffset = copyPoint(mTempRC.getOrigin());

        int begin = mCalendar.getDayBeginIdx();
        int end   = begin + mCalendar.getDayCount();

        //绘制上个月的日期
        for(int i = begin - 1; i >= 0; i--)
        {
            calendarCore.calendar_get_day_cell_rect_by_index(mCalendar,mTempRC,i);
            mTempRC.getOrigin().setX(mTempRC.getOrigin().getX() + dayRectOffset.getX() + 5.0F);
            mTempRC.getOrigin().setY(mTempRC.getOrigin().getY() + dayRectOffset.getY() + 5.0F);

            mTempRC.getSize().setWidth(mTempRC.getSize().getWidth() - 10.0F);
            mTempRC.getSize().setHeight(mTempRC.getSize().getHeight() - 10.0F);

            drawCircleInRect(canvas,mTempRC,mDayNormalCellCircleColor);

            int dayIdx = mLastMonthDayCount - (begin - i);
            //[223,223,223]
            drawStringCenter(_dayAndWeekStringArray.get(dayIdx),canvas,mTempRC,_dayStringDrawingSize,mDayNormalCellFontColor);
        }

        //绘制本月的日期以及选择标记
        int rangeCount = 0;
        for(int i = begin ;  i < end; i++)
        {
            calendarCore.calendar_get_day_cell_rect_by_index(mCalendar,mTempRC,i);
            mTempRC.getOrigin().setX(mTempRC.getOrigin().getX() + dayRectOffset.getX() + 5.0F);
            mTempRC.getOrigin().setY(mTempRC.getOrigin().getY() + dayRectOffset.getY() + 5.0F);

            mTempRC.getSize().setWidth(mTempRC.getSize().getWidth() - 10.0F);
            mTempRC.getSize().setHeight(mTempRC.getSize().getHeight() - 10.0F);

            calendarCore.date_set(mTempDate,getCurrentYear(),getCurrentMonth(),i - begin + 1);

            if(getController().isInSelectedRanges(mTempDate))
            {
                mRanges[rangeCount].rowIdx = i / 7;
                mRanges[rangeCount].columnIdx = i % 7;
                toAndroidRectF(mTempRC,mRanges[rangeCount].rect);
                rangeCount++;
            }
            else
            {
                drawCircleInRect(canvas,mTempRC,mDayNormalCellCircleColor);
                drawStringCenter(_dayAndWeekStringArray.get(i-mCalendar.getDayBeginIdx()),canvas,mTempRC,_dayStringDrawingSize,mDayNormalCellFontColor);
            }
        }

        drawSelectRanges(canvas,rangeCount);

        for(int i = 0; i < rangeCount; i++)
        {
            int idx = mRanges[i].rowIdx * 7 + mRanges[i].columnIdx;

            drawStringCenter(_dayAndWeekStringArray.get(idx - begin),canvas,mRanges[i].rect,_dayStringDrawingSize,Color.WHITE);
        }

        //绘制下个月的日期
        for(int i = end; i < 42; i++)
        {
            calendarCore.calendar_get_day_cell_rect_by_index(mCalendar,mTempRC,i);
            mTempRC.getOrigin().setX(mTempRC.getOrigin().getX() + dayRectOffset.getX() + 5.0F);
            mTempRC.getOrigin().setY(mTempRC.getOrigin().getY() + dayRectOffset.getY() + 5.0F);

            mTempRC.getSize().setWidth(mTempRC.getSize().getWidth() - 10.0F);
            mTempRC.getSize().setHeight(mTempRC.getSize().getHeight() - 10.0F);

            drawCircleInRect(canvas,mTempRC,mDayNormalCellCircleColor);
            //[245.245.245]
            drawStringCenter(_dayAndWeekStringArray.get(i-end),canvas,mTempRC,_dayStringDrawingSize,mDayNormalCellFontColor);
        }
    }

    @Override
    public boolean onTouch(View v, MotionEvent event)
    {
        if(event.getAction() == MotionEvent.ACTION_UP)
        {
            mTempPoint.setX(event.getX());
            mTempPoint.setY(event.getY());
            int hitIdx = calendarCore.calendar_get_hitted_day_cell_index(mCalendar,mTempPoint);
            if(hitIdx != -1) {
                CalendarController ctrl = getController();
                calendarCore.date_set(mTempDate, mCalendar.getDate().getYear(), mCalendar.getDate().getMonth(), hitIdx - mCalendar.getDayBeginIdx() + 1);

                if(getController().getHitCounter() % 2 == 0)
                {
                    ctrl.setSelectedRange(mTempDate,mTempDate);
                }
                else
                {
                    ctrl.setSelectedRange(ctrl.getStartDate(),mTempDate);
                }
                ctrl.updateHitCounter();
                ctrl.repaintCalendarViews();
            }
        }
       return false;
    }

    public void setCurrentYearMonth(int year,int month)
    {
        calendarCore.calendar_set_year_month(mCalendar,year,month);
        mTempDate.setYear(year);
        mTempDate.setMonth(month);
        calendarCore.date_get_prev_month(mTempDate,1);
        mLastMonthDayCount = calendarCore.date_get_month_of_day(mTempDate.getYear(),mTempDate.getMonth());
        this.invalidate();
    }

    public int getCurrentYear() {
        return mCalendar.getDate().getYear();
    }

    public void setCurrentYear(int year) {
        calendarCore.calendar_set_year_month(mCalendar,year,getCurrentMonth());
        this.invalidate();
    }

    public int getCurrentMonth() {
        return mCalendar.getDate().getMonth();
    }

    public void setCurrentMonth(int month) {
        calendarCore.calendar_set_year_month(mCalendar,getCurrentYear(),month);
        this.invalidate();
    }

}
