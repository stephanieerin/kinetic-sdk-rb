require 'digest/md5'

module KineticSdk
  class RequestCe

    # Add an attribute to a team
    #
    # @param team_name [String] the team name
    # @param attribute_name [String] the attribute name
    # @param attribute_value [String] the attribute value
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_team_attribute(team_name, attribute_name, attribute_value, headers=default_headers)
      # first find the team
      response = find_team(team_name, { "include" => "attributes"}, headers)
      team = response.content["team"]
      attributes = team["attributes"]
      # either add or update the attribute value
      exists = false
      attributes.each do |attribute|
        info("Attribute: #{attribute.inspect}")
        # if the attribute already exists, update it
        if attribute["name"] == attribute_name
          attribute["values"] = [ attribute_value ]
          exists = true
        end
      end
      # add the attribute if it didn't exist
      attributes.push({
        "name" => attribute_name,
        "values" => [ attribute_value ]
        }) unless exists

      # set the updated attributes list
      body = { "attributes" => attributes }
      if exists
        info("Updating attribute \"#{attribute_name}\" = \"#{attribute_value}\" in the \"#{team_name}\" team.")
      else
        info("Adding attribute \"#{attribute_name}\" = \"#{attribute_value}\" to the \"#{team_name}\" team.")
      end
      # Update the space
      put("#{@api_url}/teams/#{team['slug']}", body, headers)
    end

    # Add a Team
    #
    # @param team_properties [Hash] the property values for the team
    #   - +name+ - Name of the team to be added
    #   - +description+ - Description of the Team to be added
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_team(team_properties, headers=default_headers)
      raise StandardError.new "Team properties is not valid, must be a Hash." unless team_properties.is_a? Hash
      info("Adding Team \"#{team_properties['name']}\"")
      post("#{@api_url}/teams", team_properties, headers)
    end

    # Add a team membership
    #
    # @param team_name [String] the team name
    # @param username [String] the username to add to the team
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_team_membership(team_name, username, headers=default_headers)
      body = {
        "team" => {
          "name" => team_name
        },
        "user" => {
          "username" => username
        }
      }
      info("Adding user: \"#{username}\" to \"#{team_name}\" team")
      post("#{@api_url}/memberships/", body, headers)
    end

    # Find teams
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_teams(params={}, headers=default_headers)
      info("Finding Teams")
      get("#{@api_url}/teams", params, headers)
    end

    # Export a team
    #
    # @param team_name [String] the team name
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def export_team(team_name, headers=default_headers)
      team_slug = Digest::MD5.hexdigest(team_name)
      info("Exporting the \"#{team_name}\" (#{team_slug}) Team.")
      get("#{@api_url}/teams/#{team_slug}", { 'export' => true}, headers)
    end

    # Find the team
    #
    # Attributes
    #
    # @param team_name [String] the team name
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_team(team_name, params={}, headers=default_headers)
      team_slug = Digest::MD5.hexdigest(team_name)
      info("Finding the \"#{team_name}\" (#{team_slug}) Team.")
      get("#{@api_url}/teams/#{team_slug}", params, headers)
    end

  end
end
