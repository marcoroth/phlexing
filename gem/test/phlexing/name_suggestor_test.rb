# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class NameSuggestorTest < Minitest::Spec
    it "should suggest name for excluded tags" do
      assert_equal "Component", Phlexing::NameSuggestor.suggest(%(<div>...</div>))
      assert_equal "Component", Phlexing::NameSuggestor.suggest(%(<span>...</span>))
      assert_equal "Component", Phlexing::NameSuggestor.suggest(%(<p>...</p>))
      assert_equal "Component", Phlexing::NameSuggestor.suggest(%(<erb>...</erb>))
    end

    it "should suggest name for tag name" do
      assert_equal "ArticleComponent", Phlexing::NameSuggestor.suggest(%(<article>...</article>))
      assert_equal "SectionComponent", Phlexing::NameSuggestor.suggest(%(<section>...</section>))
      assert_equal "H1Component", Phlexing::NameSuggestor.suggest(%(<h1>...</h1>))
    end

    it "should suggest name for id" do
      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<span id="post">...</span>))
    end

    it "should suggst name for class" do
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<span class="posts">...</span>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<span class="posts container">...</span>))
    end

    it "should suggst name when id and class attribute is present" do
      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<span id="post" class="posts">...</span>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<span id="post" class="posts"><%= @user.name %></span>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<span id="post" class="posts"><%= user.name %></span>))
    end

    it "should suggest name with multiple top-level nodes" do
      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span id="post">...</span>))
      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span id="post" class="posts">...</span>))
      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span id="post" class="posts"><%= @user.name %><%= @company.name %></span>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span class="posts">...</span>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div>...</div><span class="posts container">...</span>))
    end

    it "should suggest name for attributes with dashes" do
      assert_equal "PostSectionComponent", Phlexing::NameSuggestor.suggest(%(<span id="post-section">...</span>))
      assert_equal "PostsSectionComponent", Phlexing::NameSuggestor.suggest(%(<span class="posts-section">...</span>))
      assert_equal "PostsSectionComponent", Phlexing::NameSuggestor.suggest(%(<span class="posts-section container">...</span>))
    end

    it "should suggest name for ivars" do
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div id="post"><%= @user.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div class="posts"><%= @user.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div id="post" class="posts"><%= @user.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div><%= @user.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div><%= @user.name %> <%= @company.name %></div>))
      assert_equal "PostComponent", Phlexing::NameSuggestor.suggest(%(<span id="post" class="posts"><%= @user.name %><%= @company.name %></span>))
    end

    it "should suggest name for locals" do
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div id="post"><%= user.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div class="posts"><%= user.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div id="post" class="posts"><%= user.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div><%= user.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div><%= user.name %> <%= company.name %></div>))
    end

    it "should suggest name id attribute and ivar/locals are present" do
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div id="posts"><%= @user.name %><%= @company.name %></div>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div id="posts"><%= @user.name %><%= company.name %></div>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div id="posts"><%= user.name %><%= @company.name %></div>))
      assert_equal "PostsComponent", Phlexing::NameSuggestor.suggest(%(<div id="posts"><%= user.name %><%= company.name %></div>))
    end

    it "should suggest name when class attribute and ivar/locals are present" do
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div class="posts"><%= @user.name %><%= @company.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div class="posts"><%= @user.name %><%= company.name %></div>))
      assert_equal "CompanyComponent", Phlexing::NameSuggestor.suggest(%(<div class="posts"><%= user.name %><%= @company.name %></div>))
      assert_equal "UserComponent", Phlexing::NameSuggestor.suggest(%(<div class="posts"><%= user.name %><%= company.name %></div>))
    end

    it "should suggest name when text nodes are present" do
      assert_equal "Component", Phlexing::NameSuggestor.suggest("text")
      assert_equal "Component", Phlexing::NameSuggestor.suggest("text<div>text</div>")
      assert_equal "Component", Phlexing::NameSuggestor.suggest("text<div>text</div>text")
    end

    it "should suggest name when only top-level erb-nodes are present" do
      assert_equal "Component", Phlexing::NameSuggestor.suggest(%(<% if render_content? %><%= "content" %><% else %><%= "no content" %><% end %>))
      assert_equal "ContentComponent", Phlexing::NameSuggestor.suggest(%(<% if render_content? %><%= content %><% else %><%= no_content %><% end %>))
      assert_equal "NoContentComponent", Phlexing::NameSuggestor.suggest(%(<% if render_content? %><%= content %><% else %><%= @no_content %><% end %>))
      assert_equal "ContentComponent", Phlexing::NameSuggestor.suggest(%(<% if render_content? %><%= @content %><% else %><%= no_content %><% end %>))
      assert_equal "ContentComponent", Phlexing::NameSuggestor.suggest(%(<% if render_content? %><%= @content %><% else %><%= @no_content %><% end %>))
    end
  end
end
