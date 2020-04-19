fx_version 'adamant'

game 'gta5'

description 'ESX Drugs by Tigo'
name 'ESX Drugs'
author 'TigoDevelopment'
contact 'me@tigodev.com'
version '1.0.0'

server_scripts {
    '@async/async.lua',
    '@es_extended/locale.lua',

    'configs/client.lua',
    'configs/server.lua',

    'locales/nl.lua',
    'locales/en.lua',

    'server/common.lua',

    'shared/shared.lua',

    'server/zones/harvest.lua',
    'server/zones/sell.lua',
    'server/zones/transform.lua',

    'server/process.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',

    'configs/client.lua',

    'locales/nl.lua',
    'locales/en.lua',

    'client/common.lua',

    'shared/shared.lua',

    'client/main.lua'
}

dependencies {
    'async',
    'es_extended'
}