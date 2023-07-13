fx_version 'bodacious'
game 'gta5'

server_script {
'@mysql-async/lib/MySQL.lua',
"server/*.lua"
}

client_script {
'@mysql-async/lib/MySQL.lua',
"client/*.lua"
}  

author 'prolaktostatin'
