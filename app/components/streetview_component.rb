# typed: strict
# frozen_string_literal: true

class StreetviewComponent < ViewComponent::Base
  extend T::Sig

  sig { params(lat: Float, lng: Float, address: String, static_src: String).void }
  def initialize(lat:, lng:, address:, static_src:)
    super()

    @lat = lat
    @lng = lng
    @address = address
    @static_src = static_src
  end
end
