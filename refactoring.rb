require './gmail_auth'
require 'base64'
require 'json'
require 'pg'
require 'sequel'
require 'nokogiri'

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
    @DB = Sequel.connect("postgres://localhost/moneybookdb")
    @mails = @DB[:mails]
    @spends = @DB[:spends]

  end

  def gets
    @lists = @client.execute!(
    :api_method => @gmail_api.users.messages.list,
    :parameters => { :userId => 'me', :q => 'from:dailyreport@samsungcard.com' })

    @html = []

    @lists.data.messages.each do |list|
      begin
        unless @mails.where( :mail_id => list.id ).any?
          @mails.insert( :mail_id => list.id )
          @message = @client.execute!(
          :api_method => @gmail_api.users.messages.get,
          :parameters => { :userId => 'me', :id => list.id })

          if JSON.parse(@message.data.to_json)["payload"]["body"]["data"]
            @encoded_message = Base64.urlsafe_decode64(JSON.parse(@message.data.to_json)["payload"]["body"]["data"])
          end

          @html << @encoded_message

        end
      rescue Exception => e
        puts "exception"
      end
    end

    @html.each do |h|
      doc = Nokogiri::HTML::Document.parse(h.to_s, nil, "UTF-8")

      data = doc.css('body table td tr table tr').map(&:text)

      data.each do |d|
        row = d.gsub(/[[:blank:]]/,'').gsub(",","").gsub("\r\n", ',').gsub(/\A,|,\Z/,'').split(',')
        if row.grep(/\A\d\d-\d\d/).any?
          @spends.insert( :date => row[0],
                          :time => row[1],
                          :type => row[2],
                          :user => row[3],
                          :card_name => row[4],
                          :card_num => row[5],
                          :store_name => row[6],
                          :price => row[7],
                          :installation => row[8] ,
                          :success => row[9]
                          )
        end
      end
    end
  end


end

m = MoneyBook.new
m.gets
