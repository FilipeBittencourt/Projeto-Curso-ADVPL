
#INCLUDE 'FWMVCDEF.CH'
#Include "Protheus.ch"


/*/{Protheus.doc} MT360GRV
Este ponto de entrada é executado apos a atualização de todas as tabelas da rotina de
condição de pagamento nas operações de inclusão, alteração e exclusão.

@author Sandro Costa
@since 07/06/2017
@version 1.0

@return Nil, Nao esperado

@example
(examples)

@see (links_or_references)
/*/

User Function MT360GRV()
	
	Local nI
	Local oObj := VIXA258():New()
	
	If INCLUI .and. MsgYesNO("Deseja cadastrar essa condição para as demais filiais?")
		aFiliais	:= GetFiliais()
		
		If Len(aFiliais) > 0
			BEGIN TRANSACTION
			For nI := 1 to Len(aFiliais)
				cFilAtuE4 := AllTrim(aFiliais[nI])
				If !Posicione("SE4",1,cFilAtuE4+M->E4_CODIGO,"FOUND()") // Se nao existir o codigo, cadastra na filial selecionada
//					lRet := MyMata360(cFilAtuE4)
					lRet := CriaSE4(cFilAtuE4)
					If !lRet
						DisarmTransaction()
						Exit
					EndIf
				Else
					Alert("Código "+M->E4_CODIGO + " Já existe na filial "+cFilAtuE4)
				EndIf
			Next nI
			END TRANSACTION
		EndIf
	EndIf	

	oObj:WorkFlowSE4() // Envia email se a condição de pagamento for altereada, caso a mesma esteja vinculada a um fornecedor

Return()


Static Function GetFiliais
	Local aFiliais
	aFiliais := U_SelFil01() // Função generica de tela de filiais
	
	If Len(aFiliais) == 0
		Alert("Não foi selecionada ao menos 1 filial. Criando somente para a atual.")
	EndIf
	
Return aFiliais

Static Function CriaSE4(cFilialAtu)
	Local lRet := .T.
	If !Posicione("SX3",1,"SE4","FOUND()")
		Alert("SX3 da tabela SE4 não localizada, favor contactar o TI.")
		Return
	EndIf
	
	RECLOCK("SE4",.T.)
	//Populando Cabeçalho
	Do While !SX3->(EOF()) .and. SX3->X3_ARQUIVO == "SE4"
		cCampo := SX3->X3_CAMPO
		If AllTrim(cCampo) $ "E4_FILIAL"
			SE4->&(cCampo) := cFilialAtu
		Else
			SE4->&(cCampo) := M->&(cCampo)
		EndIf
		SX3->(DbSkip())
	EndDo
	SE4->(MsUnLock())

Return lRet

Static Function MyMata360(cFilialAtu)
	//DEFININDO variáveis
	Local aItemAux := {} //Array auxiliar para inserção dos itens
	Local aDados := {} //Array do cabeçalho (SE4)
	Local aItens := {} //Array que irá conter os itens (SEC)
	Local lRet := .T.
	Private lMsErroAuto := .F. //Indicador do status pós chamada
	
	If !Posicione("SX3",1,"SE4","FOUND()")
		Alert("SX3 da tabela SE4 não localizada, favor contactar o TI.")
		Return
	EndIf
	
		
	//Populando Cabeçalho
	Do While !SX3->(EOF()) .and. SX3->X3_ARQUIVO == "SE4"
		cCampo := SX3->X3_CAMPO
		If AllTrim(cCampo) $ "E4_FILIAL"
			aAdd(aDados, {cCampo , cFilialAtu, Nil})
		Else
			aAdd(aDados, {cCampo , M->&(cCampo), Nil})
		EndIf
		SX3->(DbSkip())
	EndDo
	
	
	//Chamando rotina automática de inclusão
	MSExecAuto({|x,y,z|mata360(x,y,z)},aDados,aItens, 3)
	
	//Verificando status da rotina executada
	If lMsErroAuto
		MostraErro()
		lRet := .F.
	EndIf
	
Return lRet