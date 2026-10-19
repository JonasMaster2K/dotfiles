pragma Singleton

import QtQuick
import "../config"

QtObject {
    id: typography

    // =========================================================================
    // FONT FAMILIES
    // =========================================================================

    readonly property string fontFamilyPrimary: "Inter"
    readonly property string fontFamilyMono: "JetBrainsMono Nerd Font"
    readonly property string fontFamilySerif: "Georgia"

    // Semantic families
    readonly property string fontFamilyBody: fontFamilyPrimary
    readonly property string fontFamilyHeading: fontFamilyPrimary
    readonly property string fontFamilyButton: fontFamilyPrimary
    readonly property string fontFamilyClock: fontFamilyPrimary
    readonly property string fontFamilyCode: fontFamilyMono

    // =========================================================================
    // FONT WEIGHTS
    // =========================================================================

    readonly property int weightLight: Font.Light
    readonly property int weightRegular: Font.Normal
    readonly property int weightMedium: Font.Medium
    readonly property int weightSemibold: Font.DemiBold
    readonly property int weightBold: Font.Bold

    // =========================================================================
    // FONT SIZES
    // =========================================================================

    readonly property real scale: Settings.scale * Settings.fontScale

    readonly property int size3Xs: Math.round(9 * scale)
    readonly property int size2Xs: Math.round(10 * scale)
    readonly property int sizeXs: Math.round(11 * scale)
    readonly property int sizeSm: Math.round(12 * scale)
    readonly property int sizeMd: Math.round(13 * scale)
    readonly property int sizeLg: Math.round(15 * scale)
    readonly property int sizeXl: Math.round(18 * scale)
    readonly property int size2Xl: Math.round(22 * scale)
    readonly property int size3Xl: Math.round(28 * scale)
    readonly property int size4Xl: Math.round(36 * scale)

    // =========================================================================
    // SEMANTIC FONT SIZES
    // =========================================================================

    // General
    readonly property int captionSize: sizeXs
    readonly property int bodySize: sizeMd
    readonly property int labelSize: sizeSm

    // Controls
    readonly property int buttonSize: sizeMd
    readonly property int inputSize: sizeMd
    readonly property int menuItemSize: sizeMd

    // Shell
    readonly property int taskBarSize: sizeSm
    readonly property int tooltipSize: sizeSm
    readonly property int notificationSize: sizeMd

    // Headings
    readonly property int titleSize: sizeXl
    readonly property int subtitleSize: sizeLg
    readonly property int headerSize: size3Xl

    // =========================================================================
    // LINE HEIGHTS
    // =========================================================================

    readonly property real lineHeightTight: 1.15
    readonly property real lineHeightNormal: 1.4
    readonly property real lineHeightRelaxed: 1.6

    // =========================================================================
    // LETTER SPACING
    // =========================================================================

    readonly property real letterSpacingTight: -0.5
    readonly property real letterSpacingNormal: 0.0
    readonly property real letterSpacingWide: 0.5
}
