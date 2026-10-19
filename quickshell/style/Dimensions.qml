pragma Singleton

import QtQuick
import "../config"

QtObject {
    id: dimensions

    // =========================================================================
    // FOUNDATION TOKENS
    // =========================================================================

    // -------------------------------------------------------------------------
    // Spacing
    // -------------------------------------------------------------------------

    readonly property real spacingXs: 4 * Settings.scale
    readonly property real spacingSm: 8 * Settings.scale
    readonly property real spacingMd: 12 * Settings.scale
    readonly property real spacingLg: 16 * Settings.scale
    readonly property real spacingXl: 24 * Settings.scale
    readonly property real spacing2Xl: 32 * Settings.scale
    readonly property real spacing3Xl: 48 * Settings.scale
    readonly property real spacing4Xl: 64 * Settings.scale

    // -------------------------------------------------------------------------
    // Borders
    // -------------------------------------------------------------------------

    readonly property real borderWidth: 1 * Settings.scale
    readonly property real borderWidthStrong: 2 * Settings.scale

    // -------------------------------------------------------------------------
    // Corner Radii
    // -------------------------------------------------------------------------

    readonly property real radiusNone: 0
    readonly property real radiusXs: 2 * Settings.scale
    readonly property real radiusSm: 4 * Settings.scale
    readonly property real radiusMd: 8 * Settings.scale
    readonly property real radiusLg: 12 * Settings.scale
    readonly property real radiusXl: 16 * Settings.scale
    readonly property real radius2Xl: 24 * Settings.scale
    readonly property real radiusPill: 9999

    // -------------------------------------------------------------------------
    // Control Heights
    // -------------------------------------------------------------------------

    readonly property real controlHeightXs: 24 * Settings.scale
    readonly property real controlHeightSm: 28 * Settings.scale
    readonly property real controlHeightMd: 36 * Settings.scale
    readonly property real controlHeightLg: 44 * Settings.scale
    readonly property real controlHeightXl: 52 * Settings.scale

    // -------------------------------------------------------------------------
    // Icon Sizes
    // -------------------------------------------------------------------------

    readonly property real iconSizeXs: 12 * Settings.scale
    readonly property real iconSizeSm: 16 * Settings.scale
    readonly property real iconSizeMd: 20 * Settings.scale
    readonly property real iconSizeLg: 24 * Settings.scale
    readonly property real iconSizeXl: 32 * Settings.scale
    readonly property real iconSize2Xl: 48 * Settings.scale

    // -------------------------------------------------------------------------
    // Shadow Radii
    // -------------------------------------------------------------------------

    readonly property real shadowRadiusXs: 2 * Settings.scale
    readonly property real shadowRadiusSm: 6 * Settings.scale
    readonly property real shadowRadiusMd: 12 * Settings.scale
    readonly property real shadowRadiusLg: 24 * Settings.scale
    readonly property real shadowRadiusXl: 40 * Settings.scale

    // -------------------------------------------------------------------------
    // Shadow Offsets
    // -------------------------------------------------------------------------

    readonly property real shadowOffsetXs: 1 * Settings.scale
    readonly property real shadowOffsetSm: 2 * Settings.scale
    readonly property real shadowOffsetMd: 6 * Settings.scale
    readonly property real shadowOffsetLg: 12 * Settings.scale
    readonly property real shadowOffsetXl: 20 * Settings.scale

    // -------------------------------------------------------------------------
    // Shadow Opacities
    // -------------------------------------------------------------------------

    readonly property real shadowOpacityXs: 0.12
    readonly property real shadowOpacitySm: 0.16
    readonly property real shadowOpacityMd: 0.20
    readonly property real shadowOpacityLg: 0.25
    readonly property real shadowOpacityXl: 0.32

    // =========================================================================
    // SEMANTIC TOKENS
    // =========================================================================

    // -------------------------------------------------------------------------
    // Corner Radii
    // -------------------------------------------------------------------------

    readonly property real radiusControl: radiusMd
    readonly property real radiusButton: radiusMd
    readonly property real radiusInput: radiusMd
    readonly property real radiusCard: radiusLg
    readonly property real radiusModal: radiusXl
    readonly property real radiusMenu: radiusLg
    readonly property real radiusTooltip: radiusSm

    // -------------------------------------------------------------------------
    // Controls
    // -------------------------------------------------------------------------

    readonly property real controlMinHeight: controlHeightMd
    readonly property real controlMinWidth: controlHeightMd

    readonly property real controlPaddingHorizontal: spacingSm
    readonly property real controlPaddingVertical: spacingXs

    // -------------------------------------------------------------------------
    // Focus & Interaction
    // -------------------------------------------------------------------------

    readonly property real focusRingWidth: 2 * Settings.scale
    readonly property real focusRingOffset: 2 * Settings.scale
    readonly property real hitTargetMin: 32 * Settings.scale

    // -------------------------------------------------------------------------
    // Elevation
    // -------------------------------------------------------------------------

    // Card
    readonly property real shadowCardRadius: shadowRadiusSm
    readonly property real shadowCardOffset: shadowOffsetXs
    readonly property real shadowCardOpacity: shadowOpacitySm

    // Popup
    readonly property real shadowPopupRadius: shadowRadiusLg
    readonly property real shadowPopupOffset: shadowOffsetMd
    readonly property real shadowPopupOpacity: shadowOpacityLg

    // Modal
    readonly property real shadowModalRadius: shadowRadiusXl
    readonly property real shadowModalOffset: shadowOffsetLg
    readonly property real shadowModalOpacity: shadowOpacityXl

    // =========================================================================
    // LAYOUT TOKENS
    // =========================================================================

    // -------------------------------------------------------------------------
    // Screen
    // -------------------------------------------------------------------------

    readonly property real screenMargin: spacingLg

    // -------------------------------------------------------------------------
    // Taskbar
    // -------------------------------------------------------------------------
    readonly property real taskBarBaseHeight: 48 * Settings.scale
    readonly property real taskBarHeight: Settings.taskBarSize == "sm" ? 40 * Settings.scale : Settings.taskBarSize == "md" ? 48 * Settings.scale : Settings.taskBarSize == "lg" ? 56 * Settings.scale : 48 * Settings.scale
    readonly property real taskBarScale: taskBarHeight / taskBarBaseHeight
    readonly property real taskBarOuterMargin: Settings.taskBarStyle == "island" ? spacingXs : 0
    readonly property real taskBarInnerMargin: spacingSm
    readonly property real taskBarRadius: Settings.taskBarStyle == "island" ? radiusCard : 0
    readonly property real taskBarWidgetSizeSm: controlHeightSm * taskBarScale * Settings.scale
    readonly property real taskBarWidgetSizeMd: controlHeightMd * taskBarScale * Settings.scale
    readonly property real taskBarIconSizeSm: iconSizeSm * taskBarScale * Settings.scale
    readonly property real taskBarIconSizeMd: iconSizeMd * taskBarScale * Settings.scale
    readonly property real taskBarIconSizeLg: iconSizeLg * taskBarScale * Settings.scale

    // -------------------------------------------------------------------------
    // Sidebar
    // -------------------------------------------------------------------------

    readonly property real sidebarWidth: 240 * Settings.scale
    readonly property real sidebarWidthCollapsed: 56 * Settings.scale
    readonly property real sidebarPadding: spacingMd
    readonly property real sidebarItemSpacing: spacingXs

    readonly property real navigationItemHeight: 40 * Settings.scale

    // -------------------------------------------------------------------------
    // Toolbar
    // -------------------------------------------------------------------------

    readonly property real toolBarHeight: 48 * Settings.scale
    readonly property real toolBarPadding: spacingMd
    readonly property real toolBarSpacing: spacingSm

    // -------------------------------------------------------------------------
    // Menus
    // -------------------------------------------------------------------------

    readonly property real menuMinWidth: 180 * Settings.scale
    readonly property real menuItemHeight: 36 * Settings.scale
    readonly property real menuPadding: spacingXs
    readonly property real menuItemSpacing: spacingXs

    // -------------------------------------------------------------------------
    // Popups
    // -------------------------------------------------------------------------

    readonly property real popupMinWidth: 280 * Settings.scale
    readonly property real popupMaxWidth: 420 * Settings.scale
    readonly property real popupGap: spacingSm

    // -------------------------------------------------------------------------
    // Dialogs
    // -------------------------------------------------------------------------

    readonly property real dialogMinWidth: 320 * Settings.scale
    readonly property real dialogMaxWidth: 600 * Settings.scale
    readonly property real dialogPadding: spacingXl

    // -------------------------------------------------------------------------
    // Cards
    // -------------------------------------------------------------------------

    readonly property real cardPadding: spacingLg
    readonly property real cardSpacing: spacingMd

    // -------------------------------------------------------------------------
    // Lists & Tables
    // -------------------------------------------------------------------------

    readonly property real listItemHeight: 40 * Settings.scale
    readonly property real tableRowHeight: 40 * Settings.scale
    readonly property real tableHeaderHeight: 36 * Settings.scale
}
