:: Permet de lancer toutes les configs flexget les unes ar�s les autres
:: Pour la config 'subs' (sous-titres), une op�ration "d'oubli" est effectu�e
:: apr�s le flexget pour permettre le t�l�chargement de plusieurs sous-titres
:: pour un m�me �pisode.

@echo off

:: Lancement de la config "t411" (torrent)
echo ---====##### Lancement de Flexget pour T411... #####====---
flexget -c d:\telech\flexget\t411.yml

:: Lancement de la config "prelist" (kvirc)
echo .
echo .
echo ---====##### Lancement de Flexget pour prelist... #####====---
flexget -c d:\telech\flexget\prelist.yml

:: Lancement de la config "subs" (sous-titres)
echo .
echo .
echo ---====##### Lancement de Flexget pour subs... #####====---
flexget -c d:\telech\flexget\subs.yml

:: Lancement de la proc�dure "d'oubli"
echo ---====##### 'Oubli' des episodes dans la base de donnee "subs" de flexget... #####====---
if EXIST temp\seriesToForget.tmp (
	for /f "delims=" %%A in (temp\seriesToForget.tmp) do (
		:: Forget de l'�pisode de la s�rie dans la base
		flexget -c d:\telech\flexget\subs.yml --series-forget %%A
	)
	del temp\seriesToForget.tmp
) 
if EXIST temp\titleToForget.tmp (
	for /f "delims=" %%A in (temp\titleToForget.tmp) do (
		:: Forget du titre de l'�pisode (pour ne plus qu'il soit not� en 'seen')
		flexget -c d:\telech\flexget\subs.yml --forget %%A
	)
	del temp\titleToForget.tmp
) 
if EXIST temp\urlToForget.tmp (
	for /f "delims=" %%A in (temp\urlToForget.tmp) do (
		:: On passe l'url 'd�writ�e' en 'seen' pour ne pas t�l�charger � nouveau le m�me fichier
		flexget -c d:\telech\flexget\subs.yml --seen %%A
	)
	del temp\urlToForget.tmp
) 