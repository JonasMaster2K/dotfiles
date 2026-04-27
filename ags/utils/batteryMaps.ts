import AstalBattery from "gi://AstalBattery"

export const techNames: Record<number, string> = {
    [AstalBattery.Technology.UNKNOWN]:                "Unknown",
    [AstalBattery.Technology.LITHIUM_ION]:            "Lithium Ion",
    [AstalBattery.Technology.LITHIUM_POLYMER]:        "Lithium Polymer",
    [AstalBattery.Technology.LITHIUM_IRON_PHOSPHATE]: "Lithium Iron Phosphate",
    [AstalBattery.Technology.LEAD_ACID]:              "Lead Acid",
    [AstalBattery.Technology.NICKEL_CADMIUM]:         "Nickel Cadmium",
    [AstalBattery.Technology.NICKEL_METAL_HYDRIDE]:   "Nickel Metal Hydride",
}

export const warningNames: Record<number, string> = {
    [AstalBattery.WarningLevel.UNKNOWN]:     "Unknown",
    [AstalBattery.WarningLevel.NONE]:        "None",
    [AstalBattery.WarningLevel.DISCHARGING]: "Discharging",
    [AstalBattery.WarningLevel.LOW]:         "Low",
    [AstalBattery.WarningLevel.CRITICIAL]:   "Critical",
    [AstalBattery.WarningLevel.ACTION]:      "Action",
}

export const batteryLevelNames: Record<number, string> = {
    [AstalBattery.BatteryLevel.UNKNOWN]:   "Unknown",
    [AstalBattery.BatteryLevel.NONE]:      "None",
    [AstalBattery.BatteryLevel.LOW]:       "Low",
    [AstalBattery.BatteryLevel.CRITICIAL]: "Critical",
    [AstalBattery.BatteryLevel.NORMAL]:    "Normal",
    [AstalBattery.BatteryLevel.HIGH]:      "High",
    [AstalBattery.BatteryLevel.FULL]:      "Full",
}