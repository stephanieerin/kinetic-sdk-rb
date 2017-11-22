require 'yard'

desc "Generate Documentation"
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', '-', 'REQUIREMENTS.md']
  t.options = ['--title=Kinetic SDK', '--readme=README.md']
  t.stats_options = ['--list-undoc']
end

# Generate the Yard documentation
task :default => [:yard]
