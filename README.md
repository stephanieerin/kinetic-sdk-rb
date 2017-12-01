# Ruby SDK for Kinetic Data application APIs

This is a wrapper library to access Kinetic Data application APIs from Ruby without having to make explicit HTTP requests.

## Requirements

See the [REQUIREMENTS](/REQUIREMENTS.md) document for a list of requirements to use this library.

## Kinetic Data Applications

- Kinetic Request CE 1.0.4+
- Kinetic Task 4.0+
- Kinetic Bridgehub 1.0+
- Kinetic Filehub 1.0+

## About

To use the SDK library, simply require the kinetic-sdk.rb file in your application:

```ruby
require 'kinetic-sdk-rb/kinetic-sdk'
```

## Usage

Each application SDK is meant to be used independent of the other applications. With this in mind, each application SDK must be initialized individually.

- Kinetic BridgeHub SDK example:

```ruby
bridgehub_sdk = KineticSdk::Bridgehub.new({
  app_server_url: "http://localhost:8080/kinetic-bridgehub",
  login: "configuration-user",
  password: "password",
  options: {
    log_level: "debug"
  }
})
bridgehub_sdk.method_foo()
```

- Kinetic FileHub SDK example:

```ruby
filehub_sdk = KineticSdk::Filehub.new({
  app_server_url: "http://localhost:8080/kinetic-filehub",
  login: "configuration-user",
  password: "password",
  options: {
    log_level: "debug"
  }
})
filehub_sdk.method_foo()
```

- Kinetic Request CE SDK example of a Space User:

```ruby
space_sdk = KineticSdk::RequestCe.new({
  app_server_url: "http://localhost:8080/kinetic",
  space_slug: "foo",
  login: "space-user-1",
  password: "password",
  options: {
    log_level: "debug"
  }
})
space_sdk.method_foo()
```

- Kinetic Request CE SDK example of a System User:

```ruby
system_sdk = KineticSdk::RequestCe.new({
  app_server_url: "http://localhost:8080/kinetic",
  login: "configuration-user",
  password: "password",
  options: {
    log_level: "debug"
  }
})
system_sdk.method_foo()
```

- Kinetic Task SDK example:

```ruby
task_sdk = KineticSdk::Task.new({
  app_server_url: "http://localhost:8080/kinetic-task",
  login: "user-1",
  password: "password",
  options: {
    log_level: "debug",
    export_directory: "/opt/exports/task-server-a"
  }
})
task_sdk.method_foo()
```

## Additional Documentation

The RDoc documentation can be generated RDoc by running the rake command.  This will provide detailed information for each module, class, and method.  The output can be found in the generated `doc` directory.

```ruby
bundle exec rake yard
```
