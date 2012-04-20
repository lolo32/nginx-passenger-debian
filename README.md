## nginx-passenger-debian ##

This repository contains a version of nginx patched to include support for Phusion Passenger that can be built as a Debian package.

### Getting the sources ###

#### With Git ####

If you have git installed, you could clone this repository with:

    git clone git://github.com/lolo32/nginx-passenger-debian.git

#### Using the Debian sources and diff file ####

If you don't have git installed, or want don't want to download the repository, you could use the diff file, which could be applied whithout any problem to the debian sources. It add ONLY support for Phusion Passenger in the package `nginx-passenger*` and in `nginc-extras*`. Use this command to apply:

    cd <YOUR DEBIAN SOURCES>
    patch -p1 < nginx-1.1.19-passenger.diff

### Build Instructions ###

Make sure that Ruby is correctly set up and install the `passenger` gem like this:

    sudo gem install passenger

Next, check out this repository and build its Debian packages using:

    dpkg-buildpackage -b -rfakeroot

In case, mandatory build dependencies are missing, install these using:

    apt-get build-dep nginx

Install the resulting `nginx-passenger` and `nginx-common` .deb packages located in the previous directory and you are done:

    sudo dpkg -i ../nginx-passenger-1*.deb ../nginx-common*.deb

### General Information ###

Documentation is available at http://nginx.org

