FROM golang:1.8

ENV gettext_version=0.19.8
ENV glib_version=2.52.1
ENV pango_version=1.40.5
ENV atk_version=2.24.0
ENV gobject_version=1.52.1
ENV gtk_version=3.18.9

ENV DEBIAN_FRONTEND noninteractive

# Install packages needed for download, configure, makefiles, libs, ...
RUN apt-get -qq update
RUN apt-get -qq install apt-utils wget xz-utils build-essential zlib1g-dev pkg-config -y

# Download, compile, and install GETTEXT for GLIB
RUN wget https://ftp.gnu.org/pub/gnu/gettext/gettext-${gettext_version}.tar.xz -O /tmp/gettext-${gettext_version}.tar.xz -q
RUN tar -C /tmp/ -xf /tmp/gettext-${gettext_version}.tar.xz
WORKDIR /tmp/gettext-${gettext_version}
RUN ./configure
RUN make
RUN make install

# Download, compile, and install GLIB for GTK3
RUN apt-get install libffi-dev libmount-dev libpcre3-dev python3 -y
RUN wget https://download.gnome.org/sources/glib/$(echo $glib_version | sed -E 's/([0-9]+)\.([0-9]+).*/\1.\2/')/glib-${glib_version}.tar.xz -O /tmp/glib-${glib_version}.tar.xz -q
RUN tar -C /tmp/ -xf /tmp/glib-${glib_version}.tar.xz
WORKDIR /tmp/glib-${glib_version}
RUN ./configure --with-python=/usr/bin/python3
RUN make
RUN make install

# Download, compile, and install GOBJECT-INTROSPECTION for GTK3
RUN apt-get install libbison-dev python-dev flex -y
RUN wget https://download.gnome.org/sources/gobject-introspection/$(echo $gobject_version | sed -E 's/([0-9]+)\.([0-9]+).*/\1.\2/')/gobject-introspection-${gobject_version}.tar.xz -O /tmp/gobject-introspection-${gobject_version}.tar.xz -q
RUN tar -C /tmp/ -xf /tmp/gobject-introspection-${gobject_version}.tar.xz
WORKDIR /tmp/gobject-introspection-${gobject_version}
RUN ./configure
RUN make
RUN make install

# Download, compile, and install PANGO for GTK3
RUN apt-get install libfontconfig1-dev libharfbuzz-dev libfreetype6-dev libcairo2-dev -y
RUN wget https://download.gnome.org/sources/pango/$(echo $pango_version | sed -E 's/([0-9]+)\.([0-9]+).*/\1.\2/')/pango-${pango_version}.tar.xz -O /tmp/pango-${pango_version}.tar.xz -q
RUN tar -C /tmp/ -xf /tmp/pango-${pango_version}.tar.xz
WORKDIR /tmp/pango-${pango_version}
RUN ./configure
RUN make
RUN make install

# Download, compile, and install ATK for GTK3
RUN wget https://download.gnome.org/sources/atk/$(echo $atk_version | sed -E 's/([0-9]+)\.([0-9]+).*/\1.\2/')/atk-${atk_version}.tar.xz -O /tmp/atk-${atk_version}.tar.xz -q
RUN tar -C /tmp/ -xf /tmp/atk-${atk_version}.tar.xz
WORKDIR /tmp/atk-${atk_version}
RUN ./configure
RUN make
RUN make install

# Finally download, compile, and install GTK3
RUN apt-get install libgdk-pixbuf2.0-dev libxi-dev libepoxy-dev libatk-bridge2.0 -y
RUN wget http://ftp.gnome.org/pub/gnome/sources/gtk+/$(echo $gtk_version | sed -E 's/([0-9]+)\.([0-9]+).*/\1.\2/')/gtk+-${gtk_version}.tar.xz -O /tmp/gtk+-${gtk_version}.tar.xz -q
RUN tar -C /tmp/ -xf /tmp/gtk+-${gtk_version}.tar.xz
WORKDIR /tmp/gtk+-${gtk_version}
RUN ./configure
RUN make
RUN make install

# Libs will be installed in a directory not inside LD_LIBRARY_PATH
RUN echo "/usr/local/lib/" > /etc/ld.so.conf.d/local.conf
RUN ldconfig
