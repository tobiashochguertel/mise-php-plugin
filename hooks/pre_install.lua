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
        ["windows"] = "windows", -- Not supported by this source
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

-- Fetch checksum from GitHub release
local function fetch_checksum(version, filename)
    local http = require("http")

    -- TorstenDittmann releases don't have checksums in a separate file
    -- We could potentially fetch from the release API if they add them
    -- For now, return nil (mise will still work, just without verification)
    return nil
end

function PLUGIN:PreInstall(ctx) -- luacheck: ignore
    local version = ctx.version
    local os_name, arch = get_platform()

    -- Check for unsupported platforms
    if os_name == "windows" then
        error("Windows is not supported by this PHP plugin. Use the official PHP binaries from windows.php.net")
    end

    -- Build download URL for TorstenDittmann/php-binaries
    -- Format: https://github.com/TorstenDittmann/php-binaries/releases/download/{release_tag}/php-{version}-{os}-{arch}.tar.gz
    -- Release tags use format like "2025.04.20-3"

    -- First, we need to find which release contains this PHP version
    local http = require("http")
    local json = require("json")

    local releases_url = "https://api.github.com/repos/TorstenDittmann/php-binaries/releases"
    local resp, err = http.get({ url = releases_url })

    if err ~= nil then
        error("Failed to fetch releases: " .. err)
    end

    local releases = json.decode(resp.body)
    local download_url = nil
    local filename = "php-" .. version .. "-" .. os_name .. "-" .. arch .. ".tar.gz"

    -- Find the release containing our version
    for _, release in ipairs(releases) do
        if release.assets then
            for _, asset in ipairs(release.assets) do
                if asset.name == filename then
                    download_url = asset.browser_download_url
                    break
                end
            end
        end
        if download_url then break end
    end

    if not download_url then
        error("PHP " .. version .. " is not available for " .. os_name .. "-" .. arch ..
              ". Available versions can be found at: https://github.com/TorstenDittmann/php-binaries/releases")
    end

    -- Optional: Fetch checksum
    local sha256 = fetch_checksum(version, filename)

    return {
        version = version,
        url = download_url,
        sha256 = sha256,
        note = "Downloading PHP " .. version .. " (" .. os_name .. "-" .. arch .. ")",
    }
end
