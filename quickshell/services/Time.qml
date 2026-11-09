pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Date and time
    readonly property date date: clock.date ?? new Date()

    readonly property int hours: date.getHours()
    readonly property int minutes: date.getMinutes()
    readonly property int seconds: date.getSeconds()

    readonly property int day: date.getDate()
    readonly property int month: date.getMonth()
    readonly property int year: date.getFullYear()
    readonly property int weekday: date.getDay()

    readonly property bool night: hours >= 21 || hours < 6

    readonly property string period: Qt.formatDateTime(date, "AP")

    // Time formatting
    readonly property int twelveHour: hours % 12 || 12

    readonly property string time: Qt.formatDateTime(date, "ddd MMM d ") + twelveHour + Qt.formatDateTime(date, ":mm")

    readonly property string timeShort: twelveHour + Qt.formatDateTime(date, ":mm")

    readonly property string timeWithSeconds: twelveHour + Qt.formatDateTime(date, ":mm:ss")

    // Date formatting
    readonly property string dateShort: Qt.formatDateTime(date, "dd.MM.yyyy")

    readonly property string dateMedium: Qt.formatDateTime(date, "ddd, dd. MMM")

    readonly property string dateLong: Qt.formatDateTime(date, "dddd, dd. MMMM yyyy")

    // System clock
    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }
}
