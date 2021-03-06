# This file is part of mingw-cross-env.
# See doc/index.html for further information.

# GLib
PKG             := libsigc++
$(PKG)_IGNORE   := 
$(PKG)_VERSION  := 2.2.8
$(PKG)_CHECKSUM := c26f57110629c16c0b5a873346b7c1cf0edc9c5e
$(PKG)_SUBDIR   := libsigc++-$($(PKG)_VERSION)
$(PKG)_FILE     := libsigc++-$($(PKG)_VERSION).tar.bz2
$(PKG)_WEBSITE  := http://libsigc.sourceforge.net/
$(PKG)_URL      := http://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc

define $(PKG)_UPDATE
    wget -q -O- 'http://FIXME' | \
    grep '<a href=' | \
    $(SED) -n 's,.*<a[^>]*>libsigc++-*\([0-9][^<]*\)<.*,\1,p' | \
    grep -v '^2\.24\.' | \
    head -1
endef

define $(PKG)_BUILD
    # cross build
    # wine confuses the cross-compiling detection, so set it explicitly
    $(SED) -i 's,cross_compiling=no,cross_compiling=yes,' '$(1)/configure'
    cd '$(1)' && ./configure \
        --host='$(TARGET)' \
        --disable-shared \
        --prefix='$(PREFIX)/$(TARGET)' \
        --with-threads=win32 \
        CXX='$(TARGET)-c++' \
        PKG_CONFIG='$(PREFIX)/bin/$(TARGET)-pkg-config'
    $(MAKE) -C '$(1)'    -j '$(JOBS)' install
endef
