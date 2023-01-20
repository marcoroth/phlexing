# frozen_string_literal: true

require_relative "./test_helper"

class PhlexingTest < Minitest::Spec
  it "has a version number" do
    refute_nil ::Phlexing::VERSION
  end
end
