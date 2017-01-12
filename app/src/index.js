/* eslint-disable */
'use strict';

require('./index.html');
require('./styles.scss');

var Elm = require('./Profile');

Elm.Profile.embed(document.getElementById('main'));
