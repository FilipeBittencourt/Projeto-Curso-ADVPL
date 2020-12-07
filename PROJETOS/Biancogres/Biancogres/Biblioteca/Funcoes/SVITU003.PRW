#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |SVITU002  ºAutor  ³Fernando Rocha      º Data ³  09/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Escolher Grupos e Usuarios para permissao º±±     
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User function SVITU003(cCampo)    
Local aArea := GetArea()   
Local cRet := "" 

Private nTamCmp := TamSX3(cCampo)[1]
cRet := Space(nTamCmp)

Private cMarca := GetMark()
Private cAcesso := Alltrim(&("M->"+cCampo))   

IF !Empty(cAcesso) .And. Valtype(&(cAcesso)) <> 'A'
	MsgAlert("Campo Acesso com conteudo inválido, limpar e utilizar F3 para preenchimento.")
	Return(cRet)
ENDIF

//Variaveis Private da Tela
SetPrvt("oDlg1","oBrw1","oBrw2","oBtnOK","oBtnCancel")

//Definicao dos arquivos de trabalho  
if Select("TRBGRP") > 0
	TRBGRP->(DbCloseArea())
endif

if Select("TRBUSU") > 0
	TRBUSU->(DbCloseArea())
endif


_struGrp:={}
AADD(_struGrp,{"OK"        ,"C", 2,0})
AADD(_struGrp,{"GRUPO"     ,"C", 6,0})
AADD(_struGrp,{"DESCGRP"   ,"C", 25,0})
cArq:=Criatrab(_struGrp,.T.)
DBUSEAREA(.t.,,carq,"TRBGRP")

aCpoGrp := {}
AADD(aCpoGrp,{"OK","","Title","@!"})
AADD(aCpoGrp,{"GRUPO","","Grupo","@!"})
AADD(aCpoGrp,{"DESCGRP","","Descricao","@!"})

_struUsu:={}
AADD(_struUsu,{"OK"        	,"C", 2,0})
AADD(_struUsu,{"ID"		  	,"C", 6,0})
AADD(_struUsu,{"USUARIO"  	,"C", 20,0})
AADD(_struUsu,{"NOME"      	,"C", 30,0})
cArq:=Criatrab(_struUsu,.T.)
DBUSEAREA(.t.,,carq,"TRBUSU")

aCpoUsu := {}
AADD(aCpoUsu,{"OK","","Title","@!"})       
AADD(aCpoUsu,{"ID","","Usuario","@!"})
AADD(aCpoUsu,{"USUARIO","","Usuario","@!"})
AADD(aCpoUsu,{"NOME","","Nome","@!"})

//Preencher os Grupos e usuarios
LoadGrp()          
TRBGRP->(DbGoTop())
TRBUSU->(DbGoTop())
                     
//Definicao da Tela
oDlg1      := MSDialog():New( 088,232,463,940,"PERMISSAO PARA GRUPOS E USUARIOS",,,.F.,,,,,,.T.,,,.T. )
oBrw1      := MsSelect():New( "TRBGRP","OK","",aCpoGrp,.F.,@cMarca,{000,000,168,132},,, oDlg1 ) 
oBrw2      := MsSelect():New( "TRBUSU","OK","",aCpoUsu,.F.,@cMarca,{000,136,168,350},,, oDlg1 ) 
oBtnOK     := TButton():New( 171,290,"OK",oDlg1,,037,012,,,,.T.,,"",,,,.F. )
oBtnCancel := TButton():New( 171,247,"CANCELAR",oDlg1,,037,012,,,,.T.,,"",,,,.F. )
                                       
//oBrw1:bAval := {|| ChangeGrp()}
oBtnOK:bAction := {|| cRet := Confirma(),oDlg1:End()}
oBtnCancel:bAction := {|| oDlg1:End()}

oDlg1:Activate(,,,.T.)

RestArea(aArea) 
&("M->"+cCampo) := cRet
return(cRet)   
         
//Funcao para gerar a String de retorno baseado nas marcacoes
Static Function Confirma()
Local cGrupos := "" 
Local cUsuarios := "" 
Local cRet := ""

TRBGRP->(DbGoTop())
While .Not. TRBGRP->(Eof()) 

	If TRBGRP->OK == cMarca
		cGrupos += TRBGRP->GRUPO+";"
	EndIf

	TRBGRP->(DbSkip())
EndDo

TRBUSU->(DbGoTop())
While .Not. TRBUSU->(Eof())
         
   	If TRBUSU->OK == cMarca
		cUsuarios += TRBUSU->ID+";"
	EndIf
	
	TRBUSU->(DbSkip())
EndDo
        
IF !Empty(cGrupos) .Or. !Empty(cUsuarios)
	cRet := "{'"+cGrupos+"','"+cUsuarios+"'}" 
ELSE
	cRet := Space(nTamCmp)
ENDIF

Return(cRet)
      
//Funcao para preencher os arquivos de trabalho com grupos e usuarios
Static Function LoadGrp()      
Local I
Local aGrupos := AllGroups()
Local aUsuarios := AllUsers()
                                                         
//Ordenacao alfabetica
aGrupos := ASort(aGrupos,,, {|x,y| UPPER(x[1][2]) < UPPER(y[1][2]) } )
aUsuarios := ASort(aUsuarios,,, {|x,y| UPPER(x[1][2]) < UPPER(y[1][2]) } )

For I := 1 To Len(aGrupos)

	IF aGrupos[I][1][1] <> '000000'

		RecLock("TRBGRP",.T.)      
		
		If !Empty(cAcesso) .And. (aGrupos[I][1][1] $ &(cAcesso)[1])
			TRBGRP->OK := cMarca
		EndIf
		
		TRBGRP->GRUPO := aGrupos[I][1][1]
		TRBGRP->DESCGRP := aGrupos[I][1][2]
		TRBGRP->(MsUnlock()) 

	ENDIF

Next I 

For I := 1 To Len(aUsuarios)

	IF aUsuarios[I][1][1] <> '000000'

		RecLock("TRBUSU",.T.)     
		
		If !Empty(cAcesso) .And. (aUsuarios[I][1][1] $ &(cAcesso)[2])
			TRBUSU->OK := cMarca
		EndIf
		
		TRBUSU->ID		 := aUsuarios[I][1][1]
		TRBUSU->USUARIO := aUsuarios[I][1][2]
		TRBUSU->NOME    := aUsuarios[I][1][4]
		TRBUSU->(MsUnlock())  

	ENDIF

Next I

Return
