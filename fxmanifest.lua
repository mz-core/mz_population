fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'mz_population'
author 'Mazus / MZ Framework'
description 'Virtual and statistical population foundation for the MZ Framework'
version '0.1.0'

server_only 'yes'

server_scripts {
  'config.lua',
  'data/regions.lua',
  'data/zones.lua',
  'shared/util.lua',
  'shared/validation.lua',
  'server/state.lua',
  'server/service.lua',
  'server/simulation.lua',
  'server/exports.lua',
  'server/main.lua'
}
