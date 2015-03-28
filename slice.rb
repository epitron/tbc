require 'epitools'
require 'opencv'
require 'pry'

include OpenCV

slicedir = Path["slices/"]
slicedir.mkdir

files = Path["*.png"].sort
# files = files.split_before{ |f| f.filename == "143.png" }.last

letters = [*'A'..'Z']

files.each do |f|

  if (slicedir/"#{f.basename}-A.png").exists?
    puts "Skipping #{f}..."
    next
  else
    puts "Slicing #{f}..."
  end
  image = CvMat.load(f.path)

  puts "#{image.width}x#{image.height}"

  white_rows = []
  pos = 0

  image.each_row do |row|
    zero = row.xor(255).sum.to_a.sum
    white_rows << pos if zero == 0.0
    pos += 1
  end

  chunks = white_rows.split_between { |a,b| a != b-1 }.to_a
  p chunks

  ranges = chunks.map{|c| [c.first, c.last+1] unless c.empty? }
  ranges = [0, *ranges.flatten.compact, image.height-1].each_slice(2).to_a
  p ranges

  ranges.each_with_index do |(top, bottom),i|
    next if (top-bottom).abs < 10
    outfile = slicedir/"#{f.basename}-#{letters[i]}.png"
    p outfile

    rect = [0, top, image.width, bottom-top]
    image.subrect(*rect).save(outfile.path)
  end

end
