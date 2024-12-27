local M = {}

-- Fonction pour vérifier si nous sommes dans un projet Node.js
local function is_node_project()
    local package_json = vim.fn.findfile('package.json', '.;')
    return package_json ~= ''
end

-- Configuration automatique de Vimspector
function M.setup()
    -- Mappings de base
    vim.g.vimspector_enable_mappings = 'HUMAN'
    
    -- Détection automatique du projet
    vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
        callback = function()
            if is_node_project() then
                -- Configuration automatique pour Node.js/TypeScript/Vue
                local config = {
                    configurations = {
                        ["Node.js: Launch"] = {
                            adapter = "vscode-node",
                            filetypes = {"javascript", "typescript", "vue"},
                            configuration = {
                                request = "launch",
                                protocol = "auto",
                                stopOnEntry = false,
                                console = "integratedTerminal",
                                cwd = "${workspaceRoot}",
                                sourceMaps = true,
                            }
                        }
                    }
                }

                -- Détecter si c'est un projet Vue.js
                local vue_config = vim.fn.findfile('vue.config.js', '.;')
                if vue_config ~= '' then
                    config.configurations["Vue.js: Launch"] = {
                        adapter = "vscode-node",
                        filetypes = {"javascript", "typescript", "vue"},
                        configuration = {
                            request = "launch",
                            protocol = "auto",
                            program = "${workspaceRoot}/node_modules/.bin/vue-cli-service",
                            args = {"serve"},
                            cwd = "${workspaceRoot}",
                            sourceMaps = true,
                            port = 9229
                        }
                    }
                end

                -- Sauvegarder la configuration
                vim.g.vimspector_configurations = config.configurations
            end
        end
    })
end

return M 