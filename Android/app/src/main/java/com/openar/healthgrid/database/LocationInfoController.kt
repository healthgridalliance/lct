package com.openar.healthgrid.database

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [LocationInfoEntity::class], version = 1, exportSchema = false)
abstract class LocationInfoController : RoomDatabase() {
    abstract fun locationInfoDao(): LocationInfoDao?

    companion object {
        private val controller: LocationInfoController? = null
    }
}