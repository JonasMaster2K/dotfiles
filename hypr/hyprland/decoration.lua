hl.config({
    decoration = {
        rounding = 16,
        rounding_power = 2.0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        dim_modal = true,
        dim_inactive = true,
        dim_strength = 0.1,
        dim_special = 0.2,
        dim_around = 0.4,
        screen_shader = "",
        border_part_of_window = true,

        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            ignore_opacity = true,
            new_optimizations = true,
            xray = false,
            noise = 0.00,
            contrast = 0.7,
            brightness = 0.85,
            vibrancy = 0.45,
            vibrancy_darkness = 0.5,
            special = false,
            popups = true,
            popups_ignorealpha = 0.2,
            input_methods = false,
            input_methods_ignorealpha = 0.2
        },

        shadow = {
            enabled = true,
            range = 10,
            render_power = 3,
            sharp = false,
            color = 0xbb222222,
            color_inactive = 0xbb222222,
            offset = {0, 0},
            scale = 1.0,
        },

        glow = {
            enabled = false,
            range = 10,
            render_power = 3,
            color = 0xdd444444,
            color_inactive = 0xbb222222,
        }
    }
})