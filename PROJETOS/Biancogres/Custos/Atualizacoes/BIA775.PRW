#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA775
@author Marcos Alberto Soprani
@since 17/05/17
@version 1.0
@description Browser Principal para controle e armazenamento dos insumos e seus custos unitários para efeito orçamentário
@type function
/*/

User Function BIA775()

	Local tyArea         := GetArea()
	Private tyEnter      := Chr(13) + Chr(10)
	private cTab	     := "Z87"
	private bOpcao3      := {|| fOpcoes(cTab,0,3)} 

	Private cCadastro 	:= "Controle e Armazenamento de Custo Unitário de Insumos para Orçamento"
	Private aRotina 	:= { {"Pesquisar"            ,"AxPesqui"       ,0,1},;
	{                         "Visualizar"           ,"AxVisual"       ,0,2},;
	{                         "Incluir"              ,"EVAL(bOpcao3)"  ,0,3},;
	{                         "Alterar"              ,"AxAltera"       ,0,4},;
	{                         "Excluir"              ,"AxDeleta"       ,0,5},;
	{                         "0-Insumos p/ ORCA"    ,"U_B775GRV"      ,0,6},;
	{                         "2-Replica Custo ORCA" ,"U_B775PRD"      ,0,8} }

	dbSelectArea("Z87")
	dbSetOrder(1)

	mBrowse(6,1,22,75,"Z87",,,,,,)

	RestArea(tyArea)

Return

Static Function fOpcoes(cAlias,nReg,nOpc)

	Private cAliasX	:= cAlias
	Private nRegX	:= nReg
	Private nOpcX	:= nOpc
	Private bTudoOK := {|| fTuudoOK(cAliasX,nRegX,nOpcX)} 

	Do case
		Case nOpc == 3
		AxInclui(cAlias,nReg,nOpc,Nil,Nil,Nil,"EVAL(bTudoOK)")
	EndCase

Return

Static Function fTuudoOK(cAlias,nReg,nOpc)

	Local lRet	:= .T.
	Local _cAlias   := GetNextAlias()

	BeginSql Alias _cAlias

		SELECT COUNT(*) CONTAD
		FROM %TABLE:Z87% Z87
		WHERE Z87_FILIAL = %xFilial:Z87%
		AND Z87_DATARF = %Exp:M->Z87_DATARF%
		AND Z87_PRODUT = %Exp:M->Z87_PRODUT%
		AND Z87.%NotDel%

	EndSql

	If (_cAlias)->(!Eof())
		If (_cAlias)->(CONTAD) > 0
			MsgINFO("O produto já possui custo para a data informada!!!")
			lRet := .F.
		EndIf
	EndIf

	(_cAlias)->(dbCloseArea())

Return lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B775GRV  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/05/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Captura e grava os códigos dos insumos que faram parte da  ¦¦¦
¦¦¦          ¦ range orçamentária                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B775GRV()

	Processa({|| RptB775GRV()})

Return

Static Function RptB775GRV()

	Local iaEnter := CHR(13) + CHR(10)

	fPerg := "BIA775"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	tyDtIni := MV_PAR01
	tyDtFim := MV_PAR02

	rtContinua := .T.

	TR002 := " WITH REGORCTO AS (SELECT 'CUST' TIPO, COUNT(*) CONTAD "
	TR002 += "                     FROM " + RetSqlName("Z87") + " Z87 WITH (NOLOCK) "
	TR002 += "                    WHERE Z87_FILIAL = '" + xFilial("Z87") + "' "
	TR002 += "                      AND Z87_DATARF BETWEEN '" + dtos(tyDtIni) + "' AND '" + dtos(tyDtFim) + "' "
	TR002 += "                      AND D_E_L_E_T_ = ' ') "
	TR002 += " SELECT ISNULL([CUST],0) AS CUST "
	TR002 += "  FROM (SELECT TIPO, CONTAD "
	TR002 += "          FROM REGORCTO) AS TAB "
	TR002 += " PIVOT (SUM(CONTAD) "
	TR002 += "        FOR TIPO IN ([CUST]) ) AS FIM "
	TRcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TR002),'TR02',.F.,.T.)
	dbSelectArea("TR02")
	dbGoTop()
	If ( TR02->CUST ) > 0

		trMensag := " Foram encontrados os seguintes registros na base de dados que estão diretamente associado o processo orçamentário: " + iaEnter 
		trMensag += " " + iaEnter
		trMensag += "   Custo Insumos: " + Transform(TR02->CUST, "@E 999,999,999") + iaEnter
		trMensag += " " + iaEnter
		trMensag += " Para prosseguir com o processamento é necessário apagar todos os registros relacionados ao período orçamentário. " + iaEnter
		trMensag += " " + iaEnter
		trMensag += " Deseja continuar o processamento, clique <Sim>. Para abortar <Não> " + iaEnter

		nOpc := Aviso( "BIA775", trMensag, { "Sim", "Não" }, 3, "Verificação de Registro nas tabela de Orçamento!!! ", , 'ENGRENAGEM', .F. , )

		If nOpc == 1

			TR005 := " DELETE " + RetSqlName("Z87") + " "
			TR005 += "  WHERE Z87_FILIAL = '" + xFilial("Z87") + "' "
			TR005 += "    AND Z87_DATARF BETWEEN " + ValtoSql(tyDtIni) + " AND " + ValtoSql(tyDtFim) + " "
			TR005 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Zerando Custo Unitário Insumos...",,{|| TCSQLExec(TR005)})

		ElseIf nOpc == 2

			rtContinua := .F.

		EndIf 

	EndIf

	TR02->(dbCloseArea())
	Ferase(TRcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TRcIndex+OrdBagExt())          //indice gerado

	If rtContinua

		FH002 := Alltrim(" WITH NIVEIS AS (                                                                                                ") + tyEnter
		//                                 -- Membro âncora
		FH002 += Alltrim("                 SELECT SGG.GG_COMP     ID,                                                                      ") + tyEnter
		FH002 += Alltrim("                        SGG.GG_COD      IDPAI,                                                                   ") + tyEnter
		FH002 += Alltrim("                        SGG.GG_INI      DTINI,                                                                   ") + tyEnter
		FH002 += Alltrim("                        SGG.GG_FIM      DTFIM,                                                                   ") + tyEnter
		FH002 += Alltrim("                        SGG.R_E_C_N_O_  REGSGG,                                                                  ") + tyEnter
		FH002 += Alltrim("                        0               NIVEL                                                                    ") + tyEnter
		FH002 += Alltrim("                   FROM " + RetSqlName("SGG") + " SGG (NOLOCK)                                                   ") + tyEnter
		FH002 += Alltrim("                  INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_COD = SGG.GG_COD                   ") + tyEnter
		FH002 += Alltrim("                                                AND SB1.B1_TIPO IN('PA')                                         ") + tyEnter
		FH002 += Alltrim("                                                AND SB1.D_E_L_E_T_ = ' '                                         ") + tyEnter
		FH002 += Alltrim("                  WHERE SGG.GG_FILIAL = '" + xFilial("SGG") + "'                                                 ") + tyEnter
		FH002 += Alltrim("                    AND '" + dtos(tyDtIni) + "' <= SGG.GG_INI                                                    ") + tyEnter
		FH002 += Alltrim("                    AND '" + dtos(tyDtFim) + "' >= SGG.GG_FIM                                                    ") + tyEnter
		FH002 += Alltrim("                    AND SGG.D_E_L_E_T_ = ' '                                                                     ") + tyEnter
		FH002 += Alltrim("                  UNION ALL                                                                                      ") + tyEnter
		//                                 -- Filhos
		FH002 += Alltrim("                 SELECT T1.GG_COMP     ID,                                                                       ") + tyEnter
		FH002 += Alltrim("                        T1.GG_COD      IDPAI,                                                                    ") + tyEnter
		FH002 += Alltrim("                        T1.GG_INI      DTINI,                                                                    ") + tyEnter
		FH002 += Alltrim("                        T1.GG_FIM      DTFIM,                                                                    ") + tyEnter
		FH002 += Alltrim("                        T1.R_E_C_N_O_  REGSGG,                                                                   ") + tyEnter
		FH002 += Alltrim("                        NIVEL + 1      NIVEL                                                                     ") + tyEnter
		FH002 += Alltrim("                   FROM " + RetSqlName("SGG") + "  T1 (NOLOCK)                                                   ") + tyEnter
		FH002 += Alltrim("                  INNER JOIN NIVEIS ON T1.GG_COD = NIVEIS.ID                                                     ") + tyEnter
		FH002 += Alltrim("                  WHERE T1.GG_FILIAL = '" + xFilial("SGG") + "'                                                  ") + tyEnter
		FH002 += Alltrim("                    AND T1.GG_INI = NIVEIS.DTINI                                                                 ") + tyEnter
		FH002 += Alltrim("                    AND T1.GG_FIM = NIVEIS.DTFIM                                                                 ") + tyEnter
		FH002 += Alltrim("                    AND T1.D_E_L_E_T_ = ' '                                                                      ") + tyEnter
		FH002 += Alltrim("                 )                                                                                               ") + tyEnter
		FH002 += Alltrim(" SELECT DISTINCT ID, DTFIM, B1_GRUPO, RTRIM(B1_DESC) DESCR, SBZ.BZ_YUMIDAD UMID                                  ") + tyEnter
		FH002 += Alltrim("   FROM NIVEIS NIV                                                                                               ") + tyEnter
		FH002 += Alltrim("  INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON B1_COD = ID                                               ") + tyEnter
		FH002 += Alltrim("                                AND B1_TIPO NOT IN('PA','PP','PI')                                               ") + tyEnter
		FH002 += Alltrim("                                AND SB1.D_E_L_E_T_ = ' '                                                         ") + tyEnter
		FH002 += Alltrim("  INNER JOIN " + RetSqlName("SBZ") + " SBZ (NOLOCK) ON BZ_COD = ID                                               ") + tyEnter
		FH002 += Alltrim("                                AND SBZ.D_E_L_E_T_ = ' '                                                         ") + tyEnter	
		FH002 += Alltrim("  ORDER BY 2, 1                                                                                                  ") + tyEnter
		FHcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,FH002),'FH02',.F.,.T.)
		dbSelectArea("FH02")
		dbGoTop()
		ProcRegua(RecCount())
		msDtRefGrv := FH02->DTFIM
		While !Eof()

			IncProc("Processando... " + dtoc(stod(FH02->DTFIM)))

			dbSelectArea("Z87")
			dbSetOrder(1)
			If !dbSeek(xFilial("Z87") + FH02->DTFIM + FH02->ID)
				RecLock("Z87",.T.)
			Else
				RecLock("Z87",.F.)
			EndIf
			Z87->Z87_FILIAL  := xFilial("Z87")
			Z87->Z87_DATARF  := stod(FH02->DTFIM)
			Z87->Z87_PRODUT  := FH02->ID
			Z87->Z87_UMIDAD  := FH02->UMID
			MsUnLock()

			dbSelectArea("FH02")
			dbSkip()

			If msDtRefGrv <> FH02->DTFIM

				UP003 := " UPDATE " + RetSqlName("Z87") + " SET Z87_CUSTO1 = ZCH_VMES" + Substr(msDtRefGrv,5,2) + ", Z87_ORICST = 'ZCH' "
				UP003 += "   FROM " + RetSqlName("Z87") + " Z87 "
				UP003 += "  INNER JOIN " + RetSqlName("ZCH") + " ZCH ON ZCH_VERSAO = '" + MV_PAR03 + "' "
				UP003 += "                       AND ZCH_REVISA = '" + MV_PAR04 + "' "
				UP003 += "                       AND ZCH_ANOREF = '" + MV_PAR05 + "' "
				UP003 += "                       AND ZCH_CODPRO = Z87_PRODUT "
				UP003 += "                       AND ZCH_VMES" + Substr(msDtRefGrv,5,2) + " <> 0 "
				UP003 += "                       AND ZCH.D_E_L_E_T_ = ' ' "
				UP003 += "  WHERE Z87_DATARF = '" + msDtRefGrv + "' "
				UP003 += "    AND Z87.D_E_L_E_T_ = ' ' "
				TCSQLExec(UP003)

				msDtRefGrv := FH02->DTFIM

			EndIf

		End
		FH02->(dbCloseArea())
		Ferase(FHcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(FHcIndex+OrdBagExt())          //indice gerado

	Else

		MsgINFO("... Fim do Processamento ... ")

	EndIf

Return

User Function B775PRD()

	Local cBkpMv01	:=	MV_PAR01
	Local cBkpMv02	:=	MV_PAR02

	If ValidPerg()

		fIncProd()

	EndIf

	MV_PAR01	:=	cBkpMV01
	MV_PAR02	:=	cBkpMV02

Return

Static function ValidPerg()

	local cLoad	    := "B775PRD" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	local aPergs	:= {}

	MV_PAR01 := SPACE(4)
	MV_PAR02 := space(TamSx3("B1_COD")[1])
	MV_PAR03 := 0
	MV_PAR04 := SPACE(2)

	aAdd( aPergs ,{1,"Ano"		              ,MV_PAR01 ,"9999",""	                	    ,""   ,'.T.',20,.T.})	
	aAdd( aPergs ,{1,"Código Produto"		  ,MV_PAR02 ,"@!","EXISTCPO('SB1')"		        ,"SB1",'.T.',50,.T.})	
	aAdd( aPergs ,{1,"Custo"		          ,MV_PAR03 ,"@E 999,999.9999","POSITIVO()"	    ,""   ,'.T.',50,.T.})	
	aAdd( aPergs ,{1,"Tratar Mês a partir de" ,MV_PAR04 ,"99",""	                     	,""   ,'.T.',20,.T.})	

	If ParamBox(aPergs ,"Inclusão de Produto - Ano",,,,,,,,cFileName,.T.,.T.)  

		lRet := .T.

		MV_PAR01 := ParamLoad(cFileName,,1 ,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2 ,MV_PAR02) 
		MV_PAR03 := ParamLoad(cFileName,,2 ,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,2 ,MV_PAR04) 

	endif

return lRet

Static Function fIncProd()

	Local _nI
	Local _cErros	:=	""
	Local _cAlias   :=	GetNextAlias()
	Local _dData	:=	Stod(MV_PAR01 + "0101") //Sempre Inicio com a Primeira data do Ano Solicitado

	SBZ->(dbSetOrder(1))
	SBZ->(dbSeek(xFilial("SBZ") + MV_PAR02))
	xk_Umidad := SBZ->BZ_YUMIDAD

	If Empty(MV_PAR04)

		If fVerCus(_dData,MV_PAR02)
			_cErros	+=	DtoC(_dData) + CRLF
		Else
			Reclock("Z87",.T.)
			Z87->Z87_FILIAL  := xFilial("Z87")
			Z87->Z87_DATARF  := _dData
			Z87->Z87_PRODUT  := MV_PAR02
			Z87->Z87_CUSTO1  := MV_PAR03
			Z87->Z87_DTCUST  := Date()
			Z87->Z87_ORICST  := "I"
			Z87->Z87_UMIDAD  := xk_Umidad
			Z87->(MsUnlock())
		EndIf

	EndIf

	For _nI	:= 1 to 12 //Verifica custo ano a ano

		If Empty(MV_PAR04) .or. MV_PAR04 <= PADL(Alltrim(Str(_nI)),2,"0")

			_dData	:=	LastDate(Stod(MV_PAR01 + PADL(Alltrim(Str(_nI)),2,"0") + "01")) 

			If fVerCus(_dData,MV_PAR02)
				_cErros	+=	DtoC(_dData) + CRLF
			Else
				Reclock("Z87",.T.)
				Z87->Z87_FILIAL  := xFilial("Z87")
				Z87->Z87_DATARF  := _dData
				Z87->Z87_PRODUT  := MV_PAR02
				Z87->Z87_CUSTO1  := MV_PAR03
				Z87->Z87_DTCUST  := Date()
				Z87->Z87_ORICST  := "I"
				Z87->Z87_UMIDAD  := xk_Umidad
				Z87->(MsUnlock())
			EndIf

		EndIf

	Next

	If !Empty(_cErros)
		MsgInfo("O Produto já possuía custo cadastrado nos Dias Abaixo: " + CRLF + _cErros + "Os Demais Dias Foram Inseridos!")
	Else
		MsgInfo("Os Custos Foram Inseridos com Sucesso!")
	EndIf

Return

Static Function fVerCus(_dData,_cProd)

	Local _lRet		:=	.T.
	Local _cAlias	:=	GetNextAlias()
	Local _cData	:=	Dtos(_dData)

	BeginSql Alias _cAlias
		SELECT COUNT(*) CONTAD
		FROM %TABLE:Z87% Z87
		WHERE Z87_FILIAL = %xFilial:Z87%
		AND Z87_DATARF = %Exp:_cData%
		AND Z87_PRODUT = %Exp:MV_PAR02%
		AND Z87.%NotDel%
	EndSql

	_lRet	:=	(_cAlias)->CONTAD > 0

	(_cAlias)->(DbCloseArea())

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg    ¦ Autor ¦ Marcos Alberto S ¦ Data ¦ 13/05/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Versão Orçamentária      ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"04","Revisão da Versão        ?","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Ano Ref.                 ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

	dbSelectArea(_sAlias)

Return
