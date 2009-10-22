require 'sinatra'
require 'sequel'
require 'json'

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
      String :description
      
      Time :created_at
    end
  rescue Sequel::DatabaseError
    # assume table already exists
  end
end


class JsGet < Sinatra::Default
  VERSION = '0.1.1'
  
  get '/scripts.json' do
    Scripts.data.all.to_json
  end
  
  
  get '/scripts/:id' do
    throw :halt, [ 404, "No such script \"#{params[:id]}\"" ] unless Scripts.data.filter(:name => params[:id]).count > 0
    Scripts.data.filter(:name => params[:id]).first.to_json
  end
  

  post '/scripts/:id' do
    Scripts.data << { 
        :name => params[:id], 
        :created_at => (params[:created_at] || Time.now), 
        :version => (params[:version] || ""), 
        :src_url => params[:src_url], 
        :min_url => (params[:min_url] || ""), 
        :author => (params[:author] || ""), 
        :description => (params[:description] || "") 
    }
    "ok"
  end
    
    
end
