# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit meson multilib-minimal

DESCRIPTION="A D3D8 pseudo-driver which converts API calls and bytecode shaders to equivalent D3D9 ones"
HOMEPAGE="https://github.com/crosire/d3d8to9"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/crosire/d3d8to9.git"
	EGIT_BRANCH="main"
	inherit git-r3
	SRC_URI=""
else
	SRC_URI="https://github.com/crosire/d3d8to9/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
fi

LICENSE="BSD-2"
SLOT="0"
IUSE="+module pie"
RESTRICT="test"

RDEPEND="app-emulation/wine-staging:*[${MULTILIB_USEDEP},vulkan]"

DEPEND="${RDEPEND}"

BDEPEND="dev-util/meson-cross-files-wine"

PATCHES=(
	"${FILESDIR}/d3d8to9-1.12-winelib-v2.patch"
	"${FILESDIR}/fix-ptr.patch"
)

dxvk_check_requirements() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if ! tc-is-gcc || [[ $(gcc-major-version) -lt 7 || $(gcc-major-version) -eq 7 && $(gcc-minor-version) -lt 3 ]]; then
			die "At least gcc 7.3 is required"
		fi
	fi
}

pkg_pretend() {
	dxvk_check_requirements
}

pkg_setup() {
	dxvk_check_requirements
}

cross_file() {
	local variant="winelib"
	! use pie && variant="winelib.no-pie"

	[[ ${ABI} = amd64 ]] && echo "x86_64.${variant}" || echo "x86.${variant}"
}

src_prepare() {
	default
	# Create meson.build file
	cat > "${S}/meson.build" <<-EOF
	project('d3d8to9', ['cpp'], default_options : ['cpp_std=c++2a'], version : 'v1.11.0', meson_version : '>= 0.48')
	
	add_project_arguments('-DD3D8TO9NOLOG', language : ['c','cpp'])
	
	add_project_arguments('-DNOMINMAX', language : 'cpp')
	add_project_arguments('--no-gnu-unique', language : 'cpp')
	add_project_arguments('-fpermissive', language : 'cpp')
	add_project_link_arguments('-mwindows', language : ['c','cpp'])
	
	#wrc = find_program('wrc')
	lib_d3d9 = declare_dependency(link_args: [ '-ld3d9' ])
	d3d8_src = [
	  'source/d3d8to9_base.cpp',
	  'source/d3d8to9.cpp',
	  'source/d3d8to9_device.cpp',
	  'source/d3d8to9_index_buffer.cpp',
	  'source/d3d8to9_surface.cpp',
	  'source/d3d8to9_swap_chain.cpp',
	  'source/d3d8to9_texture.cpp',
	  'source/d3d8to9_vertex_buffer.cpp',
	  'source/d3d8to9_volume.cpp',
	  'source/d3d8types.cpp',
	  'source/interface_query.cpp',
	]
	
	shared_library('d3d8.dll', d3d8_src, name_prefix: '', dependencies: [ lib_d3d9 ], objects: 'd3d8.spec', gnu_symbol_visibility: 'inlineshidden', install: true)
	EOF

	# spec
	cat > "${S}/d3d8.spec" <<-EOF
	@ stdcall Direct3DCreate8(long)
	EOF
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="$(cross_file)"
		--libdir="$(get_libdir)/${PN}"
		--bindir="$(get_libdir)/${PN}/bin"
		-Dc_args="${CFLAGS}"
		-Dcpp_args="${CXXFLAGS}"
		-Dc_link_args="${LDFLAGS}"
		-Dcpp_link_args="${LDFLAGS}"
		#--unity=on
		#-Dunity_size=100
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install

	# Create symlinks to be able use APIs separately
	if use module; then
		local t_path="${EPREFIX}/usr/$(get_libdir)/${PN}"
		local d_path="${EPREFIX}/usr/$(get_libdir)/wine-modules/${PN}"

		dodir "${d_path}/d3d8"
		dosym "${t_path}/d3d8.dll.so" "${d_path}/d3d8/d3d8.dll.so"
	fi
}
