all: clean package

clean:
	rm -rf .build .test

package:
	bash package.sh

install:
	install -d $(DESTDIR)$(prefix)/bin
	install -m 755 src/main/script/rs.sh $(DESTDIR)$(prefix)/bin/rs

test:
	bash test.sh
