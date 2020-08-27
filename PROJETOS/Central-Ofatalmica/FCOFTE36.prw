#include 'protheus.ch'
#include "topconn.ch"
#include "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FCOFTE36
description Imprime o picking da pré-devolução
@author  Pontin - Facile Sistemas
@since   28.01.20
@version 1.0
/*/
//-------------------------------------------------------------------

User Function FCOFTE36()

	Local lValid				:= .T.
	Local aArea					:= GetArea()
	Local aAreaSZ5			:= SZ5->(GetArea())
	Local aAreaSZ6			:= SZ6->(GetArea())

	Private cSendDados	:= ""
	Private oObj  			:= tSocketClient():New()
	Private nPort 			:= 9100

	//|Valida o tipo de pré-devolução |
	If !AllTrim(SZ5->Z5_TIPO) $ "1/3"
		MsgStop("Tipo de Pré-Devolução inválida para impressão do Picking",FunName())
		RestArea(aAreaSZ5)
		RestArea(aAreaSZ6)
		RestArea(aArea)
		Return .F.
	EndIf

	If !MsgYesNo("Deseja imprimir o Picking da Pré-Devolução:" + cValToChar(SZ5->Z5_COD), FunName())
		RestArea(aAreaSZ5)
		RestArea(aAreaSZ6)
		RestArea(aArea)
		Return .F.
	EndIf

	//|Monta o cabeçalho do picking |
	lValid	:= fMontaCabec()

	If !lValid
		MsgStop("Falha ao montar o cabeçalho, verifique a pré-devolução selecionada",FunName())
		RestArea(aAreaSZ5)
		RestArea(aAreaSZ6)
		RestArea(aArea)
		Return .F.
	EndIf

	//|Monta os itens do picking |
	lValid	:= fMontaItens()

	If !lValid
		MsgStop("Falha ao buscar os itens, verifique a pré-devolução selecionada",FunName())
		RestArea(aAreaSZ5)
		RestArea(aAreaSZ6)
		RestArea(aArea)
		Return .F.
	EndIf

	//|Monta o rodapé |
	lValid	:= fMontaRodape()

	If !lValid
		MsgStop("Falha ao montar o rodapé, verifique a pré-devolução selecionada",FunName())
		RestArea(aAreaSZ5)
		RestArea(aAreaSZ6)
		RestArea(aArea)
		Return .F.
	EndIf

	//|Envia o picking para a impressora |
	lValid	:= fImprime()

	If !lValid
		MsgStop("Não foi possível se conectar com a impressora, favor procurar o TI",FunName())

	Else

		MsgInfo("Picking enviado para a impressora do sucesso!!",FunName())

	EndIf

	FreeObj(oObj)

	RestArea(aAreaSZ5)
	RestArea(aAreaSZ6)
	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaCabec
description Função para montar o cabeçalho do picking
@author  Pontin - Facile Sistemas
@since   28.01.20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fMontaCabec()

	Local lRet		:= .F.

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If SA1->( dbSeek( xFilial("SA1") + SZ5->Z5_CLIENTE + SZ5->Z5_LOJA ) )

		cSendDados += (chr(27)+chr(64)) // ESC @
		cSendDados += (chr(27)+chr(72)) // ESC H
		cSendDados += (chr(27)+chr(87)+chr(49)) // ESC W 1
		cSendDados += (chr(27)+chr(69)) // ESC E
		cSendDados += (PadC("DEVOLUÇÃO " + AllTrim(SZ5->Z5_COD),48)+chr(10))
		cSendDados += (chr(27)+chr(64)) // ESC @
		cSendDados += (chr(27)+chr(72)) // ESC H

		cSendDados += (chr(10)) //Salto de linha

		cSendDados += (PadR("Nome.......: "+AllTrim(SA1->A1_NOME),48)+chr(10))
		cSendDados += (PadR("E-mail.....: "+AllTrim(SA1->A1_EMAIL),48)+chr(10))
		cSendDados += (padr("TEL........: ("+AllTrim(SA1->A1_DDD)+")"+AllTrim(SA1->A1_TEL),48)+chr(10))
		cSendDados += (PadR("RG.........: "+AllTrim(SA1->A1_PFISICA),48)+chr(10))
		cSendDados += (PadR("CPF........: "+AllTrim(SA1->A1_CGC),48)+chr(10))

		cSendDados += (chr(10)) //Salto de linha

		If !Empty(SA1->A1_ENDENT)
			cSendDados += (PadR(Alltrim(SA1->A1_ENDENT),48)+chr(10))
			cSendDados += (PadR("Complemento: "+AllTrim(SA1->A1_COMPLEM),48)+chr(10))
			cSendDados += (PadR("Bairro.....: "+AllTrim(SA1->A1_BAIRROE),48)+chr(10))
			cSendDados += (PadR("CEP........: "+AllTrim(SA1->A1_CEPE),48)+chr(10))
			cMunEnt := Posicione("CC2",1,xFilial("CC2")+SA1->(A1_ESTE+A1_CODMUNE),"CC2_MUN")
			cSendDados += (PadR("Municipio..: "+AllTrim(cMunEnt),48)+chr(10))
		Else
			cSendDados += (PadR(Alltrim(SA1->A1_END),48)+chr(10))
			cSendDados += (PadR("Complemento: "+AllTrim(SA1->A1_COMPLEM),48)+chr(10))
			cSendDados += (PadR("Bairro.....: "+AllTrim(SA1->A1_BAIRRO),48)+chr(10))
			cSendDados += (PadR("CEP........: "+AllTrim(SA1->A1_CEP),48)+chr(10))
			cSendDados += (PadR("Municipio..: "+AllTrim(SA1->A1_MUN),48)+chr(10))
		EndIf

		cSendDados += (chr(27)+chr(64)) // ESC @
		cSendDados += (chr(27)+chr(72)) // ESC H
		cSendDados += (chr(27)+chr(87)+chr(49)) // ESC W 1
		cSendDados += (chr(27)+chr(69)) // ESC E
		cSendDados += (Replicate(chr(196),24)+chr(10))
		cSendDados += (chr(27)+chr(64)) // ESC @
		cSendDados += (chr(27)+chr(72)) // ESC H

		lRet	:= .T.

	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaItens
description Função para montar os itens do picking
@author  Pontin - Facile Sistemas
@since   28.01.20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fMontaItens()

	Local lRet		:= .F.
	Local cQuery	:= ""
	Local nQtdIte	:= 0

	//|Header dos items |
	cSendDados += PadR("ITEM",6)
	cSendDados += PadR("CODIGO",12)
	cSendDados += PadR("QTD",5)
	cSendDados += PadR("PRODUTO",17)
	cSendDados += (PadR("NF VENDA",10)+chr(10))
	cSendDados += (Replicate(chr(196),24)+chr(10))
	//ITEM  CODIGO      QTD  PRODUTO          NF VENDA
	//---------------------------------------------------

	cQuery	+= " SELECT * "
	cQuery	+= " FROM " + RetSqlName("SZ6") + " SZ6 "
	cQuery	+= " WHERE SZ6.Z6_FILIAL = " + ValToSql(SZ5->Z5_FILIAL)
	cQuery	+= " 			AND SZ6.Z6_COD = " + ValToSql(SZ5->Z5_COD)
	cQuery	+= " 			AND SZ6.D_E_L_E_T_ = '' "

	If Select("__TRB") > 0
		__TRB->(dbCloseArea())
	EndIf

	TcQuery cQuery New Alias "__TRB"

	While !__TRB->(EoF())

		//|Itens da devolução |
		cSendDados 	+= PadR(AllTrim(__TRB->Z6_ITEM),6)
		cSendDados 	+= PadR(AllTrim(__TRB->Z6_PROD),12)
		cSendDados 	+= PadR(cValToChar(__TRB->Z6_QUANT),5)
		cSendDados 	+= PadR(AllTrim(__TRB->Z6_DESCPRD),16) + " "
		cSendDados 	+= (PadR(AllTrim(__TRB->Z6_SAIDDOC),10)+chr(10))

		nQtdIte 	+= __TRB->Z6_QUANT
		lRet			:= .T.

		__TRB->(dbSkip())

	EndDo

	//Imprime totais
	cSendDados += (Replicate(chr(196),24)+chr(10))
	cSendDados += "Quantidade de produtos: " + cValToChar(nQtdIte)

	cSendDados += (chr(10)) //Salto de linha
	cSendDados += (chr(10)) //Salto de linha

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaRodape
description Função para montar rodapé do picking
@author  Pontin - Facile Sistemas
@since   28.01.20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fMontaRodape()

	Local lRet		:= .T.

	cSendDados += (Replicate(chr(196),24)+chr(10))
	cSendDados += PadC("Declaração de devolução de mercadoria",48)
	cSendDados += (chr(10))
	cSendDados += PadR("NUMERO: " + AllTrim(SZ5->Z5_COD) + "  " + DtoC(SZ5->Z5_DATA),48)

	cSendDados += (chr(10)) //Salto de linha
	cSendDados += (chr(10)) //Salto de linha

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fImprime
description Envia o picking para a impressora
@author  Pontin - Facile Sistemas
@since   28.01.20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fImprime()

	Local cLocal		:= "01"
	Local lRet			:= .T.

	If cLocal = "01"

		cIP   := "192.168.1.153"
		nRet  := oObj:Connect( nPort, cIp, 10 )

	EndIf

	If cLocal = "02"

		cIP   := "192.168.4.151"
		nRet  := oObj:Connect( nPort, cIp, 10 )

	EndIf

	If cLocal = "03"

		cIP   := "192.168.3.151"
		nRet  := oObj:Connect( nPort, cIp, 10 )

	EndIf

	If oObj:IsConnected()

		oObj:Send(cSendDados)

		oObj:CloseConnection()

	Else

		lRet	:= .F.	//|Não conseguiu conectar na impressora |

	EndIf

Return lRet
