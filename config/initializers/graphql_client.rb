class GraphqlClient
  def initialize(url, token)
    @url = url
    @token = token
  end

  def execute(query:, variables: nil)
    HTTParty.post(
      @url,
      headers: { 
        'Content-Type'  => 'application/json', 
        'Authorization' => "Bearer #{@token}" 
      },
      body: { 
        query: query, 
        variables: variables 
      }.to_json,
      timeout: 10
    ).with_indifferent_access
  end
end