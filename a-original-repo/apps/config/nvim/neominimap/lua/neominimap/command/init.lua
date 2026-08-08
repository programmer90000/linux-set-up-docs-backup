local subcommand_tbl = vim.tbl_deep_extend(
    "error",
    require("neominimap.command.global").subcommand_tbl,
    require("neominimap.command.buf").subcommand_tbl,
    require("neominimap.command.tab").subcommand_tbl,
    require("neominimap.command.win").subcommand_tbl,
    require("neominimap.command.focus").subcommand_tbl
    -- require("neominimap.command.perf").subcommand_tbl,
)

return {
    subcommand_tbl = subcommand_tbl,
}
