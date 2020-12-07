#include "topconn.ch"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include "Ap5Mail.ch"
#Include "tbiconn.ch"
#Include 'FONT.CH'
#Include 'COLORS.CH'
#Include "FOLDER.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'MATA200.CH'
#INCLUDE 'DBTREE.CH'
#INCLUDE "REPORT.CH"
#INCLUDE "JPEG.CH"


User Function BIA795()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA795
Empresa   := Biancogres Cerâmica S/A
Data      := 29/05/14
Uso       := Configurador
Aplicação := Criar usuários para controle de acesso aos Coletores
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Private oDlgUsrColetor
Private oButton1
Private oButton2
Private oButton3
Private trEmpres := ""
Private nDB		 := AllTrim(U_DBNAME()) //Retorna a Database utilizada no ambiente. 
Private oGetDdColetor

If cEmpAnt == "01"
	trEmpres := "B"
ElseIf cEmpAnt == "05"
	trEmpres := "I"
ElseIf cEmpAnt == "13"
	trEmpres := "M"
Else
	Aviso('Atenção','Esta empresa não está preparada para usar o coletor de dados integrado ao Ecosis. Favor Verificar!!!',{'Ok'})
	Return
EndIf

DEFINE MSDIALOG oDlgUsrColetor TITLE "Cadastro de Usuários para o Coletor de Dados" FROM 000, 000  TO 700, 1300 COLORS 0, 16777215 PIXEL

fGetDdColetor()
@ 322, 600 BUTTON oButton1 PROMPT "Fechar" SIZE 037, 012 OF oDlgUsrColetor ACTION oDlgUsrColetor:End() PIXEL
@ 322, 550 BUTTON oButton2 PROMPT "Alterar" SIZE 037, 012 OF oDlgUsrColetor ACTION Processa({|| gGrvAltUsr() }) PIXEL
@ 322, 500 BUTTON oButton3 PROMPT "Incluir" SIZE 037, 012 OF oDlgUsrColetor ACTION Processa({|| gGrvIncUsr() }) PIXEL

ACTIVATE MSDIALOG oDlgUsrColetor

Return

//------------------------------------------------
Static Function fGetDdColetor()
//------------------------------------------------
Local nX
Local aHeaderEx := {}
Local aColsEx := {}
Local aFieldFill := {}
Local aFields := {"CODIGO","NOME","TIPO_OP","OPERAC","SENHA","ACESSO","EMPRESA"}
Local aAlterFields := {}
Private trNumReg := .F.

aAdd(aHeaderEx,{"CODIGO"         ,"CODIGO"    ,"@!"               , 06   , 0,,, "C",, })
aAdd(aHeaderEx,{"NOME"           ,"NOME"      ,"@!"               , 50   , 0,,, "C",, })
aAdd(aHeaderEx,{"TIPO_OP"        ,"TIPO_OP"   ,"@!"               , 01   , 0,,, "C",, })
aAdd(aHeaderEx,{"OPERAC"         ,"OPERACOES" ,"@!"               , 50   , 0,,, "C",, })
aAdd(aHeaderEx,{"SENHA"          ,"SENHA"     ,"@!"               , 50   , 0,,, "C",, })
aAdd(aHeaderEx,{"ACESSO"         ,"ACESSO"    ,"@!"               , 01   , 0,,, "C",, })
aAdd(aHeaderEx,{"EMPRESA"        ,"EMPRESA"   ,"@!"               , 10   , 0,,, "C",, })

TR005 := " SELECT CODIGO,
TR005 += "        NOME,
TR005 += "        TIPO_OP,
TR005 += "        OPERACOES,
TR005 += "        SENHA,
TR005 += "        ACESSO,
TR005 += "        EMPRESA
TR005 += "   FROM "+nDB+"..COLETOR_USUARIOS COLETOR
TR005 += "  WHERE COLETOR.EMPRESA = '"+trEmpres+"'
TR005 += "  ORDER BY CODIGO
TRIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,TR005),'TR05',.T.,.T.)
dbSelectArea("TR05")
dbGoTop()
While !Eof()
	
	trNumReg := .T.
	
	AADD(aColsEx, Array(Len(aFields)+1) )
	aColsEx[Len(aColsEx), 1] := TR05->CODIGO
	aColsEx[Len(aColsEx), 2] := TR05->NOME
	aColsEx[Len(aColsEx), 3] := TR05->TIPO_OP
	aColsEx[Len(aColsEx), 4] := TR05->OPERACOES
	aColsEx[Len(aColsEx), 5] := TR05->SENHA
	aColsEx[Len(aColsEx), 6] := TR05->ACESSO
	aColsEx[Len(aColsEx), 7] := TR05->EMPRESA
	aColsEx[Len(aColsEx), Len(aFields)+1] := .F.
	
	dbSelectArea("TR05")
	dbSkip()
End

TR05->(dbCloseArea())
Ferase(TRIndex+GetDBExtension())
Ferase(TRIndex+OrdBagExt())

If !trNumReg
	AADD(aColsEx, Array(Len(aFields)+1) )
	aColsEx[Len(aColsEx), 1] := ""
	aColsEx[Len(aColsEx), 2] := ""
	aColsEx[Len(aColsEx), 3] := ""
	aColsEx[Len(aColsEx), 4] := ""
	aColsEx[Len(aColsEx), 5] := ""
	aColsEx[Len(aColsEx), 6] := ""
	aColsEx[Len(aColsEx), 7] := ""
	aColsEx[Len(aColsEx), Len(aFields)+1] := .F.
EndIf

oGetDdColetor := MsNewGetDados():New( 017, 005, 314, 641, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgUsrColetor, aHeaderEx, aColsEx)

Return

//------------------------------------------------
Static Function gGrvIncUsr()
//------------------------------------------------

Private oDlgInc
Private oBut1inc
Private oBut2inc
Private oGet1inc
Private cGet1inc := Space(50)
Private oGet2inc
Private cGet2inc := Space(50)
Private oGet3inc
Private cGet3inc := Space(10)
Private oSay1inc
Private oSay2inc
Private oSay3inc
Private fh_Esc         := .F.
Private fh_Grava       := .F.

DEFINE MSDIALOG oDlgInc TITLE "Incluir" FROM 000, 000  TO 120, 500 COLORS 0, 16777215 PIXEL

@ 010, 010 SAY oSay1inc PROMPT "Nome:" SIZE 028, 007 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 025, 010 SAY oSay2inc PROMPT "Operação:" SIZE 028, 007 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 040, 010 SAY oSay3inc PROMPT "Senha:" SIZE 028, 007 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 010, 046 MSGET oGet1inc VAR cGet1inc SIZE 196, 010 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 025, 046 MSGET oGet2inc VAR cGet2inc SIZE 055, 010 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 040, 046 MSGET oGet3inc VAR cGet3inc SIZE 060, 010 OF oDlgInc COLORS 0, 16777215 PIXEL

@ 040, 205 BUTTON oBut1inc PROMPT "Confirmar" SIZE 037, 012 OF oDlgInc ACTION (fh_Esc := .T., fh_Grava := .T., oDlgInc:End()) PIXEL
@ 040, 160 BUTTON oBut2inc PROMPT "Cancelar"  SIZE 037, 012 OF oDlgInc ACTION (fh_Esc := .T., fh_Grava := .F., oDlgInc:End()) PIXEL

ACTIVATE MSDIALOG oDlgInc VALID fh_Esc

If fh_Grava
	
	If !(Empty(cGet1inc) .and. Empty(cGet2inc) .and. Empty(cGet3inc))
		
		IU003 := " INSERT INTO "+nDB+"..COLETOR_USUARIOS
		IU003 += "        (CODIGO,
		IU003 += "         NOME,
		IU003 += "         TIPO_OP,
		IU003 += "         OPERACOES,
		IU003 += "         SENHA,
		IU003 += "         ACESSO,
		IU003 += "         EMPRESA)
		IU003 += " SELECT RIGHT('0000'+ CONVERT(VARCHAR, ((SELECT ISNULL(MAX(CODIGO), 0)
		IU003 += "                                           FROM "+nDB+"..COLETOR_USUARIOS COLETOR) + 1) ),3) CODIGO,
		IU003 += "        '"+Alltrim(cGet1inc)+"'  NOME,
		IU003 += "        'E'                      TIPO_OP,
		IU003 += "        '"+Alltrim(cGet2inc)+"'  OPERACOES,
		IU003 += "        '"+Alltrim(cGet3inc)+"'  SENHA,
		IU003 += "        'U'                      ACESSO,
		IU003 += "        '"+trEmpres+"'           EMPRESA
		TCSQLExec(IU003)
		
		dfNewCod := ""
		RT007 := " SELECT RIGHT('0000'+ CONVERT(VARCHAR, ISNULL(MAX(CODIGO), 0) ) ,3) NEWCOD
		RT007 += "   FROM "+nDB+"..COLETOR_USUARIOS COLETOR
		RT007 += "  WHERE COLETOR.EMPRESA = '"+trEmpres+"'
		RT007 += "    AND RTRIM(COLETOR.NOME) = '"+Alltrim(cGet1inc)+"'
		RTIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT007),'RT07',.T.,.T.)
		dbSelectArea("RT07")
		dbGoTop()
		dfNewCod := RT07->NEWCOD
		RT07->(dbCloseArea())
		Ferase(RTIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(RTIndex+OrdBagExt())          //indice gerado
		
		If !Empty(dfNewCod)
			
			AADD(oGetDdColetor:ACOLS, Array(Len(oGetDdColetor:AHEADER)+1) )
			cfLinha := Len(oGetDdColetor:ACOLS)
			oGetDdColetor:ACOLS[cfLinha][1] := dfNewCod
			oGetDdColetor:ACOLS[cfLinha][2] := cGet1inc
			oGetDdColetor:ACOLS[cfLinha][3] := "E"
			oGetDdColetor:ACOLS[cfLinha][4] := cGet2inc
			oGetDdColetor:ACOLS[cfLinha][5] := cGet3inc
			oGetDdColetor:ACOLS[cfLinha][6] := "U"
			oGetDdColetor:ACOLS[cfLinha][7] := trEmpres
			oGetDdColetor:ACOLS[cfLinha][8] := .F.
			
		EndIf
		
	EndIf
	
EndIf

Return

//------------------------------------------------
Static Function gGrvAltUsr()
//------------------------------------------------

Private oDlgInc
Private oBut1inc
Private oBut2inc
Private oGet1inc
Private cGet1inc := oGetDdColetor:ACOLS[oGetDdColetor:NAT][2]
Private oGet2inc
Private cGet2inc := oGetDdColetor:ACOLS[oGetDdColetor:NAT][4]
Private oGet3inc
Private cGet3inc := oGetDdColetor:ACOLS[oGetDdColetor:NAT][5]
Private oSay1inc
Private oSay2inc
Private oSay3inc
Private fh_Esc         := .F.
Private fh_Grava       := .F.

DEFINE MSDIALOG oDlgInc TITLE "Alterar" FROM 000, 000  TO 120, 500 COLORS 0, 16777215 PIXEL

@ 010, 010 SAY oSay1inc PROMPT "Nome:" SIZE 028, 007 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 025, 010 SAY oSay2inc PROMPT "Operação:" SIZE 028, 007 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 040, 010 SAY oSay3inc PROMPT "Senha:" SIZE 028, 007 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 010, 046 MSGET oGet1inc VAR cGet1inc When .F. SIZE 196, 010 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 025, 046 MSGET oGet2inc VAR cGet2inc SIZE 055, 010 OF oDlgInc COLORS 0, 16777215 PIXEL
@ 040, 046 MSGET oGet3inc VAR cGet3inc SIZE 060, 010 OF oDlgInc COLORS 0, 16777215 PIXEL

@ 040, 205 BUTTON oBut1inc PROMPT "Confirmar" SIZE 037, 012 OF oDlgInc ACTION (fh_Esc := .T., fh_Grava := .T., oDlgInc:End()) PIXEL
@ 040, 160 BUTTON oBut2inc PROMPT "Cancelar"  SIZE 037, 012 OF oDlgInc ACTION (fh_Esc := .T., fh_Grava := .F., oDlgInc:End()) PIXEL

ACTIVATE MSDIALOG oDlgInc VALID fh_Esc

If fh_Grava
	
	If !(Empty(cGet1inc) .and. Empty(cGet2inc) .and. Empty(cGet3inc))
		
		IU004 := " UPDATE "+nDB+"..COLETOR_USUARIOS SET OPERACOES = '"+Alltrim(cGet2inc)+"', SENHA = '"+Alltrim(cGet3inc)+"'
		IU004 += " WHERE EMPRESA = '"+trEmpres+"'
		IU004 += "	 AND CODIGO = '"+oGetDdColetor:ACOLS[oGetDdColetor:NAT][1]+"'
		TCSQLExec(IU004)
		
		oGetDdColetor:ACOLS[oGetDdColetor:NAT][4] := cGet2inc
		oGetDdColetor:ACOLS[oGetDdColetor:NAT][5] := cGet3inc
		
	EndIf
	
EndIf

Return
