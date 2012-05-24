# trello-campfire

Parse Trello activity feed into Campfire.

## Setup
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

## Credits
trello-campfire is brought to your by [Simon de Carufel](http://rufel.ca/) and [contributors to the project](https://github.com/simondec/trello-campfire/contributors). If you have feature suggestions or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/simondec/trello-campfire/issues).