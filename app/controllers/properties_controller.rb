require 'httparty'

class PropertiesController < ApplicationController
  def index
    @data = top_bid_properties
    @properties = true
  end

  def most_expensive
    @data = get_expensive_properties[:data][:sales]
    @desc = "Top #{@data.count} most expensive properties"
    @properties = true
  end

  def least_expensive
    @data = get_expensive_properties('price', 'asc')[:data][:sales]
    @desc = "Top #{@data.count} least expensive properties"
    @properties = true
    respond_to do |format|
      format.html { render :template => "properties/most_expensive" }
    end
  end

  def transactions
    @data = get_expensive_properties('timestamp')[:data][:sales]
    @desc = "#{@data.count} recent transactions"
    @transactions = true
  end

  private

  def get_properties
    client.execute(query: '{
      nfts( subgraphError:allow, where:{ category_in: [parcel] }){
        id
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
          parcel{
            x
            y
          }
        }
      }
    }")
  end



  def top_bid_properties
    parcels1 = get_properties
    parcels1 = parcels1[:data][:nfts]
    parcels1 = parcels1.map{ |data| { bid_count: data[:bids].count, id: parcels1.first[:id] }}
    all_parcels = parcels1.sort_by{ |data| data[:bid_count] }.reverse
    all_parcels.first(10)
  end
end
