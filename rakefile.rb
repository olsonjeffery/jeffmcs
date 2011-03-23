task :default => [:build]

@root = Dir.pwd
@serverTemplate = "#{@root}/server_template"
@cbServerPath = "#{@root}/server_cb"
@nwServerPath = "#{@root}/server_nw"
@vanillaServerPath = "#{@root}/server_vanilla"
@worldPicPath = "#{@root}/worldpics"
@bukkitPath = "#{@root}/src/bukkit"
@craftbukkitPath = "#{@root}/src/craftbukkit"

def add_remote(user, repo)
  sh "git remote add #{user} git://github.com/#{user}/#{repo}.git"
  sh "git fetch #{user}"
end

def setupDirFromTemplate(serverDir, templateDir, worldDir, pluginDir)
  sh "rm -Rf #{serverDir}"
  sh "cp -Rf #{templateDir} #{serverDir}"
  sh "ln -sf #{worldDir} #{serverDir}/world"
  if pluginDir != false
    sh "ln -sf #{pluginDir} #{serverDir}/plugins"
  end
  sh "ln -sf #{@root}/schematics #{serverDir}/schematics"
end

# download, setup and run the vanilla server 
task :dovanilla => [:initvanilla, :runvanilla]

# vanilla server setup
task :initvanilla => [:fetch_minecraft_server] do
  setupDirFromTemplate @vanillaServerPath, @serverTemplate, "#{@root}/world", false
  sh "cp #{@root}/bin/minecraft_server.jar #{@vanillaServerPath}/"
end

task :runvanilla do
  Dir.chdir @vanillaServerPath
  sh "./server_nogui_vanilla.sh"
end

task :fetch_minecraft_server do
  sh "wget http://minecraft.net/download/minecraft_server.jar -O #{@root}/bin/minecraft_server.jar"
end

# craftbukkit build/setup

task :initcb => [:setupservercb, :installcb]

task :runcb do
  Dir.chdir @cbServerPath
  sh './server_nogui_cb.sh'
end

task :bb do
  Dir.chdir @bukkitPath
  sh 'mvn clean install'
  Dir.chdir @root
end

task :cbb => [:bb] do
  Dir.chdir @craftbukkitPath
  sh 'mvn clean package'
  sh "cp target/craftbukkit*jar #{@root}/bin/craftbukkit.jar"
  Dir.chdir @root
end

task :copybincb do
  sh "cp -Rf #{@root}/bin/craftbukkit.jar #{@cbServerPath}/"
end

task :installcb => [:cbb, :copybincb]

task :upgradecb => [:gitbukkit, :installcb]

task :setupservercb do
  setupDirFromTemplate @cbServerPath, @serverTemplate, "#{@root}/world", "#{@root}/plugins"
end

task :gitbukkit do
  sh "rm -Rf #{@bukkitPath}"
  sh "rm -Rf #{@craftbukkitPath}"
  sh "git clone git://github.com/Bukkit/Bukkit.git #{@bukkitPath}"
  sh "git clone git://github.com/Bukkit/CraftBukkit.git #{@craftbukkitPath}"
end

task :bukkitpull do
  Dir.chdir @bukkitPath
  sh 'git pull'
  Dir.chdir @craftbukkitPath
  sh 'git pull'
  Dir.chdir @root
end

# worldpic server management
task :newpic do
  sh "../mcmap/mcmap -from -35 -35 -to 35 35 -file webapp/public/worldpics/world.png ./world"
  sh "convert -size 500x500 webapp/public/worldpics/world.png -resize 500x500 webapp/public/worldpics/world_preview.png"
  sh "../mcmap/mcmap -night -from -35 -35 -to 35 35 -file webapp/public/worldpics/world_night.png ./world"
  sh "convert -size 500x500 webapp/public/worldpics/world_night.png -resize 500x500 webapp/public/worldpics/world_night_preview.png"
end

##################
### NEW WORLD
##################
task :copybinnw do
  sh "cp -Rf #{@root}/bin/craftbukkit.jar #{@nwServerPath}/"
end

task :setupservernw do
  setupDirFromTemplate @nwServerPath, @serverTemplate, "#{@root}/new_world", "#{@root}/plugins"
end

task :installnw => [:cbb, :copybinnw]

task :upgradenw => [:gitbukkit, :installnw]

task :initnw => [:setupservernw, :upgradenw]
task :runnw do
  Dir.chdir @nwServerPath
  sh "./server_nogui_cb.sh"
end
