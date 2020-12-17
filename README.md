# Geological Tactile Image Repository

## Installation for development

```sh
# Install Ruby dependencies
$ bundle

# Install JavaScript dependencies
$ npm install
```

## Running in development

Run the following in separate terminals:

```sh
$ npm run build:js
```

and

```sh
$ bundle exec jekyll serve
```

## Additional tasks

- `npm run build:index` - building the search index in advance
- `ruby extract_thumbs.rb` - extracts thumbnails from PowerPoint files
