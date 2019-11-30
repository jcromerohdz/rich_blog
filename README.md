# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

1. Set up action text
```sh
$ rails action_text:install
Copying actiontext.scss to app/assets/stylesheets
      create  app/assets/stylesheets/actiontext.scss
Copying fixtures to test/fixtures/action_text/rich_texts.yml
      create  test/fixtures/action_text/rich_texts.yml
Copying blob rendering partial to app/views/active_storage/blobs/_blob.html.erb
      create  app/views/active_storage/blobs/_blob.html.erb
Installing JavaScript dependencies
         run  yarn add trix@^1.0.0 @rails/actiontext@^6.0.1 from "."
yarn add v1.19.1
[1/4] Resolving packages...
[2/4] Fetching packages...
info fsevents@1.2.9: The platform "linux" is incompatible with this module.
info "fsevents@1.2.9" is an optional dependency and failed compatibility check. Excluding it from installation.
[3/4] Linking dependencies...
warning " > webpack-dev-server@3.9.0" has unmet peer dependency "webpack@^4.0.0".
warning "webpack-dev-server > webpack-dev-middleware@3.7.2" has unmet peer dependency "webpack@^4.0.0".
[4/4] Building fresh packages...
success Saved lockfile.
warning Your current version of Yarn is out of date. The latest version is "1.19.2", while you're on "1.19.1".
info To upgrade, run the following command:
$ sudo apt-get update && sudo apt-get install yarn
success Saved 2 new dependencies.
info Direct dependencies
├─ @rails/actiontext@6.0.1
└─ trix@1.2.1
info All dependencies
├─ @rails/actiontext@6.0.1
└─ trix@1.2.1
Done in 3.56s.
Adding trix to app/javascript/packs/application.js
      append  app/javascript/packs/application.js
Adding @rails/actiontext to app/javascript/packs/application.js
      append  app/javascript/packs/application.js
Copied migration 20191130000235_create_active_storage_tables.active_storage.rb from active_storage
Copied migration 20191130000236_create_action_text_tables.action_text.rb from action_text
``` 
```sh
$ rails db:migrate
== 20191130000235 CreateActiveStorageTables: migrating ========================
-- create_table(:active_storage_blobs, {})
   -> 0.0023s
-- create_table(:active_storage_attachments, {})
   -> 0.0024s
== 20191130000235 CreateActiveStorageTables: migrated (0.0049s) ===============

== 20191130000236 CreateActionTextTables: migrating ===========================
-- create_table(:action_text_rich_texts)
   -> 0.0040s
== 20191130000236 CreateActionTextTables: migrated (0.0041s) ==================
```
Now we have to tell the article model that it have rich text ability a follows:
```ruby
class Article < ApplicationRecord
	has_rich_text :content
end
```
1.1 After tha we need to put the control of the action text in the erb file as follows:
```erb
#app/views/articles/new.html.erb
<%= form_with(model: @article, local: true) do |form| %>
	<div>
		<%= form.label :title %>
		<%= form.text_field :title %>
	</div>

	<div>
		<%= form.label :content %>
		<%= form.rich_text_area :content %>
	</div>

	<div>
		<%= form.submit %>		
	</div>
<% end %>
```
1.2 It's time to save the articles into Article so for that we need to tell the action to the controller as follows:
```ruby
class ArticlesController < ApplicationController
	def new
		@article = Article.new
	end

	def create
		@article = Article.create(title: params[:article][:title], content: params[:article][:content])
		render json: @article
	end
end
```
1.3 Let's analyse the create method, so we have an instance variable that create the article inside Article, the params are tile and content, in title: we have params[:article][:title] this is provided by the form and also in the content params[:article][:content]. Finally we have the render json: @article this how rails response with a JSON we will see this in the browser if evertythin is ok. And we can see the response when we add new article with a title "Super cool rich text"

```json
id:	2
title:	"Super cool rich text"
status:	null
created_at:	"2019-11-30T00:22:57.931Z"
updated_at:	"2019-11-30T00:22:58.054Z"
```
2. Displaying the article in the a web page, to accomplish this task is necesary to write in articles controller the action show as follows:
```ruby
Rails.application.routes.draw do
  get 'home/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/welcome", to: "home#index"
  get "articles/new", to: "articles#new"
  get "articles/:id", to: "articles#show"
  post "articles", to: "articles#create"
end
```
```ruby
class ArticlesController < ApplicationController
	def show
		@article = Article.find(:id)
	end
  .
  .
  .
```
2.1 Then we need to create our show.html.erb file inside views/articles and put the following code: 
```erb
<h1><%= @article.title %></h1>

<div>
	<%= @article.content %>
</div>
```

2.3 If everythin is OK you will see in your browser the article 2 when you navigate /articles/2. For understanding the article content query I'm gonna use the rails console and apply this query with active record.
```sh
$ rails console
irb(main):001:0> article = Article.find(2)
   (0.3ms)  SELECT sqlite_version(*)
  Article Load (0.1ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = ? LIMIT ?  [["id", 2], ["LIMIT", 1]]
=> #<Article id: 2, title: "Super cool rich text", status: nil, created_at: "2019-11-30 00:22:57", updated_at: "2019-11-30 00:22:58">
irb(main):002:0> article.content
  ActionText::RichText Load (0.3ms)  SELECT "action_text_rich_texts".* FROM "action_text_rich_texts" WHERE "action_text_rich_texts"."record_id" = ? AND "action_text_rich_texts"."record_type" = ? AND "action_text_rich_texts"."name" = ? LIMIT ?  [["record_id", 2], ["record_type", "Article"], ["name", "content"], ["LIMIT", 1]]
  Rendered /home/chris/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/actiontext-6.0.1/app/views/action_text/content/_layout.html.erb (Duration: 1.2ms | Allocations: 582)
=> #<ActionText::RichText id: 1, name: "content", body: #<ActionText::Content "<div class=\"trix-conte...">, record_type: "Article", record_id: 2, created_at: "2019-11-30 00:22:58", updated_at: "2019-11-30 00:22:58">
irb(main):003:0> 
```
2.4 The content is extracted from the table "action_text_rich_texts" as you can see in the article.content SQL query.

3. Edit the article, firts I'm gonna create my route with the action edit and also a patch requeste with the action update this is a rails convention in order to apply this functionallity this code is shown bellow. Then inside of articles_controller create an edit method and the update method as shown bellow. Finally a view is needed so create inside of views/articles/edit.html.erb and add the form for editing the record you want as you can see the code bellow corresponding to this view.
```ruby
Rails.application.routes.draw do
  .
  .
  .
  get "articles/:id", to: "articles#show"

  patch "articles/:id",  to: "articles#update", as: :article
  .
  .
end
```
```ruby
class ArticlesController < ApplicationController
  .
  .
  .

	def edit
		@article = Article.find(params[:id])
	end

	def update
		@article = Article.find(params[:id])
		@article.update(title: params[:article][:title], content: params[:article][:content])
		
		redirect_to @article
  end
  .
  .
  .
end
```
```erb
#app/views/articles/edit.html.erb
<%= form_with(model: @article, local: true) do |form| %>
	<div>
		<%= form.label :title %>
		<%= form.text_field :title %>
	</div>

	<div>
		<%= form.label :content %>
		<%= form.rich_text_area :content %>
	</div>

	<div>
		<%= form.submit %>		
	</div>
<% end %>
```
4. Delete the article, for applying this functionallity first is needed to create a resource with the respective action on routes in other words create a delete resource with action destroy as shown bellow. After the resource is created now inside articles_controller a destroy method is needed for the action ocurs as shown bellow. Finally a link_to is needed in the views/article/show.html.erb for telling the app to delete the corresponding article.
```ruby
Rails.application.routes.draw do
  .
  .
  .
  delete "articles/:id",  to: "articles#destroy"
end
```
```ruby
#app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  .
  .
  .
	def destroy
		@article = Article.find(params[:id])
		@article.destroy
		redirect_to root_path
	end
end
```
```erb
#app/views/articles/show.html.erb
<div>
	<%= link_to "Delete Article", @article, method: :delete%>
</div>
```
4. Defining a root path, in order this app knows how to redirect to a root path we need to especify this in the routes.rb and define this action as shown bellow:
```ruby
Rails.application.routes.draw do
  .
  root to: "home#index"
  .
  .
  .
end
``` 