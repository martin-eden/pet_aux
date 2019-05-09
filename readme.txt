Does not work in 2019!

Sorry guys, Blizz now requires passport to obtain AuthID. Fuck them.

I'll keep code locally for tinkering but this repository will be
deleted: 
  * I can't test it's current functionality
  * my account was BANNED FOREWER in WoW. Feels like medal of honour.
  * I'm tired of WoW. I've tried and saw a lot of thinkgs while I
    was playing 2009/2015

--
This is project from the "gray zone" of World of Warcraft.
It downloads current auction snapshots for given realms and
finds minimal prices for given pets on realm. (1)

It may be used for lazy crossrealm pet trading.

All business-level configuration is in "config.lua". (2)

Requirements:
  bash
  wget
  lua >= 5.2

  Internal http-requests to Blizzard uses my API key. To stay
  completely clear you'd better to register at
  https://dev.battle.net/member/register and obtain your own API
  key. Place your key's value in "api_key" variable in "run_me.sh".

Usage:
  Edit or verify "config.lua" to assure it list realm and pet lists
  you need. (You can see exact pet names in "data/species.lua" and
  realm names in "data/realms.lua". This files should appear after
  first run.)

  bash run_me.sh

  Results in "results.lua"
    To get more readable version,

      cd ./lua
      lua display_results.lua

    You'll get a list sorted by pet name. Something like

                 [pet_name]         [bracket] [price_place] [realm]        [price]
      ...
      Wretched Servant                    1..24  (1)  Chamber of Aspects     285
      Wretched Servant                    1..24  (2)  Ravencrest             300
      Wretched Servant                    1..24  (3)  Saurfang               301
      Wretched Servant                       25  (1)  Chamber of Aspects    3699
      Wretched Servant                       25  (2)  Saurfang              5500
      Yellow Moth                         1..24  (1)  Saurfang                20
      Yellow Moth                         1..24  (2)  Chamber of Aspects      50
      Yellow Moth                         1..24  (3)  Ravencrest             100
      Yellow Moth                            25  (1)  Ravencrest            3406
      ...

    It should be easy to grep it for given name or even for say
    "25-level pets which have 3-digits price".

    "display_results.lua" also supports second optional parameter
    to limit length of list for each [pet_name]-[bracket]-[realm] tuple.
    Default value is 2 so maximum list length is 3 (pet-bracket-realm
    tuple with minimal price plus up to 2 tuples with next after
    minimal price.)

Code
  Every single line of code here is written by me. This code have
  no external dependencies, no extra libraries/repositories/rocks
  are required. "workshop" contains part of my personal repository.
  Anyway I can not limit you, use it as you want. I just wish you
  never say that it's you wrote it.

Happy trading!

2016-06-26


[1]
  It divides each pet in two brackets: level 1..24 and level 25.
  No pet breeds and no pet quality division is implemented as I had
  no much need to do it.

[2]
  "config.lua" is just a lua script which should return table with
  two fields:

    servers (table)
    pet_names (table)

  <servers> - array of strings. Each string should be official name
    of realm.

    Example: {"Blade's Edge", 'Chamber of Aspects'}

  <pet_names> - array of strings or nil. Each string should be full
    name of pet. If nil is returned then price roster is built for
    all pets on auction.

    Example:
      {
        'Gusting Grimoire',
        'Hippogryph Hatchling',
        "Landro's Lil' XT",
      }
