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
	Local cMunEnt := ""

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If SA1->( dbSeek( xFilial("SA1") + SZ5->Z5_CLIENTE + SZ5->Z5_LOJA ) )
/*
		cSendDados += (chr(27)+chr(64)) // ESC @
		cSendDados += (chr(27)+chr(72)) // ESC H
		cSendDados += (chr(27)+chr(87)+chr(49)) // ESC W 1
		cSendDados += (chr(27)+chr(69)) // ESC E		
		cSendDados += (PadC("DEVOLUCAO " + AllTrim(SZ5->Z5_COD),65)+chr(10))
		cSendDados += (chr(27)+chr(64)) // ESC @
		cSendDados += (chr(27)+chr(72)) // ESC H
		*/

		//Imprimir normal CHR(18)
		//Imprimir Comprimido CHR(27)+CHR(15)		
		cSendDados += (CHR(27)+CHR(15))
 	 

		cSendDados += (chr(27)+chr(69)) // NEGRITO		
		cSendDados += (PadC("Declaracao de devolucao de mercadoria",65)+chr(10))
		cSendDados += (PadC("Numero: "+AllTrim(SZ5->Z5_COD)+ "  " + DtoC(SZ5->Z5_DATA),65))
		cSendDados += (chr(27)+chr(70)) // FIM NEGRITO		 
		cSendDados += (chr(10)+chr(10)+chr(10)) //Salto de linha

		cSendDados += (PadR("Nome: "+AllTrim(SA1->A1_NOME),65)+chr(10))
		cSendDados += (PadR("E-mail: "+AllTrim(SA1->A1_EMAIL),65)+chr(10))
		cSendDados += (padr("TEL: ("+AllTrim(SA1->A1_DDD)+")"+AllTrim(SA1->A1_TEL),65)+chr(10))
		cSendDados += (PadR("RG: "+AllTrim(SA1->A1_PFISICA),65)+chr(10))
		cSendDados += (PadR("CPF: "+AllTrim(SA1->A1_CGC),65)+chr(10))

		cSendDados += (chr(10)) //Salto de linha
/*
		If !Empty(SA1->A1_ENDENT)
			cSendDados += (PadR(Alltrim(SA1->A1_ENDENT),65)+chr(10))
			cSendDados += (PadR("Complemento: "+AllTrim(SA1->A1_COMPLEM),65)+chr(10))
			cSendDados += (PadR("Bairro: "+AllTrim(SA1->A1_BAIRROE),65)+chr(10))
			cSendDados += (PadR("CEP: "+AllTrim(SA1->A1_CEPE),65)+chr(10))
			cMunEnt := Posicione("CC2",1,xFilial("CC2")+SA1->(A1_ESTE+A1_CODMUNE),"CC2_MUN")
			cSendDados += (PadR("Municipio: "+AllTrim(cMunEnt),65)+chr(10))
		Else
			cSendDados += (PadR(Alltrim(SA1->A1_END),65)+chr(10))
			cSendDados += (PadR("Complemento: "+AllTrim(SA1->A1_COMPLEM),65)+chr(10))
			cSendDados += (PadR("Bairro: "+AllTrim(SA1->A1_BAIRRO),65)+chr(10))
			cSendDados += (PadR("CEP: "+AllTrim(SA1->A1_CEP),65)+chr(10))
			cSendDados += (PadR("Municipio: "+AllTrim(SA1->A1_MUN),65)+chr(10))
		EndIf

		cSendDados += (chr(27)+chr(64)) // ESC @
		cSendDados += (chr(27)+chr(72)) // ESC H
		cSendDados += (chr(27)+chr(87)+chr(49)) // ESC W 1
		cSendDados += (chr(27)+chr(69)) // ESC E
		cSendDados += (Replicate(chr(196),24)+chr(10))
		cSendDados += (chr(27)+chr(64)) // ESC @
		cSendDados += (chr(27)+chr(72)) // ESC H
		*/
		cSendDados += (Replicate(chr(196),65)+chr(10))
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
	Local nVlrTot	:= 0
	
		cSendDados += (chr(27)+chr(69)) // NEGRITO		
		cSendDados += (PadR("PRODUTOS A DEVOLVER:",65)+chr(10))	
		cSendDados += (chr(27)+chr(70)) // FIM NEGRITO		 
		cSendDados += (chr(10)) //Salto de linha

	//|Header dos items |
	cSendDados += PadR("ITEM",5)
	cSendDados += PadR("CODIGO",12)
	cSendDados += PadR("QTD",5)
	cSendDados += PadR("PRODUTO",26)
	cSendDados += PadR("VLR UND",11)
	cSendDados += (PadR("NF VENDA",8)+chr(10))
	cSendDados += (Replicate(chr(196),65)+chr(10))
	
	//ITEM  CODIGO      QTD  PRODUTO          NF VENDA
	//---------------------------------------------------
	/*
	cQuery	+= " SELECT * "
	cQuery	+= " FROM " + RetSqlName("SZ6") + " SZ6 "
	cQuery	+= " WHERE SZ6.Z6_FILIAL = " + ValToSql(SZ5->Z5_FILIAL)
	cQuery	+= " 			AND SZ6.Z6_COD = " + ValToSql(SZ5->Z5_COD)
	cQuery	+= " 			AND SZ6.D_E_L_E_T_ = '' "

	*/
		
		cQuery	+= " SELECT   SD2.D2_TOTAL, SZ6.Z6_ITEM, SZ6.Z6_PROD, SUM(SZ6.Z6_QUANT) as Z6_QUANT, SZ6.Z6_DESCPRD, SZ6.Z6_SAIDDOC "
		cQuery	+= " FROM " + RetSqlName("SZ6") + " SZ6 "

		cQuery	+= " INNER JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D2_DOC = SZ6.Z6_SAIDDOC "
		cQuery	+= " AND SD2.D2_SERIE = SZ6.Z6_SAIDSER "
		cQuery	+= " AND SD2.D2_ITEM = SZ6.Z6_ITEM  "
		cQuery	+= " AND SD2.D2_FILIAL = SZ6.Z6_FILDOCS "
		cQuery	+= " AND SD2.D_E_L_E_T_ = ''  "

		cQuery	+= " WHERE 0=0 "
		cQuery	+= " AND SZ6.Z6_COD = " + ValToSql(SZ5->Z5_COD)
		cQuery	+= " AND SZ6.D_E_L_E_T_ = '' "

		cQuery	+= " group by SD2.D2_TOTAL, SZ6.Z6_ITEM, SZ6.Z6_PROD,  SZ6.Z6_QUANT, SZ6.Z6_DESCPRD, SZ6.Z6_SAIDDOC "

		cQuery	+= " order by SZ6.Z6_PROD, SZ6.Z6_ITEM "



	If Select("__TRB") > 0
		__TRB->(dbCloseArea())
	EndIf

	TcQuery cQuery New Alias "__TRB"

	While !__TRB->(EoF())
	
		//|Itens da devolução |
		cSendDados 	+= PadR(AllTrim(__TRB->Z6_ITEM),5)
		cSendDados 	+= PadR(AllTrim(__TRB->Z6_PROD),12)
		cSendDados 	+= PadR(cValToChar(__TRB->Z6_QUANT),5)
		cSendDados 	+= PadR(AllTrim(__TRB->Z6_DESCPRD),25)
		cSendDados 	+= Padl(AllTrim(cValToChar(Transform(__TRB->D2_TOTAL, "@E 999,999,999.99 "))),8)
		cSendDados 	+= (PadL(AllTrim(__TRB->Z6_SAIDDOC),12)+chr(10))
 
		nQtdIte 	+= __TRB->Z6_QUANT
		nVlrTot	    += __TRB->D2_TOTAL
		lRet		:= .T.

		__TRB->(dbSkip())

	EndDo

	//Imprime totais
	cSendDados += (Replicate(chr(196),65)+chr(10))	
	cSendDados += PadR("TOTAIS",17)
	cSendDados += PadR(cValToChar(nQtdIte),32)
	cSendDados += PadR(AllTrim(cValToChar(Transform(nVlrTot, "@E 999,999,999.99 "))),7)	
	cSendDados += (chr(10)+chr(10)) //Salto de linha
	

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

 	SA1->(dbSetOrder(1))// A1 ja foi aberta
	If SA1->( dbSeek( xFilial("SA1") + SZ5->Z5_CLIENTE + SZ5->Z5_LOJA ) )

		If  SA1->A1_PESSOA  == 'F'
			cSendDados +=  (PadR("Sua devolucao somente sera processada mediante a concordancia dos",65)+chr(10))
			cSendDados +=  (PadR("Termos e declaracao devidamente assinada. E que deve ser enviada",65)+chr(10))
			cSendDados +=  (PadR("a empresa juntamente com os produtos.",65)+chr(10))

			cSendDados +=  (PadR("Declaro estar ciente e de comum acordo com as condicoes e termos",65)+chr(10))
			cSendDados +=  (PadR("da devolucao:",65)+chr(10)+chr(10))

			cSendDados +=  (PadR("(x) Devolucao dos produtos dentro de 7 dias uteis da data do",65)+chr(10)) 
			cSendDados +=  (PadR("processamento.",65)+chr(10))

			cSendDados +=  (PadR("(x) Produto em embalagem original inviolada.",65)+chr(10))
			cSendDados +=  (PadR("(x) Produto sem uso e com prazo de validade superior a 6 meses",65)+chr(10)+chr(10))


			cSendDados +=  (PadR("Declaro para os devidos fins necessarios que estou devolvendo os",65)+chr(10))

			cSendDados +=  (PadR("produtos nas notas fiscais de compra relacionadas acima.",65)+chr(10)+chr(10))

			
		Else

			cSendDados +=  (PadR("Sob pena de sua devolucao nao ser processada, sua NF deve ser",65)+chr(10))
			cSendDados +=  (PadR("preenchida exatamente como as descricoes da NF de venda acima",65)+chr(10))
			cSendDados +=  (PadR("referida.",65)+chr(10))

			cSendDados +=  (PadR("Declaro estar ciente das condicoes da devolucao assinaladas",65)+chr(10))
			cSendDados +=  (PadR("abaixo:",65)+chr(10))

			cSendDados +=  (PadR("(x) Devolucao dos produtos dentro de 7 dias uteis da data do",65)+chr(10)) 
			cSendDados +=  (PadR("processamento.",65)+chr(10))
			cSendDados +=  (PadR("(x) Produto em embalagem original inviolada.",65)+chr(10))
			cSendDados +=  (PadR("(x) Produto sem uso e com prazo de validade superior a 6 meses.",65)+chr(10)+chr(10))

			cSendDados +=  (PadR("Declaro que estou ciente e aceito todos os termose condicoes",65)+chr(10))
			cSendDados +=  (PadR("desta devolucao de mercadoria.",65)+chr(10)+chr(10))

			cSendDados +=  (PadR("Processada em: "+cValToChar(DtoC(SZ5->Z5_DATA))+"",65)+chr(10)+chr(10))
			
		EndIf

			cSendDados +=  (PadR("RESPONSAVEL PELO RECEBIMENTO",65)+chr(10)+chr(10)+chr(10))

			cSendDados +=  (PadR("_______________________________________________________________",65)+chr(10))
			cSendDados +=  (PadR("(Nome complesto)",65)+chr(10)+chr(10))

			cSendDados +=  (PadR("_______________________________________________________________",65)+chr(10))
			cSendDados +=  (PadR("(Assinatura)",65)+chr(10)+chr(10))

			cSendDados +=  (PadR("RG.________________________________DATA_________________________",65)+chr(10))
		

	EndIf
	
	cSendDados += (chr(10)+chr(10)+chr(10))  //Salto de linha
	cSendDados += (chr(27)+chr(109)) //corte parcial
 	//cSendDados += (chr(27)+chr(119)) //corte total

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

		cIP   := "192.168.1.151"
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
