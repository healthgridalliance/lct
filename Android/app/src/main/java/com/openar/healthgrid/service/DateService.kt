package com.openar.healthgrid.service

import com.openar.healthgrid.model.HistoryDateItem
import com.openar.healthgrid.util.DateUtils
import java.util.*

class DateService private constructor() {

    private object HOLDER {
        val INSTANCE = DateService()
    }

    companion object {
        val instance: DateService by lazy { HOLDER.INSTANCE }
    }

    fun loadHistoryDates(daysBefore: Int): List<HistoryDateItem> {
        val dates: MutableList<Date> = mutableListOf()
        val calendar = DateUtils.getCalendar()
        dates.add(calendar.time)
        for (i in 0..daysBefore) {
            calendar.add(Calendar.DAY_OF_YEAR, -1)
            dates.add(calendar.time)
        }
        return DateUtils.parseDateList(dates)
    }
}