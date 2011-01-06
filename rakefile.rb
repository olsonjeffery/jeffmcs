task :default => [:build]

@root = Dir.pwd
@serverPath = "#{@root}/server"
@worldPicPath = "#{@root}/worldpics"
@hmodPath = "#{@root}/src/hmod"
@bukkitPath = "#{@root}/src/bukkit"
@craftbukkitPath = "#{@root}/src/craftbukkit"

task :gitbar => [:setupserverdir, :gitserver, :runhmodserver]
task :gitserver => [:gitbuild, :bininstall]

task :runhmodserver do
  Dir.chdir @serverPath
  sh './server_nogui_hmod.sh'
end
task :runserver do
  Dir.chdir @serverPath
  sh './server_nogui.sh'
end

task :bininstall do
  Dir.chdir @serverPath
  sh "mv Minecraft_Mod.jar Minecraft_Mod.jar.old"
  sh "mv #{@root}/bin/Minecraft_Mod.jar ./"
  sh "mv minecraft_server.jar minecraft_server.jar.old"
  sh "mv #{@root}/bin/minecraft_server.jar ./"
  Dir.chdir @root
end

task :gitbuild => [:fetch_minecraft_server] do
  Dir.chdir "#{@hmodPath}/src"
  sh 'rm -f *.class *.jar'
  sh "javac *.java -cp #{@root}/bin/minecraft_server.jar && jar cvfm Minecraft_Mod.jar #{@root}/Manifest.mf *.class"
  sh "cp Minecraft_Mod.jar #{@root}/bin"
  Dir.chdir @root
end

task :fetch_minecraft_server do
  sh "wget http://minecraft.net/download/minecraft_server.jar -O #{@root}/bin/minecraft_server.jar"
end

def add_remote(user, repo)
  sh "git remote add #{user} git://github.com/#{user}/#{repo}.git"
  sh "git fetch #{user}"
end

task :reclone do
  sh "rm -Rf #{@hmodPath}"
  defaultRepo = "Minecraft-Server-Mod"
  sh "git clone git://github.com/traitor/#{defaultRepo}.git #{@hmodPath}"
  Dir.chdir @hmodPath
  add_remote "Dinnerbone", defaultRepo
  add_remote "angelsl", "hMod"
  add_remote "durron597", defaultRepo
  Dir.chdir @root
end

task :newpic do
  Dir.chdir @worldPicPath
  sh "./updatepic.sh"
  Dir.chdir @root
end

# new hottness for bukkit-based server. hopefully migrate to
# this soon.
task :bb do
  Dir.chdir @bukkitPath
  sh 'mvn clean compile package'
  sh "mvn install:install-file -DgroupId=org.bukkit -DartifactId=bukkit -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar -Dfile=#{@bukkitPath}/target/bukkit-0.0.1-SNAPSHOT.jar"
  Dir.chdir @root
end

task :cbb => [:bb] do
  Dir.chdir @craftbukkitPath
  sh 'mvn clean compile package'
  sh "cp target/craftbukkit*jar #{@root}/bin/craftbukkit.jar"
  Dir.chdir @root
end

task :cbinstall => [:cbb] do
  sh "cp -Rf #{@root}/bin/craftbukkit.jar #{@serverPath}/"
end

task :setupserverdir do
  sh "rm -Rf #{@serverPath}"
  sh "cp -Rf #{@root}/server-skeleton #{@serverPath}"
  sh "ln -sf #{@root}/world #{@serverPath}/world"
end

task :initcbserver => [:setupserverdir, :cbinstall]

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
