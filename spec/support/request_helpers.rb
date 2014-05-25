module RequestHelpers
  def json
    if response.body == 'null'
      @json = nil
    else
      @json ||= JSON.parse(response.body)
    end
  end

  def createHeaders(version, token)
    {'HTTP_ACCEPT' => "application/vnd.fbm.v#{version}", 'HTTP_AUTHORIZATION' => "Token token=\"#{token}\""}
  end
end
