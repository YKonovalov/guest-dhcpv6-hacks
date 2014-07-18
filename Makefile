nd:=tools/*
yc2:=yc2/*
linux:=$(nd) Linux/* 
freebsd:=$(nd) FreeBSD/*

all: preceed bsd rpm

preceed: $(linux)
	cat /dev/null > $@
	for f in $^; do echo "    base64 --decode <<< $$(base64 -w0 $$f) >/target/usr/sbin/$${f##*/}; \\" >> $@; echo "    chmod a+x /target/usr/sbin/$${f##*/}; \\" >> $@; done

rpm: $(linux)
	cat /dev/null > $@
	for f in $^; do echo "base64 --decode <<< $$(base64 -w0 $$f) >/usr/sbin/$${f##*/}" >> $@; printf "chmod a+x /usr/sbin/$${f##*/}\n\n" >> $@; done

bsd: $(freebsd)
	cat yc2/yc2-init-setup > $@
	for f in $^; do echo "base64 --decode <<< $$(base64 -w0 $$f) >/usr/local/sbin/$${f##*/}" >> $@; printf "chmod a+x /usr/local/sbin/$${f##*/}\n\n" >> $@; done
	for f in $(yc2); do echo "base64 --decode <<< $$(base64 -w0 $$f) >/yc2/$${f##*/}" >> $@; printf "chmod a+x /yc2/$${f##*/}\n\n" >> $@; done

altrpm: $(linux)
	cat /dev/null > $@
	for f in $^; do printf "cat > /usr/sbin/$${f##*/} << \\\EOF\n" >> $@; cat $$f >>$@; printf "EOF\nchmod a+x /usr/sbin/$${f##*/}\n\n" >> $@; done

altbsd: $(freebsd)
	cat /dev/null > $@
	for f in $^; do printf "cat > /usr/local/sbin/$${f##*/} << \\\EOF\n" >> $@; cat $$f >>$@; printf "EOF\nchmod a+x /usr/local/sbin/$${f##*/}\n\n" >> $@; done

clean:
	rm -f preceed bsd rpm altrpm altbsd

.PHONY: all preceed rpm bsd altbsd altrpm clean distclean
