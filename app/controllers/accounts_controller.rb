require 'httparty'
class AccountsController < ApplicationController

  def index
    @data = accounts
    @accounts = true
  end

  private


  def get_parcels
    client.execute(query: '{
          accounts(subgraphError: allow){
            nfts(where: {category: parcel, parcel_not: null}) {
              id
              parcel{
                id
                owner{
                  id
                  address
                  earned
                  sales
                  purchases
                  spent
                }
              }
            }
          }
        }')
  end

  def get_estate_parcels
    client.execute(query: '{
      accounts(subgraphError: allow){
        nfts(where: {category: estate}) {
          id
          estate{
            parcels{
              id
              owner{
                id
                address
                earned
                sales
                purchases
                spent
              }
            }
          }
        }
      }
    }')
  end

  def accounts
    parcels1 = get_parcels
    parcels2 = get_estate_parcels
    parcels1 = parcels1[:data][:accounts]
    parcels2 = parcels2[:data][:accounts]
    parcels1 = parcels1.map{ |data| data[:nfts] if data[:nfts].count > 0 }.compact.flatten
    parcels2 = parcels2.map{ |data| data[:nfts] if data[:nfts].count > 0 }.compact.flatten
    parcels2 = parcels2.pluck(:estate).pluck(:parcels).flatten
    parcels1 = parcels1.map{ |data| {id: data[:id], owner_id: data[:parcel][:owner][:id], data: data[:parcel][:owner]} }
    parcels2 = parcels2.map{ |data| {id: data[:id], owner_id: data[:owner][:id],  data: data[:owner]} }
    all_parcels = (parcels1 + parcels2).uniq
    all_parcels = all_parcels.group_by{ |data| data[:owner_id] }
    all_parcels = all_parcels.map{ |data| {onwer_id: data[0], parcels_count: data[1].count, data: data[1][0][:data]} }
    all_parcels = all_parcels.sort_by{ |data| data[:parcels_count] }.reverse
    all_parcels.first(10)
  end
end
