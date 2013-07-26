module Koi
  class UrlRedirect

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      current_path = env['PATH_INFO']

      if status == 404 && new_path = find_redirect(current_path)
        request = ActionDispatch::Request.new(env)

        new_location = request.url.gsub(current_path, new_path)

        # Close the body as we will not use it for a 301 redirect
        body.close

        # Issue a "Moved permanently" response with the redirect location
        [301, { "Location" => new_location }, ["#{current_path} moved. The document has moved to #{new_path}"]]
      else
        # Not a 404 or no redirect found, just send the response as is
        [status, headers, body]
      end
    end

    private

    def find_redirect(path)
      UrlRewrite.redirect_path_for(path)
    end

  end
end
