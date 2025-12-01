-- hooks/available.lua
-- Returns a list of available PHP versions from multiple sources
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#available-hook

function PLUGIN:Available(ctx) -- luacheck: ignore
    local http = require("http")
    local json = require("json")

    local versions = {}
    local seen = {}

    -- Source 1: TorstenDittmann/php-binaries
    local torsten_url = "https://api.github.com/repos/TorstenDittmann/php-binaries/releases"
    local resp, err = http.get({ url = torsten_url })

    if err == nil and resp.status_code == 200 then
        local releases = json.decode(resp.body)
        for _, release in ipairs(releases) do
            if release.assets then
                for _, asset in ipairs(release.assets) do
                    local version = asset.name:match("^php%-([%d%.]+)%-")
                    if version and not seen[version] then
                        seen[version] = true
                        table.insert(versions, {
                            version = version,
                            note = nil,
                        })
                    end
                end
            end
        end
    end

    -- Source 2: tobiashochguertel/php (fork with static binaries)
    local hochguertel_url = "https://api.github.com/repos/tobiashochguertel/php/releases"
    resp, err = http.get({ url = hochguertel_url })

    if err == nil and resp.status_code == 200 then
        local releases = json.decode(resp.body)
        for _, release in ipairs(releases) do
            local version = release.tag_name:gsub("^v", "")
            if version and not seen[version] then
                seen[version] = true
                table.insert(versions, {
                    version = version,
                    note = "static",
                })
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
