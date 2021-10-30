echo "Dist Root: ${DIST_ROOT:?}"
echo "LFS: ${LFS:?}"

mkdir -p $LFS/sources

for f in $(cat $DIST_ROOT/build_env/build_env_list)
do
	bn=$(basename $f)
	
	#checks if the packages already exists; then downloads the missing ones

	if ! test -f $LFS/sources/$bn ; then 
		wget $f -O $LFS/sources/$bn
	fi

done;


mkdir -pv $LFS/{etc,var,lib64,tools} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done


if ! test $(id -u distbuilder); then

groupadd distbuilder
useradd -s /bin/bash -g distbuilder -m -k /dev/null distbuilder
passwd distbuilder
chown -v distbuilder $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}

echo "distbuilder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers_distbuilder

dbhome=$(eval echo "~distbuilder")

cat > $dbhome/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash

EOF

cat > ~/.bashrc << EOF

set +h
umask 022
LFS=$LFS
DIST_ROOT=$DIST_ROOT


EOF

# > create file >> append file


cat >> ~/.bashrc << "EOF"

LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS="-j$(nproc)"
EOF




fi

