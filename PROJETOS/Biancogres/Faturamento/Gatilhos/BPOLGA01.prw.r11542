#include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} BPOLGA01
@description Gatilho para busca e validacao das informações da política comercial
@author Fernando Rocha
@since 04/08/2015
@version undefined
@type function
/*/


User Function BPOLGA01()

	Local aArea 	:= GetArea()
	Local aAreaA1 	:= SA1->(GetArea())
	Local cEmpNPOL 	:= AllTrim(GetNewPar("FA_EMPNPOL","14#"))
	Local cTpDVER	:= AllTrim(GetNewPar("FA_TPEDVDA","N #E #IM#R1#R2#"))
	Local nMaxDAI 	:= GetNewPar("BF_MAXDAI", 30)  //maximo de desconto de outras AI

	Private _cCliente		:= M->C5_CLIENTE+M->C5_LOJACLI
	Private _cVendedor		:= M->C5_VEND1
	Private _cProduto 		:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]
	Private _cLocal			:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})]
	Private _cLote			:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOTECTL"})]
	Private _nQtdDig 		:= Round(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})],2)

	//campos de desconto para alterar
	Private _nPDPAL		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDPAL"})
	Private _nPDCAT		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDCAT"})
	Private _nPDREG		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDREG"})
	Private _nPDGER		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDMIX"})
	Private _nPDPOL		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YPERC"})
	Private _nPDNV		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDNV"})
	Private _nPDTOT		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDESC"})
	Private _nPDESP		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDESP"})
	Private _nPDVER		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDVER"})
	Private _nPDACO		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDACO"})
	Private _nPDAI		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDAI"})
	Private _nPYDESCLI	:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_YDESCLI"})
	Private _nPNECESS	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDTNECE"})
	
	Private _nPDFRA		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDFRA"})
	
	
	Private _cSegmento := ""
	Private _nPMaxAO	:= 0
	Private _nPBonAO	:= 0
	Private _lTpDVer	:= (M->C5_YSUBTP $ cTpDVER)
	Private _lPaletizado := .F.

	// Projeto JK
	If AllTrim(cEmpAnt) == "06" .And. AllTrim(M->C5_CLIENTE) == '000481'
		RestArea(aAreaA1)
		RestArea(aArea)
		return(_nQtdDig)
	EndIf

	//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC###MATA440")
		RestArea(aAreaA1)
		RestArea(aArea)
		return(_nQtdDig)
	EndIf

	//Empresas que nao usa Politica
	If Alltrim(cEmpAnt) $ cEmpNPOL
		RestArea(aAreaA1)
		RestArea(aArea)
		return(_nQtdDig)
	EndIf

	//Checkar Vitcer se e produto Rodape - se nao passa tudo
	/*If (AllTrim(CEMPANT) == "14") .And. !U_CHKRODA(_cProduto)
	RestArea(aAreaA1)
	RestArea(aArea)
	return(_nQtdDig)
	EndIf*/

	//Ticket 10793 não disparar politica de preço para outros tipos de pedido
	//Tratamento outros tipos de pedido
	If (M->C5_TIPO <> "N")
		RestArea(aAreaA1)
		RestArea(aArea)
		Return(_nQtdDig)
	EndIf

	If (AllTrim(M->C5_YSUBTP) $ "VO") .And. !(ALLTRIM(__READVAR) == 'M->C6_YDESP')
		RestArea(aAreaA1)
		RestArea(aArea)
		Return(_nQtdDig)
	EndIf

	//transferencia vinilico
	If (AllTrim(cEmpAnt) == "07" .And. AllTrim(M->C5_CLIENTE) == '029954' .AND. AllTrim(M->C5_YLINHA) == '6')
		Return(_nQtdDig)
	EndIf
	
	//Verificando Segmento do Cliente
	_cSegmento := U_fSegCliente(M->C5_YLINHA, M->C5_CLIENTE, M->C5_LOJACLI) 

	If (_cSegmento == "E" .And. ALLTRIM(__READVAR) == 'M->C6_QTDVEN' .And. Empty(aCols[N][_nPNECESS]))
		//Mensagem ja foi exibida no FROPGA02
		RestArea(aAreaA1)
		RestArea(aArea)
		return(_nQtdDig)
	EndIf
	
	//Validacao de campos
	If Empty(_cCliente) .Or. Empty(_cVendedor) .Or. Empty(_cProduto)
		MsgAlert("É obrigatório informar:  CLIENTE, VENDEDOR e PRODUTO - antes de digitar a quantidade vendida.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
		RestArea(aAreaA1)
		RestArea(aArea)
		return(0)
	EndIf

	//Validacoes do Desconto de AI/AO
	If ( ALLTRIM(__READVAR) == 'M->C6_YDACO' ) .Or. ( ALLTRIM(__READVAR) == 'M->C6_YDVER' ) .Or. ( ALLTRIM(__READVAR) == 'M->C6_YDAI' )
		If !(_lTpDVer)
			MsgAlert("TIPO de pedido inválido para uso deste deconto.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
			aCols[N][_nPDACO] := 0
			aCols[N][_nPDVER] := 0
			aCols[N][_nPDAI] := 0
		EndIf
	EndIf
	
	//Validacoes do Desconto de AI/AO
	If ( ALLTRIM(__READVAR) == 'M->C6_YDACO' )

		If Empty(M->C5_YNUMSI)

			MsgAlert("Para desconto de AO - É obrigatório informar o Número da AI no cabeçalho no campo 'No.AI ref.AO'.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
			aCols[N][_nPDACO] := 0

		ElseIf !CheckAO(M->C5_YNUMSI, aCols[N][_nPDACO])

			MsgAlert("Percentual de Desconto de AO é maior que o bônus da AI informada."+CRLF+;
			"AI: "+M->C5_YNUMSI+" - Percentual de desconto máximo "+Transform(_nPMaxAO,"@E 999.99")+" %";		
			,"ATENÇÃO! DESCONTO DE AO -> BPOLGA01")

			aCols[N][_nPDACO] := 0

		EndIf

	EndIf
	
	//Validacoes do Desconto de OUTRAS AIs sem AO
	If ( ALLTRIM(__READVAR) == 'M->C6_YDAI' )

		If Empty(M->C5_YNOUTAI)

			MsgAlert("Para desconto de outras AI's - É obrigatório informar o Número da AI no cabeçalho no campo 'No.AI Outras'.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
			aCols[N][_nPDAI] := 0

		ElseIf !CheckAOValid(M->C5_YNOUTAI)
			MsgAlert("Percentual de Desconto de outras AI's não permitido.","ATENÇÃO! DESCONTO DE AI -> BPOLGA01")

			aCols[N][_nPDAI] := 0
		ElseIf !(aCols[N][_nPDAI] >= 0 .And. aCols[N][_nPDAI] <= nMaxDAI)

			MsgAlert("Percentual de Desconto de outras AI's não permitido - máximo = ("+AllTrim(Str(nMaxDAI))+"%).","ATENÇÃO! DESCONTO DE AI -> BPOLGA01")

			aCols[N][_nPDAI] := 0

		EndIf

	EndIf
	
	//Alterando pedido - atendente - ao trocar o lote via F6 - checkar se o lote vai ficar paletizado e dar o desconto
	If ALTERA .And. isincallstack("U_ConsEst") .And. Type("__FCESTALTLTPOL") <> "U"

		_lPaletizado := U_FRRT01P4(_cProduto, _cLocal, _nQtdDig, _cLote, _cSegmento, IIF(AllTrim(cEmpAnt)=="07", M->C5_YEMPPED, AllTrim(cEmpAnt)) )

		//escolha de lote manual arrematando estoque
		If (!_lPaletizado)
			If (AllTrim(cEmpAnt) == "07" .And. !Empty(M->C5_YEMP) .And. Len(M->C5_YEMP) == 4)
				_nSaldoRet := U_FROPCPRO(SubStr(M->C5_YEMP, 1, 2),SubStr(M->C5_YEMP, 3, 2),"U_FRRT01PR", _cProduto, _cLocal, "", "", _nQtdDig, "", _cLote)
			Else
				_nSaldoRet := U_FRRT01PR( _cProduto, _cLocal, "", "", _nQtdDig, "", _cLote)
			EndIf
			_lPaletizado := (_nSaldoRet == 0) .Or. ((_nSaldoRet - _nQtdDig) == 0) 
		EndIf
		
	EndIf

	//Pedidos normais - processa politica  
	If !(AllTrim(M->C5_YSUBTP) $ "A#M#F")

		If AllTrim(M->C5_CLIENTE) <> "010064" //Não processa para Cliente LM, considera o desconto replicado
			GAProc()		
		EndIf

		//Desconto de Amostra	
	Else
		
		
		__nValDesc := 0
		
		If (M->C5_YLINHA == '6')//Vinilico
			__nValDesc	:= DescAmosEmp('1302')	
		Else
			__nValDesc := 0
			ZA0->(DbSetOrder(1))
			If ZA0->(DbSeek(XFilial("ZA0")+"AMOS"))
				__nValDesc := ZA0->ZA0_PDESC 
			EndIf
		EndIf
		
		aCols[N][_nPDPAL]	:= 0
		aCols[N][_nPDCAT] 	:= 0
		aCols[N][_nPDREG] 	:= 0
		aCols[N][_nPDGER] 	:= 0
		aCols[N][_nPDPOL] 	:= __nValDesc
		aCols[N][_nPDNV]  	:= 0
		
		If SC6->(FieldPos("C6_YDFRA")) > 0
			aCols[N][_nPDFRA]  	:= 0
		EndIf
		aCols[N][_nPDTOT]  	:= __nValDesc
		aCols[N][_nPYDESCLI]:= __nValDesc	

	EndIf

	RestArea(aAreaA1)
	RestArea(aArea)

return(_nQtdDig)     

Static Function DescAmosEmp(cMarca)
	
	Local cQuery		:= ""
	Local cAliasTemp	:= GetNextAlias()
	Local nValor		:= 0
	
	cQuery := " SELECT ZA0_PDESC									 					" + CRLF
	cQuery += " FROM ZA0010																" + CRLF
	cQuery += " WHERE ZA0_FILIAL 	= ''												" + CRLF
	cQuery += " AND ZA0_MARCA		= '"+cMarca+"'										" + CRLF
	cQuery += " AND ZA0_TIPO		= 'AMOS'											" + CRLF
	cQuery += " AND D_E_L_E_T_		= '' 												" + CRLF
		
	TcQuery cQuery New Alias (cAliasTemp)
	
	If !(cAliasTemp)->(Eof())
		nValor := (cAliasTemp)->ZA0_PDESC
	EndIf
	(cAliasTemp)->(DbCloseArea())
	
Return nValor

/*/{Protheus.doc} GAProc
@description Processar a Politica Comercial e popular os campos de desconto do pedido
@author Fernando Rocha
@since 24/02/2017
@type function
/*/
Static Function GAProc()
	Local oDesconto
	
	
	oDesconto := TBiaPoliticaDesconto():New()
	oDesconto:LoadParMem()  //Carrega todos os parametros necessarios para a busca da politica das variaveis na tela do pedido
	
	If (AllTrim(M->C5_YSUBTP) $ "VO") .And. (ALLTRIM(__READVAR) == 'M->C6_YDESP')
		oDesconto:_lPaletizado := .F.
		oDesconto:Calculate()
		aCols[N][_nPDTOT] := oDesconto:DTOT
		aCols[N][_nPYDESCLI]  := oDesconto:DTOT_ORI
		return()
	EndIf

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProduto)) .And. SB1->B1_TIPO == "PR"
		_lPaletizado := .T.  //Produto PR considerar sempre como paletizado para descontos - ticket 4910
	EndIf

	If _lPaletizado
		oDesconto:_lPaletizado := .T.
	EndIf

	
	If oDesconto:GetPolitica()

		//Fernando em 22/11 - qualquer outro campo que for digitado que influencie na politica zerar a norma
		If ( !(ALLTRIM(__READVAR) $ 'M->C6_YDNV###M->C6_YDESP'))
			aCols[N][_nPDNV] := 0
			oDesconto:DNV := 0
			oDesconto:Calculate()
		EndIf

		If ( ALLTRIM(__READVAR) == 'M->C6_YDNV' .And. oDesconto:DNV_MAX > 0 .And. aCols[N][_nPDNV] > oDesconto:DNV_MAX )

			aCols[N][_nPDNV] := 0
			oDesconto:DNV := 0
			MsgAlert("Desconto de Norma - Máximo permitido é: "+AllTrim(Str(oDesconto:DNV_MAX))+"","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
			oDesconto:Calculate()

		ElseIf ( ALLTRIM(__READVAR) == 'M->C6_YDNV' .And. oDesconto:DNV_MAX == 0 )

			aCols[N][_nPDNV] := 0
			oDesconto:DNV := 0
			MsgAlert("Não existe NORMA cadastrada para esta venda.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
			oDesconto:Calculate()

		EndIf
		
		
		//regras vendas fracionada
		//Inicio venda fracionada
		If SC6->(FieldPos("C6_YDFRA")) > 0
		
			If ( ALLTRIM(__READVAR) == 'M->C6_YDFRA'  .And. oDesconto:_lPaletizado)
				aCols[N][_nPDFRA]	:= 0
				oDesconto:DFRA		:= 0
				MsgAlert("Desconto de venda fracionada - não permitido","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
				oDesconto:Calculate()
			ElseIf ( ALLTRIM(__READVAR) == 'M->C6_YDFRA' .And. !oDesconto:_lFracionada)
				aCols[N][_nPDFRA]	:= 0
				oDesconto:DFRA 		:= 0
				MsgAlert("Desconto de venda fracionada - não permitido","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
				oDesconto:Calculate()
			ElseIf ( ALLTRIM(__READVAR) == 'M->C6_YDFRA' .And. oDesconto:DFRA_MAX > 0 .And. aCols[N][_nPDFRA] > oDesconto:DFRA_MAX )
				aCols[N][_nPDFRA]	:= 0
				oDesconto:DFRA 		:= 0
				MsgAlert("Desconto para venda fracionada - Máximo permitido é: "+AllTrim(Str(oDesconto:DFRA_MAX))+"","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
				oDesconto:Calculate()
			ElseIf ( ALLTRIM(__READVAR) == 'M->C6_YDFRA' .And. oDesconto:DFRA_MAX == 0 )
				aCols[N][_nPDFRA]	:= 0
				oDesconto:DFRA		:= 0
				MsgAlert("Não existe desconto venda fracionada cadastrada para esta venda.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
				oDesconto:Calculate()
			EndIf
			//Fim venda fracionada
		EndIf
		
		If ( ALLTRIM(__READVAR) == 'M->C6_YDVER' )

			If ( oDesconto:DVER_MAX > 0 )

				If ( aCols[N][_nPDVER] > oDesconto:DVER_MAX )

					aCols[N][_nPDVER] := 0
					oDesconto:DVER := 0
					MsgAlert("Desconto de Verba - Máximo permitido é: "+AllTrim(Str(oDesconto:DVER_MAX))+"","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
					oDesconto:Calculate()

				Else

					oDesconto:DVER := aCols[N][_nPDVER]
					oDesconto:Calculate()

				EndIf

			Else

				aCols[N][_nPDVER] := 0
				oDesconto:DVER := 0
				MsgAlert("Não existe VERBA cadastrada para esta venda.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
				oDesconto:Calculate()

			EndIf

		EndIf


		//Se estiver digitando outros campos do desconto - recalcular pois os demais podem ter modificacao
		If ( (ALLTRIM(__READVAR) $ 'M->C6_YDNV###M->C6_YDESP###M->C6_YDVER###M->C6_YDACO###M->C6_YDAI###M->C6_YDNV'))

			oDesconto:DVER	:= aCols[N][_nPDVER]
			oDesconto:DACO	:= aCols[N][_nPDACO]
			oDesconto:DNV	:= aCols[N][_nPDNV]
			
			If SC6->(FieldPos("C6_YDFRA")) > 0
				oDesconto:DFRA	:= aCols[N][_nPDFRA]
			EndIf
			
			If SC6->(FieldPos("C6_YDAI")) > 0
				oDesconto:DAI	:= aCols[N][_nPDAI]
			EndIf

			oDesconto:Calculate()

		EndIf

		If ALLTRIM(__READVAR) == 'M->C6_QTDVEN' .And. (_lTpDVer)

			If !Empty(M->C5_YNUMSI)
				CheckAO(M->C5_YNUMSI, 0)

				oDesconto:DACO		:= _nPBonAO
				aCols[N][_nPDACO]	:= _nPBonAO
				oDesconto:Calculate()
			EndIf

			If SC6->(FieldPos("C6_YDAI")) > 0 .And. !Empty(M->C5_YNOUTAI)
				oDesconto:DAI		:= 0
				aCols[N][_nPDAI]	:= 0
				oDesconto:Calculate()
			EndIf

		EndIf

		//DVER so para pedidos de venda
		If (!_lTpDVer)
			oDesconto:DVER	:= 0
			aCols[N][_nPDVER] := 0
			oDesconto:Calculate()
		EndIf

		aCols[N][_nPDPAL] := oDesconto:DPAL
		aCols[N][_nPDCAT] := oDesconto:DCAT
		aCols[N][_nPDREG] := oDesconto:DREG
		aCols[N][_nPDGER] := oDesconto:DGER
		aCols[N][_nPDPOL] := oDesconto:DPOL
		aCols[N][_nPDNV]  := oDesconto:DNV
		
		If SC6->(FieldPos("C6_YDFRA")) > 0
			aCols[N][_nPDFRA]  := oDesconto:DFRA
		EndIf
		
		If SC6->(FieldPos("C6_YDVER")) > 0
			aCols[N][_nPDVER]  := oDesconto:DVER
		EndIf

		aCols[N][_nPDTOT] := oDesconto:DTOT

		//Salvar o campo C6_YDESCLI para comparacao e bloqueio de desconto conforme regra atual
		aCols[N][_nPYDESCLI]  := oDesconto:DTOT_ORI

	EndIf

return()


//BUSCAR COMISSAO -> BASEADO NO M410AGRV
User function fCalComi(_nComisCab,_cProduto)

	Local aAreaB1 := SB1->(GetArea())
	Local nAComis := _nComisCab

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProduto))

		If ( SB1->B1_YACRCOM <> 0 )
			nAComis += SB1->B1_YACRCOM
		EndIf

		If ( SB1->B1_YPERCOM <> 0 )
			nAComis := nAComis + (nAComis*SB1->B1_YPERCOM/100)
		EndIf

	EndIf

	RestArea(aAreaB1)

Return(nAComis)


/*/{Protheus.doc} CheckAO
@description Checkar se a AI é proveniente de AO, e neste caso limitar o desconto ao máximo da faixa de premiação
@author Fernando Rocha
@since 17/02/2017
@version undefined
@param _NUMSI, C, numero da AI
@param _NPDACO, N, percentual digitado de desconto
@type function
/*/
Static Function CheckAO(_NUMSI, _NPDACO)

	Local lRet := .T.
	Local cAliasTmp
	Local nAdDMax := GetNewPar("BF_ADDACO", 2)  //aditivo ao maximo de desconto de AI
	Local cTabSZO
	Local cTabPZ6
	Local cTabPZ5
	Local cQrySZO
	Local _cEmp
	Local _cMarca	:= ""
	Local _cMarcaDesc:= ""
	
	Do Case
		Case M->C5_YLINHA == "1"
		_cMarca	:= "0101"
		_cMarcaDesc:= 'Biancogres'
		Case M->C5_YLINHA == "2"
		_cMarca	:= "0501"
		_cMarcaDesc:= 'Incesa'
		Case M->C5_YLINHA == "3"
		_cMarca	:= "0599"
		_cMarcaDesc:= 'BelaCasa'
		Case M->C5_YLINHA == "4"
		_cMarca	:= "1399"
		_cMarcaDesc:= 'Mudiali'
		Case M->C5_YLINHA == "5"
		_cMarca	:= "0199"
		_cMarcaDesc:= 'Pegasus'
		Case M->C5_YLINHA == "6"
		_cMarca	:= "1302"
		_cMarcaDesc:= 'Vinilico'
	EndCase

	If Alltrim(M->C5_YLINHA) $ "2#3" .And. AllTrim(CEMPANT) $ "05"  //ticket 10958 marreta provisoria AI Incesa na Bianco
		cTabSZO := "% SZO050 %"
		cTabPZ6 := "% PZ6050 %"
		cTabPZ5 := "% PZ5050 %"
	Else
		cTabSZO := "% SZO010 %"
		cTabPZ6 := "% PZ6010 %"
		cTabPZ5 := "% PZ5010 %"
	EndIf

	If (AllTrim(CEMPANT) == "07")

		If ((ValType(aCols) <> "U" .And. Len(aCols) < 1) .Or. Empty(M->C5_YEMPPED))
			Aviso("AUTORIZAÇÃO DE INVESTIMENTO","Atenção: Na Empresa - LM, é necessario preencher uma linha do pedido, para depois informado o código da AI/Descontos de AI.",{"OK"},2,"SI informada: "+_NUM_SI)
			lRet := .F.
			Return(lRet)
		EndIf

		If (!Empty(M->C5_YEMPPED))
			_cEmp		:= AllTrim(M->C5_YEMPPED)

			cTabSZO := "% SZO"+_cEmp+"0 %"
			cTabPZ6 := "% PZ6"+_cEmp+"0 %"
			cTabPZ5 := "% PZ5"+_cEmp+"0 %"
		EndIf

	EndIf

	//private
	_nPMaxAO := 0
	_nPBonAO := 0

	cQryTemp := GetNextAlias()
	BeginSql Alias cQryTemp
		%NoParser%

		SELECT ZO_EMP FROM %Exp:cTabSZO% WHERE ZO_FILIAL = '01' AND ZO_SI = %Exp:_NUMSI% AND %NotDel%
		AND ZO_EMP != %Exp:_cMarca%
		
	EndSql
	
	If (!(cQryTemp)->(Eof()))
		MsgAlert("AI informada não e da não é da marca "+_cMarcaDesc+".","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
		lRet := .F.
	EndIf	
	(cQryTemp)->(DbCloseArea())
	
	
	//pesquisa AO na empresa origem
	cQrySZO := GetNextAlias()
	BeginSql Alias cQrySZO
		%NoParser%

		SELECT ZO_ITEMCTA, ZO_FPAGTO FROM %Exp:cTabSZO% WHERE ZO_FILIAL = '01' AND ZO_SI = %Exp:_NUMSI% AND %NotDel%
		AND ZO_EMP = %Exp:_cMarca%
		
		
	EndSql
	//and ZO_FPAGTO = '2'

	(cQrySZO)->(DbGoTop())
	
	
	If (!(cQrySZO)->(Eof()) .And.  AllTrim((cQrySZO)->ZO_FPAGTO) != '2' )
		If ((cQrySZO)->ZO_FPAGTO != "")
			MsgAlert("AI informada não é do 'Tipo de Pagamento:Desconto em Pedido'.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
			lRet := .F.
		EndIf
	EndIf
	
	
	If (lRet)
		IF !(cQrySZO)->(Eof()) .And. AllTrim((cQrySZO)->ZO_ITEMCTA) == "I0201"
	
			//Buscar se acordo tem percentuais de sugestao e maximo cadastrados - OS. 2508-17 - Fernando em 15/08/2017
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				%NoParser%
	
				select PZ5_PPGSUG, PZ5_PPGMAX
				from %Exp:cTabPZ6% PZ6 
				join %Exp:cTabPZ5% PZ5 on PZ5_CODIGO = PZ6_CODIGO 
				where PZ6_SI = %Exp:_NUMSI% 
				and PZ6.D_E_L_E_T_ = ''
				and PZ5.D_E_L_E_T_ = ''
	
			EndSql
	
			(cAliasTmp)->(DbGoTop())
			If !(cAliasTmp)->(Eof())
	
				_nPBonAO := (cAliasTmp)->PZ5_PPGSUG
				_nPMaxAO := (cAliasTmp)->PZ5_PPGMAX
	
				If _nPBonAO > 0 .And. _nPMaxAO <= 0
					_nPMaxAO := _nPBonAO + nAdDMax
				EndIf
	
			EndIf
			(cAliasTmp)->(DbCloseArea())
	
	
			IF ( _nPBonAO <= 0 )
	
				cAliasTmp := GetNextAlias()
				BeginSql Alias cAliasTmp
					%NoParser%
	
					select PBONUS = case when PZ6_METAF5 > 0 and PZ6_VALREA >= PZ6_METAF5 then PZ6_PBONF5
					when PZ6_METAF4 > 0 and PZ6_VALREA >= PZ6_METAF4 then PZ6_PBONF4
					when PZ6_METAF3 > 0 and PZ6_VALREA >= PZ6_METAF3 then PZ6_PBONF3
					when PZ6_METAF2 > 0 and PZ6_VALREA >= PZ6_METAF2 then PZ6_PBONF2
					else PZ6_PBONF1 end
					from %Exp:cTabPZ6% where PZ6_SI = %Exp:_NUMSI% and D_E_L_E_T_ = ''
	
				EndSql
	
				(cAliasTmp)->(DbGoTop())
				If !(cAliasTmp)->(Eof())
	
					_nPBonAO := (cAliasTmp)->PBONUS
					_nPMaxAO := _nPBonAO + nAdDMax
	
				EndIf
				(cAliasTmp)->(DbCloseArea())
	
			ENDIF
	
		Else
			MsgAlert("AI não localizada ou não é proveniente de Acordo Objetivo.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
			lRet := .F.
		EndIf
	EndIf
	
	(cQrySZO)->(DbCloseArea())

	If lRet .And. _nPMaxAO > 0

		lRet := _NPDACO <= _nPMaxAO

	EndIf

Return(lRet)


Static Function CheckAOValid(_NUMSI)

	Local lRet 		:= .T.
	Local cTabSZO	:= Nil
	Local cQrySZO	:= Nil
	Local _cEmp		:= Nil
	Local _cMarca	:= ""
	Local _cMarcaDesc:= ""
	
	Do Case
		Case M->C5_YLINHA == "1"
		_cMarca	:= "0101"
		_cMarcaDesc:= 'Biancogres'
		Case M->C5_YLINHA == "2"
		_cMarca	:= "0501"
		_cMarcaDesc:= 'Incesa'
		Case M->C5_YLINHA == "3"
		_cMarca	:= "0599"
		_cMarcaDesc:= 'BellaCasa'
		Case M->C5_YLINHA == "4"
		_cMarca	:= "1399"
		_cMarcaDesc:= 'Mudiali'
		Case M->C5_YLINHA == "5"
		_cMarca	:= "0199"
		_cMarcaDesc:= 'Pegasus'
		Case M->C5_YLINHA == "6"
		_cMarca	:= "1302"
		_cMarcaDesc:= 'Vinilico'
	EndCase
	
	If Alltrim(M->C5_YLINHA) $ "2#3" .And. AllTrim(CEMPANT) $ "05"  //ticket 10958 marreta provisoria AI Incesa na Bianco
		cTabSZO := "% SZO050 %"
	Else
		cTabSZO := "% SZO010 %"
	EndIf

	If (AllTrim(CEMPANT) == "07")

		If ((ValType(aCols) <> "U" .And. Len(aCols) < 1) .Or. Empty(M->C5_YEMPPED))
			Aviso("AUTORIZAÇÃO DE INVESTIMENTO","Atenção: Na Empresa - LM, é necessario preencher uma linha do pedido, para depois informado o código da AI/Descontos de AI.",{"OK"},2,"SI informada: "+_NUM_SI)
			lRet := .F.
			Return(lRet)
		EndIf

		If (!Empty(M->C5_YEMPPED))
			_cEmp		:= AllTrim(M->C5_YEMPPED)
			cTabSZO 	:= "% SZO"+_cEmp+"0 %"
		EndIf

	EndIf
	
	cQryTemp := GetNextAlias()
	BeginSql Alias cQryTemp
		%NoParser%

		SELECT ZO_EMP FROM %Exp:cTabSZO% WHERE ZO_FILIAL = '01' AND ZO_SI = %Exp:_NUMSI% AND %NotDel%
		AND ZO_EMP != %Exp:_cMarca%
		
	EndSql
	
	If (!(cQryTemp)->(Eof()))
		MsgAlert("AI informada da não é da marca "+_cMarcaDesc+".","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
		lRet := .F.
	EndIf	
	(cQryTemp)->(DbCloseArea())
	

	//pesquisa AO na empresa origem
	cQrySZO := GetNextAlias()
	BeginSql Alias cQrySZO
		%NoParser%

		SELECT * FROM %Exp:cTabSZO% WHERE ZO_FILIAL = '01' AND ZO_SI = %Exp:_NUMSI% AND %NotDel%
		AND ZO_EMP = %Exp:_cMarca%  
		
	EndSql
	
	
	
	(cQrySZO)->(DbGoTop())
	If (cQrySZO)->(Eof())
		MsgAlert("AI não localizada ou não é proveniente de Acordo Objetivo.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
		lRet := .F.
	Else
		If (AllTrim((cQrySZO)->ZO_FPAGTO) != '2')
			If ((cQrySZO)->ZO_FPAGTO != "") 
				MsgAlert("AI informada não é do 'Tipo de Pagamento:Desconto em Pedido'.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	
	(cQrySZO)->(DbCloseArea())


Return(lRet)