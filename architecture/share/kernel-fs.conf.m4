dnl --- T2-COPYRIGHT-NOTE-BEGIN ---
dnl This copyright note is auto-generated by ./scripts/Create-CopyPatch.
dnl 
dnl T2 SDE: architecture/share/kernel-fs.conf.m4
dnl Copyright (C) 2004 - 2005 The T2 SDE Project
dnl 
dnl More information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; version 2 of the License. A copy of the
dnl GNU General Public License can be found in the file COPYING.
dnl --- T2-COPYRIGHT-NOTE-END ---

dnl Enable Quota Support
dnl
CONFIG_PARTITION_ADVANCED=y

CONFIG_QUOTA=y

CONFIG_JOLIET=y
CONFIG_ZISOFS=y

CONFIG_DEVPTS_FS=y
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y

dnl mark the usual suspects modular
dnl
CONFIG_EXT2_FS=m
CONFIG_EXT3_FS=m
CONFIG_ISO9660_FS=m
CONFIG_FAT_FS=m

dnl Network FS settings
dnl Version 3 has several advantages ...
dnl
CONFIG_NFS_FS=m
CONFIG_NFS_V3=m
CONFIG_NFSD_V3=m

dnl ROMFS, RAMFS, CRAMFS and TMPFS (for initrd, install and /tmp)
dnl
CONFIG_ROMFS_FS=y
CONFIG_RAMFS=y
CONFIG_CRAMFS=y
CONFIG_TMPFS=y

dnl Squashfs (if patched in)
dnl
CONFIG_SQUASHFS=y

