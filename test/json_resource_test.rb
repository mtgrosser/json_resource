require_relative 'test_helper'

class JsonResourceTest < Minitest::Test

  def test_load_json
    shipment = Shipment.from_json(load_json(:shipments))
    assert_equal 'transit', shipment.status
    assert_equal 5, shipment.events.size
    assert_equal ['Ludwigsfelde, Deutschland', 'Deutschland', 'Deutschland', 'Deutschland', nil], shipment.events.map(&:locality)
  end
  
  private
  
  def load_json(name)
    Pathname.new(__FILE__).dirname.join("#{name}.json").read
  end
end
