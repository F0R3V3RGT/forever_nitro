fx_version 'adamant'

game 'gta5'

description 'F0R3V3R NITRO'

version '1.0.0'

server_scripts {
    '@es_extended/locale.lua',
    'locales/pt.lua',
    'locales/en.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/pt.lua',
    'locales/en.lua',
    'config.lua',
    'client/main.lua'
}

dependecies {
    'progressBars'
}
