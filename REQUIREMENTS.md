# Requirements

Requirements to use the Kinetic SDK for Ruby.

## Ruby 2.0+

The Ruby SDK requires Ruby 2.0+, which includes JRuby 9000+.  You can determine the version of Ruby you are using with the following command:

```bash
ruby -v
```

## Dependency Gems

The Kinetic SDK for Ruby uses the following gems:

- [Rest Client](https://github.com/rest-client/rest-client) for making HTTP calls to the application REST APIs.
- [Slugify](https://github.com/Slicertje/Slugify) for generating slugs.

For a complete list of required dependency gems, take a look at [Gemfile](./Gemfile) found in the root directory of the SDK.

## Bundler Gem

A [Gemfile](./Gemfile) is provided to automatically install the required gems using bundler.  This first requires that the bundler gem is installed.  Once bundler is installed, simply run the `bundle install` command.

Install the Bundler gem:

    gem install bundler:1.16.0

*IMPORTANT NOTE*: If using [rbenv](https://github.com/rbenv/rbenv) to manage Ruby versions, run the following command.

    rbenv rehash

Finally, install the dependency gems:

    bundle install
