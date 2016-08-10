package com.blf.calendar;

import android.content.Context;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListView;

public class MainActivity extends AppCompatActivity implements CalendarController {

    static {
        System.loadLibrary("calendarCore");
    }

    private ListView listView;
    public int  hitCounter = 0;
    public int  startYear;
    public int  endYear;
    private SDate mTempDate = new SDate();

    private int mStartTime = 0;
    private int mEndTime = 0;

    private SDate mStartDate = new SDate();
    private SDate mEndDate = new SDate();

    /*
    blf：java没有类似c++ c#的参数传地址方式
     */
    public  void swapTime() {
        int t = mStartTime;
        mStartTime = mEndTime;
        mEndTime = t;
    }
    /*
    blf:与objc的区别
     */
    public void copyDate(SDate dest,SDate src)
    {
        dest.setYear(src.getYear());
        dest.setMonth(src.getMonth());
        dest.setDay(src.getDay());
    }

    public void setSelectedRange(SDate start,SDate end)
    {
        mStartTime = calendarCore.date_get_time_t(start);
        mEndTime   = calendarCore.date_get_time_t(end);

        if(mStartTime > mEndTime)
        {
            swapTime();
            copyDate(mStartDate,end);
            copyDate(mEndDate,start);

        }else{
            copyDate(mStartDate,start);
            copyDate(mEndDate,end);
        }
    }

    public SDate getStartDate()
    {
        return mStartDate;
    }

    public SDate getEndDate()
    {
        return mEndDate;
    }

    public boolean isInSelectedRanges(SDate date)
    {
        int curr = calendarCore.date_get_time_t(date);
        if(curr < mStartTime || curr > mEndTime)
            return false;

        return true;
    }

    public int calcCalendarCount()
    {
        calendarCore.date_get_now(mTempDate);
        int diff = endYear - startYear + 1;
        diff = diff * 12;
        diff -= (12 - mTempDate.getMonth());
        return diff;
    }

    public void mapIndexToYearMonth(int idx)
    {
        calendarCore.date_map_index_to_year_month(mTempDate,startYear,idx);
    }

    public int mapYearMonthToIndex(SDate date)
    {
        int yearDiff = date.getYear() - startYear;
        int index = yearDiff * 12;
        index += date.getMonth();
        index -= 1;
        return index;
    }

    public int getHitCounter()
    {
        return hitCounter;
    }

    public void updateHitCounter()
    {
        hitCounter++;
    }

    public void showCalendarAtYearMonth(SDate date)
    {
        if(date.getYear() < startYear || date.getYear() > endYear)
            return;

        int idx =  this.mapYearMonthToIndex(date);
        //this.listView.smoothScrollToPosition(calcCalendarCount()-1);
        this.listView.setSelection(calcCalendarCount()-1);
    }

    public void repaintCalendarViews()
    {
        for(int i = 0; i < listView.getChildCount(); i++)
        {
            ViewGroup subViewGroup = (ViewGroup)listView.getChildAt(i);
            for(int j = 0; j < subViewGroup.getChildCount(); j++)
            {
                /*
                View subView = subViewGroup.getChildAt(j);
                boolean b = subView instanceof CalendarView;
                Log.v("debug","isCalendarView "+b);
                */

                CalendarView calendar = (CalendarView)subViewGroup.getChildAt(j);
                calendar.invalidate();
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        calendarCore.date_get_now(mTempDate);
        startYear   = mTempDate.getYear() - 3;
        endYear     = mTempDate.getYear();

        setContentView(R.layout.activity_main);
        listView = (ListView)findViewById(R.id.listView);
        listView.setAdapter(new MyAdapter(this));
        Log.v("debug","on Create");
    }

    @Override
    protected void onStart()
    {
        super.onStart();
       // calendarCore.date_get_now(mTempDate);
      //  showCalendarAtYearMonth(mTempDate);
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        calendarCore.date_get_now(mTempDate);
        showCalendarAtYearMonth(mTempDate);
        Log.v("debug","on Resume");
    }

    @Override
    protected void onRestart()
    {
        super.onRestart();
       // calendarCore.date_get_now(mTempDate);
       // showCalendarAtYearMonth(mTempDate);
    }

    static class ViewHolder
    {
        public CalendarView calendar;
    }

    public class MyAdapter extends BaseAdapter {
        private LayoutInflater mInflater = null;

        private MyAdapter(Context context) {
            //根据context上下文加载布局，这里的是Demo17Activity本身，即this
            this.mInflater = LayoutInflater.from(context);
        }

        @Override
        public int getCount() {
            //How many items are in the data set represented by this Adapter.
            //在此适配器中所代表的数据集中的条目数
            return calcCalendarCount();
        }

        @Override
        public Object getItem(int position) {
            // Get the data item associated with the specified position in the data set.
            //获取数据集中与指定索引对应的数据项
            return position;
        }

        @Override
        public long getItemId(int position) {
            //Get the row id associated with the specified position in the list.
            //获取在列表中与指定索引对应的行id
            return position;
        }

        //Get a View that displays the data at the specified position in the data set.
        //获取一个在数据集中指定索引的视图来显示数据
        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ViewHolder holder = null;
            mapIndexToYearMonth(position);
            //如果缓存convertView为空，则需要创建View
            if (convertView == null) {
                holder = new ViewHolder();
                //根据自定义的Item布局加载布局
                convertView = mInflater.inflate(R.layout.calendar_view, null,false);
                holder.calendar = (CalendarView) convertView.findViewById(R.id.calendarID);

                /*blf:
                可以使用
                (CalendarController)parent.getContext()方式获取

                但是更加优雅的方式如下:
                (CalendarController) MainActivity.this
                从内部类获取外部类的对象
                */
                holder.calendar.setController((CalendarController) MainActivity.this);

                //将设置好的布局保存到缓存中，并将其设置在Tag里，以便后面方便取出Tag
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
            holder.calendar.setCurrentYearMonth(mTempDate.getYear(),mTempDate.getMonth());
            return convertView;
        }

    }
}

