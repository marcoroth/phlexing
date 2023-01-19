# frozen_string_literal: true

require "test_helper"

module Phlexing
  class NameSuggestorTest < ActiveSupport::TestCase
    test "should suggest name" do
      assert_equal "Component", Phlexing::NameSuggestor.suggest(%(<div>...</div>))
      assert_equal "Component", Phlexing::NameSuggestor.suggest(%(<span>...</span>))
      assert_equal "Component", Phlexing::NameSuggestor.suggest(%(<p>...</p>))

      assert_equal "ArticleComponent", Phlexing::NameSuggestor.suggest(%(<article>...</article>))
      assert_equal "SectionComponent", Phlexing::NameSuggestor.suggest(%(<section>...</section>))
      assert_equal "H1Component", Phlexing::NameSuggestor.suggest(%(<h1>...</h1>))

      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<span id="post">...</span>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<span class="posts">...</span>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<span class="posts container">...</span>))

      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span id="post">...</span>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span class="posts">...</span>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span class="posts container">...</span>))

      assert_equal "PostSectionComponent", Phlexing::NameSuggestor.suggest(%(<span id="post-section">...</span>))
      assert_equal "PostsSectionComponent", Phlexing::NameSuggestor.suggest(%(<span class="posts-section">...</span>))
      assert_equal "PostsSectionComponent", Phlexing::NameSuggestor.suggest(%(<span class="posts-section container">...</span>))

      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<span id="post" class="posts">...</span>))
      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<span id="post" class="posts"><%= @user.name %><%= @company.name %></span>))

      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span id="post" class="posts">...</span>))
      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span id="post" class="posts"><%= @user.name %><%= @company.name %></span>))

      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<span id="post" class="posts"><%= @user.name %></span>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<span id="post" class="posts"><%= user.name %></span>))

      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div><%= @user.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div><%= @user.name %> <%= @company.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div id="posts"><%= @user.name %></div>))

      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div id="posts"><%= @user.name %><%= @company.name %></div>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div class="posts"><%= @user.name %><%= @company.name %></div>))

      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div id="posts"><%= @user.name %><%= company.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div class="posts"><%= @user.name %><%= company.name %></div>))
    end
  end
end
