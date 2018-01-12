require 'json'
require 'yaml'

pwd = File.dirname(File.expand_path(__FILE__))

# require version
require File.join(pwd, 'kinetic-sdk', 'version')
# require utilities
require File.join(pwd, 'kinetic-sdk', 'utils',  'logger')
require File.join(pwd, 'kinetic-sdk', 'utils',  'kinetic-http')
# require applications
require File.join(pwd, 'kinetic-sdk', 'bridgehub',  'bridgehub-sdk')
require File.join(pwd, 'kinetic-sdk', 'filehub',    'filehub-sdk')
require File.join(pwd, 'kinetic-sdk', 'request-ce', 'request-ce-sdk')
require File.join(pwd, 'kinetic-sdk', 'task',       'task-sdk')
