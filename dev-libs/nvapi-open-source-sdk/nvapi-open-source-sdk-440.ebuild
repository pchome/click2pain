# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="NVAPI Developer Open Source Interface for Driver Release 440"
HOMEPAGE="https://download.nvidia.com/XFree86/nvapi-open-source-sdk"

SRC_URI="https://download.nvidia.com/XFree86/nvapi-open-source-sdk/R${PV}-OpenSource.tar"
KEYWORDS="-* ~amd64"

LICENSE="MIT"
SLOT="0"
RESTRICT="test"

BDEPEND="dev-util/meson-cross-files-wine"

S="${WORKDIR}/R${PV}-OpenSource"

src_prepare() {
	default
	# Create meson.build file
	cat > "${S}/meson.build" <<-EOF
	project('nvapi', ['c'], version : 'R440', meson_version : '>= 0.46')
	
	install_headers(['NvApiDriverSettings.c', 'NvApiDriverSettings.h', 'nvapi.h', 'nvapi_interface.h'], subdir: 'nvapi')
	EOF
}
