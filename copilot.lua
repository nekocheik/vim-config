---Reference implementation:
---https://github.com/zbirenbaum/copilot.lua/blob/master/lua/copilot/auth.lua config file
---https://github.com/zed-industries/zed/blob/ad43bbbf5eda59eba65309735472e0be58b4f7dd/crates/copilot/src/copilot_chat.rs#L272 for authorization
---
---@class CopilotToken
---@field annotations_enabled boolean
---@field chat_enabled boolean
---@field chat_jetbrains_enabled boolean
---@field code_quote_enabled boolean
---@field codesearch boolean
---@field copilotignore_enabled boolean
---@field endpoints {api: string, ["origin-tracker"]: string, proxy: string, telemetry: string}
---@field expires_at integer
---@field individual boolean
---@field nes_enabled boolean
---@field prompt_8k boolean
---@field public_suggestions string
---@field refresh_in integer
---@field sku string
---@field snippy_load_test_enabled boolean
---@field telemetry string
---@field token string
---@field tracking_id string
---@field vsc_electron_fetcher boolean
---@field xcode boolean
---@field xcode_chat boolean

local curl = require("plenary.curl")

local Config = require("avante.config")
local Path = require("plenary.path")
local Utils = require("avante.utils")
local P = require("avante.providers")
local O = require("avante.providers").openai

local H = {}

local copilot_path = vim.fn.stdpath("data") .. "/avante/github-copilot.json"

---@class OAuthToken
---@field user string
---@field oauth_token string
---
---@return string
H.get_oauth_token = function()
  -- Obtenir le token GitHub avec la commande correcte
  local token_handle = io.popen("gh auth status --show-token 2>&1")
  if not token_handle then
    error("GitHub CLI (gh) n'est pas installé", 2)
  end
  local output = token_handle:read("*a")
  token_handle:close()

  -- Extraire le token de la sortie
  local token = output:match("Token: ([%w_%-]+)")
  
  if not token then
    error("Token GitHub non trouvé. Exécutez:\n1. gh auth login --web\n2. gh extension install github/gh-copilot\n3. gh copilot auth", 2)
  end
  
  return token
end

H.chat_auth_url = "https://api.githubcopilot.com/chat/completions"
H.chat_completion_url = function(base_url) 
    return "https://api.githubcopilot.com/chat/completions"
end

---@class AvanteProviderFunctor
local M = {}

H.refresh_token = function()
  if not M.state then error("internal initialization error") end

  if not M.state.github_token then
    -- Vérifier le statut de Copilot
    local status_handle = io.popen("gh copilot auth status 2>&1")
    if status_handle then
      local status = status_handle:read("*a")
      status_handle:close()
      
      if status:match("not authenticated") then
        error("Copilot n'est pas authentifié. Exécutez 'gh copilot auth'", 2)
      end
    end

    M.state.github_token = {
      token = M.state.oauth_token,
      expires_at = os.time() + 3600
    }
  end
end

---@private
---@class AvanteCopilotState
---@field oauth_token string
---@field github_token CopilotToken?
M.state = nil

M.api_key_name = ""
M.tokenizer_id = "gpt-4o"
M.role_map = {
  user = "user",
  assistant = "assistant",
}

M.parse_messages = function(opts)
  local messages = {
    { role = "system", content = opts.system_prompt },
  }
  vim
    .iter(opts.messages)
    :each(function(msg) table.insert(messages, { role = M.role_map[msg.role], content = msg.content }) end)
  return messages
end

M.parse_response = O.parse_response

M.parse_curl_args = function(provider, code_opts)
  local base, body_opts = P.parse_config(provider)

  return {
    url = H.chat_completion_url(base.endpoint),
    timeout = base.timeout,
    proxy = base.proxy,
    insecure = base.allow_insecure,
    headers = {
      ["Content-Type"] = "application/json",
      ["Authorization"] = "Bearer " .. M.state.github_token.token,
      ["Editor-Plugin-Version"] = "copilot.lua",
      ["Editor-Version"] = "neovim/" .. vim.version().major .. "." .. vim.version().minor,
      ["User-Agent"] = "GithubCopilot/1.0",
      ["OpenAI-Organization"] = "github-copilot",
      ["VScode-SessionId"] = vim.api.nvim_get_vvar("servername"),
    },
    body = vim.tbl_deep_extend("force", {
      model = "copilot-chat",
      messages = M.parse_messages(code_opts),
      stream = true,
    }, body_opts),
  }
end

M.setup = function()
  local copilot_token_file = Path:new(copilot_path)

  if not M.state then
    M.state = {
      github_token = copilot_token_file:exists() and vim.json.decode(copilot_token_file:read()) or nil,
      oauth_token = H.get_oauth_token(),
    }
  end

  vim.schedule(function() H.refresh_token() end)

  require("avante.tokenizers").setup(M.tokenizer_id)
  vim.g.avante_login = true
end

return M

