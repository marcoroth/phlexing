# frozen_string_literal: true

module TurboHelper
  include TurboPower::StreamHelper
end

Turbo::Streams::TagBuilder.prepend(TurboHelper)
