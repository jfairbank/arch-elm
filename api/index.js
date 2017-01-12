const http = require('http');
const Twitter = require('twitter');
const WebSocketServer = require('ws').Server;
const app = require('express')();
const cors = require('cors');
const { Observable } = require('rxjs');
const lru = require('lru-cache');
const usersFixture = require('./users.json');
const tweetsFixture = require('./tweets.json');

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const DEMO_MODE = false;
const TWEET_REPLAY = 50;

const {
  NODE_ENV,
  ORIGIN,
  PORT = 8081,
  QUERY = '#codemash',
} = process.env;

const isProduction = NODE_ENV === 'production';

const twitter = new Twitter({
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET,
});

const server = http.createServer(app);

const streamTo = client => (message) => {
  client.send(JSON.stringify(message));
};

function merge(...objects) {
  return Object.assign({}, ...objects);
}

let getTweetStream;
let searchTweets;

if (DEMO_MODE) {
  getTweetStream = searchTweets = () => (
    Observable.of(...tweetsFixture)
      .map(tweet => merge(tweet, {
        user: usersFixture.elpapapollo,
      }))
  );
} else {
  getTweetStream = (query) => {
    const streamOptions = { track: query };
    const stream = twitter.stream('statuses/filter', streamOptions);

    return Observable.fromEvent(stream, 'data');
  };

  searchTweets = (query) => {
    const searchOptions = {
      q: query,
      result_type: 'recent',
      include_entities: true,
    };

    const initialPromise = twitter.get('search/tweets', searchOptions);

    return Observable.fromPromise(initialPromise)
      .flatMap(tweets => tweets.statuses.slice(0, TWEET_REPLAY).reverse());
  };
}

function randomDelayTime() {
  const minTime = 1000;
  const maxTime = 3000;

  return Math.floor(Math.random() * maxTime) + minTime;
}

const wss = new WebSocketServer({
  server,
  clientTracking: true,
});

const tweets$ = getTweetStream(QUERY);

wss.on('connection', (ws) => {
  const subscription = searchTweets(QUERY)
    .concatMap(tweet => Observable.of(tweet).delay(randomDelayTime()))
    .concat(tweets$)
    .subscribe(streamTo(ws));

  ws.on('close', () => {
    subscription.unsubscribe();
  });
});

if (isProduction) {
  app.use(cors({ origin: ORIGIN }));
} else {
  app.use(cors());
}

const usersCache = lru({
  max: 20,
  maxAge: 60 * 1000 * 1000,
});

function cacheUser(user) {
  usersCache.set(user.screen_name, user);
}

const retrieveUser = DEMO_MODE
  ? (screenName) => {
    console.log('getting from fixtures');
    const user = usersFixture[screenName];

    if (user) {
      return Promise.resolve(user);
    }

    return Promise.reject(`No user "${screenName}"`);
  }

  : (screenName) => {
    const cachedUser = usersCache.get(screenName);

    if (cachedUser) {
      return Promise.resolve(cachedUser);
    }

    const options = {
      screen_name: screenName,
    };

    return twitter.get('users/show', options)
      .then((user) => {
        const newUser = merge(user, {
          profile_image_url: user.profile_image_url.replace(/_normal\./, '.'),
        });

        cacheUser(newUser);
        return newUser;
      });
  };

app.get('/user/:screenName', (req, res, next) => {
  retrieveUser(req.params.screenName)
    .then(user => res.send(user))
    .catch(next);
});

server.listen(PORT, () => {
  if (process.env.NODE_ENV !== 'production') {
    // eslint-disable-next-line no-console
    console.log(`Server listening at http://localhost:${PORT}`);
  }
});
