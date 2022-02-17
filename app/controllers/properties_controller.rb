require 'httparty'

class PropertiesController < ApplicationController
  before_action :set_endpoint

  def index
    @data = top_bid_properties
    @properties = true
  end

  def most_expensive
    @data = []
    if @is_graphql
      @data = get_expensive_properties[:data][:sales]
    end
    @desc = "Top #{@data.count} most expensive properties"
    @properties = true
  end

  def least_expensive
    if @is_graphql
      @data = get_expensive_properties('price', 'asc')[:data][:sales]
    else
      @data = get_cheap_properties['data']
    end
    @desc = "Top #{@data.count} least expensive properties"
    @properties = true
    respond_to do |format|
      format.html { render :template => "properties/most_expensive" }
    end
  end

  def transactions
    if @is_graphql
      @data = get_expensive_properties('timestamp')[:data][:sales]
    else
      @data = get_recent_sold_properties['data']
    end
    @desc = "#{@data.count} recent transactions"
    @transactions = true
  end

  def recent_listed
    if @is_graphql
      @data = get_recent_listed_properties[:data][:nfts]
    else
      @data = get_recent_listed['data']
    end
    @desc = "#{@data.count} recent listed properties"
    @recent_listed = true
    # respond_to do |format|
    #   format.html { render :template => "properties/recent_listed.html" }
    # end
  end

  private

  def get_properties
    client.execute(query: '{
      nfts( subgraphError:allow, where:{ category_in: [parcel] }){
        id
        image
        tokenId
        contractAddress
        bids{
          price
          bidder
          createdAt
          seller
          category
        }
      }
    }')
  end

  def get_expensive_properties(order_by= 'price', order_direction= 'desc')
    client.execute(query: "{
      sales(subgraphError: allow, first: 100, where:{  nft_starts_with: \"parcel\" }, orderBy: #{order_by}, orderDirection: #{order_direction}){
        id
        price
        timestamp
        seller
        buyer
        nft{
          id
          image
          tokenId
          contractAddress
          parcel{
            x
            y
          }
        }
      }
    }")
  end

  def get_recent_listed_properties
    client.execute(query: "{
      nfts(subgraphError: allow, first: 100, where:{  category: parcel }, orderBy: createdAt, orderDirection: desc){
        id
        image
        tokenId
        contractAddress
        createdAt
        parcel{
          x
          y
        }
      }
    }")
  end

  def get_cheap_properties
    HTTParty.get('https://nft-api.decentraland.org/v1/nfts?first=100&skip=0&sortBy=cheapest&isOnSale=true&isLand=true')
  end

  def get_recent_sold_properties
    HTTParty.get('https://nft-api.decentraland.org/v1/nfts?first=100&skip=0&sortBy=newest&isOnSale=true&isLand=true')
  end

  def get_recent_listed
    HTTParty.get('https://nft-api.decentraland.org/v1/nfts?first=100&skip=0&sortBy=recently_listed&isOnSale=true&isLand=true&category=parcel')
  end

  def top_bid_properties
    parcels1 = get_properties
    parcels1 = parcels1[:data][:nfts]
    parcels1 = parcels1.map{ |data| { bid_count: data[:bids].count, id: parcels1.first[:id] }}
    all_parcels = parcels1.sort_by{ |data| data[:bid_count] }.reverse
    all_parcels.first(10)
  end
end
