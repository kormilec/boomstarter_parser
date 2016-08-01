require 'set'
require 'uri'
require 'net/http'
require 'openssl'
require 'nokogiri'
require 'json'

# a1 = File.open("links.txt").read.split("\n")
a1 = *(1..72)
# puts a1

def ab arr
uri = URI.parse("https://boomstarter.ru")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

i=0
lnks = []
arr.each do |lnk|
	request = Net::HTTP::Get.new("/discover/successful?page=#{lnk}")
	html = http.request(request).body
	doc = Nokogiri::HTML(html)
	lnks[i] = doc.css('.project-thumbnail').css('.title').map { |link| link['href']}
	i=i+1
	end
return lnks
end

# puts ab(a1).length
def proj arr
uri = URI.parse("https://boomstarter.ru")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
prjcts = []
arr.each do |lnk|
	lnk.slice!("https://boomstarter.ru")
	request = Net::HTTP::Get.new("#{lnk}")
	html = http.request(request).body
	doc = Nokogiri::HTML(html)
	title = doc.css('.caption').css('.title').map { |tag| tag.text.strip }[0]
	pledged = doc.css('.caption').css('.pledged').map { |tag| tag.text.strip }[0]
	goal = doc.css('.caption').css('.goal').children[2].text.delete("\n")
	backers = doc.css('.caption').css('.backers').map { |tag| tag.text.strip }[1]
	location = doc.css('.caption').css('.location').map { |tag| tag.text.strip }[0]
	category = doc.css('.caption').css('.category').map { |tag| tag.text.strip }[0]
	prjcts.push(
		title: title,
		pledged: pledged,
		goal: goal,
		backers: backers,
		location: location,
		category: category

	)
	 
	end

return prjcts
end


ab(a1).each do |cat|
	File.open('otsort.txt', 'a'){ |file| file.puts  JSON.pretty_generate(proj(cat)) }
end