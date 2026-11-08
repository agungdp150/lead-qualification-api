require "stringio"

# Vercel's Ruby runtime supplies WEBrick-compatible request/response objects.
module VercelAdapter
  def self.call(app, request, response)
    env = request.meta_vars.merge(
      "SCRIPT_NAME" => "", "PATH_INFO" => request.path,
      "rack.input" => StringIO.new(request.body.to_s),
      "rack.errors" => $stderr, "rack.url_scheme" => "https"
    )
    status, headers, body = app.call(env)
    response.status = status
    headers.each { |name, value| response[name] = Array(value).join("\n") }
    response.body = +""
    body.each { |part| response.body << part }
  ensure
    body.close if body.respond_to?(:close)
  end
end
