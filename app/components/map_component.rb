# typed: strict
# frozen_string_literal: true

class MapComponent < ViewComponent::Base
  extend T::Sig

  sig { params(lat: Float, lng: Float, address: String, zoom: Integer, static_src: String).void }
  def initialize(lat:, lng:, address:, zoom:, static_src:)
    super()
    @lat = lat
    @lng = lng
    @address = address
    @zoom = zoom
    @static_src = static_src
  end
end
