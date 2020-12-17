#------------------------------------------------------------------------
# encoding: utf-8
# @(#)product_generator.rb	1.00 29-Nov-2011 16:38
#
# Copyright (c) 2011 Jim Pravetz. All Rights Reserved.
# Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)
#
# Description:  A generator that creates product, products and
#		ingredients pages for jekyll sites.  Uses a JSON data
#		file as the database file from which to read and
#		generate the above files.
#
# Included filters : (none)
#
# Available _config.yml settings :
# - product_title_prefix   An optional name to prefix product titles with (default '')
# - category_meta_description_prefix An optional product metadata prefix (default 'Product: ')
# - products_src_dir:      The source subfolder from where product, products and ingredients pages are obtained.
# - products_dir:          The subfolder to build products pages in (default is 'products').
# - data_dir:              The subfolder under source where data files are read.
# - data_product_file:     The name of the JSON object file within the data_dir.
#
# Update History: (most recent first)
#  22-Dec-2011 jpravetz -- Added sitemap support
#  18-Dec-2011 jpravetz -- Added Page.to_liquid method to properly set page.url
#   5-Dec-2011 jpravetz -- Split product.options into an array
#  29-Nov-2011 jpravetz -- Created from category_generator.rb
#------------------------------------------------------------------------

# Adapted and modified from http://jimpravetz.com/blog/2011/12/generating-jekyll-pages-from-data/

require 'json'
require 'csv'
require 'deep_merge'
require 'byebug'

module Jekyll

  # The TactileImagePage class creates a single ingredients, product, or products page
  class TactileImagePage < Page
    
    # The resultant relative URL of where the published file will end up
    # Added for use by a sitemap generator
    attr_accessor :dest_url
    # The last modified date to be used for web caching of this file.
    # Derived from latest date of products.json and template files
    # Added for use by a sitemap generator
    attr_accessor :src_mtime

    # Initialize a new Page.
    #
    # site - The Site object.
    # base - The String path to the source.
    # dest_dir  - The String path between the dest and the file.
    # dest_name - The String name of the destination file (e.g. index.html or myproduct.html)
    # src_dir  - The String path between the source and the file.
    # src_name - The String filename of the source page file, minus the markdown or html extension
    # data_mtime - mtime of the products.json data file, used for sitemap generator
    def initialize(site, base, dest_dir, dest_name, src_dir, src_name, data_mtime )
      @site = site
      @base = base
      @dir  = dest_dir
      @dest_dir = dest_dir
      @dest_name = dest_name
      @dest_url = File.join( '/', dest_dir ) 
      @dest_url = File.join( '/', dest_dir, dest_name ) if !dest_name.match( /index.html/i )
      @src_mtime = data_mtime

      src_file = File.join(base, src_dir, "#{src_name}.markdown" )
      src_name_with_ext = "#{src_name}.markdown" if File.exists?( src_file )
      src_name_with_ext ||= "#{src_name}.html"

      @name = src_name_with_ext
      self.process(src_name_with_ext)
      
      # Read the YAML from the specified page
      self.read_yaml(File.join(base, src_dir), src_name_with_ext )
      # byebug
      # Remember the mod time, used for site_map
      file_mtime = File.mtime( File.join(base, src_dir, src_name_with_ext) )
      @src_mtime = file_mtime if file_mtime > @src_mtime
    end

    # Override to set url properly
    def to_liquid
      self.data.deep_merge({
        "url"        => @dest_url,
        "content"    => self.content })
    end

    # Attach our  data to the global page variable. This allows pages to see this data.
    # Use to set data on page.
    def set_data( label, data )
      self.data[label] = data
    end

    # Override so that we can control where the destination file goes
    def destination(dest)
      # The url needs to be unescaped in order to preserve the correct filename.
      path = File.join(dest, @dest_dir, @dest_name )
      path = File.join(path, "index.html") if self.url =~ /\/$/
      path
    end

  end

  # The Site class is a built-in Jekyll class with access to global site config information.
  # It is not necessary to extend the Site class, it just convenient to do so. And 
  # category_generator.rb did this, so it must be a good idea.
  class Site

    # Creates instances of TactileImagePage, renders then, and writes the output to a file.
    def write_all_files
      json_filename = self.config['data_image_file'] # || 'products.json'
      data_hash = read_data_object( json_filename ) # if File.exists?( json_filename )
      json_mtime = data_hash['mtime'] if data_hash
      data = data_hash['data'] if data_hash
      puts "## Tactile images file read: found #{data.length} images"

      # Write out all our pages
      write_tactile_images( data, '_tactile_images', 'tactile_images', json_mtime)
    end

    # Write a tactile_images/uuid/index.html page
    def write_tactile_images( data, products_src_dir, dest_dir, data_mtime )
      # Attach our product data to global site variable. This allows pages to see this product's data.
      data.each do |image|
        puts "## Processing image #{image['uuid']}"
        index = TactileImagePage.new( self, self.config['source'], File.join(dest_dir, image['uuid']), 'index.html', products_src_dir, 'image', data_mtime )
        index.set_data('title', image['Title'])
        index.set_data('description', image['Description'])
        index.set_data('tactile_image', image)
        index.set_data('metadata', image.slice('Tags', 'Creator', 'Source', 'Language', 'Font'))
        index.render(self.layouts, site_payload)
        index.write(self.dest)
        # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
        self.pages << index
      end
    end

    # Read and parse the JSON file under the data directory
    # +filename+ is the String name of the file to be read
    def read_data_object( filename )

      data_dir = self.config['data_dir'] || '_data'
      data_path = File.join(self.config['source'], data_dir)
      if File.symlink?(data_path)
        return "Data directory '#{data_path}' cannot be a symlink"
      end
      file = File.join(data_path, filename)

      return "File #{file} could not be found" if !File.exists?( file )
      
      result = nil
      Dir.chdir(data_path) do
        rows = []
        CSV.foreach(filename, headers: true, col_sep: ',') do |row|
          rows << row.to_hash
        end
        result = rows
      end
      puts "## Error: No data in #{file}" if result.nil?
      result = JSON.parse( result.to_json ) if result
      { 'data' => result,
        'mtime' => File.mtime(file) }
    end

  end


  # Jekyll hook - the generate method is called by jekyll, and generates all of the product pages.
  class TactileImageGenerator < Generator
    safe true

    def generate(site)
      site.write_all_files
    end
  end

end
