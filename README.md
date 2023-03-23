# MorphoSource_SF 

MorphoSource is a digital repository for 3D, 2D, and AV media content representing physical objects of scholarly relevance, with specific support for biological specimen objects, built from and on top of [Hyrax 2.9](https://github.com/samvera/hyrax). 

## Technical stack

The primary elements of the technical stack are as follows. Version numbers reflect the current Docker deployment environment, and may differ slightly in other environments.

* Ruby on Rails web application ([Ruby 2.6](https://www.ruby-lang.org/en/), [Rails 5.2.8](https://rubyonrails.org/)): Customized Hyrax 2.9 digital repository application. Connects to FCRepo, Solr, and application-specific Postgres DB for application state information.
* [Fedora (FCRepo) 4.7.5](https://github.com/fcrepo/fcrepo/tree/fcrepo-4.7.5): Preservation and storage layer for binary files and primary record metadata. In production and docker environments, primary record metadata is stored using an FCRepo-managed Postgres DB distinct from the application DB.
* [Solr 7.7.3](https://solr.apache.org/): Indexes important record data for fast querying to enable browsing, searching, and filtering hundreds of thousands of records.
* [Postgres](https://www.postgresql.org/): Used by both Rails web app and FCRepo.
* [Universal Viewer](https://universalviewer.io/) & [Aleph](https://github.com/aleph-viewer/aleph): Web viewer framework and extensions to enable viewing of web preview assets for 3D models, CT/MRI volume data, 2D images, and video files.
* [Blacklight Catalog Framework](https://projectblacklight.org/): Used for browsing, searching, and filtering records in application front-end.

**Note:** The Docker implementation of Solr that we use is **not** affected by the recent log4j security vulnerability. While version 7.7.3 of Solr is in the range of Solr versions that can be affected by the vulnerability, the specific Docker implementation successfully mitigates the vulnerability with correct JVM settings as verified by security experts and the Apache Solr team.

There is also a raft of other third-party applications used behind the scenes to process uploaded binary files, automatically characterize file-level metadata from them, and to generate web preview derivative assets for them. For some of these (3D models and CT/MRI volumes in particular), there are no industry-standard tools to generate previews, and MorphoSource generates these preview assets using original workflows that sometimes involve multiple third-party tools. 

* FITS 1.3.0: Characterizes file-level metadata for a wide variety of files. 
* ImageMagick: Characterizes 2D images and produces thumbnails for preview assets.
* Blender 2.8: Used to work with 3D meshes, both to characterize and to assist in generating preview assets.
* FIJI 2.3.0: Used to work with CT/MRI image stacks to assist in generating previews.
* DICOM Toolkit: Various tools used to process CT/MRI image stacks for generating previews. 
* Python 3, numpy, Pillow, pydicom: Python and relevant modules used for CT/MRI processing scripts.
* gltf-pipeline: Tool to compress generated preview GLTF files using Draco compression, reducing filesize.

## Installing and deploying MorphoSource

The straightforward full-featured way to install and deploy MorphoSource is a containerized approach that uses Docker Compose to stand up a handful of containers comprising the entire technical stack. See [CONTAINERS.md](https://github.com/MorphoSource/MorphoSource_SF/blob/main/CONTAINERS.md) for more details. This is the approach recommended for any future instances of MorphoSource.

There is also a more outdated approach using a [Vagrant virtual machine](https://github.com/MorphoSource/MorphoSource_SF/blob/main/VAGRANT.md). Historically, our developers used this for deploying individual development environments. But at this point, all of our devs have shifted to using Docker, and we would not suggest continuing to use Vagrant unless there are very good reasons to do so.

Currently (as of November 2022), we deploy MorphoSource to production on Duke OIT VMs using a collection of Ansible scripts to prepare the server VM, install prerequisites, and install and set up the technical stack as well as the Rails application itself. This represents a third possible way of deploying MorphoSource, though it's by far the most complex and most dependent on specific server and network policies (and so would probably require modification if it were, for example, being applied in another university's IT environment). These scripts are available in the separate [morphosource-ansible](https://github.com/MorphoSource/morphosource-ansible) repository. In the future we plan to move to a simpler devOps environment where we use Ansible to deploy the Docker containerized version of the application. If you are interested in using Ansible here, we would recommend contacting our team for a meeting to discuss the pros and cons and so we can share tips and suggestions.

## Useful Links

* [MorphoSource Technical Documentation](https://github.com/MorphoSource/docs/wiki): Helpful documentation pertaining to technical administration of a MorphoSource repository. The base page is the "MorphoSource Management Guide (Or, The Care And Feeding Of The MorphoSource Application)," but the subsidiary pages in the wiki also contain much useful information.
* [MorphoSource container environment documentation](https://github.com/MorphoSource/MorphoSource_SF/blob/main/CONTAINERS.md)
* [General-purpose Documentation](https://wiki.duke.edu/display/MD/MorphoSource+Documentation+Home): This is a set of documentation directed toward end users that explains how to use the MorphoSource repository from a user-facing perspective.
* [REST API schema and documentation](https://morphosource.stoplight.io/docs/morphosource-api/rm6bqdolcidct-morpho-source-rest-api): Lists and examples of current query API routes. All of this information is encoded using OpenAPI 3.1.0 and is also [available on GitHub](https://github.com/MorphoSource/morphosource-api).
* [Hyrax GitHub Repository](https://github.com/samvera/hyrax): It can sometimes be helpful to look at some of the documentation relating to Hyrax, since it is the foundation on which MorphoSource runs. But there are many differences between vanilla Hyrax and MorphoSource, so caveat lector!
