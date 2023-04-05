### Description
This repository contains the advanced version of the original
physical properties tool for Garry's mod. It is designed to
have fully customizable surface properties configuration lists,
that you can modify, create, update and structure by yourself.
The tool can support many more surface properties than its original
brother, though the configuration you have to make yourself.

### Donations
I am supporting this tool in my free time mostly and it was quite a
ride since I already first created it. But since my lack of time for
playing gmod has been drastically increased some people asked me if
I accept donations, here is the [link to my PayPal](https://www.paypal.me/DeyanVasilev).

### Configuration
Looking for that, you better see the [Wiki][ref-wiki]

### How to install the extension
Just clone [this repo][ref-self] in your addons folder,
then copy the configuration files inside your [`DATA`][ref-data] folder.
You can easily [customize the materials lists][ref-config]. They will be
automatically generated from the file names that reside in the dedicated
material folder for every tool. Every file name will generate a category
and populate it with its contents separated by spaces, tabs or new lines.
You can see how to do that for any of the examples below:
1. [Material tool][ref-mmats]
2. [Properties tool][ref-pmats]

### Are you going to release it on the [workshop](https://steamcommunity.com/app/4000/workshop) ?
You can [subscribe to it here][ref-ws]. I also cannot ship comma separated values
[CSV][ref-csv] or [TSV][ref-tsv] as a local database standard as the workshop will
reject them immediately as a `harmful data`. Take the [`Track Assembly Tool`][ref-ta]
for example which has integrated the database in the initialization file. Its idea is
different than this tool by creating a full solution where the user may not interact
by changing the integrated database.

**If you prefer [the workshop version][ref-ws], please install
the material configurations yoiurself!**

[ref-self]: https://github.com/dvdvideo1234/PhysPropertiesAdv
[ref-wiki]: https://github.com/dvdvideo1234/PhysPropertiesAdv/wiki/Adding-configurations
[ref-tsv]: https://en.wikipedia.org/wiki/Tab-separated_values
[ref-csv]: https://en.wikipedia.org/wiki/Comma-separated_values
[ref-ta]: https://github.com/dvdvideo1234/TrackAssemblyTool
[ref-data]: https://github.com/dvdvideo1234/PhysPropertiesAdv/tree/master/data
[ref-pmats]: https://github.com/dvdvideo1234/PhysPropertiesAdv/tree/master/data/physprop_adv/materials
[ref-mmats]: https://github.com/dvdvideo1234/PhysPropertiesAdv/tree/master/data/material_adv/materials
[ref-config]: https://github.com/dvdvideo1234/PhysPropertiesAdv/wiki/Adding-configurations
[ref-ws]: https://steamcommunity.com/sharedfiles/filedetails/?id=2011328556
