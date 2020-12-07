#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#include "RWMAKE.CH"

User Function BIARO004()
	
	//Local xv_Emps := U_BAGtEmpr("01_05_07_12_13_") // --> PERGUNTAR QUAIS EMPRESAS PODERÃO SER CONFERÊNCIA A CEGAS 
	Local xv_Emps := U_BAGtEmpr("01_") // --> PERGUNTAR QUAIS EMPRESAS PODERÃO SER CONFERÊNCIA A CEGAS
	Local x
	
	For x := 1 to Len(xv_Emps)
		
		//Inicializa o ambiente
		RPCSetType(3)		
		WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])	
		ConOut("Hora: "+TIME()+" - Iniciando a Integração PROTHEUS x BIZAGI para o Processo Conferência a Cegas - " + xv_Emps[x,1])		
		Processa({|| BIARO004() })		
		ConOut("Hora: "+TIME()+" - Finalizando a Integração PROTHEUS x BIZAGI para o Processo Conferência a Cegas - " + xv_Emps[x,1])	
		//Finaliza o ambiente criado
		RpcClearEnv()

	Next

Return()

//--------------------------------------------------------------------------
// Executa a função que contém as regras de integração do Processo Conferência a Cegas
//--------------------------------------------------------------------------
Static Function BIARO004()

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
	cSQL += "AND PROCESSO_NOME = 'RM' "
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
					
	End			

	cSQL->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())		

Return

//--------------------------------------------------------------------------
// Executa a função que contém as regras de integração do Processo Conferência a Cegas
//--------------------------------------------------------------------------
Static Function vRetBz(cDadosEntrada, cId)

	Local cChave := ""
	Local cNF :=  ""
	Local cSerie :=  ""
	Local cFornecedor :=  ""
	Local cFornecedorCNPJ :=  ""
	Local cMaterialRecebido :=  ""
	Local cMotivoRecusa :=  ""
	Local aDadosEntrada := {}
	
	Local cSqlF1 := ""
	Local cRecnoF1 := ""
	Local _lRetF1
	Local cUpdF1 := ""	
	Local cSqlD1 := ""
	Local cRecnoD1 := ""
	Local _lRetD1
	Local cUpdD1 := ""
		
	Local _lRetBzIntegracao	
	Local cUpdBzIntegracao := ""
	
	Local _Ret := .F.
			
	/* 
	ORDEM DOS PARAMETROS:
	1. CHAVE;	
	2. NUMERO NOTA FISCAL;
	3. SERIE NOTA FISCAL;
	4. FORNECEDOR;
	5. FORNECEDOR CNPJ;
	6. MATERIAL RECEBIDO;
	7. MOTIVO DA RECUSA;
	8. [ITEM, PRODUTO, MATERIALCONFERIDO] /*ITENS NOTA FISCAL*/
	*/
	
	aDadosEntrada := fDados(cDadosEntrada,8,8)

	cChave := aDadosEntrada[1][1]
	cNF := aDadosEntrada[1][2]
	cSerie := aDadosEntrada[1][3]
	cFornecedor := aDadosEntrada[1][4]
	cFornecedorCNPJ := aDadosEntrada[1][5]
	cMaterialRecebido := aDadosEntrada[1][6]
	cMotivoRecusa := aDadosEntrada[1][7]
	
	cChave := "42190586981966000172550020001219661115212350"
		
	BEGIN TRANSACTION	
		
	cSqlF1 := ""
	cSqlF1 += " SELECT R_E_C_N_O_ AS 'RECNO', F1_YFLAGBZ AS 'FLAG', F1_YPROCBZ AS 'BIZAGI', F1_CHVNFE AS 'CHAVENFE'"
	cSqlF1 += " FROM "+RetSqlName("SF1") 
	cSqlF1 += " WHERE F1_CHVNFE = '" + cChave + "' "	
	cSqlF1 += " AND D_E_L_E_T_ = '' AND F1_YFLAGBZ = 'R' "
		
	cRecnoF1 := fRecRecno(cSqlF1)
		
	/* F1_YFLAGBZ = R (REGISTRADO) - F1_YFLAGBZ = C (CONFERIDO) */
	cUpdF1 := " UPDATE "+RetSqlName("SF1")+" SET F1_YFLAGBZ = 'C' WHERE R_E_C_N_O_ IN (" + cRecnoF1 + ")"	
	
	_lRetF1 := TcSqlExec(cUpdF1)	

	If _lRetF1 < 0				
		DisarmTransaction()		
		MsgInfo("Erro no processo de integração PROTHEUS x BIZAGI. Favor procurar a TI. (Atualização SF1 - ID Integracao : " + cId + ") - Erro : " + TCSQLError())											
	Else	
		
		cSqlD1 := ""
		cSqlD1 += " SELECT D1.R_E_C_N_O_ AS 'RECNO', D1_YFLAGBZ AS 'FLAG', D1_YPROCBZ AS 'BIZAGI', D1_COD AS 'PRODUTO' " 
		cSqlD1 += " FROM "+RetSqlName("SD1")+" D1 WITH (NOLOCK) "
		cSqlD1 += " INNER JOIN "+RetSqlName("SF1")+" F1 WITH (NOLOCK) ON F1.F1_FILIAL = D1.D1_FILIAL " 
		cSqlD1 += "                   AND F1.F1_DOC = D1.D1_DOC "
		cSqlD1 += "                   AND F1.F1_SERIE = D1.D1_SERIE " 
		cSqlD1 += "                   AND F1.F1_FORNECE = D1.D1_FORNECE " 
		cSqlD1 += "                   AND F1.F1_LOJA = D1.D1_LOJA "
		cSqlD1 += "                   AND F1.D_E_L_E_T_ = '' " 
		cSqlD1 += " WHERE F1.F1_CHVNFE = '" + cChave + "' AND F1.D_E_L_E_T_ = ''"		
	
		cRecnoD1 := fRecRecno(cSqlD1)
	
		/* D1_YFLAGBZ = R (REGISTRADO) - D1_YFLAGBZ = C (CONFERIDO) */
		cUpdD1 += " UPDATE "+RetSqlName("SD1")+" SET D1_YFLAGBZ = 'C' WHERE R_E_C_N_O_ IN (" + cRecnoD1 + ")"	
		
		// RECUPERAR LISTA DE RECNOS SD1		
		_lRetD1 := TcSqlExec(cUpdD1)
	
		If _lRetF1 < 0
			DisarmTransaction()	
			MsgInfo("Erro no processo de integração PROTHEUS x BIZAGI. Favor procurar a TI. (Atualização SD1 - ID Integracao : " + cId + ") - Erro : " + TCSQLError(),"Falha na Integração entre Sistemas")
		Else						
			cUpdBzIntegracao += " UPDATE BZINTEGRACAO SET "
			cUpdBzIntegracao += " DATA_INTEGRACAO_PROTHEUS = FORMAT(GETDATE(),'yyyy-MM-dd HH:mm:ss') "
			cUpdBzIntegracao += " , STATUS = 'AP' "
			cUpdBzIntegracao += " , DADOS_RETORNO = '' "
			cUpdBzIntegracao += " , RECNO_RETORNO = '{F1," + cRecnoF1 + "};{D1," + cRecnoD1 + "}' "
			cUpdBzIntegracao += " WHERE ID = " + cId
							
			_lRetBzIntegracao := TcSqlExec(cUpdBzIntegracao)
		
			If _lRetBzIntegracao < 0
				DisarmTransaction()	
				MsgInfo("Erro no processo de integração PROTHEUS x BIZAGI. Favor procurar a TI. (Atualização SD1 - ID Integracao : " + cId + ") - Erro : " + TCSQLError(),"Falha na Integração entre Sistemas")	
			EndIf
			
			_Ret := .T.
			
		EndIf			
	EndIf

	////// RETIRAR ESTE CODIGO - APENAS TESTE
	DisarmTransaction()

	END TRANSACTION

Return _Ret

Static Function fRecRecno(_csql)
	
	Local cRecno := ""
	
	cSqlRecno := _csql;
	
	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlRecno),'cSqlRecno',.F.,.T.)
	dbSelectArea("cSqlRecno")
	dbGoTop()
	ProcRegua(RecCount())
	
	While !Eof()			
		IncProc()					
		cRecno += cValToChar(cSqlRecno->RECNO) + ","	 					
		
		dbSelectArea("cSqlRecno")
		dbSkip()				
	End
	
	cRecno := SubStr(cRecno, 1, (LEN(cRecno) - 1)) 
	
	cSqlRecno->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())
	
Return cRecno  

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