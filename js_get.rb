require 'sinatra'
require 'sequel'
require 'json'
require 'haml'
require 'active_support'

module Scripts
  def self.data
    @@data ||= make
  end
  
  def self.make
    db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://jsget.db')
    make_table(db)
    db[:scripts]    
  end
  
  def self.make_table(db)
    db.create_table :scripts do
      primary_key :id
      String :name, :unique => true, :null => false
      String :version 
      String :src_url
      String :min_url
      String :author
      Text :description
      
      Time :created_at
    end
  rescue Sequel::DatabaseError
    # assume table already exists
  end
end


class JsGet < Sinatra::Default
  VERSION = '0.1.1'
  
  get '/' do
    @scripts = Scripts.data.all
    haml :index
  end
  
  get '/scripts.json' do
    Scripts.data.all.to_json
  end
  
  get '/scripts/new' do
    haml :form
  end
  
  get '/scripts/:id/show' do
    throw :halt, [ 404, "No such script \"#{params[:id]}\"" ] unless @script = Scripts.data.filter(:name => params[:id]).first   
    haml :show, :locals => { :script => @script }

  end

  get '/scripts/:id/edit' do
    throw :halt, [ 404, "No such script \"#{params[:id]}\"" ] unless @script = Scripts.data.filter(:name => params[:id]).first
    haml :form, :locals => { :script => @script }

  end

  get '/scripts/:id' do
    throw :halt, [ 404, "No such script \"#{params[:id]}\"" ] unless Scripts.data.filter(:name => params[:id]).count > 0
    Scripts.data.filter(:name => params[:id]).first.to_json
  end
  
  post '/scripts' do
    Scripts.data << { 
        :name => params[:name], 
        :created_at => (params[:created_at] || Time.now), 
        :version => (params[:version] || ""), 
        :src_url => params[:src_url], 
        :min_url => (params[:min_url] || ""), 
        :author => (params[:author] || ""), 
        :description => (params[:description] || "") 
    }
    redirect '/' 
    
  end
  
  post '/scripts/:id' do
    Scripts.data.filter(:name => params[:id]).update( { 
        :version => (params[:version] || ""), 
        :src_url => params[:src_url], 
        :min_url => (params[:min_url] || ""), 
        :author => (params[:author] || ""), 
        :description => (params[:description] || "") 
    })
    redirect '/'    
  end

  post '/scripts/:id/delete' do
    Scripts.data.filter(:name => params[:id]).delete
    redirect '/'
  end
    
end
