# frozen_string_literal: true

module Koi
  class UrlRedirect
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      current_path = env["REQUEST_URI"]

      if status.to_i == 404 && (new_path = find_redirect(current_path))
        request = ActionDispatch::Request.new(env)

        # Close the body as we will not use it for a 301 redirect
        body.close

        # Issue a "Moved permanently" response with the redirect location
        [301, { "Location" => new_location(current_path, new_path, request) },
         ["#{current_path} moved. The document has moved to #{new_path}"]]
      else
        # Not a 404 or no redirect found, just send the response as is
        [status, headers, body]
      end
    end

    private

    def new_location(current_path, new_path, request)
      if %r{\Ahttps{0,1}://}.match?(new_path)
        new_path
      else
        request.original_url.gsub(current_path, new_path)
      end
    end

    def find_redirect(path)
      UrlRewrite.redirect_path_for(path)
    end
  end
end
