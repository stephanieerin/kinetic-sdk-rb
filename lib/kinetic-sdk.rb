require 'json'
require 'yaml'

pwd = File.expand_path(File.dirname(__FILE__))
gemdir = File.expand_path(File.join(pwd, '..', 'gems'))

# add gem directories to load path
$:.unshift File.join(gemdir, 'mime-types-3.1', 'lib')
$:.unshift File.join(gemdir, 'mime-types-data-3.2016.0521', 'lib')
$:.unshift File.join(gemdir, 'multipart-post-2.0.0', 'lib')
$:.unshift File.join(gemdir, 'parallel-1.12.1', 'lib')
$:.unshift File.join(gemdir, 'ruby-progressbar-1.9.0', 'lib')
$:.unshift File.join(gemdir, 'slugify-1.0.7', 'lib')

require 'parallel'
require 'slugify'

# require version
require File.join(pwd, 'kinetic-sdk', 'version')
# require utilities
require File.join(pwd, 'kinetic-sdk', 'utils',  'logger')
require File.join(pwd, 'kinetic-sdk', 'utils',  'random')
require File.join(pwd, 'kinetic-sdk', 'utils',  'kinetic-http')
# require applications
require File.join(pwd, 'kinetic-sdk', 'bridgehub',  'bridgehub-sdk')
require File.join(pwd, 'kinetic-sdk', 'filehub',    'filehub-sdk')
require File.join(pwd, 'kinetic-sdk', 'request-ce', 'request-ce-sdk')
require File.join(pwd, 'kinetic-sdk', 'task',       'task-sdk')
