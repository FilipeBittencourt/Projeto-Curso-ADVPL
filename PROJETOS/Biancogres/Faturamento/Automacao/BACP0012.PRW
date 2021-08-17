#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BACP0012
@author Gabriel Rossi Mafioletti
@since 05/09/2019
@version 1.0
@description Processo de Entrada / Distribuicao e Liberacao de Pedidos LM
@type function
/*/

User Function BACP0012()

	Local xv_Emps
	Local nI

	RpcSetEnv('01','01')

	xv_Emps := U_BAGtEmpr("01_05_13_14")

	RpcClearEnv()

	RpcSetEnv("07","01")

	//Parametro para desligar os Jobs Automaticos em caso de Necessidade
	If U_GETBIAPAR("BIA_FATAUTO", .T. , cEmpAnt, cFilAnt)

		For nI := 1 To Len(xv_Emps)
			
			If U_GETBIAPAR("BIA_FATAUTO", .T. , xv_Emps[nI,1], xv_Emps[nI,2])
			
				fProcessa(xv_Emps[nI,1], xv_Emps[nI,2])
			
			Else
			
				ConOut("BACP0014 ==> Cancelado/Desligado[BIA_FATAUTO] - " + Time()+" => Empresa: "+xv_Emps[nI,1]+" Filial: "+xv_Emps[nI,2])
			
			EndIf
			
		Next nI

	Else

		ConOut("BACP0014 ==> Cancelado/Desligado[BIA_FATAUTO] - " + Time()+" => Empresa: "+cEmpAnt+" Filial: "+cFilAnt)

	EndIf

	RpcClearEnv()

Return()

Static Function fProcessa(_cEmp,_cFil)

	Local _cAlias	:=	GetNextAlias()

	Local _cFornece		
	Local _cEntid
	Local _cSF2
	Local _cSD2
	Local _cSC9
	Local _cZZV

	Local _cDoc		:= ""
	Local _cSerie	:= ""
	Local _cCliente	:= ""
	Local _cLoja	:= ""
	Local _cTesD1	:= ""
	Local aCabNF	:= {}
	Local aItem		:= {}
	Local aItens	:= {}
	Local _cItem	:=	"01"
	Local _cLogTxt	:=	""

	Local _aPedLib	:=	{}

	Private lMsErroAuto		:=	.F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

	Private _cEmpPed		:= _cEmp

	Do Case
	
		Case (_cEmp == '01' .And. _cFil == '01')
		
		_cFornece	:=	'000534'
		_cEntid		:=	"000001"
		_cSF2		:=	"%SF2010%"
		_cSD2		:=	"%SD2010%"
		_cSC9		:=  "%SC9010%"
		_cZZV		:=  "%ZZV010%"

		Case (_cEmp == '05' .And. _cFil == '01')
		
		_cFornece	:=	'002912'
		_cEntid		:=	"000002"
		_cSF2		:=	"%SF2050%"
		_cSD2		:=	"%SD2050%"
		_cSC9		:=  "%SC9050%"
		_cZZV		:=  "%ZZV050%"

		Case (_cEmp == '13' .And. _cFil == '01')
		
		_cFornece	:=	'004695'
		_cEntid		:=	"000009"
		_cSF2		:=	"%SF2130%"
		_cSD2		:=	"%SD2130%"
		_cSC9		:=  "%SC9130%"
		_cZZV		:=  "%ZZV130%"

		Case (_cEmp == '14' .And. _cFil == '01')
		
		_cFornece	:=	'003721'
		_cEntid		:=	"000011"
		_cSF2		:=	"%SF2140%"
		_cSD2		:=	"%SD2140%"
		_cSC9		:=  "%SC9140%"
		_cZZV		:=  "%ZZV140%"		

		OtherWise
		
		ConOut('BACP0012::Empresa/Filial não Cadastrada... '+_cEmp+'/'+_cFil+' - '+ Time())
		
		Return
		
	EndCase

	ConOut('BACP0012::Iniciando... '+_cEmp+'/'+_cFil+' - '+ Time())

	SB1->(dbSetOrder(1))

	BeginSql Alias _cAlias
	
		%NoParser%	

		SELECT
			D2_LOCAL,
			F2_COND, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_EMISSAO, D2_COD, D2_QUANT, 
			D2_PRCVEN, D2_TOTAL, D2_LOTECTL, D2_DTVALID, D2_PEDIDO, D2_ITEMPV, DOC_CHV CHAVE

		FROM %Exp:_cSF2% SF2 (NOLOCK)

		JOIN %Exp:_cZZV% ZZV (NOLOCK) ON
		(
			ZZV_FILIAL 			= SF2.F2_FILIAL
			AND ZZV_CARGA 		= SubString(SF2.F2_YAGREG, 5, 4)
			AND ZZV_CARGA 		<> ''
			AND ZZV.D_E_L_E_T_	= ''
		)
		
		JOIN %Exp:_cSD2% SD2 (NOLOCK) ON 
		(
			SD2.D2_FILIAL 		= SF2.F2_FILIAL
			AND SD2.D2_DOC 		= SF2.F2_DOC
			AND SD2.D2_SERIE 	= SF2.F2_SERIE
			AND SD2.D2_CLIENTE 	= SF2.F2_CLIENTE
			AND SD2.D2_LOJA 	= SF2.F2_LOJA
			AND SD2.D_E_L_E_T_	= ''
		)
		
		JOIN SPED050 SPED(NOLOCK) ON 
		(
			SPED.ID_ENT 		= %Exp:_cEntid%
			AND SPED.NFE_ID 	= SF2.F2_SERIE + SF2.F2_DOC
			AND SPED.STATUS 	= 6
			AND SPED.D_E_L_E_T_	= ''
		)
		
		WHERE SF2.F2_FILIAL = %Exp:_cFil%
		AND SF2.F2_ESPECIE 	= 'SPED'
		AND SF2.F2_TIPO 	= 'N'
		AND SF2.F2_CLIENTE 	= '010064'
		AND SF2.F2_EMISSAO 	>= '20191101'
		AND SF2.D_E_L_E_T_	= ''

		AND NOT EXISTS
		(		
			SELECT 1 
			FROM %Exp:_cSD2% SD2X (NOLOCK) 
			WHERE SD2X.D2_FILIAL 	= SF2.F2_FILIAL
			AND SD2X.D2_DOC 		= SF2.F2_DOC
			AND SD2X.D2_SERIE 		= SF2.F2_SERIE
			AND SD2X.D2_CLIENTE 	= SF2.F2_CLIENTE
			AND SD2X.D2_LOJA		= SF2.F2_LOJA
			AND SD2X.D2_QTDEDEV 	> 0
			AND SD2X.D_E_L_E_T_		= ''
		) 

		AND NOT EXISTS 
		(
			SELECT 1
			FROM SD1070 SD1 (NOLOCK)
			WHERE SD1.D1_FILIAL = SD2.D2_FILIAL
			AND SD1.D1_DOC 		= SD2.D2_DOC
			AND SD1.D1_SERIE 	= SD2.D2_SERIE
			AND SD1.D1_FORNECE 	= %Exp:_cFornece%
			AND SD1.D1_LOJA 	= '01'
			AND SD1.D1_TIPO 	= 'N'
			AND SD1.D_E_L_E_T_	= ''
		)

		AND NOT EXISTS 
		(
			SELECT 1
			FROM %Exp:_cSC9% SC9 (NOLOCK)
			WHERE SC9.C9_AGREG = SubString(SF2.F2_YAGREG, 5, 4)
			AND SC9.C9_NFISCAL = ''
			AND SC9.D_E_L_E_T_ = ''
		)

		AND NOT EXISTS 
		(
			SELECT 1
			FROM SD1070 SD1 (NOLOCK)
			WHERE SD1.D1_FILIAL = SD2.D2_FILIAL
			AND SD1.D1_DOC 		= SD2.D2_DOC
			AND SD1.D1_SERIE 	= SD2.D2_SERIE
			AND SD1.D1_FORNECE 	= %Exp:_cFornece%
			AND SD1.D1_LOJA 	= '01'
			AND SD1.D1_TIPO 	= 'N'
			AND SD1.D_E_L_E_T_	= '*'
		)
		
		ORDER BY
			SD2.D2_FILIAL,
			SD2.D2_DOC,
			SD2.D2_SERIE,
			SD2.D2_CLIENTE,
			SD2.D2_LOJA,
			SD2.D2_ITEM

	EndSql	

	If (_cAlias)->(!EOF())
	
		While (_cAlias)->(!EOF())

			If _cDoc+_cSerie+_cCliente+_cLoja <> (_cAlias)->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)

				If !Empty(_cDoc+_cSerie+_cCliente+_cLoja)

					IF !ExecNFE(_cEmp, _cFil, _cDoc, _cSerie, _cFornece, aCabNF, aItens, _aPedLib)

						ConOut('BACP0012::Nota ' + _cDoc+'/'+_cSerie + ' ERRO DISTLM - ATENCAO!!!!!!!!!!!!!!!!' +_cEmp+'/'+_cFil+' - '+ Time())
						//Return
					EndIf

				EndIf

				aCabNf	:=	{}
				
				aAdd(aCabNF,{"F1_TIPO"    , "N"            					, NIL, Nil})
				aAdd(aCabNF,{"F1_FORMUL"  , "N"             				, NIL, Nil})
				aAdd(aCabNF,{"F1_ESPECIE" , "SPED"			 				, NIL, Nil})

				SE4->(DbSetOrder(1))
				SE4->(DbSeek(xFilial("SE4")+(_cAlias)->F2_COND))

				If Alltrim(SE4->E4_TIPO) <> '9'
				
					aAdd(aCabNF,{"F1_COND" , (_cAlias)->F2_COND		 		, NIL, Nil})
					
				Else
				
					aAdd(aCabNF,{"F1_COND" , "056"					 		, NIL, Nil})
					
				EndIf

				aAdd(aCabNF,{"F1_COND" , (_cAlias)->F2_COND			 		, NIL, Nil})
				aAdd(aCabNF,{"F1_DOC"     , (_cAlias)->D2_DOC				, NIL, Nil})
				aAdd(aCabNF,{"F1_SERIE"   ,	(_cAlias)->D2_SERIE	 			, NIL, Nil})
				aAdd(aCabNF,{"F1_EMISSAO" , STOD((_cAlias)->D2_EMISSAO)		, NIL, Nil})
				aAdd(aCabNF,{"F1_FORNECE" , _cFornece			   			, NIL, Nil})
				aAdd(aCabNF,{"F1_LOJA"    , "01"				  			, NIL, Nil})
				aAdd(aCabNF,{"F1_CHVNFE"    , (_cAlias)->CHAVE				, NIL, Nil})

				_cItem	:=	"01"
				aItens	:=	{}
				_aPedLib	:=	{}

				_cDoc	:=	(_cAlias)->D2_DOC
				_cSerie	:=	(_cAlias)->D2_SERIE
				_cCliente	:=	(_cAlias)->D2_CLIENTE
				_cLoja	:=	(_cAlias)->D2_LOJA

			EndIf

			aItem := {}

			_cTesD1 := "0A2"	
					
			If SB1->(dbSeek(xFilial("SB1")+(_cAlias)->D2_COD)) .And. AllTrim(SB1->B1_GRTRIB) == "003"
			
				_cTesD1 := "0A4"
				
			EndIf

			aAdd(aItem,{"D1_ITEM" 		, _cItem								, NIL, Nil})
			aAdd(aItem,{"D1_COD" 		, (_cAlias)->D2_COD     				, NIL, Nil})
			aAdd(aItem,{"D1_DOC"    	, (_cAlias)->D2_DOC     				, Nil, Nil})
			aAdd(aItem,{"D1_SERIE"    	, (_cAlias)->D2_SERIE      				, Nil, Nil})
			aAdd(aItem,{"D1_FORNECE"	,  _cFornece      						, Nil, Nil})
			aAdd(aItem,{"D1_LOJA"    	, "01"     								, Nil, Nil})
			aAdd(aItem,{"D1_TES"    	, _cTesD1  								, Nil, Nil}) //Provisório
			aAdd(aItem,{"D1_QUANT"    	, (_cAlias)->D2_QUANT  					, Nil, Nil})
			aAdd(aItem,{"D1_VUNIT"    	, (_cAlias)->D2_PRCVEN   				, Nil, Nil})
			aAdd(aItem,{"D1_TOTAL"    	, (_cAlias)->D2_TOTAL   				, Nil, Nil})
			aAdd(aItem,{"D1_LOTECTL"    , (_cAlias)->D2_LOTECTL   				, Nil, Nil})
			aAdd(aItem,{"D1_DTVALID"    , Stod((_cAlias)->D2_DTVALID)   		, Nil, Nil})
			
			If(!Empty((_cAlias)->D2_LOCAL))
				aAdd(aItem,{"D1_LOCAL"    , (_cAlias)->D2_LOCAL		   				, Nil, Nil})
			EndIf
			
			aAdd(aItens,aItem)

			(_cAlias)->(aAdd(_aPedLib,{D2_PEDIDO, D2_ITEMPV,D2_QUANT,D2_LOTECTL}))

			_cItem	:=	Soma1(_cItem)

			(_cAlias)->(DbSkip())
			
		EndDo

		IF ( Len(aItens) > 0 )

			IF !ExecNFE(_cEmp, _cFil, _cDoc, _cSerie, _cFornece, aCabNF, aItens, _aPedLib)
			
				ConOut('BACP0012::Nota ' + _cDoc+'/'+_cSerie + ' ERRO DISTLM - ATENCAO!!!!!!!!!!!!!!!!' +_cEmp+'/'+_cFil+' - '+ Time())
				//Return
			EndIf

		EndIf

	Else
	
		ConOut('BACP0012::Não há notas a serem geradas... '+_cEmp+'/'+_cFil+' - '+ Time())
		
	EndIf

	(_cAlias)->(DbCloseArea())

	ConOut('BACP0012::Finalizando... '+_cEmp+'/'+_cFil+' - '+ Time())

Return()

Static Function ExecNFE(_cEmp, _cFil, _cDoc, _cSerie, _cFornece, aCabNF, aItens, _aPedLib)

	Local _aAutoErro
	Local _cLogTxt
	Local cErro
	Local bErro := ErrorBlock( { |oErr| cErro := oErr:Description })

	Private lMsErroAuto

	BEGIN SEQUENCE
	
		Begin Transaction
		
			lMsErroAuto	:=	.F.

			MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabNF,aItens,3,.T.)

			If !lMsErroAuto

				ConOut('BACP0012::Nota ' + _cDoc+'/'+_cSerie + ' Gerada com Sucesso!' +_cEmp+'/'+_cFil+' - '+ Time())
				ConOut('BACP0012::Nota ' + _cDoc+'/'+_cSerie + ' - Iniciado processo de distribuicao!' +_cEmp+'/'+_cFil+' - '+ Time())

				If !fDistribui(_cDoc,_cSerie,_cFornece,'01')

					ConOut('BACP0012::Nota ' + _cDoc+'/'+_cSerie + ' - Com falha no processo de distribuicao!' +_cEmp+'/'+_cFil+' - '+ Time())
					DisarmTransaction()
					Return(.F.)

				Else

					ConOut('BACP0012::Nota ' + _cDoc+'/'+_cSerie + ' - Distribuição concluida!' +_cEmp+'/'+_cFil+' - '+ Time())
					ConOut('BACP0012::Nota ' + _cDoc+'/'+_cSerie + ' - Iniciando Liberacao de pedidos!' +_cEmp+'/'+_cFil+' - '+ Time())

					If !fLibPed(_aPedLib)

						ConOut('BACP0012::Nota ' + _cDoc+'/'+_cSerie + ' - Com falha no processo de liberacao de pedidos!' +_cEmp+'/'+_cFil+' - '+ Time())
						DisarmTransaction()
						Return(.F.)

					Else

						ConOut('BACP0012::Nota ' + _cDoc+'/'+_cSerie + ' - Liberacao de Pedidos concluida!' +_cEmp+'/'+_cFil+' - '+ Time())

					EndIf

				EndIf

			Else

				_aAutoErro := GETAUTOGRLOG()

				_cLogTxt	:=	""
				
				If Len(_aAutoErro) > 0
				
					_cLogTxt += U_XCONVELOG(_aAutoErro)
					
				EndIf
				
				ConOut('BACP0012::Erro ao gerar a nota ' + _cDoc+'/'+ _cSerie + ' - ' + _cLogTxt +_cEmp+'/'+_cFil+' - '+ Time())
				
				DisarmTransaction()
				
				Return(.F.)

			EndIf

		End Transaction	
		
	END SEQUENCE
	
	ErrorBlock( bErro )

	If ValType(cErro) <> "U"

		ConOut('BACP0012::EXCEPTION ao gerar a nota ' + _cDoc+'/'+ _cSerie + ' ==> ' + cErro )
		
		DisarmTransaction()
		
		Return(.F.)

	EndIf

Return(.T.)

Static Function fDistribui(_cDoc,_cSerie,_cCli,_cLoja)

	Local _lRet		:=	.T.
	Local _cLogTxt	:=	""
	Local _cAlias	:=	GetNextAlias()
	Local aCabSDA
	Local aItSDB
	Local _aItensSDB
	Local aAutoErro

	BEGINSQL ALias _cAlias
	
		%NoParser%

		SELECT *
		FROM %TABLE:SDA% SDA (NOLOCK)
		WHERE SDA.DA_FILIAL = %xFILIAL:SDA%
		AND SDA.DA_ORIGEM 	= 'SD1'
		AND SDA.DA_DOC 		= %Exp:_cDoc%
		AND SDA.DA_SERIE 	= %Exp:_cSerie%
		AND SDA.DA_CLIFOR 	= %Exp:_cCli%
		AND SDA.DA_LOJA 	= %Exp:_cLoja%
		AND SDA.DA_TIPONF 	= 'N'
		AND SDA.%NotDel%

	EndSql


	If (_cAlias)->(!EOF())
	
		While (_cAlias)->(!EOF())

			aCabSDA    := {}
			aItSDB     := {}
			_aItensSDB := {}
			
			aCabSDA := {{"DA_PRODUTO" , (_cAlias)->DA_PRODUTO	, Nil},;
						{"DA_NUMSEQ"  , (_cAlias)->DA_NUMSEQ	, Nil} }

			aItSDB := {	{"DB_ITEM"     , "0001"                 , Nil},;
						{"DB_ESTORNO"  , " "                    , Nil},;
						{"DB_LOCALIZ"  , "LM"                 	, Nil},;
						{"DB_DATA"     , Date()					, Nil},;
						{"DB_QUANT"    , (_cAlias)->DA_SALDO	,Nil} }  

			aadd(_aItensSDB,aitSDB)
			
			MATA265( aCabSDA, _aItensSDB, 3)

			If lMsErroAuto

				//Grava log de erro para consulta posterior
				aAutoErro := GETAUTOGRLOG()
				
				_cLogTxt	:=	""
				
				If Len(_aAutoErro) > 0
				
					_cLogTxt += U_XCONVELOG(_aAutoErro)
					
				EndIf


				ConOut('BACP0012::Distribuicao - ERRO: ' +_cLogTxt)
				
				_lRet	:=	.F.
				
				Exit
				
			Else
			
				ConOut('BACP0012::Distribuicao - Produto ' + (_cAlias)->DA_PRODUTO + " Distribuído com Sucesso!")
			
			EndIf
			
			(_cAlias)->(dbSkip())
			
		EndDo
		
	Else
	
		ConOut('BACP0012::Distribuicao - ERRO: Nao foram encontrados registros' )
	
		_lret	:=	.F.
	
	EndIf
	
Return(_lRet)

Static Function fLibped(_aPedLib)

	Local _nI		:=	0
	Local _lret		:=	.T.
	Local _nQtd2
	Local _nQtdLib
	Local lCredito 	:= .T.
	Local lEstoque	:= .T.
	Local lAvalCred	:= .T.
	Local _cAlias
	Local _cPedido	:=	""


	If Len(_aPedlib) == 0
	
		ConOut('BACP0012::Liberacao de Pedidos - Nao existem itens a distribuir!')	
		
		_lRet	:=	.F.
		
	Else

		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))

		DbSelectArea("SC9")
		SC9->(DbSetOrder(1)) // C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_

		For _nI	:=	1 to Len(_aPedLib)

			_cAlias	:=	GetNextAlias()

			BeginSql Alias _cAlias
				%NoParser%

				SELECT TOP 1 C5_NUM
				FROM %TABLE:SC5% (NOLOCK)
				WHERE C5_FILIAL = %XFILIAL:SC5%
				AND C5_YEMPPED = %Exp:_cEmpPed%
				AND C5_YPEDORI = %Exp:_aPedLib[_nI,1]%
				AND %NotDel%

			EndSql

			If (_cAlias)->(!EOF())

				_cPedido	:=	(_cAlias)->C5_NUM

				If SC6->(DbSeek(xFilial("SC6")+_cPedido+_aPedLib[_ni,2]))

					RecLock("SC6",.F.)
					SC6->C6_LOTECTL := _aPedLib[_ni,4]
					SC6->C6_LOCALIZ := "LM"
					SC6->(MsUnlock())

					_nQtd2		:=	ConvUM(SC6->C6_PRODUTO, _aPedLib[_nI,3], 0, 2)

					_nQtdLib	:= MaLibDoFat(SC6->(RecNo()),_aPedLib[_nI,3],@lCredito,@lEstoque,lAvalCred,.T.,.F.,.F.,NIL,NIL,NIL,NIL,NIL,NIL,_nQtd2)

					If _nQtdLib	<> _aPedlib[_nI,3]

						ConOut('BACP0012::Liberacao de Pedidos - Pedido/Item '+_cPedido+'/'+_aPedLib[_nI,2]+' não liberado integralmente ! -> _nQtdLib = ' + cValToChar(_nQtdLib) + " | _aPedlib[_nI,3] = " + cValToChar(_aPedlib[_nI,3]) + " | " + "C6_BLQ = " + SC6->C6_BLQ + " | C6_BLOQUEI = " + SC6->C6_BLOQUEI )
						
						_lRet	:=	.F.
						
						Exit

					Else

						If SC9->(DBSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM))

							While SC9->(!EOF()) .And. SC9->(C9_FILIAL + C9_PEDIDO + C9_ITEM) == SC6->(C6_FILIAL + C6_NUM + C6_ITEM)

								If Empty(SC9->C9_NFISCAL)

									ConOut('BACP0012::Liberacao de Pedidos - Pedido/Item '+_cPedido+'/'+_aPedLib[_nI,2] + "/" + SC9->C9_SEQUEN + " SC9 -> " + "C9_BLCRED = " + SC9->C9_BLCRED + " | C9_BLOQUEI = " + SC9->C9_BLOQUEI + " | C9_BLEST = " + SC9->C9_BLEST )

								EndIf

								SC9->(DBSkip())

							EndDo

						Else

							ConOut('BACP0012::Liberacao de Pedidos - Pedido/Item '+_cPedido+'/'+_aPedLib[_nI,2]+' SC9 retornou liberacao mas foi não encontrado o registro !')

						EndIf

					EndIf

				Else
					
					ConOut('BACP0012::Liberacao de Pedidos - Pedido/Item '+_cPedido+'/'+_aPedLib[_nI,2]+' não encontrado !')	
					
					_lRet	:=	.F.
					
					Exit
					
				EndIf
				
			Else
			
				ConOut('BACP0012::Liberacao de Pedidos - Pedido '+_aPedLib[_nI,1]+' não possui correspondente na LM !')
				
				_lret	:=	.F.
				
				Exit
				
			EndIf

			(_cAlias)->(DbCloseArea())

		Next _nI	

	EndIf

Return(_lret)
