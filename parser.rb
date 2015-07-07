require 'nokogiri'
require 'csv'
f = File.open("parsed_html.html")

doc = Nokogiri::HTML::Document.parse(f, nil, "UTF-8")
@data = doc.css('body table td tr table tr').map(&:text)

CSV.open("moneybook.csv", 'w') do |csv|
  csv << %w(일자 시간 상품명 사용자 카드명 카드번호 가맹점명 이용금액 개월 구분)
  @data.each do |row|
    row = row.gsub(/[[:blank:]]/,'').gsub(",","").gsub("\r\n", ',').gsub(/\A,|,\Z/,'').split(',')
    # break if row[0] == ""
    csv << row if row.grep(/\A\d\d-\d\d/).any?
  end
end
