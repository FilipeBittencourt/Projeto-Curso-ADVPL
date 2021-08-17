#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"


/*/{Protheus.doc} FRINVEST
@description Rotina para geração e relatório de lançamentos de investimento em Cliente - nova versao do programa BIA488
@author Fernando Rocha
@since 23/06/2017
@version 1.0
@type function
/*/
User Function FRINVEST()

	Local aArea        := GetArea()
	local lEnd		   := .F.
	Local cRefPer	   := 'FRINVEST' + cEmpAnt
	Local cFileName    := __cUserID +"_"+ cRefPer
	Local aRet		   := {ctod(" "),ctod(" "),"","","","","","","","","",""}

	private cDirDest   := space(170)
	private dDtMovDe   := STOD('')
	private dDtMovAte  := STOD('')
	private cGrupoDe   := space(TamSX3("ACY_GRPVEN")[1])
	private cGrupoAte  := space(TamSX3("ACY_GRPVEN")[1])
	private cCliDe 	   := space(TamSX3("A1_COD")[1])
	private cCliAte	   := space(TamSX3("A1_COD")[1])
	private cContaDe   := space(TamSX3("CT1_CONTA")[1])
	private cContaAte  := space(TamSX3("CT1_CONTA")[1])
	private cClVlStr   := space(200)
	private nQGrupo	   := 1
	private nQSubGrupo := 1
	private nQPromo	   := 1
	private aQGrupo    := {"Conta Contábil","Item Contábil","Empresa"}
	private	aQSubGr	   := {"Tipo de Documento","Item Contábil","Conta Contábil","Nenhum"}
	private	aQPromo	   := {"NFs/Movimentação","Promotoras","Ambos"}
	private lGeraSI	   := .F.
	private cMatDe 	   := space(TamSX3("RA_MAT")[1])
	private cMatAte	   := space(TamSX3("RA_MAT")[1])

	private cQEmp	   := "XX"
	private	aEmps	   := {"XX=Todas","01=Biancogres","05=Incesa","14=Vinilico"}

	private lEmail     := .F.

	private cArqXML    := "REL_MKT_"+AllTrim(Upper(CUSERNAME))+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	private oExcel     := nil
	private lMonta	   := .T.
	private aPergs	   := {}
	private aTipos 	   := {"1=Por Grupo", "2=Por Cliente", "3=Ambos"}
	private cTabTemp   := GetNextAlias()
	private nTotReg    := 0
	private nContReg   := 0
	private cTitulo    := "Relatorio de Despesas de Marketing"
	private aTabRel	   := {}
	private np		   := 0
	private oProcess   := nil

	aAdd( aPergs ,{1,"DT Movimento de: " 		, dDtMovDe  ,"","NAOVAZIO()",'','.T.',50,.F.})
	aAdd( aPergs ,{1,"DT Movimento Ate:" 		, dDtMovAte ,"","NAOVAZIO()",'','.T.',50,.F.})

	aAdd( aPergs ,{6,"Pasta Destino: " 			, cDirDest  ,"","","", 75 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE} )

	aAdd( aPergs ,{1,"Cliente de: "	   			, cCliDe    ,"",,"SA1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Cliente Ate: "   			, cCliAte   ,"",,"SA1",'.T.',50,.F.})

	aAdd( aPergs ,{1,"Grupo de:"	   			, cGrupoDe  ,"",,"ACY",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Grupo Ate: "     			, cGrupoAte ,"",,"ACY",'.T.',50,.F.})

	aAdd( aPergs ,{1,"Conta Contábil De: "	   	, cContaDe   ,"",,"CT1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Conta Contábil Até: "   	, cContaAte  ,"",,"CT1",'.T.',50,.F.})

	aAdd( aPergs ,{1,"Classe de Valor? "   		, cClVlStr  ,"",,""	,'.T.',200,.F.})

	aAdd( aPergs ,{2,"Agrupar por: "			, aQGrupo[1],aQGrupo,100,".T.",.T.})
	aAdd( aPergs ,{2,"SubGrupo: "				, aQSubGr[1],aQSubGr,100,".T.",.T.})

	aAdd( aPergs ,{2,"Filtrar Registros: "		, aQPromo[1],aQPromo,100,".T.",.T.})

	aAdd( aPergs ,{2,"Gerar SI's?: "			, 1, {"Não","Sim"},100,".T.",.T.})

	aAdd( aPergs ,{1,"Matricula de:"	   		, cMatDe  ,"",,"SRA",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Matricula Ate: "     		, cMatAte ,"",,"SRA",'.T.',50,.F.})

	aAdd( aPergs ,{2,"Filtrar Empresa: "		, aEmps[1],aEmps,100,".T.",.T.})
	aAdd( aPergs ,{2,"Enviar Por Email?: "		, "S=Sim",{"S=Sim","N=Nao"},100,".T.",.T.})

	If ParamBox(aPergs ,"Contrato x Lancamentos Contabeis",aRet,,,,,,,cRefPer,.T.,.T.)

		dDtMovDe   := ParamLoad(cFileName,,1  , dDtMovDe)
		dDtMovAte  := ParamLoad(cFileName,,2  , dDtMovAte)
		cDirDest   := ParamLoad(cFileName,,3  , cDirDest)
		cCliDe 	   := ParamLoad(cFileName,,4  , cCliDe)
		cCliAte    := ParamLoad(cFileName,,5  , cCliAte)
		cGrupoDe   := ParamLoad(cFileName,,6  , cGrupoDe)
		cGrupoAte  := ParamLoad(cFileName,,7  , cGrupoAte)
		cContaDe   := ParamLoad(cFileName,,8  , cContaDe)
		cContaAte  := ParamLoad(cFileName,,9  , cContaAte)
		cClVlStr   := ParamLoad(cFileName,,10 , cClVlStr)

		nQGrupo	   := aScan(aQGrupo, {|x| AllTrim(x) == AllTrim(ParamLoad(cFileName,,11 , Space(30))) })
		nQSubGrupo := aScan(aQSubGr, {|x| AllTrim(x) == AllTrim(ParamLoad(cFileName,,12 , Space(30))) })
		nQPromo	   := aScan(aQPromo, {|x| AllTrim(x) == AllTrim(ParamLoad(cFileName,,13 , Space(30))) })

		lGeraSI	   := AllTrim("Sim") == AllTrim(ParamLoad(cFileName,,14 , Space(3)))

		cMatDe   	:= ParamLoad(cFileName,,15  , cMatDe)
		cMatAte  	:= ParamLoad(cFileName,,16  , cMatAte)

		cQEmp		:= AllTrim(ParamLoad(cFileName,,17 , Space(30)))

		lEmail		:= AllTrim(ParamLoad(cFileName,,18 , Space(1))) == "S"

		FWMakeDir(cDirDest)

		oProcess := MsNewProcess():New( {|lEnd| fImprime(@lEnd)},"Por favor aguarde, processando...","Carregando Informações",.T.)
		oProcess:Activate()
	endif

	oExcel   := nil
	RestArea(aArea)
Return


static function fImprime(lEnd)
	local nRegua1Tot := 0
	local nRegua1Con := 0
	local CSQL
	local _cConta
	local _nTotPrc

	If ( nQPromo == 1)
		_nTotPrc := 5
	ElseIf ( nQPromo == 2)
		_nTotPrc := 1
	Else
		_nTotPrc := 6
	EndIF

	nRegua1Tot := 1
	nRegua1Tot := ( nRegua1Tot * _nTotPrc ) + 1
	oProcess:SetRegua1(nRegua1Tot)

	If ( nQPromo == 1 .Or. nQPromo == 3)

		//Documentos de Entrada
		nRegua1Con++
		oProcess:IncRegua1("Status:  " + IIF((nRegua1Con/nRegua1Tot)*100 <= 99, StrZero((nRegua1Con/nRegua1Tot)*100,2), STRZERO(100,3)) + "% - SD1")
		fGeraSD1()

		//Documentos de Saida
		nRegua1Con++
		oProcess:IncRegua1("Status:  " + IIF((nRegua1Con/nRegua1Tot)*100 <= 99, StrZero((nRegua1Con/nRegua1Tot)*100,2), STRZERO(100,3)) + "% - SD2")
		fGeraSD2()

		//Movimentacoes Internas
		nRegua1Con++
		oProcess:IncRegua1("Status:  " + IIF((nRegua1Con/nRegua1Tot)*100 <= 99, StrZero((nRegua1Con/nRegua1Tot)*100,2), STRZERO(100,3)) + "% - SD3")
		fGeraSD3()

		//Movimentos Bancarios
		nRegua1Con++
		oProcess:IncRegua1("Status:  " + IIF((nRegua1Con/nRegua1Tot)*100 <= 99, StrZero((nRegua1Con/nRegua1Tot)*100,2), STRZERO(100,3)) + "% - SE5")
		fGeraSE5()

		//Lancamento Contabil Manual
		nRegua1Con++
		oProcess:IncRegua1("Status:  " + IIF((nRegua1Con/nRegua1Tot)*100 <= 99, StrZero((nRegua1Con/nRegua1Tot)*100,2), STRZERO(100,3)) + "% - CT2")
		fGeraCT2()

	EndIf

	//Gerar movimentacao de custo de Promotoras
	cLogCalculo := ""

	If ( nQPromo == 2 .Or. nQPromo == 3)

		nRegua1Con++
		oProcess:IncRegua1("Status:  " + IIF((nRegua1Con/nRegua1Tot)*100 <= 99, StrZero((nRegua1Con/nRegua1Tot)*100,2), STRZERO(100,3)) + "% - PROMOTORAS")
		cLogCalculo := fGeraPromo()

	EndIf

	//Ordenacao do vetor
	__nPosData := 3
	__nPosDoc  := 10  //posicao do campo documento
	__nPosNome := 12  //posicao do cliente/fornecedor

	If nQGrupo == 1
		nOrdGrupo	:= 5  //conta contabil
	ElseIf nQGrupo == 2
		nOrdGrupo	:= 7  //item contabil
	Else
		nOrdGrupo	:= 2  //Empresa
	EndIf

	If nQSubGrupo == 1
		nOrdSubGr	:= 1  //tipo documento
	ElseIf nQSubGrupo == 2
		nOrdSubGr	:= 7  //item contabil
	ElseIf nQSubGrupo == 3
		nOrdSubGr	:= 5  //conta contabil
	Else
		nOrdSubGr	:= 0  //conta contabil
	EndIf

	If (nOrdSubGr > 0)
		aTabRel := aSort(aTabRel,,,{|x,y| x[nOrdGrupo]+x[nOrdSubGr]+x[__nPosData]+x[__nPosNome]+x[__nPosDoc] < y[nOrdGrupo]+y[nOrdSubGr]+y[__nPosData]+y[__nPosNome]+y[__nPosDoc] })
	Else
		aTabRel := aSort(aTabRel,,,{|x,y| x[nOrdGrupo]+x[__nPosData]+x[__nPosNome]+x[__nPosDoc] < y[nOrdGrupo]+y[__nPosData]+y[__nPosNome]+y[__nPosDoc] })
	EndIf

	oExcel := ARSexcel():New()

	if empty(cDirDest) .or. !ExistDir(cDirDest)
		cDirDest := Alltrim(GetTempPath())
	endif

	nRegua1Con++
	oProcess:IncRegua1("Carregando Dados - Status:  " + IIF((nRegua1Con/nRegua1Tot)*100 <= 99, StrZero((nRegua1Con/nRegua1Tot)*100,2), STRZERO(100,3)) + "%")

	If Len(aTabRel) <= 0

		MsgAlert("Não foram encontrados dados com os parâmetros informados","FRINVEST - ATENÇÃO.")

	Else

		_cLogRet := fImpPlan(@lEnd)

		If ( lEmail )

			cDirDest := "\P10\DOCTEMP\"
			oExcel:lJob := .T.
			oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.)

			cAnexo := Alltrim(cDirDest)+cArqXML+".xml"

			cMailUsu := Alltrim(UsrRetMail(__CUSERID))

			__cCorpo := "LOG DE EVENTOS:"+CRLF+CRLF+_cLogRet

			If ( nQPromo == 2 ) .And. !Empty(cLogCalculo)
				__cCorpo += CRLF + CRLF +cLogCalculo
			EndIf


			U_BIAEnvMail(,cMailUsu,"[FRINVEST] Relatório de Investimentos/Marketing",__cCorpo,,cAnexo)

		Else

			oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.)

		EndIf

		//Geração das SIs - tabela SZO
		IF lGeraSI

			If U_VALOPER("SIG") //!(Upper(AllTrim(getenvserver())) == "PRODUCAO") .OR. alltrim(upper(cUserName)) $ 'WANISAY_RANISSES'

				fGerarSI()

			EndIf

		ENDIF

	EndIf

Return

// processa query SD1
Static Function fGeraSD1()
	local cQuery 	:= ""
	local cAliasCont
	local nTotRegT  := 0
	local nRegAtu   := 0
	local cAliasTmp := ""
	local aAux
	local cINDEX_KEY := ""
	local nSeqCab	 := 0

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - SD1")

	cQuery := "select * from FNC_GET_INVEST_CT2('"+DTOS(dDtMovDe)+"','"+DTOS(dDtMovAte)+"','"+cCliDe+"','"+cCliAte+"','"+cGrupoDe+"','"+cGrupoAte+"','"+cContaDe+"','"+cContaAte+"','"+AllTrim(cClVlStr)+"','SD1') "
	cQuery += " union all select * from FNC_GET_INVEST_CT2('"+DTOS(dDtMovDe)+"','"+DTOS(dDtMovAte)+"','"+cCliDe+"','"+cCliAte+"','"+cGrupoDe+"','"+cGrupoAte+"','"+cContaDe+"','"+cContaAte+"','"+AllTrim(cClVlStr)+"','SF1') "

	If Select(cTabTemp) > 0
		(cTabTemp)->(dbCloseArea())
	Endif
	TcQuery cQuery Alias (cTabTemp) New
	(cTabTemp)->(DbGoTop())

	While (cTabTemp)->(!EOF())
		nTotRegT++
		(cTabTemp)->(DbSkip())
	EndDo

	oProcess:SetRegua2(nTotRegT)

	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!EOF())

		cAliasTmp	:= ""
		cINDEX_KEY	:= ""

		nRegAtu++
		oProcess:IncRegua2("Processando Registros SD1 - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

		cINDEX_KEY := (cTabTemp)->INDEX_KEY

		If !Empty(cINDEX_KEY)

			cAliasTmp := GetNextAlias()

			cQuery := " select DOC = D1_DOC+D1_ITEM, "+CRLF
			cQuery += " ITEMCTA = SUBSTRING(D1_ITEMCTA,1,5), "+CRLF
			cQuery += " VALORDOC = (case when F4_YCCONT not in ('999','050') then D1_CUSTO - D1_ICMSCOM else 0 end - case when F4_PISCRED = '4' then D1_VALIMP6+D1_VALIMP5 else 0 end), "+CRLF  //LP 650-001
			cQuery += " CLVL = D1_CLVL, "+CRLF
			cQuery += " CONTA = D1_CONTA, "+CRLF
			cQuery += " PRODUTO = B1_DESC, "+CRLF
			cQuery += " NOME = ISNULL( A2_COD+'/'+A2_LOJA+'-'+RTRIM(A2_NOME), SI3.A1_COD+'/'+SI3.A1_LOJA+'-'+RTRIM(SI3.A1_NOME)), "+CRLF
			cQuery += " CLIENTE_SI = ISNULL( SI.A1_COD+'/'+SI.A1_LOJA+'-'+RTRIM(SI.A1_NOME), ISNULL( SI2.A1_COD+'/'+SI2.A1_LOJA+'-'+RTRIM(SI2.A1_NOME), SI3.A1_COD+'/'+SI3.A1_LOJA+'-'+RTRIM(SI3.A1_NOME))), "+CRLF
			cQuery += " CODLOJSI = ISNULL( SI.A1_COD+SI.A1_LOJA, ISNULL(SI2.A1_COD+SI2.A1_LOJA, SI3.A1_COD+SI3.A1_LOJA)) "+CRLF
			cQuery += " from SD1"+AllTrim((cTabTemp)->EMP)+"0 SD1 (nolock) "+CRLF
			cQuery += " join SF1"+AllTrim((cTabTemp)->EMP)+"0 SF1 (nolock) on F1_FILIAL = D1_FILIAL and F1_DOC = D1_DOC and F1_SERIE = D1_SERIE and F1_FORNECE = D1_FORNECE and F1_LOJA = D1_LOJA and SF1.D_E_L_E_T_='' "+CRLF
			cQuery += " join SB1010 SB1 (nolock) on B1_COD = D1_COD and SB1.D_E_L_E_T_='' "+CRLF
			cQuery += " join SF4"+AllTrim((cTabTemp)->EMP)+"0 SF4 (nolock) on F4_FILIAL = D1_FILIAL and F4_CODIGO = D1_TES and SF4.D_E_L_E_T_='' "+CRLF
			cQuery += " left join SA2010 SA2 (nolock) on A2_COD = D1_FORNECE and A2_LOJA = D1_LOJA and SA2.D_E_L_E_T_='' "+CRLF
			cQuery += " left join SA1010 SI (nolock) on SI.A1_COD = D1_YSI and SI.A1_LOJA = '01' and SI.D_E_L_E_T_='' "+CRLF
			cQuery += " left join SD2"+AllTrim((cTabTemp)->EMP)+"0 SD2 (nolock) on D2_FILIAL = D1_FILIAL and D2_DOC = D1_NFORI and D2_SERIE = D1_SERIORI and D2_ITEM = D1_ITEMORI and D2_CLIENTE = D1_FORNECE and D2_LOJA = D1_LOJA and SD2.D_E_L_E_T_='' "+CRLF
			cQuery += " left join SC5"+AllTrim((cTabTemp)->EMP)+"0 SC5 (nolock) on C5_FILIAL = D2_FILIAL and C5_NUM = D2_PEDIDO and SC5.D_E_L_E_T_='' "+CRLF
			cQuery += " left join SA1010 SI2 (nolock) on SI2.A1_COD = C5_YSI and SI2.A1_LOJA = '01' and SI2.D_E_L_E_T_='' "+CRLF
			cQuery += " left join SA1010 SI3 (nolock) on SI3.A1_COD = D2_CLIENTE and SI3.A1_LOJA = D2_LOJA and SI3.D_E_L_E_T_='' "+CRLF

			cQuery += " where ("+AllTrim(cINDEX_KEY)+") = left('"+(cTabTemp)->CT2_KEY+"',len("+AllTrim(cINDEX_KEY)+")) "+CRLF
			cQuery += " and SD1.D_E_L_E_T_='' "
			cQuery += " order by D1_DOC, D1_ITEM "

			TcQuery cQuery Alias (cAliasTmp) New
			(cAliasTmp)->(DbGoTop())

		EndIf

		AddLinRes(cAliasTmp, "NOTA FISCAL DE ENTRADA", 0, "3")

		If !Empty(cAliasTmp)
			(cAliasTmp)->(DbCloseArea())
		EndIf

		(cTabTemp)->(DbSkip())
	end

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

return

// processa query SD2
Static Function fGeraSD2()
	local cQuery 	:= ""
	local cAliasCont
	local nTotRegT  := 0
	local nRegAtu   := 0
	local cAliasTmp
	local aAux
	local cFPgto := ""

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - SD2")

	cQuery := "select * from FNC_GET_INVEST_CT2('"+DTOS(dDtMovDe)+"','"+DTOS(dDtMovAte)+"','"+cCliDe+"','"+cCliAte+"','"+cGrupoDe+"','"+cGrupoAte+"','"+cContaDe+"','"+cContaAte+"','"+AllTrim(cClVlStr)+"','SD2') "
	cQuery += " union all select * from FNC_GET_INVEST_CT2('"+DTOS(dDtMovDe)+"','"+DTOS(dDtMovAte)+"','"+cCliDe+"','"+cCliAte+"','"+cGrupoDe+"','"+cGrupoAte+"','"+cContaDe+"','"+cContaAte+"','"+AllTrim(cClVlStr)+"','SF2') "

	If Select(cTabTemp) > 0
		(cTabTemp)->(dbCloseArea())
	Endif
	TcQuery cQuery Alias (cTabTemp) New
	(cTabTemp)->(DbGoTop())

	While (cTabTemp)->(!EOF())
		nTotRegT++
		(cTabTemp)->(DbSkip())
	EndDo

	oProcess:SetRegua2(nTotRegT)

	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!EOF())

		nRegAtu++
		oProcess:IncRegua2("Processando Registros SD2 - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

		cAliasTmp := GetNextAlias()

		cQuery := "select DOC = D2_DOC, "+CRLF
		cQuery += "	ITEMCTA = SUBSTRING(C5_YITEMCT,1,5), "+CRLF
		cQuery += "	CLVL = C5_YCLVL, "+CRLF
		cQuery += "	CONTA = '', "+CRLF
		cQuery += " VALORDOC = D2_TOTAL, "+CRLF
		cQuery += " PRODUTO = B1_DESC, "+CRLF
		cQuery += " NOME = SA1.A1_COD+'/'+SA1.A1_LOJA+'-'+RTRIM(SA1.A1_NOME), "+CRLF
		cQuery += " CLIENTE_SI = isnull(SI.A1_COD+'/'+SI.A1_LOJA+'-'+RTRIM(SI.A1_NOME), SA1.A1_COD+'/'+SA1.A1_LOJA+'-'+RTRIM(SA1.A1_NOME)), "+CRLF
		cQuery += " CODLOJSI = isnull(SI.A1_COD+SI.A1_LOJA , SA1.A1_COD+SA1.A1_LOJA), "+CRLF
		cQuery += " C5_YSUBTP, "+CRLF
		cQuery += " D2_DESCON "+CRLF
		cQuery += " from SD2"+AllTrim((cTabTemp)->EMP)+"0 SD2 (nolock) "+CRLF
		cQuery += " join SF2"+AllTrim((cTabTemp)->EMP)+"0 SF2 (nolock) on F2_FILIAL = D2_FILIAL and F2_DOC = D2_DOC and F2_SERIE = D2_SERIE and F2_CLIENTE = D2_CLIENTE and F2_LOJA = D2_LOJA and SF2.D_E_L_E_T_='' "+CRLF
		cQuery += " join SC5"+AllTrim((cTabTemp)->EMP)+"0 SC5 (nolock) on C5_FILIAL = D2_FILIAL and C5_NUM = D2_PEDIDO and SC5.D_E_L_E_T_='' "+CRLF
		cQuery += " join SB1010 SB1 (nolock) on B1_COD = D2_COD and SB1.D_E_L_E_T_='' "+CRLF
		cQuery += " join SA1010 SA1 (nolock) on A1_COD = D2_CLIENTE and A1_LOJA = D2_LOJA and SA1.D_E_L_E_T_='' "+CRLF
		cQuery += " left join SA1010 SI (nolock) on SI.A1_COD = C5_YSI and SI.A1_LOJA = '01' and SI.D_E_L_E_T_='' "+CRLF
		cQuery += " where ("+AllTrim((cTabTemp)->INDEX_KEY)+") = left('"+(cTabTemp)->CT2_KEY+"',len("+AllTrim((cTabTemp)->INDEX_KEY)+")) "+CRLF
		cQuery += " and SD2.D_E_L_E_T_='' "+CRLF

		TcQuery cQuery Alias (cAliasTmp) New
		(cAliasTmp)->(DbGoTop())

		If (cAliasTmp)->D2_DESCON == 0
			IF ALLTRIM((cAliasTmp)->C5_YSUBTP) == 'O'
				cFPgto  := '3'
			ELSE
				cFPgto  := '1'
			ENDIF
		Else
			cFPgto := '6'
		EndIf

		AddLinRes(cAliasTmp, "NOTA FISCAL DE SAIDA",, cFPgto)

		(cAliasTmp)->(DbCloseArea())

		(cTabTemp)->(DbSkip())
	end

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

return

// processa query SD3
Static Function fGeraSD3()
	local cQuery 	:= ""
	local cAliasCont
	local nTotRegT  := 0
	local nRegAtu   := 0
	local cAliasTmp
	local aAux

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - SD3")

	cQuery := "select * from FNC_GET_INVEST_CT2('"+DTOS(dDtMovDe)+"','"+DTOS(dDtMovAte)+"','"+cCliDe+"','"+cCliAte+"','"+cGrupoDe+"','"+cGrupoAte+"','"+cContaDe+"','"+cContaAte+"','"+AllTrim(cClVlStr)+"','SD3') "

	If Select(cTabTemp) > 0
		(cTabTemp)->(dbCloseArea())
	Endif
	TcQuery cQuery Alias (cTabTemp) New
	(cTabTemp)->(DbGoTop())

	While (cTabTemp)->(!EOF())
		nTotRegT++
		(cTabTemp)->(DbSkip())
	EndDo

	oProcess:SetRegua2(nTotRegT)

	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!EOF())

		nRegAtu++
		oProcess:IncRegua2("Processando Registros SD3 - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")


		cAliasTmp := GetNextAlias()

		cQuery := "select D3_FILIAL, DOC = D3_DOC, SUBSTRING(D3_ITEMCTA,1,5) AS ITEMCTA, CLVL = D3_CLVL, CONTA = D3_CONTA, VALORDOC = D3_CUSTO1, "
		cQuery += " PRODUTO = B1_DESC, NOME = '', CLIENTE_SI = A1_COD+'/'+A1_LOJA+'-'+RTRIM(A1_NOME), CODLOJSI = A1_COD+A1_LOJA "
		cQuery += " from SD3"+AllTrim((cTabTemp)->EMP)+"0 SD3 (nolock) "
		cQuery += " join SB1010 SB1 (nolock) on B1_COD = D3_COD and SB1.D_E_L_E_T_='' "
		cQuery += " left join SA1010 SA1 (nolock) on A1_COD = D3_YSI and A1_LOJA = '01' and SA1.D_E_L_E_T_='' "
		cQuery += " where ("+AllTrim((cTabTemp)->INDEX_KEY)+") = left('"+(cTabTemp)->CT2_KEY+"',len("+AllTrim((cTabTemp)->INDEX_KEY)+")) "
		cQuery += " and SD3.D_E_L_E_T_=''

		TcQuery cQuery Alias (cAliasTmp) New
		(cAliasTmp)->(DbGoTop())

		AddLinRes(cAliasTmp, "MOVIMENTAÇÕES INTERNAS",, "3")

		(cAliasTmp)->(DbCloseArea())

		(cTabTemp)->(DbSkip())
	end

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

return

// processa query SE5
Static Function fGeraSE5()

	local cQuery 	:= ""
	local cAliasCont
	local nTotRegT  := 0
	local nRegAtu   := 0
	local cAliasTmp
	local aAux

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - SE5")

	cQuery := "select * from FNC_GET_INVEST_CT2('"+DTOS(dDtMovDe)+"','"+DTOS(dDtMovAte)+"','"+cCliDe+"','"+cCliAte+"','"+cGrupoDe+"','"+cGrupoAte+"','"+cContaDe+"','"+cContaAte+"','"+AllTrim(cClVlStr)+"','SE5') "

	If Select(cTabTemp) > 0
		(cTabTemp)->(dbCloseArea())
	Endif
	TcQuery cQuery Alias (cTabTemp) New
	(cTabTemp)->(DbGoTop())

	While (cTabTemp)->(!EOF())
		nTotRegT++
		(cTabTemp)->(DbSkip())
	EndDo

	oProcess:SetRegua2(nTotRegT)

	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!EOF())

		If Empty(SubStr((cTabTemp)->CT2_KEY,3,2))

			nRegAtu++
			oProcess:IncRegua2("Processando Registros SE5 - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

			AddLinRes("", "MOVIMENTAÇÕES BANCÁRIAS",, "3")

			(cTabTemp)->(DbSkip())

		Else

			nRegAtu++
			oProcess:IncRegua2("Processando Registros SE5 - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")


			cAliasTmp := GetNextAlias()

			cQuery := "select E5_FILIAL, DOC = E5_NUMERO, SUBSTRING(E5_ITEMD,1,5) AS ITEMCTA, CLVL = E5_CLVLDB, CONTA = E5_DEBITO, VALORDOC = E5_VALOR, "
			cQuery += " PRODUTO = RTRIM(E5_PREFIXO)+'-'+RTRIM(E5_NUMERO)+'-'+RTRIM(E5_PARCELA)+'-'+RTRIM(E5_TIPO)+'-'+SUBSTRING(E5_BENEF,1,35)+'-'+SUBSTRING(E5_HISTOR,1,40), "
			cQuery += " NOME = '', "
			cQuery += " CLIENTE_SI = isnull(SA1.A1_COD+'/'+SA1.A1_LOJA+'-'+RTRIM(SA1.A1_NOME),SA1T.A1_COD+'/'+SA1T.A1_LOJA+'-'+RTRIM(SA1T.A1_NOME)), "
			cQuery += " CODLOJSI = isnull(SA1.A1_COD+SA1.A1_LOJA, SA1T.A1_COD+SA1T.A1_LOJA) "
			cQuery += " from SE5"+AllTrim((cTabTemp)->EMP)+"0 SE5 (nolock) "
			cQuery += " left join SA1010 SA1 (nolock) on A1_COD = E5_YSI and A1_LOJA = '01' and SA1.D_E_L_E_T_='' "
			cQuery += " left join SA1010 SA1T (nolock) on SA1T.A1_COD = E5_CLIFOR and SA1T.A1_LOJA = E5_LOJA and SA1T.D_E_L_E_T_='' "
			cQuery += " where (E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_DATA) = left('"+(cTabTemp)->CT2_KEY+"',len(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_DATA)) "
			cQuery += " and SE5.D_E_L_E_T_=''

			TcQuery cQuery Alias (cAliasTmp) New
			(cAliasTmp)->(DbGoTop())

			AddLinRes(cAliasTmp, "MOVIMENTAÇÕES BANCÁRIAS",, "3")

			(cAliasTmp)->(DbCloseArea())

			(cTabTemp)->(DbSkip())

		EndIf
	end

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

return


// processa query CT2
Static Function fGeraCT2()

	local cQuery 	:= ""
	local cAliasCont
	local nTotRegT  := 0
	local nRegAtu   := 0
	local cAliasTmp
	local aAux

	oProcess:SetRegua2(nTotRegT)

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - CT2")

	cQuery := "select * from FNC_GET_INVEST_CT2_MANUAL('"+DTOS(dDtMovDe)+"','"+DTOS(dDtMovAte)+"','"+cCliDe+"','"+cCliAte+"','"+cGrupoDe+"','"+cGrupoAte+"','"+cContaDe+"','"+cContaAte+"','"+AllTrim(cClVlStr)+"') "

	If Select(cTabTemp) > 0
		(cTabTemp)->(dbCloseArea())
	Endif
	TcQuery cQuery Alias (cTabTemp) New
	(cTabTemp)->(DbGoTop())

	While (cTabTemp)->(!EOF())
		nTotRegT++
		(cTabTemp)->(DbSkip())
	EndDo

	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!EOF())

		nRegAtu++
		oProcess:IncRegua2("Processando Registros CT2 - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

		AddLinRes("", "LCTO CONTÁBIL MANUAL",, "3")

		(cTabTemp)->(DbSkip())
	end

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

return


/*/{Protheus.doc} fGeraPromo
@description Geracao de custos de Promotoras
@author Fernando Rocha
@since 09/11/2017
@version undefined
@type function
/*/
Static Function fGeraPromo()

	local cQuery 	:= ""
	local cAliasCont
	local nTotRegT  := 0
	local nRegAtu   := 0
	local cAliasTmp
	local aAux
	local cAno := SubStr(DTOS(dDtMovDe),1,4)
	local cMes := SubStr(DTOS(dDtMovDe),5,2)
	local cDirDest
	Local xCusto, xCustoFol
	Local xCustoRat, xCustoTot
	local cLogCalculo
	Local _cDVend := ""
	Local _cVend := ""
	Local _cTabSZS
	Local xVisaVale := 0
	Local _cCoord01 := GetNewPar("FA_PVECO01","001137#")
	Local _cCoord05 := GetNewPar("FA_PVECO01","")
	Local _cLogRetC := ""
	Local _cLogCompl := ""

	oProcess:SetRegua2(nTotRegT)

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta - Promotoras")

	IF ( cAno+cMes > "202005" )

		//QUERY SENIOR

		cQuery := ""
		cQuery += " select distinct "+CRLF
		cQuery += " CODEMP = SRA.CODEMP, "+CRLF
		cQuery += " P_MAT = RA_MAT, "+CRLF
		cQuery += " P_NOME = RA_NOME "+CRLF
		cQuery += " from VW_SENIOR_SRA SRA "+CRLF
		cQuery += " join Z31010 Z31 on Z31_CODEMP = SRA.CODEMP and Z31_CODFUN = RA_MAT and Z31.D_E_L_E_T_ = '' "+CRLF
		cQuery += " where RA_MAT between '"+cMatDe+"' and '"+cMatAte+"' "+CRLF

	ELSE

		//QUERY ORIGINAL ANTES DO SENIOR
		cQuery := ""
		cQuery += " select distinct "+CRLF
		cQuery += " CODEMP = '01', "+CRLF
		cQuery += " P_MAT = RD_MAT, "+CRLF
		cQuery += " P_NOME = RA_NOME "+CRLF
		cQuery += " from SRD010 SRD "+CRLF
		cQuery += " join SRA010 SRA on RA_FILIAL = RD_FILIAL and RA_MAT = RD_MAT "+CRLF
		cQuery += " where "+CRLF
		cQuery += " RD_FILIAL = '01' "+CRLF
		cQuery += " and RD_DATARQ = '"+cAno+cMes+"' "+CRLF
		cQuery += " and RA_MAT in (select distinct Z31_CODFUN from Z31010 where Z31_CODEMP = '01' and D_E_L_E_T_='') "+CRLF
		cQuery += " and RA_MAT between '"+cMatDe+"' and '"+cMatAte+"' "+CRLF
		cQuery += " and SRD.D_E_L_E_T_='' "+CRLF
		cQuery += " and SRA.D_E_L_E_T_='' "+CRLF

		//Adicionando as matriculas de coordenador para calculo do custo
		If !Empty(_cCoord01)
			cQuery += " union "+CRLF
			cQuery += " select CODEMP = '01', P_MAT = RA_MAT, P_NOME = RA_NOME from SRA010 "+CRLF
			cQuery += " where D_E_L_E_T_='' and RA_MAT in ("+ U_MontaSQLIN(_cCoord01, '#', 6)+") "+CRLF
		EndIf

		cQuery += " UNION ALL"
		cQuery += " select distinct "+CRLF
		cQuery += " CODEMP = '05', "+CRLF
		cQuery += " P_MAT = RD_MAT, "+CRLF
		cQuery += " P_NOME = RA_NOME "+CRLF
		cQuery += " from SRD050 SRD "+CRLF
		cQuery += " join SRA050 SRA on RA_FILIAL = RD_FILIAL and RA_MAT = RD_MAT "+CRLF
		cQuery += " where "+CRLF
		cQuery += " RD_FILIAL = '01' "+CRLF
		cQuery += " and RD_DATARQ = '"+cAno+cMes+"' "+CRLF
		cQuery += " and RA_MAT in (select distinct Z31_CODFUN from Z31010 where Z31_CODEMP = '05' and D_E_L_E_T_='') "+CRLF
		cQuery += " and RA_MAT between '"+cMatDe+"' and '"+cMatAte+"' "+CRLF
		cQuery += " and SRD.D_E_L_E_T_='' "+CRLF
		cQuery += " and SRA.D_E_L_E_T_='' "+CRLF

		//Adicionando as matriculas de coordenador para calculo do custo
		If !Empty(_cCoord05)
			cQuery += " union "+CRLF
			cQuery += " select CODEMP = '05', P_MAT = RA_MAT, P_NOME = RA_NOME from SRA050 "+CRLF
			cQuery += " where D_E_L_E_T_='' and RA_MAT in ("+ U_MontaSQLIN(_cCoord05, '#', 6)+") "+CRLF
		EndIf

		cQuery += " UNION ALL"
		cQuery += " select distinct "+CRLF
		cQuery += " CODEMP = '07', "+CRLF
		cQuery += " P_MAT = RD_MAT, "+CRLF
		cQuery += " P_NOME = RA_NOME "+CRLF
		cQuery += " from SRD070 SRD "+CRLF
		cQuery += " join SRA070 SRA on RA_FILIAL = RD_FILIAL and RA_MAT = RD_MAT "+CRLF
		cQuery += " where "+CRLF
		cQuery += " RD_FILIAL = '01' "+CRLF
		cQuery += " and RD_DATARQ = '"+cAno+cMes+"' "+CRLF
		cQuery += " and RA_MAT in (select distinct Z31_CODFUN from Z31010 where Z31_CODEMP = '07' and D_E_L_E_T_='') "+CRLF
		cQuery += " and RA_MAT between '"+cMatDe+"' and '"+cMatAte+"' "+CRLF
		cQuery += " and SRD.D_E_L_E_T_='' "+CRLF
		cQuery += " and SRA.D_E_L_E_T_='' "+CRLF

	ENDIF


	If Select(cTabTemp) > 0
		(cTabTemp)->(dbCloseArea())
	Endif
	TcQuery cQuery Alias (cTabTemp) New
	(cTabTemp)->(DbGoTop())

	While (cTabTemp)->(!EOF())
		nTotRegT++
		(cTabTemp)->(DbSkip())
	EndDo

	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!EOF())

		nRegAtu++
		oProcess:IncRegua2("Processando Registros Promotoras - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

		IF ( cAno+cMes <= "202005" )

			//PROTHEUS
			//Valor do beneficio visa vale no mes
			_cTabSZS := "% SZS"+(cTabTemp)->CODEMP+"0 %"

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				%NoParser%

				select ZS_VALOR from %Exp:_cTabSZS% where ZS_MESANO = %Exp:cAno+cMes% and ZS_BENEF = '1' and ZS_MAT = %Exp:(cTabTemp)->P_MAT% and D_E_L_E_T_=''

			EndSql
			(cAliasTmp)->(DbGoTop())
			If !(cAliasTmp)->(Eof())
				xVisaVale := (cAliasTmp)->ZS_VALOR
			Else
				xVisaVale := 0
			EndIf
			(cAliasTmp)->(DbCloseArea())

		ENDIF

		cDirDest := Alltrim(GetTempPath())

		xCustoFol := 0
		_cLogRetC := ""


		IF ( cAno+cMes <= "202005" )

			//PROTHEUS
			If ( (cTabTemp)->CODEMP <> CEMPANT )
				aRetCFol := U_FROPCPRO((cTabTemp)->CODEMP,"01","U_FINVCCUS", (cTabTemp)->P_MAT, dDtMovDe, dDtMovAte)
			Else
				aRetCFol := U_FINVCCUS((cTabTemp)->P_MAT, dDtMovDe, dDtMovAte)
			EndIF

		ELSE

			//QUERY DE BUSCA DE CUSTO DA FOLHA SENIOR
			aRetCFol := {0, ""}
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
			%NoParser%

			select custo_total from FNC_INVEST_CUSTO_FUNCIONARIO_SENIOR(%Exp:(cTabTemp)->CODEMP%,%Exp:(cTabTemp)->P_MAT%,%Exp:cAno%,%Exp:cMes%)

			EndSql
			(cAliasTmp)->(DbGoTop())
			If !(cAliasTmp)->(Eof())

				aRetCFol := { (cAliasTmp)->custo_total, ""}

			EndIf
			(cAliasTmp)->(DbCloseArea())

		ENDIF


		xCustoFol := aRetCFol[1]
		_cLogRetC := aRetCFol[2]

		//custo total
		IF ( cAno+cMes <= "202005" )
			xCusto := xCustoFol + xVisaVale
		ELSE
			xCusto := xCustoFol
		ENDIF

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			%NoParser%

			select Z31_CODIGO, 
			Z31_SEQ, 
			Z31_CODFUN, 
			Z31_CLVL, 
			Z31_ITEMCB, 
			Z31_CODCLI, 
			Z31_LOJCLI, 
			Z31_NOMCLI, 
			Z31_RATEIO
			,IIF(SUBSTRING(Z31_CLVL,1,2)='21','01','05') AS CTH_YUN
			from Z31010 Z31
			where Z31_DTFIM >= %Exp:DTOS(dDtMovAte)%
			and Z31_DTINIC <= %Exp:DTOS(dDtMovAte)% 
			and Z31_CODEMP = %Exp:(cTabTemp)->CODEMP%
			and Z31_CODFUN = %Exp:(cTabTemp)->P_MAT%
			and Z31.D_E_L_E_T_= ''

		EndSql

		xCustoTot := xCusto
		xCusRatAd := 0

		__NCONTRAT := 0
		(cAliasTmp)->(DbGoTop())
		While !(cAliasTmp)->(Eof())
			__NCONTRAT++
			(cAliasTmp)->(DbSkip())
		EndDo

		__NCONT := 0
		(cAliasTmp)->(DbGoTop())
		While !(cAliasTmp)->(Eof())

			__NCONT++

			If (__NCONT < __NCONTRAT)
				xCustoRat := Round(( xCusto * (cAliasTmp)->Z31_RATEIO )/100,2)
				xCusRatAd += xCustoRat
			Else
				xCustoRat := ( xCusto - xCusRatAd )
				xCusRatAd += xCustoRat
			EndIf

			_cDVend := GetVend(@_cVend, (cAliasTmp)->Z31_CODCLI+(cAliasTmp)->Z31_LOJCLI, (cAliasTmp)->Z31_CLVL)

			SA1->(DbSetOrder(1))
			SA1->(DbSeek(XFilial("SA1")+(cAliasTmp)->Z31_CODCLI))

			If cQEmp == "01" .And. ( SubStr((cAliasTmp)->CTH_YUN,1,2) <> "01" )
				(cAliasTmp)->(DbSkip())
				loop
			ElseIf cQEmp == "05" .And. ( SubStr((cAliasTmp)->CTH_YUN,1,2) <> "05" )
				(cAliasTmp)->(DbSkip())
				loop
			EndIf

			aAux := {}
			AADD(aAux, cTitulo ) 								//Titulo
			AADD(aAux, SubStr((cAliasTmp)->CTH_YUN,1,2) )	//Empresa da classe de valor para gerar o SZO
			AADD(aAux, DTOS(dDtMovDe) )							//Data do Lcto
			AADD(aAux, (cTabTemp)->P_MAT)						//Chave de busca da origem
			AADD(aAux, "" )						//Conta LC
			AADD(aAux, (cAliasTmp)->Z31_CLVL )	//Classe LC
			AADD(aAux, (cAliasTmp)->Z31_ITEMCB )//Item LC
			AADD(aAux, (cAliasTmp)->Z31_CODCLI+"-"+AllTrim(SA1->A1_NREDUZ))	//Cliente AI do LC
			AADD(aAux, xCustoRat )				//Valor LC
			AADD(aAux, "F.PAGTO: "+SUBSTRING((cAliasTmp)->Z31_ITEMCB,1,5)+'-'+(cAliasTmp)->Z31_CODIGO+'-'+(cAliasTmp)->Z31_SEQ+'-'+AllTrim((cTabTemp)->P_NOME) )//Historico
			AADD(aAux, "" )						//Documento origem
			AADD(aAux, "Custo Folha: "+AllTrim(Transform(xCustoFol,"@E 999,999.99")))	//Produto
			AADD(aAux, (cAliasTmp)->Z31_CODCLI+"/"+(cAliasTmp)->Z31_LOJCLI+"-"+AllTrim((cAliasTmp)->Z31_NOMCLI) ) //Cliente/Fornecedor
			AADD(aAux, (cAliasTmp)->Z31_CODCLI+"/"+(cAliasTmp)->Z31_LOJCLI+"-"+AllTrim((cAliasTmp)->Z31_NOMCLI) ) //Cliente SI
			AADD(aAux, _cDVend ) 	//Vendedor
			AADD(aAux, xCustoTot )				  	//Valor Documento
			AADD(aAux, "" )							//Conta origem
			AADD(aAux, "" )							//Classe origem
			AADD(aAux, "" )							//Item origem

			AADD(aAux, (cAliasTmp)->Z31_CODCLI+(cAliasTmp)->Z31_LOJCLI ) //Codigo+Loja do cliente para SI
			AADD(aAux, (cAliasTmp)->CTH_YUN ) 	//Empresa SI
			AADD(aAux, _cVend )						//Vendedor SI
			AADD(aAux, "3" )						//F Pgto SI

			AADD(aTabRel,aAux)

			xCustoTot := 0 //para só sair o custo total na primeira linha de cada promotora

			(cAliasTmp)->(DbSkip())
		EndDo
		(cAliasTmp)->(dbCloseArea())


		//Gravando Arquivo de LOG de calculo da folha
		If !Empty(_cLogRetC)

			MemoWrite( cDirDest + AllTrim((cTabTemp)->CODEMP)+AllTrim((cTabTemp)->P_MAT)+".TXT", _cLogRetC )
			_cLogCompl += CRLF + CRLF + "CUSTO FUNCIONARIO MATRICULA: "+(cTabTemp)->P_MAT+CRLF+ _cLogRetC

		EndIf

		(cTabTemp)->(DbSkip())
	end

	nRegAtu++
	oProcess:IncRegua2("Processando Consulta SQL - Status: " + IIF((nRegAtu/nTotRegT)*100 <= 99, StrZero((nRegAtu/nTotRegT)*100,2), STRZERO(100,3)) + "%")

Return(_cLogCompl)


//Adicionar linhas no vetor para gerar o relatorio
Static Function AddLinRes(cAliasTmp, cTitulo, nSeqCab, cFPgto)

	local aAux
	local _cVend := ""
	local _cDVend := ""
	local _cEmpSI := ""

	default nSeqCab := 0

	_cDVend := GetVend(@_cVend, AllTrim((cTabTemp)->CLISI), (cTabTemp)->CLVL)

	CTH->(DbSetOrder(1))
	If CTH->(DbSeek(XFilial("CTH")+(cTabTemp)->CLVL)) .And. !Empty(CTH->CTH_YUN)
		If Substr(Alltrim(CTH->CTH_CLVL),1,2) == "21"
			_cEmpSI := "01"
		Else
			_cEmpSI := "05"
		EndIf
	EndIf

	//If (cTabTemp)->EMP == "07" .And. Empty(_cEmpSI)
	//	MsgAlert("CLASSE DE VALOR: "+(cTabTemp)->CLVL+" NAO CONFIGURADA PARA LM.","ATENÇÃO!!! (FRINVEST)")
	//EndIF

	If cQEmp == "01"
		If .Not. ( (cTabTemp)->EMP == "01" .Or. ( (cTabTemp)->EMP == "07" .And. _cEmpSI == "01" )  )
			return
		EndIf
	ElseIf cQEmp == "05"
		If .Not. ( (cTabTemp)->EMP == "05" .Or. ( (cTabTemp)->EMP == "07" .And. _cEmpSI == "05" )  )
			return
		EndIf
	EndIf

	//Preenchedo vetor com dados para impressão em Excel
	aAux := {}
	AADD(aAux, cTitulo ) 								//Titulo
	AADD(aAux, (cTabTemp)->EMP )						//Empresa
	AADD(aAux, (cTabTemp)->CT2_DATA )					//Data do Lcto
	AADD(aAux, (cTabTemp)->CT2_KEY )					//Chave de busca da origem
	AADD(aAux, (cTabTemp)->CONTA )						//Conta LC
	AADD(aAux, (cTabTemp)->CLVL )						//Classe LC
	AADD(aAux, (cTabTemp)->ITEMCTA )					//Item LC

	//Cliente SI - ATIVI - do LC
	If !Empty((cTabTemp)->CLISI)
		AADD(aAux, AllTrim((cTabTemp)->CLISI)+"-"+AllTrim(Posicione("SA1",1,XFilial("SA1")+AllTrim((cTabTemp)->CLISI),"A1_NREDUZ")))
	Else
		AADD(aAux, "" )
	EndIf

	If (nSeqCab == 0 .Or. nSeqCab == 1)
		AADD(aAux, (cTabTemp)->CT2_VALOR )					//Valor LC
		AADD(aAux, (cTabTemp)->CT2_HIST )					//Historico
	Else
		AADD(aAux, 0 )					//Valor LC
		AADD(aAux, "" )					//Historico
	EndIf

	//Se localizou a chave na tabela origem
	IF  !Empty(cAliasTmp) .And. !(cAliasTmp)->(EOF())

		AADD(aAux, (cAliasTmp)->DOC )				//Documento origem
		AADD(aAux, (cAliasTmp)->PRODUTO )			//Produto
		AADD(aAux, (cAliasTmp)->NOME )				//Cliente/Fornecedor
		AADD(aAux, (cAliasTmp)->CLIENTE_SI )		//Cliente SI
		AADD(aAux, _cDVend )						//Vendedor
		AADD(aAux, IIf((cTabTemp)->CT2_VALOR >= 0, (cAliasTmp)->VALORDOC, -(cAliasTmp)->VALORDOC) )			//Valor Documento
		AADD(aAux, (cAliasTmp)->CONTA )				//Conta origem
		AADD(aAux, (cAliasTmp)->CLVL )				//Classe origem
		AADD(aAux, (cAliasTmp)->ITEMCTA )			//Item origem

		//Campos adicionais de controle
		//AADD(aAux, (cAliasTmp)->CODLOJSI )  //codi+loja cliente si
		AADD(aAux, AllTrim((cTabTemp)->CLISI) + IIF(!Empty((cTabTemp)->CLISI),Posicione("SA1",1,Xfilial("SA1")+AllTrim((cTabTemp)->CLISI),"A1_LOJA"),"")  )  //codi+loja cliente si
		AADD(aAux, _cEmpSI ) //empresa si
		AADD(aAux, _cVend )  //vendedor si
		AADD(aAux, cFPgto )  //fpgto si

	ELSE

		AADD(aAux, "" )				//Documento origem
		AADD(aAux, "" )				//Produto
		AADD(aAux, "" )				//Cliente/Fornecedor
		AADD(aAux, "" )				//Cliente SI
		AADD(aAux, _cDVend )		//Vendedor
		AADD(aAux, 0 )				//Valor Documento
		AADD(aAux, "" )				//Conta origem
		AADD(aAux, "" )				//Classe origem
		AADD(aAux, "" )				//Item origem

		//Campos adicionais de controle  (lancamento manual)
		AADD(aAux, AllTrim((cTabTemp)->CLISI) + IIF(!Empty((cTabTemp)->CLISI),Posicione("SA1",1,Xfilial("SA1")+AllTrim((cTabTemp)->CLISI),"A1_LOJA"),"")  )  //codi+loja cliente si
		AADD(aAux, _cEmpSI ) //empresa si
		AADD(aAux, _cVend )  //vendedor si
		AADD(aAux, cFPgto )  //fpgto s

	ENDIF

	AADD(aTabRel,aAux)

Return

//Buscar codigo e nome do vendedor
Static Function GetVend(_cVend, _cCodLoj, _cCLVL)

	Local _cDVend := ""
	Local _cEmpSI := ""
	Local cClVlBella := AllTrim(GetNewPar("MV_YCLVLBC","2210#2251#"))  //Classes de Valor BellaCasa - Ticket 7537

	If !Empty(_cCodLoj)
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(XFilial("SA1")+_cCodLoj))

			CTH->(DbSetOrder(1))
			If CTH->(DbSeek(XFilial("CTH")+_cCLVL)) .And. !Empty(CTH->CTH_YUN)
				If Substr(Alltrim(CTH->CTH_CLVL),1,2) == "21"
					_cEmpSI := "01"
				Else
					_cEmpSI := "05"
				EndIf
			EndIf

			If Empty(_cEmpSI) .Or. (_cEmpSI == "01")
				_cVend := SA1->A1_VEND
			ElseIf (_cEmpSI == "05")
				_cVend := SA1->A1_YVENDI
			ElseIf ( AllTrim(_cCLVL) $ cClVlBella)
				_cVend := SA1->A1_YVENBE1
			Else
				_cVend := SA1->A1_VEND
			EndIf
		EndIf

		SA3->(DbSetOrder(1))
		If !Empty(_cVend) .And. SA3->(DbSeek(XFilial("SA3")+_cVend))
			_cDVend := _cVend+"-"+SA3->A3_NOME
		EndIf
	EndIf

Return(_cDVend)

//Gera Planilha Geral
Static Function fImpPlan(lEnd)

	local cEmpresa   := StrTran(AllTrim(CapitalAce(SM0->M0_NOMECOM)),"S.a.","S.A.")
	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#9E1238'
	local cCorFun11	 := '#D83863
	local cChave	 := ''
	local cSubTit	 := ''
	local nSubTot
	local nTotItem

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#F79646'

	local cFonte3	 := 'Arial'
	local nTamFont3	 := 8
	local cCorFont3  := '#000000'
	local cCorFun3	 := '#F5F5F5'
	local cCorAlert  := '#FF0000'
	local _cCorDef

	local cFonte4	 := 'Arial'
	local nTamFont4	 := 10
	local cCorFont4  := '#000000'
	local cCorFun4	 := '#AAAAAA'

	local nContReg 	:= 0
	local nTotReg	:= Len(aTabRel)
	local np		:= 0

	local nPosGrupo	:= 7
	local nPosSubGr	:= 1
	local cTitGru
	local cTitSubGru

	local _lValid
	local cLogRet

	static nPosVlLP		:= 9
	static nPosDet		:= 11
	static nMaxCols		:= 17


	If nQGrupo == 1
		nPosGrupo	:= 5  //conta contabil
		cTitGru		:= "Conta"
	ElseIf nQGrupo == 2
		nPosGrupo	:= 7  //item contabil
		cTitGru		:= "Item Contábil"
	Else
		nPosGrupo	:= 2  //empresa
		cTitGru		:= "Empresa"
	EndIf

	If nQSubGrupo == 1
		nPosSubGr	:= 1  //tipo documento
		cTitSubGru	:= "Tipo"
	ElseIf nQSubGrupo == 2
		nPosSubGr	:= 7  //item contabil
		cTitSubGru	:= "Item Contábil"
	ElseIf nQSubGrupo == 3
		nPosSubGr	:= 5  //conta contabil
		cTitSubGru	:= "Conta"
	Else
		nPosSubGr	:= 0  //nao agrupa subgrupo
	EndIf

	oProcess:SetRegua2(nTotReg)

	oExcel:AddPlanilha('Planilha_Geral',{20,40,40,120,50,50,50,50,200,100,200,200,200,200,50,50,50})
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,nMaxCols)
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,nMaxCols)
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,nMaxCols)

	oExcel:AddLinha(30)
	oExcel:AddLinha(12)
	oExcel:AddCelula()
	oExcel:AddCelula("Empresa"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt.Lcto"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Chave"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Conta" 				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Classe Valor"  		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Item Cta."		   	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cli.AI.LC."		   	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Valor"		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Histórico"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)

	oExcel:AddCelula("Documento"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Produto"		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cliente/Fornecedor"	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cliente SI"			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Vendedor"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Valor Documento"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Conta Origem" 		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cl.Vl.Origem"  		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("It.Cta.Origem"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)

	nSubTot := 0
	nTotItem := 0

	cSubTit := aTabRel[1,nPosGrupo]  //Grupo
	oExcel:AddLinha(14)
	oExcel:AddLinha(14)
	oExcel:AddCelula(cTitGru+": "+cSubTit		,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,nMaxCols)

	If (nPosSubGr > 0)
		cChave := aTabRel[1,nPosSubGr]  //Sub Grupo
		oExcel:AddLinha(14)
		oExcel:AddLinha(14)
		oExcel:AddCelula(cTitSubGru+": "+cChave		,0,'L',cFonte4,nTamFont4,cCorFont4,.T.,.T.,cCorFun4,,,,,.T.,2,nMaxCols)
	EndIf

	cLogRet := ""

	for np:=1 to Len(aTabRel)

		_lValid := ValidLin(aTabRel, np, @cLogRet)

		If lEnd
			MsgStop("Relatorio Cancelado","Fim")
			return
		Endif

		If (nPosSubGr > 0 .And. cChave <> aTabRel[np,nPosSubGr]) .Or. cSubTit <> aTabRel[np,nPosGrupo]

			If (nPosSubGr > 0)
				oExcel:AddLinha(14)
				oExcel:AddCelula("Total "+cTitSubGru+": "+cChave		,0,'L',cFonte4,nTamFont4,cCorFont4,.T.,.T.,cCorFun4,,,,,.T.,2,6)
				oExcel:AddCelula( nSubTot  ,2,'R',cFonte4,nTamFont4,cCorFont4,,,cCorFun4,.T.,.T.,.T.,.T.)
			EndIf

			If cSubTit <> aTabRel[np,nPosGrupo]

				oExcel:AddLinha(14)
				oExcel:AddLinha(14)
				oExcel:AddCelula("Total "+cTitGru+": "+cSubTit		,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFun11,,,,,.T.,2,6)
				oExcel:AddCelula(nTotItem  ,2,'R',cFonte1,nTamFont1,cCorFont1,,,cCorFun11,.T.,.T.,.T.,.T.)

				nTotItem := 0
				cSubTit := aTabRel[np,nPosGrupo]
				oExcel:AddLinha(14)
				oExcel:AddLinha(14)
				oExcel:AddCelula(cTitGru+": "+cSubTit		,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,nMaxCols)
			EndIf

			If (nPosSubGr > 0)
				nSubTot := 0
				cChave := aTabRel[np,nPosSubGr]
				oExcel:AddLinha(14)
				oExcel:AddLinha(14)
				oExcel:AddCelula(cTitSubGru+": "+cChave		,0,'L',cFonte4,nTamFont4,cCorFont4,.T.,.T.,cCorFun4,,,,,.T.,2,nMaxCols)
			EndIf
		EndIf

		_cCorDef := IIF(_lValid,cCorFun3,cCorAlert)

		oExcel:AddLinha(14)
		oExcel:AddCelula()
		oExcel:AddCelula( aTabRel[np,2] 			,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( DTOC(STOD(aTabRel[np,3]))	,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( aTabRel[np,4] 			,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( aTabRel[np,5] 			,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( aTabRel[np,6] 			,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( aTabRel[np,7]				,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( aTabRel[np,8]				,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( aTabRel[np,9]				,2,'R',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( aTabRel[np,10]			,2,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)

		nSubTot += aTabRel[np,nPosVlLP]
		nTotItem += aTabRel[np,nPosVlLP]

		If Len(aTabRel[np]) >= nPosDet
			oExcel:AddCelula( aTabRel[np,nPosDet] 		,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( aTabRel[np,nPosDet+1]		,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( aTabRel[np,nPosDet+2]		,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( aTabRel[np,nPosDet+3]		,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( aTabRel[np,nPosDet+4]		,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( aTabRel[np,nPosDet+5]		,2,'R',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( aTabRel[np,nPosDet+6]		,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( aTabRel[np,nPosDet+7]		,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( aTabRel[np,nPosDet+8]		,0,'L',cFonte3,nTamFont3,cCorFont3,,,_cCorDef,.T.,.T.,.T.,.T.)
		EndIf

		nContReg++
		oProcess:IncRegua2("Listando Planilha Geral - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")

	next np

	If (nPosSubGr > 0)
		oExcel:AddLinha(14)
		oExcel:AddCelula("Total "+cTitSubGru+": "+cChave		,0,'L',cFonte4,nTamFont4,cCorFont4,.T.,.T.,cCorFun4,,,,,.T.,2,6)
		oExcel:AddCelula(nSubTot  ,2,'R',cFonte4,nTamFont4,cCorFont4,,,cCorFun4,.T.,.T.,.T.,.T.)
	EndIf

	oExcel:AddLinha(14)
	oExcel:AddCelula("Total "+cTitGru+": "+cSubTit		,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFun11,,,,,.T.,2,6)
	oExcel:AddCelula(nTotItem  ,2,'R',cFonte1,nTamFont1,cCorFont1,,,cCorFun11,.T.,.T.,.T.,.T.)

return(cLogRet)

/*/{Protheus.doc} fGerarSI
@description Funcao para gerar as SI conforme a tabela de despesas/custos gerada no excel
@author Fernando Rocha
@since 16/11/2017
@version undefined
@type function
/*/
Static Function fGerarSI()

	Local cLogTxt := ""
	Local nSI01 := 0
	Local nSI05 := 0
	Local np
	Local cLogRet

	for np:=1 to Len(aTabRel)
		//Validar integridade da linha
		ValidLin(aTabRel, np, @cLogRet)
	next np

	If !Empty(cLogRet)
		U_FROPMSG("Não é possivel Gerar as AI enquanto houver erros.","Erros de validação de Linhas:"+CRLF+cLogRet)
		Return
	EndIf

	If !MsgNoYes("Tem certeza que deseja gerar as SI's ?"+CRLF+"Será gerado 1 SI para cada linha da planilha conforme a empresa do movimento.","INCLUSÃO DE SI's")
		Return
	EndIf

	LjMsgRun("Aguarde... Gerando SI's da BIANCOGRES",,{|| fGSI01(@cLogTxt,@nSI01) })

	LjMsgRun("Aguarde... Gerando SI's da INCESA",,{|| fGSI05(@cLogTxt,@nSI05) })

	U_FROPMSG("Geração de AI",;
		"Foram geradas "+AllTrim(Str(nSI01))+" na empresa BIANCOGRES."+CRLF+;
		"Foram geradas "+AllTrim(Str(nSI05))+" na empresa INCESA."+CRLF+;
		IIF(!Empty(cLogTxt),CRLF+"Erros na geração de AI's:"+CRLF+cLogTxt,""))

Return

Static Function fGSI01(cLogTxt,nSI01)

	Local aRet

	aRet := U_FROPCPRO("01","01","U_fGSIInvPrc", aTabRel, cUserName)

	If ValType(aRet) == "A"
		nSI01 := aRet[1]
		cLogTxt += aRet[2]
	EndIf

Return

Static Function fGSI05(cLogTxt,nSI05)

	Local aRet

	aRet := U_FROPCPRO("05","01","U_fGSIInvPrc", aTabRel, cUserName)

	If ValType(aRet) == "A"
		nSI05 := aRet[1]
		cLogTxt += aRet[2]
	EndIf

Return

Static Function ValidLin(aTabRel, np, cLogRet)

	Local _cTxt
	Local _CCLVLALL   := GetNewPar("FA_CVLMALL","01#05#14")  //Parametro para Empresas permitidas para classe de valor LM de investimentos

	Default cLogRet := ""

	If Alltrim(aTabRel[np][2]) == "07" .And. !(AllTrim(aTabRel[np][21]) $ _CCLVLALL)

		_cTxt := "LINHA: "+AllTrim(Str(np))+" => SI LM COM CLASSE DE VALOR NÃO CONFIGURADA / EMPRESA INVÁLIDA (campo CTH_YUN) => VALOR: "+AllTrim(Str(aTabRel[np][9]))+" - CT2 HIST: "+aTabRel[np][10]
		cLogRet += _cTxt + CRLF
		ConOut("FRINVEST: Skip "+_cTxt)

	EndIf


	If ( Empty(aTabRel[np][20]) .Or. Empty(aTabRel[np][7]) .Or. Empty(aTabRel[np][2]) .Or. Empty(aTabRel[np][22]) )

		If Empty(aTabRel[np][20])

			_cTxt := "LINHA: "+AllTrim(Str(np))+" => SI SEM CLIENTE => VALOR: "+AllTrim(Str(aTabRel[np][9]))+" - CT2 HIST: "+aTabRel[np][10]
			cLogRet += _cTxt + CRLF
			ConOut("FRINVEST: Skip "+_cTxt)

		endif

		If Empty(aTabRel[np][22])

			_cTxt := "LINHA: "+AllTrim(Str(np))+" => SI SEM REPRESENTANTE => VALOR: "+AllTrim(Str(aTabRel[np][9]))+" - CT2 HIST: "+aTabRel[np][10]
			cLogRet += _cTxt + CRLF
			ConOut("FRINVEST: Skip "+_cTxt)

		endif

		If Empty(aTabRel[np][7])

			_cTxt := "LINHA: "+AllTrim(Str(np))+" => SI SEM ITEM CONTABIL => VALOR: "+AllTrim(Str(aTabRel[np][9]))+" - CT2 HIST: "+aTabRel[np][10]
			cLogRet += _cTxt + CRLF
			ConOut("FRINVEST: Skip "+_cTxt)

		endif

		Return(.F.)
	EndIf

Return(.T.)

User Function fGSIInvPrc(aTabRel, _cUser)

	Local np
	Local cSerie := ""
	Local _NTOT := 0
	Local cLogRet := ""
	Local nCont := 0
	Local cClVlBella := AllTrim(GetNewPar("MV_YCLVLBC","2210#2251#"))  //Classes de Valor BellaCasa - Ticket 7537


	//aTabRel[np][1]	Titulo
	//aTabRel[np][2]	Empresa
	//aTabRel[np][3]	Data do Lcto
	//aTabRel[np][4]	Chave de busca da origem
	//aTabRel[np][5]	Conta LC
	//aTabRel[np][6]	Classe LC
	//aTabRel[np][7]	Item LC
	//aTabRel[np][8]	Cliente AI LC
	//aTabRel[np][9]	Valor LC
	//aTabRel[np][10]	Historico
	//aTabRel[np][11]	Documento origem
	//aTabRel[np][12]	Produto
	//aTabRel[np][13]	Cliente/Fornecedor
	//aTabRel[np][14]	Cliente SI
	//aTabRel[np][15]	Vendedor
	//aTabRel[np][16]	Valor Documento
	//aTabRel[np][17]	Conta origem
	//aTabRel[np][18]	Classe origem
	//aTabRel[np][19]	Item origem
	//aTabRel[np][20]	Codigo+Loja cliente SI
	//aTabRel[np][21]	Empresa SI
	//aTabRel[np][22]	Cod.Vendedor SI
	//aTabRel[np][23]	Fpgto


	for np:=1 to Len(aTabRel)

		//Validar integridade da linha
		If !ValidLin(aTabRel, np)
			loop
		EndIf

		//Skipar linhas de outras empresas
		If Alltrim(aTabRel[np][2]) <> AllTrim(CEMPANT)
			If !(Alltrim(aTabRel[np][2]) == "07" .And. AllTrim(aTabRel[np][21]) == AllTrim(CEMPANT))
				loop
			EndIf
		EndIf

		If aTabRel[np][21] == "01"
			cSerie := "S1"
		ElseIf aTabRel[np][21] == "05"
			cSerie := "S2"
		Else
			cSerie := ""
		EndIf

		RecLock("SZO",.T.)

		SZO->ZO_FILIAL  := xFilial("SZO")
		SZO->ZO_DATA    := STOD(aTabRel[np][3])
		SZO->ZO_CLIENTE := SubStr(aTabRel[np][20],1,6)
		SZO->ZO_LOJA    := SubStr(aTabRel[np][20],7,2)
		SZO->ZO_VALOR   := aTabRel[np][9]
		SZO->ZO_DESCR   := aTabRel[np][10]
		SZO->ZO_STATUS  := 'Baixa Total'
		SZO->ZO_SI      := '999999'
		SZO->ZO_CLVL	:= aTabRel[np][6]
		SZO->ZO_CONTA	:= aTabRel[np][5]
		SZO->ZO_ITEMCTA := aTabRel[np][7]
		SZO->ZO_FPAGTO  := aTabRel[np][23]
		SZO->ZO_SERIE 	:= cSerie
		SZO->ZO_REPRE 	:= aTabRel[np][22]

		If ( aTabRel[np][21] == "05" .And. AllTrim(aTabRel[np][6]) $ cClVlBella )
			SZO->ZO_EMP   	:= "0599"
		Else
			SZO->ZO_EMP   	:= aTabRel[np][21]+"01"
		EndIf

		SZO->ZO_USUDIR	:= _cUser
		SZO->ZO_DATADIR := dDataBase
		SZO->ZO_HORADIR := SubStr(Time(),1,5)

		SZO->(MsUnLock())


		_NTOT += aTabRel[np][9]
		nCont++

	next np

	ConOut("FRINVEST: Total SZO Empresa: "+AllTrim(CEMPANT)+": "+AllTrim(Str(_NTOT)))

Return({nCont,cLogRet})


//CHAMADA CalCust RPC
User Function FINVCCUS(cMatricula, dDtMovDe, dDtMovAte)
	Local aRet

	aRet := U_CalCustoFun("01",cMatricula,.T.,.T.,dDtMovDe,dDtMovAte,,,,,,,,,,,.T.,,,)

Return(aRet)

//USER FUNTION
User Function CalCustoFun(cFil,cMatricula,lProvisao,lEncargos,dDtIni,dDtFim,cCusto,aPIS,aINSS,aAcidente,aLabore,aAutonomo,aProvisao,aVerbas,aFGTS,aContSoc,lGeraLog,aLog,aAddVerb)

	Local aArea		:= GetArea()
	Local cCodFol 	:= ""
	Local nValCusto	:= 0	// Valor do Custo
	Local nBInss013	:= 0 	// Base Salario Contr. ate limite base
	Local nBInss014	:= 0 	// Base Salario Contr. acima limite base
	Local nBInss019	:= 0 	// Base Inss ate Limite para 13§ Salario
	Local nBInss020	:= 0 	// Base Inss acima Limite para 13§ Salario
	Local nBInss221	:= 0 	// Base Inss Pro-Labore
	Local nBInss225	:= 0	// Base Inss Autonomo
	Local nBaseINSS := 0   	// Base do INSS
	Local nBasePIs	:= 0	// Base PIS
	Local nBaseAci	:= 0	// Base Acidente de Trabalho
	Local nBFGTS017	:= 0	// Base FGTS
	Local nBFGTS018	:= 0	// FGTS Deposito
	Local nBFGTS108	:= 0	// Base FGTS 13§ Salario
	Local nBFGTS109 := 0	// Valor FGTS 13§ Salario

	//--Contribuicao Social
	Local aContS295 := array(2)	// Contrib. 0.5% s/Rescisao
	Local aContS296 := array(2)	// Contrib. 0.5% s/13o. Rescisao
	Local aContS297 := array(2)	// Contrib. 10% s/Montante Dep. Fgts Rescisao
	Local aContS298 := array(2)	// Contrib. 0.5% s/Rem. Folha.
	Local aContS299 := array(2)	// Contrib. 0.5% s/Rem. 13o. Folha

	//-- Valores
	Local nValPIS   := 0	// Valor do PIS
	Local nValACI	:= 0	// Valor de Acidente de Trabalho
	Local nValPRO	:= 0	// Valor Pro-Labore
	Local nValAut	:= 0	// Valor Autonomo
	Local nBasFGTS	:= 0	// Base do FGTS
	//-- Valores da Provisao
	Local nPrFerV	:= 0	// Provisao Ferias Vencidas
	Local nPrFerP	:= 0 	// Provisao Ferias Proporcionais
	Local nPr13Sal	:= 0	// Provisao 13o Salario
	Local nPr14Sal	:= 0	// Provisao 14o Salario
	Local aBases[09]
	Local aValINSS[23][2]
	Local cMesAnt
	Local dDataRef
	Local nDia
	Local nPos		:= 0
	Local nTpc
	Local nx		:= 1
	Local nY		:= 1

	//--Variaveis para Query SRD
	Local cQuery    := "" 		//Expressao da Query
	Local lQuery    := .F. 	// Indica se a query foi executada
	Local cAliasSRD := "SRD" 	//Alias da Query
	Local aStruSRD  := {}      //Estrutura da Query
	Local cVbEnc    := ""

	//Biancogres - calculo de encargos sobre provisoes
	Local _aInssEmp := Array(23,2)
	Local _aEncProv := {}

	DEFAULT aLog			:= {}
	DEFAULT aAddVerb	:= {}
	DEFAULT lGeraLog	:= .F.

	lGeraLog	:=	lGeraLog
	cCusto	:= if( cCusto == Nil,"",cCusto)
	aPIS	:= if( aPIS == NIL,{},aPis)
	aINSS	:= if( aINSS== NIL,{},aINSS)
	aAcidente:=if(aAcidente==NIl,{},aAcidente)
	aLabore	:= if(aLabore == NIL,{},aLabore)
	aAutonomo:=if(aAutonomo==NIL,{},aAutonomo)
	aProvisao:=if(aProvisao==Nil,{},aProvisao)
	aVerbas	:= if(aVerbas == NIL,{},aVerbas)
	aFGTS	:= if(aFGTS == NIL,{},aFGTS)
	aContSoc:= IF(aContSoc== Nil,{},aContSoc)
	aCodFol := {}

	/*If FP_CODFOL(@aCodFol,SRA->RA_FILIAL)

	If Len(aCodFol) > 0
	// Encargos Empresa
	cVbEnc:= aCodFol[148,1] + "/" + aCodFol[149,1] + "/" + aCodFol[150,1] + "/" +;
	aCodFol[184,1] + "/" + aCodFol[185,1] + "/" + aCodFol[186,1] + "/" +;
	aCodFol[187,1] + "/" + aCodFol[188,1] + "/" + aCodFol[189,1] + "/" +;
	aCodFol[190,1] + "/" + aCodFol[191,1] + "/" + aCodFol[192,1] + "/" +;
	aCodFol[193,1] + "/" + aCodFol[200,1] + "/" + aCodFol[201,1] + "/" +;
	aCodFol[204,1] + "/" + aCodFol[782,1]	

	Else

	MsgAlert("Encargos não encontrados matricula: "+cMatricula)

	EndIf

EndIf*/

if SRV->(FIELDPOS("RV_CUSTEMP")) == 0
		Return{0,""}
Endif

	//Posiciona no funcionario
	SRA->(dbSeek(cFil+cMatricula))
	nTpc	:= val(If(Empty(SRA->RA_TPCONTR),"1",SRA->RA_TPCONTR))

#IFDEF TOP
	lQuery := .T.
	cAliasSRD := "QSRD"
	aStruSRD  := If(Empty(aStruSRD),SRD->(dbStruct()),aStruSRD)
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SRD")+" SRD "
	cQuery += "WHERE SRD.RD_FILIAL='"+cFil+"' AND "
	cQuery += "SRD.RD_MAT='"+cMatricula+"' AND "
	cQuery += "SRD.RD_DATARQ>='"+MesAno(dDtIni)+"' AND "			
	cQuery += "SRD.RD_DATARQ<='"+MesAno(dDtFim)+"' AND "			
	if !Empty(cCusto)
		cQuery += "SRD.RD_CC='"+cCusto+"' AND "
	EndIf
	cQuery += "SRD.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SRD->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRD,.T.,.T.)

	For nX := 1 To Len(aStruSRD)
		If ( aStruSRD[nX][2] <> "C" )
			TcSetField(cAliasSRD,aStruSRD[nX][1],aStruSRD[nX][2],aStruSRD[nX][3],aStruSRD[nX][4])
		EndIf
	Next nX
#ELSE
	dbSelectArea("SRD")
	dbSeek(cFIL + cMATricula+MesAno(dDtIni))	
#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda o Mes               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMesAnt	:= (cAliasSRD)->RD_DATARQ
	aContS295[2] := 0
	aContS296[2] := 0
	aContS297[2] := 0
	aContS298[2] := 0
	aContS299[2] := 0

While (cAliasSRD)->(!EOF()) .AND. (cAliasSRD)->RD_MAT==cMatricula .and.;
	(cAliasSRD)->RD_DATARQ >= MesAno(dDtIni) .AND.(cAliasSRD)->RD_DATARQ <= MesAno(dDtFim)

		If !empty(cCusto) .and. (cAliasSRD)->RD_CC <> cCusto
			(cAliasSRD)->(dbskip())
			Loop	
	EndIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as verbas                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If PosSrv((cAliasSRD)->RD_PD,(cAliasSRD)->RD_FILIAL,"RV_TIPOCOD") $ "13" //Provento;Base
			nBaseINSS 	+= (cAliasSRD)->RD_VALOR
			//Calculo do PIS
			nBasePis += If ( PosSrv((cAliasSRD)->RD_PD,(cAliasSRD)->RD_FILIAL,"RV_PIS")=="S",(cAliasSRD)->RD_VALOR,0)

	Elseif PosSrv((cAliasSRD)->RD_PD,(cAliasSRD)->RD_FILIAL,"RV_TIPOCOD") == "2" //Desconto
			nBaseINSS 	-= (cAliasSRD)->RD_VALOR
			//Calculo do PIS
			nBasePis -= If ( PosSrv((cAliasSRD)->RD_PD,(cAliasSRD)->RD_FILIAL,"RV_PIS")=="S",(cAliasSRD)->RD_VALOR,0)
	Endif

		cCodFol  := PosSrv((cAliasSRD)->RD_PD,(cAliasSRD)->RD_FILIAL,"RV_CODFOL") 

	If cCodFol $ "0013#0014#0019#0020#0221#0225#0017#0018#0108#0109#0295#0296#0297#0298#0299"
			nBInss013+= if(cCodFol=="0013",(cAliasSRD)->RD_VALOR,0)  // Salario Contr. ate limite base
			nBInss014+= if(cCodFol=="0014",(cAliasSRD)->RD_VALOR,0)  // Salario Contr. acima limite base
			nBInss019+= if(cCodFol=="0019",(cAliasSRD)->RD_VALOR,0)  // Base Inss ate Limite para 13§ Salario
			nBInss020+= if(cCodFol=="0020",(cAliasSRD)->RD_VALOR,0)  // Base Inss acima Limite para 13§ Salario
			nBInss221+= if(cCodFol=="0221",(cAliasSRD)->RD_VALOR,0)  // Base Inss Pro-Labore 15%
			nBInss225+= if(cCodFol=="0225",(cAliasSRD)->RD_VALOR,0)  // Base Inss Autonomo 20%
			//FGTS
			nBFGTS017+= if(cCodFol=="0017",(cAliasSRD)->RD_VALOR,0)  // Base FGTS
			nBFGTS018+= if(cCodFol=="0018",(cAliasSRD)->RD_VALOR,0)  // FGTS Deposito
			nBFGTS108+= if(cCodFol=="0108",(cAliasSRD)->RD_VALOR,0)  // Base FGTS 13§ Salario
			nBFGTS109+= if(cCodFol=="0109",(cAliasSRD)->RD_VALOR,0)  // Valor FGTS 13§ Salario
			//--Contribuicao Social
		If cCodFol=="0295"
				aContS295[1] := (cAliasSRD)->RD_PD				
				aContS295[2] += (cAliasSRD)->RD_VALOR
		ElseIf cCodFol=="0296"
				aContS296[1] := (cAliasSRD)->RD_PD				
				aContS296[2] += (cAliasSRD)->RD_VALOR
		ElseIf cCodFol=="0297"
				aContS297[1] := (cAliasSRD)->RD_PD				
				aContS297[2] += (cAliasSRD)->RD_VALOR
		ElseIf cCodFol=="0298"
				aContS298[1] := (cAliasSRD)->RD_PD				
				aContS298[2] += (cAliasSRD)->RD_VALOR
		ElseIf cCodFol=="0299"
				aContS299[1] := (cAliasSRD)->RD_PD				
				aContS299[2] += (cAliasSRD)->RD_VALOR
		EndIf
			//Base para Acidente de Trabalho
			nBaseAci+= if( cCodFol $ "0013#0014#0019#0020",(cAliasSRD)->RD_VALOR,0)
	Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica as verbas que estao definidas com "S"   ³
			//³ para o calculo do custo do funcionario           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If PosSrv((cAliasSRD)->RD_PD,(cAliasSRD)->RD_FILIAL,"RV_CUSTEMP") == "1"
			If PosSrv((cAliasSRD)->RD_PD,(cAliasSRD)->RD_FILIAL,"RV_TIPOCOD") == "2" //Desconto
					aaDD(aVerbas,{(cAliasSRD)->RD_PD,0,(cAliasSRD)->RD_VALOR*(-1)})
			Else
					aaDD(aVerbas,{(cAliasSRD)->RD_PD,0,(cAliasSRD)->RD_VALOR})
			EndIf
		EndIF
	EndIf

		(cAliasSRD)->(dbSkip())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se quebrar o mes, calcula os valores  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if cMesAnt <> (cAliasSRD)->RD_DATARQ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula os valores atraves das bases passadas     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aFill(aBases,0)
			aEval(aValInss,{|x|aFill(x,0)})

			aBases[01]	:= 	nBaseInss 	// Base Inss
			aBases[02]	:= 	nBasePis  	// Base PIS
			aBases[03]	:= 	nBaseAci  	// Base Acidente de Trabalho
			aBases[04]	:=	nBInss013 	// Salario Contr. ate limite base
			aBases[05]	:=	nBInss014 	// Salario Contr. acima limite base
			aBases[06]	:=	nBInss019	// Base Inss ate Limite para 13§ Salario
			aBases[07]	:=	nBInss020	// Base Inss acima Limite para 13§ Salario
			aBases[08]	:= 	nBInss221	// Base Inss Pro-Labore 15%
			aBases[09]	:=	nBInss225  	// Base Inss Autonomo 20%

			FCalcEnc(aBases,cFil,cMatricula,@nValPIS,@nValACI,@nValPRO,@nValAut,@aValINSS,cCusto,cMesAnt) 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena nos arrays os valores calculados no mes     ³
			//³ 1a.Coluna - Mes/ANO                                  ³
			//³ 2a.Coluna Base de calculo                            ³
			//³ 3a.Coluna Valor                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aPIS,{cMesAnt,nBasePis,nValPis}) 	

			///bianco - acidente de trabalho com aliquotas variantes na tabela
		If MesAno(dDtIni) <= '201712'
			If AllTrim(CEMPANT) == "05"
					nValAci := nBaseAci * 0.030303
			Else
					nValAci := nBaseAci * 0.02825
			EndIf
		EndIf

			AADD(aAcidente,{cMesAnt,nBaseAci,nValAci})
			AADD(aLabore,{cMesAnt,nBInss221,nValPRO}) 
			AADD(aAutonomo,{cMesAnt,nBInss225,nValAut}) 
			//--FGTS    

			//bianco - a segunda variavel e a base e valor do 13o que ja eh provisionado
			//nBasFGTS:= nBFGTS017+nBFGTS108
			//nValFGTS:= nBFGTS018+nBFGTS109

			nBasFGTS:= nBFGTS017
			nValFGTS:= nBFGTS018			

			aaDD(aFGTS,{cMesAnt,nBasFGTS, nValFGTS})	// FGTS

			//--Contribuicao Social
			AADD(aContSoc,{cMesAnt,aContS295,aContS296,aContS297,aContS298,acontS299})
			//-- Zera os array de Contribuicao Social
			aContS295		:=	array(2)
			aContS295[2] 	:= 	0
			aContS296		:=	array(2)
			aContS296[2] 	:= 	0
			aContS297    	:=	array(2)
			aContS297[2] 	:= 	0
			aContS298		:=	array(2)
			aContS298[2] 	:= 	0
			acontS299		:=	array(2)
			aContS299[2] 	:= 	0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena no array os valores calculados ³
			//³ no mes ref. a INSS. Colunas:            ³
			//³ 1 - Valor Inss Emp.                     ³
			//³ 2 - Terceiros                           ³
			//³ 9 - Sal.Educ.                           ³
			//³10 - Incra                               ³
			//³11 - Senai                               ³
			//³12 - Sesi                                ³
			//³13 - Senac                               ³
			//³14 - Sesc                                ³
			//³15 - Sebrae                              ³
			//³16 - Dpc                                 ³
			//³17 - Faer                                ³
			//³18 - Senab                               ³
			//³19 - Seconc                              ³
			//³22 - Sest                                ³
			//³23 - Senat                               ³
			//³24 - Mes/aNO                             ³
			//³25 - Base de calculo                     ³
			//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
			//³A chave deste array sera a coluna 24     ³
			//³ MES/ANO                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValBasINSS := nBInss013+nBInss014+nBInss019+nBInss020
			AADD(aINSS,array(25))
			npos := len(aINSS)     

			aINSS[nPos,24] := cMesAnt      		// 24 - Mes/aNO
			aInss[nPos,25] := nValBasINSS 			// 25 - Base de calculo
			aInss[nPos,01] := aValINSS[01,nTpc]	// 01 - Valor Inss Emp.
			aInss[nPos,02] := aValINSS[02,nTpc]	// 02 - Terceiros
			aInss[nPos,09] := aValINSS[09,nTpc]	// 09 - Sal.Educ.
			aInss[nPos,10] := aValINSS[10,nTpc]	// 10 - Incra 
			aInss[nPos,11] := aValINSS[11,nTpc]	// 11 - Senai
			aInss[nPos,12] := aValINSS[12,nTpc]	// 12 - Sesi
			aInss[nPos,13] := aValINSS[13,nTpc]	// 13 - Senac
			aInss[nPos,14] := aValINSS[14,nTpc]	// 14 - Sesc
			aInss[nPos,15] := aValINSS[15,nTpc]	// 15 - Sebrae
			aInss[nPos,16] := aValINSS[16,nTpc]	// 16 - Dpc
			aInss[nPos,17] := aValINSS[17,nTpc]	// 17 - Faer
			aInss[nPos,18] := aValINSS[18,nTpc]	// 18 - Senab
			aInss[nPos,19] := aValINSS[19,nTpc]	// 19 - Seconc
			aInss[nPos,22] := aValINSS[22,nTpc]	// 22 - Sest 
			aInss[nPos,23] := aValINSS[23,nTpc]	// 23 - Senat

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Guarda o Mes               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMesAnt	:= (cAliasSRD)->RD_DATARQ
	EndIf
EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo das Provisoes                                    ³
	//³ Traz os valores de aFerVenc, aFerProp, a13Salar, a14Salar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lProvisao

		dDataRef := dDtIni

	While dDataRef <= dDtFim

			U_FcalcProv(cFil,cMatricula,SRA->RA_CC,dDataRef,@nPrFerV,@nPrFerP,@nPr13Sal,@nPr14Sal)			
			AADD(aProvisao,{MesAno(dDataRef),0,nPrFerV,nPrFerP,nPr13Sal,nPr14Sal}) 

			nDia	:= F_UltDia(dDataRef)
			dDataRef := cTod(strzero(ndia,2)+"/"+Substr(MesAno(dDataRef),5,2)+"/"+Substr(MesAno(dDataRef),1,4))+1

	EndDo

		//Biancogres - buscar as aliquotas de encargos para aplicar sobre as provisoes
	If fInssEmp(cFil,@_aInssEmp,,MesAno(dDtIni))

			__nBasProv := nPrFerV + nPrFerP + nPr13Sal + nPr14Sal

			__nCtrSe := 0.965  //contrato contribuicao sesi senai

		If MesAno(dDtIni) <= '201712'
				_aInssEmp[3,1] := 0.02825 //Biancogres - fixo que na manutencao tabel nao tem historico de todos os meses - meses anteiores calculando errado
		EndIf

			AAdd(_aEncProv, {"INSS Empresa", Round(__nBasProv * _aInssEmp[1,1],2)} )  //0.2
			AAdd(_aEncProv, {"Terceiros", Round(__nBasProv * _aInssEmp[2,1],2)} )  //0.033 (outros sem o SENAI e SESI)
			AAdd(_aEncProv, {"SENAI", Round(__nBasProv * _aInssEmp[11,1] * __nCtrSe,2)} )  //0.01
			AAdd(_aEncProv, {"SESI", Round(__nBasProv * _aInssEmp[12,1] * __nCtrSe,2)} )   //0.015
			AAdd(_aEncProv, {"Acidente Trabalho", Round(__nBasProv * _aInssEmp[3,1],2)} )   //variante

			//Bianco
			AAdd(_aEncProv, {"FGTS", Round(__nBasProv * 0.08,2)} )   //FGTS provisionado mes a mes

			//3 = 0.02477 %acidente trabalho
			//29 = 0.03 %Rat

	Endif

EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o Custo    		 			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//--PIS
	aAdd(aLog,"PIS")

For nX := 1 to len(aPIS)
		nValCusto += aPIS[nX,3]
		aAdd(aLog,STR(aPIS[nX,3],8,2))
Next
	//--Acidente de Trabalho
	aAdd(aLog,"Acidente de trabalho")
For nX := 1 to len(aAcidente)
		nValCusto += aAcidente[nX,3]
		aAdd(aLog,STR(aAcidente[nX,3],8,2))
Next
	//-- Pro Labore
	aAdd(aLog,"Prolabore")
For nX := 1 to len(aLabore)
		nValCusto += aLabore[nX,3]
		aAdd(aLog,STR(aLabore[nX,3],8,2))
Next
	//-- Autonomo
	aAdd(aLog,"Autonomo")
For nX := 1 to len(aAutonomo)
		nValCusto += aAutonomo[nX,3]
		aAdd(aLog,STR(aAutonomo[nX,3],8,2))
Next
	//-- Demais verbas
	aAdd(aLog,"Verbas")
For nX := 1 to len(aVerbas)
		//If !aVerbas[nx,1] $ cVbEnc
		nValCusto += aVerbas[nX,3]
		aAdd(aLog,aVerbas[nx,1]+":"+STR(aVerbas[nX,3],8,2))
		nPosVerb := aScan(aAddVerb,{|x| x[1] == aVerbas[nx,1] })
	If nPosVerb > 0
			aAddVerb[nPosVerb,2] += aVerbas[nX,3]
	Else
			aAdd(aAddVerb,{aVerbas[nX,1],aVerbas[nX,3]})
	EndIf
		//EndIf	
Next
	//-- Contribuicao Social
	aAdd(aLog,"Contribuicao Social")
For nX := 1 to len(aContSoc)
	For nY := 2 to 6
		if aContSoc[nX,nY,2] <> nil
				nValCusto += aContSoc[nX,nY,2]
				aAdd(aLog,STr(aContSoc[nX,nY,2],10,2))
		EndIf
	Next
Next

If lEncargos
		aAdd(aLog,"Encargos")
	For nX := 1 to len(aINSS)
			nValCusto+= aInss[nX,01]	// Inss Empresa
			nValCusto+= aInss[nX,02]	// Terceiros
			nValCusto+= aInss[nX,09] 	// Sal. Educ.
			nValCusto+= aInss[nX,10] 	// INCRA

			//nValCusto+= aInss[nX,11] 	// SENAI
			//nValCusto+= aInss[nX,12] 	// SESI

			//Customizado bianco - SENAI e SESI 
			__cAliasTmp := GetNextAlias()
		BeginSql Alias __cAliasTmp
				%NoParser%

				select RD_PD, RD_VALOR from %Table:SRD% SRD 
				where RD_FILIAL = %XFILIAL:SRD% 
				and RD_MAT = %Exp:cMatricula% 
				and RD_DATARQ >= %Exp:MesAno(dDtIni)%
				and RD_DATARQ <= %Exp:MesAno(dDtFim)%			 
				and RD_PD in ('730','764') 
				and SRD.D_E_L_E_T_=''

		EndSql

		(__cAliasTmp)->(DbGoTop())
		While !(__cAliasTmp)->(Eof())

			If (__cAliasTmp)->RD_PD == "730"

				aInss[nX,11] := (__cAliasTmp)->RD_VALOR
				nValCusto+= aInss[nX,11]

			ElseIf (__cAliasTmp)->RD_PD == "764"

				aInss[nX,12] := (__cAliasTmp)->RD_VALOR
				nValCusto+= aInss[nX,12]

			EndIf

			(__cAliasTmp)->(DbSkip())
		EndDo
		(__cAliasTmp)->(DbCloseArea())


		nValCusto+= aInss[nX,13] 	// SENAC
		nValCusto+= aInss[nX,14] 	// SESC
		nValCusto+= aInss[nX,15] 	// SEBRAE
		nValCusto+= aInss[nX,16] 	// DPC
		nValCusto+= aInss[nX,17] 	// FAER
		nValCusto+= aInss[nX,18] 	// SENAB
		nValCusto+= aInss[nX,19] 	// SECOND
		nValCusto+= aInss[nX,22] 	// SEST
		nValCusto+= aInss[nX,23] 	// SENAT
		aAdd(aLog,"INSS Empresa : "+STr(aInss[nx,1],10,2))
		aAdd(aLog,"Terceiros : "+STr(aInss[nx,2],10,2))
		aAdd(aLog,"Sal. Educ. : "+STr(aInss[nx,9],10,2))
		aAdd(aLog,"INCRA : "+STr(aInss[nx,10],10,2))
		aAdd(aLog,"SENAI : "+STr(aInss[nx,11],10,2))
		aAdd(aLog,"SESI : "+STr(aInss[nx,12],10,2))
		aAdd(aLog,"SENAC : "+STr(aInss[nx,13],10,2))
		aAdd(aLog,"SESC : "+STr(aInss[nx,14],10,2))
		aAdd(aLog,"SEBRAE : "+STr(aInss[nx,15],10,2))
		aAdd(aLog,"DPC : "+STr(aInss[nx,16],10,2))
		aAdd(aLog,"FAER : "+STr(aInss[nx,17],10,2))
		aAdd(aLog,"SENAB : "+STr(aInss[nx,18],10,2))
		aAdd(aLog,"SECONB : "+STr(aInss[nx,19],10,2))
		aAdd(aLog,"SEST : "+STr(aInss[nx,22],10,2))
		aAdd(aLog,"SENAT : "+STr(aInss[nx,13],10,2))
	Next
	For nX := 1 to len(aFGTS)
		aAdd(aLog,"FGTS Empresa : "+STr(aFGTS[nX,3],10,2))
		nValCusto+= aFGTS[nX,3]	// FGTS
	Next
EndIf

If lProvisao
	aAdd(aLog,"Provisao")
	For nX := 1 to Len(aProvisao)
		nValCusto+= aProvisao[nX,3]
		nValCusto+= aProvisao[nX,4]
		nValCusto+= aProvisao[nX,5]
		nValCusto+= aProvisao[nX,6]
		aAdd(aLog,aProvisao[nx,1]+Str(aProvisao[nx,3],10,2)+Str(aProvisao[nx,4],10,2)+Str(aProvisao[nx,5],10,2)+Str(aProvisao[nx,6],10,2))
	Next

	//Biancogres
	aAdd(aLog,"Encargos sobre Provisao")
	For nX := 1 to Len(_aEncProv)

		nValCusto+= _aEncProv[nX,2]
		aAdd(aLog,_aEncProv[nx,1]+": "+Str(_aEncProv[nX,2],10,2))

	Next

EndIf

cWrite := ""
aAdd(aLog,"CUSTO FUNCIONARIO :"+Str(nValcusto,10,2))
If lGeraLog
	For nx := 1 to Len(aLog)
		cWrite += aLog[nx] + CHR(13)+CHR(10)
	Next
Endif

#IFDEF TOP
	dbSelectArea(cAliasSRD)
	dbCloseArea()
#ENDIF

RestArea(aArea)
Return( {nValCusto, cWrite} )


/*/{Protheus.doc} FcalcProv
@description Funcao copiada do fonte da Totvs para adequar - calculo das provisoes de Ferias e Decimo terceiro
@author Fernando Rocha
@since 18/01/2018
@version 1.0
@type function
/*/
User Function  FcalcProv(cFil,cMatricula,cCusto,dDataRef,nPrFerV,nPrFerP,nPr13Sal,nPr14Sal)
	Local noldOrder	:= SRT->(INDEXORD())
	Local cChave
	Local cVbBaixa	:= ""
	Local nPos

	Private dDataAtu
	Private dDataAnt

	Private aTransf		:= {}

	Private nPrFerVAnt	:=0
	Private nPrFerPAnt	:=0
	Private nPr13SalAnt	:=0
	Private nPr13SalPos	:=0
	Private nPr14SalAnt	:=0
	Private nPr14SalPos	:=0
	Private nPrFerVPos	:=0
	Private nPrFerPPos	:=0


	//Variaves utilizadas no ponto de entrada
	Private nProvFeV	:=0
	Private nProv13S  	:=0
	Private nProvFeP   	:=0
	Private	nProv14S   	:=0
	Private lVlrNeg    := If(SuperGetMv("MV_PROVNEG",,"N") == "S", .T., .F.) 	// Gerar Valor Negativo
	dDataAtu := dDataRef
	dDataAnt := FirstDay(FirstDay(dDataRef)-1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Matriz com os Funcionarios Transferidos No Mes     |
	//| Conteudo da Matriz :                                     |
	//| 01-Empresa De                                            |
	//| 02-Filial+Matricula De                                   |
	//| 03-Centro de Custo De                                    |
	//| 04-Empresa Para                                          |
	//| 05-Filial+Matricula Para                                 |
	//| 06-Centro ce Custo Para						             |
	//| 07-Data da Transferencia                                 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aAuxArea	:= SRA->(GetArea())
	//fTransf( @aTransf, mesano(dDataAtu),.T.,.T.,.T. )
	//nPos	:= Ascan( aTransf,{|x| MesAno(x[7]) == MesAno(dDataAtu)})
	//SRA->(dbSetOrder(1))
	//SRA->(dbSeek(aTransf[nPos,2]))
	//aTrans := {}
	fTransf( @aTransf, mesano(dDataAtu),.F.,.F.,.F. )
	//RestArea(aAuxARea)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as transferencias do mes anterior        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cEmpSRTAnt := AllTrim(CEMPANT)

	if len(aTransf) >0
		nPos	:= Ascan( aTransf,{|x| MesAno(x[7]) == MesAno(dDataAtu)})
		if nPos > 0

			cChave	:= aTransf[nPos,2]+aTransf[nPos,3]+MesAno(dDataAnt)

			If ( aTransf[nPos,1] <> AllTrim(CEMPANT) )
				_cEmpSRTAnt := aTransf[nPos,1]
			EndIf

		EndIF
	Else
		cChave	:= cFil+cMatricula+cCusto+MesAno(dDataAnt)
	EndIf

	_cAliasSRT := GetNextAlias()
	_cTabSRT := "% SRT"+_cEmpSRTAnt+"0 %"
	BeginSql Alias _cAliasSRT
		%NoParser%

		SELECT RT_DATACAL, RT_VERBA, RT_TIPPROV, RT_VALOR, RT_CLVL
		FROM %Exp:_cTabSRT%
		WHERE RT_FILIAL+RT_MAT+RT_CC+Substring(RT_DATACAL,1,6) = %Exp:cChave%

	EndSql


	//Calcula valor do mes anterior a data de refencia
	While (_cAliasSRT)->(!EOF())

		__cMes = SubStr((_cAliasSRT)->RT_DATACAL,5,2)

		If Empty((_cAliasSRT)->RT_CLVL)
			(_cAliasSRT)->(dbskip())
			loop
		EndIf

		//verbas de base da provisao e adicionais
		If __cMes == "12"
			__cVerbas := "800#801#802#805#806#807#862#863"
		Else
			__cVerbas := "800#801#802#805#806#807#830#831"
		EndIf

		//Biancogres - Verbas de Provisao de Ferias e 13o
		If Alltrim((_cAliasSRT)->RT_VERBA) $ __cVerbas

			if (_cAliasSRT)->RT_TIPPROV == "1"
				nPrFerVAnt+=(_cAliasSRT)->RT_VALOR
			ElseIf (_cAliasSRT)->RT_TIPPROV == "2"
				nPrFerPAnt+=(_cAliasSRT)->RT_VALOR
			ElseIf (_cAliasSRT)->RT_TIPPROV == "3"
				nPr13SalAnt+=(_cAliasSRT)->RT_VALOR
			ElseIf (_cAliasSRT)->RT_TIPPROV == "4"
				nPr14SalAnt+=(_cAliasSRT)->RT_VALOR
			EndIf

		EndIf

		(_cAliasSRT)->(dbskip())
	EndDo
	(_cAliasSRT)->(DbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as transferencias do mes atual           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if len(aTransf) >0
		nPos	:= Ascan( aTransf,{|x| MesAno(x[7]) == MesAno(dDataAtu)})
		If nPos > 0
			cChave	:= aTransf[nPos,5]+aTransf[nPos,6]+MesAno(aTransf[nPos,7])
		Else
			cChave	:= cFil+cMatricula+cCusto+MesAno(dDataAtu)
		EndIF
	Else
		cChave	:= cFil+cMatricula+cCusto+MesAno(dDataAtu)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula valor do mes referente a data de refencia |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SRT->( dbSeek(cChave))
	While SRT->(!EOF()) .and. SRT->RT_FILIAL+SRT->RT_MAT+SRT->RT_CC+mesAno( SRT->RT_DATACAL) == cChave

		__cMes = SubStr(DTOS(SRT->RT_DATACAL),5,2)

		If Empty(SRT->RT_CLVL)
			SRT->(dbskip())
			loop
		EndIf

		//verbas de base da provisao e adicionais
		If __cMes == "12"
			__cVerbas := "800#801#802#805#806#807#862#863"
		Else
			__cVerbas := "800#801#802#805#806#807#830#831"
		EndIf

		//Biancogres - Verbas de Provisao de Ferias e 13o
		If Alltrim(SRT->RT_VERBA) $ __cVerbas

			if SRT->RT_TIPPROV == "1"
				nPrFerVPos+=SRT->RT_VALOR
			ElseIf SRT->RT_TIPPROV == "2"
				nPrFerPPos+=SRT->RT_VALOR
			ElseIf SRT->RT_TIPPROV == "3"
				nPr13SalPos+=SRT->RT_VALOR
			ElseIf SRT->RT_TIPPROV == "4"
				nPr14SalPos+=SRT->RT_VALOR
			EndIf

		EndIf
		SRT->(dbskip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula valor da provisao |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lVlrNeg
		nPrFerV	:= Max((nPrFerVPos + nPrFerPPos) - (nPrFerVAnt + nPrFerPAnt) ,0)
		nPrFerP	:= 0
		nPr13Sal:= If(month(dDataAtu) == 01,nPr13SalPos,Max(nPr13SalPos - nPr13SalAnt,0)) //no mes 01, utilizar apenas o saldo atual
		nPr14Sal:= Max(nPr14SalPos - nPr14SalAnt,0)
	Else
		nPrFerV	:= (nPrFerVPos + nPrFerPPos) - (nPrFerVAnt + nPrFerPAnt)
		nPrFerP	:= 0
		nPr13Sal:= If(month(dDataAtu) == 01,nPr13SalPos,nPr13SalPos - nPr13SalAnt) //no mes 01, utilizar apenas o saldo atual
		nPr14Sal:= nPr14SalPos - nPr14SalAnt
	EndIf

	If ExistBlock("GPEPMSPRV")
		EXECBLOCK("GPEPMSPRV",.F.,.F.)
		nPrFerV	 := nProvFeV
		nPr13Sal := nProv13S
		nPrFerP	 := nProvFeP
		nPr14Sal := nProv14S
	Endif
	SRT->(dbSetOrder(nOldOrder))

Return
