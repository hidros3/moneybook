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

# READ TABLE FROM DB
DB = Sequel.connect("postgres://localhost/moneybookdb")
@mails = DB[:mails]
@spends = DB[:spends]

def check_id
	#check it
end
puts results

