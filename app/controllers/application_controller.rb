class ApplicationController < ActionController::Base
  def client
    @client ||= GraphqlClient.new('https://api.thegraph.com/subgraphs/name/decentraland/marketplace','')
  end

  def set_endpoint
    @is_graphql = params[:graphql].nil? || params[:graphql] == 'true'
  end

  def mana_to_usd
    response ||= HTTParty.get('https://api.nomics.com/v1/currencies/ticker?key=7f5332a92b94e03b090f42de8d57bc04bc360a26&ids=MANA')
    @mana_rate ||= response[0]['price'].to_i
  end
end
