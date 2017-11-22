module KineticSdk
  class RequestCe

    # Create a Submission
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param form_slug [String] slug of the Form
    # @param payload [Hash] payload of the submission
    #   - +origin+ - Origin ID of the submission to be created
    #   - +parent+ - Parent ID of the submission to be created
    #   - +values+ - hash of field values for the submission
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_submission(kapp_slug, form_slug, payload={}, headers=default_headers)
      # initialize "values" if nil
      payload["values"] = {} if payload["values"].nil?
      # set origin hash if origin was passed as a string
      payload["origin"] = { "id" => payload["origin"] } if payload["origin"].is_a? String
      # set parent hash if parent was passed as a string
      payload["parent"] = { "id" => payload["parent"] } if payload["parent"].is_a? String
      # Create the submission
      puts "Creating a submission in the \"#{form_slug}\" Form."
      post("#{@api_url}/kapps/#{kapp_slug}/forms/#{form_slug}/submissions", payload, headers)
    end

    # Patch a new Submission
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param form_slug [String] slug of the Form
    # @param payload [Hash] payload of the submission
    #   - +origin+ - Origin ID of the submission to be created
    #   - +parent+ - Parent ID of the submission to be created
    #   - +values+ - hash of field values for the submission
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def patch_submission(kapp_slug, form_slug, payload={}, headers=default_headers)
      # set the currentPage hash if currentPage was passed as a string
      payload["currentPage"] = { "name" => payload["currentPage"] } if payload["currentPage"].is_a? String
      # initialize "values" if nil
      payload["values"] = {} if payload["values"].nil?
      # set origin hash if origin was passed as a string
      payload["origin"] = { "id" => payload["origin"] } if payload["origin"].is_a? String
      # set parent hash if parent was passed as a string
      payload["parent"] = { "id" => payload["parent"] } if payload["parent"].is_a? String
      # Create the submission
      puts "Patching a submission in the \"#{form_slug}\" Form."
      patch("#{@api_url}/kapps/#{kapp_slug}/forms/#{form_slug}/submissions", payload, headers)
    end

    # Retrieve all Submissions for a form.
    #
    # This method will process pages of form submissions and internally
    # concatenate the results into a single array.
    #
    # Warning - using this method can cause out of memory errors on large
    #           result sets.
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param form_slug [String] slug of the Form
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_all_form_submissions(kapp_slug, form_slug, params={}, headers=default_headers)
      puts "Retrieving submission for the \"#{form_slug}\" Form."
      # Make the initial request of pages submissions
      response = retrieve_form_submissions(kapp_slug, form_slug, params, headers)
      # Build the Messages Array
      messages = response["messages"]
      # Build Submissions Array
      submissions = response["submissions"]
      # if a next page token exists, keep retrieving submissions and add them to the results
      while (!response["nextPageToken"].nil?)
        params['pageToken'] = response["nextPageToken"]
        response = retrieve_form_submissions(kapp_slug, form_slug, params, headers)
        # concat the messages
        messages.concat(response["messages"])
        # concat the submissions
        submissions.concat(response["submissions"])
      end
      # Return the results
      { "messages" => messages, "submissions" => submissions, "nextPageToken" => nil }
    end

    # Retrieve a page of Submissions for a form.
    #
    # The page offset can be defined by passing in the "pageToken" parameter,
    # indicating the value of the token that will represent the first
    # submission in the result set.  If not provided, the first page of
    # submissions will be retrieved.
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param form_slug [String] slug of the Form
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    #   - +pageToken+ - used for paginated results
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_form_submissions(kapp_slug, form_slug, params={}, headers=default_headers)
      # Get next page token
      token = params["pageToken"]
      if token.nil?
        puts "Retrieving first page of submissions for the \"#{form_slug}\" Form."
      else
        puts "Retrieving page of submissions starting with token \"#{token}\" for the \"#{form_slug}\" Form."
      end

      # Build Submission URL
      url = "/kapps/#{kapp_slug}/forms/#{form_slug}/submissions"
      # Return parsed response
      JSON.parse(get(url, params, headers))
    end

    # Retrieve a page of Submissions for a kapp.
    #
    # The page offset can be defined by passing in the "pageToken" parameter,
    # indicating the value of the token that will represent the first
    # submission in the result set.  If not provided, the first page of
    # submissions will be retrieved.
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    #   - +pageToken+ - used for paginated results
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_kapp_submissions(kapp_slug, params={}, headers=default_headers)
      # Get next page token
      token = params["pageToken"]
      if token.nil?
        puts "Retrieving first page of submissions for the \"#{kapp_slug}\" Kapp."
      else
        puts "Retrieving page of submissions starting with token \"#{token}\" for the \"#{kapp_slug}\" Kapp."
      end

      # Build Submission URL
      url = "/kapps/#{kapp_slug}/submissions"
      # Return parsed response
      JSON.parse(get(url, params, headers))
    end

    # Update a submission
    #
    # @param submission_id [String] String value of the Submission Id (UUID)
    # @param body [Hash] submission properties to update
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_submission(submission_id, body={}, headers=default_headers)
      puts "Updating Submission \"#{submission_id}\""
      put("#{@api_url}/submissions/#{url_encode(submission_id)}", body, headers)
    end

  end
end
