require 'mechanize'

m = Mechanize.new

n = 0
loop do 
  n += 1

  filename = "%0.3d.png" % n

  if File.exists? filename
    puts "* Skipping #{n}"
    next
  end

  url = "http://brainchip.webcomic.ws/comics/#{n}/"
  puts "* #{url}"

  page = m.get(url)

  heading = page.at("h2.heading")
  if heading.text =~ /Comic (\d+)/
    fetched = $1.to_i
    if n != fetched
      puts "Done!" 
      break
    end
  else
    raise "wat: #{heading.to_s}"
  end

  img = page.image_with src: %r{images/comics/.+\.png$}

  image = img.fetch

  puts "  |_ got #{image.uri.path}"

  ext = File.extname image.uri.path
  image.save(filename)
  puts "  |_ wrote #{filename}, #{File.size filename} bytes"
  puts
end
