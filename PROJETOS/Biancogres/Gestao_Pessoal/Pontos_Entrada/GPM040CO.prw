#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function GPM040CO()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := GPM040CO
Empresa   := Biancogres Cerâmica S/A
Data      := 13/06/13
Uso       := Gestão de Pessoal
Aplicação := O ponto de entrada que indica se a rotina prossegue com o Cálculo
.            de Rescisão ou não.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local yjValdRc := .T.
Local yjDescRes := ""

Local aArea   := GetArea()     
Local cAlias1 := GetNextAlias()

Private cAlias2 := GetNextAlias()
Private nCount := 0
Private cEoL := Chr(13)
Private cQry := ""
Private cSRE := RetSqlName("SRE")
Private cFil := ValToSql(SRA->RA_FILIAL)
Private cMat := ValToSql(SRA->RA_MAT)
Private cCenC := ValToSql(SRA->RA_CC)
Private cMatTraf 	:= ""
Private cMatTran 	:= ""

yjDescRes := ">>>>>>          " + SubStr( fDesc("SRX","32"+cTipRes,"RX_TXT",,SRA->RA_FILIAL) , 1 , 30 ) + "         <<<<<<<"

If !MsgNOYES("Foi escolhido o seguinte tipo de rescisão:                      " + CHR(13) + CHR(13) + CHR(13) + yjDescRes + CHR(13) + CHR(13) + CHR(13) + "Deseja continuar calculando a Rescisão?            ", "TIPO DE RESCISÃO")
	yjValdRc := .F.
	Return (yjValdRc)
EndIf

//Verifica Transferencias

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funçao pra verificar as Transferencias do funcionario        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FTranf("")

If !Empty(cMatTraf)
	yjValdRc := MsgYesNo( "Funcionario possui Transferencias de Empresas e/ou Filiais.", "Atenção" ) 
Endif

Return ( yjValdRc )


//??????????????????????????????????????????????????????????????ø
//?Chama a Query Inicialmente para buscar o primeiro funcionario?
//¿??????????????????????????????????????????????????????????????
Static Function fTranf(cMatTran)

Local cQryRe := ""
Local _cEmp
Local _cFil
Local _cMat

If Select(cAlias2) > 0
	(cAlias2)->(dbCloseArea())
EndIf

cQryRe := " SELECT RE_EMPD, RE_FILIALD, RE_MATD " + cEol 
cQryRe += " FROM "+ cSRE +" WHERE RE_FILIALP = "+ cFil + cEol 
cQryRe += " AND RE_MATP = " +ValToSql(cMat) + cEol
cQryRe += " AND (RE_EMPD <> RE_EMPP OR RE_FILIALD <> RE_FILIALP)" + cEol 
dbUseArea( .T., "TOPCONN", TCGenQry(,,ChangeQuery(cQryRe)), cAlias2, .F., .F.)
IF Empty((cAlias2)->RE_EMPD)
	Return()
Endif

While !(cAlias2)->(Eof())

	_cEmp :=  Alltrim((cAlias2)->RE_EMPD)     
	_cFil :=  Alltrim((cAlias2)->RE_FILIALD) 
	_cMat :=  Alltrim((cAlias2)->RE_MATD)

	If Empty(cMatTran)    	     
		cMatTran += "'"+ _cFil + _cMat +"'"
		cMatTraf += cMatTran	     
	Else						
		cMatTraf += "," + "'"+ _cFil + _cMat+"'"
	Endif	

	(cAlias2)->(DbSkip())
	
Enddo

If Select(cAlias2) > 0
	(cAlias2)->(dbCloseArea())
EndIf

Return()