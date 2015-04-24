require 'mechanize'
require 'fileutils'

class Comic < Struct.new(:n)

  class Done < Exception; end

  PANELDIR = "images/panels"

  def panel_filename
    "%0.3d.png" % n
  end

  def save_path
    "#{PANELDIR}/#{panel_filename}"
  end

  def url
    "http://brainchip.webcomic.ws/comics/#{n}/"
  end

  def m
    @mechanize ||= Mechanize.new {|a| a.user_agent_alias = "Windows IE 7" }
  end

  def scraped?
    File.exists? save_path
  end

  def scrape!
    # Skip if already downloaded the image

    puts "* #{url}"

    # get comic #n's webpage

    page = m.get(url)

    # Find comic panel image

    heading = page.at("h2.heading")
    if heading.text =~ /Comic (\d+)/
      current_comic = $1.to_i
      raise Done if n != current_comic
    else
      raise "wat: #{heading.to_s}"
    end

    # Fetch image

    img = page.image_with src: %r{images/comics/.+\.png$}
    image = img.fetch
    puts "  |_ got #{image.uri.path}"

    # Save image

    ext = File.extname image.uri.path
    image.save(save_path)
    puts "  |_ wrote #{save_path}, #{File.size save_path} bytes"
    puts
  end

  def self.scrape_all!
    FileUtils.mkdir_p PANELDIR

    n = 0
    loop do 
      n += 1
      c = new(n)

      if c.scraped?
        puts "* Skipping #{n}"
      else
        c.scrape!
      end
    end
  rescue Done
    puts "Done!" 
  end

end


Comic.scrape_all!