module KineticSdk
  class RequestCe

    # Add a Datastore Submission
    #
    # @param form_slug [String] slug of the Form
    # @param payload [Hash] payload of the submission
    #   - +origin+ - Origin ID of the submission to be added
    #   - +parent+ - Parent ID of the submission to be added
    #   - +values+ - hash of field values for the submission
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_datastore_submission(form_slug, payload={}, headers=default_headers)
      # initialize "values" if nil
      payload["values"] = {} if payload["values"].nil?
      # set origin hash if origin was passed as a string
      payload["origin"] = { "id" => payload["origin"] } if payload["origin"].is_a? String
      # set parent hash if parent was passed as a string
      payload["parent"] = { "id" => payload["parent"] } if payload["parent"].is_a? String
      # Create the submission
      info("Adding a submission in the \"#{form_slug}\" Datastore Form.")
      post("#{@api_url}/datastore/forms/#{form_slug}/submissions", payload, headers)
    end

    # Add a Datastore Submission page
    #
    # @param form_slug [String] slug of the Form
    # @param page_name [String] name of the Page
    # @param payload [Hash] payload of the submission
    #   - +origin+ - Origin ID of the submission to be added
    #   - +parent+ - Parent ID of the submission to be added
    #   - +values+ - hash of field values for the submission
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_datastore_submission_page(form_slug, page_name, payload={}, headers=default_headers)
      # initialize "values" if nil
      payload["values"] = {} if payload["values"].nil?
      # set origin hash if origin was passed as a string
      payload["origin"] = { "id" => payload["origin"] } if payload["origin"].is_a? String
      # set parent hash if parent was passed as a string
      payload["parent"] = { "id" => payload["parent"] } if payload["parent"].is_a? String
      # Create the submission
      info("Adding a submission page in the \"#{form_slug}\" Datastore Form.")
      post("#{@api_url}/datastore/forms/#{form_slug}/submissions?page=#{encode(page_name)}", payload, headers)
    end

    # Patch a new Datastore Submission
    #
    # @param form_slug [String] slug of the Form
    # @param payload [Hash] payload of the submission
    #   - +origin+ - Origin ID of the submission to be patched
    #   - +parent+ - Parent ID of the submission to be patched
    #   - +values+ - hash of field values for the submission
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def patch_datastore_submission(form_slug, payload={}, headers=default_headers)
      # set the currentPage hash if currentPage was passed as a string
      payload["currentPage"] = { "name" => payload["currentPage"] } if payload["currentPage"].is_a? String
      # initialize "values" if nil
      payload["values"] = {} if payload["values"].nil?
      # set origin hash if origin was passed as a string
      payload["origin"] = { "id" => payload["origin"] } if payload["origin"].is_a? String
      # set parent hash if parent was passed as a string
      payload["parent"] = { "id" => payload["parent"] } if payload["parent"].is_a? String
      # Create the submission
      info("Patching a submission in the \"#{form_slug}\" Form.")
      patch("#{@api_url}/datastore/forms/#{form_slug}/submissions", payload, headers)
    end

    # Find all Submissions for a Datastore Form.
    #
    # This method will process pages of form submissions and internally
    # concatenate the results into a single array.
    #
    # Warning - using this method can cause out of memory errors on large
    #           result sets.
    #
    # @param form_slug [String] slug of the Form
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_all_form_datastore_submissions(form_slug, params={}, headers=default_headers)
      info("Finding submissions for the \"#{form_slug}\" Datastore Form.")
      # Make the initial request of pages submissions
      response = find_form_datastore_submissions(form_slug, params, headers)
      # Build the Messages Array
      messages = response.content["messages"]
      # Build Submissions Array
      submissions = response.content["submissions"]
      # if a next page token exists, keep retrieving submissions and add them to the results
      while (!response.content["nextPageToken"].nil?)
        params['pageToken'] = response.content["nextPageToken"]
        response = find_form_datastore_submissions(form_slug, params, headers)
        # concat the messages
        messages.concat(response.content["messages"] || [])
        # concat the submissions
        submissions.concat(response.content["submissions"] || [])
      end
      final_content = { "messages" => messages, "submissions" => submissions, "nextPageToken" => nil }
      # Return the results
      response.content=final_content
      response.content_string=final_content.to_json
      response
    end

    # Find a page of Submissions for a Datastore form.
    #
    # The page offset can be defined by passing in the "pageToken" parameter,
    # indicating the value of the token that will represent the first
    # submission in the result set.  If not provided, the first page of
    # submissions will be retrieved.
    #
    # @param form_slug [String] slug of the Form
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    #   - +pageToken+ - used for paginated results
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_form_datastore_submissions(form_slug, params={}, headers=default_headers)
      # Get next page token
      token = params["pageToken"]
      if token.nil?
        info("Finding first page of submissions for the \"#{form_slug}\" Datastore.")
      else
        info("Finding page of submissions starting with token \"#{token}\" for the \"#{form_slug}\" Form.")
      end

      # Build Submission URL
      url = "#{@api_url}/datastore/forms/#{form_slug}/submissions"
      # Return the response
      get(url, params, headers)
    end


    # Update a Datastore submission
    #
    # @param submission_id [String] String value of the Submission Id (UUID)
    # @param body [Hash] submission properties to update
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_datastore_submission(submission_id, body={}, headers=default_headers)
      info("Updating Datastore Submission \"#{submission_id}\"")
      put("#{@api_url}/datastore/submissions/#{encode(submission_id)}", body, headers)
    end

  end
end
