pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // ===========================================================================================
    // Raw date

    readonly property date date: clock.date

    // ===========================================================================================
    // Time

    readonly property string time:{
        var h = date.getHours() % 12;
        if(h == 0) h = 12
        return Qt.formatDateTime(date, "ddd MMM d") + " " + h + Qt.formatDateTime(date, ":mm")
    }
        

    readonly property string timeShort:{
        var h = date.getHours() % 12;
        if(h == 0) h = 12
        return h + Qt.formatDateTime(date, ":mm")
    }

    readonly property string timeWithSeconds:{
        var h = date.getHours() % 12;
        if(h == 0) h = 12
        return h + Qt.formatDateTime(date, ":mm:ss")
    }

    readonly property string period:
        Qt.formatDateTime(
            date,
            "AP"
        )

    readonly property bool night: date.getHours() >= 21 || date.getHours() < 6

    // ===========================================================================================
    // Date

    readonly property string dateShort:
        Qt.formatDateTime(
            date,
            "dd.MM.yyyy"
        )

    readonly property string dateMedium:
        Qt.formatDateTime(
            date,
            "ddd, dd. MMM"
        )

    readonly property string longDate:
        Qt.formatDateTime(
            date,
            "dddd, dd. MMMM yyyy"
        )

    // ===========================================================================================
    // Date parts

    readonly property int day:
        date.getDate()

    readonly property int month:
        date.getMonth()

    readonly property int year:
        date.getFullYear()

    readonly property int weekday:
        date.getDay()

    readonly property int hours:
        date.getHours()

    readonly property int minutes:
        date.getMinutes()

    readonly property int seconds:
        date.getSeconds()

    // ===========================================================================================
    // Clock

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }
}