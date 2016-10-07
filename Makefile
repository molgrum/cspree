#QCC = fteqcc

INSTALL_DIR = ~/quake

all:
	$(MAKE) -C ss -f Makefile ../../gmapn/qwprogs.dat
#	$(MAKE) -C cs -f Makefile csprogs.dat

#install:
#	$(MAKE) -C ss -f Makefile install
#	$(MAKE) -C cs -f Makefile install

CFGS := $(shell find . -name '*.cfg' -print)
SHS  := $(shell find . -name '*.sh' -print)

install-configs:
	for i in $(CFGS); do cp --parent $$i $(INSTALL_DIR); done
	for i in $(SHS); do cp --parent $$i $(INSTALL_DIR); done
	cp --parent gmapn/maps/*.ent $(INSTALL_DIR)
	cp --parent gmapn/maps/*.way $(INSTALL_DIR)
	cp --parent *.sh $(INSTALL_DIR)

clean:
	$(MAKE) -C ss -f Makefile clean
	$(MAKE) -C cs -f Makefile clean

