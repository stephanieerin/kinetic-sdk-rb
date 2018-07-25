# GDPR Mask User Driver

Documentation for masking a user given a set of strings in the Kinetic Request CE System.

## Configuration File

* Create a configuration file in the `config` directory for the specific environment.
  * Use the `sample-config.yaml` file as a template.
  * Change the values to correspond to the environment you are working with
    * CE configuration options
      * ce:server - URL of the Kinetic Request CE web application
      * ce:space_admin_credentials:username - username of a space admin user
      * ce:space_admin_credentials:password - password of the space admin user
      * task properties are used with the `-t task`, `-t ce/task`, or `-t all` option flag
        * task:server - URL of the Kinetic Task web application
        * task:credentials:username - username of the task admin user
        * task:credentials:password - password of the task admin user
    * Masking Options
      * strings_to_mask - A list of strings to search for when masking a user
      * user_to_mask - A valid CE user that has created submissions that need to be masked
      * masked_replacement_value - This value will replace any matches found in strings_to_mask

## Run Instructions

Run the export script, passing in the appropriate options.

```bash
# OPTIONS
#
# -s <space_slug>   Slug of the space the masked user exists in
#
# -c <config_file>  Name of the configuration file relative to the `config`
#                   directory.  Note: the value should not be prefixed with
#                   the config/ path.
#
jruby gdpr-cleanup.rb -s <space-slug> -c <config-file.yaml>
```
