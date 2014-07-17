nd:=tools/*
linux:=$(nd) Linux/* 
freebsd:=$(nd) FreeBSD/*

all: preceed bsd bsdalt rpm rpmalt

preceed: $(linux)
	cat /dev/null > $@
	for f in $^; do echo "    base64 --decode <<< $$(base64 -w0 $$f) >/target/usr/sbin/$${f##*/}; \\" >> $@; echo "    chmod a+x /target/usr/sbin/$${f##*/}; \\" >> $@; done

rpmalt: $(linux)
	cat /dev/null > $@
	for f in $^; do echo "base64 --decode <<< $$(base64 -w0 $$f) >/usr/sbin/$${f##*/}" >> $@; printf "chmod a+x /usr/sbin/$${f##*/}\n\n" >> $@; done

rpm: $(linux)
	cat /dev/null > $@
	for f in $^; do printf "cat > /usr/sbin/$${f##*/} << \\\EOF\n" >> $@; cat $$f >>$@; printf "EOF\nchmod a+x /usr/sbin/$${f##*/}\n\n" >> $@; done

bsd: $(freebsd)
	cat /dev/null > $@
	for f in $^; do printf "cat > /usr/local/sbin/$${f##*/} << \\\EOF\n" >> $@; cat $$f >>$@; printf "EOF\nchmod a+x /usr/local/sbin/$${f##*/}\n\n" >> $@; done

bsdalt: $(freebsd)
	cat /dev/null > $@
	for f in $^; do echo "base64 --decode <<< $$(base64 -w0 $$f) >/usr/local/sbin/$${f##*/}" >> $@; printf "chmod a+x /usr/local/sbin/$${f##*/}\n\n" >> $@; done

clean:
	rm -f preceed bsd rpm rpmalt bsdalt

.PHONY: all preceed rpm rpmalt bsd bsdalt clean distclean
