#!/bin/bash
HOME_PATH=${PWD}
IMMORTAL_BRANCH="master"
CONFIG_FILE="configs/x86_64.config"
DIY_SCRIPT="diy-script.sh"
CLASH_KERNEL="amd64"
start_time=$(date +%s)

git clone -b ${IMMORTAL_BRANCH} --single-branch --filter=blob:none https://github.com/immortalwrt/immortalwrt

cd immortalwrt
WRT_PATH=${PWD}
cp ${HOME_PATH}/${CONFIG_FILE} ${WRT_PATH}/.config
make defconfig > /dev/null 2>&1
./scripts/feeds update -a
./scripts/feeds install -a

cd ${HOME_PATH}
[ -e files ] && cp files ${WRT_PATH}/files
[ -e ${CONFIG_FILE} ] && cp ${CONFIG_FILE} ${WRT_PATH}/.config
chmod +x ${HOME_PATH}/scripts/*.sh
chmod +x ${DIY_SCRIPT}

cd ${WRT_PATH}
${HOME_PATH}/${DIY_SCRIPT}
${HOME_PATH}/scripts/preset-terminal-tools.sh
${HOME_PATH}/scripts/preset-adguard-core.sh ${CLASH_KERNEL}
${HOME_PATH}/scripts/preset-clash-core.sh ${CLASH_KERNEL}
cp -f ${HOME_PATH}/images/bg3.png package/feeds/luci/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cd files/root && cp ${HOME_PATH}/scripts/.zshrc .

cd ${WRT_PATH}
make defconfig
make download -j$(nproc)
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;

mkdir -p files/etc/uci-defaults
cp ${HOME_PATH}/scripts/init-settings.sh files/etc/uci-defaults/99-init-settings
echo -e "$(nproc) thread compile"
make -j$(nproc) || make -j1 || make -j1 V=s.

end_time=$(date +%s)
cost_time=$[ $end_time-$start_time ]
echo "编译完成！共耗时: $(($cost_time/60))min $(($cost_time%60))s"
