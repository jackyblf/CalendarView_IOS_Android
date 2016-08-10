package com.blf.calendar;

import android.content.Context;
import android.widget.ListView;

/**
 * Created by 步亦凡 on 2016/4/19.
 */
public interface CalendarController {

    public boolean isInSelectedRanges(SDate date);

    public void setSelectedRange(SDate start,SDate end);

    public SDate getStartDate();

    public SDate getEndDate();

    public int calcCalendarCount();

    public void mapIndexToYearMonth(int idx);

    public int mapYearMonthToIndex(SDate date);

    public void showCalendarAtYearMonth(SDate date);

    public int getHitCounter();

    public void updateHitCounter();

    public void repaintCalendarViews();
}
