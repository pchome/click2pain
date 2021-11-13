# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{64,32} )

inherit meson multilib-minimal

DESCRIPTION="Steam client helper for Proton"
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

RDEPEND="app-emulation/wine-staging[${MULTILIB_USEDEP}]"

DEPEND="${RDEPEND}
	>=dev-util/meson-0.54"

BDEPEND="dev-util/meson-cross-files-wine"

cross_file() { [[ ${ABI} = amd64 ]] && echo "x86_64.winelib" || echo "x86.winelib" ; }

src_prepare() {
	default

	cat > "${S}/meson.build" <<-EOF
	project('${PN}', ['c','cpp'], version : '${PV}', meson_version : '>= 0.49')
	
	add_project_arguments('-fvisibility=hidden', language : ['c', 'cpp'])
	add_project_arguments('-fvisibility-inlines-hidden', language : 'cpp')
	
	add_project_arguments('-DNOMINMAX', language : 'cpp')
	add_project_arguments('--no-gnu-unique', language : 'cpp')
	
	add_project_arguments('-Wno-non-virtual-dtor', language : 'cpp')
	
	defs = [
	  '-DSTEAM_API_EXPORTS',
	  '-Dprivate=public',
	  '-Dprotected=public',
	  '-Wno-attributes',
	  '-Wno-unknown-pragmas',
	]
	
	add_project_arguments(defs, language : ['c','cpp'])
	
	ls_cmd = find_program('find')
	
	sources = run_command(ls_cmd, 'lsteamclient', '-type', 'f', '-name', '*.c', '-o', '-name', '*.cpp').stdout().strip().split('\n')
	
	shared_library('lsteamclient.dll', sources,
	  name_prefix : '',
	  dependencies: declare_dependency(link_args: [ '-ldl' ]),
	  objects     : 'lsteamclient/lsteamclient.spec',
	  install     : true)
	EOF

	# wine/list.h missing
	mkdir -p lsteamclient/wine || die
	cp "${FILESDIR}/list.h" lsteamclient/wine/
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="$(cross_file)"
		--libdir="$(get_libdir)/wine-modules/proton"
		--bindir="$(get_libdir)/wine-modules/proton"
		-Dc_args="${CFLAGS}"
		-Dcpp_args="${CXXFLAGS}"
		-Dc_link_args="${LDFLAGS}"
		-Dcpp_link_args="${LDFLAGS}"
		#--unity=on
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}
