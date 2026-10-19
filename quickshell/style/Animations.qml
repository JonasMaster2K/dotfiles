pragma Singleton

import QtQuick
import "../config"

QtObject {
    id: animations

    // =========================================================================
    // ANIMATION DURATIONS
    // =========================================================================

    readonly property int animationInstant: 0
    readonly property int animationVeryFast: Settings.reducedMotion ? 0 : 80
    readonly property int animationFast: Settings.reducedMotion ? 0 : 120
    readonly property int animationNormal: Settings.reducedMotion ? 0 : 180
    readonly property int animationSlow: Settings.reducedMotion ? 0 : 280
    readonly property int animationVerySlow: Settings.reducedMotion ? 0 : 500

    // =========================================================================
    // EASING CURVES
    // =========================================================================

    readonly property int easingLinear: Easing.Linear
    readonly property int easingStandard: Easing.OutCubic
    readonly property int easingSmooth: Easing.InOutQuad
    readonly property int easingEmphasized: Easing.OutExpo
    readonly property int easingBounce: Easing.OutBack

    // =========================================================================
    // INTERACTION DURATIONS
    // =========================================================================

    readonly property int hoverDuration: animationFast
    readonly property int pressDuration: animationVeryFast
    readonly property int releaseDuration: animationFast
    readonly property int focusDuration: animationFast
    readonly property int toggleDuration: animationNormal

    // =========================================================================
    // SURFACE TRANSITIONS
    // =========================================================================

    readonly property int elevationDuration: animationNormal
    readonly property int shadowDuration: animationNormal
    readonly property int colorDuration: animationNormal
    readonly property int themeDuration: animationSlow

    // =========================================================================
    // COMPONENT TRANSITIONS
    // =========================================================================

    readonly property int popupEnterDuration: animationNormal
    readonly property int popupExitDuration: animationFast

    readonly property int notificationEnterDuration: animationSlow
    readonly property int notificationExitDuration: animationNormal

    readonly property int sidebarDuration: animationSlow
    readonly property int menuDuration: animationFast
    readonly property int tooltipDuration: animationFast

    // =========================================================================
    // SEMANTIC EASING
    // =========================================================================

    readonly property int easingHover: easingStandard
    readonly property int easingPress: easingStandard
    readonly property int easingRelease: easingSmooth
    readonly property int easingElevation: easingSmooth

    readonly property int easingEnter: easingEmphasized
    readonly property int easingExit: easingStandard
    readonly property int easingTheme: easingSmooth

    // =========================================================================
    // MOTION DISTANCES
    // =========================================================================

    readonly property real motionDistanceSm: Settings.reducedMotion ? 0 : 4 * Settings.scale

    readonly property real motionDistanceMd: Settings.reducedMotion ? 0 : 8 * Settings.scale

    readonly property real motionDistanceLg: Settings.reducedMotion ? 0 : 16 * Settings.scale

    // =========================================================================
    // SCALE EFFECTS
    // =========================================================================

    readonly property real scalePressed: Settings.reducedMotion ? 1.0 : 0.98
    readonly property real scaleHover: Settings.reducedMotion ? 1.0 : 1.02
    readonly property real scaleNormal: 1.0
}
