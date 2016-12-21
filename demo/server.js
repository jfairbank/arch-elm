const http = require('http');
const Twitter = require('twitter');
const WebSocketServer = require('ws').Server;
const app = require('express')();
const cors = require('cors');
const { Observable } = require('rx');

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

// const PORT = process.env.PORT;
const PORT = 8081;

const QUERY = '#codemash';
// const QUERY = 'javascript';

const twitter = new Twitter({
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET,
});

const server = http.createServer(app);

const wss = new WebSocketServer({
  server,
  clientTracking: true,
});

const streamTo = client => (message) => {
  client.send(JSON.stringify(message));
};

function getTweetStream(query) {
  const initialPromise = twitter.get('search/tweets', { q: query });
  const stream = twitter.stream('statuses/filter', { track: query });

  return Observable.fromPromise(initialPromise)
    .flatMap(tweets => tweets.statuses.slice(0, 10))
    .concat(Observable.fromEvent(stream, 'data'));
}

const tweets$ = getTweetStream(QUERY);

function randomDelayTime() {
  const minTime = 1000;
  const maxTime = 5000;

  return Math.floor(Math.random() * maxTime) + minTime;
}

wss.on('connection', (ws) => {
  const subscription = tweets$
    .shareReplay(10)
    .concatMap(tweet => Observable.of(tweet).delay(randomDelayTime()))
    .subscribe(streamTo(ws));

  ws.on('close', () => {
    subscription.dispose();
  });
});

app.use(cors());

const users = {};

function cacheUser(user) {
  users[user.screen_name] = user;
}

function retrieveUser(screenName) {
  const cachedUser = users[screenName];

  if (cachedUser) {
    return Promise.resolve(cachedUser);
  }

  const options = {
    screen_name: screenName,
  };

  return twitter.get('users/show', options)
    .then((user) => {
      cacheUser(user);
      return user;
    });
}

app.get('/user/:screenName', (req, res, next) => {
  retrieveUser(req.params.screenName)
    .then(user => res.send(user))
    .catch(next);
});

server.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Server listening at http://localhost:${PORT}`);
});
