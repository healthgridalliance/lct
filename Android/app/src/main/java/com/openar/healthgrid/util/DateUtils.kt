package com.openar.healthgrid.util

import com.openar.healthgrid.model.HistoryDateItem
import java.text.SimpleDateFormat
import java.util.*

object DateUtils {
    fun getCalendar(): Calendar = Calendar.getInstance()

    fun parseDateList(dates: List<Date>): List<HistoryDateItem> {
        val historyList: MutableList<HistoryDateItem> = mutableListOf()
        val dateFormat = SimpleDateFormat("EE dd", Locale.US)
        for (obj in dates) {
            val date = dateFormat.format(obj).split(" ")
            if (date.size == 2) {
                historyList.add(HistoryDateItem(date[0], date[1]))
            }
        }
        return historyList
    }

    fun convertToFormat(dateString: String, pattern: String): String {
        val format = SimpleDateFormat(pattern, Locale.US)
        val date = format.parse(dateString)
        return if (date != null) format.format(date) else ""
    }

    fun getTimeStamp(time: Long): String = convertTimeSinceEpochToDate(time, "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")

    fun getDate(time: Long): String = convertTimeSinceEpochToDate(time, "yyyy-MM-dd'T'HH:mm")

    fun getTodayDate(): String = getDate(Calendar.getInstance().timeInMillis)

    fun getDateDaysBefore(days: Int): String {
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, -days)
        return getDate(calendar.timeInMillis)
    }

    private fun convertTimeSinceEpochToDate(time: Long, pattern: String): String {
        val format = SimpleDateFormat(pattern, Locale.US)
        format.timeZone = TimeZone.getTimeZone("UTC")
        return format.format(Date(time))
    }
}