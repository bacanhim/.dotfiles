import subprocess
getVersion =  subprocess.Popen("checkupdates | wc -l", shell=True, stdout=subprocess.PIPE).stdout
version =  getVersion.read()
if(version.decode() == "0\n"):
	print("")
else:
	print(version.decode())