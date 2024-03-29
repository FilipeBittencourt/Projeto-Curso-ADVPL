#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#Include "font.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "vkey.ch"

User Function BIA290()
Local lDebug := .T.
/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := BIA290
Empresa   := Biancogres Cer鈓ica S/A
Data      := 21/03/12
Uso       := WorkFlow
Aplica玢o := Conecta � caixa de e-mail definida para recepcionar os arquivos
.            XML envolvidos no processo de importa玢o autom醫ica das NFE's
.            Recep玢o autom醫ica de arquivo xml a partir de caixa de entrada
.            de e-mail
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

ConOut("HORA: "+TIME()+" - Iniciando Processo BIA290 - BIANCOGRES")

If lDebug
	U_WF_BIA290('01')
Else
	Startjob("U_WF_BIA290","SCHEDULE",.T.,"01")
EndIf

ConOut("HORA: "+TIME()+" - Finalizando Processo BIA290 - BIANCOGRES")

ConOut("HORA: "+TIME()+" - Iniciando Processo BIA290 - INCESA")
//Startjob("U_WF_BIA290","SCHEDULE",.T.,"05")

ConOut("HORA: "+TIME()+" - Finalizando Processo BIA290 - INCESA")

ConOut("HORA: "+TIME()+" - Iniciando Processo BIA290 - LM")
Startjob("U_WF_BIA290","SCHEDULE",.T.,"07")
ConOut("HORA: "+TIME()+" - Finalizando Processo BIA290 - LM")

ConOut("HORA: "+TIME()+" - Iniciando Processo BIA290 - ST GESTAO")
Startjob("U_WF_BIA290","SCHEDULE",.T.,"12")
ConOut("HORA: "+TIME()+" - Finalizando Processo BIA290 - ST GESTAO")

ConOut("HORA: "+TIME()+" - Iniciando Processo BIA290 - MUNDI")
Startjob("U_WF_BIA290","SCHEDULE",.T.,"13")
ConOut("HORA: "+TIME()+" - Finalizando Processo BIA290 - MUNDI")

//ConOut("HORA: "+TIME()+" - Iniciando Processo BIA290 - VITCER")
//Startjob("U_WF_BIA290","SCHEDULE",.T.,"14")                               // - TOTVS COLABORA敲O Vitcer 100% das notas pelo TC
//ConOut("HORA: "+TIME()+" - Finalizando Processo BIA290 - VITCER")

Return( .T. )

/*___________________________________________________________________________
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun玢o    � WF_BIA290 � Autor � Marcos Alberto S     � Data � 08/03/12 Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζ�          � Respons醰el pela execu玢o dos Jobs                         Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
User Function WF_BIA290(AA_EMP)

Local aAttInfo
Local cFilename			:= ""
Local cPopServer		:= SubStr(GetMv("MV_YSRVPOP"),1,RAT(':',GetMv("MV_YSRVPOP"))-1)	 
Local cAccount 			:= "nf-ebiancogres"
Local cPwd				:= "Bi@ncogres"
Local nPortPop			:= Val(SubStr(GetMv("MV_YSRVPOP"),RAT(':',GetMv("MV_YSRVPOP"))+1,Len(Alltrim(GetMv("MV_YSRVPOP")))))
Local lUseSSL			:= GetMv("MV_RELSSL")
Local nAtach			:= 0
Local nPopResult  	    := 0
Local nMessages 		:= 0
Local nMessage			:= 0
Local nAtachDown		:= 0
Local nHandle			:= 0
Local nCount       	    := .F.
Local oPopServer
Local oMessage
Local nIndex	        := 1

If Select("SX6") == 0                                 // Via Schedule
	*****************************************************************
	
	If AA_EMP == "01"                     // Biancogres
		RPCSETENV("01","01",,,"FAT")
		cAccount 			:= "nf-ebiancogres"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "05"                 // Incesa
		RPCSETENV("05","01",,,"FAT")
		cAccount 			:= "nf-eincesa"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "07"                 // LM
		RPCSETENV("07","01",,,"FAT")
		cAccount 			:= "nf-elm"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "12"                 // St Gest鉶
		RPCSETENV("12","01",,,"FAT")
		cAccount 			:= "nf-estgestao"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "13"                 // Mundi
		RPCSETENV("13","01",,,"FAT")
		cAccount 			:= "nf-emundi"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "14"                 // Vitcer
		RPCSETENV("14","01",,,"FAT")
		cAccount 			:= "nf-evitcer"
		cPwd				:= "Bi@ncogres"
	EndIf
	
Else                                             // Importa玢o Manual
	*****************************************************************
	
	AA_EMP := PARAMIXB
	If AA_EMP == "01"                     // Biancogres
		cAccount 			:= "nf-ebiancogres"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "05"                 // Incesa
		cAccount 			:= "nf-eincesa"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "07"                 // LM
		cAccount 			:= "nf-elm"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "12"                 // St Gest鉶
		cAccount 			:= "nf-estgestao"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "13"                 // Mundi
		cAccount 			:= "nf-emundi"
		cPwd				:= "Bi@ncogres"
	ElseIf AA_EMP == "14"                 // Vitcer
		cAccount 			:= "nf-evitcer"
		cPwd				:= "Bi@ncogres"
	EndIf
	
EndIf

// Cria arquivo semafaro para controle de acessos simult鈔eos
df_ArqEtq := GetSrvProfString("Startpath","")+"bia290_" +AA_EMP+ ".txt"
If File(df_ArqEtq)
	Help(" ",1,"BIA290!",, "Esta rotina j� est� em uso em outra esta玢o de trabalho!!! Necess醨io aguardar.",1,0)
	Return
Else
	nHandle := FCREATE(df_ArqEtq, FC_NORMAL)
	FCLOSE(nHandle)
EndIf

cRootPath := AllTrim( GetSrvProfString( "RootPath","" ) )
cRootPath := If( Right( cRootPath, 1 ) == "\", Left( cRootPath, Len( cRootPath ) -1 ), cRootPath )

oPopServer := TMailManager():New()

oPopServer:SetUseSSL(lUseSSL)
oPopServer:Init( cPopServer, "", cAccount, cPwd, 0, nPortPop )

If ( (nPopResult := oPopServer:PopConnect()) == 0)

	oPopServer:GetNumMsgs(@nMessages)                                              // Conta quantas mensagens h� no servidor
	If( nMessages > 0 )
		oMessage := TMailMessage():New()
	
		For nMessage := 1 To nMessages                                             // Verifica todas mensagens no servidor

			oMessage:Clear()
			nPopResult := oMessage:Receive( oPopServer, nMessage)
			
			If (nPopResult == 0)                                                   // Recebido com sucesso?
				nCount := 0
				
				lkMoved := .F.
				nIndex	:= 1
				For nAtach  := 1 to oMessage:getAttachCount()                      // Verifica todos anexos da mensagem e os salva
					aAttInfo:= oMessage:getAttachInfo(nAtach)
					If File(cRootPath+"\P10\XML_NFE\"+FWCodEmp() + FwCodFil()+"\RECEBIDOS\"+Alltrim(aAttInfo[1]))
						Conout("(BIA290) Arquivo " + Alltrim(aAttInfo[1]) + " j� existente")
					Else
						lSave := oMessage:SaveAttach(nIndex, cRootPath+"\P10\XML_NFE\"+ FWCodEmp() + FwCodFil() +"\RECEBIDOS\"+Alltrim(aAttInfo[1]))  // Salva Anexos
						If !lSave
							Conout("N鉶 gravou"+ cRootPath+"\P10\XML_NFE\"+FWCodEmp() + FwCodFil()+"\RECEBIDOS\"+Alltrim(aAttInfo[1]))
						EndIf
					EndIf
					nIndex := nIndex + 1
				Next
				
				lkMoved := oPopServer:MoveMsg(1, "Recebidos")
				
				If lkMoved
					oMessage:SetConfirmRead(.T.)                                   // Deleta mensagem
					oPopServer:DeleteMsg(nMessage)
				Else
					If oMessage:getAttachCount() > 0
						Conout("(BIA290) ATENCAO - NAO MOVEU O Arquivo " + Alltrim(aAttInfo[1]) + " PARA A PASTA RECEBIDOS")
					EndIf
				EndIf
				
			EndIf
			
		Next
		
	EndIf
	
	oPopServer:PopDisconnect()

Else
	Conout( "(BIA290) Falha ao conectar " + Alltrim(Str(oPopServer:PopConnect())))    
EndIf

ExecBlock("BIA295",.F.,.F.,AA_EMP)

// Libera arquivo semafaro para controle de acessos simult鈔eos
If File(df_ArqEtq)
	FERASE(df_ArqEtq)
EndIf

Return
