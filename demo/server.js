const http = require('http');
const Twitter = require('twitter');
const WebSocketServer = require('ws').Server;
const app = require('express')();
const cors = require('cors');
const { Observable } = require('rx');

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const PORT = process.env.PORT;
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

// const send = message => client => client.send(message);

// function notifyClients(tweet) {
//   wss.clients.forEach(send(JSON.stringify(tweet)));
// }

const streamTo = client => (message) => {
  client.send(JSON.stringify(message));
};

function getTweetStream(query) {
  const initialPromise = twitter.get('search/tweets', { q: query });
  const stream = twitter.stream('statuses/filter', { track: query });

  // const initialTweets$ = Observable.fromPromise(initialPromise)
  //   .flatMap(tweets => tweets.statuses.slice(0, 10));
  // const newTweets$ = Observable.fromEvent(stream 'data');
  // const source$ = Observable.merge(initialTweets$, newTweets$);

  const source$ = Observable.fromPromise(initialPromise)
    .flatMap(tweets => tweets.statuses.slice(0, 10))
    .concat(Observable.fromEvent(stream, 'data'));

  return source$;

  // let closed = false;
  // let subscription;

  // const api = {
  //   subscribe(fn) {
  //     if (!subscription) {
  //       subscription = source$.subscribe(fn);
  //     }

  //     return api;
  //   },

  //   close() {
  //     if (!closed && subscription) {
  //       subscription.dispose();
  //       stream.destroy();
  //       closed = true;
  //     }

  //     return api;
  //   },
  // };

  // return api;
}

// const replay = n => x => x.take(n).repeat(n);

const tweets$ = getTweetStream(QUERY);

function randomDelayTime() {
  const minTime = 1000;
  const maxTime = 5000;

  return Math.floor(Math.random() * maxTime) + minTime;
}

wss.on('connection', (ws) => {
  // const stream = getTweetStream(QUERY).subscribe(streamTo(ws));

  const subscription = tweets$
    // .replay(replay(10), 10)
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
