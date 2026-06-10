# Developing MorphoSource

MorphoSource is a digital repository for 3D, 2D, and AV media content representing physical objects of scholarly relevance, with specific support for biological specimen objects, built from and on top of [Hyrax 5](https://github.com/samvera/hyrax).

## Technical stack

The primary elements of the technical stack are as follows. Version numbers reflect the current Docker deployment environment, and may differ slightly in other environments.

* Ruby on Rails web application ([Ruby 3.3.6](https://www.ruby-lang.org/en/), [Rails 6.1](https://rubyonrails.org/)): Customized Hyrax 5.0.5 digital repository application. Connects to FCRepo, Solr, and application-specific Postgres DB for application state information.
* [Fedora (FCRepo) 4.7.5](https://github.com/fcrepo/fcrepo/tree/fcrepo-4.7.5): Preservation and storage layer for binary files and primary record metadata. In production and docker environments, primary record metadata is stored using an FCRepo-managed Postgres DB distinct from the application DB.
* [Solr 8.11.2](https://solr.apache.org/): Indexes important record data for fast querying to enable browsing, searching, and filtering hundreds of thousands of records.
* [Postgres 16.9](https://www.postgresql.org/): Used by both Rails web app and FCRepo.
* [Universal Viewer](https://universalviewer.io/) & [aleph-r3f](https://github.com/aleph-viewer/aleph-r3f): Web viewer framework and extensions to enable viewing of web preview assets for 3D models, CT/MRI volume data, 2D images, and video files.
* [Blacklight Catalog Framework](https://projectblacklight.org/): Used for browsing, searching, and filtering records in application front-end.

There are also third-party applications used behind the scenes to process uploaded binary files, automatically characterize file-level metadata from them, and to generate web preview derivative assets for them. For some of these (3D models and CT/MRI volumes in particular), there are no industry-standard tools to generate previews, and MorphoSource generates these preview assets using original workflows that sometimes involve multiple third-party tools.

* FITS 1.5.5: Characterizes file-level metadata for a wide variety of files.
* ImageMagick: Characterizes 2D images and produces thumbnails for preview assets.
* Blender 2.8: Used to work with 3D meshes, both to characterize and to assist in generating preview assets.
* FIJI 2.11.0: Used to work with CT/MRI image stacks to assist in generating previews.
* DICOM Toolkit: Various tools used to process CT/MRI image stacks for generating previews.
* Python 3, numpy, Pillow, pydicom: Python and relevant modules used for CT/MRI processing scripts.
* gltf-pipeline: Tool to compress generated preview GLTF files using Draco compression, reducing filesize.

## Dploying MorphoSource

The best way to deploy MorphoSource is a containerized approach that uses Docker Compose. See [CONTAINERS.md](https://github.com/MorphoSource/MorphoSource_SF/blob/main/CONTAINERS.md) for more details.

For our production instance, we use a Helm Chart to deploy to a Kubernetes cluster. Reach out to us if you're interested in this.

## Useful Links

* [MorphoSource Technical Documentation](https://github.com/MorphoSource/docs/wiki): Helpful documentation pertaining to technical administration of a MorphoSource repository. The base page is the "MorphoSource Management Guide (Or, The Care And Feeding Of The MorphoSource Application)," but the subsidiary pages in the wiki also contain much useful information.
* [MorphoSource container environment documentation](https://github.com/MorphoSource/MorphoSource_SF/blob/main/CONTAINERS.md)
* [General-purpose Documentation](https://duke.atlassian.net/wiki/spaces/MD/overview): This is a set of documentation directed toward end users that explains how to use the MorphoSource repository from a user-facing perspective.
* [REST API schema and documentation](https://morphosource.stoplight.io/docs/morphosource-api/rm6bqdolcidct-morpho-source-rest-api): Lists and examples of current query API routes. All of this information is encoded using OpenAPI 3.1.0 and is also [available on GitHub](https://github.com/MorphoSource/morphosource-api).
* [Hyrax GitHub Repository](https://github.com/samvera/hyrax): It can sometimes be helpful to look at some of the documentation relating to Hyrax, since it is the foundation on which MorphoSource runs. But there are many differences between vanilla Hyrax and MorphoSource, so caveat lector!
