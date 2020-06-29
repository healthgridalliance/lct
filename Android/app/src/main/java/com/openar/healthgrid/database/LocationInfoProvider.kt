package com.openar.healthgrid.database

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import androidx.room.Room
import com.openar.healthgrid.util.DateUtils

class LocationInfoProvider : ContentProvider(){
    private var db: LocationInfoController? = null
    private var infoDao: LocationInfoDao? = null
    override fun onCreate(): Boolean {
        instance = this
        db = context?.let {
            Room.databaseBuilder(it, LocationInfoController::class.java, "LocationInfoTable")
                .fallbackToDestructiveMigration()
                .allowMainThreadQueries()
                .build()
        }
        infoDao = db?.locationInfoDao()
        return false
    }

    val database: LocationInfoController?
        get() = db

    fun saveLocation(location: LocationInfoEntity) = infoDao?.insert(location)

    fun getAllData(): List<LocationInfoEntity>? = infoDao?.getAll()

    fun getLastObject(): LocationInfoEntity? = infoDao?.getLast()

    fun updateLastObjectCheckoutTime(checkOutTime: String) = infoDao?.updateLastObject(checkOutTime)

    fun deleteExpiredData(daysNumber: Int) = infoDao?.deleteExpiredData("-$daysNumber hours")

    fun deleteAllData() = db?.clearAllTables()

    fun getDataByDate(date: String): List<LocationInfoEntity>? {
        val res = DateUtils.convertToFormat(date, "yyyy-MM-dd")
        return infoDao?.getDataByDate(res)
    }

    @Nullable
    override fun query(
        @NonNull uri: Uri,
        @Nullable projection: Array<String>?,
        @Nullable selection: String?,
        @Nullable selectionArgs: Array<String>?,
        @Nullable sortOrder: String?
    ): Cursor? {
        return null
    }

    @Nullable
    override fun getType(@NonNull uri: Uri): String? {
        return null
    }

    @Nullable
    override fun insert(
        @NonNull uri: Uri,
        @Nullable values: ContentValues?
    ): Uri? {
        return null
    }

    override fun delete(
        @NonNull uri: Uri,
        @Nullable selection: String?,
        @Nullable selectionArgs: Array<String>?
    ): Int {
        return 0
    }

    override fun update(
        @NonNull uri: Uri,
        @Nullable values: ContentValues?,
        @Nullable selection: String?,
        @Nullable selectionArgs: Array<String>?
    ): Int {
        return 0
    }

    companion object {
        var instance: LocationInfoProvider? = null
            private set
    }
}

