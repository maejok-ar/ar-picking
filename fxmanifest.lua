fx_version 'cerulean'
game 'gta5'

author 'MAEJOK <https://github.com/maej20>'
description 'Wild Cannabis Picking and Processing'
version '1.0.0'

client_scripts {
    'config.lua',
    'client/field.lua',
    'client/processing.lua',
}
server_scripts {
    'config.lua',
    'server/field.lua',
    'server/processing.lua',
}

dependencies {
    'qb-core'
}

lua54 'yes'