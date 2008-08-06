DESTDIR  =
PREFIX   = /usr/local
BINDIR   = $(PREFIX)/bin
ICONDIR  = $(PREFIX)/share/icons/hicolor/scalable/apps
MENUDIR  = $(PREFIX)/share/applications
DFLAGS   = #-ggdb #-pg
OFLAGS   = -Os
AOFLAGS  = -O3
CXXFLAGS = -Wall $(DFLAGS) `pkg-config gtkmm-2.4 gthread-2.0 --cflags`
LDFLAGS  = $(DFLAGS) -Lcellrenderertk
TARGETS  = easystroke

LIBS     = $(DFLAGS) -lcellrenderertk -lboost_serialization -lXtst `pkg-config gtkmm-2.4 gthread-2.0 --libs`

LIBS_STATIC = $(DFLAGS) -lcellrenderertk -lXtst `pkg-config gtkmm-2.4 gthread-2.0 --libs` /usr/lib/libboost_serialization.a

BINARY   = easystroke
ICON     = easystroke.svg
MENU     = easystroke.desktop
MANPAGE  = easystroke.1

CCFILES  = $(wildcard *.cc)
CFILES   = clientwin.c dsimple.c gui.c
OFILES   = $(patsubst %.cc,%.o,$(CCFILES)) $(patsubst %.c,%.o,$(CFILES)) 
DEPFILES = $(wildcard *.Po)
GENFILES = gui.gb gui.c

all: $(TARGETS)

.PHONY: all clean $(BINARY)

clena:	clean

clean:
	$(MAKE) -C cellrenderertk clean
	$(RM) $(OFILES) $(BINARY) $(GENFILES) $(DEPFILES)

include $(DEPFILES)

$(BINARY): $(OFILES)
	$(MAKE) -C cellrenderertk
	$(CXX) $(LDFLAGS) -o $(BINARY) $(OFILES) $(LIBS)

static: $(OFILES)
	$(MAKE) -C cellrenderertk
	$(CXX) $(LDFLAGS) -o $(BINARY) $(OFILES) $(LIBS_STATIC)
	strip -s $(BINARY)

stroke.o: stroke.cc
	$(CXX) $(CXXFLAGS) $(AOFLAGS) -MT $@ -MMD -MP -MF $*.Po -o $@ -c $<

%.o: %.cc
	$(CXX) $(CXXFLAGS) $(OFLAGS) -MT $@ -MMD -MP -MF $*.Po -o $@ -c $<

gui.gb: gui.glade
	gtk-builder-convert gui.glade gui.gb

gui.c: gui.gb
	echo "const char *gui_buffer = \"\\" > gui.c
	sed 's/"/\\"/g' gui.gb | sed 's/.*/&\\n\\/' >> gui.c
	echo "\";" >> gui.c

vartest: var.cc var.h
	g++ -ggdb `pkg-config gtkmm-2.4 gthread-2.0 --cflags --libs` -DTEST_VAR var.cc -o vartest

man:	$(MANPAGE)

$(MANPAGE):	$(BINARY)
	help2man -N -n "X11 gesture recognition application" ./$(BINARY) > $(MANPAGE)

install: all
	install -Ds $(BINARY) $(DESTDIR)$(BINDIR)/$(BINARY)
	install -D -m 644 $(ICON) $(DESTDIR)$(ICONDIR)/$(ICON)
	install -D -m 644 $(MENU) $(DESTDIR)$(MENUDIR)/$(MENU)

uninstall:
	rm $(DESTDIR)$(BINDIR)/$(BINARY) || true
	rm $(DESTDIR)$(ICONDIR)/$(ICON) || true
	rm $(DESTDIR)$(MENUDIR)/$(DESKTOP) || true
