TARGETS = mountkernfs.sh hostname.sh udev mountdevsubfs.sh hwclock.sh checkroot.sh checkfs.sh mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh networking rpcbind urandom kmod bootmisc.sh generate-ssh-hostkeys udev-finish checkroot-bootclean.sh x11-common procps screen-cleanup
INTERACTIVE = udev checkroot.sh checkfs.sh
udev: mountkernfs.sh
mountdevsubfs.sh: mountkernfs.sh udev
hwclock.sh: mountdevsubfs.sh
checkroot.sh: hwclock.sh mountdevsubfs.sh hostname.sh
checkfs.sh: checkroot.sh
mountall.sh: checkfs.sh checkroot-bootclean.sh
mountall-bootclean.sh: mountall.sh
mountnfs.sh: mountall.sh mountall-bootclean.sh networking rpcbind
mountnfs-bootclean.sh: mountall.sh mountall-bootclean.sh mountnfs.sh
networking: mountkernfs.sh mountall.sh mountall-bootclean.sh urandom procps
rpcbind: networking mountall.sh mountall-bootclean.sh
urandom: mountall.sh mountall-bootclean.sh hwclock.sh
kmod: checkroot.sh
bootmisc.sh: mountnfs-bootclean.sh checkroot-bootclean.sh mountall.sh mountall-bootclean.sh mountnfs.sh udev
generate-ssh-hostkeys: mountall.sh mountall-bootclean.sh
udev-finish: udev mountall.sh mountall-bootclean.sh
checkroot-bootclean.sh: checkroot.sh
x11-common: mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh
procps: mountkernfs.sh mountall.sh mountall-bootclean.sh udev
screen-cleanup: mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh
