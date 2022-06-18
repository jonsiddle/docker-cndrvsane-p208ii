# Summary

This docker project wraps the aging Canon P208-II driver since it is
increasingly difficult to get working with modern versions of Sane.

Note: I'm going for stability here. It uses an ancient version of Debian
(Jessie) rather than trying to make tweaks to work with more recent versions
which would need more regular updates.

# Pre-requisites

You need a working docker setup and the P208-II driver from Canon which you can get from here:

[https://files.canon-europe.com/files/soft45931/Software/d1515mux_lnx_DRP208II_v10003.zip](https://files.canon-europe.com/files/soft45931/Software/d1515mux_lnx_DRP208II_v10003.zip)

You only actually need `cndrvsane-p208ii-1.00-3.tar.gz` from that zip. Place it
in this directory.

# Building

This should be as simple as:

```
$ docker build -t cndrvsane:latest .
```

# Running

## Overview

+ It needs to be run with --privileged to access USB
+ It writes its output to /root/data so you should typically bind a local
  directory there
+ It just runs scanadf in the data directory

## Finding your device

This serves as a useful test, and also allows you to select the correct device.
Hopefully you will see something similar to below:

```
$ docker run --rm -it --privileged -v `pwd`/data:/root/data cndrvsane:latest -L
device `canondr:libusb:003:012' is a Canon P208II sheetfed scanner
```

(Strictly speaking the data volume binding is pointless here since we're not
scanning enything)

## Scanning

```
$ docker run --rm -it --privileged -v `pwd`/data:/root/data cndrvsane:latest -d canondr:libusb:003:012 --mode Color --resolution 600 --ScanMode Duplex -o "page-%04d.ppm"
Scanned document page-0001.ppm
Scanned document page-0002.ppm
scanadf: sane_read: Document feeder out of documents
Scanned 2 pages
$ ls data/                                                                                             
page-0001.ppm  page-0002.ppm  page-0003.ppm
```

Note: you will typically get an extra blank page. You can use the reported
number of scanned pages (which is correct) to know what to discard.
