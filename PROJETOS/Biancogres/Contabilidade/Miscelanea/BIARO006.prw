#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#include "RWMAKE.CH"

User Function BIARO006()
	
	Local xv_Emps := U_BAGtEmpr("01_05_07_12_13_") // --> PERGUNTAR QUAIS EMPRESAS PODERÃO SER SOLICITADA EMISSÃO DE NF DE SAÍDA 
	Local x
	
	For x := 1 to Len(xv_Emps)
		
		//Inicializa o ambiente
		RPCSetType(3)		
		WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])	
		ConOut("Hora: "+TIME()+" - Iniciando a Integração PROTHEUS x BIZAGI para o Processo de Emissão de NF de Saída - " + xv_Emps[x,1])		
		Processa({|| BIARO006() })		
		ConOut("Hora: "+TIME()+" - Finalizando a Integração PROTHEUS x BIZAGI para o Processo de Emissão de NF de Saída - " + xv_Emps[x,1])	
		//Finaliza o ambiente criado
		RpcClearEnv()

	Next

Return()

//--------------------------------------------------------------------------
// Executa a função que contém as regras de integração do Processo Emissão de NF de Saída
//--------------------------------------------------------------------------
Static Function BIARO006()

		Local GUcIndex 
		Local cSQL := ""
		cSQL += "SELECT "
		cSQL += "ID "
		cSQL += ",DATA_INTEGRACAO_BIZAGI "
		cSQL += ",DATA_INTEGRACAO_PROTHEUS "
		cSQL += ",STATUS "
		cSQL += ",DADOS_ENTRADA "
		cSQL += ",DADOS_RETORNO "
		cSQL += ",PROCESSO_BIZAGI "
		cSQL += ",RECNO_RETORNO "
		cSQL += ",EMPRESA "
		cSQL += ",FILIAL "
		cSQL += "FROM BZINTEGRACAO "
		cSQL += "WHERE STATUS IN ('IB') "
		cSQL += "AND PROCESSO_BIZAGI = 'SNF' "
		cSQL += "AND EMPRESA = '" + cEmpAnt + "' "
		cSQL += "AND FILIAL = '" + cFilAnt + "' "
		//cSQL += "AND EM_PROCESSAMENTO = '' "		
		
		GUcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'cSQL',.F.,.T.)
		dbSelectArea("cSQL")
		dbGoTop()
		ProcRegua(RecCount())
		
		While !Eof()	
			
			If !vRetBz(cSQL->DADOS_ENTRADA, cValToChar(cSQL->ID))	
				Loop
			EndIf	
											
			dbSelectArea("cSQL")
			dbSkip()	
			
		End
		
		vRetBz("999999;N;N;000005; ;[201A173|5|100.0000&201A173|5|100.0000&201A173|5|100.0000&201A173|5|100.0000&201A173|5|100.0000&201A173|5|100.0000];1000;1000;C;004976;2019-04-12 12:00:00;Administrador do Portal;Victor Bragatto Luchi;",0)
		
Return

//--------------------------------------------------------------------------
// Executa a função que contém as regras de integração do Processo Emissão de NF de Saída
//--------------------------------------------------------------------------
Static Function vRetBz(cDadosEntrada, cId)

	Local cVendedor := ""
	Local cTipoSaida :=  ""
	Local cTipoPedido :=  ""
	Local cCliente :=  ""
	Local cPedidoCompra :=  ""
	Local cClasseValor :=  ""
	Local cCentroCusto :=  ""`
	Local cFrete :=  ""`
	Local cTransportadora :=  ""`
	Local cDataSaidaMercadoria :=  ""`
	Local cSolicitante :=  ""`
	Local cAprovadoPor :=  ""`
		
	Local aDadosEntrada := {}

	Local _Ret := .F.

	/* 
	ORDEM DOS PARAMETROS:
	1. VENDEDOR
	2. TIPODESAIDA
	3. TIPODEPEDIDO
	4. CLIENTE
	5. PEDIDODECOMPRA
	6. [PRODUTO | QUANTIDADEPRODUTO | VALORPRODUTO]
	7. CLASSEDEVALOR
	8. CENTRODECUSTO
	9. FRETE
	10. TRANSPORTADORA
	11. DATADESAIDADAMERCADORIA
	12. SOLICITANTE
	13. AUTORIZADOPOR
	*/
	
	aDadosEntrada := fDados(cDadosEntrada,6,13)	

	cVendedor := aDadosEntrada[1][1]
	cTipoSaida := aDadosEntrada[1][2]
	cTipoPedido := aDadosEntrada[1][3]
	cCliente := aDadosEntrada[1][4]
	cPedidoCompra := aDadosEntrada[1][5]
	cClasseValor := aDadosEntrada[1][6]
	cCentroCusto := aDadosEntrada[1][7]
	cFrete := aDadosEntrada[1][8]
	cTransportadora := aDadosEntrada[1][9]
	cDataSaidaMercadoria := aDadosEntrada[1][10]
	cSolicitante := aDadosEntrada[1][11]
	cAprovadoPor := aDadosEntrada[1][12]
	
	//cChave := "42190586981966000172550020001219661115212350"
		
	BEGIN TRANSACTION		
	
	END TRANSACTION

Return _Ret

Static Function fDados(_cDados, _indexArray, _tamArray)

	Local _aRet	:=	{{},{}} //_aRet[1] - Cabeçalho / _aRet[2] - Itens
	Local _aDados	:=	{}
	Local _aItens	:=	{}
	Local _nI

	_aDados	:=	StrtoKArr(Alltrim(_cDados),";")

	For _nI:= 1 to _tamArray 
		aAdd(_aRet[1],_aDados[_nI])
	Next

	_aItens	:=	StrToKArr(REPLACE(REPLACE(_aDados[_indexArray],"[",""),"]",""),"&")

	For _nI	:=	1 to Len(_aItens)
		aAdd(_aRet[2],StrToKarr(_aItens[_nI],"|"))
	Next	
	
Return _aRet