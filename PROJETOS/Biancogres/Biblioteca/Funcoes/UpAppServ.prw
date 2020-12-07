#include "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "fileio.ch"
#include "FOLDER.CH"
#include 'DBTREE.CH'

User Function AtualForm()
Local oCaminho
Local olocal
Local oSay
Local _nDiskSpc	:=	0

Private oCheckBo1
Private lCheckBo1 := .F.
Private oDlg


DEFINE MSDIALOG oDlg TITLE "Realização de Troca a Quente" FROM 180, 180  TO 580, 700 COLORS 0, 16777215 PIXEL

@ 025, 005 SAY "Path Instalação "  SIZE 050, 007 PIXEL OF oDlg
@ 040, 005 SAY "SourcePath (Slave1) "   SIZE 050, 007 PIXEL OF oDlg
@ 055, 005 SAY "Qtd. de Slaves " SIZE 050, 007 PIXEL OF oDlg
@ 070, 005 SAY "Versão Atual " SIZE 050, 007 PIXEL OF oDlg
@ 070, 100 SAY "Prox. Versão?" SIZE 050, 007 PIXEL OF oDlg

//Caminho da instalação do Protheus.
cTGet1 := "T:\Protheus\"
oTGet1 := TGet():New( 25,60,{|u| If(PCount()>0,cTGet1:=u,cTGet1)},oDlg,100,009,"@!",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGet1",,)
//Recebe o SourcePath contido no Slave1.
cTGet2 := ""
oTGet2 := TGet():New( 40,60,{|u| If(PCount()>0,cTGet2:=u,cTGet2)},oDlg,200,009,"@!",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGet2",,)
//Quantidade de Slaves contidos no servidor.
cTGet3 := "10"
cTget3 := PADL(cTGet3,2,"0")
oTGet3 := TGet():New( 55,60,{|u| If(PCount()>0,cTGet3:=u,cTGet3)},oDlg,010,009,"@R 99",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGet3",,)

cTGet4 := ""
cTGet5 := ""
oTGet5 := TGet():New( 70,060,{|u| If(PCount()>0,cTGet5:=u,cTGet5)},oDlg,015,009,"@R 999",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGet5",,)
cTGet6 := ""
oTGet6 := TGet():New( 70,150,{|u| If(PCount()>0,cTGet6:=u,cTGet6)},oDlg,015,009,"@R 999",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGet6",,)


__nRemLin := 80
@ 015+__nRemLin, 005 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "Atualizar Ambiente REMOTO?" SIZE 081, 008 OF oDlg COLORS 0, 16777215 PIXEL
@ 025+__nRemLin, 005 SAY "Path Instalação "  SIZE 050, 007 PIXEL OF oDlg
@ 040+__nRemLin, 005 SAY "SourcePath (Slave1) "   SIZE 050, 007 PIXEL OF oDlg
@ 055+__nRemLin, 005 SAY "Qtd. de Slaves " SIZE 050, 007 PIXEL OF oDlg
@ 070+__nRemLin, 005 SAY "Versão Atual " SIZE 050, 007 PIXEL OF oDlg
@ 070+__nRemLin, 100 SAY "Prox. Versão?" SIZE 050, 007 PIXEL OF oDlg

//Caminho da instalação do Protheus.
cTGetRem1 := "T:\Protheus\"
oTGetRem1 := TGet():New( 25+__nRemLin,60,{|u| If(PCount()>0,cTGetRem1:=u,cTGetRem1)},oDlg,100,009,"@!",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGetRem1",,)
//Recebe o SourcePath contido no Slave1.
cTGetRem2 := ""
oTGetRem2 := TGet():New( 40+__nRemLin,60,{|u| If(PCount()>0,cTGetRem2:=u,cTGetRem2)},oDlg,200,009,"@!",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGetRem2",,)
//Quantidade de Slaves contidos no servidor.
cTGetRem3 := "3"
oTGetRem3 := TGet():New( 55+__nRemLin,60,{|u| If(PCount()>0,cTGetRem3:=u,cTGetRem3)},oDlg,010,009,"@R 99",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGetRem3",,)

cTGetRem4 := ""
cTGetRem5 := ""
oTGetRem5 := TGet():New( 70+__nRemLin,060,{|u| If(PCount()>0,cTGetRem5:=u,cTGetRem5)},oDlg,015,009,"@R 999",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGetRem5",,)
cTGetRem6 := ""
oTGetRem6 := TGet():New( 70+__nRemLin,150,{|u| If(PCount()>0,cTGetRem6:=u,cTGetRem6)},oDlg,015,009,"@R 999",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGetRem6",,)

_nDiskSpc	:=	fGetDskSpc()

@ 100+__nRemLin, 005 SAY "Espaço Disponível no Drive D: " + Alltrim(Str(_nDiskSpc)) + " GB" SIZE 200, 007 PIXEL OF oDlg


oTButton1 := TButton():New( 100+__nRemLin, 175, "Atualizar",oDlg,{|| U_UProcessa() } , 80,10,,,.F.,.T.,.F.,,.F.,,,.F. )

cTGet2 := U_BuscaVers(1,1,cTGet1+"bin\")
cTGetRem2 := U_BVersRem(1,1,cTGetRem1+"bin\")


If Empty(cTGet2)
	Alert("Não foi possível encontrar o SourcePath do slave1!")
	oTButton1:Enable(.F.)
ElseIf _nDiskSpc < 5
	Alert("Não há espaço em disco suficiente na unidade D: para realizar a troca a quente!")
	oTButton1:Hide(.T.)
Else
	oTButton1:Enable(.T.)
EndIf

cPathServ := Substr(cTGet2, Len("SourcePath=") + 1)
cPathServ := Substr(cPathServ, 1, Len(cPathServ) - 3)
cVersServ := Substr(cTGet2, Len(cTGet2) - 2 ,Len(cTGet2))

cTGet4 := cPathServ
cTGet5 := cVersServ
cTGet6 := Soma1(cVersServ)

//REMOTO
cPathRem := Substr(cTGetRem2, Len("SourcePath=") + 1)
cPathRem := Substr(cPathRem, 1, Len(cPathRem) - 3)
cVersRem := Substr(cTGetRem2, Len(cTGetRem2) - 2 ,Len(cTGetRem2))

cTGetRem4 := cPathRem
cTGetRem5 := cVersRem
cTGetRem6 := Soma1(cVersRem)

ACTIVATE DIALOG oDlg CENTERED

return

//Chama função para atualização
User Function UProcessa()

Processa( {|| U_UpAppServ(cTGet1+"apo\PRODUCAO\",cTGet1+"bin\",cTGet5,cTGet6,val(cTGet3))  } )

If (lCheckBo1)
	Processa( {|| U_UpAppServ(cTGetRem1+"apo\REMOTO\",cTGetRem1+"bin\",cTGetRem5,cTGetRem6,val(cTGetRem3), .T.)  } )
EndIf

Return

//FUNÇÃO PARA ATUALIZAR OS SLAVE's
User Function UpAppServ(cpServ, cpBin, cpVersao,cpNovaVer, npQtd, lRemoto)
Local cPathServ := cpServ
Local cPathBin  := cpBin
Local cDirProd  := cpVersao
Local cDirNovo  := cpNovaVer
Local cLinha    := ""
Local fDirProd := {}
Local fDirNovo := {}
Local fDirAux  := {}
Local fArqIni
Local fAtual
Local fNovo
Local aArqs := Directory(cPathServ + "*.*", "D")
Local nTamArq := Len(aArqs)
Local nQtdApp := npQtd
Local nX := 1

Default lRemoto := .F.

Private cNomeRPO  := "tttp120.rpo"

/*
1	cNome		F_NAME
2	cTamanho	F_SIZE
3	dData		F_DATE
4	cHora		F_TIME
5	cAtributos	F_ATT
*/

If !Empty(cDirNovo)
	aAuxDir := Directory(cpServ+cDirNovo +"*.*", "D")
	lnaoExist := (Len(aAuxDir) == 0)
	If (CopiaArq(cpServ+cDirNovo, lnaoExist))
		fDirNovo := Directory(cpServ+cDirNovo +"*.*", "D")
		fDirProd := Directory(cpServ+cpVersao +"*.*", "D")
	EndIf
Else
	For nX := 1 to nTamArq
		cLog := ('Arquivo: ' + aArqs[nX,1] + ' - Size: ' + AllTrim(Str(aArqs[nX,2])) )
		cLog := cLog
		
		fDirAux  := aArqs[nX]
		
		If (fDirAux[1] == cDirProd)
			fDirProd := fDirAux
		EndIf
		
		If Len(fDirProd) > 0 .And. aArqs[nX] != fDirProd
			If (fDirProd[3] <= aArqs[nX,3]) .And. (fDirProd[4] < aArqs[nX,4])
				
				If Len(fDirNovo) == 0
					fDirNovo := fDirAux
				ElseIf fDirAux[1] > fDirNovo[1]
					fDirNovo := fDirAux
				EndIf
				
			EndIf
		EndIf
		
	Next nX
EndIf

//Se conheço o diretorio em produção e se há atualização (novo diretório)
//Então procura o arquivo *.rpo e verifica se realmente tem atualização.
If Len(fDirProd) > 0 .And. Len(fDirNovo) > 0
	
	If(MSGYESNO("A nova versão foi carregada! Gostaria de Atualiza-la?","Atualização"))
		
		nY 			:= 1
		Enter       := CHR(13)+CHR(10)

		//Monta Regua 
		ProcRegua(10)		
		
		For nX := 1 to nQtdApp
			
			If !lRemoto
				IncProc("Atualizando Slave... "+Str(nX))
			Else
				IncProc("Atualizando Slave (REMOTO)... "+Str(nX))
			EndIf
			
			cArquivo	:= ''
			lAchou 	:= .F.
			lErro   := .F.
			
			If !lRemoto
				cAuxPath:= cPathBin +"appserver_slave"+ AllTrim(STRZERO(nX,2))+"\appserver.ini"
			Else
				cAuxPath:= cPathBin +"appserver_remoto_slave"+ AllTrim(STRZERO(nX,2))+"\appserver.ini"
			EndIf
			
			fArqIni := FT_FUSE(cAuxPath)
			
			While !FT_FEOF()
				IncProc()
				cBuffer := FT_FREADLN()
				//Se encontrar a TAG Produção, procuro SourcePath
				
				If AllTrim(cBuffer) == IIf(!lRemoto,"[PRODUCAO]","[REMOTO]") .And. !lAchou
					
					cArquivo += cBuffer + Enter
					
					FT_FSKIP()
					cBuffer := FT_FREADLN()
					
					While !FT_FEOF() .And. !lAchou .And. !lErro
						
						If SubStr(cBuffer,1,Len("SourcePath")) == "SourcePath"
							cArquivo += Substr(cBuffer, 1, Len(cBuffer) - 3) + fDirNovo[1,1]+ Enter
							//cArquivo+= "SourcePath="+ cPathServ + fDirNovo[1] + Enter
							lAchou := .T.
						ElseIf SubStr(cBuffer,1,1) == "["
							Alert("Não foi possível achar a Tag SourcePath. Favor verificar o arquivo " + cAuxPath)
							lErro := .T.
							Exit
						Else
							cArquivo += cBuffer +" "+ Enter
						EndIf
						
						FT_FSKIP()
						cBuffer := FT_FREADLN()
					End
				Else
					cArquivo += cBuffer + Enter
					FT_FSKIP()
				EndIf
			End
			FT_FUSE()
			FERASE(cAuxPath)
			fNovoIni := fCreate(cAuxPath,2)
			If fNovoIni > 0
				fWrite(fNovoIni,cArquivo)
				fClose(fNovoIni)
			Else	
				Alert("Não foi possível criar o Arquio INI em " + cAuxPath +". Favor copiar as configurações.")
				Aviso(cArquivo,{"OK"}, 3 )
			EndIf
			
	    Next nX
	    
	    If lRemoto
	    
	    	IncProc("Atualizando WEBAPP")
			
			cArquivo	:= ''
			lAchou 	:= .F.
			lErro   := .F.
			
			cAuxPath:= cPathBin +"appserver_remoto_webapp\appserver.ini"
			
			fArqIni := FT_FUSE(cAuxPath)
			
			While !FT_FEOF()
				IncProc()
				cBuffer := FT_FREADLN()
				//Se encontrar a TAG Produção, procuro SourcePath
				
				If AllTrim(cBuffer) == "[REMOTO]" .And. !lAchou
					
					cArquivo += cBuffer + Enter
					
					FT_FSKIP()
					cBuffer := FT_FREADLN()
					
					While !FT_FEOF() .And. !lAchou .And. !lErro
						
						If SubStr(cBuffer,1,Len("SourcePath")) == "SourcePath"
							cArquivo += Substr(cBuffer, 1, Len(cBuffer) - 3) + fDirNovo[1,1]+ Enter
							lAchou := .T.
						ElseIf SubStr(cBuffer,1,1) == "["
							Alert("Não foi possível achar a Tag SourcePath. Favor verificar o arquivo " + cAuxPath)
							lErro := .T.
							Exit
						Else
							cArquivo += cBuffer +" "+ Enter
						EndIf
						
						FT_FSKIP()
						cBuffer := FT_FREADLN()
					End
				Else
					cArquivo += cBuffer + Enter
					FT_FSKIP()
				EndIf
			End
			FT_FUSE()
			FERASE(cAuxPath)
			fNovoIni := fCreate(cAuxPath,2)
			If fNovoIni > 0
				fWrite(fNovoIni,cArquivo)
				fClose(fNovoIni)
			Else	
				Alert("Não foi possível criar o Arquio INI em " + cAuxPath +". Favor copiar as configurações.")
				Aviso(cArquivo,{"OK"}, 3 )
			EndIf
	    
	    EndIf
	    
	    MsgInfo("A operação foi realizada com sucesso!", "Troca a Quente") 
	Else
		Alert("Operação Cancelada pelo usuário!")
		Return
	EndIf
	oDlg:End()
EndIf
Return

Static Function CopiaArq(cpNovoDir,nGera)
Local lSucess := .F.

If nGera
	If(MakeDir(cpNovoDir)!=0)
		Alert("Falha ao gerar diretório.")
	EndIf
EndIf

If !FILE(cpNovoDir+"\"+cNomeRPO)
	
	cArqOrig := "T:\Protheus\apo\COMPILACAO\"+cNomeRPO
	cArqDest := cpNovoDir+"\"+cNomeRPO
	If File(cArqOrig)                                                                  
		lSucess:= __copyfile(cArqOrig,cArqDest)
		if !lSucess
			Alert("Não foi possível copiar o arquivo!")
		EndiF
	EndIf                                                                       
Else
	lSucess := .T.
EndIf

Return lSucess

User Function BuscaVers(nIni,nFim,cpPathBin)
cRet := ""
For nIni := 1 to nFim
	lAchou 	:= .F.
	lErro   := .F.
	cAuxPath:= cpPathBin +"appserver_slave"+ AllTrim(STRZERO(nIni,2))+"\appserver.ini"
	fArqIni := FT_FUSE(cAuxPath)
	
	While !FT_FEOF()
		IncProc()
		cBuffer := FT_FREADLN()
		//Se encontrar a TAG Produção, procuro SourcePath
		If AllTrim(cBuffer) == "[PRODUCAO]" .And. !lAchou
			
			FT_FSKIP()
			cBuffer := FT_FREADLN()
			
			While !FT_FEOF() .And. !lAchou .And. !lErro
				If SubStr(cBuffer,1,Len("SourcePath")) == "SourcePath"
					cRet := cBuffer
					lAchou := .T.
					FT_FUSE()
					Return cRet
				ElseIf SubStr(cBuffer,1,1) == "["
					Alert("Não foi possível achar a Tag SourcePath. Favor verificar o arquivo " + cAuxPath)
					FT_FUSE()
					Return ""
					lErro := .T.
					Exit
				Else
					FT_FSKIP()
					cBuffer := FT_FREADLN()
				EndIf
			End
		EndIf
	End
	FT_FUSE()
Next nX
Return cRet

User Function BVersRem(nIni,nFim,cpPathBin)
cRet := ""
For nIni := 1 to nFim
	lAchou 	:= .F.
	lErro   := .F.
	cAuxPath:= cpPathBin +"appserver_remoto_slave"+ AllTrim(STRZERO(nIni,2))+"\appserver.ini"
	fArqIni := FT_FUSE(cAuxPath)
	
	While !FT_FEOF()
		IncProc()
		cBuffer := FT_FREADLN()
		//Se encontrar a TAG Produção, procuro SourcePath
		If AllTrim(cBuffer) == "[REMOTO]" .And. !lAchou
			
			FT_FSKIP()
			cBuffer := FT_FREADLN()
			
			While !FT_FEOF() .And. !lAchou .And. !lErro
				If SubStr(cBuffer,1,Len("SourcePath")) == "SourcePath"
					cRet := cBuffer
					lAchou := .T.
					FT_FUSE()
					Return cRet
				ElseIf SubStr(cBuffer,1,1) == "["
					Alert("Não foi possível achar a Tag SourcePath. Favor verificar o arquivo " + cAuxPath)
					FT_FUSE()
					Return ""
					lErro := .T.
					Exit
				Else
					FT_FSKIP()
					cBuffer := FT_FREADLN()
				EndIf
			End
		EndIf
	End
	FT_FUSE()
Next nX
Return cRet


Static Function fGetDskSpc()

Local _nHandle	:=	0
Local _nBuffer	:=	0

WaitRunSrv( "D:\PROTHEUS12\DiskSpace\diskspace.bat" , .t. , "D:\PROTHEUS12\DiskSpace" ) 

If (_nHandle := FT_FUSE("T:\DiskSpace\urano.txt")) > 0
	_nBuffer	:=	ROUND(Val(Replace(FT_FREADLN(),"D:","")) / (1024^3),2)

	FCLOSE(_nHandle)
EndIF



Return _nBuffer