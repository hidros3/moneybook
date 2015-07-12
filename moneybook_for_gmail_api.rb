require './gmail_auth'
require 'base64'
require 'json'
require 'pg'
require 'sequel'

# Initialize the API
client = Google::APIClient.new(:application_name => APPLICATION_NAME)
client.authorization = authorize
gmail_api = client.discovered_api('gmail', 'v1')


# Show the user's labels
results = client.execute!(
  :api_method => gmail_api.users.messages.list,
  :parameters => { :userId => 'me', :q => 'from:dailyreport@samsungcard.com' })

puts "No labels found" if results.data.messages.empty?

# insert retrived mail list
# DB scheme
# # :mails
# primary_key :id
# String :mail_id
DB = Sequel.connect("postgres://localhost/moneybookdb")
@mails = DB[:mails]

begin
	results.data.messages.each do |message|
	  unless @mails.where(:mail_id => "#{message.id}").any?
	  	@mails.insert(:mail_id => "#{message.id}")
		  details = client.execute!(
		    :api_method => gmail_api.users.messages.get,
		    :parameters => { :userId => 'me', :id => "#{message.id}" })
		    if JSON.parse(details.data.to_json)["payload"]["body"]["data"]
		    	encoded_details = Base64.urlsafe_decode64(JSON.parse(details.data.to_json)["payload"]["body"]["data"])
		    end
		  puts encoded_details
	  end	  
	end
rescue => e
	puts "#{e.message}"
end

@mails.save
