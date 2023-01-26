# frozen_string_literal: true

Rails.application.routes.draw do
  resources :converters

  patch "/converters" => "converters#update"

  root "converters#index"
end
