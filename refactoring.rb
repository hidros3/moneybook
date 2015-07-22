require './gmail_auth'
require 'base64'
require 'json'
require 'pg'
require 'sequel'

# # Initialize the API


# # Show the user's labels
# results = @client.execute!(
#   :api_method => @gmail_api.users.messages.list,
#   :parameters => { :userId => 'me', :q => 'from:dailyreport@samsungcard.com' })

# # READ TABLE FROM DB
# DB = Sequel.connect("postgres://localhost/moneybookdb")
# @mails = DB[:mails]
# @spends = DB[:spends]

def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
  storage = Google::APIClient::Storage.new(file_store)
  auth = storage.authorize

  if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
    app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
    flow = Google::APIClient::InstalledAppFlow.new({
      :client_id => app_info.client_id,
      :client_secret => app_info.client_secret,
      :scope => SCOPE})
    auth = flow.authorize(storage)
    puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
  end
  auth
end

class MoneyBook < Google::APIClient


  def initialize
    @client = Google::APIClient.new(:application_name => APPLICATION_NAME)
    @client.authorization = authorize
    @gmail_api = @client.discovered_api('gmail', 'v1')
  end

  def gets_lists
    @lists = @client.execute!(
    :api_method => @gmail_api.users.messages.list,
    :parameters => { :userId => 'taekjoo@gmail.com', :q => 'from:dailyreport@samsungcard.com' })
  end

  def gets_details
    @lists.data.messages.each do |list|
      message = @client.execute!(
      :api_method => @gmail_api.users.messages.get,
      :parameters => { :userId => 'taekjoo@gmail.com', :id => '14eb445940f4236d' })
    p message
    break
    end
  end






  # def samsung_card
  #   a = []
  #   mails = DB[:mails]
  #   @lists.data.messages.each do |list|
  #     unless mails.where(:mail_id => "#{list.id}").any?
  #       mails.insert(:mail_id => "#{list.id}")
  #       messages = @client.execute!(
  #         :api_method => @gmail_api.users.messages.get,
  #         :parameters => { :userId => 'me', :id => "#{list.id}"})
  #       if JSON.parse(messages.data.to_json)["payload"]["body"]["data"]
  #         encoded_message = Base64.urlsafe_decode64(JSON.parse(messages.data.to_json)["payload"]["body"]["data"])
  #         a << encoded_message
  #       end
  #     end
  #   end
  #   mails.save
  #   return a
  # end

end

m = MoneyBook.new
m.gets_lists
m.gets_details
