require './gmail_auth'
require 'base64'
require 'json'

# Initialize the API
client = Google::APIClient.new(:application_name => APPLICATION_NAME)
client.authorization = authorize
gmail_api = client.discovered_api('gmail', 'v1')


# Show the user's labels
results = client.execute!(
  :api_method => gmail_api.users.messages.list,
  :parameters => { :userId => 'me', :q => 'from:dailyreport@samsungcard.com' })

puts "No labels found" if results.data.messages.empty?

results.data.messages.each do |message|
  details = client.execute!(
    :api_method => gmail_api.users.messages.get,
    :parameters => { :userId => 'me', :id => "#{message.id}" })
    encoded_details = Base64.urlsafe_decode64(JSON.parse(details.data.to_json)["payload"]["body"]["data"])
    puts encoded_details
end
