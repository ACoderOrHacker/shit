-- utilities for xmake

function gdc_flag(target, gdc)
    if gdc ~= "" then
        target:add("dcflags", gdc, {tools = "gdc"})
    end
end

function ldc_flag(target, ldc)
    if ldc ~= "" then
        target:add("dcflags", ldc, {tools = "ldc"})
    end
end

function dmd_flag(target, dmd)
    if dmd ~= "" then
        target:add("dcflags", dmd, {tools = "dmd"})
    end
end

function flag(target, gdc, ldc, dmd)
    gdc_flag(target, gdc)
    ldc_flag(target, ldc)
    dmd_flag(target, dmd)
end

function main(target, gdc, ldc, dmd)
    flag(target, gdc, ldc, dmd)
end