# Xray for OpenWrt

Just the binary file and optional geoip.dat & geosite.dat from [Loyalsoldier/v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat)

For LuCI support try [yichya/luci-app-xray](https://github.com/yichya/luci-app-xray)



This fork version contains upx compression enabled in makefie during build, everything else remains same. Thanks to yichya


Compiling steps:

git clone https://github.com/sevvian/openwrt-xray.git package/xray

./scripts/feeds update -a
./scripts/feeds install -a

 make defconfig    #(or make menuconfig)
 
 make package/xray/{clean,compile} V=s


Note: whiie compiling it may fail due to go lang version. I downloaded the golang latest from snapshot SDK branch of openwrt mvebu (for my router architecture)
and copied that lang/golang folder to  19.07 openwrt SDK and replaced , Then the compilation worked for me and produced the ipk.

The compiled ipk files will be avaiable under

./bin/packages/arm_cortex-a9_vfpv3-d16/base/       (should be under corresponding architecture base folder)



