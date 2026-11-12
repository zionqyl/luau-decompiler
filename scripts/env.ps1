
$taskRoot = Split-Path -Parent $PSScriptRoot
if (Test-Path -LiteralPath (Join-Path $taskRoot '.tools/cargo/bin/cargo.exe')) {
    $env:RUSTUP_HOME = Join-Path $taskRoot '.tools/rustup'
    $env:CARGO_HOME = Join-Path $taskRoot '.tools/cargo'
    $env:PATH = (Join-Path $taskRoot '.tools/cargo/bin') + ';' + $env:PATH
}
if (Test-Path -LiteralPath (Join-Path $taskRoot '.tools/mingw64/bin/gcc.exe')) {
    $env:PATH = (Join-Path $taskRoot '.tools/mingw64/bin') + ';' + $env:PATH
}
if (Test-Path -LiteralPath (Join-Path $taskRoot '.tools/luau/luau-compile.exe')) {
    $env:LUAU_COMPILE = Join-Path $taskRoot '.tools/luau/luau-compile.exe'
    $env:LUAU_RUN = Join-Path $taskRoot '.tools/luau/luau.exe'
}
if (Test-Path -LiteralPath (Join-Path $taskRoot '.tools/vm-runner.exe')) {
    $env:LUAU_VM_RUNNER = Join-Path $taskRoot '.tools/vm-runner.exe'
}
