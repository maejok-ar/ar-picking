fx_version 'cerulean'
game 'gta5'

author 'MAEJOK <https://github.com/maej20>'
description 'Wild Cannabis Picking and Processing'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/field.lua',
    'client/processing.lua',
}
server_scripts {
    'server/field.lua',
    'server/processing.lua',
}

files {
    './locales/*.json'
}

dependencies {
    'ox_lib',
    'qb-core'
}

lua54 'yes'
