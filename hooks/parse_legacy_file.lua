-- hooks/parse_legacy_file.lua
-- Parses legacy PHP version files (.php-version, .phpenv-version)
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#parselegacyfile-hook

function PLUGIN:ParseLegacyFile(ctx) -- luacheck: ignore
    local filename = ctx.filename
    local filepath = ctx.filepath

    -- Read file content
    local file = io.open(filepath, "r")
    if not file then
        return { version = nil }
    end

    local content = file:read("*all")
    file:close()

    if not content then
        return { version = nil }
    end

    -- Parse version from file content
    -- Support formats like:
    --   8.4.6
    --   php-8.4.6
    --   8.4
    --   ^8.4 (constraint style - use latest 8.4.x)

    local version = nil

    -- Try to match php-X.Y.Z format
    version = content:match("php%-([%d%.]+)")

    -- Try to match plain version X.Y.Z or X.Y
    if not version then
        version = content:match("^%s*([%d%.]+)%s*$")
    end

    -- Try to match ^X.Y constraint (just extract the base version)
    if not version then
        version = content:match("^%s*%^([%d%.]+)")
    end

    -- Clean up whitespace
    if version then
        version = version:gsub("%s+", "")
    end

    return {
        version = version
    }
end
