FROM jcr.io/coreos/kmod-builder:1911.4.0 as builder

# makedumpfile
#RUN USE="static static-libs" emerge --verbose -e dev-libs/libgcrypt
ENV ACCEPT_KEYWORDS="~amd64"
ADD freeipmi /var/lib/portage/coreos-overlay/sys-apps/freeipmi
RUN emerge --verbose sys-apps/freeipmi
RUN quickpkg sys-apps/freeipmi

# Repackage
RUN mkdir /tmp/pkg-tmp && cd /tmp/pkg-tmp
WORKDIR /tmp/pkg-tmp
RUN tar jxvf /var/lib/portage/pkgs/sys-apps/freeipmi-1.6.2.tbz2
RUN tar jcvf /tmp/pkg.tbz2 .

FROM alpine:latest
COPY docker-entrypoint.sh /
RUN mkdir /target /src
COPY --from=builder /tmp/pkg.tbz2 /src

ENTRYPOINT ["/docker-entrypoint.sh"]
