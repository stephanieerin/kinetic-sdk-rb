module KineticSdk
  class Task

    # Test the database connection
    #
    # @param db [Hash] Database configuration seettings to send as the request body
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     {
    #       "type": "PostgreSQL",
    #       "properties": {
    #         "host": "mydbserver.company.com",
    #         "port": "5432",
    #         "database": "kinetictask",
    #         "username": "TaskUser",
    #         "password": "TaskPassword1"
    #       }
    #     }
    #
    def test_db_connection(db={}, headers=default_headers)
      puts "Testing database connection"
      response = post("#{@api_url}/setup/db/test", db, headers)
      response.body
    end


    # Run the database migrations
    #
    # @param db [Hash] Database configuration seettings to send as the request body
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    # 
    #     {
    #       "type": "PostgreSQL",
    #       "properties": {
    #         "host": "mydbserver.company.com",
    #         "port": "5432",
    #         "database": "kinetictask",
    #         "username": "TaskUser",
    #         "password": "TaskPassword1"
    #       }
    #     }
    #
    def migrate_db(db={}, headers=default_headers)
      puts "Running database migrations"
      response = post("#{@api_url}/setup/db/migrate", db, headers)
      response.body
    end

  end
end
