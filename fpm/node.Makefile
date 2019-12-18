.PHONY: package build
build: 
	wget https://nodejs.org/dist/v12.13.1/node-v12.13.1.tar.gz;  \
	tar -zxf node-v12.13.1.tar.gz;  \
	cd node-v12.13.1;  \
	./configure --prefix=/usr ; \
	make

package:
	mkdir /tmp/installdir ; \
	make install DESTDIR=/tmp/installdir ; \
	fpm -s dir -t deb -n nodejs -v 12.13.1 -C /tmp/installdir \
  -p nodejs_VERSION_ARCH.deb \
  usr/bin usr/lib

