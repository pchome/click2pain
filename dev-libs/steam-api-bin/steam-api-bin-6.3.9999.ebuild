# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{64,32} )

inherit multilib-minimal

DESCRIPTION="Steam api lib for Proton"
HOMEPAGE="https://github.com/ValveSoftware/Proton"

if [[ ${PV} == "6.3.9999" ]] ; then
	EGIT_REPO_URI="https://github.com/ValveSoftware/Proton.git"
	EGIT_BRANCH="experimental_6.3"
	EGIT_SUBMODULES=()
	inherit git-r3
	SRC_URI=""
else
	GIT_V="6.3-7"
	GIT_COMMIT=5536e50175b478e8f0b1fdf77a0679ba6720aaa7
	SRC_URI="https://github.com/ValveSoftware/Proton/archive/${GIT_COMMIT}.zip -> Proton-${GIT_V}.zip"
	S="${WORKDIR}/Proton-${GIT_COMMIT}"
	KEYWORDS="-* ~amd64"
fi

LICENSE="ValveSteamLicense"
SLOT="0"

RESTRICT="test"

win_bit() {
	[[ ${ABI} = amd64 ]] && echo "64" || echo "32"
}

multilib_src_install() {
	insinto "${EPREFIX}/usr/$(get_libdir)"
	doins "${S}/steam_helper/$(win_bit)/libsteam_api.so"
}
