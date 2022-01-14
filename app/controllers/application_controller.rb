class ApplicationController < ActionController::Base
  def client
    @client ||= GraphqlClient.new('https://api.thegraph.com/subgraphs/name/decentraland/marketplace','')
  end
end
