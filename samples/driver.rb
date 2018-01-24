##
# This driver file assumes the Kinetic SDK is located in the relative directory:
#   - vendor/kinetic-sdk-rb
##

# Require the Kinetic SDK from the vendor directory
require File.join(File.expand_path(File.dirname(__FILE__)), 'vendor', 'kinetic-sdk-rb', 'kinetic-sdk')

# Instantiate the Kinetic Request CE SDK with a user in the space
request_ce_sdk = KineticSdk::RequestCe.new({
  app_server_url: "https://my-request-ce-server",
  space_slug: "company-name",
  username: "user1@mycompany.com",
  password: "changeme",
  options: {
      log_level: "debug", # off | info | debug | trace
      max_redirects: 3
  }
})
# Retrieve info about the current user
response = request_ce_sdk.me()

### Display results
puts response.content
