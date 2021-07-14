require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'rubyzip'
  gem 'byebug'
end

puts 'Gems installed and loaded!'

require 'zip'

Dir['assets/tactile_image_files/**/*.pptx'].each do |f|
  Zip::File.open(f) do |zipfile|
    file_name = zipfile.name.split('/').last.split('.').first.split('-').first
    thumbnail = zipfile.find { |v| v.name.start_with? 'docProps/thumbnail' }
    if !thumbnail
      puts "error with #{file_name}"
      next
    end
    FileUtils.rm("#{File.expand_path File.dirname(__FILE__)}/assets/thumbnails/#{file_name}.jpeg", force: true)
    thumbnail.extract("#{File.expand_path File.dirname(__FILE__)}/assets/thumbnails/#{file_name}.jpeg")
  end
end
