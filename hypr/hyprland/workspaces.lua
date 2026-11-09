--hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
--hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })

--hl.window_rule({ 
--    match = { float = false, workspace = "w[tv1]s[false]" }, 
--    border_size = 0, 
--    rounding = 0 
--})

--hl.workspace_rule({ workspace = "2", on_created_empty = "zen-browser" })

hl.on("workspace.created", function(workspace)
    -- Check if it matches your target workspace name and is empty
    if workspace.name == "special:scratchpad" and workspace.is_empty then
        hl.exec_cmd("kitty")
    end
end)