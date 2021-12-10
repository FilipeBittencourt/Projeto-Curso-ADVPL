#include "PROTHEUS.CH"


/*/{Protheus.doc} BFATRT02
@description Rotina para rodar em schedule - verificar os pedidos com residuo eliminado e acertar as baixas de AI
@author Fernando Rocha
@since 06/12/2017
@version undefined
@type function
/*/
User Function BFATRT02()

	Local xv_Emps    := U_BAGtEmpr("01_05_14")
	Local nI

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
		//Gera o html do WF.
		Processa({|| PrcBFRT02()})

		RpcClearEnv()
	Next nI 

Return

Static Function PrcBFRT02()

	Local __cAliasAux
	Local _dData := dDataBase

	ConOut("BFATRT02 ("+DTOC(_dData)+") => iniciando ajuste de saldos de AI por eliminacao de residuo  => Empresa: "+AllTrim(CEMPANT))

	//Todos itens do pedido
	__cAliasAux := GetNextAlias()
	BeginSql Alias __cAliasAux
		%NOPARSER%

		select C5_NUM, C5_YLINHA, C5_YNUMSI, C5_YNOUTAI, C5_CLIENTE
		from %Table:SC6% SC6 (nolock)
		join %Table:SC5% SC5 (nolock) on C5_FILIAL = C6_FILIAL and C5_NUM = C6_NUM
		where C6_FILIAL = '01'

		and (
		((C5_CLIENTE <> '010064') and (C6_YDTRESI = %Exp:DTOS(_dData)%))
		OR
		((C5_CLIENTE = '010064') and (
		(
		select top 1 C6_YDTRESI
		from SC6070 C67 (nolock) 
		join SC5070 C57 (nolock) on C57.C5_FILIAL = C67.C6_FILIAL and C57.C5_NUM = C67.C6_NUM
		where
		C57.C5_YEMPPED = %Exp:AllTrim(CEMPANT)%
		and C57.C5_YPEDORI = SC5.C5_NUM 
		and C67.C6_ITEM = SC6.C6_ITEM
		and C67.D_E_L_E_T_='' and C57.D_E_L_E_T_=''
		)   = %Exp:DTOS(_dData)%))
		)

		and (C5_YNUMSI <> '' or C5_YNOUTAI <> '')
		and SC6.%NotDel%
		and SC5.%NotDel%

	EndSql

	ConOut("BFATRT02 => Consulta sucesso => Empresa: "+AllTrim(CEMPANT))

	(__cAliasAux)->(DbGoTop())  
	While !(__cAliasAux)->(Eof())

		ConOut("BFATRT02 => Processando pedido: "+(__cAliasAux)->C5_NUM+" => Empresa: "+AllTrim(CEMPANT))

		If !Empty((__cAliasAux)->C5_YNUMSI)
			//incluir nova baixa para itens restantes do pedido
			U_AO_INCBX((__cAliasAux)->C5_NUM,(__cAliasAux)->C5_YNUMSI)
		EndIf

		If !Empty((__cAliasAux)->C5_YNOUTAI)
			//incluir nova baixa para itens restantes do pedido
			U_AO_INCBX((__cAliasAux)->C5_NUM,(__cAliasAux)->C5_YNOUTAI,"Baixa.Aut.Ped.c/Desc.", 2)
		EndIf

		(__cAliasAux)->(DbSkip())
	EndDo
	(__cAliasAux)->(DbCloseArea())

	ConOut("BFATRT02 => Finalizado com sucesso => Empresa: "+AllTrim(CEMPANT))

Return()
