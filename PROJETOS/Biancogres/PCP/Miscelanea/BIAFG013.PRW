#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG013
@author Gabriel Rossi Mafioletti
@since 28/06/2017
@version 1.0
@description Relatório Excel de Pseudo Apontamento
@type function
/*/

User Function BIAFG013()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	private aPergs := {}
	Private oExcel      := nil 
	private cDirDest    := space(170)

	If !ValidPerg()
		Return
	EndIf

	fQryDados()

return

Static Function ValidPerg()

	local cLoad	    := "BIAFG013" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.

	MV_PAR01 := SPACE(6)
	MV_PAR02 := SPACE(6)
	MV_PAR03 :=	Space(TAMSX3("B1_COD")[1])
	MV_PAR04 :=	Space(TAMSX3("B1_COD")[1])
	MV_PAR05 := space(100)

	aAdd( aPergs ,{1,"Ano/Mês de? " 	   		,MV_PAR01 ,"@R 9999/99"  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Ano/Mês Até?" 	   		,MV_PAR02 ,"@R 9999/99"  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto De?" 	   			,MV_PAR03 ,""  ,"",'SB1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto Até?" 	   		,MV_PAR04 ,""  ,"",'SB1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  			,MV_PAR05 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Pseudo Apontamento",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

		cDirDest	:=	MV_PAR05

		if empty(MV_PAR05) 
			MV_PAR05 := AllTrim(GetTempPath()) 	
		endif

	EndIf

Return lRet

Static Function fQryDados()

	Local nTotReg	:=	0
	local nRegAtu   := 0

	local cCab1Fon	:= 'Calibri' 
	local cCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'

	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	Local _nFator	:=	1

	local cArqXML   := "BIAFG013_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	Local msEnter     := Chr(13) + Chr(10)

	RL002 := Alltrim("SELECT Z97_COD, Z97_SEQREG, Z97_ORITAB, COUNT(1) CONTADOR "                           ) + msEnter
	RL002 += Alltrim("  FROM " + RetSqlName("Z97") + " WITH (NOLOCK) "                                      ) + msEnter
	RL002 += Alltrim(" WHERE Z97_TM = '010' "                                                               ) + msEnter
	RL002 += Alltrim("   AND SUBSTRING(Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' ") + msEnter
	RL002 += Alltrim("   AND D_E_L_E_T_ = ' ' "                                                             ) + msEnter 	
	RL002 += Alltrim(" GROUP BY Z97_COD, Z97_SEQREG, Z97_ORITAB "                                           ) + msEnter 
	RL002 += Alltrim("HAVING COUNT(1) > 1 "                                                                 ) + msEnter 

	RLIndex := CriaTrab(Nil,.f.)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RL002),'RL02',.T.,.T.)
	dbSelectArea("RL02")
	RL02->(DbGoTop())
	Count To nTotReg 

	if nTotReg > 1
		MsgStop('Verifique se existe outro colaborador executando esta rotina e faça o reprocessamento.')

		return
	endif

	RL02->(DbCloseArea())	

	RL002 := Alltrim(" WITH CANPROD                                                                                                                                                                  ") + msEnter
	RL002 += Alltrim("      AS (SELECT D3_YRFCUST RFCUST,                                                                                                                                            ") + msEnter
	RL002 += Alltrim("                 D3_EMISSAO EMISSAO,                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 D3_COD PRODUTO,                                                                                                                                               ") + msEnter
	RL002 += Alltrim("                 D3_QUANT QUANT                                                                                                                                                ") + msEnter
	RL002 += Alltrim("          FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                                                      ") + msEnter
	RL002 += Alltrim("          WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                                       ") + msEnter
	RL002 += Alltrim("                AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                          ") + msEnter
	RL002 += Alltrim("                AND SD3.D3_TM IN('711')                                                                                                                                        ") + msEnter
	RL002 += Alltrim("          AND SD3.D3_ESTORNO = ' '                                                                                                                                             ") + msEnter
	RL002 += Alltrim("          AND SD3.D_E_L_E_T_ = ' '),                                                                                                                                           ") + msEnter
	RL002 += Alltrim("      DADOSPRODUC                                                                                                                                                              ") + msEnter
	RL002 += Alltrim("      AS (SELECT Z97_ORITAB ORIGTAB,                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 Z97_SEQREG NUMSEQ,                                                                                                                                            ") + msEnter
	RL002 += Alltrim("                 Z97_OP NUMOP,                                                                                                                                                 ") + msEnter
	RL002 += Alltrim("                 Z97_TRT REVOP,                                                                                                                                                ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT XZ97.Z97_COD                                                                                                                                              ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("Z97") + " XZ97 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("              WHERE XZ97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                 ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_SEQREG = Z97.Z97_SEQREG                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_ORITAB = Z97.Z97_ORITAB                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(XZ97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                     ") + msEnter
	RL002 += Alltrim("                    AND XZ97.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ) PROD_OP,                                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 1 QTD_OP,                                                                                                                                                     ") + msEnter
	RL002 += Alltrim("                 Z97_EMISSA EMISSAO,                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 Z97_TM TM,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                 Z97_CF CF,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                 SB1.B1_YCTRIND CONTA,                                                                                                                                         ") + msEnter
	RL002 += Alltrim("                 Z97_COD COD_APON,                                                                                                                                             ") + msEnter
	RL002 += Alltrim("                 Z97_CUSTO1 CUSUNIT,                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 Z97_QUANT QTDUNIT,                                                                                                                                            ") + msEnter
	RL002 += Alltrim("                 Z97_QUANT * ((ISNULL(                                                                                                                                         ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(SD3.D3_QUANT)                                                                                                                                         ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("Z97") + " XZ97 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("                   JOIN " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) ON SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                 ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_COD = XZ97.Z97_COD                                                                                               ") + msEnter
	RL002 += Alltrim("                                                   AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_TM = '010'                                                                                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D_E_L_E_T_ = ''                                                                                                     ") + msEnter
	RL002 += Alltrim("              WHERE XZ97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                 ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_SEQREG = Z97.Z97_SEQREG                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_ORITAB = Z97.Z97_ORITAB                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(XZ97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                     ") + msEnter
	RL002 += Alltrim("                    AND XZ97.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ), 0)) - (ISNULL(                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(SD3.D3_QUANT)                                                                                                                                         ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("Z97") + " XZ97 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("                   JOIN " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) ON SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                 ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_COD = XZ97.Z97_COD                                                                                               ") + msEnter
	RL002 += Alltrim("                                                   AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_TM = '711'                                                                                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D_E_L_E_T_ = ''                                                                                                     ") + msEnter
	RL002 += Alltrim("              WHERE XZ97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                 ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_SEQREG = Z97.Z97_SEQREG                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_ORITAB = Z97.Z97_ORITAB                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(XZ97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                     ") + msEnter
	RL002 += Alltrim("                    AND XZ97.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ), 0))) QUANT,                                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                 Z97_CUSTO1 * ((ISNULL(                                                                                                                                        ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(SD3.D3_QUANT)                                                                                                                                         ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("Z97") + " XZ97 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("                   JOIN " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) ON SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                 ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_COD = XZ97.Z97_COD                                                                                               ") + msEnter
	RL002 += Alltrim("                                                   AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_TM = '010'                                                                                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D_E_L_E_T_ = ''                                                                                                     ") + msEnter
	RL002 += Alltrim("              WHERE XZ97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                 ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_SEQREG = Z97.Z97_SEQREG                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_ORITAB = Z97.Z97_ORITAB                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(XZ97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                     ") + msEnter
	RL002 += Alltrim("                    AND XZ97.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ), 0)) - (ISNULL(                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(SD3.D3_QUANT)                                                                                                                                         ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("Z97") + " XZ97 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("                   JOIN " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) ON SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                 ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_COD = XZ97.Z97_COD                                                                                               ") + msEnter
	RL002 += Alltrim("                                                   AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_TM = '711'                                                                                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D_E_L_E_T_ = ''                                                                                                     ") + msEnter
	RL002 += Alltrim("              WHERE XZ97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                 ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_SEQREG = Z97.Z97_SEQREG                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_ORITAB = Z97.Z97_ORITAB                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(XZ97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                     ") + msEnter
	RL002 += Alltrim("                    AND XZ97.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ), 0))) CUSTO,                                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                 ((ISNULL(                                                                                                                                                     ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(SD3.D3_QUANT)                                                                                                                                         ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("Z97") + " XZ97 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("                   JOIN " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) ON SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                 ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_COD = XZ97.Z97_COD                                                                                               ") + msEnter
	RL002 += Alltrim("                                                   AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_TM = '010'                                                                                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D_E_L_E_T_ = ''                                                                                                     ") + msEnter
	RL002 += Alltrim("              WHERE XZ97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                 ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_SEQREG = Z97.Z97_SEQREG                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_ORITAB = Z97.Z97_ORITAB                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(XZ97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                     ") + msEnter
	RL002 += Alltrim("                    AND XZ97.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ), 0)) - (ISNULL(                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(SD3.D3_QUANT)                                                                                                                                         ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("Z97") + " XZ97 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("                   JOIN " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) ON SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                 ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_COD = XZ97.Z97_COD                                                                                               ") + msEnter
	RL002 += Alltrim("                                                   AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_TM = '711'                                                                                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D_E_L_E_T_ = ''                                                                                                     ") + msEnter
	RL002 += Alltrim("              WHERE XZ97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                 ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_SEQREG = Z97.Z97_SEQREG                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_ORITAB = Z97.Z97_ORITAB                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(XZ97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                     ") + msEnter
	RL002 += Alltrim("                    AND XZ97.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ), 0))) QTD_APON,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                 ((ISNULL(                                                                                                                                                     ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(SD3.D3_QUANT)                                                                                                                                         ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("Z97") + " XZ97 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("                   JOIN " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) ON SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                 ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_COD = XZ97.Z97_COD                                                                                               ") + msEnter
	RL002 += Alltrim("                                                   AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_TM = '010'                                                                                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D_E_L_E_T_ = ''                                                                                                     ") + msEnter
	RL002 += Alltrim("              WHERE XZ97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                 ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_SEQREG = Z97.Z97_SEQREG                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_ORITAB = Z97.Z97_ORITAB                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(XZ97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                     ") + msEnter
	RL002 += Alltrim("                    AND XZ97.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ), 0)) - (ISNULL(                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(SD3.D3_QUANT)                                                                                                                                         ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("Z97") + " XZ97 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("                   JOIN " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) ON SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                 ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_COD = XZ97.Z97_COD                                                                                               ") + msEnter
	RL002 += Alltrim("                                                   AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D3_TM = '711'                                                                                                       ") + msEnter
	RL002 += Alltrim("                                                   AND SD3.D_E_L_E_T_ = ''                                                                                                     ") + msEnter
	RL002 += Alltrim("              WHERE XZ97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                 ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_SEQREG = Z97.Z97_SEQREG                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                    AND XZ97.Z97_ORITAB = Z97.Z97_ORITAB                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(XZ97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                     ") + msEnter
	RL002 += Alltrim("                    AND XZ97.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ), 0))) QTD_ACUM,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                 Z97_DOC DOCUMEN,                                                                                                                                              ") + msEnter
	RL002 += Alltrim("                 CASE                                                                                                                                                          ") + msEnter
	RL002 += Alltrim("                     WHEN Z97_TM = '010'                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                     THEN '001'                                                                                                                                                ") + msEnter
	RL002 += Alltrim("                     WHEN Z97_TM = '999'                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                          AND SB1.B1_TIPO = 'PP'                                                                                                                               ") + msEnter
	RL002 += Alltrim("                     THEN '060'                                                                                                                                                ") + msEnter
	RL002 += Alltrim("                     WHEN Z97_TM = '999'                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                          AND SB1.B1_TIPO = 'PA'                                                                                                                               ") + msEnter
	RL002 += Alltrim("                     THEN '065'                                                                                                                                                ") + msEnter
	RL002 += Alltrim("                     ELSE ISNULL(CT1_YITCUS, '')                                                                                                                               ") + msEnter
	RL002 += Alltrim("                 END ITCUS                                                                                                                                                     ") + msEnter
	//RL002 += Alltrim("                 ISNULL(CT1_YITCUS, '') ITCUS                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          FROM " + RetSqlName("Z97") + " Z97                                                                                                                                   ") + msEnter
	RL002 += Alltrim("               INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                                               ") + msEnter
	RL002 += Alltrim("                                                     AND SB1.B1_COD = Z97.Z97_COD                                                                                              ") + msEnter
	RL002 += Alltrim("                                                     AND SB1.D_E_L_E_T_ = ' '                                                                                                  ") + msEnter
	RL002 += Alltrim("               LEFT JOIN " + RetSqlName("CT1") + " CT1 WITH(NOLOCK) ON CT1.CT1_FILIAL = '" + xFilial("CT1") + "'                                                               ") + msEnter
	RL002 += Alltrim("                                                    AND CT1_CONTA = SB1.B1_YCTRIND                                                                                             ") + msEnter
	RL002 += Alltrim("                                                    AND CT1.D_E_L_E_T_ = ' '                                                                                                   ") + msEnter
	RL002 += Alltrim("          WHERE Z97.Z97_FILIAL = '" + xFilial("Z97") + "'                                                                                                                      ") + msEnter
	RL002 += Alltrim("                AND SUBSTRING(Z97.Z97_EMISSA, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                          ") + msEnter
	RL002 += Alltrim("                AND Z97.D_E_L_E_T_ = ' '                                                                                                                                       ") + msEnter
	RL002 += Alltrim("          UNION ALL                                                                                                                                                            ") + msEnter
	RL002 += Alltrim("          SELECT 'SD3' ORIGTAB,                                                                                                                                                ") + msEnter
	RL002 += Alltrim("                 SD3.D3_NUMSEQ NUMSEQ,                                                                                                                                         ") + msEnter
	RL002 += Alltrim("                 SD3.D3_OP NUMOP,                                                                                                                                              ") + msEnter
	RL002 += Alltrim("                 SC2.C2_REVISAO REVOP,                                                                                                                                         ") + msEnter
	RL002 += Alltrim("                 SC2.C2_PRODUTO PROD_OP,                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                 SC2.C2_QUANT QTD_OP,                                                                                                                                          ") + msEnter
	RL002 += Alltrim("                 SD3.D3_EMISSAO EMISSAO,                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                 SD3.D3_TM TM,                                                                                                                                                 ") + msEnter
	RL002 += Alltrim("                 SD3.D3_CF CF,                                                                                                                                                 ") + msEnter
	RL002 += Alltrim("                 SD3.D3_CONTA CONTA,                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 SD3.D3_COD COD_APON,                                                                                                                                          ") + msEnter
	RL002 += Alltrim("                 0 CUSUNIT,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                 0 QTDUNIT,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                 SUM(SD3.D3_QUANT) QUANT,                                                                                                                                      ") + msEnter
	RL002 += Alltrim("                 SUM(SD3.D3_CUSTO1) CUSTO,                                                                                                                                     ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT ZZD3.D3_QUANT                                                                                                                                             ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("SD3") + " ZZD3 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("              WHERE ZZD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                                  ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_EMISSAO = SD3.D3_EMISSAO                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_NUMSEQ = SD3.D3_NUMSEQ                                                                                                                         ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_TM = '010'                                                                                                                                     ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ) QTD_APON,                                                                                                                                                          ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(ZZD3.D3_QUANT)                                                                                                                                        ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("SD3") + " ZZD3 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("              WHERE ZZD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                                  ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(ZZD3.D3_EMISSAO, 1, 6) = SUBSTRING(SD3.D3_EMISSAO, 1, 6)                                                                                     ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_COD = SC2.C2_PRODUTO                                                                                                                           ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(ZZD3.D3_EMISSAO, 1, 6) = SUBSTRING(SD3.D3_EMISSAO, 1, 6)                                                                                     ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_TM = '010'                                                                                                                                     ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ) QTD_ACUM,                                                                                                                                                          ") + msEnter
	RL002 += Alltrim("                 D3_DOC DOCUMEN,                                                                                                                                               ") + msEnter
	RL002 += Alltrim("                 CASE                                                                                                                                                          ") + msEnter
	RL002 += Alltrim("                     WHEN SD3.D3_TM = '010'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                     THEN '001'                                                                                                                                                ") + msEnter
	RL002 += Alltrim("                     WHEN SD3.D3_TM = '999'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                          AND SD3.D3_CONTA = '11301020'                                                                                                                        ") + msEnter
	RL002 += Alltrim("                     THEN '005'                                                                                                                                                ") + msEnter
	RL002 += Alltrim("                     WHEN SD3.D3_TM = '999'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                          AND SD3.D3_CONTA = '11302020'                                                                                                                        ") + msEnter
	RL002 += Alltrim("                     THEN '015'                                                                                                                                                ") + msEnter
	RL002 += Alltrim("                     ELSE D3_YITCUS                                                                                                                                            ") + msEnter
	RL002 += Alltrim("                 END ITCUS                                                                                                                                                     ") + msEnter
	//RL002 += Alltrim("                 D3_YITCUS ITCUS                                                                                                                                               ") + msEnter
	RL002 += Alltrim("          FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                                                      ") + msEnter
	RL002 += Alltrim("               INNER JOIN " + RetSqlName("SC2") + " SC2 WITH(NOLOCK) ON SC2.C2_FILIAL = '" + xFilial("SC2") + "'                                                               ") + msEnter
	RL002 += Alltrim("                                                     AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)                                                                               ") + msEnter
	RL002 += Alltrim("                                                     AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)                                                                              ") + msEnter
	RL002 += Alltrim("                                                     AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)                                                                            ") + msEnter
	RL002 += Alltrim("                                                     AND SC2.D_E_L_E_T_ = ' '                                                                                                  ") + msEnter
	RL002 += Alltrim("          WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                                       ") + msEnter
	RL002 += Alltrim("                AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                          ") + msEnter
	RL002 += Alltrim("                AND SD3.D3_ESTORNO = ' '                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                AND SD3.D_E_L_E_T_ = ' '                                                                                                                                       ") + msEnter
	RL002 += Alltrim("          GROUP BY SD3.D3_NUMSEQ,                                                                                                                                              ") + msEnter
	RL002 += Alltrim("                   SD3.D3_OP,                                                                                                                                                  ") + msEnter
	RL002 += Alltrim("                   SC2.C2_REVISAO,                                                                                                                                             ") + msEnter
	RL002 += Alltrim("                   SC2.C2_PRODUTO,                                                                                                                                             ") + msEnter
	RL002 += Alltrim("                   SC2.C2_QUANT,                                                                                                                                               ") + msEnter
	RL002 += Alltrim("                   SD3.D3_EMISSAO,                                                                                                                                             ") + msEnter
	RL002 += Alltrim("                   SD3.D3_TM,                                                                                                                                                  ") + msEnter
	RL002 += Alltrim("                   SD3.D3_CF,                                                                                                                                                  ") + msEnter
	RL002 += Alltrim("                   SD3.D3_CONTA,                                                                                                                                               ") + msEnter
	RL002 += Alltrim("                   SD3.D3_COD,                                                                                                                                                 ") + msEnter
	RL002 += Alltrim("                   D3_DOC,                                                                                                                                                     ") + msEnter
	RL002 += Alltrim("                   D3_YITCUS                                                                                                                                                   ") + msEnter
	RL002 += Alltrim("          UNION ALL                                                                                                                                                            ") + msEnter
	RL002 += Alltrim("          SELECT 'SD3' ORIGTAB,                                                                                                                                                ") + msEnter
	RL002 += Alltrim("                 SD3.D3_YRFCUST NUMSEQ,                                                                                                                                        ") + msEnter
	RL002 += Alltrim("                 SD3.D3_OP NUMOP,                                                                                                                                              ") + msEnter
	RL002 += Alltrim("                 '   ' REVOP,                                                                                                                                                  ") + msEnter
	RL002 += Alltrim("                 CAN.PRODUTO PROD_OP,                                                                                                                                          ") + msEnter
	RL002 += Alltrim("                 0 QTD_OP,                                                                                                                                                     ") + msEnter
	RL002 += Alltrim("                 SD3.D3_EMISSAO EMISSAO,                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                 SD3.D3_TM TM,                                                                                                                                                 ") + msEnter
	RL002 += Alltrim("                 SD3.D3_CF CF,                                                                                                                                                 ") + msEnter
	RL002 += Alltrim("                 SD3.D3_CONTA CONTA,                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 SD3.D3_COD COD_APON,                                                                                                                                          ") + msEnter
	RL002 += Alltrim("                 0 CUSUNIT,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                 0 QTDUNIT,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                 (SD3.D3_QUANT) * (-1) QUANT,                                                                                                                                  ") + msEnter
	RL002 += Alltrim("                 (SD3.D3_CUSTO1) * (-1) CUSTO,                                                                                                                                 ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT ZZD3.D3_QUANT * (-1)                                                                                                                                      ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("SD3") + " ZZD3 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("              WHERE ZZD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                                  ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_EMISSAO = SD3.D3_EMISSAO                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_NUMSEQ = SD3.D3_YRFCUST                                                                                                                        ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_TM = '711'                                                                                                                                     ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ) QTD_APON,                                                                                                                                                          ") + msEnter
	RL002 += Alltrim("          (                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("              SELECT SUM(ZZD3.D3_QUANT) * (-1)                                                                                                                                 ") + msEnter
	RL002 += Alltrim("              FROM " + RetSqlName("SD3") + " ZZD3 WITH(NOLOCK)                                                                                                                 ") + msEnter
	RL002 += Alltrim("              WHERE ZZD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                                  ") + msEnter
	RL002 += Alltrim("                    AND SUBSTRING(ZZD3.D3_EMISSAO, 1, 6) = SUBSTRING(SD3.D3_EMISSAO, 1, 6)                                                                                     ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_YRFCUST = SD3.D3_YRFCUST                                                                                                                       ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D3_TM = '711'                                                                                                                                     ") + msEnter
	RL002 += Alltrim("                    AND ZZD3.D_E_L_E_T_ = ' '                                                                                                                                  ") + msEnter
	RL002 += Alltrim("          ) QTD_ACUM,                                                                                                                                                          ") + msEnter
	RL002 += Alltrim("                 SD3.D3_DOC DOCUMEN,                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 CASE                                                                                                                                                          ") + msEnter
	RL002 += Alltrim("                     WHEN SD3.D3_TM = '711'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                     THEN '001'                                                                                                                                                ") + msEnter
	RL002 += Alltrim("                     WHEN SD3.D3_TM = '211'                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                     THEN CT1.CT1_YITCUS                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                     ELSE D3_YITCUS                                                                                                                                            ") + msEnter
	RL002 += Alltrim("                 END ITCUS                                                                                                                                                     ") + msEnter
	//RL002 += Alltrim("                 SD3.D3_YITCUS ITCUS                                                                                                                                           ") + msEnter
	RL002 += Alltrim("          FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                                                      ") + msEnter
	RL002 += Alltrim("               INNER JOIN CANPROD CAN ON CAN.RFCUST = SD3.D3_YRFCUST                                                                                                           ") + msEnter
	RL002 += Alltrim("               LEFT JOIN " + RetSqlName("CT1") + " CT1 WITH(NOLOCK) ON CT1.CT1_FILIAL = '" + xFilial("CT1") + "'                                                               ") + msEnter
	RL002 += Alltrim("                                                    AND CT1_CONTA = SD3.D3_CONTA                                                                                               ") + msEnter
	RL002 += Alltrim("                                                    AND CT1.D_E_L_E_T_ = ' '                                                                                                   ") + msEnter
	RL002 += Alltrim("          WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                                       ") + msEnter
	RL002 += Alltrim("                AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                          ") + msEnter
	RL002 += Alltrim("                AND SD3.D3_TM IN('711', '211')                                                                                                                                 ") + msEnter
	RL002 += Alltrim("               AND SD3.D3_ESTORNO = ' '                                                                                                                                        ") + msEnter
	RL002 += Alltrim("               AND SD3.D_E_L_E_T_ = ' ')                                                                                                                                       ") + msEnter
	RL002 += Alltrim("      SELECT TAB.ORIGTAB TABELA,                                                                                                                                               ") + msEnter
	RL002 += Alltrim("             PROD_OP CODPAI,                                                                                                                                                   ") + msEnter
	RL002 += Alltrim("             SB1PAI.B1_DESC AS DESCPAI,                                                                                                                                        ") + msEnter
	RL002 += Alltrim("             SB1PAI.B1_YFORMAT AS FORMATO,                                                                                                                                     ") + msEnter
	RL002 += Alltrim("             TAB.PERIODO,                                                                                                                                                      ") + msEnter
	RL002 += Alltrim("             TM,                                                                                                                                                               ") + msEnter
	RL002 += Alltrim("             CF,                                                                                                                                                               ") + msEnter
	RL002 += Alltrim("             TAB.CONTA,                                                                                                                                                        ") + msEnter
	RL002 += Alltrim("             CT1.CT1_DESC01 AS DESCONTA,                                                                                                                                       ") + msEnter
	RL002 += Alltrim("             TAB.ITCUS AS CODITE,                                                                                                                                              ") + msEnter
	RL002 += Alltrim("             Z29.Z29_DESCR AS DESCIT,                                                                                                                                          ") + msEnter
	RL002 += Alltrim("             Z29.Z29_TIPO AS TPITC,                                                                                                                                            ") + msEnter
	RL002 += Alltrim("             TAB.COD_APON AS CODFIL,                                                                                                                                           ") + msEnter
	RL002 += Alltrim("             SB1FILHO.B1_DESC AS DESFIL,                                                                                                                                       ") + msEnter
	RL002 += Alltrim("             QUANT,                                                                                                                                                            ") + msEnter
	RL002 += Alltrim("             CUSTO,                                                                                                                                                            ") + msEnter
	RL002 += Alltrim("             TAB.QTD_APON AS QTDAPON,                                                                                                                                          ") + msEnter
	RL002 += Alltrim("             CASE                                                                                                                                                              ") + msEnter
	RL002 += Alltrim("                 WHEN TAB.QTD_APON = 0                                                                                                                                         ") + msEnter
	RL002 += Alltrim("                 THEN 0                                                                                                                                                        ") + msEnter
	RL002 += Alltrim("                 ELSE QUANT / TAB.QTD_APON                                                                                                                                     ") + msEnter
	RL002 += Alltrim("             END AS QTDPON,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("             CASE                                                                                                                                                              ") + msEnter
	RL002 += Alltrim("                 WHEN TAB.QTD_APON = 0                                                                                                                                         ") + msEnter
	RL002 += Alltrim("                 THEN 0                                                                                                                                                        ") + msEnter
	RL002 += Alltrim("                 ELSE CUSTO / TAB.QTD_APON                                                                                                                                     ") + msEnter
	RL002 += Alltrim("             END AS CUSPON,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("             QTD_ACUM AS QTD_ACUM,                                                                                                                                             ") + msEnter
	RL002 += Alltrim("             CASE                                                                                                                                                              ") + msEnter
	RL002 += Alltrim("                 WHEN QTD_ACUM = 0                                                                                                                                             ") + msEnter
	RL002 += Alltrim("                 THEN QTDUNIT                                                                                                                                                  ") + msEnter
	RL002 += Alltrim("                 ELSE QUANT / QTD_ACUM                                                                                                                                         ") + msEnter
	RL002 += Alltrim("             END AS QTDACUM,                                                                                                                                                   ") + msEnter
	RL002 += Alltrim("             CASE                                                                                                                                                              ") + msEnter
	RL002 += Alltrim("                 WHEN QTD_ACUM = 0                                                                                                                                             ") + msEnter
	RL002 += Alltrim("                 THEN CUSUNIT                                                                                                                                                  ") + msEnter
	RL002 += Alltrim("                 ELSE CUSTO / QTD_ACUM                                                                                                                                         ") + msEnter
	RL002 += Alltrim("             END AS CUSACUM                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("      FROM                                                                                                                                                                     ") + msEnter
	RL002 += Alltrim("      (                                                                                                                                                                        ") + msEnter
	RL002 += Alltrim("          SELECT ORIGTAB,                                                                                                                                                      ") + msEnter
	RL002 += Alltrim("                 PROD_OP,                                                                                                                                                      ") + msEnter
	RL002 += Alltrim("                 SUBSTRING(EMISSAO, 1, 6) PERIODO,                                                                                                                             ") + msEnter
	RL002 += Alltrim("                 TM,                                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 CF,                                                                                                                                                           ") + msEnter
	RL002 += Alltrim("                 CONTA,                                                                                                                                                        ") + msEnter
	RL002 += Alltrim("                 ITCUS,                                                                                                                                                        ") + msEnter
	RL002 += Alltrim("                 COD_APON,                                                                                                                                                     ") + msEnter
	RL002 += Alltrim("                 CUSUNIT,                                                                                                                                                      ") + msEnter
	RL002 += Alltrim("                 QTDUNIT,                                                                                                                                                      ") + msEnter
	RL002 += Alltrim("                 SUM(QUANT) QUANT,                                                                                                                                             ") + msEnter
	RL002 += Alltrim("                 SUM(CUSTO) CUSTO,                                                                                                                                             ") + msEnter
	RL002 += Alltrim("                 SUM(QTD_APON) QTD_APON,                                                                                                                                       ") + msEnter
	RL002 += Alltrim("                 QTD_ACUM                                                                                                                                                      ") + msEnter
	RL002 += Alltrim("          FROM DADOSPRODUC DPC                                                                                                                                                 ") + msEnter
	RL002 += Alltrim("          GROUP BY ORIGTAB,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                   PROD_OP,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                   SUBSTRING(EMISSAO, 1, 6),                                                                                                                                   ") + msEnter
	RL002 += Alltrim("                   TM,                                                                                                                                                         ") + msEnter
	RL002 += Alltrim("                   CF,                                                                                                                                                         ") + msEnter
	RL002 += Alltrim("                   CONTA,                                                                                                                                                      ") + msEnter
	RL002 += Alltrim("                   CUSUNIT,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                   QTDUNIT,                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("                   ITCUS,                                                                                                                                                      ") + msEnter
	RL002 += Alltrim("                   COD_APON,                                                                                                                                                   ") + msEnter
	RL002 += Alltrim("                   QTD_ACUM                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("      ) TAB                                                                                                                                                                    ") + msEnter
	RL002 += Alltrim("      JOIN " + RetSqlName("SB1") + " SB1PAI ON SB1PAI.B1_FILIAL = '" + xFilial("SB1") + "'                                                                                     ") + msEnter
	RL002 += Alltrim("                            AND SB1PAI.B1_COD = TAB.PROD_OP                                                                                                                    ") + msEnter
	RL002 += Alltrim("                            AND SB1PAI.D_E_L_E_T_ = ' '                                                                                                                        ") + msEnter
	RL002 += Alltrim("      JOIN " + RetSqlName("SB1") + " SB1FILHO ON SB1FILHO.B1_FILIAL = '" + xFilial("SB1") + "'                                                                                 ") + msEnter
	RL002 += Alltrim("                              AND SB1FILHO.B1_COD = TAB.COD_APON                                                                                                               ") + msEnter
	RL002 += Alltrim("                              AND SB1FILHO.D_E_L_E_T_ = ' '                                                                                                                    ") + msEnter
	RL002 += Alltrim("      LEFT JOIN Z29010 Z29 ON Z29.Z29_FILIAL = '" + xFilial("Z29") + "'                                                                                                        ") + msEnter
	RL002 += Alltrim("                              AND Z29.Z29_COD_IT = TAB.ITCUS                                                                                                                   ") + msEnter
	RL002 += Alltrim("                              AND Z29.D_E_L_E_T_ = ' '                                                                                                                         ") + msEnter
	RL002 += Alltrim("      LEFT JOIN " + RetSqlName("CT1") + " CT1 ON CT1.CT1_FILIAL = '" + xFilial("CT1") + "'                                                                                     ") + msEnter
	RL002 += Alltrim("                              AND CT1.CT1_CONTA = TAB.CONTA                                                                                                                    ") + msEnter
	RL002 += Alltrim("                              AND CT1.D_E_L_E_T_ = ' '                                                                                                                         ") + msEnter
	RL002 += Alltrim("      WHERE TAB.PROD_OP BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'                                                                                                      ") + msEnter
	RL002 += Alltrim("      ORDER BY ORIGTAB,                                                                                                                                                        ") + msEnter
	RL002 += Alltrim("               PROD_OP,                                                                                                                                                        ") + msEnter
	RL002 += Alltrim("               PERIODO,                                                                                                                                                        ") + msEnter
	RL002 += Alltrim("               TM,                                                                                                                                                             ") + msEnter
	RL002 += Alltrim("               TAB.COD_APON                                                                                                                                                    ") + msEnter
	RLIndex := CriaTrab(Nil,.f.)

	nHandle := FCreate("c:\temp\consultaSQL_BIAFG013.txt")
	FWrite(nHandle, RL002)
	FClose(nHandle)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RL002),'RL02',.T.,.T.)
	dbSelectArea("RL02")
	RL02->(DbGoTop())
	Count To nTotReg 
	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		RL02->(DbCloseArea())
		return
	endif
	RL02->(dbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio",{20,56,61,210,60,60,44,41,41,54,153,61,146,72,210,73,73,73,73,73,73,73,73},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,21) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,21) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Pseudo-Apontamento ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,21)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()

	oExcel:AddCelula("Tabela"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cod. Pai"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc. Pai"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Formato"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Período"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("TM"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CF"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Conta"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc. Conta"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("It. Custo"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc. Item Custo"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Tipo ItCus"     			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cod. Comp."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc. Comp."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Qtd."						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Qtd. Apont."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Qtd. Pond."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Pond."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Qtd. Acum."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Qtd.Unit.Acm"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cst.Unit.Acm"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	While RL02->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		If SUBSTR(ALLTRIM(RL02->CODFIL),1,3) == 'MOD' 
			If RL02->CUSTO < 0
				_nFator	:=	-1
			Else
				_nFator	:=	1
			EndIf
		Else
			_nFator	:=	1
		EndIf

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula( RL02->TABELA		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->CODPAI		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->DESCPAI		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->FORMATO		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->PERIODO		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->TM			        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->CF			        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->CONTA		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->DESCONTA	        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->CODITE		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->DESCIT		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->TPITC		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->CODFIL		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->DESFIL		        ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->QUANT * _nFator		,8		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->CUSTO		        ,4		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->QTDAPON 		    ,8		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->QTDPON * _nFator	,8		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->CUSPON		        ,4		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->QTD_ACUM	        ,8		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->QTDACUM * _nFator 	,8		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( RL02->CUSACUM	            ,4		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		RL02->(DbSkip())

	EndDo
	fGeraParametros()
	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	RL02->(dbCloseArea())

Return

//Gera parametros
Static Function fGeraParametros()

	local nCont		 := 0 
	local cCorFundo  := ""
	local cTitulo	 := 'Parametros'

	local cFonte1    := 'Calibri' 
	local nTamFont1  := 9
	local cCorFont1  := '#FFFFFF'
	local cCorFund1  := '#4F81BD'

	local cFonte2    := 'Arial' 
	local nTamFont2  := 9
	local cCorFont2  := '#000000'

	aPergs[1,3] := MV_PAR01 
	aPergs[2,3] := MV_PAR02  
	aPergs[3,3] := MV_PAR03 
	aPergs[4,3] := MV_PAR04	
	aPergs[5,3] := cDirDest     

	oExcel:AddPlanilha('Parametros',{30,80,120,270})
	oExcel:AddLinha(18)
	oExcel:AddCelula(cTitulo,0,'C','Arial',12,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula( "Sequencia" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Pergunta"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Conteudo"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 

	for nCont := 1 to Len(aPergs)	

		if MOD(nCont,2) > 0 
			cCorFundo := '#DCE6F1'	
		else
			cCorFundo := '#B8CCE4'	
		endif	  

		oExcel:AddLinha(16) 
		oExcel:AddCelula()
		oExcel:AddCelula( strzero(nCont,2) ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,2]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,3]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo 

	next aPergs

Return 
