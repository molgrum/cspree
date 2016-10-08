#!/bin/sh

QCC=./fteqcc
SRV=../fteqw.sv
PAK=gmapn.pk3

if [ `getconf LONG_BIT` = "64" ]; then
	wget -O ${QCC} http://triptohell.info/moodles/linux_amd64/fteqcc64
	wget -O ${SRV} http://triptohell.info/moodles/linux_amd64/fteqw-sv64
else
	wget -O ${QCC} http://triptohell.info/moodles/linux_x86/fteqcc32
	wget -O ${SRV} http://triptohell.info/moodles/linux_x86/fteqw-sv32
fi

chmod +x ${QCC}
chmod +x ${SRV}

wget -O ${PAK} http://triptohell.info/moodles/junk/${PAK}
