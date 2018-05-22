# Ruby SDK for Kinetic Data application APIs

This library allows access to Kinetic Data application APIs from Ruby without having to write explicit HTTP requests.

## About

The Kinetic Ruby SDK is a library that consists of and SDK for each supported Kinetic Data application, and a helper HTTP library to make the HTTP requests.

### Supported Applications

The following Kinetic Data applications are supported in this SDK library:

* Kinetic Request CE 1.0.4+
* Kinetic Task 4.0+
* Kinetic Bridgehub 1.0+
* Kinetic Filehub 1.0+

## Getting Started

See the [Getting Started Guide](docs/GettingStarted.md) for getting started quickly.

## Requirements

The following are a list of requirements to use this SDK

### Ruby

The Kinetic Ruby SDK requires Ruby 2.0+, which includes JRuby 9000+. You can determine the version of Ruby you are using with the following command:

```bash
ruby -v
```

### Included Dependency Gems

The Kinetic Ruby SDK uses the following gems, which are conveniently packaged in the SDK. You do not need to install these gems to the default gem path.

* [mime-types](https://github.com/mime-types/ruby-mime-types) used by the multipart-post gem.
* [mime-types-data](https://github.com/mime-types/mime-types-data) used by the multipart-post gem.
* [multipart-post](https://github.com/nicksieger/multipart-post) for uploading files to the application REST APIs.
* [parallel](https://github.com/grosser/parallel) used in some of the samples for importing data in parallel threads.
* [ruby-progressbar](https://github.com/jfelchner/ruby-progressbar) used by parallel gem to indicate progress.
* [slugify](https://github.com/Slicertje/Slugify) for converting names to slugs.

## Usage

Each Kinetic Data application SDK is meant to be used independent of other application SDKs. With this in mind, each application SDK must be initialized individually.

All of the HTTP methods return a KineticSdk::Utils::KineticHttpResponse object that contains additional methods to obtain information about the request status, the reponse body content, the response headers, and access to the raw response object.

### Require the SDK

```ruby
# Assumes the SDK is installed to vendor/kinetic-sdk-rb
require File.join(File.expand_path(File.dirname(__FILE__)), 'vendor', 'kinetic-sdk-rb', 'kinetic-sdk')
```

### Kinetic BridgeHub SDK example

```ruby
bridgehub_sdk = KineticSdk::Bridgehub.new({
  app_server_url: "http://localhost:8080/kinetic-bridgehub",
  username: "configuration-user",
  password: "password",
  options: {
    log_level: "info",
    max_redirects: 3
  }
})
response = bridgehub_sdk.find_bridges()
bridges = response.content['bridges']

puts response.code            # String value of HTTP response code ("200", "400", "500", etc...)
puts response.status          # Ruby Fixnum value of response.code (200, 400, 500, etc...)
puts response.content         # Ruby Hash
puts response.content_string  # JSON formatted response body
```

### Kinetic FileHub SDK example

```ruby
filehub_sdk = KineticSdk::Filehub.new({
  app_server_url: "http://localhost:8080/kinetic-filehub",
  username: "configuration-user",
  password: "password",
  options: {
    log_level: "info",
    max_redirects: 3
  }
})
response = filehub_sdk.find_filestores()
filestores = response.content['filestores']

puts response.code            # String value of HTTP response code ("200", "400", "500", etc...)
puts response.status          # Ruby Fixnum value of response.code (200, 400, 500, etc...)
puts response.content         # Ruby Hash
puts response.content_string  # JSON formatted response body
```

### Kinetic Request CE SDK example of a Space User

```ruby
space_sdk = KineticSdk::RequestCe.new({
  app_server_url: "http://localhost:8080/kinetic",
  space_slug: "foo",
  username: "space-user-1",
  password: "password",
  options: {
    log_level: "info",
    max_redirects: 3
  }
})
response = space_sdk.find_kapps()
kapps = response.content['kapps']

puts response.code            # String value of HTTP response code ("200", "400", "500", etc...)
puts response.status          # Ruby Fixnum value of response.code (200, 400, 500, etc...)
puts response.content         # Ruby Hash
puts response.content_string  # JSON formatted response body
```

### Kinetic Request CE SDK example of a System User

```ruby
system_sdk = KineticSdk::RequestCe.new({
  app_server_url: "http://localhost:8080/kinetic",
  username: "configuration-user",
  password: "password",
  options: {
    log_level: "info",
    max_redirects: 3
  }
})
response = system_sdk.add_space('My Company Space', 'my-company')

puts response.code            # String value of HTTP response code ("200", "400", "500", etc...)
puts response.status          # Ruby Fixnum value of response.code (200, 400, 500, etc...)
puts response.content         # Ruby Hash
puts response.content_string  # JSON formatted response body
```

### Kinetic Request CE SDK example of a Subdomain

This example requires a proxy server configured to rewrite the space slug subdomain to the expected Request CE API route.

```ruby
space_sdk = KineticSdk::RequestCe.new({
  space_server_url: "https://foo.myapp.io",
  space_slug: "foo",
  username: "space-user-1",
  password: "password",
  options: {
    log_level: "info",
    max_redirects: 3
  }
})
response = space_sdk.find_kapps()
kapps = response.content['kapps']

puts response.code            # String value of HTTP response code ("200", "400", "500", etc...)
puts response.status          # Ruby Fixnum value of response.code (200, 400, 500, etc...)
puts response.content         # Ruby Hash
puts response.content_string  # JSON formatted response body
```

### Kinetic Task SDK example

```ruby
task_sdk = KineticSdk::Task.new({
  app_server_url: "http://localhost:8080/kinetic-task",
  username: "user-1",
  password: "password",
  options: {
    export_directory: "/opt/exports/task-server-a",
    log_level: "info",
    max_redirects: 3
  }
})
response = task_sdk.environment()

puts response.code            # String value of HTTP response code ("200", "400", "500", etc...)
puts response.status          # Ruby Fixnum value of response.code (200, 400, 500, etc...)
puts response.content         # Ruby Hash
puts response.content_string  # JSON formatted response body
```

## SSL Options

Starting in Kinetic SDK version 0.0.2, server certificate validation is turned off by default.  In version 0.0.1 it was enabled, but this caused problems with self-signed certificates and there was no way to disable it.

In version 0.0.2, there are now two additional options that can be passed when constructing the SDK object.

* `ssl_verify_mode`: allows server certificate validation when the value `peer` is used. (default `none`).
* `ssl_ca_file`: allows specifying the server certificate key file (PEM format). Used when server certificate validation is enabled (`ssl_verify_mode: "peer"`).

May be used with all application SDKs.

**Example 1 using Kinetic Request CE without server certificate validation:**

```ruby
space_sdk = KineticSdk::RequestCe.new({
  ...
  options: {}
})
```

**Example 2 using Kinetic Request CE without server certificate validation:**

```ruby
space_sdk = KineticSdk::RequestCe.new({
  ...
  options: {
    ssl_verify_mode: "none"
  }
})
```

**Example using Kinetic Request CE with server certificate validation and known CAs:**

```ruby
space_sdk = KineticSdk::RequestCe.new({
  ...
  options: {
    ssl_verify_mode: "peer"
  }
})
```

**Example using Kinetic Request CE with server certificate validation and a self-signing CA:**

```ruby
space_sdk = KineticSdk::RequestCe.new({
  ...
  options: {
    ssl_verify_mode: "peer",
    ssl_ca_file: "/path/to/self-signing-ca.pem"
  }
})
```

## Advanced Usage

If you need to make a custom HTTP call for some reason, there is a class that allows you to do that. Simply make sure the KineticSdk is required in your program. See the [Getting Started Guide](docs/GettingStarted.md) for details.

Then you need to instantiate a new instance of the KineticHttp class, and call the desired HTTP method with the appropriate information. Each response will be returned as a KineticSdk::Utils::KineticHttpResponse object.

```ruby
# instantiate the KineticHttp class without authentication
http = KineticSdk::Utils::KineticHttp.new

# instantiate the KineticHttp class with Basic authentication
http = KineticSdk::Utils::KineticHttp.new("john.doe@company.com", "s3cretP@ssw0rd")

# call the appropriate method

# custom HTTP delete
response = http.delete("https://my-server.com", default_headers)

# custom HTTP get
response = http.get(
  "https://my-server.com",
  { foo: 'foo', bar: 'bar' },
  default_headers)

# custom HTTP patch
response = http.patch(
  "https://my-server.com",
  { foo: 'foo', bar: 'bar' },
  default_headers)

# custom HTTP post
response = http.post(
  "https://my-server.com",
  { foo: 'foo', bar: 'bar' },
  { "Custom Header" => "a custom value" }.merge(default_headers))

# custom HTTP post multipart/form-data (for file uploads)
response = http.post_multipart(
  "https://my-server.com",
  { file: File.new('/path/file.txt', 'rb') },
  { "Custom Header" => "a custom value" }.merge(default_headers))

# custom HTTP put
response = http.put(
  "https://my-server.com",
  { foo: 'foo', bar: 'bar' },
  default_headers)
```

## Additional Documentation

The RDoc documentation for the SDK can be generated by running a rake command. This will provide detailed information for each module, class, and method. The output can be found in the generated `rdoc` directory.

In order to do this however, the `yard` gem is required and must first be installed.

This SDK includes a [Gemfile](./Gemfile) that can be used with the `bundler` gem to ensure the proper version is installed.

Install the Bundler gem:

    gem install bundler

_IMPORTANT NOTE_: If using [rbenv](https://github.com/rbenv/rbenv) to manage Ruby versions, run the following command.

    rbenv rehash

Finally, install the dependency gems:

    bundle install

Now that the required documentation generation gem is installed, a simple Rake command can be run to generate the inline documentation. For this SDK, the following commands are all equivalent:

```ruby
bundle exec rake doc
```

```ruby
bundle exec rake yard
```

```ruby
bundle exec rake
```
