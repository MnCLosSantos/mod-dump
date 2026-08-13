fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Stan Leigh'
description 'Advanced Job Garage System'
version '1.3.8'

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'config.lua',
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'oxmysql',
    'qb-target',
    'qb-menu'
}