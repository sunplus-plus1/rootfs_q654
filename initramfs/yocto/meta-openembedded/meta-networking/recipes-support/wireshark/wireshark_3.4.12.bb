DESCRIPTION = "wireshark - a popular network protocol analyzer"
HOMEPAGE = "http://www.wireshark.org"
SECTION = "net"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=6e271234ba1a13c6e512e76b94ac2f77"

DEPENDS = "pcre expat glib-2.0 glib-2.0-native libgcrypt libgpg-error libxml2 bison-native c-ares"

DEPENDS:append:class-target = " wireshark-native chrpath-replacement-native "

SRC_URI = "https://1.eu.dl.wireshark.org/src/all-versions/wireshark-${PV}.tar.xz"

SRC_URI += " \
    file://0001-wireshark-src-improve-reproducibility.patch \
    file://0002-flex-Remove-line-directives.patch \
    file://0003-bison-Remove-line-directives.patch \
    file://0004-lemon-Remove-line-directives.patch \
    file://CVE-2022-3190.patch \
    file://CVE-2023-2855.patch \
    file://CVE-2023-2856.patch \
    file://CVE-2023-2858.patch \
    file://CVE-2023-2879.patch \
    file://CVE-2023-2952.patch \
    file://CVE-2023-0666.patch \
    file://CVE-2023-0667.patch \
    file://CVE-2023-0668.patch \
    file://CVE-2023-2906.patch \
"

UPSTREAM_CHECK_URI = "https://1.as.dl.wireshark.org/src"

SRC_URI[sha256sum] = "881a13303e263b7dc7fe337534c8a541d4914552287879bed30bbe76c5bf68ca"

PE = "1"

inherit cmake pkgconfig python3native python3targetconfig perlnative upstream-version-is-even mime mime-xdg

PACKAGECONFIG ?= "libpcap gnutls libnl libcap sbc"

PACKAGECONFIG:class-native = "libpcap gnutls ssl libssh"

PACKAGECONFIG[libcap] = "-DENABLE_CAP=ON,-DENABLE_CAP=OFF -DENABLE_PCAP_NG_DEFAULT=ON, libcap"
PACKAGECONFIG[libpcap] = "-DENABLE_PCAP=ON,-DENABLE_PCAP=OFF -DENABLE_PCAP_NG_DEFAULT=ON , libpcap"
PACKAGECONFIG[libsmi] = "-DENABLE_SMI=ON,-DENABLE_SMI=OFF,libsmi"
PACKAGECONFIG[libnl] = ",,libnl"
PACKAGECONFIG[portaudio] = "-DENABLE_PORTAUDIO=ON,-DENABLE_PORTAUDIO=OFF, portaudio-v19"
PACKAGECONFIG[gnutls] = "-DENABLE_GNUTLS=ON,-DENABLE_GNUTLS=OFF, gnutls"
PACKAGECONFIG[ssl] = ",,openssl"
PACKAGECONFIG[krb5] = "-DENABLE_KRB5=ON,-DENABLE_KRB5=OFF, krb5"
PACKAGECONFIG[lua] = "-DENABLE_LUA=ON,-DENABLE_LUA=OFF, lua"
PACKAGECONFIG[zlib] = "-DENABLE_ZLIB=ON,-DENABLE_ZLIB=OFF, zlib"
PACKAGECONFIG[geoip] = ",, geoip"
PACKAGECONFIG[plugins] = "-DENABLE_PLUGINS=ON,-DENABLE_PLUGINS=OFF"
PACKAGECONFIG[sbc] = "-DENABLE_SBC=ON,-DENABLE_SBC=OFF, sbc"
PACKAGECONFIG[libssh] = ",,libssh2"
PACKAGECONFIG[lz4] = "-DENABLE_LZ4=ON,-DENABLE_LZ4=OFF, lz4"
PACKAGECONFIG[zstd] = "-DENABLE_STTD=ON,-DENABLE_ZSTD=OFF, zstd"
PACKAGECONFIG[nghttp2] = "-DENABLE_NGHTTP2=ON,-DENABLE_NGHTTP2=OFF, nghttp2"

# these next two options require addional layers
PACKAGECONFIG[c-ares] = "-DENABLE_CARES=ON,-DENABLE_CARES=OFF, c-ares"
PACKAGECONFIG[qt5] = "-DENABLE_QT5=ON -DBUILD_wireshark=ON, -DENABLE_QT5=OFF -DBUILD_wireshark=OFF, qttools-native qtmultimedia qtsvg"

inherit ${@bb.utils.contains('PACKAGECONFIG', 'qt5', 'cmake_qt5', '', d)}

EXTRA_OECMAKE += "-DENABLE_NETLINK=ON \
                  -DBUILD_mmdbresolve=OFF \
                  -DBUILD_randpktdump=OFF \
                  -DBUILD_androiddump=OFF \
                  -DBUILD_dcerpcidl2wrs=OFF \
                  -DM_INCLUDE_DIR=${includedir} \
                  -DM_LIBRARY=${libdir} \
                 "
CFLAGS:append = " -lm"

do_install:append:class-native() {
	install -d ${D}${bindir}
	for f in lemon
	do
		install -m 0755 ${B}/run/$f ${D}${bindir}
	done
}

do_install:append:class-target() {
	for f in `find ${D}${libdir} ${D}${bindir} -type f -executable`
	do
		chrpath --delete $f
	done
}

PACKAGE_BEFORE_PN += "tshark"

FILES:tshark = "${bindir}/tshark ${mandir}/man1/tshark.*"

FILES:${PN} += "${datadir}*"

RDEPENDS:tshark = "wireshark"

BBCLASSEXTEND = "native"
