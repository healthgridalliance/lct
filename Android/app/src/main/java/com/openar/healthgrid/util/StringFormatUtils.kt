package com.openar.healthgrid.util

object StringFormatUtils {
    private const val HEX_COLOR_PATTERN = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"

    fun isHexFormat(color: String): Boolean {
        val regex = Regex(pattern = HEX_COLOR_PATTERN)
        return regex.matches(input = color)
    }

}