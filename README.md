# click2pain
Steam compat tool, Wine w/ Staging/Proton patches and ™.

#### Note: WIP. Trying to resurect my local overlay (used for Proton 5.0) for modern Proton versions (experimental)

#### Note: focused on winelib builds

## Motivation
* one common Wine version for Steam and system
* broken Gentoo Mingw64 builds, focused on Windows native compilation (not cross-compilation),
  produses broken binaries which fails here and there and leeking memory
  (or it's just me not lucky enough to build Mingw64 on Gentoo)
* I just need more time to adopt my environment for PE builds

## WINEMODPATH
Copy/paste of WINEDLLPATH but for higher priority.
Which mean all `*.dll.so` files will be loaded first from path found in WINEMODPATH=/path/to,
then in Wine, and then (if missed) in WINEDLLPATH=/path/to.

This behaviour makes WINEMODPATH environment variable perfect for various winelib builds, e.g.
`WINEMODPATH=/usr/lib64/dxvk:/usr/lib/dxvk wine some-d3d11.exe` should run DXVK d3d11, no copying,
no registry, etc.

## MEBUILDs
EBUILDs with `meson.build` mix.
Just to have common, predictable, compact build system, for sources which may lack it etc.

#### Note: maybe current Meson fixed/finished it's "rewrite" thing, but for now just `cat >`
