local realms =
  {
    'Ravencrest',
    'Saurfang',
    "Blade's Edge",
    'Chamber of Aspects',
    -- 'Magtheridon',
    -- 'Outland',
    -- 'Fordragon',
    -- 'Gordunni',
    -- 'Blackscar',
    -- 'Galakrond',
  }

local card_game_pets =
  {
    'Bananas',
    'Dragon Kite',
    'Ethereal Soul-Trader',
    'Eye of the Legion',
    'Guardian Cub',
    'Gregarious Grell',
    'Gusting Grimoire',
    'Hippogryph Hatchling',
    "Landro's Lil' XT",
    'Nightsaber Cub',
    'Purple Puffer',
    'Rocket Chicken',
    'Sand Scarab',
    'Spectral Tiger Cub',
    'Tuskarr Kite',
  }

local expensive_pets =
  {
    'Albino River Calf',
    'Ammen Vale Lashling',
    'Aqua Strider',
    'Ashleaf Spriteling',
    'Azure Whelpling',
    'Bananas',
    'Black Tabby Cat',
    'Blackfuse Bombling',
    'Blazing Cindercrawler',
    'Bronze Whelpling',
    'Bush Chicken',
    'Chuck',
    'Coilfang Stalker',
    'Crawling Claw',
    'Crimson Whelpling',
    'Cursed Birman',
    'Dark Whelpling',
    'Darkmoon Eye',
    'Darkmoon Rabbit',
    'Death Adder Hatchling',
    'Disgusting Oozeling',
    'Dragon Kite',
    "Droplet of Y'Shaarj",
    'Dun Morogh Cub',
    'Durotar Scorpion',
    'Emerald Whelpling',
    'Enchanted Broom',
    'Ethereal Soul-Trader',
    'Eye of Observation',
    'Eye of the Legion',
    'Feline Familiar',
    'Festival Lantern',
    'Firefly',
    'Fox Kit',
    'Frigid Frostling',
    'Frostwolf Pup',
    'Giant Sewer Rat',
    'Gilnean Raven',
    'Glowing Sporebat',
    'Gooey Sha-ling',
    'Gregarious Grell',
    "Gu'chi Swarmling",
    'Guardian Cub',
    'Gulp Froglet',
    'Gundrak Hatchling',
    'Gusting Grimoire',
    'Hatespark the Tiny',
    'Hippogryph Hatchling',
    'Hyacinth Macaw',
    'Jade Owl',
    'Jadefire Spirit',
    'Jademist Dancer',
    'Ji-Kun Hatchling',
    'Kovok',
    'Land Shark',
    "Landro's Lil' XT",
    'Lanticore Spawnling',
    'Legs',
    'Living Fluid',
    'Lumpy',
    'Lunar Lantern',
    'Macabre Marionette',
    'Magical Crawdad',
    'Mechanopeep',
    'Mojo',
    'Moon Moon',
    'Muckbreath',
    'Mulgore Hatchling',
    'Netherspace Abyssal',
    'Nightmare Bell',
    'Nightsaber Cub',
    'Peanut',
    'Periwinkle Calf',
    'Pierre',
    'Porcupette',
    'Pterrordax Hatchling',
    'Purple Puffer',
    'Pygmy Direhorn',
    'Rascal-Bot',
    'Razzashi Hatchling',
    'Rocket Chicken',
    'Ruby Droplet',
    'Sand Scarab',
    'Savage Cub',
    'Scooter the Snail',
    'Sea Calf',
    'Seaborne Spore',
    'Searing Scorchling',
    "Sen'jin Fetish",
    'Shimmering Wyrmling',
    'Shore Crawler',
    'Son of Animus',
    'Spectral Porcupette',
    'Spectral Tiger Cub',
    'Speedy',
    'Spineclaw Crab',
    'Sprite Darter Hatchling',
    'Syd the Squid',
    'Teldrassil Sproutling',
    'Tiny Blue Carp',
    'Tiny Green Carp',
    'Tiny Red Carp',
    'Tiny White Carp',
    'Tirisfal Batling',
    'Tuskarr Kite',
    'Vengeful Porcupette',
    'Viscidus Globule',
    'Viscous Horror',
    'Whiskers the Rat',
    'Widget the Departed',
  }

local ethereal_tournament_pets =
  {
    'Anubisath Idol',
    'Ashstone Core',
    'Corefire Imp',
    'Darkmoon Tonk',
    'Darkmoon Zeppelin',
    'Death Talon Whelpguard',
    'Giant Sewer Rat',
    'Gilnean Raven',
    'Gregarious Grell',
    'Lesser Voidcaller',
    "Lil' Bling",
    'Macabre Marionette',
    'Mechanical Pandaren Dragonling',
    'Mojo',
    'Mr. Wiggles',
    'Snowshoe Rabbit',
    'Son of Animus',
    'Spectral Porcupette',
    'Stitched Pup',
    'Sunreaver Micro-Sentry',
    'Vengeful Porcupette',
    'Voodoo Figurine',
    'Zandalari Anklerender',
    'Zandalari Kneebiter',
  }

local darkmoon_pets =
  {
    'Darkmoon Cub',
    'Darkmoon Hatchling',
    'Darkmoon Monkey',
    'Darkmoon Tonk',
    'Darkmoon Turtle',
    'Darkmoon Zeppelin',
  }

local pets_to_levelup =
  {
    'Albino Chimaeraling',
    'Black Kingsnake',
    'Blue Dragonhawk Hatchling',
    'Blue Moth',
    'Bombay Cat',
    'Brilliant Spore',
    'Brown Rabbit',
    'Cockatiel',
    'Corefire Imp',
    'Cornish Rex Cat',
    'Crimson Snake',
    'Crimson Spore',
    'Dandelion Frolicker',
    'Death Talon Whelpguard',
    'Doom Bloom',
    "Father Winter's Helper",
    'Firewing',
    'Fishy',
    'Fruit Hunter',
    'Ghastly Kid',
    'Ghostly Skull',
    'Golden Dragonhawk Hatchling',
    'Great Horned Owl',
    'Grumpling',
    'Hawk Owl',
    'Hydraling',
    'Ikky',
    'Imperial Moth',
    'Imperial Silkworm',
    'Iron Starlette',
    'Leaping Hatchling',
    'Lifelike Mechanical Frostboar',
    'Lifelike Toad',
    "Lil' Bling",
    "Lil' Leftovers",
    'Living Sandling',
    'Macabre Marionette',
    'Magic Lamp',
    'Mana Wyrmling',
    'Meadowstomper Calf',
    'Mechanical Pandaren Dragonling',
    'Mechanical Squirrel',
    'Mr. Wiggles',
    'Nether Ray Fry',
    'Nightshade Sproutling',
    'Orange Tabby Cat',
    'Pandaren Air Spirit',
    'Pandaren Water Spirit',
    'Pengu',
    'Personal World Destroyer',
    'Razormaw Hatchling',
    'Red Dragonhawk Hatchling',
    'Red Moth',
    'Sea Pony',
    'Senegal',
    "Sentinel's Companion",
    'Servant of Demidos',
    'Shard of Cyrukh',
    'Siamese Cat',
    'Silver Dragonhawk Hatchling',
    'Silver Tabby Cat',
    'Sister of Temptation',
    'Smolderweb Hatchling',
    'Spring Rabbit',
    'Sunfire Kaliri',
    'Terrible Turnip',
    'Tickbird Hatchling',
    'Umbrafen Spore',
    'Undercity Cockroach',
    'Untamed Hatchling',
    'White Kitten',
    'White Moth',
    'White Tickbird Hatchling',
    'Wretched Servant',
    'Yellow Moth',
    'Zangar Spore',
  }

local pets =
  {
    -- [[ general trade
    -- 'Ammen Vale Lashling', --
    'Aqua Strider', --
    'Ashstone Core', --**
    'Bone Serpent', --
    'Cinder Pup', --
    'Corefire Imp', -- good seller, concurrency
    -- 'Chuck', --selled very long (4k)
    'Chrominius', --ok seller
    -- 'Crimson Spore', --
    'Dandelion Frolicker', -- good seller
    -- 'Dark Whelpling', -- hard to sell
    -- 'Darkmoon Cub', --
    -- 'Darkmoon Hatchling', --
    -- 'Darkmoon Monkey', --
    -- 'Darkmoon Tonk', --
    'Darkmoon Turtle', --
    -- 'Darkmoon Zeppelin', --
    'Death Talon Whelpguard', --** ok seller
    'Direhorn Runt', --** ok seller
    -- 'Disgusting Oozeling', -- 5k
    'Doom Bloom', --*
    -- 'Enchanted Broom', --
    'Elementium Geode', --
    -- 'Eye of Observation', -- good seller
    'Everbloom Peachick', --*
    "Father Winter's Helper", --
    -- 'Fishy', --
    -- 'Fox Kit', -- bad seller, concurrency
    -- 'Fragment of Desire', --
    -- 'Fragment of Suffering', --
    -- 'Frigid Frostling', --
    -- 'Enchanted Broom', -- concurrency
    -- 'Ghastly Kid', --sells ok
    -- 'Gilnean Raven', -- hard to sell
    -- 'Giant Bone Spider', --selled ok
    'Harbinger of Flame', -- too small profit
    -- 'Ikky', --
    'Iron Starlette', -- ok seller
    -- 'Jade Owl', --
    -- 'Land Shark', -- selled quick
    -- 'Lesser Voidcaller', -- too expensive to buy
    -- 'Lifelike Mechanical Frostboar', --
    'Leviathan Hatchling', --*
    "Lil' Bad Wolf", --*
    -- "Lil' Bling", --
    'Macabre Marionette', --
    -- 'Magic Lamp', --
    -- 'Mechanical Axebeak', -- too small profit
    -- 'Mechanical Pandaren Dragonling', --
    -- 'Mojo', --
    'Netherspawn, Spawn of Netherspawn', -- concurrency
    -- 'Nether Ray Fry', --
    -- 'Nightmare bell', -- selled quick
    -- 'Orange Tabby Cat', -- no demand
    -- 'Ore Eater', --
    -- 'Peddlefeet', --
    'Phoenix Hawk Hatchling', --*
    'Puddle Terror',
    -- 'Pint-Sized Pink Pachyderm', -- ok seller, too expensive to buy
    'Razzashi Hatchling', -- too rare to trade
    -- 'Ruby Droplet', -- 14k concurrency
    -- 'Savage Cub', -- good seller
    -- 'Sea Pony', --
    -- "Sen'jin Fetish", --
    'Sinister Squashling', --****
    -- 'Shard of Cyrukh', --
    -- 'Sky-Bo', --
    -- "Sentinel's Companion", --
    'Silver Dragonhawk Hatchling', --
    'Sister of Temptation', -- **
    'Snowshoe Rabbit', --
    -- 'Smolderweb Hatchling', --
    -- "Spawn of G'nathus", -- too expensive to buy
    -- 'Speedy', --selled for 1.8k
    -- 'Spectral Porcupette', --
    'Stitched Pup', --** good seller, too small profit
    -- 'Stonegrinder', --selled ok
    'Sunblade Micro-Defender', --*
    -- 'Sunreaver Micro-Sentry', -- too small profit
    -- 'Teroclaw Hatchling', --
    -- 'Tiny Red Carp', --
    'Toxic Wasteling', --***
    'Untamed Hatchling', --**
    -- 'Vengeful Porcupette', --
    'Voodoo Figurine', --**
    -- 'Widget the Departed', -- ok seller
    -- 'Winter Reindeer', --
    "Winter's Little Helper", --
    'Worg Pup', --**
    -- 'Wretched Servant', --
    'Young Talbuk', --*** selling ok
    -- 'Zandalari Anklerender', -- stable seller, пяткогрыз
    'Zandalari Footslasher', --* stable seller, пяткохлыстик
    -- 'Zandalari Kneebiter', -- stable seller, ногокус
    'Zandalari Toenibbler', --*****
    -- 'Zomstrok', --
    -- 'Zangar Spore', --
    --]]
  }

return
  {
    realms = realms, --require('all_realms'),
    pets = pets,
  }
