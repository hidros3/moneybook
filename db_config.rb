# DB setups

require 'sequel'

DB = Sequel.connect("postgres://localhost/moneybookdb")

# DB.create_table :mails do
# 	primary_key :id
# 	String :mail_id
# end

DB.create_table :spends do
	primary_key :id
	String 	:date
	String 	:time
	String 	:type
	String 	:user
	String 	:card_name
	String 	:card_num
	String 	:store_name
	Float 	:price
	String	:installation
	String	:success
end
