#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA947
@author Marcos Alberto Soprani
@since 06/02/18
@version 1.0
@description Atribui valor sequencial diferenciado ao campo CT2_SEQIDX para evitar erro de chave 
.            duplicada quando lojas variadas por empresa
@type function
/*/

User Function BIA947()

	fPerg := "BIA947"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	HB008 := " WITH MOVXXX AS (SELECT CT2_FILIAL, "
	HB008 += "                        CT2_DATA, "
	HB008 += "                        CT2_LOTE, "
	HB008 += "                        CT2_SBLOTE, "
	HB008 += "                        CT2_DOC, "
	HB008 += "                        CT2_LINHA, "
	HB008 += "                        CT2_EMPORI, "
	HB008 += "                        CT2_MOEDLC, "
	HB008 += "                        CT2_SEQIDX, "
	HB008 += "                        R_E_C_D_E_L_, "
	HB008 += "                        R_E_C_N_O_, "
	HB008 += "                        REPLICATE('0', 5 - LEN(RTRIM(CONVERT(CHAR, ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_))))) + RTRIM(CONVERT(CHAR, ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_))) CT2REC "
	HB008 += "                   FROM " + RetSqlName("CT2") + " "
	HB008 += "                  WHERE CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "') "
	HB008 += " UPDATE " + RetSqlName("CT2") + " SET CT2_SEQIDX = CT2REC "
	HB008 += "   FROM " + RetSqlName("CT2") + " CT2 "
	HB008 += "  INNER JOIN MOVXXX XXX ON XXX.R_E_C_N_O_ = CT2.R_E_C_N_O_ "
	HB008 += "  WHERE CT2.CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "

	U_BIAMsgRun("Aguarde... Resolvendo duplicadade de chave para Consolidação Geral... ",,{|| TcSQLExec(HB008) })

	MsgINFO("Fim do processamento.... Pode efetuar a Consolidação Geral...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg    ¦ Autor ¦ Marcos Alberto S ¦ Data ¦ 13/05/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := GetArea()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	RestArea(_sAlias)

Return
