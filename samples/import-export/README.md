# Import Export Driver

Documentation for Importing and Exporting spaces and space related items.

## Configuration File

* Create a configuration file in the `config` directory for the specific environment.
  * Use the `sample-config.yaml` file as a template.
  * Change the values to correspond to the environment you are exporting
    * ce properties are used with the `-t ce`, `-t ce/task`, or `-t all` option flag
      * ce:server - URL of the Kinetic Request CE web application
      * ce:system_credentials:username - username of the system configuration user
      * ce:system_credentials:password - password of the system configuration user
      * ce:space_admin_credentials:username - username of a space admin user
      * ce:space_admin_credentials:password - password of the space admin user
      * ce:task_source_name - name of the Kinetic Task Source for this space
        (TODO: move this into the task config section)
    * task properties are used with the `-t task`, `-t ce/task`, or `-t all` option flag
      * task:server - URL of the Kinetic Task web application
      * task:credentials:username - username of the task admin user
      * task:credentials:password - password of the task admin user

## Export Instructions

Run the export script, passing in the appropriate options. An `exports` directory
will first be created if it doesn't already exist, and then a directory with the
specified `space_slug` value will be created for the exported definitions.

```bash
# OPTIONS
#
# -s <space_slug>   Slug of the space being exported. Required even if only
#                   exporting task because a directory will be created with
#                   this value.
#
# -c <config_file>  Name of the configuration file relative to the `config`
#                   directory.  Note: the value should not be prefixed with
#                   the config/ path.
#
# -t <export_type>  What type of definitions are being exported:
#                     ce   - Kinetic Request CE space defs only.
#                     task - Kinetic Task defs only.
#                     all  - both Kinetic Request CE and Kinetic Task defs.
#
jruby export-environment.rb -s <space-slug> -c <config-file.yaml> -t <export-type>
```

## Import Instructions

Run the import script, passing in the appropriate options.

```bash
# OPTIONS
#
# -e <export_slug>  Slug of a previously exported space. This value must
#                   correspond to a directory in the `exports` directory.
#
# -s <space_slug>   Slug of the space being imported.
#
# -n <space_name>   Name of the space being created.
#
# -c <config_file>  Name of the configuration file relative to the `config`
#                   directory.  Note: the value should not be prefixed with
#                   the config/ path.
#
# -t <import_type>  What type of definitions are being imported:
#                     ce   - Kinetic Request CE space defs only.
#                     task - Kinetic Task defs only.
#                     ce/task - both Kinetic Request CE and Kinetic Task defs.
#                     all  - Kinetic Request CE and Kinetic Task defs, also
#                            configure Kinetic Bridgehub and Kinetic Filehub.
#
jruby import-environment.rb -e <export-slug> -s <space-slug> -c <config-file.yaml> -t <import-type>
```
