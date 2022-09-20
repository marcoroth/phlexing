# frozen_string_literal: true

Rails.application.routes.draw do
  resources :converters

  root "converters#index"
end
