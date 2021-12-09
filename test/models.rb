class Shipment
  include JsonResource::Model

  self.root = %w[shipments [0]]
  
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
