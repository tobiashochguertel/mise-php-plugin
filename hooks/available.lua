-- hooks/available.lua
-- Returns a list of available PHP versions from TorstenDittmann/php-binaries
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#available-hook

function PLUGIN:Available(ctx) -- luacheck: ignore
    local http = require("http")
    local json = require("json")

    -- Fetch releases from TorstenDittmann/php-binaries
    -- This repo provides prebuilt PHP binaries for Linux and macOS
    local repo_url = "https://api.github.com/repos/TorstenDittmann/php-binaries/releases"

    local resp, err = http.get({
        url = repo_url,
    })

    if err ~= nil then
        error("Failed to fetch PHP versions: " .. err)
    end
    if resp.status_code ~= 200 then
        error("GitHub API returned status " .. resp.status_code .. ": " .. resp.body)
    end

    local releases = json.decode(resp.body)
    local versions = {}
    local seen = {}

    -- Parse releases to extract PHP versions
    -- Release format: assets like "php-8.4.6-macos-arm64.tar.gz"
    for _, release in ipairs(releases) do
        if release.assets then
            for _, asset in ipairs(release.assets) do
                -- Extract version from asset name: php-X.Y.Z-os-arch.tar.gz
                local version = asset.name:match("^php%-([%d%.]+)%-")
                if version and not seen[version] then
                    seen[version] = true

                    -- Determine note based on version
                    local note = nil
                    local major, minor = version:match("^(%d+)%.(%d+)")
                    if major == "8" and minor == "5" then
                        note = "latest"
                    elseif major == "8" and minor == "4" then
                        note = "stable"
                    end

                    table.insert(versions, {
                        version = version,
                        note = note,
                    })
                end
            end
        end
    end

    -- Sort versions in descending order (newest first)
    table.sort(versions, function(a, b)
        local function parse_version(v)
            local parts = {}
            for num in v.version:gmatch("%d+") do
                table.insert(parts, tonumber(num))
            end
            return parts
        end

        local va = parse_version(a)
        local vb = parse_version(b)

        for i = 1, math.max(#va, #vb) do
            local na = va[i] or 0
            local nb = vb[i] or 0
            if na ~= nb then
                return na > nb
            end
        end
        return false
    end)

    return versions
end
