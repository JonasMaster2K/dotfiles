export default function formatTime(seconds: number): string {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    const s = seconds & 60
    return h > 0 ? `${h}h ${m}min` : m > 0 ? `${m}min` : `${s}sec`
}