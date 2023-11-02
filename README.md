[![Gem Version](https://badge.fury.io/rb/json_resource.svg)](http://badge.fury.io/rb/json_resource)
[![build](https://github.com/mtgrosser/json_resource/actions/workflows/build.yml/badge.svg)](https://github.com/mtgrosser/json_resource/actions/workflows/build.yml)

# json_resource – Create Ruby objects from JSON data

```ruby
class Post
  include JsonResource::Model
  
  attribute :id,          type: :integer
  attribute :body,        type: :string
  attribute :timestamp,   type: :time
  attribute :status_code, type: :integer, path: %w[status statusCode]
  attribute :status_text, type: :string,  path: %w[status statusText]
  
  has_collection :comments
end

class Comment
  include JsonResource::Model
  
  attribute :author,    type: :string
  attribute :text,      type: :string
  attribute :timestamp, type: :time
end
```

```json
{
  "posts": [
    {
      "id": 123,
      "body": "Lorem ipsum",
      "timestamp": "2021-12-08T18:43:00",
      "status": {
        "statusCode": 2,
        "statusText": "published"
      },
      "comments": [
        {
          "author": "Mr. Spock",
          "text":   "Fascinating!",
          "timestamp": "2350-05-01T19:00:00"
        },
        {
          "author": "Chekov",
          "text":   "Warp 10",
          "timestamp": "2350-05-01T20:00:00"
        }
      ]
      
    }
  ]
}
```

```ruby
posts = Post.collection_from_json(json, root: 'posts')

posts.first.id => 123
posts.first.body => 'Lorem ipsum'
posts.first.status_text => 'published'
posts.first.comments.first.author => 'Mr. Spock'
```

## Instantiation

To instantiate collections, use `collection_from_json` on a JSON array.

To instantiate single objects, use `from_json` on a JSON hash.


## Field types

Attributes can have one of the following types:

| Type        | Conversion          | Options                   |
| ----------- | ------------------- | ------------------------- |
| `:string`   | `value`             |                           |
| `:integer`  | `value.to_i`        |                           |
| `:float`    | `value.to_f`        |                           |
| `:boolean`  | any of `[true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON']` | |
| `:decimal`  | direct, or `to_d`   | `:precision`, `:scale`    |
| `:date`     | `Date.parse`        |                           |
| `:time`     | `Time.parse`        |                           |


## Extracting data

Sometimes, APIs return data wrapped within arrays of hashes of arrays etc:

```json
{
  "data": [
    {
      "status": "ok"
    },
    {
      "planets": [
        {
          "name": "Earth",
          "mass": 5.9722E+24,
          "orbit": 1.000
        },
        {
          "name": "Jupiter",
          "mass": 1.8990E+27,
          "orbit": 5.205
        }
      ]
    }
  ]
}
```

```ruby
class Planet
  include JsonResource::Model
  
  attribute :name, type: :string
  attribute :mass, type: :decimal, precision: 10, scale: 4
end
```

To dig for this data, a call-sequence can be provided as the `root` option.

```ruby
planets = Planet.collection_from_json(json, root: %w[data [1] planets])
```
