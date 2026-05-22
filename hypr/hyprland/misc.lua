hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        disable_scale_notification = true,

        col = {
            splash = 0xff000000,
        },

        font_family = "JetBrainsMono NerdFont",
        splash_font_family = "",
        force_default_wallpaper = 0,
        vrr = 3,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        name_vk_after_proc = true,
        always_follow_on_dnd = true,
        layers_hog_keyboard_focus = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,
        disable_autoreload = false,
        enable_swallow = false,
        swallow_regex = "foot|kitty|allacritty|Allacritty",
        swallow_exception_regex = "",
        focus_on_activate = true,
        mouse_move_focuses_monitor = true,
        allow_session_lock_restore = true,
        session_lock_xray = true,
        background_color = 0xff000000,
        close_special_on_empty = true,
        on_focus_under_fullscreen = 1,
        exit_window_retains_fullscreen = false,
        initial_workspace_tracking = 1,
        middle_click_paste = true,
        render_unfocused_fps = 15,
        disable_xdg_env_checks = false,
        lockdead_screen_delay = 1000,
        enable_anr_dialog = true,
        size_limits_tiled = false,
        disable_watchdog_warning = false,
    },

    xwayland = {
        enabled = true,
        use_nearest_neighbor = true,
        force_zero_scaling = true,
        create_abstract_socket = false,
    },

    opengl = {
        nvidia_anti_flicker = true,
    },

    render = {
        direct_scanout = 0,
        expand_undersized_textures = true,
        xp_mode = false,
        ctm_animation = 2,
        cm_enabled = true,
        send_content_type = true,
        cm_auto_hdr = 1,
        new_render_scheduling = false,
        non_shader_cm = 2,
        non_shader_cm_interop = 2,
        cm_sdr_eotf = "default",
        commit_timing_enabled = true,
        use_fp16 = 2,
        keep_unmodified_copy = 2,
        use_shader_blur_blend = false,
    },

    ecosystem = {
        no_update_news = false,
        no_donation_nag = false,
        enforce_permissions = false,
    },

    quirks = {
        prefer_hdr = 0,
    },
})