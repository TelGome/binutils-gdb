#!/usr/bin/env bash
#   Copyright (C) 1990-2024 Free Software Foundation
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# This script creates release packages for gdb, binutils, and other
# packages which live in src.  It used to be implemented as the src-release
# Makefile and prior to that was part of the top level Makefile, but that
# turned out to be very messy and hard to maintain.

set -e

BZIPPROG=bzip2
GZIPPROG=gzip
LZIPPROG=lzip
XZPROG=xz
ZSTDPROG=zstd
SHA256PROG=sha256sum
MAKE=make
CC=gcc
CXX=g++
release_date=

# Default to avoid splitting info files by setting the threshold high.
MAKEINFOFLAGS=--split-size=5000000

#
# Support for building net releases

# Files in root used in any net release.
DEVO_SUPPORT="ar-lib ChangeLog compile config config-ml.in config.guess \
	config.rpath config.sub configure configure.ac COPYING COPYING.LIB \
	COPYING3 COPYING3.LIB depcomp install-sh libtool.m4 ltgcc.m4 \
	ltmain.sh ltoptions.m4 ltsugar.m4 ltversion.m4 lt~obsolete.m4 \
	MAINTAINERS Makefile.def Makefile.in Makefile.tpl missing mkdep \
	mkinstalldirs move-if-change README README-maintainer-mode \
	SECURITY.txt src-release.sh symlink-tree test-driver ylwrap \
        multilib.am"

# Files in devo/etc used in any net release.
ETC_SUPPORT="ChangeLog Makefile.am Makefile.in aclocal.m4 add-log.el \
	add-log.vi configbuild.* configdev.* configure configure.ac \
	configure.in configure.info* configure.texi fdl.texi gnu-oids.texi \
	make-stds.texi standards.info* standards.texi texi2pod.pl \
	update-copyright.py"

# Get the version number of a given tool
getver()
{
    tool=$1
    if grep 'AC_INIT.*BFD_VERSION' $tool/configure.ac >/dev/null 2>&1; then
	bfd/configure --version | sed -n -e '1s,.* ,,p'
    elif test -f $tool/common/create-version.sh; then
	$tool/common/create-version.sh $tool 'dummy-host' 'dummy-target' VER.tmp
	cat VER.tmp | grep 'version\[\]' | sed 's/.*"\([^"]*\)".*/\1/' | sed 's/-git$//'
        rm -f VER.tmp
    elif test $tool = "gdb"; then
	./gdbsupport/create-version.sh $tool 'dummy-host' 'dummy-target' VER.tmp
	cat VER.tmp | grep 'version\[\]' | sed 's/.*"\([^"]*\)".*/\1/' | sed 's/-git$//'
        rm -f VER.tmp
    elif test -f $tool/version.in; then
	head -n 1 $tool/version.in
    else
	echo VERSION
    fi
}

clean_sources()
{
    # Check that neither staged nor unstaged changes of any tracked file remains.
    if [ -n "$(git status --porcelain -uno)" ]; then
        echo "There are uncommitted changes. Please commit or stash them."
        exit 1
    fi

    echo "==> Cleaning sources."

    # Remove all untracked files.
    git clean -fdx

    # Umask for any new file created by this script.
    umask 0022

    # Fix permissions of all tracked files and directories according to the previously set umask.
    echo "==> Fixing permissions."
    permreg=$(printf "%o" $((0666 & ~$(umask))))
    permexe=$(printf "%o" $((0777 & ~$(umask))))
    git ls-tree -rt --format "objectmode=%(objectmode) path=%(path)" HEAD | while read -r objectprop; do
        eval $objectprop
        case $objectmode in
            100644)
                # regular file
                chmod $permreg $path
                ;;
            100755|040000)
                # executable file or directory
                chmod $permexe $path
                ;;
            120000)
                # symlink, do nothing, always lrwxrwxrwx.
                ;;
            160000)
                # submodule, currently do nothing
                ;;
            *)
                # unlikely, might be a future version of Git
                echo unsupported object at $path
                exit 1
                ;;
        esac
    done
}

# Setup build directory for building release tarball
do_proto_toplev()
{
    package=$1
    ver=$2
    tool=$3
    support_files=$4

    clean_sources
    
    echo "==> Making $package-$ver/"
    # Take out texinfo from a few places.
    sed -e '/^all\.normal: /s/\all-texinfo //' \
	-e '/^	install-texinfo /d' \
	<Makefile.in >tmp
    mv -f tmp Makefile.in
    # configure.  --enable-gold is needed to ensure .c/.h from .y are
    # built in the gold dir.  The disables speed the build a little.
    enables=
    disables=
    for dir in binutils gas gdb gold gprof gprofng libsframe ld libctf libdecnumber readline sim; do
	case " $tool $support_files " in
	    *" $dir "*) enables="$enables --enable-$dir" ;;
	    *) disables="$disables --disable-$dir" ;;
	esac
    done
    echo "==> configure --target=i386-pc-linux-gnu $disables $enables"
    ./configure --target=i386-pc-linux-gnu $disables $enables
    $MAKE configure-host configure-target \
	ALL_GCC="" ALL_GCC_C="" ALL_GCC_CXX="" \
	CC_FOR_TARGET="$CC" CXX_FOR_TARGET="$CXX"
    # Make links, and run "make diststuff" or "make info" when needed.
    rm -rf proto-toplev
    mkdir proto-toplev
    dirs="$DEVO_SUPPORT $support_files $tool"
    for d in $dirs ; do
	if [ -d $d ]; then
	    if [ ! -f $d/Makefile ] ; then
		true
	    elif grep '^diststuff:' $d/Makefile >/dev/null ; then
		(cd $d ; $MAKE MAKEINFOFLAGS="$MAKEINFOFLAGS" diststuff) \
		    || exit 1
	    elif grep '^info:' $d/Makefile >/dev/null ; then
		(cd $d ; $MAKE MAKEINFOFLAGS="$MAKEINFOFLAGS" info) \
		    || exit 1
	    fi
	    if [ -d $d/proto-$d.dir ]; then
		ln -s ../$d/proto-$d.dir proto-toplev/$d
	    else
		ln -s ../$d proto-toplev/$d
	    fi
	else
	    if (echo x$d | grep / >/dev/null); then
		mkdir -p proto-toplev/`dirname $d`
		x=`dirname $d`
		ln -s ../`echo $x/ | sed -e 's,[^/]*/,../,g'`$d proto-toplev/$d
	    else
		ln -s ../$d proto-toplev/$d
	    fi
	fi
    done
    (cd etc; $MAKE MAKEINFOFLAGS="$MAKEINFOFLAGS" info)
    $MAKE distclean
    mkdir proto-toplev/etc
    (cd proto-toplev/etc;
	for i in $ETC_SUPPORT; do
	    ln -s ../../etc/$i .
	done)
    #
    # Take out texinfo from configurable dirs
    rm proto-toplev/configure.ac
    sed -e '/^host_tools=/s/texinfo //' \
	<configure.ac >proto-toplev/configure.ac
    #
    mkdir proto-toplev/texinfo
    ln -s ../../texinfo/texinfo.tex proto-toplev/texinfo/
    if test -r texinfo/util/tex3patch ; then
	mkdir proto-toplev/texinfo/util && \
	    ln -s ../../../texinfo/util/tex3patch proto-toplev/texinfo/util
    fi
    #
    # Create .gmo files from .po files.
    for f in `find . -name '*.po' -type f -print`; do
	msgfmt -o `echo $f | sed -e 's/\.po$/.gmo/'` $f
    done
    #
    rm -f $package-$ver
    ln -s proto-toplev $package-$ver
}

CVS_NAMES='-name CVS -o -name .cvsignore'

# Add a sha256sum to the built tarball
do_sha256sum()
{
    echo "==> Adding sha256 checksum to top-level directory"
    (cd proto-toplev && find * -follow \( $CVS_NAMES \) -prune \
	-o -type f -print \
	| xargs $SHA256PROG > ../sha256.new)
    rm -f proto-toplev/sha256.sum
    mv sha256.new proto-toplev/sha256.sum
}

# Build the release tarball
do_tar()
{
    package=$1
    ver=$2
    echo "==> Making $package-$ver.tar"
    rm -f $package-$ver.tar
    if test x$release_date == "x" ; then
       find $package-$ver -follow \( $CVS_NAMES \) -prune -o -type f -print \
	   | tar cTfh - $package-$ver.tar
    else
	# Attempt to create a consistent, reproducible tarball using the
	# specified date.
	find $package-$ver -follow \( $CVS_NAMES \) -prune -o -type f -print \
	    | LC_ALL=C sort \
	    | tar cTfh - $package-$ver.tar \
		  --mtime=$release_date --group=0 --owner=0
    fi
}

# Compress the output with bzip2
do_bz2()
{
    package=$1
    ver=$2
    echo "==> Bzipping $package-$ver.tar.bz2"
    rm -f $package-$ver.tar.bz2
    $BZIPPROG -k -v -9 $package-$ver.tar
}

# Compress the output with gzip
do_gz()
{
    package=$1
    ver=$2
    echo "==> Gzipping $package-$ver.tar.gz"
    rm -f $package-$ver.tar.gz
    $GZIPPROG -k -v -9 $package-$ver.tar
}

# Compress the output with lzip
do_lz()
{
    package=$1
    ver=$2
    echo "==> Lzipping $package-$ver.tar.lz"
    rm -f $package-$ver.tar.lz
    $LZIPPROG -k -v -9 $package-$ver.tar
}

# Compress the output with xz
do_xz()
{
    package=$1
    ver=$2
    echo "==> Xzipping $package-$ver.tar.xz"
    rm -f $package-$ver.tar.xz
    $XZPROG -k -v -9 -T0 $package-$ver.tar
}

# Compress the output with zstd
do_zstd()
{
    package=$1
    ver=$2
    echo "==> Zzipping $package-$ver.tar.zst"
    rm -f $package-$ver.tar.zst
    $ZSTDPROG -k -v -19 -T0 $package-$ver.tar
}

# Compress the output with all selected compresion methods
do_compress()
{
    package=$1
    ver=$2
    compressors=$3
    for comp in $compressors; do
	case $comp in
	    bz2)
		do_bz2 $package $ver;;
	    gz)
		do_gz $package $ver;;
	    lz)
		do_lz $package $ver;;
	    xz)
		do_xz $package $ver;;
	    zstd)
		do_zstd $package $ver;;
	    *)
		echo "Unknown compression method: $comp" && exit 1;;
	esac
    done
}

# Add djunpack.bat the tarball
do_djunpack()
{
    package=$1
    ver=$2
    echo "==> Adding updated djunpack.bat to top-level directory"
    echo - 's /gdb-[0-9\.]*/$package-'"$ver"'/'
    sed < djunpack.bat > djunpack.new \
	-e 's/gdb-[0-9][0-9\.]*/$package-'"$ver"'/'
    rm -f proto-toplev/djunpack.bat
    mv djunpack.new proto-toplev/djunpack.bat
}

# Create a release package, tar it and compress it
tar_compress()
{
    package=$1
    tool=$2
    support_files=$3
    compressors=$4
    verdir=${5:-$tool}
    ver=$(getver $verdir)
    do_proto_toplev $package $ver $tool "$support_files"
    do_sha256sum
    do_tar $package $ver
    do_compress $package $ver "$compressors"
}

# Create a gdb release package, tar it and compress it
gdb_tar_compress()
{
    package=$1
    tool=$2
    support_files=$3
    compressors=$4
    ver=$(getver $tool)
    do_proto_toplev $package $ver $tool "$support_files"
    do_sha256sum
    do_djunpack $package $ver
    do_tar $package $ver
    do_compress $package $ver "$compressors"
}

GAS_DIRS="bfd gas include libiberty opcodes setup.com makefile.vms zlib"
gas_release()
{
    compressors=$1
    package=gas
    tool=gas
    tar_compress $package $tool "$GAS_DIRS" "$compressors"
}

BINUTILS_DIRS="$GAS_DIRS binutils cpu gprof gprofng ld libsframe libctf"
binutils_release()
{
    compressors=$1
    package=binutils
    tool=binutils
    tar_compress $package $tool "$BINUTILS_DIRS" "$compressors"
}

BINUTILS_GOLD_DIRS="$BINUTILS_DIRS elfcpp gold"
binutils_gold_release()
{
    compressors=$1
    package=binutils-with-gold
    tool=binutils
    tar_compress $package $tool "$BINUTILS_GOLD_DIRS" "$compressors"
}

GOLD_DIRS="gold elfcpp include"
# These extra directories whilst not directly related to
# gold are needed in order to be able to build and test it.
GOLD_DIRS="$GOLD_DIRS bfd libsframe libctf libiberty binutils opcodes gas"
gold_release()
{
    compressors=$1
    package=gold
    tool=binutils
    tar_compress $package $tool "$GOLD_DIRS" "$compressors"
}

GDB_SUPPORT_DIRS="libsframe bfd include libiberty libctf opcodes readline sim libdecnumber cpu zlib contrib gnulib gdbsupport gdbserver libbacktrace"
gdb_release()
{
    compressors=$1
    package=gdb
    tool=gdb
    gdb_tar_compress $package $tool "$GDB_SUPPORT_DIRS" "$compressors"
}

# Corresponding to the CVS "sim" module.
SIM_SUPPORT_DIRS="libsframe bfd opcodes libiberty libctf/swap.h include gdb/version.in gdb/common/create-version.sh makefile.vms zlib gnulib"
sim_release()
{
    compressors=$1
    package=sim
    tool=sim
    tar_compress $package $tool "$SIM_SUPPORT_DIRS" "$compressors" gdb
}

usage()
{
    echo "src-release.sh <options> <release>"
    echo "options:"
    echo "  -b: Compress with bzip2"
    echo "  -g: Compress with gzip"
    echo "  -l: Compress with lzip"
    echo "  -x: Compress with xz"
    echo "  -z: Compress with zstd"
    echo "  -r <date>: Create a reproducible tarball using <date> as the mtime"
    echo "release:"
    echo "  binutils:     All the binutils except gold"
    echo "  binutils_with_gold:  All the binutils including gold"
    echo "  gas:          Just the assembler"
    echo "  gdb:          All of GDB"
    echo "  gold:         Just the gold linker"
    echo "  sim:          Just the simulator"
    exit 1
}

build_release()
{
    release=$1
    compressors=$2
    case $release in
	binutils)
	    binutils_release "$compressors";;
	binutils_with_gold)
	    binutils_gold_release "$compressors";;
	gas)
	    gas_release "$compressors";;
	gdb)
	    gdb_release "$compressors";;
	gold)
	    gold_release "$compressors";;
	sim)
	    sim_release "$compressors";;
	*)
	    echo "Unknown release name: $release" && usage;;
    esac
}

compressors=""

while getopts ":bglr:xz" opt; do
    case $opt in
	b)
	    compressors="$compressors bz2";;
	g)
	    compressors="$compressors gz";;
	l)
	    compressors="$compressors lz";;
	r)
	    release_date=$OPTARG;;
	x)
	    compressors="$compressors xz";;
	z)
	    compressors="$compressors zstd";;
	\?)
	    echo "Invalid option: -$OPTARG" && usage;;
    esac
done
shift $((OPTIND -1))
release=$1

build_release $release "$compressors"
