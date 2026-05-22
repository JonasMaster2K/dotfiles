hl.config({
    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_touch = false,
        workspace_swipe_invert = true,
        workspace_swipe_touch_invert = false,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_cancel_ratio = 0.2,
        workspace_swipe_create_new = true,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_forever = false,
        workspace_swipe_use_r = false,
        close_max_timeout = 1000,
    }
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down", mods = "SUPER", action = "close"})
hl.gesture({ fingers = 3, direction = "vertical", action = "fullscreen"})