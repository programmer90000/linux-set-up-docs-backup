local A = vim.api

---Common commentstring shared b/w multiple languages
local M = {
    cxx_l = '//%s',
    cxx_b = '/*%s*/',
    dbl_hash = '##%s',
    dash = '--%s',
    dash_bracket = '--[[%s]]',
    handlebars = '{{!--%s--}}',
    hash = '#%s',
    hash_bracket = '#[[%s]]',
    haskell_b = '{-%s-}',
    fsharp_b = '(*%s*)',
    html = '<!--%s-->',
    latex = '%%s',
    semicolon = ';%s',
    lisp_l = ';;%s',
    lisp_b = '#|%s|#',
    twig = '{#%s#}',
    vim = '"%s',
    lean_b = '/-%s-/',
    ruby_block = '=begin%s=end',
}

---Lang table that contains commentstring (linewise/blockwise) for multiple filetypes
---Structure = { filetype = { linewise, blockwise } }
---@type table<string,string[]>
local L = setmetatable({
    arduino = { M.cxx_l, M.cxx_b },
    applescript = { M.hash },
    asm = { M.hash },
    astro = { M.html },
    autohotkey = { M.semicolon, M.cxx_b },
    bash = { M.hash },
    beancount = { M.semicolon },
    bib = { M.latex },
    blueprint = { M.cxx_l }, -- Blueprint doesn't have block comments
    c = { M.cxx_l, M.cxx_b },
    cabal = { M.dash },
    cairo = { M.cxx_l },
    cmake = { M.hash, M.hash_bracket },
    conf = { M.hash },
    conkyrc = { M.dash, M.dash_bracket },
    coq = { M.fsharp_b, M.fsharp_b },
    cpp = { M.cxx_l, M.cxx_b },
    cs = { M.cxx_l, M.cxx_b },
    css = { M.cxx_b, M.cxx_b },
    cuda = { M.cxx_l, M.cxx_b },
    cue = { M.cxx_l },
    dart = { M.cxx_l, M.cxx_b },
    dhall = { M.dash, M.haskell_b },
    dnsmasq = { M.hash },
    dosbatch = { 'REM%s' },
    dot = { M.cxx_l, M.cxx_b },
    dts = { M.cxx_l, M.cxx_b },
    editorconfig = { M.hash },
    eelixir = { M.html, M.html },
    elixir = { M.hash },
    elm = { M.dash, M.haskell_b },
    elvish = { M.hash },
    faust = { M.cxx_l, M.cxx_b },
    fennel = { M.semicolon },
    fish = { M.hash },
    func = { M.lisp_l },
    fsharp = { M.cxx_l, M.fsharp_b },
    gdb = { M.hash },
    gdscript = { M.hash },
    gdshader = { M.cxx_l, M.cxx_b },
    gitignore = { M.hash },
    gleam = { M.cxx_l },
    glsl = { M.cxx_l, M.cxx_b },
    gnuplot = { M.hash, M.hash_bracket },
    go = { M.cxx_l, M.cxx_b },
    gomod = { M.cxx_l },
    graphql = { M.hash },
    groovy = { M.cxx_l, M.cxx_b },
    handlebars = { M.handlebars, M.handlebars },
    haskell = { M.dash, M.haskell_b },
    haxe = { M.cxx_l, M.cxx_b },
    hcl = { M.hash, M.cxx_b },
    heex = { M.html, M.html },
    html = { M.html, M.html },
    htmldjango = { M.html, M.html },
    hyprlang = { M.hash },
    idris = { M.dash, M.haskell_b },
    idris2 = { M.dash, M.haskell_b },
    ini = { M.hash },
    jai = { M.cxx_l, M.cxx_b },
    java = { M.cxx_l, M.cxx_b },
    javascript = { M.cxx_l, M.cxx_b },
    javascriptreact = { M.cxx_l, M.cxx_b },
    jq = { M.hash },
    jsonc = { M.cxx_l },
    jsonnet = { M.cxx_l, M.cxx_b },
    julia = { M.hash, '#=%s=#' },
    kdl = { M.cxx_l, M.cxx_b },
    kotlin = { M.cxx_l, M.cxx_b },
    lean = { M.dash, M.lean_b },
    lean3 = { M.dash, M.lean_b },
    lidris = { M.dash, M.haskell_b },
    lilypond = { M.latex, '%{%s%}' },
    lisp = { M.lisp_l, M.lisp_b },
    lua = { M.dash, M.dash_bracket },
    metalua = { M.dash, M.dash_bracket },
    luau = { M.dash, M.dash_bracket },
    markdown = { M.html, M.html },
    make = { M.hash },
    mbsyncrc = { M.dbl_hash },
    mermaid = { '%%%s' },
    meson = { M.hash },
    mojo = { M.hash },
    nextflow = { M.cxx_l, M.cxx_b },
    nim = { M.hash, '#[%s]#' },
    nix = { M.hash, M.cxx_b },
    nu = { M.hash },
    objc = { M.cxx_l, M.cxx_b },
    objcpp = { M.cxx_l, M.cxx_b },
    ocaml = { M.fsharp_b, M.fsharp_b },
    odin = { M.cxx_l, M.cxx_b },
    openscad = { M.cxx_l, M.cxx_b },
    plantuml = { "'%s", "/'%s'/" },
    purescript = { M.dash, M.haskell_b },
    puppet = { M.hash },
    python = { M.hash }, -- Python doesn't have block comments
    php = { M.cxx_l, M.cxx_b },
    prisma = { M.cxx_l },
    proto = { M.cxx_l, M.cxx_b },
    quarto = { M.html, M.html },
    r = { M.hash }, -- R doesn't have block comments
    racket = { M.lisp_l, M.lisp_b },
    rasi = { M.cxx_l, M.cxx_b },
    readline = { M.hash },
    reason = { M.cxx_l, M.cxx_b },
    rego = { M.hash },
    remind = { M.hash },
    rescript = { M.cxx_l, M.cxx_b },
    robot = { M.hash }, -- Robotframework doesn't have block comments
    ron = { M.cxx_l, M.cxx_b },
    ruby = { M.hash, M.ruby_block },
    rust = { M.cxx_l, M.cxx_b },
    sbt = { M.cxx_l, M.cxx_b },
    scala = { M.cxx_l, M.cxx_b },
    scss = { M.cxx_b, M.cxx_b },
    scheme = { M.lisp_l, M.lisp_b },
    sh = { M.hash },
    solidity = { M.cxx_l, M.cxx_b },
    supercollider = { M.cxx_l, M.cxx_b },
    sql = { M.dash, M.cxx_b },
    stata = { M.cxx_l, M.cxx_b },
    svelte = { M.html, M.html },
    swift = { M.cxx_l, M.cxx_b },
    sxhkdrc = { M.hash },
    systemverilog = { M.cxx_l, M.cxx_b },
    tablegen = { M.cxx_l, M.cxx_b },
    teal = { M.dash, M.dash_bracket },
    terraform = { M.hash, M.cxx_b },
    tex = { M.latex },
    template = { M.dbl_hash },
    tidal = { M.dash, M.haskell_b },
    tmux = { M.hash },
    toml = { M.hash },
    twig = { M.twig, M.twig },
    typescript = { M.cxx_l, M.cxx_b },
    typescriptreact = { M.cxx_l, M.cxx_b },
    typst = { M.cxx_l, M.cxx_b },
    v = { M.cxx_l, M.cxx_b },
    vala = { M.cxx_l, M.cxx_b },
    verilog = { M.cxx_l },
    vhdl = { M.dash },
    vim = { M.vim },
    vifm = { M.vim },
    vue = { M.html, M.html },
    wgsl = { M.cxx_l, M.cxx_b },
    xdefaults = { '!%s' },
    xml = { M.html, M.html },
    xonsh = { M.hash }, -- Xonsh doesn't have block comments
    yaml = { M.hash },
    yuck = { M.lisp_l },
    zig = { M.cxx_l }, -- Zig doesn't have block comments
}, {
    -- Support for compound filetype i.e. 'ios.swift', 'ansible.yaml' etc.
    __index = function(this, k)
        local base, fallback = string.match(k, '^(.-)%.(.*)')
        if not (base or fallback) then
            return nil
        end
        return this[base] or this[fallback]
    end,
})

local ft = {}

function ft.set(lang, val)
    L[lang] = type(val) == 'string' and { val } or val --[[ @as string[] ]]
    return ft
end

function ft.get(lang, ctype)
    local tuple = L[lang]
    if not tuple then
        return nil
    end
    if not ctype then
        return vim.deepcopy(tuple)
    end
    return tuple[ctype]
end

function ft.contains(tree, range)
    for lang, child in pairs(tree:children()) do
        if lang ~= 'comment' and child:contains(range) then
            return ft.contains(child, range)
        end
    end
    
    return tree
end

function ft.calculate(ctx)
    local ok, parser = pcall(vim.treesitter.get_parser, A.nvim_get_current_buf())
    
    if not ok then
        return ft.get(vim.bo.filetype, ctx.ctype)
    end
    
    local lang = ft.contains(parser, {
        ctx.range.srow - 1,
        ctx.range.scol,
        ctx.range.erow - 1,
        ctx.range.ecol,
    }):lang()
    
    return ft.get(lang, ctx.ctype) or ft.get(vim.bo.filetype, ctx.ctype)
end

return setmetatable(ft, {
    __newindex = function(this, k, v)
        this.set(k, v)
    end,
    __call = function(this, langs, spec)
        for _, lang in ipairs(langs) do
            this.set(lang, spec)
        end
        return this
    end,
})
