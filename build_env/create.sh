echo "Dist Root: ${DIST_ROOT:?}"
echo "LFS: ${LFS:?}"

echo "Creating build environment..."

if ! test $(whoami) == 'distbuilder'; then
	echo "Must run as distbuilder!"
	exit -1
fi