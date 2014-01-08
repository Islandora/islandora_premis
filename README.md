## Islandora PREMIS

### Build Status

[![Build Status](https://travis-ci.org/ruebot/islandora_premis.png?branch=7.x)](https://travis-ci.org/ruebot/islandora_premis)

### Summary

This module produces XML and HTML representations of [PREMIS](http://www.loc.gov/standards/premis/) metadata for objects in your repository. Currently, it documents all fixity checks performed on datastreams, includes 'agent' entries for your insitution and for the Fedora Commons software and, maps contents of each object's "rights" elements in DC datastreams to equivalent PREMIS "rightsExtension" elements.

PREMIS XML describing all the datastreams in an object [looks like this](https://gist.github.com/mjordan/8256978), and a HTML rendering [looks like this](http://digital.library.yorku.ca/yul-89067/city-dover-bought-penetang-group/view_premis).

### Requirements

None. But, it is recommended to download and install [Islandora Checksum](https://github.com/ruebot/islandora_checksum) and [Islandora Checksum Checker](https://github.com/mjordan/islandora_checksum_checker).

[Islandora Checksum](https://github.com/ruebot/islandora_checksum) will create checksums.

[Islandora Checksum Checker](https://github.com/mjordan/islandora_checksum_checker) periodically verifies checksums on datastreams and will populate your Islandora objects' audit logs with fixity checking 'events' that map to PREMIS.

### Installation

`cd $ISLANDORA_HOME/sites/all/modules && git clone https://github.com/ruebot/islandora_premis && drush pm-enable islandora_premis`

### Configuration

Go to admin/islandora/premis and configure your insitutions's 'agent' settings.

### License

[GPLv3](http://www.gnu.org/licenses/gpl-3.0.txt)

### Troubleshooting

Having problems/Solved a problem? 

Check out the Islandora google groups for a solution.

[Islandora Group](https://groups.google.com/forum/?hl=en&fromgroups#!forum/islandora)

[Islandora Dev Group](https://groups.google.com/forum/?hl=en&fromgroups#!forum/islandora-dev)
