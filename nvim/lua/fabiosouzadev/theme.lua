local tokyonight = require 'tokyonight'

local function init()
    vim.cmd [[colorscheme tokyonight-night]]
end

return {
    init = init,
}
