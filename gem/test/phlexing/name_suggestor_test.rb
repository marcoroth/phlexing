# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class NameSuggestorTest < Minitest::Spec
    it "should suggest name for excluded tags" do
      assert_equal "Component", NameSuggestor.call(%(<div>...</div>))
      assert_equal "Component", NameSuggestor.call(%(<span>...</span>))
      assert_equal "Component", NameSuggestor.call(%(<p>...</p>))
      assert_equal "Component", NameSuggestor.call(%(<erb>...</erb>))
    end

    it "should suggest name for tag name" do
      assert_equal "ArticleComponent", NameSuggestor.call(%(<article>...</article>))
      assert_equal "SectionComponent", NameSuggestor.call(%(<section>...</section>))
      assert_equal "H1Component", NameSuggestor.call(%(<h1>...</h1>))
      assert_equal "ButtonComponent", NameSuggestor.call(%(<button>...</button>))
    end

    it "should suggest name for id" do
      assert_equal "PostComponent", NameSuggestor.call(%(<span id="post">...</span>))
    end

    it "should suggst name for class" do
      assert_equal "PostsComponent", NameSuggestor.call(%(<span class="posts">...</span>))
      assert_equal "PostsComponent", NameSuggestor.call(%(<span class="posts container">...</span>))
    end

    it "should suggst name when id and class attribute is present" do
      assert_equal "PostComponent", NameSuggestor.call(%(<span id="post" class="posts">...</span>))
      assert_equal "UserComponent", NameSuggestor.call(%(<span id="post" class="posts"><%= @user.name %></span>))
      assert_equal "UserComponent", NameSuggestor.call(%(<span id="post" class="posts"><%= user.name %></span>))
    end

    it "should suggest name with multiple top-level nodes" do
      assert_equal "PostComponent", NameSuggestor.call(%(<div>...</div><span id="post">...</span>))
      assert_equal "PostComponent", NameSuggestor.call(%(<div>...</div><span id="post" class="posts">...</span>))
      assert_equal "PostComponent", NameSuggestor.call(%(<div>...</div><span id="post" class="posts"><%= @user.name %><%= @company.name %></span>))
      assert_equal "PostsComponent", NameSuggestor.call(%(<div>...</div><span class="posts">...</span>))
      assert_equal "PostsComponent", NameSuggestor.call(%(<div>...</div><span class="posts container">...</span>))
    end

    it "should suggest name for attributes with dashes" do
      assert_equal "PostSectionComponent", NameSuggestor.call(%(<span id="post-section">...</span>))
      assert_equal "PostsSectionComponent", NameSuggestor.call(%(<span class="posts-section">...</span>))
      assert_equal "PostsSectionComponent", NameSuggestor.call(%(<span class="posts-section container">...</span>))
    end

    it "should suggest name for ivars" do
      assert_equal "UserComponent", NameSuggestor.call(%(<div id="post"><%= @user.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div class="posts"><%= @user.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div id="post" class="posts"><%= @user.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div><%= @user.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div><%= @user.name %> <%= @company.name %></div>))
      assert_equal "PostComponent", NameSuggestor.call(%(<span id="post" class="posts"><%= @user.name %><%= @company.name %></span>))
    end

    it "should suggest name for locals" do
      assert_equal "UserComponent", NameSuggestor.call(%(<div id="post"><%= user.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div class="posts"><%= user.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div id="post" class="posts"><%= user.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div><%= user.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div><%= user.name %> <%= company.name %></div>))
    end

    it "should suggest name id attribute and ivar/locals are present" do
      assert_equal "PostsComponent", NameSuggestor.call(%(<div id="posts"><%= @user.name %><%= @company.name %></div>))
      assert_equal "PostsComponent", NameSuggestor.call(%(<div id="posts"><%= @user.name %><%= company.name %></div>))
      assert_equal "PostsComponent", NameSuggestor.call(%(<div id="posts"><%= user.name %><%= @company.name %></div>))
      assert_equal "PostsComponent", NameSuggestor.call(%(<div id="posts"><%= user.name %><%= company.name %></div>))
    end

    it "should suggest name when class attribute and ivar/locals are present" do
      assert_equal "UserComponent", NameSuggestor.call(%(<div class="posts"><%= @user.name %><%= @company.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div class="posts"><%= @user.name %><%= company.name %></div>))
      assert_equal "CompanyComponent", NameSuggestor.call(%(<div class="posts"><%= user.name %><%= @company.name %></div>))
      assert_equal "UserComponent", NameSuggestor.call(%(<div class="posts"><%= user.name %><%= company.name %></div>))
    end

    it "should suggest name when text nodes are present" do
      assert_equal "Component", NameSuggestor.call("text")
      assert_equal "Component", NameSuggestor.call("text<div>text</div>")
      assert_equal "Component", NameSuggestor.call("text<div>text</div>text")
    end

    it "should suggest name when only top-level erb-nodes are present" do
      assert_equal "Component", NameSuggestor.call(%(<% if render_content? %><%= "content" %><% else %><%= "no content" %><% end %>))
      assert_equal "ContentComponent", NameSuggestor.call(%(<% if render_content? %><%= content %><% else %><%= no_content %><% end %>))
      assert_equal "NoContentComponent", NameSuggestor.call(%(<% if render_content? %><%= content %><% else %><%= @no_content %><% end %>))
      assert_equal "ContentComponent", NameSuggestor.call(%(<% if render_content? %><%= @content %><% else %><%= no_content %><% end %>))
      assert_equal "ContentComponent", NameSuggestor.call(%(<% if render_content? %><%= @content %><% else %><%= @no_content %><% end %>))
    end

    it "should handle invalid syntax" do
      assert_equal "Component", NameSuggestor.call(%(<%= tag.div %><% end %>))
      assert_equal "Component", NameSuggestor.call(%(<%= %><% end %>))
      assert_equal "Component", NameSuggestor.call(%(<% end %>))
      assert_equal "Component", NameSuggestor.call(%(<% if %>))
    end
  end
end
