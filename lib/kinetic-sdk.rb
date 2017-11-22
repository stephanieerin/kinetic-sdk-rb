require 'json'
require 'yaml'

pwd = File.dirname(File.expand_path(__FILE__))

Dir[File.join(pwd, 'kinetic-sdk', '*.rb')].each {|file| require file }

# require applications
require File.join(pwd, 'kinetic-sdk', 'bridgehub',  'bridgehub-sdk')
require File.join(pwd, 'kinetic-sdk', 'filehub',    'filehub-sdk')
require File.join(pwd, 'kinetic-sdk', 'request-ce', 'request-ce-sdk')
require File.join(pwd, 'kinetic-sdk', 'task',       'task-sdk')
