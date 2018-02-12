![Gaia Sky](https://zah.uni-heidelberg.de/fileadmin/user_upload/gaia/gaiasky/img/GaiaSkyBanner-vr.jpg)
--------------------------

[![Documentation Status](https://readthedocs.org/projects/gaia-sky/badge/?version=latest)](http://gaia-sky.readthedocs.io/en/latest/?badge=latest)
[![Circle CI](https://circleci.com/gh/langurmonkey/gaiasky.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/langurmonkey/gaiasky/tree/master)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)

[**Gaia Sky VR**](https://zah.uni-heidelberg.de/gaia/outreach/gaiasky) is a real-time, 3D, astronomy VR software that
runs on multiple headsets and operating systems thanks to Valve's [OpenVR](https://github.com/ValveSoftware/openvr). It is developed in the framework of
[ESA](http://www.esa.int/ESA)'s [Gaia mission](http://sci.esa.int/gaia) to chart about 1 billion stars of our Galaxy.
To get the latest up-to-date and most complete information,

*  Visit our [**home page**](https://zah.uni-heidelberg.de/gaia/outreach/gaiasky)
*  Read the [**Documentation**](http://gaia-sky.readthedocs.io) for the non-VR version
*  Submit a [**bug** or a **feature request**](https://github.com/langurmonkey/gaiasky/issues)
*  Follow development news at [@GaiaSky_Dev](https://twitter.com/GaiaSky_Dev)

This file contains the following sections:

1. [Running Gaia Sky VR](#1-running-gaia-sky-vr)
2. [Documentation and help](#2-documentation-and-help)
3. [Copyright and licensing information](#3-copyright-and-licensing-information)
4. [Contact information](#4-contact-information)
5. [Credits and acknowledgements](#5-acknowledgements)


## 1. Running Gaia Sky VR

The Gaia Sky VR project is the Virtual Reality version of Gaia Sky. At the moment, only [OpenVR](https://github.com/ValveSoftware/openvr) is supported, but nothing prevents us from supporting other APIs (like the Kronos Group's [OpenXR](https://www.khronos.org/openxr)) in the future if it makes sense. Our tests have only been carried out with the Oculus Rift CV1 headset in direct mode under Windows. Supporting Linux is a top priority for us, and the HTC Vive should work well under Linux, even though the state of OpenVR in the platform is a bit rough. Also, we want to point out that Linux support for the Oculus Rift was dropped for the CV1 and it is not expected to be continued any time soon, unfortunately.

Gaia Sky VR is heavily under development, and it is not guaranteed to work. Currently, no binaries are provided, but it can still be run by compiling the source. Just keep in mind that this is the developmen branch.

### 1.1. Pre-requisites

This guide is for running Gaia Sky VR with the Oculus Rift in Windows. You will need the following: 

1. Download and install [Git for Windows](http://gitforwindows.org/) and get used to the unix-like command line interface.
2. If you are using the Oculus Rift headset, follow the provided instructions and install the Oculus app with the runtime.
3. Download and install [Steam](http://store.steampowered.com/) and then install [SteamVR](http://store.steampowered.com/steamvr).

### 1.2. Cloning the repository

First, open the Git for Windows CLI and clone the [GitHub](https://github.com/langurmonkey/gaiasky) repository and checkout the `vr` branch:

```
$  git clone https://github.com/langurmonkey/gaiasky.git
$  cd gaiasky
$  git checkout vr
```

Make sure you have at least `JDK8` installed.

### 1.3. Getting the data

The TGAS catalog files (Gaia data) are **not** in the repository, so if you want to use TGAS when running
from source you need to download
the `tar` file corresponding to your version — see table below.

As of version `1.5.0`, there are new GPU-bound catalogs which perform much better and can also be combined with the levels-of-detail structure to produce a good combo in terms of performance
and load times. Choose which catalog you want to use. Usually, the single file GPU version should work fine (tgas gpu), and has no culling, so all particles are visible at all times.

| **Catalog** | **Description** | **Extract location** | **Catalog file** |
|---------|-------------|----------|----------|
| [tgas lod (1.0.3)](http://wwwstaff.ari.uni-heidelberg.de/gaiasandbox/files/20161206_tgas_gaiasky_1.0.3.tar.gz)  | Levels of detail (lod) TGAS catalog. CPU-bound. | `gaiasky/assets/data/octree` | - |
| [tags lod (1.0.4)](http://wwwstaff.ari.uni-heidelberg.de/gaiasandbox/files/20161206_tgas_gaiasky_1.0.4.tar.gz)  | Levels of detail (lod) TGAS catalog. CPU-bound. | `gaiasky/assets/data/octree` | - |
| tags lod ([1.5.0](http://wwwstaff.ari.uni-heidelberg.de/gaiasandbox/files/20170731_tgas_lod_gaiasky_1.5.0.tar.gz), [1.5.1](http://wwwstaff.ari.uni-heidelberg.de/gaiasandbox/files/20171204_tgas_lod_gaiasky_1.5.1.tar.gz))  | Levels of detail (lod) TGAS catalog. GPU-bound. Version `1.5.1` contains a fix in proper motion and RAVE radial velocities.  | `gaiasky/assets/data/octree/tgas` | `data/catalog-tgas-hyg-lod.json` |
| tags gpu ([1.5.0](http://wwwstaff.ari.uni-heidelberg.de/gaiasandbox/files/20170731_tgas_gpu_gaiasky_1.5.0.tar.gz), [1.5.1](http://wwwstaff.ari.uni-heidelberg.de/gaiasandbox/files/20171204_tgas_gpu_gaiasky_1.5.1.tar.gz))  | TGAS catalog, GPU-bound. Version `1.5.1` contains a fix in proper motion and RAVE radial velocities.  | `gaiasky/assets/data/catalog` | `data/catalog-tgas-hyg.json` | 

First, choose the package corresponding to your Gaia Sky version and extract it into the specified **Extract location**. `tgas lod` means levels of detail, so data in these catalogs is streamed from disk to GPU. `tgas gpu` means that the data is loaded all at startup and sent to the GPU at that moment. Choose `tgas gpu` if you have a good graphics card.

Then, you need to point the key `data.json.catalog` in your `$HOME/.gaiasky/global.properties` file to the
file specified in the last column in the table (**Catalog file**).

Albeit **not recommended** for performance reasons, the legacy particle-based (CPU-bound) version of the catalog (version `1.0.4`) can still be used with newer versions. To do so, extract the package in `gaiasky/android/assets/data/octree/tgas` so that the `metadata.bin` file and the `particles` folder are directly within that folder and 
edit the configuration file so that `data.json.catalog` points to `data/catalog-tgas-hyg-lod-old.json`.


### 1.4. Running

To run Gaia Sky VR, make sure that both the Oculus runtime and Steam VR are running. Then, run Gaia Sky through gradle. The first time it will pull lots of dependencies and compile the whole project, so it may take a while.

```
$  gradlew.bat core:run
```

Et voilà! Gaia Sky VR dev branch is running.

In order to pull the latest version from the repository, just run the following from the `gaiasky` folder.

```
$  git pull origin vr
```

Remember that the master branch is the development branch and therefore intrinsically unstable. It is not guaranteed to always work.

##  2. Documentation and help

The most up-to-date documentation of Gaia Sky is always in [gaia-sky.readthedocs.io](http://gaia-sky.readthedocs.io).

##  3. Copyright and licensing information

This software is published and distributed under the MPL 2.0
(Mozilla Public License 2.0). You can find the full license
text here https://github.com/langurmonkey/gaiasky/blob/master/LICENSE.md
or visiting https://opensource.org/licenses/MPL-2.0

##  4. Contact information

The main webpage of the project is
**[https://www.zah.uni-heidelberg.de/gaia/outreach/gaiasky](https://www.zah.uni-heidelberg.de/gaia/outreach/gaiasky)**. There you can find
the latest versions and the latest information on Gaia Sky.

##  5. Acknowledgements

The latest acknowledgements are always in the [ACKNOWLEDGEMENTS.md](https://github.com/langurmonkey/gaiasky/blob/master/ACKNOWLEDGEMENTS.md) file.
