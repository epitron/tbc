require 'epitools'

# data = Path["slices/*.png"].sort.map { |path| [path.basename, "slices/#{path.filename}"] }.to_h
data = Dir["slices/*.png"].sort

File.write("comics.json", JSON.dump(data))

