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
After tha we need to put the control of the action text in the erb file as follows:
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
It's time to save the articles into Article so for that we need to tell the action to the controller as follows:
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
Les analyse the create method, so we have an instance variable that create the article inside Article, the params are tile and content, in title: we have params[:article][:title] this is provided by the form and also in the content params[:article][:content]. Finally we have the render json: @article this how rails response with a JSON we will see this in the browser if evertythin is ok. And we can see the response when we add new article with a title "Super cool rich text"

```json
id:	2
title:	"Super cool rich text"
status:	null
created_at:	"2019-11-30T00:22:57.931Z"
updated_at:	"2019-11-30T00:22:58.054Z"
```