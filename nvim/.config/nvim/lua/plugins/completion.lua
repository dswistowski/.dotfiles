return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "*",
  opts = {
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    completion = { documentation = { auto_show = true } },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
  },
}
