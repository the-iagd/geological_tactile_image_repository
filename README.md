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

## Contributing new tactile images

To contribute new tactile images, you will need to do the following:

1. [Fork and clone](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/cloning-a-repository) this repository to your computer.
1. Update `_data/tactile_images.csv` with new rows of the images you are adding. Please make sure to add a local identifer in the convention e.g `0034` and a uuid. Also make sure to specify a license for the content. `cc-by-4` is translated to the Creative Commons By 4.0 license. Using Excel or Numbers to import and save this file can be problematic as it may change the format of some fields.

1. Add the PDF and PPTX formatted files in the `assets/tactile_image_files` directory in a new directory based off of the local identifier and title.

1. Submit a [pull request](https://help.github.com/en/articles/about-pull-requests) with the changes.

## License

The code in this repository is licensed under the MIT license. Tactile image files are licensed under the CC-BY-4 license.
