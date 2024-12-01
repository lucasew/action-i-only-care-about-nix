stuffToStop=()
stuffToDelete=()

#doc: Stop services

stuffToStop+=(
  mono-xsp4.service
  snapd.service
  rsyslog.service
  chrony.service
  php8.1-fpm.service
)

#doc: Docker

docker image rm $(docker image ls --format '{{.ID}}')

#doc: Get rid of snap once and for all (~1GB)

sudo snap remove lxd core20 snapd

sudo systemctl stop snapd
sudo systemctl disable snapd
sudo systemctl mask snapd

sudo apt purge snapd -y
sudo apt-mark hold snapd

sudo cat <<EOF | sudo tee /etc/apt/preferences.d/nosnap.pref
  Package: snapd
  Pin: release a=*
  Pin-Priority: -10
EOF

stuffToDelete+=(
~/snap
/snap
/var/snap
/var/lib/snapd

#doc: Remove unnecessary stuff in /opt (~11GB)

/opt/hostedtoolcache
/opt/microsoft
/opt/az
/opt/pipx
/opt/google
/opt/mssql-tools

#doc: Remove android stuff (~7.7GB)
/usr/local/lib/android

#doc: Remove nodejs stuff (~1.1GB)
/usr/local/lib/node_modules

#doc: Remove lein stuff (~15MB)
/usr/local/lib/lein

#doc: Remove ghcup (~5.5GB)
/usr/local/lib/.ghcup

#doc: Remove powershell (~1.2GB)
/usr/local/share/powershell

#doc: Remove chromium (~500MB)
/usr/local/share/chromium

#doc: Remove vcpkg (~150MB)
/usr/local/share/vcpkg

#doc: Remove edge driver (~30MB)

/usr/local/share/edge_driver

#doc: Remove cmake (~30MB)
/usr/local/share/cmake-*

#doc: Remove chromedriver (~20MB)
/usr/local/share/chromedriver*

#doc: Remove geckodriver (~6MB)
/usr/local/share/gecko_driver

#doc: Remove bins (>1GB)
/usr/local/bin/oc
/usr/local/bin/minikube
/usr/local/bin/pulumi
/usr/local/bin/terraform
/usr/local/bin/bicep
/usr/local/bin/aliyun
/usr/local/bin/helm
/usr/local/bin/azcopy
/usr/local/bin/packer
/usr/local/bin/pulumi-*
/usr/local/bin/cmake-gui # LOL
/usr/local/bin/ctest
/usr/local/bin/cpack
/usr/local/bin/cmake
/usr/local/bin/ccmake
/usr/local/bin/kustomize
/usr/local/bin/oras
/usr/local/bin/phpunit

#doc: Remove julia (~900MB)
/usr/local/julia-*

#doc: Remove aws (~500MB)
/usr/local/aws-*

#doc: Remove n (~200MB)
/usr/local/n

#doc: Remove sqlpackage (~100MB)
/usr/local/sqlpackage

#doc: Remove doc (~50MB)
/usr/local/doc

#doc: Remove bin (>1GB)
/usr/bin/kubectl
/usr/bin/x86_64-*
/usr/bin/buildah
/usr/bin/pedump
/usr/bin/skopeo
/usr/bin/my*
/usr/bin/php*
/usr/bin/mono*
/usr/bin/perl*

/usr/sbin/mysql*
/usr/sbin/php*
/usr/sbin/nginx*

#doc: /var/lib's (~500MB)
/var/lib/gems
/var/lib/mysql
/var/lib/mecab
/var/lib/postgresql
/var/cache/*
)

systemctl stop "${stuffToStop[@]}"
sudo rm -rf "${stuffToDelete[@]}"
