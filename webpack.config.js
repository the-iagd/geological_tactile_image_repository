const path = require('path');

const baseConfig = {
  // webpack folder’s entry js — excluded from jekll’s build process.
  entry: {
    index: './src/index.js',
  },
  output: {
    // we’re going to put the generated file in the assets folder so jekyll will grab it.
    path: path.resolve(__dirname, 'assets/javascript'),
    filename: '[name].bundle.js',
  },
  module: {
  },
  resolve: {
    extensions: ['.js', '.jsx', '.json'],
    modules: ['node_modules', 'src'],
  },
};

module.exports = (env, options) => {
  const isProduction = options.mode === 'production';
  baseConfig.devtool = !isProduction ? 'eval-source-map' : false; // eslint-disable-line no-param-reassign
  return baseConfig;
};
