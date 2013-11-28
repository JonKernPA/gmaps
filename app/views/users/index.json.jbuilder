json.array!(@users) do |user|
  json.extract! user, :latitude, :longitude, :address, :description, :title
  json.url user_url(user, format: :json)
end
