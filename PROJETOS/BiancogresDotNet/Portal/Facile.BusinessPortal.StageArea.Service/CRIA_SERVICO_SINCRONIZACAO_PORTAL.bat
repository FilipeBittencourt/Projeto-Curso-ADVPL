@echo off

Sc delete SincronizacaoRegistroPortal 
sc create SincronizacaoRegistroPortal binPath=C:\Users\Desenvolvimento1\Documents\Projetos\Biancogres\Projetos.NET\Portal\Facile.BusinessPortal.StageArea.Service\bin\Debug\Facile.BusinessPortal.StageArea.Service.exe DisplayName="_Sincronizacao-Registro-Portal"

pause