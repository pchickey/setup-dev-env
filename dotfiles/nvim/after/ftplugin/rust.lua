

local bufnr = vim.api.nvim_get_current_buf()

-- Resolve the edition of the crate that owns `dir` via `cargo metadata`, then
-- invoke `callback(edition, err)`. We don't use `cargo fmt` because it
-- resolves a "current package" from cwd and errors ("failed to find
-- targets") in common layouts (e.g. workspaces with a virtual root
-- manifest). Querying metadata ourselves and running `rustfmt --edition`
-- directly sidesteps that resolution entirely.
local function resolve_rustfmt_edition(dir, callback)
  vim.system(
    { "cargo", "metadata", "--no-deps", "--format-version", "1" },
    { cwd = dir, text = true },
    function(obj)
      if obj.code ~= 0 then
        callback(nil, obj.stderr)
        return
      end
      local ok, metadata = pcall(vim.json.decode, obj.stdout)
      if not ok or not metadata.packages then
        callback(nil, "failed to parse `cargo metadata` output")
        return
      end
      -- Pick the package whose manifest directory is the closest ancestor of `dir`.
      local best_edition, best_len = nil, -1
      for _, pkg in ipairs(metadata.packages) do
        local pkg_dir = vim.fs.dirname(pkg.manifest_path)
        if dir:sub(1, #pkg_dir) == pkg_dir and #pkg_dir > best_len then
          best_len = #pkg_dir
          best_edition = pkg.edition
        end
      end
      callback(best_edition, best_edition and nil or "no owning package found in workspace")
    end
  )
end

-- Format with rustfmt on save, using the edition resolved above.
vim.api.nvim_create_autocmd("BufWritePost", {
  buffer = bufnr,
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local dir = vim.fs.dirname(bufname)
    resolve_rustfmt_edition(dir, function(edition, resolve_err)
      if not edition then
        vim.schedule(function()
          vim.notify(
            "rustfmt: couldn't resolve crate edition (" .. resolve_err .. "), skipping format",
            vim.log.levels.WARN
          )
        end)
        return
      end
      vim.system(
        { "rustfmt", "--edition", edition, bufname },
        { cwd = dir },
        function(obj)
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return
            end
            if obj.code ~= 0 then
              vim.notify(
                "rustfmt failed:\n" .. (obj.stderr or ""),
                vim.log.levels.ERROR
              )
              return
            end
            -- Reload the buffer to pick up the changes rustfmt made on disk.
            local view = vim.fn.winsaveview()
            vim.api.nvim_buf_call(bufnr, function()
              vim.cmd("checktime")
            end)
            vim.fn.winrestview(view)
          end)
        end
      )
    end)
  end,
})

vim.keymap.set(
  "n", 
  "<leader>a", 
  function()
    vim.cmd.RustLsp('codeAction')
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>k", 
  function()
    vim.cmd.RustLsp('hover')
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>d", 
  function()
    vim.lsp.buf.definition()
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>x", 
  function()
    vim.lsp.buf.references()
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>r", 
  function()
    vim.lsp.buf.rename()
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>i", 
  function()
    vim.cmd.RustLsp({'renderDiagnostic', 'current'})
  end,
  { silent = true, buffer = bufnr }
)


vim.cmd('set tw=78')

   --Enable completion triggered by <c-x><c-o>
--[[
  opt ('omnifunc', 'v:lua.vim.lsp.omnifunc')

  mapcmd('<leader>k', 'vim.lsp.buf.hover()')
  mapcmd('<leader>d', 'vim.lsp.buf.definition()')
  mapcmd('<leader>x', 'vim.lsp.buf.references()')
  mapcmd('<leader>r', 'vim.lsp.buf.rename()')
  mapcmd('<leader>a', 'vim.lsp.buf.code_action()')
  mapcmd('<leader>i', 'vim.diagnostic.open_float()')
]]

