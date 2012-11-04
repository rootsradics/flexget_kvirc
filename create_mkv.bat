:: Génère un fichier MKV si les fichiers nécessaires (une vidéo et au moins 1 sous-titre) sont présents.
:: La génération se fait via mkvmerge.exe de l'outil "mkvtoolnix". L'exécutable est dans le path windows.
:: Utilisation :
::			create_mkv.bat "nomDeLaSerie" "SxxExx" "numeroDeLaSaison"

:: ToDo -> Afiner la création du mkv via mkvmerge en ajoutant des options

@echo off

:: Variables 'path' à renseigner
set dirBase=d:\telech\flexget\testdl\

:: Récupération des paramètres
set param1=%1
set serieName=%param1:"=%
set param2=%2
set serieId=%param2:"=%
set numSaison=%3
set numSaison=%param3:"=%

:: Initialisation des variables
set phrase=%serieName% %serieId%
set testFile=*%phrase: =*%*
set dirname="%1 - Saison %3 (VOSTFR)"
set dirname=%dirname:"=%
set pathComplet=%dirBase%%dirname%\

:: Comptage de tous les types de fichiers (.srt, .mkv .mp4 .avi)
set nbSrt=0
for %%a In ("%pathComplet%%testFile%.srt") do set /A nbSrt+=1
set nbMkv=0
for %%a In ("%pathComplet%%testFile%.mkv") do set /A nbMkv+=1
set nbMp4=0
for %%a In ("%pathComplet%%testFile%.mp4") do set /A nbMp4+=1
set nbAvi=0
for %%a In ("%pathComplet%%testFile%.avi") do set /A nbAvi+=1

:: Pour exécuter la création des MKV, il faut au moins un .srt et un .mkv/mp4/avi
if %nbSrt% == 0 goto :nofiles
if %nbMkv% GTR 0 goto :mkvtocreate
if %nbMp4% GTR 0 goto :mkvtocreate
if %nbAvi% GTR 0 goto :mkvtocreate
goto :nofiles

:mkvtocreate
:: Nécesaire pour la boucle for
setlocal enabledelayedexpansion

:: Boucle générant les paramètres à passer à l'outil mkmerge
echo Création du fichier mkv...
set tmp=
for %%A in ("%pathComplet%%testFile%") do (
	set tmp=!tmp! "%%A"
)

:: Nom du fichier MKV
set finalName=%phrase: =.%.VOSTFR.mkv

:: Lancement du programme mkvmerge avec les paramètres
mkvmerge -o "%pathComplet%%finalName%.tmp" %tmp%

:: Suppresion des fichiers
del %tmp%

:: Rename pour arriver au fichier final
ren "%pathComplet%%finalName%.tmp" "%finalName%"

:nofiles