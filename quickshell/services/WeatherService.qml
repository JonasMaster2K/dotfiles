pragma Singleton

import QtQuick
import Quickshell

import "../services"

Singleton {
    id: root

    // ─────────────────────────────────────────────
    // Settings
    // ─────────────────────────────────────────────

    property bool automaticLocation: false
    property string latitude: ""
    property string longitude: ""
    property string locationName: "Unbekannt"

    // "metric" oder "imperial"
    property string units: "metric"

    readonly property string temperatureUnit:
        units === "imperial" ? "°F" : "°C"

    readonly property string windUnit:
        units === "imperial" ? "mph" : "km/h"

    // ─────────────────────────────────────────────
    // Current weather
    // ─────────────────────────────────────────────

    property real temperature: 0
    property real feelsLike: 0
    property int humidity: 0
    property real windSpeed: 0
    property int weatherCode: 0

    // ─────────────────────────────────────────────
    // Forecast
    // ─────────────────────────────────────────────

    property var hourly: []
    property var daily: []

    property bool loading: false
    property bool error: false

    // ─────────────────────────────────────────────
    // Weather icons
    // ─────────────────────────────────────────────

    // weather-clear-symbolic
    // weather-clear-night-symbolic
    // weather-few-clouds-symbolic
    // weather-few-clouds-night-symbolic
    // weather-fog-symbolic
    // weather-overcast-symbolic
    // weather-severe-alert-symbolic
    // weather-showers-scattered-symbolic
    // weather-showers-symbolic
    // weather-snow-symbolic
    // weather-storm-symbolic

    readonly property string iconName: {
        switch (weatherCode) {
        case 0:
            return Time.night ? "weather-clear-night-symbolic" : "weather-clear-symbolic"
        case 1:
        case 2:
            return Time.night ? "weather-few-clouds-night-symbolic" : "weather-few-clouds-symbolic"
        case 3:
            return "weather-overcast-symbolic"
        case 45:
        case 48:
            return "weather-fog-symbolic"
        case 51:
        case 53:
        case 55:
        case 56:
        case 57:
            return "weather-showers-symbolic"
        case 61:
        case 63:
        case 65:
        case 66:
        case 67:
            return "weather-rain-symbolic"
        case 71:
        case 73:
        case 75:
        case 77:
            return "weather-snow-symbolic"
        case 80:
        case 81:
        case 82:
            return "weather-showers-symbolic"
        case 85:
        case 86:
            return "weather-snow-symbolic"
        case 95:
        case 96:
        case 99:
            return "weather-storm-symbolic"
        default:
            return "weather-none-symbolic"
        }
    }

    // ─────────────────────────────────────────────
    // Get location from IP
    // ─────────────────────────────────────────────

    function updateLocation() {
        if(!automaticLocation){
            latitude = "51.0258100"
            longitude = "7.65023"
            locationName = "Bergneustadt"
            updateWeather()
        }else {
            const request = new XMLHttpRequest()

            request.onreadystatechange = function() {
                if (request.readyState !== XMLHttpRequest.DONE)
                    return

                if (request.status !== 200) {
                    console.log("ipinfo request failed:", request.status)
                    error = true
                    return
                }

                try {
                    const data = JSON.parse(request.responseText)

                    if (!data.loc) {
                        console.log("ipinfo: no location returned")
                        error = true
                        return
                    }

                    // ipinfo liefert z.B.:
                    // "50.9851,7.5536"
                    const coordinates = data.loc.split(",")

                    if (coordinates.length !== 2) {
                        console.log("Invalid location:", data.loc)
                        error = true
                        return
                    }

                    latitude = coordinates[0]
                    longitude = coordinates[1]

                    // Stadtname von ipinfo übernehmen
                    if (data.city)
                        locationName = data.city

                    // Erst nachdem die Koordinaten bekannt sind:
                    updateWeather()

                } catch (e) {
                    console.log("Failed to parse ipinfo response:", e)
                    error = true
                }
            }

            request.open("GET", "https://ipinfo.io/json")
            request.send()
        }
    }

    // ─────────────────────────────────────────────
    // Weather API
    // ─────────────────────────────────────────────

    function updateWeather() {
        if (!latitude || !longitude) {
            console.log("No coordinates available")
            return
        }

        const temperatureUnit =
            units === "imperial" ? "fahrenheit" : "celsius"

        const windSpeedUnit =
            units === "imperial" ? "mph" : "kmh"

        const precipitationUnit =
            units === "imperial" ? "inch" : "mm"

        const url =
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=" + latitude +
            "&longitude=" + longitude +
            "&current=" +
                "temperature_2m," +
                "apparent_temperature," +
                "relative_humidity_2m," +
                "wind_speed_10m," +
                "weather_code" +
            "&hourly=" +
                "temperature_2m," +
                "apparent_temperature," +
                "precipitation_probability," +
                "weather_code," +
                "wind_speed_10m" +
            "&daily=" +
                "weather_code," +
                "temperature_2m_max," +
                "temperature_2m_min," +
                "precipitation_probability_max," +
                "precipitation_sum," +
                "sunrise," +
                "sunset" +
            "&temperature_unit=" + temperatureUnit +
            "&wind_speed_unit=" + windSpeedUnit +
            "&precipitation_unit=" + precipitationUnit +
            "&forecast_days=7" +
            "&timezone=auto"

        const request = new XMLHttpRequest()

        request.onreadystatechange = function() {
            if (request.readyState !== XMLHttpRequest.DONE)
                return

            loading = false

            if (request.status !== 200) {
                console.log(
                    "Open-Meteo request failed:",
                    request.status
                )
                error = true
                return
            }

            try {
                const data = JSON.parse(request.responseText)

                // ─────────────────────────────────
                // Current
                // ─────────────────────────────────

                temperature = data.current.temperature_2m
                feelsLike = data.current.apparent_temperature
                humidity = data.current.relative_humidity_2m
                windSpeed = data.current.wind_speed_10m
                weatherCode = data.current.weather_code

                // ─────────────────────────────────
                // Hourly
                // ─────────────────────────────────

                hourly = []

                for (let i = 0; i < data.hourly.time.length; i++) {
                    hourly.push({
                        time: data.hourly.time[i],
                        temperature:
                            data.hourly.temperature_2m[i],
                        feelsLike:
                            data.hourly.apparent_temperature[i],
                        precipitationProbability:
                            data.hourly.precipitation_probability[i],
                        weatherCode:
                            data.hourly.weather_code[i],
                        windSpeed:
                            data.hourly.wind_speed_10m[i]
                    })
                }

                // ─────────────────────────────────
                // Daily
                // ─────────────────────────────────

                daily = []

                for (let i = 0; i < data.daily.time.length; i++) {
                    daily.push({
                        date: data.daily.time[i],
                        temperatureMax:
                            data.daily.temperature_2m_max[i],
                        temperatureMin:
                            data.daily.temperature_2m_min[i],
                        precipitationProbability:
                            data.daily.precipitation_probability_max[i],
                        precipitation:
                            data.daily.precipitation_sum[i],
                        sunrise:
                            data.daily.sunrise[i],
                        sunset:
                            data.daily.sunset[i],
                        weatherCode:
                            data.daily.weather_code[i]
                    })
                }

            } catch (e) {
                console.log(
                    "Failed to parse Open-Meteo response:",
                    e
                )
                error = true
            }
        }

        request.open("GET", url)
        request.send()
    }

    // ─────────────────────────────────────────────
    // Update
    // ─────────────────────────────────────────────

    function update() {
        loading = true
        error = false

        // Erst IP-Position bestimmen,
        // danach Wetterdaten laden.
        updateLocation()
    }

    // ─────────────────────────────────────────────
    // Update timer
    // ─────────────────────────────────────────────

    Timer {
        interval: 10 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.update()
    }
}