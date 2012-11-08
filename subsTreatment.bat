:: Applique diff�rents traitemenst pour placer le(s) fichier(s) au bon endroit,
:: pr�ts � �tre ins�r�(s) dans un mkv. (unzip, rename, move, ...)
:: Ensuite, la cr�ation du mkv est lanc�e (create_mkv.bat).
:: Le script utilise unzip.exe qui doit �tre renseign� dans les variables
:: Utilisation :
::			subTreatment.bat "nomDuFichierZip" "nomDeLaSerie" "SxxExx" "numeroDeLaSaison"

:: ToDo -> il subsiste certainement des bugs si les path contiennent des espaces. A corriger.
:: ToDo -> ins�rer date/heure dans nom du fichier srt pour �viter les conflits de noms de fichiers
:: Todo -> g�rer les fichiers de sous-titres.eu (ils ont un rss). zipfile avec moult .str & .ass

@echo off
:: N�cesaire pour la boucle for
setlocal enabledelayedexpansion

:: Variables 'path' � renseigner
set dlDirectory=d:\telech\flexget\Downloads\
set unzipCommand=d:\telech\flexget\unzip.exe
set dirBase=d:\telech\flexget\testdl\

:: Variables de 'path'
set zipFile=%1
set zipFile=%zipFile:"=%
set dirname="%2 - Saison %4 (VOSTFR)"
set dirname=%dirname:"=%
set pathComplet=%dirBase%%dirname%\
set finalFileName=%2.%3.STFR.srt
set finalFileName=%finalFileName:"=%

:: Si le r�pertoire n'existe pas, on le cr�e
if not exist "%pathComplet%" (
echo Creating directory "%pathComplet%" ...
md "%pathComplet%"
echo ok.
)

:: Dezipping
echo unzipping "%dlDirectory%%zipFile%" ...
%unzipCommand% "%dlDirectory%%zipFile%" -d %dlDirectory%
echo ok.
:: Supression du .zip
echo Deleting "%dlDirectory%%zipFile%" ...
del "%dlDirectory%%zipFile%"
echo ok.

:: Boucle pour renommer tous les fichiers SRT pr�sents
echo Renaming and moving srt files to "%pathComplet%"...
set /A i=0
for %%A in ("%dlDirectory%*.srt") do (
	set /A i=!i!+1
	echo Rename "%%A" to !i!_%finalFileName% ...
	ren "%%A" "!i!_%finalFileName%"
	echo ok.
	echo Moving "%dlDirectory%!i!_%finalFileName%" in "%pathComplet%" ...
	move "%dlDirectory%!i!_%finalFileName%" "%pathComplet%"
	echo ok.
)

:: Appel du script de cr�ation du MKV
echo Creating MKV file if possible...
create_mkv.bat %2 %3 %4