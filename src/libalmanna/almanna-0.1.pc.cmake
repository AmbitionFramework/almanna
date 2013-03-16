prefix=@PREFIX@
exec_prefix=@DOLLAR@{prefix}
libdir=@DOLLAR@{prefix}/lib
bindir=@DOLLAR@{prefix}/bin
includedir=@DOLLAR@{prefix}/include

Name: @PKGNAME@-@PKGVERSION@
Description: Almanna ORM for Vala and/or GObject.
Version: @PKGVERSION@
Libs: -L@DOLLAR@{libdir} -l@PKGNAME@-@PKGVERSION@
Cflags: -I@DOLLAR@{includedir}
Requires: gio-2.0 glib-2.0 gobject-2.0 libgda-5.0 libxml-2.0
