# Google Maps for Rails Example App

* Ruby 2.0
* Rails 4.0
* ActiveRecord
* Plain Vanilla
* [gmaps4rails](https://github.com/apneadiving/Google-Maps-for-Rails)

## Companion Video

From the [gmaps4rails](https://github.com/apneadiving/Google-Maps-for-Rails) github site,
which references a [quick tutorial on Youtube](http://www.youtube.com/watch?v=R0l-7en3dUw&feature=youtu.be).

I created these steps so that I could be sure on the proper steps to get gmaps working.

# Demo Steps

## Create New Rails App

Bootstrap the rails app inside an RVM setup ([RVM](http://rvm.io/) is optional)

```
$ mkdir gmaps
$ cd gmaps/
$ rvm use ruby-2.0.0@gmaps --ruby-version --create
Using /Users/jon/.rvm/gems/ruby-2.0.0-p247 with gemset gmaps
ruby-2.0.0-p247@gmaps ~/Nitrous.IO/jons-box-1/gmaps
$ gem install rails
```

## Create User Model

The user will have lat.lon data

```ruby
rails g scaffold User latitude:float longitude:float address:string description:string title:string
rake db:migrate
```

### Add Address Geocoding

In Gemfile:

```ruby
gem 'geocoder'
```

In routes.rb

```ruby
root 'users#index'
```

In user.rb

```ruby
geocoded_by :address
after_validation :geocode
```

Start Rails

```ruby
$ bundle install
rails s
```

## Create a New User

In the App, create a new user, add an address (for example, "New York, NY" -- do not enter a lat or lon), save new user.

You should see lat/lon geocoded...

## Add Gmaps4Rails

In Gemfile

```ruby
gem 'gmaps4rails'
```

```ruby
bundle install
rails s
```

### Add Map Div

Inside users/index.html.erb

Add at the bottom of page:

```ruby
<div style='width: 800px;'>
  <div id="map" style='width: 800px; height: 400px;'></div>
</div>
```

### Javascript

Put the following at the top of the users/index.html.erb page

```ruby
<script src="//maps.google.com/maps/api/js?v=3.13&sensor=false&libraries=geometry" type="text/javascript"></script>
<script src='//google-maps-utility-library-v3.googlecode.com/svn/tags/markerclustererplus/2.0.14/src/markerclusterer_packed.js' type='text/javascript'></script>
```

### Underscores.js

Visit http://underscorejs.org/underscore-min.js
Select Production Version, copy all text or do right-click, Save As...

Add this file under vendors as follows:

```ruby
vendor/assets/javascripts/underscore.js
```

### Asset Pipeline

Add to app/assets/javascripts/application.js

```ruby
//= require underscore
//= require gmaps/google
```

(leaving require_tree as last line)

### Map Generation Script

Add the map script to the bottom of the view, below the div.

Note: this has dummy marker data at a lat/lon of 0,0 :-)

```ruby
<script type="text/javascript">
  handler = Gmaps.build('Google');
  handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
    markers = handler.addMarkers([
      {
        "lat": 0,
        "lng": 0,
        "picture": {
          "url": "https://addons.cdn.mozilla.net/img/uploads/addon_icons/13/13028-64.png",
          "width":  36,
          "height": 36
        },
        "infowindow": "hello!"
      }
    ]);
    handler.bounds.extendWith(markers);
    handler.fitMapToBounds();
  });
</script>
```

### Map Should be Visible

Refresh the view... Now you should see a map!

If you don't see a map, something is wrong.


## Generate Map Data

Add to the controller the generation of the mapping data points from the user records:

```ruby
def index
    @users = User.all
    @hash = Gmaps4rails.build_markers(@users) do |user, marker|
      marker.lat user.latitude
      marker.lng user.longitude
    end
end
```

Replace the dummy marker data in the view script with data from the model:

```ruby
markers = handler.addMarkers(<%=raw @hash.to_json %>);
```

### Map Should be Visible

Be sure to add a couple of User records with addresses (and verify the geocoding worked).

Refresh the users page.

Now you should see a map with your user data points...

If you do not see the inidividual user data points, then something wrong



