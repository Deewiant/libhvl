.PHONY: always all clean install

all: hivelytracker/hvl2wav/hvl2wav libhvl.so libhvl.h

hivelytracker/hvl2wav/hvl2wav: always
	$(MAKE) -C hivelytracker/hvl2wav CFLAGS="$(CFLAGS) -fPIC"

libhvl.so: hivelytracker/hvl2wav/hvl2wav
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -o $@ hivelytracker/hvl2wav/replay.o -lm

# The sed does:
# - Use standard type names (see upstream types.h, adapted here to be based on
#   stdint.h; and yes, BOOL is short)
# - Rename MAX_CHANNELS with a HVL_ prefix
# - Remove Period2Freq
libhvl.h: hivelytracker/hvl2wav/replay.h prefix.h suffix.h
	cat prefix.h > $@
	sed 's/int\(8\|16\|32\)/&_t/g; s/float64/double/g; s/TEXT/char/g; s/BOOL/short/g; s/MAX_CHANNELS/HVL_&/g; /Period2Freq/d' $< >> $@
	cat suffix.h >> $@

clean:
	rm -f hivelytracker/hvl2wav/hvl2wav hivelytracker/hvl2wav/*.o libhvl.so libhvl.h

PREFIX := /usr/local

install: all
	install -Dm644 -t $(PREFIX)/lib libhvl.so
	install -Dm644 -t $(PREFIX)/include libhvl.h
	install -Dm755 -t $(PREFIX)/bin hivelytracker/hvl2wav/hvl2wav
	install -Dm644 -t $(PREFIX)/doc/libhvl hivelytracker/LICENSE
