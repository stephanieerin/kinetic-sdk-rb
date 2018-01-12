# Getting Started with Kinetic SDK

This is a guide for getting up and running quickly with the Kinetic SDK.

## About

The Kinetic SDK is a library that provides easy to use methods for interacting with the REST API built into Kinetic Data applications.  The intention is for the end user to create a Ruby program/script, and include the Kinetic SDK into the program.  This guide shows how to do that.

## How To

This document assumes you the necessary [requirements](../README.md#requirements) installed on your client computer before proceeding.

This guide assumes you have the `git` program installed on your client machine.  If not, you can download a zip file of the [latest Kinetic SDK package](https://github.com/kineticdata/kinetic-sdk-rb/archive/master.zip).  You would then unzip this file, and copy the extracted `kinetic-sdk-rb-master` directory to the `my_project/vendor/kinetic-sdk-rb` directory.

### Prepare a Ruby program

Prepare your Ruby program/script to use the Kinetic SDK.

```bash
# create the project directory, and a vendor directory within the project directory

mkdir my_project
mkdir my_project/vendor

# clone the kinetic-sdk-rb repository from GitHub
# see above to download the zip file if you don't have the git client

git clone https://github.com/kineticdata/kinetic-sdk-rb.git my_project/vendor

# copy the sample driver

cp my_project/vendor/kinetic-sdk-rb/samples/driver.rb my_project/driver.rb

# install the required Ruby gems

cd my_project/vendor/kinetic-sdk-rb
gem install bundler
bundle install

# generate and open the inline Ruby documentation for the SDK

bundle exec rake doc
open rdoc/index.html
```

### Try the driver

Modify the sample driver program with your Kinetic Request CE (or other Kinetic Application), and try it out.

```bash
# make sure to change back to the project root directory

cd my_project

# run the driver file

ruby driver.rb
```
