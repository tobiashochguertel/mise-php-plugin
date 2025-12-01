-- hooks/post_install.lua
-- Performs additional setup after PHP installation
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#postinstall-hook

function PLUGIN:PostInstall(ctx) -- luacheck: ignore
    local sdkInfo = ctx.sdkInfo["php"]
    local path = sdkInfo.path
    local version = sdkInfo.version

    -- Set executable permissions on Unix systems
    if RUNTIME.osType ~= "Windows" then
        -- Make all binaries executable
        os.execute("chmod +x " .. path .. "/bin/* 2>/dev/null || true")
    end

    -- Create php.ini if it doesn't exist
    local ini_path = path .. "/lib/php.ini"
    local ini_dev_path = path .. "/lib/php.ini-development"

    -- Check if php.ini-development exists and copy it
    local f = io.open(ini_dev_path, "r")
    if f then
        f:close()
        local ini_check = io.open(ini_path, "r")
        if not ini_check then
            os.execute("cp " .. ini_dev_path .. " " .. ini_path .. " 2>/dev/null || true")
        else
            ini_check:close()
        end
    end

    -- Print installation complete message
    print("PHP " .. version .. " installed successfully!")
    print("Binary location: " .. path .. "/bin/php")
end
