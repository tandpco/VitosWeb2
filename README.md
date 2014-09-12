VitosWeb
=========

## Local Installation
```bash
bundle install
npm i
gem install rerun
```

> Also install grunt and mongo server running locally if you don't already have it.

## Running The Server
This will watch any changes you make and restart the server.
```bash
rerun thin start --pattern "*.rb"
```

## Compiling Angular + Stylus
Use grunt to compile any of the files in `./src` which compile the angular app and also the style.
```bash
grunt watch
```

## Compiling SASS
```bash
cd ./src/sass
compass watch
```

## Managing Todos
If you're using sublime, you can install TodoReview and run it in order to track all the todos in code. If you run into **anything** while you're working, please be sure to add a todo with the syntax `@TODO: YOUR MESSAGE`. This will make sure nothing gets missed and everything gets resolved.
