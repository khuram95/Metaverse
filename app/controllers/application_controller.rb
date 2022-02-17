class ApplicationController < ActionController::Base
  def client
    @client ||= GraphqlClient.new('https://api.thegraph.com/subgraphs/name/decentraland/marketplace','')
  end

  def set_endpoint
    @is_graphql = params[:graphql].nil? || params[:graphql] == 'true'
  end
end
