#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0035; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaNfeSefaz																		|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/01/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do xml da nota fiscal   |
| 				| eletrônica 																			|
|-----------------------------------------------------------|
*/

// Indices do array principal com todas as informações
#DEFINE IDX_Prod 1
#DEFINE IDX_MensCli 2
#DEFINE IDX_MensFis 3
#DEFINE IDX_Dest 4
#DEFINE IDX_Nota 5
#DEFINE IDX_InfoItem 6
#DEFINE IDX_Dupl 7
#DEFINE IDX_Transp 8
#DEFINE IDX_Entrega 9
#DEFINE IDX_Retirada 10
#DEFINE IDX_Veiculo 11
#DEFINE IDX_Reboque 12
#DEFINE IDX_EspVol 13
#DEFINE IDX_VincRur 14


Class TBiaNfeSefaz From LongClassName
	
	Data oProduto
	Data oMensCli
	Data oMensFis
	Data oDestino
	Data oNota
	Data oInfoItem
	Data oDuplicata
	Data oTransportador
	Data oEntrega
	Data aRetirada
	Data oVeiculo
	Data aReboque
	Data oEspVol
	Data aNfVincRur
	
	Data lValidate // Identifica se o envio da nota fiscal foi autorizado
		
	Method New(aParam) Constructor
	Method Validate()
	Method VldField()
	Method VldTes()
	Method Update(aParam)
	
EndClass


Method New(aParam) Class TBiaNfeSefaz
	
	::oProduto := TBiaProdutoNfeSefaz():New(aParam[IDX_Prod], aParam[IDX_InfoItem])	
	::oMensCli := TBiaMensagemClienteNfeSefaz():New(aParam[IDX_MensCli], aParam[IDX_Dupl])
	::oMensFis := TBiaMensagemFiscalNfeSefaz():New(aParam[IDX_MensFis])
	::oDestino := TBiaDestinoNfeSefaz():New(aParam[IDX_Dest])
	::oNota := TBiaNotaNfeSefaz():New(aParam[IDX_Nota])	
	::oInfoItem := TBiaInfoItemNfeSefaz():New(aParam[IDX_InfoItem])
	::oDuplicata := TBiaDuplicataNfeSefaz():New(aParam[IDX_Dupl])
	::oTransportador := TBiaTransportadorNfeSefaz():New(aParam[IDX_Transp])
	::oEntrega := TBiaEntregaNfeSefaz():New(aParam[IDX_Entrega])
	::aRetirada := aParam[IDX_Retirada]
	::oVeiculo := TBiaVeiculoNfeSefaz():New(aParam[IDX_Veiculo])
	::aReboque := aParam[IDX_Reboque]
	::oEspVol := TBiaEspecieVolumeNfeSefaz():New(aParam[IDX_EspVol])
	::aNfVincRur := aParam[IDX_VincRur]
	
	::lValidate := .T.

Return()


Method Validate() Class TBiaNfeSefaz
	
	If SFT->FT_TIPOMOV == "S"
		::lValidate := ::VldField() .And. ::VldTes()
	EndIf
  
Return()


Method VldField() Class TBiaNfeSefaz
Local lRet := .T.

	// Bloqueia a geracao da NFE quando nao estao informados todos os campos devido a erro durante a finalizado do Faturamento SF2460I
	If !cEmpAnt $ "02_06" // Exceto para Ceramica Incesa e JK
		
		If Empty(SF2->F2_YDES) .Or. Empty(Alltrim(SF2->F2_YSUBTP))
		
			lRet := .F.
			
			MsgAlert("Atenção, Não será possível transmitir a NF-e "+ SF2->F2_DOC+"/"+SF2->F2_SERIE +", pois alguns campos obrigatórios não foram informados. " +;
							 "Favor contactar o setor de TI!", "NfeSefaz")
						
		EndIf
		
	EndIf

Return(lRet)


Method VldTes() Class TBiaNfeSefaz
Local lRet := .T.
Local cSQL := ""
Local cSD2 := RetSQLName("SD2")
Local cQry := GetNextAlias()

	// Verifica se foi utilizado mais de um tes na geracao da NF-e
	cSQL := " SELECT COUNT(*) QUANT	"
	cSQL += " FROM ( "
	cSQL += " 	SELECT D2_TES, COUNT(*) COUNT "
	cSQL += " 	FROM " + cSD2 
	cSQL += " 	WHERE D2_FILIAL = "+ ValToSQL(SF2->F2_FILIAL)
	cSQL += " 	AND D2_DOC = "+ ValToSQL(SF2->F2_DOC)
	cSQL += " 	AND D2_SERIE = "+ ValToSQL(SF2->F2_SERIE)
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " 	GROUP BY D2_TES " 
	cSQL += " 	) AS TMP "
	
	TcQuery cSQL New Alias (cQry)	
	
	If (cQry)->QUANT <> 1 .and. SF2->F2_CLIENTE <> "004536" // Por Marcos em 16/01/18 para atender venda Fábrica vs Fábrica		
		
		lRet := .F.
		
		MsgAlert("Atenção, não será possível transmitir está NF-e, pois ocorreu um problema na sua geração (MAIS DE UM TES NO PEDIDO, PARA MESMA NF-e). " +;
						 "Favor contactar o setor de TI!", "NfeSefaz")
		
	EndIf
	
	(cQry)->(DbCloseArea())
	
Return(lRet)


Method Update() Class TBiaNfeSefaz
Local aRet := {}
	
	// Caso o envio não seja validado, retorna as mesmas informações enviadas para as classes, 
	// com exeção do array de notas, que é setado com nulo(Nil), para abortar o envio da NF-e via validação padrão
	If ::lValidate

		aAdd(aRet, ::oProduto:Update())
		aAdd(aRet, ::oMensCli:Update())
		aAdd(aRet, ::oMensFis:Update())
		aAdd(aRet, ::oDestino:Update())
		aAdd(aRet, ::oNota:Update())		
		aAdd(aRet, ::oInfoItem:Update())
		aAdd(aRet, ::oDuplicata:Update())
		aAdd(aRet, ::oTransportador:Update())
		aAdd(aRet, ::oEntrega:Update())
		aAdd(aRet, ::aRetirada)
		aAdd(aRet, ::oVeiculo:Update())
		aAdd(aRet, ::aReboque)
		aAdd(aRet, ::oEspVol:Update())
		aAdd(aRet, ::aNfVincRur)

	Else
		
		aAdd(aRet, ::oProduto:aProduto)
		aAdd(aRet, ::oMensCli:cMensagem)
		aAdd(aRet, ::oMensFis:cMensagem)
		aAdd(aRet, ::oDestino:aDestino)
		aAdd(aRet, Nil)		
		aAdd(aRet, ::oInfoItem:aInfoItem)
		aAdd(aRet, ::oDuplicata:aDuplicata)
		aAdd(aRet, ::oTransportador:aTransportador)
		aAdd(aRet, ::oEntrega:aEntrega)
		aAdd(aRet, ::aRetirada)
		aAdd(aRet, ::oVeiculo:aVeiculo)
		aAdd(aRet, ::aReboque)
		aAdd(aRet, ::oEspVol:aEspVol)
		aAdd(aRet, ::aNfVincRur)
					
	EndIf
			
Return(aRet)