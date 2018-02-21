#!/bin/bash -xe

pkg_version=$1
if [ -z ${pkg_version+x} ]; then
    echo "No package version provided"
    exit 1
fi

cat > $HOME/.rpmmacros << EOF_MACROS
%_topdir /root/el
%_tmppath %{_topdir}/tmp
%_signature gpg
%_gpg_name hello@serverdensity.com
%_gpg_path ~/.gnupg
EOF_MACROS

mkdir /root/el
cd /root/el
for dir in SOURCES BUILD RPMS SRPMS; do
    [ -d $dir ] || mkdir $dir
done
for repo in /sd-agent-core-plugins; do
    tar -czf /root/el/SOURCES/${repo}-${pkg_version}.tar.gz ${repo}
    cp -a ${repo}/packaging/el/{SPECS,inc,description} /root/el
    cd /root/el
    chown -R `id -u`:`id -g` /root/el
    function build {
        rpmdir=/root/build/result/$1
        yum-builddep -y SPECS/${repo}-$1.spec
        rpmbuild -ba SPECS/${repo}-$1.spec && \
        (test -d $rpmdir || mkdir -p $rpmdir) && cp -a /root/el/RPMS/* $rpmdir
    }
    build "el6"
done

if [ ! -d /packages/el ]; then
    mkdir /packages/el
fi

if [ ! -d /packages/el/6 ]; then
    mkdir /packages/el/6
fi

if [ ! -d /packages/src ]; then
    mkdir /packages/src
fi
cp -r /root/el/RPMS/* /packages/el/6
cp -r /root/el/SRPMS/* /packages/src
