 --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../linux24/lx_config.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

treever=${pkg/linux/} ; treever=${treever/-*/}

lx_cpu=`echo "$arch_machine" | sed -e s/i.86/i386/ -e s/powerpc/ppc/ \
        -e s/sh.$/sh/ -e s/hppa/parisc/`
lx_extraversion=""
lx_kernelrelease=""
lx_defconfig="arch/$lx_cpu/defconfig arch/$lx_cpu/configs/common_defconfig"

[ $arch = sparc -a "$ROCKCFG_SPARC_64BIT_KERNEL" = 1 ] && \
        lx_cpu=sparc64

MAKE="$MAKE ARCH=$lx_cpu CROSS_COMPILE=$archprefix KCC=$KCC"

auto_config ()
{
	if [ -f $base/architecture/$arch/kernel$treever.conf.sh ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf.sh"
		. $base/architecture/$arch/kernel$treever.conf.sh > .config
	elif [ -f $base/architecture/$arch/kernel$treever.conf.m4 ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf.m4"
		m4 -I $base/architecture/$arch -I $base/architecture/share \
		   $base/architecture/$arch/kernel$treever.conf.m4 > .config
	elif [ -f $base/architecture/$arch/kernel$treever.conf ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf"
		cp $base/architecture/$arch/kernel$treever.conf .config
	elif [ -f $base/architecture/$arch/kernel.conf.sh ] ; then
		echo "  using: architecture/$arch/kernel.conf.sh"
		. $base/architecture/$arch/kernel.conf.sh > .config
	elif [ -f $base/architecture/$arch/kernel.conf.m4 ] ; then
		echo "  using: architecture/$arch/kernel.conf.m4"
		m4 -I $base/architecture/$arch -I $base/architecture/share \
		   $base/architecture/$arch/kernel.conf.m4 > .config
	elif [ -f $base/architecture/$arch/kernel.conf ] ; then
		echo "  using: architecture/$arch/kernel.conf"
		cp $base/architecture/$arch/kernel.conf .config
	else
		echo "  using: no rock kernel config found"
		cp arch/$lx_cpu/defconfig .config
	fi

	echo "  merging (system default(s)): $lx_defconfig"
	grep -h '^CONF.*=y' $lx_defconfig | cut -f1 -d= | while read tag
	do
		egrep -q "(^| )$tag[= ]" .config || echo "$tag=y"
	done >> .config ; cp .config .config.1

	# all modules needs to be first so modules can be disabled by i.e.
	# the targets later
	echo "Enabling all modules ..."
	yes '' | eval $MAKE no2modconfig > /dev/null ; cp .config .config.2

	if [ -f $base/target/$target/kernel$treever.conf.sh ] ; then
		confscripts="$base/target/$target/kernel$treever.conf.sh $confscripts"
	elif [ -f $base/target/$target/kernel.conf.sh ] ; then
		confscripts="$base/target/$target/kernel.conf.sh $confscripts"
	fi

	for x in $confscripts ; do
		echo "  running: $x"
		sh $x .config
	done
	cp .config .config.3

	# merge various text/plain config files
	for x in $base/config/$config/linux.cfg \
	         $base/target/$target/kernel.conf ; do
	   if [ -f $x ] ; then
		echo "  merging: '$x'"
		tag="$(sed '/CONFIG_/ ! d; s,.*CONFIG_\([^ =]*\).*,\1,' \
			$x | tr '\n' '|')"
		egrep -v "\bCONFIG_($tag)\b" < .config > .config.4
		sed 's,\(CONFIG_.*\)=n,# \1 is not set,' \
			$x >> .config.4
		cp .config.4 .config
	   fi
	done

	# create a valid .config
	yes '' | eval $MAKE oldconfig > /dev/null ; cp .config .config.5

	# last disable broken stuff
	rm -f /tmp/$$.sed
	list="CONFIG_THIS_DOES_NOT_EXIST"
	for x in $pkg_linux_brokenfiles ; do
	    if [ -f "$x" ] ; then
		echo "Disable broken file: $x"
		list="$list `tr ' ' '\t' < $x | cut -f1 | grep '^CONFIG_'`"
            fi
	done
	for x in $list ; do
		echo "s,^$x=.\$,# $x is not set,;" >> /tmp/$$.sed
	done

	sed -f /tmp/$$.sed < .config > .config.6
	cp .config.6 .config ; rm -f /tmp/$$.sed

	# create a valid .config (dependencies might need to be disabled)
	yes '' | eval $MAKE oldconfig > /dev/null

	# save final config
	cp .config .config_modules

	echo "Creating config without modules ...."
	sed "s,\(CONFIG_.*\)=m,# \1 is not set," .config > .config_new
	mv .config_new .config
	# create a valid .config (dependencies might need to be disabled)
	yes '' | eval $MAKE oldconfig > /dev/null
	mv .config .config_nomods

	# which .config to use?
	if [ "$ROCKCFG_PKG_LINUX_CONFIG_STYLE" = "modules" ] ; then
		cp .config_modules .config
	else
		cp .config_nomods .config
	fi
}

lx_grabextraversion () {
	local ev
	ev=$( sed -n -e 's,^[ \t]*EXTRAVERSION[ \t]*=[ \t]*\([^ \t]*\),\1,p' Makefile | tail -n 1 )
	if [ "$ev" ]; then
		lx_extraversion="${lx_extraversion}$ev"
		# keep intact but commented since the second EXTRAVERSION
		# definition, and clean the first.
		sed -e 's,^\([ \t]*EXTRAVERSION[ \t]*=.*\),#\1,g' \
		    -e 's,^#\(EXTRAVERSION =\).*,\1,' \
		    Makefile > Makefile.new
		mv Makefile.new Makefile
	fi
}
lx_injectextraversion () {
	lx_extraversion="${lx_extraversion}-dist"

	# inject final EXTRAVERSION into Makefile
	sed -i -e "s,^\([ \t]*EXTRAVERSION[ \t]*\)=.*,\1= ${lx_extraversion},g" Makefile

	# update version.h - we only do this, because some other freaky
	# projects like rsbac change EXTRAVERSION in other Makefiles ...
	rerun=""; eval $MAKE include/linux/version.h | grep -q "is up to date" && rerun=1
	if [ "$rerun" ] ; then
		echo "WARNING: Your system's timer resolution is too low ..."
		sleep 1 ; touch Makefile
		eval $MAKE include/linux/version.h
	fi

	# get kernel_release
	lx_kernelrelease="$( echo -e "#include <linux/version.h>\nUTS_RELEASE" \
                    > conftest.c &&	\
                    gcc -E -I./include conftest.c | tail -n 1	\
                    | cut -d '"' -f 2 && rm -f conftest.c )"
}

lx_patch ()
{
	echo "Generic linux patching ..."

	# grab extraversion from vanilla
	lx_grabextraversion

	# inject a possible prerelease patch
	var_insert patchfiles " " "`match_source_file patch-*.bz2`"

	hook_eval prepatch
	apply_patchfiles "lx_grabextraversion"
	hook_eval postpatch

	echo "Redefining some VERSION flags ..."
	lx_injectextraversion

	echo "Correcting user and permissions ..."
	chown -R root:root . * ; chmod -R u=rwX,go=rX .

	if [[ $treever = 24* ]] ; then
		echo "Create symlinks and a few headers for <$lx_cpu> ... "
		eval $MAKE symlinks
		cp $base/package/base/linux24/autoconf.h include/linux/
		touch include/linux/modversions.h
	else
		echo "Create symlinks and a few headers for <$lx_cpu> ... "
		eval $MAKE include/asm
	fi

	echo "Clean up the *.orig and *~ files ... "
	rm -f .config.old
	find -name '*.orig' -o -name '*~' | xargs rm -f

	# some arches (sh64 at the time of writing) have a "defect" Makefile
	# and do not work without a .config ...
	touch .config

	echo "... linux source patching finished."
}

lx_config() {
	echo "Generic linux configuration ..."
	hook_eval preconf
	if [ "$ROCKCFG_PKG_LINUX_CONFIG_STYLE" = none ] ; then
		echo "Using \$base/config/\$config/linux.cfg."
		echo "Since automatic generation is disabled ..."
		cp -v $base/config/$config/linux.cfg .config || true
	else
		echo "Automatically creating default configuration ...."
		auto_config
	fi

	echo "... configuration finished!"
}

pkg_linux_brokenfiles="$base/architecture/$arch/kernel-disable.lst \
	$base/architecture/$arch/kernel$treever-disable.lst \
	$base/package/*/linux$treever/disable-broken.lst \
	$pkg_linux_brokenfiles"

