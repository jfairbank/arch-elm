const path = require('path');
const webpack = require('webpack');
const DashboardPlugin = require('webpack-dashboard/plugin');

const production = process.env.NODE_ENV === 'production';

const config = {
  entry: path.resolve(__dirname, 'src/index.js'),

  output: {
    path: path.resolve(__dirname, 'public'),
    filename: 'main.js',
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
        test: /\.scss$/,
        loader: 'style!css!sass',
      },
      {
        test: /\.elm$/,
        exclude: /elm-stuff|node_modules/,
        // loader: 'elm-hot!elm-webpack',
        loader: 'elm-webpack',
      },
      {
        test: /\.eot(\?(v=\d+\.\d+\.\d+|\w+))?$/,
        loader: 'file-loader',
      },
      {
        test: /\.(woff|woff2)(\?(v=\d+\.\d+\.\d+|\w+))?$/,
        loader: 'url-loader?prefix=font/&limit=5000',
      },
      {
        test: /\.ttf(\?(v=\d+\.\d+\.\d+|\w+))?$/,
        loader: 'url-loader?limit=10000&mimetype=application/octet-stream',
      },
      {
        test: /\.svg$/,
        loader: 'svg-loader',
      },
    ],

    noParse: /\.elm$/,
  },

  // sassLoader: {
  //   includePaths: [
  //     path.resolve(__dirname, 'src'),
  //     // path.resolve(__dirname, 'src/vendors/bootstrap/assets/stylesheets'),
  //   ],
  // },

  plugins: [],

  devServer: {
    stats: 'errors-only',
  },
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
} else {
  config.plugins.push(new DashboardPlugin());
}

module.exports = config;
