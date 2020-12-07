#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} BIA955
@author Carlos Augusto P.Junqueira
@since 10/07/14
@version 1.0
@description Alteração de email do campo de supervisor SRA (RA_YSUPEML)
@type function
/*/

User Function BIA955()

	fPerg 	:= "XXXX"
	fTamX1 	:= IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	LjMsgRun("Atualizando E-Mail...",, {|| xeAtuSRA() })

Return

Static Function xeAtuSRA()

	WT006 := " UPDATE " + RetSqlName("SRA")
	WT006 += "    SET RA_YSUPEML = '"+Alltrim(MV_PAR02)+"'
	WT006 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	WT006 += "    AND RA_SITFOLH <> 'D'
	WT006 += "    AND RA_YSUPEML LIKE '%"+Alltrim(MV_PAR01)+"%'
	If !Empty(MV_PAR03)
		WT006 += "    AND RA_CLVL = '"+MV_PAR03+"'
	EndIf
	WT006 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(WT006)

Return

Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","E-Mail Atual (minúsculo) ?","","","mv_ch1","C",50,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Substituir pelo E-Mail   ?","","","mv_ch2","C",50,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Classe Valor(Vazio Geral)?","","","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CTH"})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
