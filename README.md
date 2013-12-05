## GMaps4Rails, ActiveRecord, Plain UI Example App

## Related GMaps4Rails Projects
* [gmaps](https://github.com/JonKernPA/gmaps): Standard Rails4, ActiveRecord, standard UI
* [gmaps_mongo](https://github.com/JonKernPA/gmaps_mongo): Rails4, MongoDB, standard UI
* [gmaps_zurb](https://github.com/JonKernPA/gmaps_zurb): Rails4, MongoDB, Zurb Foundation

## Tech Stack

This application requires:

* Ruby 2.0
* Rails 4.0
* ActiveRecord
* Plain Vanilla
* [gmaps4rails](https://github.com/apneadiving/Google-Maps-for-Rails)

## Companion Video

From the [gmaps4rails](https://github.com/apneadiving/Google-Maps-for-Rails) github site,
which references a [quick tutorial on Youtube](http://www.youtube.com/watch?v=R0l-7en3dUw&feature=youtu.be).

I created these steps so that I could be sure on the proper steps to get gmaps working.

## Demo Steps

### Create New Rails App

Bootstrap the rails app inside an RVM setup ([RVM](http://rvm.io/) is optional)

```
$ mkdir gmaps
$ cd gmaps/
$ rvm use ruby-2.0.0@gmaps --ruby-version --create
Using /Users/jon/.rvm/gems/ruby-2.0.0-p247 with gemset gmaps
ruby-2.0.0-p247@gmaps ~/Nitrous.IO/jons-box-1/gmaps
$ gem install rails
```

### Create User Model

The user will have lat/lon data

```
rails g scaffold User latitude:float longitude:float address:string description:string title:string
rake db:migrate
```

### Add Address Geocoding

In Gemfile, add:

```ruby
gem 'geocoder'
```

In `routes.rb` add `root 'users#index'`

```ruby
Gmaps::Application.routes.draw do
  resources :users
  root 'users#index'
end
```

In `user.rb` add the Geocoder bits

```ruby
class User < ActiveRecord::Base
  geocoded_by :address
  after_validation :geocode
end
```

Start Rails

```
bundle install
rails s
```

### Create a New User

In the App, create a new user, add an address (for example, "New York, NY" -- do not enter a lat or lon), save new user.

*Assert:* You should see lat/lon geocoded...

### Add Gmaps4Rails

In Gemfile

```ruby
gem 'gmaps4rails'
```

```
bundle install
rails s
```

### Add Map Div

Inside `users/index.html.erb`

Add at the bottom of page:

```erb
<div style='width: 800px;'>
  <div id="map" style='width: 800px; height: 400px;'></div>
</div>
```

### Add Map Javascript

Put the following at the top of the `users/index.html.erb` page

```javascript
<script src="//maps.google.com/maps/api/js?v=3.13&sensor=false&libraries=geometry" type="text/javascript"></script>
<script src="//google-maps-utility-library-v3.googlecode.com/svn/tags/markerclustererplus/2.0.14/src/markerclusterer_packed.js" type="text/javascript"></script>
```

### Underscores.js

Visit [http://underscorejs.org/underscore-min.js](http://underscorejs.org/underscore-min.js).
Select Production Version, copy all text or do right-click, Save As...

Add this file under `vendor` as follows:

```
vendor/assets/javascripts/underscore.js
```

### Asset Pipeline

Add underscore and gmaps to `app/assets/javascripts/application.js`

```ruby
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require underscore
//= require gmaps/google
//= require_tree .
```

(leaving `require_tree .` as last line)

### Map Generation Script

Add the map script to the bottom of the view, below the div.

Note: this has dummy marker data at a lat/lon of 0,0 :-)

```javascript
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

### Assert: Map Should be Visible

Refresh the view... Now you should see a map!

If you don't see a map, something is wrong.


### Generate Map Datapoints

Add to the controller the generation of the mapping datapoints from the user records:

```ruby
  def index
    @users = User.all
    @hash = Gmaps4rails.build_markers(@users) do |user, marker|
      marker.lat user.latitude
      marker.lng user.longitude
      marker.title user.title
    end
  end
```

Replace the dummy marker data in the view script with data from the model:

```javascript
markers = handler.addMarkers(<%=raw @hash.to_json %>);
```

### Assert: Map Should be Visible

Be sure to add a couple of User records with addresses (and verify the geocoding worked).

Refresh the users page.

Now you should see a map with your user datapoints...

If you do not see the individual user datapoints, then something is wrong.



