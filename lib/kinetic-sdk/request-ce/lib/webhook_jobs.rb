module KineticSdk
  class RequestCe

    # Find space webhook jobs
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +status+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_space_webhook_jobs(params={}, headers=default_headers)
      info("Finding webhook jobs in the Space")
      get("#{@api_url}/webhookJobs", params, headers)
    end

    # Find all Webhook Jobs for a space.
    #
    # This method will process pages of jobs and internally
    # concatenate the results into a single array.
    #
    # Warning - using this method can cause out of memory errors on large
    #           result sets.
    #
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +status+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_all_space_webhook_jobs(params={}, headers=default_headers)
      # Make the initial request of pages jobs
      response = find_space_webhook_jobs(params, headers)
      # Build Submissions Array
      jobs = response.content["webhookJobs"]
      # if a next page token exists, keep retrieving jobs and add them to the results
      while (!response.content["nextPageToken"].nil?)
        params['pageToken'] = response.content["nextPageToken"]
        response = find_space_webhook_jobs(params, headers)
        # concat the jobs
        jobs.concat(response.content["webhookJobs"] || [])
      end
      final_content = {"webhookJobs" => jobs, "nextPageToken" => nil }
      # Return the results
      response.content=final_content
      response.content_string=final_content.to_json
      response
    end

    # Find kapp webhook jobs
    #
    # @param kapp_slug [String] the Kapp slug
    # @param params [Hash] Query parameters that are added to the URL, such as +status+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_kapp_webhook_jobs(kapp_slug, params={}, headers=default_headers)
      info("Finding webhook jobs in the \"#{kapp_slug}\" Kapp")
      get("#{@api_url}/kapps/#{kapp_slug}/webhookJobs", params, headers)
    end

    # Find all Webhook Jobs for a kapp.
    #
    # This method will process pages of jobs and internally
    # concatenate the results into a single array.
    #
    # Warning - using this method can cause out of memory errors on large
    #           result sets.
    #
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +status+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_all_kapp_webhook_jobs(kapp_slug, params={}, headers=default_headers)
      # Make the initial request of pages jobs
      response = find_kapp_webhook_jobs(kapp_slug, params, headers)
      # Build Submissions Array
      jobs = response.content["webhookJobs"]
      # if a next page token exists, keep retrieving jobs and add them to the results
      while (!response.content["nextPageToken"].nil?)
        params['pageToken'] = response.content["nextPageToken"]
        response = find_kapp_webhook_jobs(kapp_slug, params, headers)
        # concat the jobs
        jobs.concat(response.content["webhookJobs"] || [])
      end
      final_content = {"webhookJobs" => jobs, "nextPageToken" => nil }
      # Return the results
      response.content=final_content
      response.content_string=final_content.to_json
      response
    end

    # Update space webhook job
    #
    # @param job_id [String] id of the Job
    # @param job_properties [Hash] Query parameters that are added to the URL, such as +status+
    #   - +event+ -  "Complete",
    #   - +id+ -  "00000000-0000-1000-8000-000000000000",
    #   - +name+ -  "Foo",
    #   - +parentId+ -  "00000000-0000-1000-8000-000000000000",
    #   - +requestContent+ -  null,
    #   - +responseContent+ -  null,
    #   - +retryCount+ -  0,
    #   - +scheduledAt+ -  "2016-04-20T12:00:00Z",
    #   - +scopeId+ -  "00000000-0000-1000-8000-000000000000",
    #   - +scopeType+ -  "Kapp",
    #   - +status+ -  "Queued",
    #   - +summary+ -  null,
    #   - +type+ -  "Submission",
    #   - +url+ -  "http://my.server.com/api",
    #   - +webhookId+ -  "00000000-0000-1000-8000-000000000000"
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_space_webhook_job(job_id, job_properties={}, headers=default_headers)
      info("Updating the webhook job #{job_id} in Space")
      put("#{@api_url}/webhookJobs/#{job_id}", job_properties, headers)
    end


    # Update kapp webhook job
    #
    # @param kapp_slug [String] the Kapp slug
    # @param job_id [String] id of the Job
    # @param job_properties [Hash] Query parameters that are added to the URL, such as +status+
    #   - +event+ -  "Complete",
    #   - +id+ -  "00000000-0000-1000-8000-000000000000",
    #   - +name+ -  "Foo",
    #   - +parentId+ -  "00000000-0000-1000-8000-000000000000",
    #   - +requestContent+ -  null,
    #   - +responseContent+ -  null,
    #   - +retryCount+ -  0,
    #   - +scheduledAt+ -  "2016-04-20T12:00:00Z",
    #   - +scopeId+ -  "00000000-0000-1000-8000-000000000000",
    #   - +scopeType+ -  "Kapp",
    #   - +status+ -  "Queued",
    #   - +summary+ -  null,
    #   - +type+ -  "Submission",
    #   - +url+ -  "http://my.server.com/api",
    #   - +webhookId+ -  "00000000-0000-1000-8000-000000000000"
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_kapp_webhook_job(kapp_slug, job_id, job_properties={}, headers=default_headers)
      info("Updating the webhook job #{job_id} in the \"#{kapp_slug}\" Kapp")
      put("#{@api_url}/kapps/#{kapp_slug}/webhookJobs/#{job_id}", job_properties, headers)
    end

  end
end
