fx_version 'cerulean'
game 'gta5'

author 'Stan Leigh'
description 'Advanced givecar + seizecar commands for QBCore (supports Tebex, ox_lib notifies, garage detection)'
version '1.3.2'

lua54 'yes'

shared_script '@qb-core/shared/locale.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    '@ox_lib/init.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'oxmysql'
}