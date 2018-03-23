# Getting Started with Kinetic SDK

This is a guide for getting up and running quickly with the Kinetic SDK.

## About

The Kinetic SDK is a library that provides easy to use methods for interacting with the REST API built into Kinetic Data applications. The intention is for the end user to create a Ruby program/script, and include the Kinetic SDK into the program. This guide shows how to do that.

## How To

This document assumes you have the necessary [requirements](../README.md) installed on your client computer before proceeding.

This guide also assumes you have the `git` program installed on your client machine in order to obtain the latest kinetic-sdk-rb code from Github.

If you do not have git and don't want to install it, you can download a zip file of the [latest Kinetic SDK code](https://github.com/kineticdata/kinetic-sdk-rb/archive/master.zip). You would then unzip this file, and copy the extracted `kinetic-sdk-rb-master` directory to the `my_project/vendor/kinetic-sdk-rb` directory.

### Prepare a Ruby program

Prepare your Ruby program/script to use the Kinetic SDK.

```bash
# create the project directory

mkdir my_project

# clone the kinetic-sdk-rb repository from GitHub
# see above to download the zip file if you don't have the git client

git clone https://github.com/kineticdata/kinetic-sdk-rb.git my_project/vendor/kinetic-sdk-rb

# copy the sample driver to your project's root directory

cp my_project/vendor/kinetic-sdk-rb/samples/driver/driver.rb my_project/driver.rb
```

### Try the driver

Modify the sample driver program with your Kinetic Request CE (or other Kinetic Application) information, and try it out.

```bash
# make sure to change back to the project root directory

cd my_project

# run the driver file

ruby driver.rb
```

### Inline documentation

If you would like to generate the inline documentation for this SDK, perform the following steps.

```bash
# install the bundler gem, and then then necessary documenation gems
cd my_project/vendor/kinetic-sdk-rb
gem install bundler
bundle install

# generate and open the inline Ruby documentation for the SDK

bundle exec rake doc
open rdoc/index.html
```
