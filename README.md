# click2pain
Steam compat tool, Wine w/ Staging/Proton patches and ™.

#### Note: WIP. Trying to resurect my local overlay (used for Proton 5.0) for modern Proton versions (experimental)

#### Note: focused on winelib builds

## Motivation
* one common Wine version for Steam and system
* broken Gentoo Mingw64 builds, focused on Windows native compilation (not cross-compilation),
  produses broken binaries which fails here and there and leeking memory
  (or it's just me not lucky enough to build Mingw64 on Gentoo)

## MEBUILDs
EBUILDs with `meson.build` mix.
Just to have common, predictable, compact build system, for sources which may lack it etc.

#### Note: maybe current Meson fixed/finished it's "rewrite" thing, but for now just `cat >`
