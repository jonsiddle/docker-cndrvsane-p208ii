FROM debian:jessie
LABEL org.opencontainers.image.authors="Jon Siddle <jon@trapdoor.org>"

# Jessie is dead
RUN echo 'deb http://archive.debian.org/debian/ jessie main contrib non-free' > /etc/apt/sources.list
RUN echo 'deb-src http://archive.debian.org/debian/ jessie main contrib non-free' >> /etc/apt/sources.list
RUN apt-get -y --force-yes update

# Package seem to be older on archive than in the base image, so have to downgrade some things - ick
RUN apt-get -y  --force-yes install libbz2-1.0=1.0.6-7+b3 perl-base=5.20.2-3+deb8u11 gcc-4.9-base=4.9.2-10+deb8u1 libgcc1=1:4.9.2-10+deb8u1 libstdc++6=4.9.2-10+deb8u1


# Deps
RUN apt-get -y  --force-yes install build-essential devscripts autoconf libtool libusb-dev libsane sane

# Start preparing our build area
RUN mkdir /root/build
WORKDIR /root/build

# Driver depends on parallel sane-backends source & lib
RUN apt-get -y --force-yes --allow-unauthenticated source sane-backends
WORKDIR /root/build/sane-backends-1.0.24
RUN ./configure --prefix=/usr --sysconfdir=/etc
RUN make
# Driver expects static lib (presumably older versions didn't require this hack)
RUN cp sanei/.libs/*.a sanei/

# Driver itself
WORKDIR /root/build
COPY cndrvsane-p208ii-1.00-3.tar.gz /root/build
RUN tar xvzf cndrvsane-p208ii-1.00-3.tar.gz
WORKDIR /root/build/cndrvsane-p208ii-1.00-3
# Update version number from the one the driver expects to the one we're using (which matches the system)
RUN find . -type f -print0 | xargs -0 sed -i -e 's/sane-backends-1.0.19/sane-backends-1.0.24/g'

RUN ln -s /usr/lib/x86_64-linux-gnu/sane /usr/lib/sane

# I can't work out why it doesn't build pure 64bit...but it doesn't
RUN dpkg --add-architecture i386
RUN apt-get -y --force-yes update
RUN apt-get -y --force-yes install libc6:i386 libstdc++6:i386
RUN debuild --no-tgz-check -uc -us
RUN dpkg -i ../cndrvsane-p208ii_1.00-3_amd64.deb

# Create non-root user
RUN groupadd -g 1000 user && useradd -u 1000 -g user -m user

USER 1000:1000

# Expect this to be bound with -v
RUN mkdir /home/user/data
WORKDIR /home/user/data
ENTRYPOINT ["scanadf"]
