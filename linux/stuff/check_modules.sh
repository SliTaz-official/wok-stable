#!/bin/sh
# Echo any module in kernel .config that's not added to one of linux-* pkgs
# (c) SliTaz - GNU General Public License.
# 20090618 <jozee@slitaz.org> 
# 20100528 <pankso@slitaz.org>
#
WOK=$(cd `basedir $0` && pwd | sed 's/wok.*/wok/')
VERSION=`grep  ^VERSION= $WOK/linux/receipt | cut -d "=" -f2 | sed -e 's/"//g'`
src="$WOK/linux/linux-$VERSION"

cd $src
mkdir -p ../tmp
rm -f ../tmp/*

echo -e "\nChecking for modules selected in .config but not in linux-* pkgs"
echo "======================================================================"

# create a packaged modules list
cat ../stuff/modules-"$VERSION".list >> ../tmp/pkgs-modules-"$VERSION".list 

for i in $(cd $WOK; ls -d linux-*)
do
	tazpath="taz/$i-$VERSION"
	for j in $(cat $WOK/$i/$tazpath/files.list | grep ".ko.gz")
	do
		basename $j >> ../tmp/pkgs-modules-"$VERSION".list	
	done 	
done
# get the original list in .config
for i in $(find $_pkg -iname "*.ko.gz") 
do
	basename $i >> ../tmp/originial-"$VERSION".list
done
# compare original .config and pkged modules
for i in $(cat ../tmp/originial-$VERSION.list)   
do		
	if ! grep -qs "$i" ../tmp/pkgs-modules-"$VERSION".list ; then 
		modpath=`find $_pkg -iname "$i"`
		echo "Orphan module: $i"
		echo "$i : $modpath" >> ../tmp/unpackaged-modules-"$VERSION".list
	fi
done
if [ -f ../tmp/unpackaged-modules-"$VERSION".list ]; then
	echo "======================================================================"
	echo -e "Check linux/tmp/unpackaged-modules-$VERSION.list for mod path\n"
else
	echo -e "\nAll modules are packaged\n"
	echo "======================================================================"
	echo ""
	rm -rf ../tmp
fi
