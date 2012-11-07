:: Permet de lancer toutes les configs flexget les unes arès les autres
:: Pour la config 'subs' (sous-titres), une opération "d'oubli" est effectuée
:: après le flexget pour permettre le téléchargement de plusieurs sous-titres
:: pour un même épisode.

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

:: Lancement de la procédure "d'oubli"
echo ---====##### 'Oubli' des episodes dans la base de donnee "subs" de flexget... #####====---
if EXIST temp\seriesToForget.tmp (
	for /f "delims=" %%A in (temp\seriesToForget.tmp) do (
		:: Forget de l'épisode de la série dans la base
		flexget -c d:\telech\flexget\subs.yml --series-forget %%A
	)
	del temp\seriesToForget.tmp
) 
if EXIST temp\titleToForget.tmp (
	for /f "delims=" %%A in (temp\titleToForget.tmp) do (
		:: Forget du titre de l'épisode (pour ne plus qu'il soit noté en 'seen')
		flexget -c d:\telech\flexget\subs.yml --forget %%A
	)
	del temp\titleToForget.tmp
) 
if EXIST temp\urlToForget.tmp (
	for /f "delims=" %%A in (temp\urlToForget.tmp) do (
		:: On passe l'url 'déwritée' en 'seen' pour ne pas télécharger à nouveau le même fichier
		flexget -c d:\telech\flexget\subs.yml --seen %%A
	)
	del temp\urlToForget.tmp
) 