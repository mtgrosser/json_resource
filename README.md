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
