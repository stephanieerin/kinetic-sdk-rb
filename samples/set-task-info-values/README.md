# Set Task Info Values Driver

Documentation for Setting Info Values on Task Handlers

## Configuration File

* Create a configuration file in the `config` directory for the specific environment.
  * Use the `sample-config.yaml` file as a template.
  * Change the values to correspond to the environment you are updating
    * task properties for how to connect to the task server
      * task:server - URL of the Kinetic Task web application
      * task:credentials:username - username of the task admin user
      * task:credentials:password - password of the task admin user
    * handlers to update
      * for each type of handler you would like to update, create a yaml object
        named with the same prefix of the handlers you would like to update.
        each type should also list the cooresponding info properties and the Values
        you would like to update.

## Update Instructions

Run the script, passing in the appropriate options.

```bash
# OPTIONS
#
# -p <prefix>       (Optional) If your config file has many handler types configured
#                   and you only want to update handlers of a specific type, you
#                   can pass the prefix used in the config file. If no prefix is set
#                   all handlers defined in the config file will be updated.
#
# -c <config_file>  Name of the configuration file relative to the `config`
#                   directory.  Note: the value should not be prefixed with
#                   the config/ path.
#
jruby export-environment.rb -c <config-file.yaml> -p <handler-type-prefix>
```
