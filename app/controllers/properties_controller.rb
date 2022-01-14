require 'httparty'

class PropertiesController < ApplicationController
  def index
    @data = top_bid_properties
    @properties = true
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


  def top_bid_properties
    parcels1 = get_properties
    parcels1 = parcels1[:data][:nfts]
    parcels1 = parcels1.map{ |data| { bid_count: data[:bids].count, id: parcels1.first[:id] }}
    all_parcels = parcels1.sort_by{ |data| data[:bid_count] }.reverse
    all_parcels.first(10)
  end
end
