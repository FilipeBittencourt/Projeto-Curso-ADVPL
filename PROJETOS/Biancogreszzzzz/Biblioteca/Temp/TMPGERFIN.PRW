#include "PROTHEUS.CH"


/*/{Protheus.doc} TMPGERFIN
@description Rotina TEMPORARIA - gerar titulos financeiros de NF de entrada que nao geraram por problema na V12
@author Fernando Rocha
@since 06/12/2017
@version undefined
@type function
/*/
User Function TMPGERFIN()

	Local xv_Emps    := U_BAGtEmpr("05")
	Local nI

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
		//Gera o html do WF.
		//Processa({|| PrcTMP()})
		LjMsgRun("Aguarde... processando",,{|| PrcTMP() })

		RpcClearEnv()
	Next nI 

Return

Static Function PrcTMP()

	Local __cAliasAux
	Local aParc
	Local I
	Local _cParc

	LOCAL aArray := {}

	PRIVATE lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

	//Todos itens do pedido
	__cAliasAux := GetNextAlias()
	BeginSql Alias __cAliasAux
	%NOPARSER%

	select distinct D1_DTDIGIT, D1_TES,  F1_COND, E4_COND, E4_DESCRI, D1_FORNECE, D1_LOJA, D1_DOC, D1_SERIE, D1_TES, D1_CF, F1_VALBRUT, F1_PREFIXO
	from %Table:SD1% SD1  
	join %Table:SF1% SF1 on F1_FILIAL = D1_FILIAL and F1_DOC = D1_DOC and F1_SERIE = D1_SERIE and F1_FORNECE = D1_FORNECE and F1_LOJA = D1_LOJA
	join %Table:SF4% SF4 on F4_FILIAL = D1_FILIAL and F4_CODIGO = D1_TES
	join %Table:SE4% SE4 on E4_FILIAL = '  ' and E4_CODIGO = F1_COND and SE4.D_E_L_E_T_=''
	where
	D1_FILIAL = '01'
	and D1_CF <> ''
	and D1_DTDIGIT >= '20171012'
	and F1_TIPO in ('N','C')
	and F4_DUPLIC = 'S'
	and not exists(select * from %Table:SE2% SE2 where E2_FILIAL = D1_FILIAL and E2_PREFIXO = F1_PREFIXO and E2_NUM = D1_DOC and E2_FORNECE = D1_FORNECE and E2_LOJA = D1_LOJA and SE2.D_E_L_E_T_='' )
	and SD1.D_E_L_E_T_=''
	and SF4.D_E_L_E_T_=''
	and SF1.D_E_L_E_T_=''

	EndSql
	(__cAliasAux)->(DbGoTop())  
	While !(__cAliasAux)->(Eof())
	
	
		BEGIN TRANSACTION

		aParc	:= Condicao((__cAliasAux)->F1_VALBRUT,(__cAliasAux)->F1_COND,0,STOD((__cAliasAux)->D1_DTDIGIT),0)
		
		If Len(aParc) <= 1
		
			_cParc := " "
		
		Else
		
			_cParc := "A"
		
		Endif
		
		__cNaturez := ""
		SA2->(DbSetOrder(1))
		If SA2->(DbSeek(XFilial("SA2")+(__cAliasAux)->D1_FORNECE+(__cAliasAux)->D1_LOJA)) .And. !Empty(SA2->A2_NATUREZ)
			__cNaturez := SA2->A2_NATUREZ
		EndIf
			

		For I := 1 To Len(aParc)

			aArray := {; 
			{ "E2_PREFIXO"  , (__cAliasAux)->F1_PREFIXO             , NIL },;
			{ "E2_NUM"      , (__cAliasAux)->D1_DOC            		, NIL },;
			{ "E2_PARCELA"  , _cParc			            		, NIL },;
			{ "E2_TIPO"     , "NF"           				   		, NIL },;
			{ "E2_NATUREZ"  , __cNaturez							, NIL },;
			{ "E2_FORNECE"  , (__cAliasAux)->D1_FORNECE           	, NIL },;
			{ "E2_LOJA"  	, (__cAliasAux)->D1_LOJA           		, NIL },;
			{ "E2_EMISSAO"  , STOD((__cAliasAux)->D1_DTDIGIT)		, NIL },;
			{ "E2_VENCTO"   , aParc[I][1]						  	, NIL },;
			{ "E2_VENCREA"  , DATAVALIDA(aParc[I][1])				, NIL },;
			{ "E2_VALOR"    , aParc[I][2]  					        , NIL },;
			{ "E2_ORIGEM"   , "MATA100"  					        , NIL },;
			{ "E2_YOBSLIB"  , "TMPGERFIN"							, NIL }}

			
			lMsErroAuto := .F.
			
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

			If lMsErroAuto
			
				DisarmTransaction()
				
				aAutoErro := GETAUTOGRLOG()
				_cLogTxt  := XCONVERRLOG(aAutoErro)
		
				ConOut("ERRO TMPGERFIN: "+_cLogTxt)
				
				MsgAlert(_cLogTxt)						
		
				(__cAliasAux)->(DbSkip())
				loop
				
			Endif

			_cParc := Soma1(_cParc,1)			

		Next I		
		
		End Transaction

		(__cAliasAux)->(DbSkip())
	EndDo
	(__cAliasAux)->(DbCloseArea())

Return()


STATIC FUNCTION XCONVERRLOG(aAutoErro)
	LOCAL cRet := ""
	LOCAL nX := 1

	FOR nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX]+CRLF
	NEXT nX
RETURN cRet