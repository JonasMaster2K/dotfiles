hl.config({
    general = {
        border_size = 0,
        gaps_in = 5,
        gaps_out = 5,
        float_gaps = 4,
        gaps_workspaces = 0,

        col = {
            active_border = 0x7aa2f7ff,
            inactive_border = 0xbb9af7ff,
            nogroup_border_active = 0x7aa2f7ff,
            nogroup_border = 0xbb9af7ff,
        },

        layout = "dwindle",
        no_focus_fallback = false,
        resize_on_border = true,
        extend_border_grab_area = 15,
        hover_icon_on_border = true,
        allow_tearing = false,
        resize_corner = 0,
        modal_parent_blocking = true,
        locale = "",

        snap = {
            enabled = true,
            window_gap = 10,
            monitor_gap = 10,
            border_overlap = true,
            respect_gaps = true,
        }
    }
})