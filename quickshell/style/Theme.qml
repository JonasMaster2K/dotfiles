pragma Singleton

import QtQuick
import Quickshell
import "../config"

Singleton {
    id: theme

    // =========================================================================
    // THEME API — use these namespaces in new components
    // =========================================================================

    readonly property QtObject palette: Colors
    readonly property QtObject dimensions: Dimensions
    readonly property QtObject typography: Typography
    readonly property QtObject animations: Animations

    function toggleMode(): void {
        Settings.darkMode = !Settings.darkMode;
    }

    // =========================================================================
    // COMPAT / LEGACY — remove one property after migrating its call sites
    // =========================================================================
    // New code: Colors.*, Dimensions.*, Typography.*, Animations.*, Settings.*
    // Some old dimensions deliberately retain their historical numeric values.
    // No duplicate fallback palettes: Colors is the single source of truth.

    readonly property color accent: Colors.accent
    readonly property color accentDisabled: Colors.accentDisabled
    readonly property color accentForeground: Colors.textOnAccent
    readonly property color accentHover: Colors.accentHover
    readonly property color accentPressed: Colors.accentPressed
    readonly property color accentSelected: Colors.accentSelected
    readonly property int animationEasing: Animations.easingStandard
    readonly property int animationFast: Animations.animationFast
    readonly property int animationInstant: Animations.animationInstant
    readonly property int animationNormal: Animations.animationNormal
    readonly property int animationSlow: Animations.animationSlow
    readonly property int animationVeryFast: Animations.animationVeryFast
    readonly property int animationVerySlow: Animations.animationVerySlow
    readonly property real audioVisualizerBarSpacing: 2 * uiScale
    readonly property color audioVisualizerColor: accent
    readonly property real audioVisualizerHeight: 24 * uiScale
    readonly property int audioVisualizerHideDelay: 700
    readonly property real audioVisualizerMinimumBarHeight: 2 * uiScale
    readonly property real audioVisualizerMinimumBarWidth: 1 * uiScale
    readonly property real audioVisualizerSensitivity: 1.0
    readonly property real audioVisualizerSilenceThreshold: 0.02
    readonly property real audioVisualizerWidth: 100 * uiScale
    readonly property color background: Colors.background
    readonly property real barBottomMargin: 0 * barScale
    readonly property real barButtonIconSize: 24 * barScale
    readonly property real barButtonMinimumHeight: 34 * barScale
    readonly property real barButtonMinimumWidth: 34 * barScale
    readonly property real barButtonPadding: 6 * barScale
    readonly property real barButtonRadius: 10 * barScale
    readonly property real barButtonSpacing: 4 * barScale
    readonly property real barContentMargin: 6 * barScale
    readonly property real barControlHeight: 34 * barScale
    property real barHeight: 50 * uiScale
    readonly property real barHorizontalMargin: 0 * barScale
    readonly property real barIconSize: 24 * barScale
    readonly property real barPadding: 6 * barScale
    readonly property real barRadius: 0 * barScale
    readonly property real barScale: barHeight / baseBarHeight
    readonly property real barSpacing: 6 * barScale
    readonly property real barTopMargin: 0 * barScale
    readonly property real baseBarHeight: 50
    readonly property color borderColor: Colors.border
    readonly property color borderDisabled: Colors.borderDisabled
    readonly property color borderElevatedColor: Colors.borderElevated
    readonly property color borderFocusColor: Colors.borderFocus
    readonly property color borderRaisedColor: Colors.borderRaised
    readonly property color borderStrongColor: Colors.borderStrong
    readonly property color borderSubtleColor: Colors.borderSubtle
    readonly property real borderWidth: Dimensions.borderWidth
    readonly property real borderWidthFocus: 2 * uiScale
    readonly property real borderWidthStrong: Dimensions.borderWidthStrong
    readonly property color buttonAccent: accent
    readonly property color buttonAccentForeground: accentForeground
    readonly property color buttonAccentHover: accentHover
    readonly property color buttonAccentPressed: accentPressed
    readonly property color buttonBackground: normalBackground
    readonly property color buttonBorderColor: borderColor
    readonly property color buttonForeground: foreground
    readonly property color buttonForegroundSecondary: foregroundSecondary
    readonly property color buttonHoverBackground: hoverBackground
    readonly property real buttonIconSize: iconSizeMd
    readonly property real buttonMinimumHeight: 34 * uiScale
    readonly property real buttonMinimumWidth: 34 * uiScale
    readonly property real buttonPadding: spacingSm
    readonly property color buttonPressedBackground: pressedBackground
    readonly property real buttonRadius: radiusMd
    readonly property color buttonSelectedBackground: selectedBackground
    readonly property real buttonSpacing: spacingSm
    readonly property real calendarDayHeight: 38 * uiScale
    readonly property real cardGap: spacingLg
    readonly property real cardPadding: Dimensions.cardPadding
    readonly property real clockPopupActionWidth: 110 * uiScale
    readonly property real clockPopupStopwatchSize: 54 * uiScale
    readonly property real clockPopupTimeSize: 32 * uiScale
    readonly property real clockPopupTimerSize: 58 * uiScale
    readonly property real clockPopupWidth: 420 * uiScale
    readonly property QtObject colors: Colors
    readonly property real contentGap: spacingMd
    readonly property color controlBackground: Colors.controlBackground
    readonly property color controlBackgroundDisabled: Colors.controlBackgroundDisabled
    readonly property color controlBackgroundHover: Colors.controlBackgroundHover
    readonly property color controlBackgroundPressed: Colors.controlBackgroundPressed
    readonly property real controlGap: spacingSm
    readonly property real controlHeightLg: Dimensions.controlHeightLg
    readonly property real controlHeightMd: Dimensions.controlHeightMd
    readonly property real controlHeightSm: Dimensions.controlHeightSm
    readonly property real controlMinHeight: Dimensions.controlMinHeight
    readonly property real controlMinWidth: Dimensions.controlMinWidth
    readonly property real controlPaddingHorizontal: Dimensions.controlPaddingHorizontal
    readonly property real controlPaddingVertical: Dimensions.controlPaddingVertical
    readonly property color controlThumb: Colors.controlThumb
    readonly property color controlTrack: Colors.controlTrack
    readonly property color controlTrackDisabled: Colors.controlTrackDisabled
    readonly property color controlTrackHover: Colors.controlTrackHover
    readonly property color controlTrackPressed: Colors.controlTrackPressed
    readonly property real controlsPopupWidth: 440 * uiScale
    readonly property color cyan: Colors.cyan
    // Writable compatibility for legacy Theme.darkMode = ... usage.
    property bool darkMode: Settings.darkMode
    onDarkModeChanged: {
        if (Settings.darkMode !== darkMode)
            Settings.darkMode = darkMode;
    }
    readonly property real disabledOpacity: 0.42
    readonly property int easingBounce: Animations.easingBounce
    readonly property int easingEmphasized: Animations.easingEmphasized
    readonly property int easingSmooth: Animations.easingSmooth
    readonly property int easingStandard: Animations.easingStandard
    readonly property color error: Colors.error
    readonly property real floatingSurfaceRadius: radiusXl
    readonly property string fontFamily: Typography.fontFamilyPrimary
    readonly property string fontFamilyMono: Typography.fontFamilyMono
    readonly property real fontScale: Math.max(0.9, Math.min(1.2, uiScale))
    readonly property int fontSize2Xl: Math.round(24 * fontScale)
    readonly property int fontSize3Xl: Math.round(32 * fontScale)
    readonly property int fontSize4Xl: Math.round(40 * fontScale)
    readonly property int fontSizeLg: Math.round(16 * fontScale)
    readonly property int fontSizeMd: Math.round(13 * fontScale)
    readonly property int fontSizeSm: Math.round(11 * fontScale)
    readonly property int fontSizeXl: Math.round(20 * fontScale)
    readonly property int fontSizeXs: Math.round(10 * fontScale)
    readonly property int fontWeightBold: Typography.weightBold
    readonly property int fontWeightMedium: Typography.weightMedium
    readonly property int fontWeightRegular: Typography.weightRegular
    readonly property int fontWeightSemibold: Typography.weightSemibold
    readonly property color foreground: Colors.textPrimary
    readonly property color foregroundDisabled: Colors.textDisabled
    readonly property color foregroundMuted: Colors.textTertiary
    readonly property color foregroundOnAccent: Colors.textOnAccent
    readonly property color foregroundSecondary: Colors.textSecondary
    readonly property color highlight: Colors.highlight
    readonly property int hoverAnimationDuration: Animations.hoverDuration
    readonly property color hoverBackground: Colors.hover
    readonly property real iconSize2Md: 28 * uiScale
    readonly property real iconSize2Sm: 20 * uiScale
    readonly property real iconSize2Xl: Dimensions.iconSize2Xl
    readonly property real iconSize3Xl: 56 * uiScale
    readonly property real iconSizeLg: Dimensions.iconSizeLg
    readonly property real iconSizeMd: Dimensions.iconSizeMd
    readonly property real iconSizeSm: Dimensions.iconSizeSm
    readonly property real iconSizeXl: Dimensions.iconSizeXl
    readonly property real iconSizeXs: Dimensions.iconSizeXs
    readonly property color indigo: Colors.indigo
    readonly property color info: Colors.info
    readonly property color inputBackground: Colors.inputBackground
    readonly property color inputBackgroundHover: Colors.inputBackgroundHover
    readonly property color inputBorder: Colors.inputBorder
    readonly property real inputHeight: controlHeightLg
    readonly property real inputPaddingHorizontal: spacingLg
    readonly property real inputPaddingVertical: spacingMd
    readonly property real listItemGap: spacingMd
    readonly property real listItemMinHeight: controlHeightLg
    readonly property real listItemPadding: spacingLg
    readonly property string locale: "de_DE"
    readonly property int marqueeInterval: 10000
    readonly property real marqueeSpacing: 40 * uiScale
    readonly property real marqueeSpeed: 35
    readonly property int marqueeStartDelay: 5000
    readonly property real mediaMaximumWidth: 200 * uiScale
    readonly property real mediaMinimumWidth: 100 * uiScale
    readonly property color mediaPauseOverlay: darkMode ? "#80000000" : "#55000000"
    readonly property real mediaPopupContentWidth: 300 * uiScale
    readonly property real mediaPopupIconSize: 64 * uiScale
    readonly property real mediaPopupPlayButtonWidth: 110 * uiScale
    readonly property real mediaPopupWidth: 480 * uiScale
    readonly property color mediaProgressOverlay: darkMode ? "#95FFFFFF" : "#55000000"
    readonly property real mediaSimpleWidth: 150 * uiScale
    readonly property real mutedOpacity: 0.52
    readonly property color normalBackground: "transparent"
    readonly property real notificationDismissButtonSize: 28 * uiScale
    readonly property int notificationDismissDuration: Animations.notificationExitDuration
    readonly property real notificationIconContainerSize: 44 * uiScale
    readonly property real notificationToggleHeight: 38 * uiScale
    readonly property real notificationsEmptyStatePadding: 60 * uiScale
    readonly property real notificationsPopupListMaximumHeight: 640 * uiScale
    readonly property real notificationsPopupWidth: 500 * uiScale
    readonly property color orange: Colors.orange
    readonly property real overlayOffset: spacingMd
    readonly property color panelBackground: surfaceOverlay
    readonly property color panelBorderColor: borderColor
    readonly property real panelBorderWidth: borderWidth
    readonly property real panelEffectHeight: 8 * uiScale
    readonly property color panelElevatedBackground: surfaceElevated
    readonly property color panelElevatedBorderColor: borderElevatedColor
    readonly property color panelHighlightSoft: darkMode ? "#14FFFFFF" : "#20FFFFFF"
    readonly property color panelHighlightStrong: darkMode ? "#48FFFFFF" : "#40FFFFFF"
    readonly property real panelPadding: 12 * uiScale
    readonly property real panelRadius: radiusLg
    readonly property color panelRaisedBackground: surfaceRaised
    readonly property color panelRaisedBorderColor: borderRaisedColor
    readonly property color panelShadowSoft: darkMode ? "#28000000" : "#10000000"
    readonly property color panelShadowStrong: darkMode ? "#90000000" : "#30000000"
    readonly property color pink: Colors.pink
    readonly property real pomodoroActionWidth: 110 * uiScale
    readonly property real pomodoroPopupWidth: 380 * uiScale
    readonly property real pomodoroTimeSize: 52 * uiScale
    readonly property int popupAnimationDuration: Animations.popupEnterDuration
    readonly property color popupBackground: background
    readonly property color popupBorderColor: borderColor
    readonly property real popupBorderWidth: borderWidth
    readonly property real popupContentGap: spacingLg
    readonly property real popupContentPadding: spacingXl
    readonly property real popupHeight: 600 * uiScale
    readonly property real popupMaximumHeight: 1400 * uiScale
    readonly property real popupMaximumWidth: 640 * uiScale
    readonly property real popupMinimumHeight: 0 * uiScale
    readonly property real popupMinimumWidth: 240 * uiScale
    readonly property real popupOffset: spacingMd
    readonly property real popupPadding: spacingXl
    readonly property real popupRadius: radiusXl
    readonly property real popupSlideDistance: 10 * uiScale
    readonly property real popupSpacing: spacingLg
    readonly property real popupWidth: 500 * uiScale
    readonly property int pressAnimationDuration: Animations.pressDuration
    readonly property color pressedBackground: Colors.pressed
    readonly property color progressBackground: darkMode ? "#22FFFFFF" : "#18000000"
    readonly property color progressForeground: accent
    readonly property real progressHeight: 4 * uiScale
    readonly property real progressRadius: radiusPill
    readonly property real progressTrackHeight: spacingSm
    readonly property color purple: Colors.purple
    readonly property real quickControlSliderHeight: 8 * uiScale
    readonly property real quickControlTileHeight: 72 * uiScale
    readonly property real radius2Xl: Dimensions.radius2Xl
    readonly property real radiusCard: Dimensions.radiusCard
    readonly property real radiusControl: Dimensions.radiusControl
    readonly property real radiusLg: Dimensions.radiusLg
    readonly property real radiusMd: Dimensions.radiusMd
    readonly property real radiusPill: Dimensions.radiusPill
    readonly property real radiusSm: Dimensions.radiusSm
    readonly property real radiusXl: Dimensions.radiusXl
    readonly property color scrimColor: Colors.scrim
    readonly property real secondaryOpacity: 0.72
    readonly property real sectionGap: spacingLg
    readonly property color selectedBackground: Colors.selected
    readonly property color selectionBorder: Colors.selectionBorder
    readonly property color selectionSurface: Colors.selectionSurface
    readonly property color separatorColor: Colors.separator
    readonly property real separatorWidth: borderWidth
    readonly property color shadowColor: Colors.shadow
    readonly property real shadowOpacity: 0.18
    readonly property real shadowRadius: 18 * uiScale
    readonly property int slideAnimationDuration: Animations.animationNormal
    readonly property real sliderTrackHeight: spacingSm
    readonly property real spacing2Xl: Dimensions.spacing2Xl
    readonly property real spacing3Xl: Dimensions.spacing3Xl
    readonly property real spacing4Xl: Dimensions.spacing4Xl
    readonly property real spacing5Xl: 48 * uiScale
    readonly property real spacing6Xl: 64 * uiScale
    readonly property real spacingLg: Dimensions.spacingLg
    readonly property real spacingMd: Dimensions.spacingMd
    readonly property real spacingSm: Dimensions.spacingSm
    readonly property real spacingXl: Dimensions.spacingXl
    readonly property real spacingXs: Dimensions.spacingXs
    readonly property color success: Colors.success
    readonly property color surface: Colors.surface
    readonly property color surfaceElevated: Colors.surfaceElevated
    readonly property color surfaceOverlay: Colors.surfaceOverlay
    readonly property color surfaceRaised: Colors.surfaceRaised
    readonly property color surfaceSunken: Colors.surfaceSunken
    readonly property color switchHandleColor: controlThumb
    readonly property real switchHandleSize: switchHeight - switchPadding * 2
    readonly property real switchHeight: 20 * uiScale
    readonly property real switchPadding: 2 * uiScale
    readonly property real switchWidth: switchHeight * 1.9
    readonly property color systemMetricHot: darkMode ? "#D0D1D5" : "#B68A43"
    readonly property int systemTrayMaxColumns: 5
    readonly property color teal: Colors.teal
    readonly property color tooltipBackground: darkMode ? "#E6222225" : "#E6292723"
    readonly property real tooltipContentPadding: spacingMd
    readonly property int tooltipDelay: 450
    readonly property color tooltipForeground: darkMode ? "#F1F1F3" : "#F8F5EE"
    readonly property real tooltipPaddingHorizontal: spacingMd
    readonly property real tooltipPaddingVertical: spacingSm
    readonly property real tooltipRadius: radiusSm
    readonly property real touchTargetMinSize: 40 * uiScale
    readonly property color transparent: Colors.transparent
    readonly property real uiScale: Settings.scale
    readonly property color warning: Colors.warning
    readonly property real workspaceIconSize: iconSize2Md

    readonly property QtObject lightColors: Colors.lightColors
    readonly property QtObject darkColors: Colors.darkColors

    // Synchronize if a new component changes Settings.darkMode.
    Connections {
        target: Settings
        function onDarkModeChanged() {
            if (theme.darkMode !== Settings.darkMode)
                theme.darkMode = Settings.darkMode;
        }
    }
}
