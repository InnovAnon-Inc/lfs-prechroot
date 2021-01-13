FROM innovanon/builder as builder-01
USER root
ARG LFS=/mnt/lfs
ARG TEST=
# optional
COPY             --chown=root ./sources/ $LFS/sources/
COPY --from=innovanon/book --chown=root /home/lfs/lfs-systemd/* \
                                         $LFS/sources/
FROM builder-01 as builder-02
#ARG EXT=tgz
ARG LFS=/mnt/lfs
COPY --from=innovanon/book --chown=root /home/lfs/lfs-sysd-commands/chapter02/* \
                                        /home/lfs/lfs-sysd-commands/chapter04/* \
                              /root/.bin/
WORKDIR $LFS/sources
RUN sleep 31                                           \
 && echo dash dash/sh boolean false                    \
  | debconf-set-selections                             \
 && dpkg-reconfigure dash -f noninteractive            \
 && $SHELL -eux 016-hostreqs                           \
 && rm -v version-check.sh                             \
 && $SHELL -eux 026-creatingminlayout                  \
 && chown -v lfs $LFS/{usr,lib,var,etc,bin,sbin,tools} \
 && case $(uname -m) in                                \
      x86_64) chown -v lfs $LFS/lib64 ;;               \
    esac                                               \
 && rm -rf                    /root/.bin               \
 && mv -v /usr{/local,}/bin/dl                         \
 && exec true || exec false

FROM builder-02 as builder-03
ARG LFS=/mnt/lfs
ARG TEST=
COPY --from=innovanon/book --chown=root /home/lfs/lfs-sysd-commands/chapter05/* \
                              /home/lfs/.bin/

#WORKDIR $LFS/sources
# TODO check command -v
USER lfs
RUN sleep 31 \
 && command -v dl                                         \
 \
 && dl binutils-2.35.1.tar.xz                        \
 && cd              binutils-2.35.1                     \
 && $SHELL -eux 035-binutils-pass1                      \
 && cd $LFS/sources                                     \
 && rm -rf          binutils-2.35.1                     \
 \
 && dl gcc-10.2.0.tar.xz gmp-6.2.1.tar.xz       \
          isl-0.23.tar.xz   mpc-1.2.1.tar.gz       \
          mpfr-4.1.0.tar.xz                        \
 && cd              gcc-10.2.0                     \
 && tar xf ../isl-0.23.tar.xz                      \
 && mv -v     isl{-0.23,}                          \
 && $SHELL -eux 036-gcc-pass1                      \
 && cd $LFS/sources                                \
 && rm -rf          gcc-10.2.0                     \
 \
 && dl linux-5.10.4.tar.xz                           \
 && cd              linux-5.10.4                     \
 && $SHELL -eux 037-linux-headers                    \
 && cd $LFS/sources                                  \
 && rm -rf          linux-5.10.4                     \
 \
 && dl glibc-2.32.tar.xz                        \
 && cd              glibc-2.32                     \
 && $SHELL -eux 038-glibc                          \
 && cd $LFS/sources                                \
 && rm -rf          glibc-2.32                     \
 \
 && tar xf          gcc-10.2.0.tar.xz   \
 && cd              gcc-10.2.0          \
 && $SHELL -eux 039-gcc-libstdc++-pass1 \
 && cd $LFS/sources                     \
 && rm -rf          gcc-10.2.0         \
 && exec true || exec false
#                    $HOME/.bin

#FROM builder-03 as squash-tmp
#USER root
#RUN  squash.sh
#FROM scratch as squash
#ADD --from=squash-tmp /tmp/final.tar /

FROM builder-03
