-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

local packer = require('packer')

packer.init({
    git = {
        clone_timeout = false
    }
})

return packer.startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use({
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    })

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('tpope/vim-surround')
    use('tpope/vim-commentary')
    use('tpope/vim-fugitive')
end)
