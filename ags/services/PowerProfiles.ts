import { execAsync } from "ags/process"

export type PowerProfile = "power-saver" | "balanced" | "performance"

export const getCurrentProfile = (): Promise<PowerProfile> =>
    execAsync("powerprofilesctl get").then(o => o.trim() as PowerProfile)

export const setProfile = (profile: PowerProfile): Promise<string> =>
    execAsync(`powerprofilesctl set ${profile}`)