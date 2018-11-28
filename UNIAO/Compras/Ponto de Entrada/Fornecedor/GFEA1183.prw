#Include 'Protheus.ch'

/*/
@Title   : Ponto de entrada para corrigir falha no processamento entre empresas
@Type    : FUN = Função
@Name    : GFEA1183
@Author  : Ihorran Milholi
@Date    : 20/10/2016
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
/*/
User Function GFEA1183()
	
	Local oXML		:= PARAMIXB[1]
	Local lRet		:= .T.
	Local _cChave	:= If(Type("PARAMIXB[1]:_INFCTE:_ID:TEXT") == "C", PARAMIXB[1]:_INFCTE:_ID:TEXT, "")
	
	If Type("PARAMIXB[1]:_INFCTE:_ID:TEXT") == "C"
		
		
		Conout("Chave: [" + _cChave + "]" + " - cEmpAnt+cFilAnt: [" + cEmpAnt+cFilAnt + "]" + " - SM0->M0_CODIGO+SM0->M0_CODFIL: [" + SM0->M0_CODIGO+SM0->M0_CODFIL + "]")
		
	Else
		
		Conout("SM0->M0_CGC: [" + SM0->M0_CGC + "] - Chave: [" + "nao encontrei -> PARAMIXB[1]:_INFCTE:_ID:TEXT]")
		
	Endif
	/*
	If !CTe_VldEmp(oXML,SM0->M0_CGC)
		
		lRet := .F.
		
	EndIf
*/
Return(lRet)

USER FUNCTION WSC_X()
	
	Local aParam := {"08", "01"}
	
	RPCSetType(3)
	
	RpcSetEnv(aParam[1], aParam[2])
	
	SchedComCol(aParam)
	
	RpcClearEnv()
	
RETURN()
