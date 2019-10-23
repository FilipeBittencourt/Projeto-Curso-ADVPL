#INCLUDE 'TOTVS.CH'
#Include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*
@Title   : Ponto de entrada para incluir botões no cadastro do cliente
@Type    : FUN = Função
@Name    : MA030BUT
@Author  : Ihorran Milholi
@Date    : 21/05/2015
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
*/
User Function MA030BUT
	
	Local aButtons := {}
	Local cUserLog := SuperGetMV("MV_YCUSRLO",.F.,"FREDERICO/CREDITO1/ERICO/PENHA/Administrador")
	
	aAdd(aButtons,{"CLIENTE",{|| U_TkHistCli(2)},"Cons. Historico","Cons. Historico"})


	aAdd(aButtons,{"CLIENTE",{|| FWMsgRun(, {|| U_NEUROCLI(M->A1_COD,M->A1_LOJA)}, "Aguarde!", "Processando a rotina NEUROTECH...")},"NEUROTECH","NEUROTECH"})
	
	If !INCLUI
		//Função para reprocessar o saldo financeiro do cliente
		aAdd(aButtons,{"CLIENTE",{|| Processa({|| ReprocSaldo()},"Reprocessando Saldo do Cliente...")},"Reproc.Saldo","Reproc.Saldo"})
	EndIf
	
	aAdd(aButtons,{"CLIENTE",{|| Processa({|| ConCad()},"Consultando cadastro do Cliente...")},"Cons. Cadastro","Cons. Cadastro"})
	
	
	IF Alltrim(cUserName) $ cUserLog
		//Atendendo Chamado: 83795
		aAdd(aButtons,{"CLIENTE",{|| Processa({|| ConLog(xFilial("SA1") + M->A1_COD + M->A1_LOJA, "SA1")},"Consultando log de alterações...")},"Cons. Log","Cons. Log"})	
	End If
	
	/*
	If !ISBLIND()
		U_WhenCli()
	EndIf
	*/
	
Return aButtons

/*
@Title   : Função para reprocessar o saldo do cliente
@Type    : FUN = Função
@Name    : ReprocSaldo
@Author  : Ihorran Milholi
@Date    : 21/05/2015
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
*/
Static Function ReprocSaldo()
	
	Local oVIXA095 	:= VIXA095():New()
	
	If !INCLUI
		
		oVIXA095:cCliente	:= SA1->A1_COD
		oVIXA095:cLoja		:= SA1->A1_LOJA
		oVIXA095:lJob		:= .f.
		oVIXA095:cTabPadrao	:= RetSqlName("SA1")
		
		//Rotina para montar array com tabelas
		oVIXA095:MontaSA1Proc()
		oVIXA095:ProcessaSA1()
		
	EndIf
	
Return


/*
@Title   : Função para Consultar cliente na SEFAZ
@Type    : FUN = Função
@Name    : ReprocSaldo
@Author  : LeonardoR
@Date    : 08/12/2015
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
*/
Static Function ConCad()
	
	Local aDadosRet := {}
	
	If empty(M->A1_CGC) .OR. empty(M->A1_EST)
		Aviso("Consulta Cadastro","CNPJ/CFP e UF devem estar preenchidos!" ,{"Voltar"})
		Return
	Else
		aDadosRet := U_WsConCad(M->A1_CGC, M->A1_EST)
	EndIf
	
	If aDadosRet[1][2] != '111'
		Aviso("Erro Consulta",aDadosRet[1][2] + ' - ' + aDadosRet[2][2] ,{"Voltar"})
		return
	EndIf
	
	M->A1_CEP     := ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cCEP'})][2]
	M->A1_COD_MUN := substr(ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cCMUN'})][2],3,10)
	M->A1_END     := ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cXLGR'})][2]  + ', ' + ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cNRO'})][2]
	M->A1_NOME    := ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cXNOME'})][2]
	M->A1_BAIRRO  := ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cXBAIRRO'})][2]
	M->A1_INSCR   := ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cIE'})][2]
	M->A1_EST     := ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cUF'})][2]
	M->A1_DTNASC  := stod(STRTRAN(ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cDINIATIV'})][2],'-','' ))
	M->A1_CNAE    := ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cCNAE'})][2]
	
	cCSIT     := ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cCSIT'})][2]
	cDULTSIT := dtoc(stod(STRTRAN(ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'cDULTSIT'})][2],'-','' )))
	
	If type("ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'xCpl'})][2]") # 'U'
		M->A1_COMPLEM := ADADOSRET[aScan(ADADOSRET,{|x| x[1] == 'xCpl'})][2]
	EndIf
	
	If cCSIT == "0"
		Aviso("Consulta Cadastro","Cliente não habilitado!"+ Chr(13) + 'Data Situação Cadastral: '+ cDULTSIT + Chr(13) + 'Não será possível faturar para o mesmo até que seja resolvido sua pendência perante à SEFAZ!', {"Voltar"})
	EndIf
	
Return

/*
@Title   : Função para Consultar log de cliente na tabela SXP protheus, log padrao.
@Type    : FUN = Função
@Name    : ConLog
@Author  : Henry de Almeida Woelffel - Brasoft
@Date    : 17/02/2016
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
*/
Static Function ConLog(_cCodUnico, _cAlias)
	
	Local _aArea := GetArea()
	Local cTabela
	Local _aEmp := {}
	
	Static oDlgEvent
	Static oButton1
	
	Private oMSNew
	Private aColsEx := {}
	
	//Define pelo SX2 as tabelas compartilhadas entre empresas
	//para definir SXP corretamente.
	_aEmp := TabEmp(_cAlias)
	
	//Alimenta Acols com dados existestes na tabela SXP
	fAcols(_cCodUnico, _cAlias, _aEmp)
	
	If Len(aColsEx) == 0
		MsgAlert("Nenhum evento encontrato para este cliente.","Cliente Sem Log")
		Return
	EndIf
	
	DEFINE MSDIALOG oDlgEvent TITLE "Registro de LOGs" FROM 000, 000  TO 300, 795 COLORS 0, 16777215 PIXEL
	
	fMSNewGet1()
	
	@ 014, 340 BUTTON oButton1 PROMPT "SAIR" 	Size 037,12 OF oDlgEvent PIXEL ACTION oDlgEvent:End()
	
	ACTIVATE MSDIALOG oDlgEvent CENTERED
	
	RestArea(_aArea)
	
Return

//--------------------------------------------------------------//
// Funcao para montar getdados.                                 //
//--------------------------------------------------------------//
Static Function fMSNewGet1()
	
	Local _aArea := GetArea()
	Local nX := 0
	Local aHeaderEx := {}
	Local aAlterFields := {}
	
	Aadd(aHeaderEX,{"Data / hora"		,"XP_DATA"		,"@!"	,  020,	0,"",,"C","",""})
	Aadd(aHeaderEX,{"Operação"			,"XP_OPER"		,"@!"	,  010,	0,"",,"C","",""})
	Aadd(aHeaderEX,{"Usuario"			,"XP_USER"		,"@!"	,  020,	0,"",,"C","",""})
	Aadd(aHeaderEX,{"Campo"				,"XP_CAMPO"	,"@!"	,  015,	0,"",,"C","",""})
	Aadd(aHeaderEX,{"Valor Ant."		,"XP_ANTVAL"	,"@!"	,  020,	0,"",,"C","",""})
	Aadd(aHeaderEX,{"Valor Novo"		,"XP_NOVVAL"	,"@!"	,  020,	0,"",,"C","",""})
	
	oMSNew := MsNewGetDados():New( 032, 007, 145, 393, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgEvent, aHeaderEx, aColsEx)
	
	RestArea(_aArea)
	
Return

//Monta acols com dados de acordo com a empresa
Static Function fAcols(_cCodUnico, _cAlias, _aEmp)
	
	Local _aArea := GetArea()
	Local _cTipoLog := ""
	Local _cEmpAnt := cEmpAnt
	
	For _nX := 1 To Len(_aEmp)
		
		//Altera empresa atual
		cEmpAnt := _aEmp[_nX]
		
		DbSelectArea("SXP")
		
		Set Filter To XP_ALIAS == _cAlias .and. _cCodUnico $ XP_UNICO //"SA1"
		dbGoTop()
		
		Do While !Eof()
			
			Do Case
			Case SXP->XP_OPER == 064; _cTipoLog := "Inclusão"
			Case SXP->XP_OPER == 128; _cTipoLog := "Alteração"
			Case SXP->XP_OPER == 256; _cTipoLog := "Exclusão"
			EndCase
			
			Aadd(aColsEx, {	DTOC(SXP->XP_DATA) + " - " + SXP->XP_TIME	,;	//[01] Data SXP->XP_TIME				,;	//[02] Hora
			_cTipoLog					,;	//[03] Operação SXP->XP_OPER
			SXP->XP_USER				,;	//[04] Usuário
			DescriSx3(SXP->XP_CAMPO)	,;	//[05] Campo
			SXP->XP_ANTVAL			,;	//[06] Valor Anterior
			SXP->XP_NOVVAL			,;	//[07] Valor Atual
			.F.	})
			DbSkip()
			
		EndDo
		
		DbCloseArea("SXP")
		
	Next _nX
	
	//Ordenar Array
	aSort(aColsEx,,,{|x,y| x[1] < y[1]})
	
	//Retorna Empresa Inicial
	cEmpAnt := _cEmpAnt
	
	RestArea(_aArea)
	
Return

//--------------------------------------------------------------//
// Funcao para recuperar titulo do campo no SX3.                //
//--------------------------------------------------------------//
Static Function DescriSx3(_cCampo)
	
	Local _aArea := GetArea()
	Local cTitulo
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	If dbSeek( _cCampo )
		cTitulo := X3Titulo()
	EndIf
	
	RestArea(_aArea)
	
Return cTitulo

//--------------------------------------------------------------//
// Funcao para definir quais empresas serao consideradas SXP.   //
//--------------------------------------------------------------//
Static Function TabEmp(_cAlias)
	
	Local _aArea := GetArea()
	Local _cTab
	Local _aEmp := {}
	Local _cTabela := alltrim(posicione("SX2",1,_cAlias,"X2_ARQUIVO"))
	
	//Inicializa o arquivo de empresas
	SET(_SET_DELETED,.T.)
	dbUseArea(.T.,,"SIGAMAT.EMP","XSM0",.T.,.F.)
	dbSetIndex("SIGAMAT.IND")
	
	//Seta na primeira Empresa\Filial
	XSM0->(dbGoTop())
	
	While XSM0->(!Eof())
		
		//Inicializa o arquivo SX2 de empresas
		SET(_SET_DELETED,.T.)
		dbUseArea(.T.,,"SX2"+XSM0->M0_CODIGO+"0.DTC","XSX2",.T.,.F.)
		dbSetIndex("SX2"+XSM0->M0_CODIGO+"0.CDX")
		
		//Recupera o nome das tabelas a serem analisadas
		_cTab := AllTrim(Posicione("XSX2",1,_cAlias,"X2_ARQUIVO"))
		
		If _cTabela == _cTab
			If aScan(_aEmp, XSM0->M0_CODIGO) == 0
				aAdd(_aEmp,XSM0->M0_CODIGO)
			EndIf
		EndIf
		
		//Finaliza ambiente
		XSX2->(dbCloseArea())
		
		XSM0->(dbSkip())
		
	EndDo
	
	XSM0->(dbCloseArea())
	
	RestArea(_aArea)
	
Return (_aEmp)


//--------------------------------------------------------------//
// Funcao para atualizar limite de credito do cliente via neurotec.   //
//--------------------------------------------------------------//
User Function NEUROCLI(cCodCli, cLoja)
	
	//Local aParam := {"08", "01"}
	//RpcSetType(3)
	//RpcSetEnv(aParam[1],aParam[2],,,"COM")
 
	Local aUser := {}
	Local cFunName := ""
	Local oClienteM := nil
    Local dVenLimit := ""  
    Local nNumProp   := ""
    Local nW := 1
	Local oLogC := TINLogController():New()
	Local oLogM := TINLogModel():New()
	Local oNeurotM   := TINNeurotechModel():New()
	Local oWSClient  := TINNeurotechRequest():New()	
	Local nNumProp   := GETSXENUM("ZZ8","ZZ8_CNTNEU") 
	Local oClienteC  := TINClienteController():New() // Instancia o controller
    Local oClienteM  := oClienteC:GetCliLoja(XFilial("SA1"),cCodCli,cLoja)	 // Recuperar o modelo do negócio

	oNeurotM:oCliente   := oClienteM
	oNeurotM:nNumProp   := nNumProp
	oNeurotM:nVlrTotVen := 0
	oNeurotM:cObserv    := "Pedido de credito via cadastro do cliente."
	


	oLogM:dDtEnvNeu  := DATE()
	oLogM:cHrEnvNeu  := SubStr(Time(),1,5)

	oWSClient:PostRequest(oNeurotM)

	oLogM:dDtResNeu  := DATE()
	oLogM:cHrResNeu  := SubStr(Time(),1,5)

	If !EMPTY(oWSClient:oRetorno:NCDOPERACAO)

		//Caso dê erro na NEUROTECH
		oLogM:cCodNeu  := oWSClient:oRetorno:NCDOPERACAO		
		oLogM:cErroNeu := ""
		If (oWSClient:oRetorno:CCDMENSAGEM != "0100")
			oLogM:cErroNeu :=  cValToChar(oWSClient:oRetorno:NCDOPERACAO)+" - ("+oWSClient:oRetorno:CCDMENSAGEM+") " + cValToChar(oWSClient:oRetorno:CDsMensagem)
			oLogM:cStatus  := "" //  Vazio - Erro preto 		
			lRet := .F.			
		Else
			
			If (oWSClient:oRetorno:CCDMENSAGEM == "0100" .AND. cValToChar(oWSClient:oRetorno:CRESULTADO) == "APROVADO")				
				oLogM:cStatus := "3" //Retonro liberado - azul
				lRet := .T.

			ElseIf (oWSClient:oRetorno:CCDMENSAGEM == "0100" .AND. cValToChar(oWSClient:oRetorno:CRESULTADO) == "PENDENTE")							    
				oLogM:cMotivNeu  := cValToChar(oWSClient:oRetorno:NCDOPERACAO)+" - "+cValToChar(oWSClient:oRetorno:CRESULTADO)
				oLogM:cStatus := "5" //Pendente -  Laranja
				lRet := .F.
			Else
				oLogM:cMotivNeu  := cValToChar(oWSClient:oRetorno:NCDOPERACAO)+" - "+cValToChar(oWSClient:oRetorno:CRESULTADO)
				oLogM:cStatus := "2" // Retorno com bloqueio - vermelho
				lRet := .F.
			EndIf

		EndIf

		//Atualizar dados do cliente mediante ao retorno da NEUROTECH	 
		if(LEN(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo) > 0)
			
			For nW := 1 To LEN(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo)

				if (oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CNMPARAMETRO == "RET_DATA_VENCIMENTO_LIMITE" .AND. oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO != "")
					
					RecLock("SA1", .F.)					
					SA1->A1_VENCLC := CTOD(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO) //SUBSTR(STRTRAN(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO, "-", ""),0,8)   					
					SA1->(MsUnLock())
                    dVenLimit = CTOD(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO)

				EndIf
				
				if (oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CNMPARAMETRO == "RET_LIMITE_CREDITO"  .AND.  VAL(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO) > 0)
					
					RecLock("SA1", .F.)					 
					SA1->A1_LC := VAL(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO)					
					SA1->(MsUnLock())	
					oLogM:nVlrNeu := VAL(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO)				

				EndIf

			Next nW            

		EndIf

         MsgInfo("A solicitação para o cliente <b>"+cValToChar(oClienteM:cCodigo)+"</b>  retornou: <b>"+cValToChar(oWSClient:oRetorno:CRESULTADO)+"</b> e o novo saldo é: <b>"+cValToChar(oLogM:nVlrNeu)+"</b> com vencimento em: <b>"+cValToChar(dVenLimit)+"</b> ", "Aviso" )		
        
	Else	

		oLogM:cErroNeu := "Um erro inesperado ocorreu, a conexão não foi estabelecida com a neurotech."
        MsgInfo("Um erro inesperado ocorreu, a conexão não foi estabelecida com a neurotech.", "Aviso" )

	EndIf

	//LOG
	PswOrder(2) 
	aUser := PswRet(1)
	cFunName := FunName()

	oLogM:cFilialx   := XFilial("ZZ8")
	oLogM:cOutXML    := oWSClient:cOutXML
	oLogM:cInXML     := oWSClient:cInXML
	oLogM:cNumNeu    := nNumProp
	oLogM:cNumPedido := cFunName
	oLogM:cCodVend   := ""
	oLogM:cCodOper   := aUser[1][1]
	oLogM:cCodCli    := oClienteM:cCodigo
	oLogM:cCliLoja   := oClienteM:cLoja
	oLogM:cCliNome   := oClienteM:cNome
	oLogM:cCliCGC    := oClienteM:cCGC
	oLogM:cRotina    := cFunName	    
	oLogM:cLimitNeu  := 0 //MaFisRet(,"NF_TOTAL")  //VALOR DO PEDIDO	

	oLogC:Insert(oLogM)	
   
Return .T.
