# MorphoSource_SF

A generated Hyrax-based MorphoSource application

*Note that this application is intended to run within the [morphosource-vagrant](https://github.com/MorphoSource/morphosource-vagrant) virtual machine*


## Prerequisites (vagrant / virtualbox)

* [Vagrant](https://www.vagrantup.com/) version 1.8.5+

   *You can quickly check to see if you have a suitable version of vagrant installed by running `vagrant -v`*

   *If you don't have vagrant installed, you can [download it](https://www.vagrantup.com/downloads.html) -- it's available for both Mac and Windows, as well as Debian and Centos.*

* [VirtualBox](https://www.virtualbox.org/)

   *Vagrant runs inside of a Virtual Machine (VM) hosted by VirtualBox, which is made by Oracle and is free to [download](https://www.virtualbox.org/wiki/Downloads). They have version for Mac and Windows, as well as Linux and Solaris.*

   *You can quickly check to see if you have VirtualBox installed by running `vboxmanage --version`*


## Setup the Environment


### Vagrant

1. clone the [morphosource-vagrant](https://github.com/morphosource/morphosource-vagrant) repository

   `git clone https://github.com/morphosource/morphosource-vagrant.git`

2. move to the *morphosource-vagrant* folder, then clone the MorphoSource_SF repository

   `cd morphosource-vagrant`

   `git clone https://github.com/MorphoSource/MorphoSource_SF.git`

3. startup vagrant

   `vagrant up`

   *This will run through provisioning the new Virtual Machine. The first time it runs, it will take a while to complete. In the future when you want to startup the dev environment, you'll run the same command but it will startup much more quickly*

   *Vagrant creates a shared folder that you can access both inside the VM and on your workstation. We've found it's best to do your git operations exclusively via the workstation folder.*

   Shell into vagrant box

   `vagrant ssh`


### MorphoSource application

This repo ([MorphoSource_SF](https://github.com/morphosource/MorphoSource_SF)) is included as a submodule in morphosource-vagrant, so the folder and files are there already.

4. Move to the MorphoSource_SF folder

   `cd /vagrant/MorphoSource_SF`

   then checkout the latest code from the MorphoSource_SF repository.
   For dev branch, run the following commands:

    `git checkout dev`

    `git fetch`

    `git pull`

5. Run MorphoSource_SF setup script

   `../install_scripts/morphosource_sf.sh`

6. start the server(s)

    `bin/rails hydra:server`

    *This starts Solr, Fedora, and Rails*


7. Create default admin set

    Open a new ssh session and shell into vagrant:

   `cd morphosource-vagrant`

   `vagrant ssh`

   `cd /vagrant/MorphoSource_SF`

    then run

    `bin/rails hyrax:default_admin_set:create`

    (you can close the session when it's done)


8. The application should now be running at [localhost:3000](http://localhost:3000). You can try to do some things like [creating a new user account](http://localhost:3000/users/sign_up?locale=en) and [depositing an object](http://localhost:3000/concern/works/new?locale=en)

    *Note that if you would like to give your user account admin rights, you'll need to edit the config/role_map.yml file. Create a new role type under the development section at the top named 'admin:' and add the user account you created under it as '- email@address.com'.  After updating the role_map.xml, shutdown and restart the rails server to see the change. *


### Shut down the application

* to shut down the app, stop the rails server by pressing Ctrl-C, logout of vagrant `logout`, and then shutdown the VM `vagrant halt`


### Start up the application

* to startup again, run `vagrant up`, `vagrant ssh`, `cd /vagrant/MorphoSource_SF`, and `bin/rails hydra:server`



## Solr and Fedora

* [SOLR](https://github.com/apache/lucene-solr) should be running on [:8983](http://localhost:8983)
* [Fedora](https://github.com/fcrepo4/fcrepo4) should be running on [:8984](http://localhost:8984)
* Solr and Fedora now run individually (so we don't need to run rake tasks) see [Run the wrappers](https://github.com/samvera/hyrax/wiki/Hyrax-Development-Guide#run-the-wrappers).


## Environment (via morphosource-vagrant)

* Ubuntu 16.04 64-bit base machine
* [Solr 6.6.0](http://lucene.apache.org/solr/): [http://localhost:8983/solr/](http://localhost:8983/solr/)
* [Fedora 4.7.1](http://fedorarepository.org/): [http://localhost:8984/](http://localhost:8984/)
* [Ruby 2.4.2](https://www.ruby-lang.org) (managed by RVM)
* [Rails 5.1.4](http://rubyonrails.org/)
* [Hyrax v2.2.0](http://hyr.ax/)

## Tests

* See further instructions in the [Wiki](https://github.com/MorphoSource/MorphoSource_SF/wiki/Tests)

## References

Instructions are based on the [Samvera Hyrax](https://github.com/samvera/hyrax#creating-a-hyrax-based-app) installation instructions
