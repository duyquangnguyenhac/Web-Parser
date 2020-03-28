require 'httparty'
require 'Nokogiri'
require 'byebug'

def scraper
	doc = HTTParty.get("https://www.ssense.com/en-us/men")
	@parse_page = Nokogiri::HTML(doc)
	productCards = @parse_page.css('figure.browsing-product-item') #60 items
	products = Array.new

	page = 1
	per_page = productCards.count;
	last_page = @parse_page.css("li.last-page").css('a')[0].children.text
	last_pagenumber = last_page.to_i
	while page <= last_pagenumber
		pagination_url = "https://www.ssense.com/en-us/men?page=#{page}"
		puts pagination_url
		puts "Page: #{page}"
		puts ''
		pagination_unparsed_page = HTTParty.get(pagination_url)
		pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
		pagination_products = pagination_parsed_page.css('figure.browsing-product-item')
		pagination_products.each do |pagination_products|
			product = {
				brand: pagination_products.css('p.bold').text,
				name: pagination_products.css('p.product-name-plp').text,
				price: pagination_products.css('p.price').text,
				url: "https://www.ssense.com" + pagination_products.css('a')[0].attributes["href"].value
			}
			products << product
			puts "Added #{product[:name]}"
			puts "From: #{product[:brand]}"
			puts ""
		end
		page +=1
	end
	byebug
end

scraper
