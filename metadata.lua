-- metadata.lua
-- PHP Plugin for mise - Downloads prebuilt PHP binaries
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#metadata-lua

PLUGIN = { -- luacheck: ignore
    -- Required: Tool name (lowercase, no spaces)
    name = "php",

    -- Required: Plugin version (not the tool version)
    version = "1.0.0",

    -- Required: Brief description of the tool
    description = "PHP runtime with prebuilt binaries (via TorstenDittmann/php-binaries)",

    -- Required: Plugin author/maintainer
    author = "Tobias Hochguerel",

    -- Optional: Repository URL for plugin updates
    updateUrl = "https://github.com/tobiashochguertel/mise-php",

    -- Optional: Minimum mise runtime version required
    minRuntimeVersion = "0.2.0",

    -- Optional: Legacy version files this plugin can parse
    legacyFilenames = {
        ".php-version",
        ".phpenv-version"
    }
}
