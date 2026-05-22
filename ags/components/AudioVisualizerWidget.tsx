import { Gtk } from "ags/gtk4"
import AudioVisualizer from "../services/AudioVisualizer"

interface VisualizerWidgetProps {
    visualizer: AudioVisualizer
    width?: number
    height?: number
    barWidth?: number
    barSpacing?: number
}

export default function AudioVisualizerWidget({
    visualizer,
    width = 200,
    height = 60,
    barWidth = 4,
    barSpacing = 2
}: VisualizerWidgetProps): Gtk.Widget {
    
    const drawingArea = new Gtk.DrawingArea({
        width_request: width,
        height_request: height,
        css_classes: ["audio-visualizer-canvas"]
    })

    drawingArea.set_draw_func((_, cr, _allocatedWidth, allocatedHeight) => {
        const bars = visualizer.getBars()
        const count = visualizer.getBarcount()
        const align = visualizer.getAlign()
        const radius = 2

        const context = drawingArea.get_style_context()
        const color = context.get_color()

        for (let i = 0; i < count; i++) {
            const value = bars[i] ?? 0
            const x = i * (barWidth + barSpacing)
            const currentBarHeight = Math.max(allocatedHeight * value, 2)

            let y = 0
            let h = currentBarHeight

            // Dynamische Deckkraft wie in deinem Original (0.4 bis 1.0)
            cr.setSourceRGBA(color.red, color.green, color.blue, 0.4 + value * 0.6)

            if (align === "end") {
                y = allocatedHeight - currentBarHeight
                cr.moveTo(x + radius, y)
                cr.lineTo(x + barWidth - radius, y)
                cr.arc(x + barWidth - radius, y + radius, radius, -Math.PI / 2, 0)
                cr.lineTo(x + barWidth, y + h)
                cr.lineTo(x, y + h)
                cr.arc(x + radius, y + radius, radius, Math.PI, Math.PI * 1.5)
            } 
            else if (align === "start") {
                y = 0
                cr.moveTo(x, y)
                cr.lineTo(x + barWidth, y)
                cr.lineTo(x + barWidth, y + h - radius)
                cr.arc(x + barWidth - radius, y + h - radius, radius, 0, Math.PI / 2)
                cr.lineTo(x + radius, y + h)
                cr.arc(x + radius, y + h - radius, radius, Math.PI / 2, Math.PI)
            } 
            else if (align === "center") {
                y = (allocatedHeight / 2) - (currentBarHeight / 2)
                cr.moveTo(x + radius, y)
                cr.lineTo(x + barWidth - radius, y)
                cr.arc(x + barWidth - radius, y + radius, radius, -Math.PI / 2, 0)
                cr.lineTo(x + barWidth, y + h - radius)
                cr.arc(x + barWidth - radius, y + h - radius, radius, 0, Math.PI / 2)
                cr.lineTo(x + radius, y + h)
                cr.arc(x + radius, y + h - radius, radius, Math.PI / 2, Math.PI)
                cr.lineTo(x, y + radius)
                cr.arc(x + radius, y + radius, radius, Math.PI, Math.PI * 1.5)
            }

            cr.closePath()
            cr.fill()
        }
    })

    visualizer.subscribe(() => {
        drawingArea.queue_draw()
    })

    return drawingArea
}