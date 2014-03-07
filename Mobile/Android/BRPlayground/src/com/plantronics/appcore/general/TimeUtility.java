/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.general;

import java.text.DecimalFormat;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import com.plantronics.appcore.debug.CoreLogTag;
import android.content.Context;
import android.util.Log;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 6/27/12
 */
public class TimeUtility {

    public static final DecimalFormat FORMAT_ZERO_POINT_HASH = new DecimalFormat("0.#");

    public static final String TAG = CoreLogTag.getGlobalTagPrefix() + TimeUtility.class.getSimpleName();
    public static final int SECOND = 1000;
    public static final int MINUTE = 60 * SECOND;
    public static final int HOUR = 60 * MINUTE;
    public static final int DAY = 24 * HOUR;
    public static final int TWO_DAYS = 2 * DAY;

    public static final int MILLIS_PER_SECOND = 1000;
    public static final int MILLIS_PER_DAY = DAY;

    /**
     * Convert a duration in seconds to mm:ss string
     * @param seconds number of seconds
     * @return mm:ss string
     */
    public static String formatSecondsToMmSsString(int seconds) {
        int minutes = seconds / 60;
        int sSeconds = seconds % 60;
        return ((minutes < 10) ? "0" + minutes : minutes) + ":" + ((sSeconds < 10) ? "0" + sSeconds : sSeconds);
    }

    /**
     * Function used for formatting the talk time. It handles the negative talk times as well.
     * @param minutes
     *      raw number of minutes
     * @return
     *      The formatted string of talk time
     */
    public static String formatMinutesToHrsMinStringWithHrsMinLabels(int minutes) {
        int minutesParam = Math.abs(minutes);
        long hours = minutesParam / 60;
        int minutesMod = minutesParam % 60;
        
        // TODO handle the case when there is 0 minutes, then just display the hours
        return (hours != 0 ? hours + "h, " : "") + minutesMod + "m";
    }

    /**
     * Formats time elapsed into a string stating how many days, hours and minutes it lasts. 
     * It formats the time in a string like these ones: "2 days" or "1 day 16 hrs" or "5 hrs" or "1 hour 5 mins" or "2 mins 5 secs" or just "5 seconds" or "1 second".
     * It was made for the Find MyHeadset function that writes out how many time the user took to find their headset.
     * @param now
     * 		The current moment in milliseconds
     * @param timeInPast
     * 		A time in the past in milliseconds
     * @return
     * 		The returning String formatted as explained above
     */
    public static String convertToTimeElapsedStringShortAsPossible(long now, long timeInPast) {
        long millis = now - timeInPast;

        // It presents time in the future
        if (millis < 0) {
            return "no time"; // We return immediately
        }

        int hours = (int) (millis / HOUR);

        // If we have the time in days that is it,
        // then we only return the number of days
        int days = hours / 24;
        if (days > 0) {
            return days + (days == 1 ? " day" : " days");
        }
        hours %= 24;

        int secondsTotalRawSum = (int) (millis / 1000);
        int seconds = secondsTotalRawSum % 60;
        int minutesTotalRawSum = secondsTotalRawSum / 60;
        int minutes = minutesTotalRawSum % 60;

        String s = "";
        if (hours > 0) {
            s += hours + (hours == 1 ? " hour" : " hrs");
        }

        if (minutes > 0) {
            s += " " + minutes + (minutes == 1 ? " min" : " mins");
        }

        // There are only seconds, hours and minutes are both 0
        if (s.trim().length() == 0) {
            long secondsRounded = Math.round(millis / 1000f);
            return secondsRounded + (secondsRounded == 1 ? " second" : " seconds"); // We only write the seconds

        } else {

            // Add seconds to minutes only if there are no hours
            if (hours == 0) {
                s += " " + seconds + (seconds == 1 ? " sec" : " secs");
            }

            return s.trim(); // Trimming is necessary because there might be some " " at the beginning
        }
    }

    /**
     * The time converting method that returns Today, Yesterday, a week day or a date
     * @param time
     *      Time in the past
     * @param context
     * 		Context of the caller
     * @return
     *      The string representation based on the UX spec-ed guidelines
     */
    public static String convertToTimeAgoString(Context context, long time) {

        Calendar calendar = Calendar.getInstance();

        // Get the time of midnight today
        Date midnightDate = calendar.getTime();
        midnightDate.setHours(0);
        midnightDate.setMinutes(0);
        midnightDate.setSeconds(0);
        long midnightThisDay = midnightDate.getTime();     
        final long midnightDayBefore = midnightThisDay - MILLIS_PER_DAY;
        final long midnight6DaysBefore = midnightThisDay - 6 * MILLIS_PER_DAY;  

        // From before 6 days
        if (time < midnight6DaysBefore) {

            // === Old implementation ===
            //Date date = new Date(time);
            //return new SimpleDateFormat("dd/MM/yy").format(date);

            // === Android System Format ===
            Format systemDateFormat = android.text.format.DateFormat.getDateFormat(context);
            return systemDateFormat.format(time);
        }

        // In the last 6 days
        if (time >= midnight6DaysBefore && time < midnightDayBefore) {
            Date date = new Date(time);
            return new SimpleDateFormat("EEEE").format(date);
        }

        // Day before
        if (time >= midnightDayBefore && time < midnightThisDay) {
            return "Yesterday";
        }

        return "Today";
    }

    /**
     * The time converting method that returns Today, Yesterday, a week day or a date
     * @param time
     *      Time in the past in milliseconds
     * @param now
     * 		Current time in milliseconds
     * @return
     *      The string representation based on the UX spec-ed guidelines
     */
    public static String convertToTimeAgoString(long now, long time) {
        Log.d(TAG, "now: " + new Date(now) + ", the event time: " + new Date(time));

        // If the time is in future return "/"
        if (time > now) {
            Log.e(TAG, "Time in the future!" + time);
            return "/";
        }

        //..............................................................
        // Helper variables
        //..............................................................
        Calendar calendar = Calendar.getInstance();

        // Get the time of midnight today
        Date midnightDate = calendar.getTime();
        midnightDate.setHours(0);
        midnightDate.setMinutes(0);
        midnightDate.setSeconds(0);
        long midnightThisDay = midnightDate.getTime();
//        final long midnightThisDay = now - now % MILLIS_PER_DAY; // Buggy. Won't work across time zones

        final long midnightDayBefore = midnightThisDay - MILLIS_PER_DAY;
        final long midnight6DaysBefore = midnightThisDay - 6 * MILLIS_PER_DAY;
        final long hourAgo = now - HOUR;
        final long hourAndHalfAgo = hourAgo - HOUR / 2;
        final long minuteAgo = now - MINUTE;
        final long elapsedTime = now - time;

        // From before 6 days
        if (time < midnight6DaysBefore) {
            Date date = new Date(time);
            return new SimpleDateFormat("MMM d, yyyy").format(date);
        }

        // In the last 6 days
        if (time >= midnight6DaysBefore && time < midnightDayBefore) {
            Date date = new Date(time);
            return new SimpleDateFormat("EEEE").format(date);
        }

        // Day before
        if (time >= midnightDayBefore && time < midnightThisDay){
            return "Yesterday";
        }

        // Older than an hour and a half ago
        if (time >= midnightThisDay && time < hourAndHalfAgo) {
            return Math.round((float) elapsedTime / HOUR) + " hrs ago";
        }

        // Less than an hour and a half ago
        if (time >= hourAndHalfAgo && time < hourAgo) {
            return "1 hr ago";
        }

        // Less than an hour ago
        if (time >= hourAgo && time < minuteAgo) {
            // Never mind the difference in hours between calendars - it's all less than an hour
            final Date elapsedTimeDate = new Date(elapsedTime);
            return new SimpleDateFormat("m 'min ago'").format(elapsedTimeDate);
        }

        // Less than a minute ago
        if (time >= minuteAgo) {
            // Never mind the difference in hours between calendars - it's all less than an hour
            final Date elapsedTimeDate = new Date(elapsedTime);
            return new SimpleDateFormat("s 'sec ago'").format(elapsedTimeDate);
        }

        return ""; // Not covered
    }

    /**
     * Determine if the given back in past time in milliseconds is older then specified time offset (that we subtract from the present moment).
     *
     * @param backInPastInMillis
     *      The time in milliseconds.
     * @param currentTimeInMillis
     *      The current time in milliseconds.
     * @param timeOffset
     *      The time offset in milliseconds.
     * @return
     *      The outcome is <b>true</b> if the specified timestamp is older then time offset.
     */
    public static boolean isOlderThanTimeOffset(long backInPastInMillis, long currentTimeInMillis, long timeOffset) {
        return currentTimeInMillis - timeOffset >= backInPastInMillis;
    }


}
