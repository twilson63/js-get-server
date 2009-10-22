require 'sinatra'
require 'sequel'

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
  
  get '/scripts/:id' do
    throw :halt, [ 404, "No such script \"#{params[:id]}\"" ] unless Scripts.data.filter(:name => params[:id]).count > 0
    @script = Scripts.data.filter(:name => params[:id]).first
    puts @script.inspect
    <<-JSON
{ "name": "#{@script[:name]}", "version": "#{@script[:version]}", "src_url": "#{@script[:src_url]}", "min_url": "#{@script[:min_url]}", "author": "#{@script[:author]}", "description": "#{@script[:description]}", "created_at": "#{@script[:created_at].strftime("%Y-%m-%d %H:%M:%S")}" }
    JSON
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
