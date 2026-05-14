:: Check if NodeJS is in the right version before running the program
@echo off
(node --version & echo.) >2 & (set /p ver=)<2

if NOT %ver:~1,2% == 22 (goto changenode) else (goto start)

:changenode
nvm use 22
:: Espera 1 segundo para as mudanças ficarem disponíveis
timeout /t 1

:start
npm run dev