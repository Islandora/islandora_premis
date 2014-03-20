# Islandora PREMIS [![Build Status](https://travis-ci.org/Islandora/islandora_premis.png?branch=7.x)](https://travis-ci.org/Islandora/islandora_premis)

## Introduction

This module produces XML and HTML representations of [PREMIS](http://www.loc.gov/standards/premis/) metadata for objects in your repository. Currently, it documents all fixity checks performed on datastreams, includes 'agent' entries for your insitution and for the Fedora Commons software and, maps contents of each object's "rights" elements in DC datastreams to equivalent PREMIS "rightsExtension" elements.

PREMIS XML describing all the datastreams in an object [looks like this](https://gist.github.com/mjordan/8256978), and a HTML rendering [looks like this](http://digital.library.yorku.ca/yul-89067/city-dover-bought-penetang-group/view_premis).

## Requirements

This module requires the following modules/libraries:

* [Islandora](https://github.com/islandora/islandora)
* [Tuque](https://github.com/islandora/tuque)

Recommended modules:

* [Islandora Checksum](https://github.com/islandora/islandora_checksum): create checksums.
* [Islandora Checksum Checker](https://github.com/islandora/islandora_checksum_checker): periodically verifies checksums on datastreams and will populate your Islandora objects' audit logs with fixity checking 'events' that map to PREMIS.

## Installation

Install as usual, see [this](https://drupal.org/documentation/install/modules-themes/modules-7) for further information.

## Configuration

Set your institution's 'agent' settings Administration » Islandora » PREMIS.

[![Configuration](http://i.imgur.com/SSGa5PF.png)](http://i.imgur.com/SSGa5PF.png)

Set your permissions for 'View PREMIS metadata' and 'Download PREMIS metadata' at Administration » People » Permissions.

## FAQ

## Troubleshooting

Having problems/Solved a problem? Check out the Islandora google groups for a solution.

* [Islandora Group](https://groups.google.com/forum/?hl=en&fromgroups#!forum/islandora)
* [Islandora Dev Group](https://groups.google.com/forum/?hl=en&fromgroups#!forum/islandora-dev)

## Maintainers

[Nick Ruest](https://github.com/ruebot)
[Mark Jordan](https://github.com/mjordan)
[Donald Moses](https://github.com/dmoses)

## License

[GPLv3](http://www.gnu.org/licenses/gpl-3.0.txt)
