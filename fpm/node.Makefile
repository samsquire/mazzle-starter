
package: 
	wget http://nodejs.org/dist/v0.6.0/node-v0.6.0.tar.gz;  \
	tar -zxf node-v0.6.0.tar.gz;  \
	cd node-v0.6.0;  \
	./configure --prefix=/usr ; \
	make ; \
	mkdir /tmp/installdir ; \
	make install DESTDIR=/tmp/installdir ; \
	fpm -s dir -t deb -n nodejs -v 0.6.0 -C /tmp/installdir \
  -p nodejs_VERSION_ARCH.deb \
  -d "libssl0.9.8 > 0" \
  -d "libstdc++6 >= 4.4.3" \
  usr/bin usr/lib

