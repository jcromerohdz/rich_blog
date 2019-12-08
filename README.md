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

# SASS and Webpack
1. Need to be documented

# Devise integreation for the app
1.  Install and setup the devise gem, to have the authentication functionallity I'm gonna use devise gem, so I will put it in my Gamefile as show below. Then a cople steps are require in order to set up this gem, firt generate the installation of this gem as shown bellow after executing the command some configuration are creted like devise.rb and devise.en.yml and a massege with "some setup you must do manually if you haven't yet:" as shown bellow, now the second step is generate a User table via devise  and make the corresponding migration as show bellow
```ruby
```
```sh
$ rails generate devise:install
 * devise (4.7.1)
	Summary: Flexible authentication solution for Rails with Warden
	Homepage: https://github.com/plataformatec/devise
	Path: /home/chris/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/devise-4.7.1
blog$ rails generate devise:install
Running via Spring preloader in process 31990
      create  config/initializers/devise.rb
      create  config/locales/devise.en.yml
===============================================================================

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. You can copy Devise views (for customization) to your app by running:

       rails g devise:views

===============================================================================

```
```sh
$ rails generate devise User
Running via Spring preloader in process 366
      invoke  active_record
      create    db/migrate/20191201161655_devise_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      insert    app/models/user.rb
       route  devise_for :users
```
```sh
$ rails db:migrate
== 20191201161655 DeviseCreateUsers: migrating ================================
-- create_table(:users)
   -> 0.0015s
-- add_index(:users, :email, {:unique=>true})
   -> 0.0008s
-- add_index(:users, :reset_password_token, {:unique=>true})
   -> 0.0008s
== 20191201161655 DeviseCreateUsers: migrated (0.0032s) =======================
```
2. Working with devise sessions, ones we make an account devise created for us a session for each user, it can be use every time you needed, I'm gonna put an example in my nav partial as shown bellow. The user_signed_in? method is generated by devise and is asking if the user is signed in and if it is meaning a session for the current user is created then it will show the hi inside the navigation menu. Now I thing in this li tag is good idea to close the user session and we can achive that by adding a destroy action that devise is given as shown bellow.
```erb
#app/views/partials/_nav.html.erb
<nav class="nav bg-dark padding">
	<li class="nav-item">
		<%= link_to 'Home', root_path, class: "nav-link" %>
	</li>
	<li class="nav-item">
		<%= link_to 'Articles', articles_path, class: "nav-link" %>
	</li>
	<li class="nav-item">
		<%= link_to 'New Article', new_articles_path, class: "nav-link" %>
	</li>

	<% if user_signed_in? %>
		<li class="nav-item">
			<span>Hi</span>
		</li>
	<% end %>
</nav>
```
```erb
#app/views/partials/_nav.html.erb
<nav class="nav bg-dark padding">
	<li class="nav-item">
		<%= link_to 'Home', root_path, class: "nav-link" %>
	</li>
	<li class="nav-item">
		<%= link_to 'Articles', articles_path, class: "nav-link" %>
	</li>
	<li class="nav-item">
		<%= link_to 'New Article', new_articles_path, class: "nav-link" %>
	</li>

	<% if user_signed_in? %>
		<li class="nav-item">
			<%= link_to 'Close session', destroy_user_session_path, method: :delete, class: "nav-link" %>
		</li>
	<% end %>
</nav>
```
3. Modifying devise view, to achive this I need to generated the views via devise as shown bellow, after
```sh
$ rails generate devise:views
Running via Spring preloader in process 2215
      invoke  Devise::Generators::SharedViewsGenerator
      create    app/views/devise/shared
      create    app/views/devise/shared/_error_messages.html.erb
      create    app/views/devise/shared/_links.html.erb
      invoke  form_for
      create    app/views/devise/confirmations
      create    app/views/devise/confirmations/new.html.erb
      create    app/views/devise/passwords
      create    app/views/devise/passwords/edit.html.erb
      create    app/views/devise/passwords/new.html.erb
      create    app/views/devise/registrations
      create    app/views/devise/registrations/edit.html.erb
      create    app/views/devise/registrations/new.html.erb
      create    app/views/devise/sessions
      create    app/views/devise/sessions/new.html.erb
      create    app/views/devise/unlocks
      create    app/views/devise/unlocks/new.html.erb
      invoke  erb
      create    app/views/devise/mailer
      create    app/views/devise/mailer/confirmation_instructions.html.erb
      create    app/views/devise/mailer/email_changed.html.erb
      create    app/views/devise/mailer/password_change.html.erb
      create    app/views/devise/mailer/reset_password_instructions.html.erb
      create    app/views/devise/mailer/unlock_instructions.html.erb
```
# One to many associations
1. for doing this rails use a convention that is to use an id reference of the table you want to associate and I can achieve this generating a migration as shown bellow after executing the migration a migration of the database is needed.
```sh
$ rails g migration add_user_id_to_articles user:references
Running via Spring preloader in process 8192
      invoke  active_record
      create    db/migrate/20191207015227_add_user_id_to_articles.rb
$ rails db:migrate
```
if you have records in the database you should reset the database via rails then preform the corresponding migration as shown bellow.
```sh
$ rails db:reset
Dropped database 'db/development.sqlite3'
Database 'db/test.sqlite3' does not exist
Created database 'db/development.sqlite3'
Created database 'db/test.sqlite3'
You have 1 pending migration:
  20191207015227 AddUserIdToArticles
$ rails db:migrate
```
# Rails scaffolds and many to many associations
1. Here I'm going to use rails magic, the scaffolds are fantastic for prototyping, rails make this easy to implemented. After performing the scaffold a migration is needed
```sh
$ rails g scaffold Category title color
Running via Spring preloader in process 4831
      invoke  active_record
      create    db/migrate/20191207160237_create_categories.rb
      create    app/models/category.rb
      invoke    test_unit
      create      test/models/category_test.rb
      create      test/fixtures/categories.yml
      invoke  resource_route
       route    resources :categories
      invoke  scaffold_controller
      create    app/controllers/categories_controller.rb
      invoke    erb
      create      app/views/categories
      create      app/views/categories/index.html.erb
      create      app/views/categories/edit.html.erb
      create      app/views/categories/show.html.erb
      create      app/views/categories/new.html.erb
      create      app/views/categories/_form.html.erb
      invoke    test_unit
      create      test/controllers/categories_controller_test.rb
      create      test/system/categories_test.rb
      invoke    helper
      create      app/helpers/categories_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/categories/index.json.jbuilder
      create      app/views/categories/show.json.jbuilder
      create      app/views/categories/_category.json.jbuilder
      invoke  assets
      invoke    scss
      create      app/assets/stylesheets/categories.scss
      invoke  scss
      create    app/assets/stylesheets/scaffolds.scss
$ rails db:migrate
blog$ rails db:migrate
== 20191207160237 CreateCategories: migrating =================================
-- create_table(:categories)
   -> 0.0014s
== 20191207160237 CreateCategories: migrated (0.0015s) ========================

```
2. Generate the model for reference the associations between category table and article table, this can be done via rails, after generating this model a migration is need to complete the associations as shown bellow.
```sh
$ rails g model HasCategory article:references category:references
Running via Spring preloader in process 15399
      invoke  active_record
      create    db/migrate/20191208160234_create_has_categories.rb
      create    app/models/has_category.rb
      invoke    test_unit
      create      test/models/has_category_test.rb
      create      test/fixtures/has_categories.yml
$ rails db:migrate
== 20191208160234 CreateHasCategories: migrating ==============================
-- create_table(:has_categories)
   -> 0.0032s
== 20191208160234 CreateHasCategories: migrated (0.0033s) =====================
```
