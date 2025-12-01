-- hooks/pre_install.lua
-- Returns download information for a specific PHP version
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#preinstall-hook

-- Helper function for platform detection
local function get_platform()
    -- RUNTIME object is provided by mise/vfox
    -- RUNTIME.osType: "Windows", "Linux", "Darwin"
    -- RUNTIME.archType: "amd64", "386", "arm64", etc.

    local os_name = RUNTIME.osType:lower()
    local arch = RUNTIME.archType

    -- Map to TorstenDittmann/php-binaries naming convention
    -- Format: php-X.Y.Z-{macos|linux}-{arm64|x64}.tar.gz
    local os_map = {
        ["darwin"] = "macos",
        ["linux"] = "linux",
        ["windows"] = "windows",
    }

    local arch_map = {
        ["amd64"] = "x64",
        ["x86_64"] = "x64",
        ["arm64"] = "arm64",
        ["aarch64"] = "arm64",
    }

    local mapped_os = os_map[os_name] or os_name
    local mapped_arch = arch_map[arch] or arch

    return mapped_os, mapped_arch
end

-- Try to find PHP binary from TorstenDittmann/php-binaries
local function try_torsten_dittmann(version, os_name, arch, http, json)
    local releases_url = "https://api.github.com/repos/TorstenDittmann/php-binaries/releases"
    local resp, err = http.get({ url = releases_url })

    if err ~= nil then
        return nil, nil
    end

    local releases = json.decode(resp.body)
    local filename = "php-" .. version .. "-" .. os_name .. "-" .. arch .. ".tar.gz"

    for _, release in ipairs(releases) do
        if release.assets then
            for _, asset in ipairs(release.assets) do
                if asset.name == filename then
                    return asset.browser_download_url, nil
                end
            end
        end
    end

    return nil, nil
end

-- Try to find PHP binary from tobiashochguertel/php (fork with 8.5+ support)
local function try_hochguertel_php(version, os_name, arch, http, json)
    -- This source uses static-php-cli naming: php-X.Y.Z-{linux|macos}-{x86_64|aarch64}.tar.gz
    local arch_map_static = {
        ["x64"] = "x86_64",
        ["arm64"] = "aarch64",
    }
    local static_arch = arch_map_static[arch] or arch

    local releases_url = "https://api.github.com/repos/tobiashochguertel/php/releases"
    local resp, err = http.get({ url = releases_url })

    if err ~= nil then
        return nil, nil
    end

    local releases = json.decode(resp.body)
    local filename = "php-" .. version .. "-" .. os_name .. "-" .. static_arch .. ".tar.gz"

    for _, release in ipairs(releases) do
        -- Check if this release matches our version (tag like v8.4.15)
        local release_version = release.tag_name:gsub("^v", "")
        if release_version == version and release.assets then
            for _, asset in ipairs(release.assets) do
                if asset.name == filename then
                    return asset.browser_download_url, nil
                end
            end
        end
    end

    return nil, nil
end

function PLUGIN:PreInstall(ctx) -- luacheck: ignore
    local version = ctx.version
    local os_name, arch = get_platform()

    -- Check for unsupported platforms
    if os_name == "windows" then
        error("Windows is not supported by this PHP plugin. Use the official PHP binaries from windows.php.net")
    end

    local http = require("http")
    local json = require("json")

    -- Try sources in order of preference
    local download_url = nil
    local source_name = nil

    -- 1. Try TorstenDittmann/php-binaries (has more extensions, dynamically linked)
    download_url = try_torsten_dittmann(version, os_name, arch, http, json)
    if download_url then
        source_name = "TorstenDittmann/php-binaries"
    end

    -- 2. Try tobiashochguertel/php (static binaries, may have newer versions)
    if not download_url then
        download_url = try_hochguertel_php(version, os_name, arch, http, json)
        if download_url then
            source_name = "tobiashochguertel/php"
        end
    end

    if not download_url then
        error("PHP " .. version .. " is not available for " .. os_name .. "-" .. arch ..
              ". Check: https://github.com/TorstenDittmann/php-binaries/releases or https://github.com/tobiashochguertel/php/releases")
    end

    return {
        version = version,
        url = download_url,
        note = "Downloading PHP " .. version .. " from " .. source_name,
    }
end
