#!/bin/bash
PACKAGE=trepan

# FIXME put some of the below in a common routine
function finish {
  cd $owd
}

cd $(dirname ${BASH_SOURCE[0]})
owd=$(pwd)
trap finish EXIT

if ! source ./pyenv-newer-versions ; then
    exit $?
fi
if ! source ./setup-master.sh ; then
    exit $?
fi

cd ..
source $PACKAGE/version.py
echo $VERSION

for pyversion in $PYVERSIONS; do
    if ! pyenv local $pyversion ; then
	exit $?
    fi
    # pip bdist_egg create too-general wheels. So
    # we narrow that by moving the generated wheel.

    # Pick out first two number of version, e.g. 3.5.1 -> 35
    first_two_dot=$(echo $pyversion | cut -d'.' -f 1-2 )
    first_two=$(echo $pyversion | cut -d'.' -f 1-2 | sed -e 's/\.//')
    rm -fr build
    python setup.py bdist_egg bdist_wheel
    # mv -v dist/${PACKAGE}-$VERSION-py${first_two_dot}.egg dist/${PACKAGE}3k-$VERSION-py${first_two_dot}.egg
    mv -v dist/${PACKAGE}-$VERSION-py3-none-any.whl dist/${PACKAGE}-$VERSION-py${first_two}-none-any.whl
done

python ./setup.py sdist
# mv -v dist/${PACKAGE}-$VERSION.tar.gz dist/${PACKAGE}3k-$VERSION.tar.gz
