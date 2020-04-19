ServerConfig = {}

ServerConfig.DetermineLimit = 'weight' -- Possible options are: Weight or Limit
ServerConfig.SyncPoliceInterval = 5 * 60000 -- how often to sync the number of police in milliseconds

ServerConfig.Zones = {
	HarvestWeed	= {
		position = vector3(841.24, 2168.06, 51.28),
        whitelistedFor = { },
		blacklistedFor = { 'police', 'offpolice', 'ambulance' },
		requiredCops = 0,
		timeToHarvest = 4.5,
		type = 'harvest',
		outputs = {
			{
                item = 'weed',
			    count = 1
			}
		},
		blip = {
			onMap = true,
			sprite = 496,
			colour = 25
		}
	},
	TransformWeed = {
		position = vector3(118.49, -1951.12, 19.74),
        whitelistedFor = { },
		blacklistedFor = { 'police', 'offpolice', 'ambulance' },
		requiredCops = 1,
		timeToTransform = 4.0,
		type = 'transform',
		inputs = {
			{
                item = 'weed',
			    count = 5
            }
		},
		outputs = {
			{
                item = 'weed_pooch',
			    count = 1
            }
		},
		blip = {
			onMap = true,
			sprite = 496,
			colour = 25
		}
	},
	SellWeed = {
        position = vector3(-59.86, -2415.37, 5.0),
        whitelistedFor = { },
		blacklistedFor = { 'police', 'offpolice', 'ambulance' },
		requiredCops = 1,
		timeToSell = 3.5,
		type = 'sell',
		inputs = {
			{
                item = 'weed_pooch',
			    count = 1
            }
		},
		outputs = {
			{
                account = 'black_money',
                price = {
                    min = 500,
                    max = 800,
                    requiredCopsForMax = 4
                }
            }
		},
		blip = {
			onMap = true,
			sprite = 496,
			colour = 25
		}
	},
	HarvestCoke	= {
        position = vector3(690.15, -716.45, 25.07),
        whitelistedFor = { },
		blacklistedFor = { 'police', 'offpolice', 'ambulance', 'offambulance' },
		requiredCops = 2,
		timeToHarvest = 5.0,
		type = 'harvest',
		outputs = {
			{
                item = 'coke',
			    count = 1
            }
		}
	},
	TransformCoke = {
        position = vector3(2520.45, -415.46, 93.11),
        whitelistedFor = { },
		blacklistedFor = { 'police', 'offpolice', 'ambulance', 'offambulance' },
		requiredCops = 2,
		timeToTransform = 4.5,
		type = 'transform',
		inputs = {
			{
                item = 'coke',
			    count = 5
            }
		},
		outputs = {
			{
                item = 'coke_pooch',
			    count = 1
            }
		}
	},
	SellCoke = {
        position = vector3(66.22, 6913.41, 12.16),
        whitelistedFor = { },
		blacklistedFor = { 'police', 'offpolice', 'ambulance', 'offambulance' },
		requiredCops = 2,
		timeToSell = 4.0,
		type = 'sell',
		inputs = {
			{
                item = 'coke_pooch',
			    count = 1
            }
		},
		outputs = {
			{
                account = 'black_money',
                price = {
                    min = 700,
                    max = 1000,
                    requiredCopsForMax = 5
                }
            }
		}
	},
	HarvestOpium	= {
        position = vector3(-1166.33, 4926.28, 222.06),
        whitelistedFor = { },
		blacklistedFor = { 'police', 'offpolice', 'ambulance', 'offambulance' },
		requiredCops = 3,
		timeToHarvest = 5.5,
		type = 'harvest',
		outputs = {
			{
                item = 'opium',
			    count = 1
            }
		}
	},
	TransformOpium = {
        position = vector3(-913.01, 108.25, 54.51),
        whitelistedFor = { },
		blacklistedFor = { 'police', 'offpolice', 'ambulance', 'offambulance' },
		requiredCops = 3,
		timeToTransform = 5.0,
		type = 'transform',
		inputs = {
			{
                item = 'opium',
			    count = 5
            }
		},
		outputs = {
			{
                item = 'opium_pooch',
			    count = 1
            }
		}
	},
	SellOpium = {
        position = vector3(-840.99, -398.95, 30.47),
        whitelistedFor = { },
		blacklistedFor = { 'police', 'offpolice', 'ambulance', 'offambulance' },
		requiredCops = 3,
		timeToSell = 4.5,
		type = 'sell',
		inputs = {
			{
                item = 'opium_pooch',
			    count = 1
            }
		},
		outputs = {
			{
                account = 'black_money',
                price = {
                    min = 900,
                    max = 1200,
                    requiredCopsForMax = 6
                }
            }
		}
	}
}