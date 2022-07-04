Almanna ORM
===========

REQUIREMENTS
------------

Almanna is written in the Vala programming language, and relies on other
libraries for its functionality. To build, you will need:

* Vala 0.48.0 or higher
* Meson 0.40 or higher, with ninja
* The GCC 4.x toolchain

At minimum, the following libraries are required:

* glib-2.0 (>=2.32)
* gio-2.0
* gee-1.0
* libgda-5.0
* libxml-2.0

BUILDING/INSTALLING FROM GIT
----------------------------

Almanna uses Meson to configure and prepare the source for installation. By
default, Almanna will install into /usr/local. Many Linux distros have a hard
time with that, so these instructions redirect to "/usr". To build the framework
using an "out of source" build:

```
meson --prefix=/usr builddir
cd builddir
ninja
ninja test
sudo ninja install
```

