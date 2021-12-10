#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA647
@author Marcos Alberto Soprani
@since 14/11/17
@version 1.0
@description Rotina de listar o desdobramento do Orçamento de RECEITA em meses  
@type function
/*/

User Function BIA647()

	Private msrhEnter := CHR(13) + CHR(10)
	Private aDados2   := {}
	ktNomArq := "BIA647"

	fPerg := "BIA647"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03
	_cMarca    := MV_PAR04

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	AVISO( "Formato do arquivo", "Devido a performance de transformação de arquivos .xml em arquivos .xlsx e o volume de dados a ser processamento deste desdobramento de RECEITA, optou-se em gerar os dados em formato .csv por ser mais leve e compatível com o excel",  { "Ok" }, 3 )

	Processa({ || cMsg := BIA647A() }, "Aguarde...", "Carregando dados...", .F.)

Return

Static Function BIA647A()

	ZL009 := " SELECT ZBH_VERSAO, "
	ZL009 += "        ZBH_REVISA, "
	ZL009 += "        ZBH_ANOREF, "
	ZL009 += "        ZBH_PERIOD, "
	ZL009 += "        ZBH_MARCA, "
	ZL009 += "        Z37_DESCR, "
	ZL009 += "        ZBH_CANALD, "
	ZL009 += "        ZBJ_DESCR, "
	ZL009 += "        ZBH_VEND, "
	ZL009 += "        A3_NOME, "
	ZL009 += "        ZBH_GRPCLI, "
	ZL009 += "        ZBH_TPSEG, "
	ZL009 += "        ZBH_ESTADO, "
	ZL009 += "        ZBH_PCTGMR, "
	ZL009 += "        SX5.X5_DESCRI, "
	ZL009 += "        ZBH_FORMAT, "
	ZL009 += "        ZZ6_DESC, "
	ZL009 += "        ZBH_CATEG, "
	ZL009 += "        ZBH_CLASSE, "
	ZL009 += "        ZBH_QUANT, "
	ZL009 += "        ZBH_VALOR, "
	ZL009 += "        ZBH_TOTAL, "
	ZL009 += "        ZBH_PCOMIS, "
	ZL009 += "        ZBH_VCOMIS, "
	ZL009 += "        ZBH_BICMS, "
	ZL009 += "        ZBH_PICMS, "
	ZL009 += "        ZBH_VICMS, "
	ZL009 += "        ZBH_BPIS, "
	ZL009 += "        ZBH_PPIS, "
	ZL009 += "        ZBH_VPIS, "
	ZL009 += "        ZBH_BCOF, "
	ZL009 += "        ZBH_PCOF, "
	ZL009 += "        ZBH_VCOF, "
	ZL009 += "        ZBH_BST, "
	ZL009 += "        ZBH_PST, "
	ZL009 += "        ZBH_VST, "
	ZL009 += "        ZBH_BDIFAL, "
	ZL009 += "        ZBH_PDIFAL, "
	ZL009 += "        ZBH_VDIFAL, "
	ZL009 += "        ZBH_BIPI, "
	ZL009 += "        ZBH_PIPI, "
	ZL009 += "        ZBH_VIPI, "
	ZL009 += "        ZBH_PRZMET,	"
	ZL009 += "        ZBH_PERVER,	"
	ZL009 += "        ZBH_VALVER,	"
	ZL009 += "        ZBH_PERBON,	"
	ZL009 += "        ZBH_VALBON,	"
	ZL009 += "        ZBH_PERCPV,	"
	ZL009 += "        ZBH_VALCPV,	"
	ZL009 += "        ZBH_BICMBO, "
	ZL009 += "        ZBH_PICMBO,	"
	ZL009 += "        ZBH_VICMBO	"
	ZL009 += "   FROM " + RetSqlName("ZBH") + " ZBH "
	ZL009 += "   LEFT JOIN " + RetSqlName("Z37") + " Z37 ON Z37_MARCA = ZBH_MARCA "
	ZL009 += "                       AND Z37.D_E_L_E_T_ = ' ' "
	ZL009 += "   LEFT JOIN " + RetSqlName("ZBJ") + " ZBJ ON ZBJ_CANALD = ZBH_CANALD "
	ZL009 += "                       AND ZBJ.D_E_L_E_T_ = ' ' "
	ZL009 += "   LEFT JOIN " + RetSqlName("SA3") + " SA3 ON A3_COD = ZBH_VEND "
	ZL009 += "                       AND SA3.D_E_L_E_T_ = ' ' "
	ZL009 += "   LEFT JOIN " + RetSqlName("SX5") + " SX5 ON SX5.X5_TABELA = 'ZH' "
	ZL009 += "                       AND SX5.X5_CHAVE = ZBH_PCTGMR "
	ZL009 += "                       AND SX5.D_E_L_E_T_ = ' ' "
	ZL009 += "   LEFT JOIN " + RetSqlName("ZZ6") + " ZZ6 ON ZZ6_COD = ZBH_FORMAT "
	ZL009 += "                       AND ZZ6.D_E_L_E_T_ = ' ' "
	ZL009 += "  WHERE ZBH.ZBH_VERSAO = '" + _cVersao + "' "
	ZL009 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
	ZL009 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
	If !Empty(_cMarca)
		ZL009 += "    AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
	EndIf
	ZL009 += "    AND ZBH.ZBH_PERIOD <> '00' "
	ZL009 += "    AND ZBH.ZBH_ORIGF = '5' "
	ZL009 += "    AND ZBH.D_E_L_E_T_ = ' ' "
	ZL009 += " 	ORDER BY ZBH_VERSAO,
	ZL009 += "           ZBH_REVISA,
	ZL009 += "           ZBH_ANOREF,
	ZL009 += "           ZBH_PERIOD,
	ZL009 += "           ZBH_MARCA ,
	ZL009 += "           ZBH_CANALD,
	ZL009 += "           ZBH_VEND,
	ZL009 += "           ZBH_GRPCLI,
	ZL009 += "           ZBH_TPSEG ,
	ZL009 += "           ZBH_ESTADO,
	ZL009 += "           ZBH_PCTGMR,
	ZL009 += "           ZBH_FORMAT,
	ZL009 += "           ZBH_CATEG,
	ZL009 += "           ZBH_CLASSE
	ZLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZL009),'ZL09',.T.,.T.)
	dbSelectArea("ZL09")
	ZL09->(dbGoTop())

	ProcRegua(RecCount())
	If !ZL09->(Eof())

		While !ZL09->(Eof())

			IncProc("Processando registro...: " + Alltrim(Str(ZL09->(Recno()))) )

			aAdd(aDados2, { ZL09->ZBH_VERSAO ,;
			ZL09->ZBH_REVISA ,;
			ZL09->ZBH_ANOREF ,;
			ZL09->ZBH_PERIOD ,;
			ZL09->ZBH_MARCA  ,;
			ZL09->Z37_DESCR  ,;
			ZL09->ZBH_CANALD ,;
			ZL09->ZBJ_DESCR  ,;
			ZL09->ZBH_VEND   ,;
			ZL09->A3_NOME    ,;
			ZL09->ZBH_GRPCLI ,;
			ZL09->ZBH_TPSEG  ,;
			ZL09->ZBH_ESTADO ,;
			ZL09->ZBH_PCTGMR ,;
			ZL09->X5_DESCRI  ,;
			ZL09->ZBH_FORMAT ,;
			ZL09->ZZ6_DESC   ,;
			ZL09->ZBH_CATEG  ,;
			ZL09->ZBH_CLASSE ,;
			Transform( ZL09->ZBH_QUANT  , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VALOR  , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_TOTAL  , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PCOMIS , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VCOMIS , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_BICMS  , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PICMS  , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VICMS  , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_BPIS   , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PPIS   , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VPIS   , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_BCOF   , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PCOF   , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VCOF   , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_BST    , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PST    , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VST    , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_BDIFAL    , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PDIFAL , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VDIFAL , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_BIPI    , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PIPI , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VIPI , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PRZMET , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PERVER , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VALVER , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PERBON , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VALBON , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PERCPV , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VALCPV , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_BICMBO , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_PICMBO , "@E 999,999,999.9999") ,;
			Transform( ZL09->ZBH_VICMBO , "@E 999,999,999.9999") })

			ZL09->(dbSkip())

		End

		aStru1 := ZL09->(dbStruct())

		ZL09->(dbCloseArea())
		Ferase(ZLIndex+GetDBExtension())
		Ferase(ZLIndex+OrdBagExt())

	EndIf

	U_BIAxExcel(aDados2, aStru1, ktNomArq + strzero(seconds()%3500,5) )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Versão Orçamentária      ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão Ativa            ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano de Referência        ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Marca? (se VAZIO, todas)  ","","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","Z37"})
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
