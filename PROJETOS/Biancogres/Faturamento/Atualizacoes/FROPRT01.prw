#include "PROTHEUS.CH"      
#include "TOPCONN.CH"

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

/*/{Protheus.doc} FROPRT01
@description Rotina para calcular saldo disponivel para venda
@author Fernando Rocha
@since 18/02/2014
@version undefined
@param _cProd		, , descricao
@param _cLocal		, , descricao
@param _cPedido		, , descricao
@param _cItem		, , descricao
@param _nQtdDig		, , qtde digitada
@param _cLote		, , lote especifico para consulta ou reserva
@param _cSegmento	, ,	segmento do cliente
@param _cEmpOri		, ,	empresa de origem
@param _lPalete		, , Se cliente so aceita palete fechado
@param _cCategoria	, , Categoria do cliente
@param _cLotRes		, ,	Cliente aceita Lote restrito
@param _nProxLote	, , Se he para escolher primeiro lote que nao gere ponta
@param _cLoteAdd    , , Parametro para listar separado por # lotes especificos para pesquisar 
@param _cLoteExc    , , Parametro para listar separado por # lotes para EXCLUIR da pesquisar
@type function
/*/

User Function FROPRT01(_cProd, _cLocal, _cPedido, _cItem, _nQtdDig, _cLote, _cSegmento, _cEmpOri, _lPalete, _cCategoria, _cLotRes, _nProxLote, _cLoteAdd, _cLoteExc, _lExibirTela, _lDFRA)

	Local aArea := GetArea()
	Local _nSaldo
	Local _cUserName	:= CUSERNAME
	Local _nPMax 		:= GetNewPar("MV_YSLTMAX",	20)  
	Local _nPMin 		:= GetNewPar("MV_YSLTMIN",	20)  
	Local _cPrioSaldo	:= GetNewPar("MV_YSLTPRI",	'')
	Local _nTolerancia	:= GetNewPar("MV_YSLTTMA",	0.99)
	  
	
	Local _aRetSaldo	:= Array(13)

	/*Formato do vetor _aRetSaldo
	aRet[1] 	:= oPBI:EmpEst			=> Empresa do Estoque	
	aRet[2] 	:= oPBI:LocEst			=> Armazem
	aRet[3] 	:= oPBI:CodProduto		=> Produto
	aRet[4] 	:= oPBI:Prioridade		=> Prioridade
	aRet[5] 	:= oPBI:Lote			=> Lote
	aRet[6] 	:= oPBI:Qtd_Solicit		=> Qtde Solicitada
	aRet[7] 	:= oPBI:Saldo			=> Saldo total do Lote
	aRet[8] 	:= oPBI:Qtd_Sug			=> Qtde sugerida para venda
	aRet[9] 	:= oPBI:N_Pallets		=> Numero de paletes fechados sugeridos para venda
	aRet[10] 	:= oPBI:Qtd_Um_Pallet	=> Qtde m2 de um palete
	aRet[11] 	:= oPBI:Qtd_Ponta		=> Qtde em Ponta/Fracionado sugerido para venda
	aRet[12] 	:= oPBI:Regra_Sug		=> Regra de sugestao usada
	aRet[13] 	:= oPBI:EscolhaManual	=> Escolha lote manual
	
	*/

	Default _cLote 			:= ""
	Default _cSegmento 		:= ""
	Default _cEmpOri 		:= ""
	Default _cCategoria		:= ""
	Default _cLotRes		:= ""
	Default _nProxLote		:= 0
	Default _cLoteAdd		:= ""
	Default _cLoteExc		:= ""
	Default _lExibirTela	:= .F.
	Default	_lDFRA			:= .F.

	If Type("_FROPCHVTEMPRES") <> "U" .And. !Empty(_FROPCHVTEMPRES)
		_cUserName := _FROPCHVTEMPRES
	EndIf

	If ( _nProxLote == 1 )

		_nPMax := 0  
		_nPMin := 0

	EndIf

	If (Empty(_cEmpOri) .And. AllTrim(cEmpAnt) == '07' .And. AllTrim(cFilAnt) == '05')
		_cEmpOri := '07'
	EndIf
	
	
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cProd))

	//PBI/Consolidacao - Poduto Manta e consulta de lote especifico - entra na consulta direto de lote na empresa logada
	If (SB1->B1_TIPO == "PR") .OR. !Empty(_cLote)

		_nSaldo := U_FRRT01PR(_cProd, _cLocal, _cPedido, _cItem, _nQtdDig, _cUserName, _cLote)

		_aRetSaldo[1] := AllTrim(CEMPANT)
		_aRetSaldo[2] := _cLocal
		_aRetSaldo[3] := _cProd
		_aRetSaldo[4] := 0
		_aRetSaldo[5] := _cLote
		_aRetSaldo[6] := _nQtdDig
		_aRetSaldo[7] := _nSaldo

		//Demais casos funcao geral de estoque PBI
	Else

		SB1->(DbSetOrder(1))
		IF SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. !Empty(SB1->B1_YEMPEST)

			_aRetPBI := U_FPBIGEMP(_cProd, _nQtdDig, _cSegmento, _cUserName, _cItem, _nPMax, _nPMin, _cEmpOri, _lPalete, _cCategoria, _cLotRes, _nProxLote, _cLoteAdd, _cLoteExc, _cPrioSaldo, _nTolerancia, _lExibirTela, _lDFRA)

			_aRetSaldo := _aRetPBI

		Else

			U_FROPMSG(TIT_MSG, 	"Formato sem ESTOQUE E/OU EMPRESA DE FABRICAÇÃO configurada. Verifique.",,,"CONFIGURAÇÃO DO PRODUTO")

			_aRetSaldo := Array(13)

		EndIf

	EndIf

	RestArea(aArea)

return(_aRetSaldo)


User Function FRRT01PR(_cProd, _cLocal, _cPedido, _cItem, _nQtdDig, _cUserName, _cLote)
	Local _nSaldo
	Local cAliasTmp
	Local _cExpEnd
	Local _cExpLot

	Default _cPedido 	:= ""
	Default _cItem 		:= ""
	Default _cUserName	:= ""  
	Default _cLote		:= ""


	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cProd))

	IF SB1->B1_TIPO <> "PR"

		If AllTrim(CEMPANT) <> "13"                   
			If _cLocal <> "05"
				_cExpEnd := "% BF_LOCALIZ in ('ZZZZ','P. DEVOL') %"
			Else
				_cExpEnd := "% BF_LOCALIZ in ('AMT') %"
			EndIf
		Else
			_cExpEnd := "% 1 = 1 %"
		EndIf

		If !Empty(_cLote)
			_cExpLot := "% BF_LOTECTL = '"+_cLote+"' %"
		Else
			_cExpLot := "% 1 = 1 %"
		EndIf

		_nSaldo := 0

		//Buscar saldo do primeiro lote com capacidade para atender ao item de pedido
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			%NoParser%

			with TAB_LOT as
			(select BF_LOTECTL, SALDO = SUM(BF_QUANT - BF_EMPENHO)
			from %TABLE:SBF%	SBF
			where 	BF_PRODUTO = %EXP:_cProd%
			and BF_LOCAL = %EXP:_cLocal%
			and (BF_QUANT - BF_EMPENHO) > 0
			and %EXP:_cExpEnd%
			and %EXP:_cExpLot%
			and SBF.D_E_L_E_T_ = ''
			group by BF_LOTECTL)
			select top 1 SALDO
			from TAB_LOT
			where Round(SALDO,2) >= %EXP:_nQtdDig%
			order by SALDO

		EndSql
		//MemoWrite("\Consulta_Estoque_ROP.TXT", GetLastQuery()[2])

	ELSE

		//Buscar saldo de produto PR - Fernando 23/05/18 - Ticekt 4910
		_nSaldo := 0

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			%NoParser%

			select top 1 SALDO = ISNULL(B2_QATU - (B2_QEMP + B2_RESERVA),0) 
			FROM SB2070 SB2 
			JOIN SB1010 SB1 ON B1_COD = B2_COD
			WHERE 
			B1_TIPO = 'PR' 
			AND B2_COD = %EXP:_cProd%
			AND B2_LOCAL IN ('02','04') 
			AND B2_QATU > 0 
			AND SB1.D_E_L_E_T_=' ' 
			AND SB2.D_E_L_E_T_=' ' 

		EndSql

	ENDIF

	If !(cAliasTmp)->(Eof())
		_nSaldo := _nSaldo + (cAliasTmp)->SALDO
	EndIf
	(cAliasTmp)->(DbCloseArea())

	//Alteracao de pedido - descontar reservas do proprio item
	If !Empty(_cPedido)

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp

			select SALDO = sum(C0_QUANT) from %TABLE:SC0% where C0_SOLICIT = %EXP:_cUserName% and C0_PRODUTO = %EXP:_cProd% and C0_YITEMPV = %EXP:_cItem% and D_E_L_E_T_ = ' '

		EndSql

		If !(cAliasTmp)->(Eof())
			_nSaldo := _nSaldo + (cAliasTmp)->SALDO
		EndIf
		(cAliasTmp)->(DbCloseArea())

	EndIf

return(_nSaldo)

/*/{Protheus.doc} FRSLDAMO
@description Saldo para AMOSTRA - Fernando/Facile em 17/08/15
@author Fernando Rocha
@since 30/05/2017
@version undefined
@param _cProd, , descricao
@param _cLocal, , descricao
@param _nQtdDig, , descricao
@param lRodape, logical, descricao
@type function
/*/
User Function FRSLDAMO(_cProd, _cLocal, _nQtdDig, lRodape)
	Local aArea := GetArea()
	Local _nSaldo

	Default lRodape := .F.

	If AllTrim(CEMPANT) <> "07"

		_nSaldo := U_FRSAMOPR(_cProd, _cLocal, _nQtdDig, lRodape)

	Else

		SB1->(DbSetOrder(1))
		IF SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. !Empty(SB1->B1_YEMPEST)

			nLinhaEmp := SB1->B1_YEMPEST
			_nSaldo := U_FROPCPRO(SubStr(nLinhaEmp,1,2),SubStr(nLinhaEmp,3,2),"U_FRSAMOPR", _cProd, _cLocal, _nQtdDig, lRodape)

		Else

			U_FROPMSG(TIT_MSG, 	"Formato sem EMPRESA DE FABRICAÇÃO cadastrada. Verifique.",,,"CONFIGURAÇÃO DO FORMATO")

			_nSaldo := 0
		EndIf
	EndIf

	RestArea(aArea)
return(_nSaldo)

User Function FRSAMOPR(_cProd, _cLocal, _nQtdDig, lRodape)
	Local _nSaldo := 0
	Local cAliasTmp
	Local _aAreaB1 := SB1->(GetArea())
	Local cLocaliz := ""

	Default lRodape := .F.

	If lRodape
		cLocaliz := "ZZZZ"
	Else
		cLocaliz := "AMT"
	EndIf 

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProd))  

		//Buscar saldo do armazem 05 para o produto - se tiver controle de localizao SBF , se nao SB2 -> Fernando em 21/10/15
		cAliasTmp := GetNextAlias()

		If SB1->B1_LOCALIZ == "S"

			BeginSql Alias cAliasTmp
				%NOPARSER%

				select SALDO = SUM(BF_QUANT - BF_EMPENHO)
				from %TABLE:SBF%	SBF
				where 	BF_PRODUTO = %EXP:_cProd%
				and BF_LOCAL = %EXP:_cLocal%
				and (BF_QUANT - BF_EMPENHO) > 0
				and BF_LOCALIZ in (%EXP:cLocaliz%)
				and SBF.D_E_L_E_T_ = ''
				group by BF_LOTECTL

			EndSql

		Else      

			BeginSql Alias cAliasTmp
				%NOPARSER%

				select SALDO = SUM(B2_QATU - B2_RESERVA)
				from %TABLE:SB2%	SB2
				where 	B2_COD = %EXP:_cProd%
				and B2_LOCAL = %EXP:_cLocal%
				and (B2_QATU - B2_RESERVA) > 0
				and SB2.D_E_L_E_T_ = ''
				group by B2_LOCAL

			EndSql

		EndIf

		If !(cAliasTmp)->(Eof())
			_nSaldo := _nSaldo + (cAliasTmp)->SALDO
		EndIf
		(cAliasTmp)->(DbCloseArea()) 

	EndIf

	RestArea(_aAreaB1)
return(_nSaldo)       



/*/{Protheus.doc} FRRT01P3
@description Funcao para pesquisar lote de AMOSTRA - compatibilizando com a pesquisa para venda
@author Fernando Rocha
@since 30/05/2017
@version undefined
@param _cProduto, , descricao
@param _cLocal, , descricao
@param _nQuant, , descricao
@type function
/*/
User Function FRRT01P3(_cProduto, _cLocal, _nQuant)
	Local cAliasTmp                      
	Local aRET
	Local _aAreaB1 := SB1->(GetArea())

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProduto))  

		//Buscar saldo do armazem 05 para o produto - se tiver controle de localizao SBF , se nao SB2 -> Fernando em 21/10/15
		cAliasTmp := GetNextAlias()

		If SB1->B1_LOCALIZ == "S"

			BeginSql Alias cAliasTmp
				%NOPARSER%

				select LOTE = BF_LOTECTL, SALDO = SUM(BF_QUANT - BF_EMPENHO)
				from %TABLE:SBF%	SBF
				where 	BF_PRODUTO = %EXP:_cProduto%
				and BF_LOCAL = %EXP:_cLocal%
				and ROUND((BF_QUANT - BF_EMPENHO), 2)  >= %EXP:_nQuant%
				and BF_LOCALIZ in ('AMT')
				and SBF.D_E_L_E_T_ = ''
				group by BF_LOTECTL

			EndSql

		Else      

			BeginSql Alias cAliasTmp
				%NOPARSER%

				select LOTE = ' ', SALDO = SUM(B2_QATU - B2_RESERVA)
				from %TABLE:SB2%	SB2
				where 	B2_COD = %EXP:_cProduto%
				and B2_LOCAL = %EXP:_cLocal%
				and (B2_QATU - B2_RESERVA) >= %EXP:_nQuant%
				and SB2.D_E_L_E_T_ = ''
				group by B2_LOCAL

			EndSql

		EndIf

		If !(cAliasTmp)->(Eof())

			aRET := Array(10)

			aRET[1] := (cAliasTmp)->LOTE
			aRET[2] := (cAliasTmp)->SALDO
			aRET[3] := (cAliasTmp)->SALDO
			aRET[4] := 0
			aRET[5]	:= 0
			aRET[6]	:= 0
			aRET[7]	:= 0
			aRET[8]	:= AllTrim(CEMPANT)
			aRET[9]	:= _cLocal
			aRET[10]:= .T.

		Else

			aRET := Array(10)

		EndIf
		(cAliasTmp)->(DbCloseArea()) 

	EndIf

	RestArea(_aAreaB1)
return(aRET)


/*/{Protheus.doc} FRRT01P4
@description Validar se Lote escolhido vai ficar paletizado apos reserva
@author Fernando Rocha
@since 30/05/2017
@version undefined
@param _cProduto, , descricao
@param _cLocal, , descricao
@param _nQuant, , descricao
@type function
/*/
User Function FRRT01P4(_cProd, _cLocal, _nQtdDig, _cLote, _cSegmento, _cEmpOri)

	Local _lRet := .F.
	Local _nSldLot
	Local _aAreaB1 := SB1->(GetArea())
	Local _nDivPA

	_nSldLot := U_FROPRT01(_cProd, _cLocal, "", "", _nQtdDig, _cLote, _cSegmento, _cEmpOri)[7]

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProd))

		_nDivPA := SB1->B1_YDIVPA * SB1->B1_CONV

		ZZ9->(DbSetOrder(1))
		If ZZ9->(DbSeek(XFilial("ZZ9")+_cLote+_cProd))

			_nDivPA := ZZ9->ZZ9_DIVPA * SB1->B1_CONV

		EndIf

		_lRet := ((_nSldLot - _nQtdDig) % _nDivPA) == 0  //o saldo restante é Zero ou Palete Fechado

	EndIf

	RestArea(_aAreaB1)
Return(_lRet)


User Function BSRESPRO(_cNRESER,  _cProduto, _cLote, nQuant, _cTipo, _cDocRes)
	Local _cQuery			:= ""
	Local _cAliasTemp		:= Nil//GetNextAlias()
	Local _aArea			:= Nil//GetArea()
	Local lRet				:= .F.
	Local lErro				:= .F.
	
	Local nQtdResult	:= 0 
	Local cNum			:= ""
	Local cProd			:= ""
	Local cLocal		:= ""
	Local cNumLote		:= ""
	Local cLoteCtl		:= ""
	Local cLocaliz		:= ""
	Local cNumSerie		:= ""
	Local cData			:= ""
	Local cSolici		:= ""
	Local cYPraSol		:= ""
	
	Default _cTipo			:= 'CL'
	Default _cDocRes		:= 'SILVER'
	
		
	_cAliasTemp		:= GetNextAlias()
	_aArea			:= GetArea()
					
	_cQuery += " SELECT ID=R_E_C_N_O_								 		 						"
	_cQuery += " FROM " + RetSQLName("SC0")+"														"		    
	_cQuery += " WHERE C0_FILIAL 		= "+ ValToSQL(xFilial("SC0"))+"								"
	_cQuery += " AND C0_TIPO			= '"+_cTipo+"'												"
	_cQuery += " AND C0_DOCRES			= '"+_cDocRes+"'											"
	_cQuery += " AND C0_NUM		 		= '"+_cNRESER+"' 											"
	_cQuery += " AND C0_PRODUTO			= '"+_cProduto+"'											"
	_cQuery += " AND C0_LOTECTL	 		= '"+_cLote+"'												"
	
	_cQuery += " AND C0_QUANT 			>= '"+cvaltochar(nQuant)+"' 								"
	_cQuery += " AND C0_LOCALIZ 		NOT IN ('AMT') 												"
	_cQuery += " AND D_E_L_E_T_ 		= '' 														"
	TcQuery _cQuery New Alias (_cAliasTemp)

	If (!(_cAliasTemp)->(Eof()))
		
		  DBSelectArea("SC0")
		  SC0->(DBGoTo((_cAliasTemp)->ID))
		  	
		  	nQtdResult	:= (SC0->C0_QUANT - nQuant) 
		  	cNum		:= SC0->C0_NUM
		  	cProd		:= SC0->C0_PRODUTO
		  	cLocal		:= SC0->C0_LOCAL
		  	cNumLote	:= SC0->C0_NUMLOTE
		  	cLoteCtl	:= SC0->C0_LOTECTL
		  	cLocaliz	:= SC0->C0_LOCALIZ
		  	cNumSerie	:= SC0->C0_NUMSERI
		  	cData		:= SC0->C0_VALIDA
            cSolici		:= SC0->C0_SOLICIT
            cYPraSol	:= SC0->C0_YPRASOL	
            
		   Begin Transaction
		   
		   	 lErro := !a430Reserv({3,"VD","", cUserName, XFilial("SC0")},; // A funcao estorna tudo
		        	SC0->C0_NUM,;
		            SC0->C0_PRODUTO,;
		            SC0->C0_LOCAL,;
		            SC0->C0_QUANT,;
		            {	SC0->C0_NUMLOTE,;
		            SC0->C0_LOTECTL,;
		            SC0->C0_LOCALIZ,;
		            SC0->C0_NUMSERI})
		    
		    If !lErro // Significa que foi estornado parte da SC0

                lErro := !a430Reserva({1,"VD","", cUserName, XFilial("SC0")},;
                   	cNum,;
                    cProd,;
                    cLocal,;
                    (nQtdResult),;
                    {"", cLoteCtl, cLocaliz, cNumSerie})

                	SC0->(DbSetOrder(1))
					If SC0->(DbSeek(XFilial("SC0")+cNum+cProd))
						RecLock("SC0",.F.)
						SC0->C0_VALIDA		:= cData
						SC0->C0_TIPO		:= 	'CL'	
						SC0->C0_DOCRES		:= 'SILVER'
						SC0->C0_SOLICIT		:=  cSolici
						SC0->C0_YPRASOL		:= cYPraSol
					EndIf    

            EndIf
                    
		    If lErro
		
		        DisarmTransaction()
		
		    EndIf
		
		   End Transaction         
            
     EndIf

	(_cAliasTemp)->(DbCloseArea())
	
	RestArea(_aArea)
Return lErro

User Function CSRESPRO(_cNRESER, _cProduto, _cLote, _nQuant, _cTipo, _cDocRes)
	Local _cQuery			:= ""
	Local _cAliasTemp		:= Nil//GetNextAlias()
	Local _aArea			:= Nil//GetArea()
	Local lRet				:= .F.
	Local lErro				:= .F.
	
	Local nQtdResult	:= "" 
	Local cNum			:= ""
	Local cProd			:= ""
	Local cLocal		:= ""
	Local cNumLote		:= ""
	Local cLoteCtl		:= ""
	Local cLocaliz		:= ""
	Local cNumSerie		:= ""
	Local cData			:= ""
	Local cSolici		:= ""
	Local cYPraSol		:= ""
	
	Default _cTipo			:= 'CL'
	Default _cDocRes		:= 'SILVER'
	
	_cAliasTemp		:= GetNextAlias()
	_aArea			:= GetArea()
					
	_cQuery += " SELECT ID=R_E_C_N_O_								 		 						"
	_cQuery += " FROM " + RetSQLName("SC0")+"														"		    
	_cQuery += " WHERE C0_FILIAL 		= "+ ValToSQL(xFilial("SC0"))+"								"
	_cQuery += " AND C0_TIPO			= '"+_cTipo+"'												"
	_cQuery += " AND C0_DOCRES			= '"+_cDocRes+"'											"
	_cQuery += " AND C0_NUM		 		= '"+_cNRESER+"' 											"
	_cQuery += " AND C0_LOCALIZ 		NOT IN ('AMT') 												"
	_cQuery += " AND C0_PRODUTO			= '"+_cProduto+"'											"
	_cQuery += " AND C0_LOTECTL	 		= '"+_cLote+"'												"
	_cQuery += " AND D_E_L_E_T_ 		= '' 														"
	
	TcQuery _cQuery New Alias (_cAliasTemp)

	If (!(_cAliasTemp)->(Eof()))
		
		  DBSelectArea("SC0")
		  SC0->(DBGoTo((_cAliasTemp)->ID))
		  	
		  	nQtdResult	:= (SC0->C0_QUANT + _nQuant) 
		  	cNum		:= SC0->C0_NUM
		  	cProd		:= SC0->C0_PRODUTO
		  	cLocal		:= SC0->C0_LOCAL
		  	cNumLote	:= SC0->C0_NUMLOTE
		  	cLoteCtl	:= SC0->C0_LOTECTL
		  	cLocaliz	:= SC0->C0_LOCALIZ
		  	cNumSerie	:= SC0->C0_NUMSERI
		  	cData		:= SC0->C0_VALIDA
            cSolici		:= SC0->C0_SOLICIT
            cYPraSol	:= SC0->C0_YPRASOL	
            
		   Begin Transaction
		   
		   	 lErro := !a430Reserv({3,"VD","", cUserName, XFilial("SC0")},; // A funcao estorna tudo
		        	SC0->C0_NUM,;
		            SC0->C0_PRODUTO,;
		            SC0->C0_LOCAL,;
		            SC0->C0_QUANT,;
		            {	SC0->C0_NUMLOTE,;
		            SC0->C0_LOTECTL,;
		            SC0->C0_LOCALIZ,;
		            SC0->C0_NUMSERI})
		    
		    If !lErro // Significa que foi estornado parte da SC0

                lErro := !a430Reserva({1,"VD","", cUserName, XFilial("SC0")},;
                   	cNum,;
                    cProd,;
                    cLocal,;
                    (nQtdResult),;
                    {"", cLoteCtl, cLocaliz, cNumSerie})

                	SC0->(DbSetOrder(1))
					If SC0->(DbSeek(XFilial("SC0")+cNum+cProd))
						RecLock("SC0",.F.)
						SC0->C0_VALIDA		:= cData
						SC0->C0_TIPO		:= 	'CL'	
						SC0->C0_DOCRES		:= 'SILVER'
						SC0->C0_SOLICIT		:=  cSolici
						SC0->C0_YPRASOL		:= cYPraSol
					EndIf    

            EndIf
                    
		    If lErro
		
		        DisarmTransaction()
		
		    EndIf
		
		   End Transaction         
            
     EndIf

	(_cAliasTemp)->(DbCloseArea())
	
	RestArea(_aArea)
Return lErro


User Function EXRESPEI(_cSolicit, _cProduto, _cLote, _nQuant, _cPedido, _cItem, _cEmp, _cFil)

	Local _cQuery			:= ""
	Local _cAliasTemp		:= Nil
	Local _aArea			:= Nil
	Local _lRet				:= .F.
	
	_cAliasTemp		:= GetNextAlias()
	_aArea			:= GetArea()
					
					
	_cQuery += " SELECT *													 						"
	_cQuery += " FROM " + RetSQLName("SC0")+"														"		    
	_cQuery += " WHERE C0_FILIAL 		= "+ ValToSQL(xFilial("SC0"))+"								"
	_cQuery += " AND C0_SOLICIT			= '"+_cSolicit+"'											"
	_cQuery += " AND C0_PRODUTO			= '"+_cProduto+"'											"
	_cQuery += " AND C0_LOTECTL	 		= '"+_cLote+"'												"
	_cQuery += " AND C0_QUANT 			= '"+cvaltochar(_nQuant)+"'									"
		
	If (_cEmp == '07')
		_cQuery += " AND C0_YPITORI	 		= '"+_cPedido+_cItem+"' 								"	
	Else
		_cQuery += " AND C0_YPEDIDO	= '"+_cPedido+"'				 								"	
		_cQuery += " AND C0_YITEMPV	= '"+_cItem+"'			 										"	
	EndIf
	_cQuery += " AND C0_YTEMP	= 'S'				 												"	
					
	_cQuery += " AND D_E_L_E_T_ = ''		 														"
	
	conout(_cQuery)
	
	TcQuery _cQuery New Alias (_cAliasTemp)

	If (!(_cAliasTemp)->(Eof()))
		  _lRet := .T.
	EndIf

	(_cAliasTemp)->(DbCloseArea())
	
//	Alert(cvaltochar(_lRet))
	
	RestArea(_aArea)
Return _lRet


User Function VAPRESPI(_cNRESER, _nQtdDig, _cSolicit, _cProduto, _cLote, _cPedido, _cItem, _cEmp, _cFil)

	Local _cQuery			:= ""
	Local _cAliasTemp		:= Nil
	Local _aArea			:= Nil
	Local _nQuant			:= 0
	Local _cTipo			:= 'CL'
	Local _cDocRes			:= 'SILVER'
	Local _lRet				:= .T.
	Local _nDivPA			:= 0
	Local _nLoteMin			:= 0
	
	_cAliasTemp		:= GetNextAlias()
	_aArea			:= GetArea()
					
	_cQuery += " SELECT C0_PRODUTO, C0_QUANT														"
	_cQuery += " FROM " + RetSQLName("SC0")+"														"		    
	_cQuery += " WHERE C0_FILIAL 		= "+ ValToSQL(xFilial("SC0"))+"								"
	_cQuery += " AND C0_TIPO			= '"+_cTipo+"'												"
	_cQuery += " AND C0_DOCRES			= '"+_cDocRes+"'											"
	_cQuery += " AND C0_NUM		 		= '"+_cNRESER+"' 											"
	_cQuery += " AND C0_PRODUTO			= '"+_cProduto+"'											"
	_cQuery += " AND C0_LOCALIZ 		NOT IN ('AMT') 												"
	_cQuery += " AND D_E_L_E_T_ 		= '' 														"
	
	TcQuery _cQuery New Alias (_cAliasTemp)

	If (!(_cAliasTemp)->(Eof()))
		 _nQuant := (_cAliasTemp)->C0_QUANT
	EndIf
	
	(_cAliasTemp)->(DbCloseArea())
	
	_nQuant += U_GQTRESPI(_cSolicit, _cProduto, _cLote, _cPedido, _cItem, _cEmp, _cFil)
	

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProduto))

		_nDivPA := SB1->B1_YDIVPA * SB1->B1_CONV

		ZZ9->(DbSetOrder(1))
		If ZZ9->(DbSeek(XFilial("ZZ9")+_cLote+_cProduto))

			_nDivPA := ZZ9->ZZ9_DIVPA * SB1->B1_CONV

		EndIf
		
	
		DbSelectArea('ZZ6')
		ZZ6->(DbSetOrder(1))
		If (ZZ6->(DbSeek(xFilial('ZZ6')+SB1->B1_YFORMAT)))
			_nLoteMin := ZZ6->ZZ6_LOTEMI
		EndIf
		
		_lRet := ((_nQuant - _nQtdDig) % _nDivPA) >= _nLoteMin  
		
		If (!_lRet)
			_lRet := (_nQuant - _nQtdDig) == 0
		EndIf
		
	EndIf
	
	RestArea(_aArea)

Return _lRet


User Function GQTRESPI(_cSolicit, _cProduto, _cLote, _cPedido, _cItem, _cEmp, _cFil)

	Local _cQuery			:= ""
	Local _cAliasTemp		:= Nil
	Local _aArea			:= Nil
	Local _nQuant			:= 0
	
	_cAliasTemp		:= GetNextAlias()
	_aArea			:= GetArea()
					
					
	_cQuery += " SELECT *													 						"
	_cQuery += " FROM " + RetSQLName("SC0")+"														"		    
	_cQuery += " WHERE C0_FILIAL 		= "+ ValToSQL(xFilial("SC0"))+"								"
	_cQuery += " AND C0_SOLICIT			= '"+_cSolicit+"'											"
	_cQuery += " AND C0_PRODUTO			= '"+_cProduto+"'											"
	_cQuery += " AND C0_LOTECTL	 		= '"+_cLote+"'												"
		
	If (_cEmp == '07')
		_cQuery += " AND C0_YPITORI	 		= '"+_cPedido+_cItem+"' 								"	
	Else
		_cQuery += " AND C0_YPEDIDO	= '"+_cPedido+"'				 								"	
		_cQuery += " AND C0_YITEMPV	= '"+_cItem+"'			 										"	
	EndIf
	_cQuery += " AND C0_YTEMP	= 'S'				 												"	
					
	_cQuery += " AND D_E_L_E_T_ = ''		 														"
	
	conout(_cQuery)
	
	TcQuery _cQuery New Alias (_cAliasTemp)

	If (!(_cAliasTemp)->(Eof()))
		 _nQuant := (_cAliasTemp)->C0_QUANT
	EndIf

	(_cAliasTemp)->(DbCloseArea())
	
	RestArea(_aArea)
Return _nQuant


User Function GDRESPRO(_cNRESER, _cProd, _nQuant, _cTipo, _cDocRes)

	Local _cQuery			:= ""
	Local _cAliasTemp		:= Nil
	Local _aArea			:= Nil
	Local _aRet				:= {"", "", "", "", ""}
	Default _cTipo			:= 'CL'
	Default _cDocRes		:= 'SILVER'
	
	_cAliasTemp		:= GetNextAlias()
	_aArea			:= GetArea()
					
	_cQuery += " SELECT C0_PRODUTO, C0_QUANT, C0_LOTECTL, C0_LOCALIZ, C0_LOCAL 						"
	_cQuery += " FROM " + RetSQLName("SC0")+"														"		    
	_cQuery += " WHERE C0_FILIAL 		= "+ ValToSQL(xFilial("SC0"))+"								"
	_cQuery += " AND C0_TIPO			= '"+_cTipo+"'												"
	_cQuery += " AND C0_DOCRES			= '"+_cDocRes+"'											"
	_cQuery += " AND C0_NUM		 		= '"+_cNRESER+"' 											"
	_cQuery += " AND C0_PRODUTO	 		= '"+_cProd+"' 												"
	_cQuery += " AND C0_QUANT 			>= '"+cvaltochar(_nQuant)+"' 								"
	_cQuery += " AND C0_LOCALIZ 		NOT IN ('AMT') 												"
	_cQuery += " AND D_E_L_E_T_ 		= '' 														"
	
	TcQuery _cQuery New Alias (_cAliasTemp)

	If (!(_cAliasTemp)->(Eof()))
		   _aRet := {;
		   			(_cAliasTemp)->C0_PRODUTO,; 
		   			(_cAliasTemp)->C0_LOTECTL,; 
		   			(_cAliasTemp)->C0_QUANT,;
		   			(_cAliasTemp)->C0_LOCALIZ,;
		   			(_cAliasTemp)->C0_LOCAL;
		   			}
	EndIf

	(_cAliasTemp)->(DbCloseArea())
	
	RestArea(_aArea)
Return _aRet

//existe produto com DFRA na politica comercial ativa 
User Function PRPCDFRA(_cCliLoja, _cVend, _cData, _cProd, _cLote)
	
	Local _lRet 			:= .F.
	Local _cQuery			:= ""
	Local _cAliasTemp		:= GetNextAlias()
	Local _aArea			:= GetArea()
	
	
	_cQuery += " SELECT TOP 1 ATIVO=[dbo].[CHECK_ATIVO_DFRA_POLITICA_DATA_01] 							"
	_cQuery += " ('01', '"+_cCliLoja+"', '"+_cVend+"', '"+_cProd+"', '"+_cLote+"' , '"+_cData+"')		"
	
	
	/*_cQuery += " SELECT TOP 1 ZA0_PDESC FROM ZA0010													"		    
	_cQuery += " WHERE ZA0_FILIAL 		= "+ ValToSQL(xFilial("ZA0"))+"								"
	_cQuery += " AND ZA0_TIPO			= 'DFRA'													"
	_cQuery += " AND ZA0_CODPRO			= '"+_cProd+"'												"
	_cQuery += " AND ZA0_VIGINI 		<= '"+_cData+"' and ZA0_VIGFIM >= '"+_cData+"'				"
	_cQuery += " AND ZA0_STATUS 		= 'A' 														"
	_cQuery += " AND D_E_L_E_T_ 		= '' 														"
	_cQuery += " ORDER BY ZA0_MARCA																	"
	*/
	
	Conout(_cQuery)
	
	TcQuery _cQuery New Alias (_cAliasTemp)

	If !((_cAliasTemp)->(Eof())) .And. (_cAliasTemp)->ATIVO == 'S'
		_lRet := .T.
	EndIf

	(_cAliasTemp)->(DbCloseArea())
	
	RestArea(_aArea)
	
Return _lRet


