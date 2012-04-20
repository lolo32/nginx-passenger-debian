## nginx-passenger-debian ##

This repository contains a version of nginx patched to include support for Phusion Passenger that can be built as a Debian package.

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

