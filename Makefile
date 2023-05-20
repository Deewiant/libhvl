.PHONY: always all clean install

all: hvl2wav libhvl.so libhvl.h

# sed command for:
# - Using standard type names (see upstream types.h, adapted here to be based on
#   stdbool.h and stdint.h) and standard true/false
# - Rename MAX_CHANNELS with a HVL_ prefix
FIX_TYPES := 's/int\(8\|16\|32\)/&_t/g; s/float64/double/g; s/TEXT/char/g; s/BOOL/bool/g; s/MAX_CHANNELS/HVL_&/g; s/FALSE/false/g; s/TRUE/true/g; s/CONST/const/g'

%.c: hivelytracker/hvl2wav/%.c hivelytracker/hvl2wav/replay.h
	grep Period2Freq hivelytracker/hvl2wav/replay.h > $@
	sed -e $(FIX_TYPES) -e 's/replay\.h/libhvl.h/; /types\.h/d' $< >> $@

%.o: %.c libhvl.h
	$(CC) -c -std=gnu99 $(CPPFLAGS) $(CFLAGS) -fPIC -o $@ $<

hvl2wav: hvl2wav.o replay.o
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ $+ -lm

libhvl.so: hvl2wav.o replay.o
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -o $@ $+ -lm

libhvl.h: hivelytracker/hvl2wav/replay.h prefix.h suffix.h
	cat prefix.h > $@
	sed -e $(FIX_TYPES) -e /Period2Freq/d $< >> $@
	cat suffix.h >> $@

clean:
	rm -f replay.c replay.o hvl2wav.c hvl2wav.o hvl2wav libhvl.so libhvl.h

PREFIX := /usr/local

install: all
	install -Dm644 -t $(PREFIX)/lib libhvl.so
	install -Dm644 -t $(PREFIX)/include libhvl.h
	install -Dm755 -t $(PREFIX)/bin hvl2wav
	install -Dm644 -t $(PREFIX)/doc/libhvl hivelytracker/LICENSE
