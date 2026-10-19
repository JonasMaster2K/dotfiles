pragma Singleton

import QtQuick
import "../config"

// Public semantic color API. Components should use Colors.<token>,
// never the fallback palettes directly.
// Matugen can later replace the light/dark palette sources.
QtObject {
    id: colors

    readonly property QtObject palette: Settings.darkMode ? darkColors : lightColors

    // ====================================================================
    // ACCENT
    // ====================================================================
    readonly property color accent: palette.accent
    readonly property color accentHover: palette.accentHover
    readonly property color accentPressed: palette.accentPressed
    readonly property color accentDisabled: palette.accentDisabled
    readonly property color accentSelected: palette.accentSelected
    readonly property color textOnAccent: palette.textOnAccent

    // ====================================================================
    // SURFACES
    // ====================================================================
    readonly property color background: palette.background
    readonly property color surface: palette.surface
    readonly property color surfaceSunken: palette.surfaceSunken
    readonly property color surfaceRaised: palette.surfaceRaised
    readonly property color surfaceElevated: palette.surfaceElevated
    readonly property color surfaceOverlay: palette.surfaceOverlay
    readonly property color surfaceHover: palette.surfaceHover
    readonly property color surfacePressed: palette.surfacePressed
    readonly property color surfaceDisabled: palette.surfaceDisabled
    readonly property color surfaceActive: palette.surfaceActive
    readonly property color surfaceActiveMuted: palette.surfaceActiveMuted

    // ====================================================================
    // TEXT
    // ====================================================================
    readonly property color textPrimary: palette.textPrimary
    readonly property color textSecondary: palette.textSecondary
    readonly property color textTertiary: palette.textTertiary
    readonly property color textDisabled: palette.textDisabled
    readonly property color textInverse: palette.textInverse

    // ====================================================================
    // BORDERS
    // ====================================================================
    readonly property color borderSubtle: palette.borderSubtle
    readonly property color border: palette.border
    readonly property color borderStrong: palette.borderStrong
    readonly property color borderDisabled: palette.borderDisabled
    readonly property color borderFocus: palette.borderFocus
    readonly property color separator: palette.separator
    readonly property color borderRaised: palette.borderRaised
    readonly property color borderElevated: palette.borderElevated

    // ====================================================================
    // CONTROLS
    // ====================================================================
    readonly property color controlBackground: palette.controlBackground
    readonly property color controlBackgroundHover: palette.controlBackgroundHover
    readonly property color controlBackgroundPressed: palette.controlBackgroundPressed
    readonly property color controlBackgroundDisabled: palette.controlBackgroundDisabled
    readonly property color controlThumb: palette.controlThumb
    readonly property color controlTrack: palette.controlTrack
    readonly property color controlTrackHover: palette.controlTrackHover
    readonly property color controlTrackPressed: palette.controlTrackPressed
    readonly property color controlTrackDisabled: palette.controlTrackDisabled

    // ====================================================================
    // INPUTS
    // ====================================================================
    readonly property color inputBackground: palette.inputBackground
    readonly property color inputBackgroundHover: palette.inputBackgroundHover
    readonly property color inputBackgroundFocus: palette.inputBackgroundFocus
    readonly property color inputBackgroundDisabled: palette.inputBackgroundDisabled
    readonly property color inputBorder: palette.inputBorder
    readonly property color inputBorderHover: palette.inputBorderHover
    readonly property color inputBorderFocus: palette.inputBorderFocus
    readonly property color inputBorderError: palette.inputBorderError

    // ====================================================================
    // INTERACTION
    // ====================================================================
    readonly property color hover: palette.hover
    readonly property color pressed: palette.pressed
    readonly property color selected: palette.selected
    readonly property color selectionSurface: palette.selectionSurface
    readonly property color selectionBorder: palette.selectionBorder
    readonly property color selectionText: palette.selectionText
    readonly property color focusRing: palette.focusRing

    // ====================================================================
    // STATUS
    // ====================================================================
    readonly property color success: palette.success
    readonly property color successBackground: palette.successBackground
    readonly property color successText: palette.successText
    readonly property color warning: palette.warning
    readonly property color warningBackground: palette.warningBackground
    readonly property color warningText: palette.warningText
    readonly property color error: palette.error
    readonly property color errorBackground: palette.errorBackground
    readonly property color errorText: palette.errorText
    readonly property color info: palette.info
    readonly property color infoBackground: palette.infoBackground
    readonly property color infoText: palette.infoText

    // ====================================================================
    // OVERLAY & LIGHTING
    // ====================================================================
    readonly property color scrim: palette.scrim
    readonly property color shadow: palette.shadow
    readonly property color highlight: palette.highlight
    readonly property color shadowDark: palette.shadowDark
    readonly property color shadowLight: palette.shadowLight
    readonly property color shadowAmbient: palette.shadowAmbient

    // ====================================================================
    // OPTIONAL ACCENTS
    // ====================================================================
    readonly property color cyan: palette.cyan
    readonly property color indigo: palette.indigo
    readonly property color orange: palette.orange
    readonly property color pink: palette.pink
    readonly property color purple: palette.purple
    readonly property color teal: palette.teal

    // ====================================================================
    // UTILITIES
    // ====================================================================
    readonly property color enabledAccent: palette.enabledAccent
    readonly property color transparent: palette.transparent

    // ====================================================================
    // FALLBACK PALETTES
    // ====================================================================

    readonly property QtObject lightColors: QtObject {
        // Accent
        readonly property color accent: "#0066CC"
        readonly property color accentHover: "#0059B3"
        readonly property color accentPressed: "#004C99"
        readonly property color accentDisabled: "#A8C7E8"
        readonly property color accentSelected: "#0059B3"
        readonly property color textOnAccent: "#FFFFFF"

        // Surfaces
        readonly property color background: "#E4E9ED"
        readonly property color surface: "#E4E9ED"
        readonly property color surfaceSunken: "#D8DEE5"
        readonly property color surfaceRaised: "#E4E9ED"
        readonly property color surfaceElevated: "#E9EEF2"
        readonly property color surfaceOverlay: "#EDF1F5"
        readonly property color surfaceHover: controlBackgroundHover
        readonly property color surfacePressed: surfaceSunken
        readonly property color surfaceDisabled: controlBackgroundDisabled
        readonly property color surfaceActive: accent
        readonly property color surfaceActiveMuted: "#D2E4F9"

        // Text
        readonly property color textPrimary: "#263544"
        readonly property color textSecondary: "#536474"
        readonly property color textTertiary: "#61758A"
        readonly property color textDisabled: "#8295A7"
        readonly property color textInverse: "#FFFFFF"

        // Borders
        readonly property color borderSubtle: "#D2DBE3"
        readonly property color border: "#BCCCDC"
        readonly property color borderStrong: "#91A6BC"
        readonly property color borderDisabled: "#DCE4EA"
        readonly property color borderFocus: accent
        readonly property color separator: "#CBD5DF"
        readonly property color borderRaised: borderSubtle
        readonly property color borderElevated: border

        // Controls
        readonly property color controlBackground: surface
        readonly property color controlBackgroundHover: "#EDF1F5"
        readonly property color controlBackgroundPressed: surfaceSunken
        readonly property color controlBackgroundDisabled: "#E3E8ED"
        readonly property color controlThumb: surfaceRaised
        readonly property color controlTrack: surfaceSunken
        readonly property color controlTrackHover: "#CED7E0"
        readonly property color controlTrackPressed: "#C2CDD7"
        readonly property color controlTrackDisabled: "#DFE5EB"

        // Inputs
        readonly property color inputBackground: surfaceSunken
        readonly property color inputBackgroundHover: "#DDE4EA"
        readonly property color inputBackgroundFocus: surfaceSunken
        readonly property color inputBackgroundDisabled: "#E0E5EA"
        readonly property color inputBorder: borderSubtle
        readonly property color inputBorderHover: border
        readonly property color inputBorderFocus: borderFocus
        readonly property color inputBorderError: error

        // Interaction
        readonly property color hover: "#0D263544"
        readonly property color pressed: "#19263544"
        readonly property color selected: "#1F0066CC"
        readonly property color selectionSurface: "#D2E4F9"
        readonly property color selectionBorder: "#80B8F0"
        readonly property color selectionText: "#004C99"
        readonly property color focusRing: "#660066CC"

        // Status
        readonly property color success: "#107C41"
        readonly property color successBackground: "#D8F3E5"
        readonly property color successText: "#0E5A30"
        readonly property color warning: "#B85A00"
        readonly property color warningBackground: "#FFF0DF"
        readonly property color warningText: "#874000"
        readonly property color error: "#B42318"
        readonly property color errorBackground: "#FDE8E7"
        readonly property color errorText: "#912018"
        readonly property color info: "#0066CC"
        readonly property color infoBackground: "#EAF3FF"
        readonly property color infoText: "#004C99"

        // Overlay & Lighting
        readonly property color scrim: "#66000000"
        readonly property color shadow: "#B0BAC5"
        readonly property color highlight: "#FFFFFF"
        readonly property color shadowDark: shadow
        readonly property color shadowLight: highlight
        readonly property color shadowAmbient: "#728396"

        // Optional Accents
        readonly property color cyan: "#0891B2"
        readonly property color indigo: "#5856D6"
        readonly property color orange: "#E67E00"
        readonly property color pink: "#DB2777"
        readonly property color purple: "#9333EA"
        readonly property color teal: "#0D9488"

        // Utilities
        readonly property color enabledAccent: textOnAccent
        readonly property color transparent: "transparent"
    }

    readonly property QtObject darkColors: QtObject {
        // Accent
        readonly property color accent: "#3B82F6"
        readonly property color accentHover: "#60A5FA"
        readonly property color accentPressed: "#2563EB"
        readonly property color accentDisabled: "#1E3A8A"
        readonly property color accentSelected: "#60A5FA"
        readonly property color textOnAccent: "#FFFFFF"

        // Surfaces
        readonly property color background: "#1E222A"
        readonly property color surface: "#1E222A"
        readonly property color surfaceSunken: "#15181E"
        readonly property color surfaceRaised: "#1E222A"
        readonly property color surfaceElevated: "#252A33"
        readonly property color surfaceOverlay: "#2A303A"
        readonly property color surfaceHover: controlBackgroundHover
        readonly property color surfacePressed: surfaceSunken
        readonly property color surfaceDisabled: controlBackgroundDisabled
        readonly property color surfaceActive: accent
        readonly property color surfaceActiveMuted: "#203B66"

        // Text
        readonly property color textPrimary: "#F1F5F9"
        readonly property color textSecondary: "#A8B8CA"
        readonly property color textTertiary: "#879AAF"
        readonly property color textDisabled: "#65768A"
        readonly property color textInverse: "#0F172A"

        // Borders
        readonly property color borderSubtle: "#2A303C"
        readonly property color border: "#333A48"
        readonly property color borderStrong: "#536175"
        readonly property color borderDisabled: "#252A33"
        readonly property color borderFocus: accent
        readonly property color separator: "#2A303C"
        readonly property color borderRaised: borderSubtle
        readonly property color borderElevated: border

        // Controls
        readonly property color controlBackground: surface
        readonly property color controlBackgroundHover: "#252A33"
        readonly property color controlBackgroundPressed: surfaceSunken
        readonly property color controlBackgroundDisabled: "#1A1D23"
        readonly property color controlThumb: surfaceRaised
        readonly property color controlTrack: surfaceSunken
        readonly property color controlTrackHover: "#1C2028"
        readonly property color controlTrackPressed: "#111317"
        readonly property color controlTrackDisabled: "#1A1D23"

        // Inputs
        readonly property color inputBackground: surfaceSunken
        readonly property color inputBackgroundHover: "#1B2028"
        readonly property color inputBackgroundFocus: surfaceSunken
        readonly property color inputBackgroundDisabled: "#1A1D23"
        readonly property color inputBorder: borderSubtle
        readonly property color inputBorderHover: borderStrong
        readonly property color inputBorderFocus: borderFocus
        readonly property color inputBorderError: error

        // Interaction
        readonly property color hover: "#14FFFFFF"
        readonly property color pressed: "#26FFFFFF"
        readonly property color selected: "#263B82F6"
        readonly property color selectionSurface: "#1E3A8A"
        readonly property color selectionBorder: "#60A5FA"
        readonly property color selectionText: "#E0F2FE"
        readonly property color focusRing: "#663B82F6"

        // Status
        readonly property color success: "#22C55E"
        readonly property color successBackground: "#064E3B"
        readonly property color successText: "#A7F3D0"
        readonly property color warning: "#F59E0B"
        readonly property color warningBackground: "#78350F"
        readonly property color warningText: "#FDE68A"
        readonly property color error: "#EF4444"
        readonly property color errorBackground: "#7F1D1D"
        readonly property color errorText: "#FECACA"
        readonly property color info: "#3B82F6"
        readonly property color infoBackground: "#1E3A8A"
        readonly property color infoText: "#BFDBFE"

        // Overlay & Lighting
        readonly property color scrim: "#80000000"
        readonly property color shadow: "#101318"
        readonly property color highlight: "#343C49"
        readonly property color shadowDark: shadow
        readonly property color shadowLight: highlight
        readonly property color shadowAmbient: "#080A0D"

        // Optional Accents
        readonly property color cyan: "#22D3EE"
        readonly property color indigo: "#818CF8"
        readonly property color orange: "#FB923C"
        readonly property color pink: "#F472B6"
        readonly property color purple: "#C084FC"
        readonly property color teal: "#2DD4BF"

        // Utilities
        readonly property color enabledAccent: textOnAccent
        readonly property color transparent: "transparent"
    }
}
