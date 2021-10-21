include $(TOPDIR)/rules.mk

PKG_NAME:=openwrt-xray
PKG_VERSION:=1.5.0
PKG_RELEASE:=1

PKG_LICENSE:=MPLv2
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=yichya <mail@yichya.dev>

PKG_SOURCE:=Xray-core-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/XTLS/Xray-core/tar.gz/v${PKG_VERSION}?
PKG_HASH:=43f35c83902db9d1eba0210c0e27b7814d4caf198cd0424c8af9c97a3ce9a860
PKG_BUILD_DEPENDS:=golang/host upx/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/XTLS/Xray-core

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/../feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
	SECTION:=Custom
	CATEGORY:=Extra packages
	TITLE:=Xray-core
	DEPENDS:=$(GO_ARCH_DEPENDS)
	PROVIDES:=xray-core
endef

define Package/$(PKG_NAME)/description
	Xray-core bare bones binary and optional geoip / geosite data files
endef

define Package/$(PKG_NAME)/config
menu "Xray Configuration"
	depends on PACKAGE_$(PKG_NAME)

config PACKAGE_XRAY_FETCH_VIA_PROXYCHAINS
	bool "Fetch data files using proxychains (not recommended)"
	default n

config PACKAGE_XRAY_ENABLE_GOPROXY_IO
	bool "Use goproxy.io to speed up module fetching (recommended for some network situations)"
	default n

config PACKAGE_XRAY_INCLUDE_GEOSITE
	bool "Include Loyalsoldier geosite.dat"
	default n

choice 
	prompt "Include Loyalsoldier geoip.dat"
	default PACKAGE_XRAY_INCLUDE_GEOIP_NONE
	config PACKAGE_XRAY_INCLUDE_GEOIP_NONE
		bool "Do not include"
	config PACKAGE_XRAY_INCLUDE_GEOIP_FULL
		bool "Include full geoip"
	config PACKAGE_XRAY_INCLUDE_GEOIP_CN_PRIVATE
		bool "Include cn and private geoip only"
endchoice

endmenu
endef

PROXYCHAINS:=

ifdef CONFIG_PACKAGE_XRAY_FETCH_VIA_PROXYCHAINS
	PROXYCHAINS:=proxychains
endif

USE_GOPROXY:=
ifdef CONFIG_PACKAGE_XRAY_ENABLE_GOPROXY_IO
	USE_GOPROXY:=GOPROXY=https://goproxy.io,direct
endif

MAKE_PATH:=$(GO_PKG_WORK_DIR_NAME)/build/src/$(GO_PKG)
MAKE_VARS += $(GO_PKG_VARS)

define Build/Patch
	$(CP) $(PKG_BUILD_DIR)/../Xray-core-$(PKG_VERSION)/* $(PKG_BUILD_DIR)
	$(Build/Patch/Default)
endef

define Build/Compile
	cd $(PKG_BUILD_DIR); $(GO_PKG_VARS) $(USE_GOPROXY) CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -o $(PKG_INSTALL_DIR)/bin/xray ./main; 
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_INSTALL_DIR)/bin/xray || true
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/xray $(1)/usr/bin/xray
	$(INSTALL_DIR) $(1)/usr/share/xray
ifdef CONFIG_PACKAGE_XRAY_INCLUDE_GEOIP_FULL
	$(PROXYCHAINS) wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O $(PKG_BUILD_DIR)/geoip.dat
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/geoip.dat $(1)/usr/share/xray/
endif
ifdef CONFIG_PACKAGE_XRAY_INCLUDE_GEOIP_CN_PRIVATE
	$(PROXYCHAINS) wget https://github.com/Loyalsoldier/geoip/releases/latest/download/geoip-only-cn-private.dat -O $(PKG_BUILD_DIR)/geoip.dat
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/geoip.dat $(1)/usr/share/xray/
endif
ifdef CONFIG_PACKAGE_XRAY_INCLUDE_GEOSITE
	$(PROXYCHAINS) wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O $(PKG_BUILD_DIR)/geosite.dat
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/geosite.dat $(1)/usr/share/xray/
endif
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
