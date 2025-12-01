-- hooks/env_keys.lua
-- Configures environment variables for the installed PHP
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#envkeys-hook

function PLUGIN:EnvKeys(ctx) -- luacheck: ignore
    local mainPath = ctx.path

    -- PHP environment configuration
    local env_vars = {
        -- Add PHP bin to PATH
        {
            key = "PATH",
            value = mainPath .. "/bin",
        },
        -- PHP home directory
        {
            key = "PHP_HOME",
            value = mainPath,
        },
    }

    -- Platform-specific library paths
    if RUNTIME.osType == "Darwin" then
        -- macOS uses DYLD_LIBRARY_PATH
        table.insert(env_vars, {
            key = "DYLD_LIBRARY_PATH",
            value = mainPath .. "/lib",
        })
    elseif RUNTIME.osType == "Linux" then
        -- Linux uses LD_LIBRARY_PATH
        table.insert(env_vars, {
            key = "LD_LIBRARY_PATH",
            value = mainPath .. "/lib",
        })
    end

    return env_vars
end
