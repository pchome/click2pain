# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{64,32} )

inherit meson multilib-minimal

DESCRIPTION="Steam helper for Proton"
HOMEPAGE="https://github.com/ValveSoftware/Proton"

if [[ ${PV} == "6.3.9999" ]] ; then
	EGIT_REPO_URI="https://github.com/ValveSoftware/Proton.git"
	EGIT_BRANCH="experimental_6.3"
	EGIT_SUBMODULES=()
	inherit git-r3
	SRC_URI=""
	STEAM_SDK_VER="142"
else
	STEAM_SDK_VER="142"
	GIT_V="6.3-7"
	GIT_COMMIT=5536e50175b478e8f0b1fdf77a0679ba6720aaa7
	SRC_URI="https://github.com/ValveSoftware/Proton/archive/${GIT_COMMIT}.zip -> Proton-${GIT_V}.zip"
	S="${WORKDIR}/Proton-${GIT_COMMIT}"
	KEYWORDS="-* ~amd64"
fi

LICENSE="ValveSteamLicense"
SLOT="0"

RESTRICT="test"

RDEPEND="app-emulation/wine-staging[${MULTILIB_USEDEP}]
	app-emulation/steam-client-helper[${MULTILIB_USEDEP}]
	dev-libs/steam-api-bin
"

DEPEND="${RDEPEND}
	>=dev-util/meson-0.49"

BDEPEND="dev-util/meson-cross-files-wine"

PATCHES=(
	# Temporary(?) disable vr/xr an problematic parts
	"${FILESDIR}/steam_helper-fix-build.patch"
	"${FILESDIR}/wine-heap.patch"
)

cross_file() { [[ ${ABI} = amd64 ]] && echo "x86_64.winelib" || echo "x86.winelib" ; }

src_prepare() {
	default

	cat > "${S}/meson.build" <<-EOF
	project('${PN}', ['cpp'], version : '${PV}', meson_version : '>= 0.49')
	
	add_project_arguments('-fvisibility=hidden', language : ['c', 'cpp'])
	add_project_arguments('-fvisibility-inlines-hidden', language : 'cpp')
	
	add_project_arguments('-DNOMINMAX', language : 'cpp')
	add_project_arguments('--no-gnu-unique', language : 'cpp')
	
	add_project_arguments('-Wno-non-virtual-dtor', language : 'cpp')
	
	executable('steam.exe.so', 'steam_helper/steam.cpp',
	  dependencies        : declare_dependency(link_args: ['-lsteam_api', '-lole32', '-lshell32']),
	  include_directories : include_directories(['./lsteamclient/steamworks_sdk_${STEAM_SDK_VER}']),
	  install             : true)
	EOF
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="$(cross_file)"
		--libdir="$(get_libdir)/wine-modules/proton"
		--bindir="$(get_libdir)/wine-modules/proton"
		-Dcpp_args="${CXXFLAGS}"
		-Dcpp_link_args="${LDFLAGS}"
		--unity=on
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}
