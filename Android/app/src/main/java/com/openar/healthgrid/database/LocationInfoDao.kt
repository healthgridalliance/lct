package com.openar.healthgrid.database

import androidx.room.*

@Dao
interface LocationInfoDao {
    @Insert
    fun insert(info: LocationInfoEntity)

    @Update
    fun update(info: LocationInfoEntity)

    @Delete
    fun delete(info: LocationInfoEntity)

    @Query("SELECT * FROM LocationInfoEntity")
    fun getAll(): List<LocationInfoEntity>?

    @Query("SELECT * FROM LocationInfoEntity ORDER BY id DESC LIMIT 1")
    fun getLast(): LocationInfoEntity?

    @Query("UPDATE LocationInfoEntity SET CheckOutTime = :checkOutTime WHERE id = (SELECT MAX(id) FROM LocationInfoEntity)")
    fun updateLastObject(checkOutTime: String)

    @Query("DELETE FROM LocationInfoEntity WHERE Date <= strftime('%Y-%m-%dT%H:%M', 'now', :daysNumber)")
    fun deleteExpiredData(daysNumber: String)

    @Query("SELECT strftime('%Y-%m-%dT%H:%M', 'now', :daysNumber)")
    fun getDate(daysNumber: String): String?

    @Query("SELECT * FROM LocationInfoEntity WHERE Date >= :date AND Date < strftime('%Y-%m-%d', :date, '+1 day')")
    fun getDataByDate(date: String): List<LocationInfoEntity>?
}