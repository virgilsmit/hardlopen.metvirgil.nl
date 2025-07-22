# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Werkafspraak: Automatische server-restart

Na elke wijziging in de codebase wordt automatisch het volgende commando uitgevoerd:

```
sudo systemctl restart hardlopen-metvirgil.service
```

Hierdoor is de live server altijd direct up-to-date na elke aanpassing. Handmatig herstarten is niet meer nodig.
