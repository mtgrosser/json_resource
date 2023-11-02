require_relative 'test_helper'

class JsonResourceTest < Minitest::Test

  def test_load_object
    shipment = Shipment.from_json(load_json(:shipments), root: ['shipments', '[0]'])
    assert_equal 'transit', shipment.status
    assert_equal 5, shipment.events.size
    assert_equal ['Ludwigsfelde, Deutschland', 'Deutschland', 'Deutschland', 'Deutschland', nil], shipment.events.map(&:locality)
  end

  def test_load_collection
    posts = Post.collection_from_json(load_json(:array))
    assert_equal 2, posts.size
    assert_equal [123, 456], posts.map(&:id)
    assert_equal ['Lorem ipsum', 'Make it so!'], posts.map(&:body)
  end

  def test_load_collection_with_root
    posts = Post.collection_from_json(load_json(:posts), root: 'posts')
    assert_equal 1, posts.size
    assert post = posts.first
    assert_equal 123, post.id
    assert_equal 'Lorem ipsum', post.body
  end
  
  def test_load_collection_from_array_element
    planets = Planet.collection_from_json(load_json(:array_of_planets), root: %w[data [1] planets])
    assert_equal %w[Earth Jupiter], planets.map(&:name)
  end
  
  def test_casting_big_decimals
    planets = Planet.collection_from_json(load_json(:planets), root: 'planets')
    assert_equal [5972200000000000000000000, 1899000000000000000000000000], planets.map(&:mass)
    assert_equal [BigDecimal('1.00'), BigDecimal('5.21')], planets.map(&:orbit)
  end

  private

  def load_json(name)
    Pathname.new(__FILE__).dirname.join("#{name}.json").read
  end
end
