QCC = fteqcc

INSTALL_DIR = ~/quake/gmapn

SRC = \
	constants.qc \
	csbuiltins.qc \
	entrypoints.qc

csprogs.dat: $(SRC)
	$(QCC)

install: csprogs.dat
	cp -f csprogs.dat $(INSTALL_DIR)

clean:
	rm -f csprogs.dat csprogs.lno

