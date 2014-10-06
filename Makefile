nd:=tools/*

linux:=$(nd) Linux/sbin/* 
freebsd:=$(nd) FreeBSD/sbin/*
openbsd:=$(nd) OpenBSD/sbin/*

freebsd_init:=$(nd) FreeBSD/init/*
openbsd_init:=OpenBSD/init/*
hardy_init:=Linux/init/sysvinit/ipv4ll

yc2:=yc2/*
freebsd_yc2:=$(yc2) FreeBSD/yc2/*
openbsd_yc2:=$(yc2) OpenBSD/yc2/*

all: linux freebsd openbsd preceed hardy

preceed: $(linux)
	cat /dev/null > $@
	for f in $^; do echo "    echo $$(base64 -w0 $$f)|/target/usr/bin/base64 -d >/target/usr/sbin/$${f##*/}; \\" >> $@; echo "    chmod a+x /target/usr/sbin/$${f##*/}; \\" >> $@; done

linux: $(linux)
	cat /dev/null > $@
	for f in $^; do echo "base64 --decode <<< $$(base64 -w0 $$f) >/usr/sbin/$${f##*/}" >> $@; printf "chmod a+x /usr/sbin/$${f##*/}\n\n" >> $@; done

hardy: preceed $(hardy_init)
	cat preceed > $@
	for f in $(hardy_init); do echo "    echo $$(base64 -w0 $$f)|/target/usr/bin/base64 -d >/target/etc/init.d/$${f##*/}; \\" >> $@; echo "    chmod a+x /target/etc/init.d/$${f##*/}; \\" >> $@; done

freebsd: $(freebsd)
	cat FreeBSD/yc2/yc2-init-setup > $@
	for f in $^; do echo "base64 --decode <<< $$(base64 -w0 $$f) >/usr/local/sbin/$${f##*/}" >> $@; printf "chmod a+x /usr/local/sbin/$${f##*/}\n\n" >> $@; done
	for f in $(freebsd_init); do echo "base64 --decode <<< $$(base64 -w0 $$f) >/usr/local/etc/rc.d/$${f##*/}" >> $@; done
	for f in $(freebsd_yc2); do echo "base64 --decode <<< $$(base64 -w0 $$f) >/yc2/$${f##*/}" >> $@; printf "chmod a+x /yc2/$${f##*/}\n\n" >> $@; done

openbsd: $(openbsd)
	cat OpenBSD/yc2/yc2-init-setup > $@
	for f in $^; do echo "base64 -d <<< $$(base64 -w0 $$f) > /usr/local/sbin/$${f##*/}" >> $@; printf "chmod a+x /usr/local/sbin/$${f##*/}\n\n" >> $@; done
	#for f in $(openbsd_init); do echo "base64 -d <<< $$(base64 -w0 $$f) > /etc/rc.d/$${f##*/}" >> $@; printf "chmod a+x /etc/rc.d/$${f##*/}\n\n" >> $@; done
	for f in $(openbsd_yc2); do echo "base64 -d <<< $$(base64 -w0 $$f) > /yc2/$${f##*/}" >> $@; printf "chmod a+x /yc2/$${f##*/}\n\n" >> $@; done

altrpm: $(linux)
	cat /dev/null > $@
	for f in $^; do printf "cat > /usr/sbin/$${f##*/} << \\\EOF\n" >> $@; cat $$f >>$@; printf "EOF\nchmod a+x /usr/sbin/$${f##*/}\n\n" >> $@; done

altbsd: $(freebsd)
	cat /dev/null > $@
	for f in $^; do printf "cat > /usr/local/sbin/$${f##*/} << \\\EOF\n" >> $@; cat $$f >>$@; printf "EOF\nchmod a+x /usr/local/sbin/$${f##*/}\n\n" >> $@; done

clean:
	rm -f preceed freebsd linux altrpm altbsd openbsd hardy

.PHONY: all preceed hardy rpm freebsd openbsd altbsd altrpm clean distclean
