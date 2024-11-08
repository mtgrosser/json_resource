class Shipment
  include JsonResource::Model

  attribute :id,                 type: :string
  attribute :status,             type: :string, path: %w[status statusCode]
  attribute :status_description, type: :string, path: %w[status description]
  attribute :product_name,       type: :string, path: %w[details product productName]
  
  has_collection :events, class_name: 'Event'
end

class Event
  include JsonResource::Model

  attribute :timestamp,   type: :time
  attribute :locality,    type: :string, path: %w[location address addressLocality]
  attribute :status,      type: :string, path: %w[statusCode]
  attribute :description, type: :string

  def to_formatted_s
    "#{timestamp}: #{status_text}\n#{description_text}"
  end
end

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

  has_attributes :author, :text, type: :string

  attribute :timestamp, type: :time
end

class Planet
  include JsonResource::Model
  
  attribute :name, type: :string
  attribute :mass, type: :decimal, scale: 0
  attribute :orbit, type: :decimal, scale: 2, precision: 12
end
