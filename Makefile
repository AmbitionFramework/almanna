
PREFIX ?= /usr
LIBDIR ?=
ifeq ($(LIBDIR),)
ARCHBSZ= $(shell echo $(HOST_ARCH) | sed -e 's/.*64.*/64b/')
ifeq ($(ARCHBSZ),64b)
	LIBDIR = lib64
else
	LIBDIR = lib
endif
endif
VAPIDIR ?= $(PREFIX)/share/vala/vapi
PC_DIR ?= $(PREFIX)/share/pkgconfig

VER = 0.1
SRC_DIR = src
BUILD_DIR = build
TEST_DIR = test
LIB_ROOT = almanna-$(VER)
LIBRARY = lib$(LIB_ROOT).so
HEADER = $(LIB_ROOT).h

LIB_SRC = \
	$(SRC_DIR)/Column.vala \
	$(SRC_DIR)/Comparison.vala \
	$(SRC_DIR)/Config.vala \
	$(SRC_DIR)/Entity.vala \
	$(SRC_DIR)/Logger.vala \
	$(SRC_DIR)/Query.vala \
	$(SRC_DIR)/Repo.vala \
	$(SRC_DIR)/Search.vala \
	$(SRC_DIR)/Server.vala

TESTS = \
	$(TEST_DIR)/test-runner.vala $(TEST_DIR)/repo.vala \
	$(TEST_DIR)/entity-define.vala $(TEST_DIR)/entity-save.vala \
    $(TEST_DIR)/column.vala $(TEST_DIR)/search.vala $(TEST_DIR)/UserEntity.vala \
    $(TEST_DIR)/server.vala

PKGS = --pkg gee-1.0 --pkg gio-2.0 --pkg posix --pkg libgda-4.0 --pkg libxml-2.0

VALAC = valac
VALACOPTS = -g -X -shared -X -fPIC --vapi $(BUILD_DIR)/$(LIB_ROOT).vapi --library $(LIB_ROOT) --header $(BUILD_DIR)/$(HEADER) --enable-experimental

.PHONY: all test clean

all:
	@test -d build || mkdir build
	@$(VALAC) $(VALACOPTS) $(LIB_SRC) -o $(BUILD_DIR)/$(LIBRARY) $(PKGS)

install:
	install -m 0755 $(BUILD_DIR)/$(LIBRARY) $(PREFIX)/$(LIBDIR)
	install -m 0755 $(BUILD_DIR)/$(HEADER) $(PREFIX)/include
	install -m 0755 $(BUILD_DIR)/$(LIB_ROOT).vapi $(VAPIDIR)
	install -m 0755 $(LIB_ROOT).deps $(VAPIDIR)
	@sed -e 's/@LIBDIR@/\$(PREFIX)\/$(LIBDIR)/' -e 's/@INCLUDEDIR@/\$(PREFIX)\/include/' $(LIB_ROOT).pc.in > $(PC_DIR)/$(LIB_ROOT).pc

test:
	@LD_LIBRARY_PATH=build $(VALAC) -g $(PKGS) --vapidir build --pkg $(LIB_ROOT) -X -l$(LIB_ROOT) -X -Lbuild -X -Ibuild -o $(BUILD_DIR)/test-$(LIB_ROOT) $(TESTS)
	@LD_LIBRARY_PATH=build $(BUILD_DIR)/test-$(LIB_ROOT)
	@test -e $(BUILD_DIR)/test-$(LIB_ROOT)

clean:
	@rm -v -fr *~ *.c $(BUILD_DIR)/*
