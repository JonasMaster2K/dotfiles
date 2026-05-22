hl.config({
    animations = {
        enabled = true,
        workspace_wraparound = false,
    }
})

-- =========================================================
-- CURVES
-- =========================================================

-- Hauptkurve
hl.curve("smooth", {
    type = "bezier",
    points = {
        {0.15, 1},
        {0.15, 1}
    }
})

-- Snappy movement
hl.curve("move", {
    type = "bezier",
    points = {
        {0.18, 1},
        {0.30, 1}
    }
})

-- Workspaces
hl.curve("workspace", {
    type = "bezier",
    points = {
        {0.30, 1},
        {0.40, 1}
    }
})

-- UI / Menus
hl.curve("ui", {
    type = "bezier",
    points = {
        {0.16, 1},
        {0.28, 1}
    }
})

-- =========================================================
-- GLOBAL
-- =========================================================

hl.animation({
    leaf = "global",
    enabled = true,
    speed = 5,
    bezier = "smooth"
})

-- =========================================================
-- WINDOWS
-- =========================================================

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 8,
    bezier = "smooth",
    style = "slide"
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 12.5,
    bezier = "smooth",
    style = "slide"
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 10,
    bezier = "smooth",
    style = "slide"
})

hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 9,
    bezier = "move"
})

-- =========================================================
-- FADING
-- =========================================================

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 4,
    bezier = "smooth"
})

hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 4,
    bezier = "smooth"
})

hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 3.5,
    bezier = "smooth"
})

-- =========================================================
-- WORKSPACES
-- =========================================================

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 5,
    bezier = "workspace",
    style = "slide"
})

-- =========================================================
-- SPECIAL WORKSPACES
-- =========================================================

hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 5,
    bezier = "workspace",
    style = "slidevert"
})

hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 5,
    bezier = "workspace",
    style = "slidevert"
})

-- =========================================================
-- UI / LAYERS
-- =========================================================

hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 4,
    bezier = "ui",
    style = "fade"
})

hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4.5,
    bezier = "ui",
    style = "slidefade"
})

hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 3.2,
    bezier = "ui",
    style = "fade"
})

-- =========================================================
-- BORDER
-- =========================================================

hl.animation({
    leaf = "border",
    enabled = false
})

hl.animation({
    leaf = "borderangle",
    enabled = false
})

-- =========================================================
-- MISC
-- =========================================================

hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 5,
    bezier = "smooth"
})