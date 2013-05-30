# trello-campfire

Parse Trello activity feed into Campfire.

## Setup
Get your [Trello API key](https://trello.com/1/appKey/generate) and [Trello API token](https://trello.com/docs/gettingstarted/index.html#getting-a-token-from-a-user), then clone the repo or:

```
$ gem install trello-campfire
```

## Usage
To start the daemon:

```
$ trello-campfire start -- --campfire-subdomain <campfire subdomain> --campfire-token <campfire token> --campfire-room-name <campfire room> --trello-board-id <trello board id> --trello-api-key <trello api key> --trello-api-token <trello api token>
```

To stop the daemon:

```
$ trello-campfire stop
```

## Heroku
1. Clone the repo
2. Create a new Heroku app: `heroku create`
3. Push: `git push heroku master`
4. Set your config vars:

```
heroku config:set TRELLO_API_KEY=fill_me_in TRELLO_API_TOKEN=fill_me_in TRELLO_BOARD_ID=fill_me_in CAMPFIRE_SUBDOMAIN=fill_me_in CAMPFIRE_ROOM=fill_me_in CAMPFIRE_TOKEN=fill_me_in UPDATE_INTERVAL=30
```

Also, you may need to start your worker: `heroku ps:scale worker=1`

## Credits
trello-campfire is brought to your by [Simon de Carufel](http://rufel.ca/) and [contributors to the project](https://github.com/simondec/trello-campfire/contributors). If you have feature suggestions or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/simondec/trello-campfire/issues).
