const path = require('path');
const webpack = require('webpack');

const production = process.env.NODE_ENV === 'production';

const config = {
  entry: [
    path.resolve(__dirname, 'src/index.html'),
    path.resolve(__dirname, 'src/styles.css'),
    path.resolve(__dirname, 'src/index.js'),
  ],

  output: {
    path: path.resolve(__dirname, 'public'),
    filename: 'bundle.js',
    publicPath: 'http://localhost:8000/',
  },

  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm'],
    root: path.resolve(__dirname, 'src'),
  },

  module: {
    loaders: [
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file?name=[name].[ext]',
      },
      {
        test: /\.css$/,
        loader: 'style!css',
      },
      {
        test: /\.elm$/,
        exclude: /elm-stuff|node_modules/,
        loader: 'elm-hot!elm-webpack',
      },
    ],

    noParse: /\.elm$/,
  },

  plugins: [],
};

if (production) {
  config.plugins.push(
    new webpack.NoErrorsPlugin(),

    new webpack.optimize.UglifyJsPlugin({
      compressor: { warnings: false },
      sourceMap: false,
    }),

    new webpack.DefinePlugin({
      'process.env': { NODE_ENV: JSON.stringify('production') },
    }),

    new webpack.optimize.DedupePlugin(),

    // eslint-disable-next-line comma-dangle
    new webpack.optimize.OccurenceOrderPlugin()
  );
}

module.exports = config;
