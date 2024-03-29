#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function GPM040CO()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := GPM040CO
Empresa   := Biancogres Cer鈓ica S/A
Data      := 13/06/13
Uso       := Gest鉶 de Pessoal
Aplica玢o := O ponto de entrada que indica se a rotina prossegue com o C醠culo
.            de Rescis鉶 ou n鉶.
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

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

If !MsgNOYES("Foi escolhido o seguinte tipo de rescis鉶:                      " + CHR(13) + CHR(13) + CHR(13) + yjDescRes + CHR(13) + CHR(13) + CHR(13) + "Deseja continuar calculando a Rescis鉶?            ", "TIPO DE RESCIS肙")
	yjValdRc := .F.
	Return (yjValdRc)
EndIf

//Verifica Transferencias

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//矲un鏰o pra verificar as Transferencias do funcionario        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
FTranf("")

If !Empty(cMatTraf)
	yjValdRc := MsgYesNo( "Funcionario possui Transferencias de Empresas e/ou Filiais.", "Aten玢o" ) 
Endif

Return ( yjValdRc )


//??????????????????????????????????????????????????????????????�
//?Chama a Query Inicialmente para buscar o primeiro funcionario?
//�??????????????????????????????????????????????????????????????
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