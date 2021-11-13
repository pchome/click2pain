# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Meson build system cross-files for winelib build"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-util/meson"
RDEPEND="${DEPEND}"
S="${WORKDIR}"

src_install() {
	insinto "${EPREFIX}/usr/share/meson/cross"

	doins "${FILESDIR}/x86.winelib"
	doins "${FILESDIR}/x86_64.winelib"

	doins "${FILESDIR}/x86.winelib.no-pie"
	doins "${FILESDIR}/x86_64.winelib.no-pie"

	doins "${FILESDIR}/x86.mingw32"
	doins "${FILESDIR}/x86_64.mingw32"

	doins "${FILESDIR}/winesrc.flags"
	doins "${FILESDIR}/winelib.flags"
	doins "${FILESDIR}/mingw32.flags"

	doins "${FILESDIR}/winesrc.flags.meson-0.55"
	doins "${FILESDIR}/winelib.flags.meson-0.55"
	doins "${FILESDIR}/mingw32.flags.meson-0.55"
}
