module Query
  query = {
    accounts:  '{
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
    }'
  }
end