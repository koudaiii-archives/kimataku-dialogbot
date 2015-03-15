### kimataku 会話bot ###

    $ heroku apps:create
    $ heroku config:set TWITTER_CONSUMER_KEY=... TWITTER_CONSUMER_SECRET=... ...
    $ git push heroku master
#### FAQ

* Crashした際

    $ heroku ps:restart bot.1
