#Include 'protheus.ch'

User Function GFEA044()

	Local aParam		:= PARAMIXB
	Local aArea			:= GetArea()
	Local aAreaGWU		:= GWU->(GetArea())
	Local aAreaSA2		:= SA2->(GetArea())
	Local aAreaSA1		:= SA1->(GetArea())
	Local aAreaSX5		:= SX5->(GetArea())
	Local aAreaSA4		:= SA4->(GetArea())

	Local cF1_CDTPDC 	:= ""
	Local lNumProp 		:= ""
	Local cCod 			:= ""
	Local cLoja 		:= ""
	Local cSerie 		:= ""
	Local cDoc 			:= ""
	Local cEmisDc		:= ""
	Local cChvGWU		:= ""
	Local cPCompra		:= ""
	Local cCodUF		:= ""
	Local cCgcTransp	:= ""
	Local nSeq			:= "0"
	Local nForCli 		:= 0
	Local nPos			:= 0
	Local lDeletou		:= .F.
	Local aUF			:= {}
	Local lAtualRota	:= .f.

//	alert(cDoc)
	//oObj     := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]

	//If !(cIdPonto $ 'FORMPRE/MODELPRE/FORMLINEPRE/FORMLINEPOS/FORMCOMMITTTSPRE/FORMPOS/MODELPOS/FORMCOMMITTTSPOS')
	If AllTrim(cIdModel) == "GFEA044" .And. cIdPonto $ "MODELCOMMITNTTS"

		If INCLUI .Or. ALTERA
			If Type('SF1->F1_SERIE') == 'U'
				Return .T.
			EndIf
			
			cSerie 		:= SF1->F1_SERIE
			cDoc 		:= SF1->F1_DOC

			//|Região Norte |
			aAdd(aUF,{"RO","11"})
			aAdd(aUF,{"AC","12"})
			aAdd(aUF,{"AM","13"})
			aAdd(aUF,{"RR","14"})
			aAdd(aUF,{"PA","15"})
			aAdd(aUF,{"AP","16"})
			aAdd(aUF,{"TO","17"})

			//|Região Nordeste |
			aAdd(aUF,{"MA","21"})
			aAdd(aUF,{"PI","22"})
			aAdd(aUF,{"CE","23"})
			aAdd(aUF,{"RN","24"})
			aAdd(aUF,{"PB","25"})
			aAdd(aUF,{"PE","26"})
			aAdd(aUF,{"AL","27"})
			aAdd(aUF,{"SE","28"})
			aAdd(aUF,{"BA","29"})

			//|Região Sudeste |
			aAdd(aUF,{"MG","31"})
			aAdd(aUF,{"ES","32"})
			aAdd(aUF,{"RJ","33"})
			aAdd(aUF,{"SP","35"})

			//|Região Sul |
			aAdd(aUF,{"PR","41"})
			aAdd(aUF,{"SC","42"})
			aAdd(aUF,{"RS","43"})

			//|Região Centro-Oeste |
			aAdd(aUF,{"MS","50"})
			aAdd(aUF,{"MT","51"})
			aAdd(aUF,{"GO","52"})
			aAdd(aUF,{"DF","53"})

			lNumProp	:= SuperGetMv("MV_EMITMP",.F.,"0") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"

			//|Busca o tipo de documento |
			cF1_CDTPDC 	:= Posicione("SX5",1,xFilial("SX5")+"MQ"+SF1->F1_TIPO+"E","X5_DESCRI")

			If Empty(cF1_CDTPDC)
				cF1_CDTPDC := Posicione("SX5",1,xFilial("SX5")+"MQ"+SF1->F1_TIPO,"X5_DESCRI")
			EndIf

			//|Busca o emissor |
			If SF1->F1_TIPO $ "DB"
				SA1->( dbSetOrder(1) )
				SA1->( MsSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA ) )
				If !SA1->( EOF() ) .And. SA1->A1_FILIAL == xFilial("SA1");
									.And. AllTrim(SA1->A1_COD) == AllTrim(SF1->F1_FORNECE);
									.And. AllTrim(SA1->A1_LOJA) == AllTrim(SF1->F1_LOJA)

					cCod 	:= SA1->A1_COD
					cLoja 	:= SA1->A1_LOJA

					If lNumProp
						nForCli := 1
					Else
						If SA1->A1_TIPO == "X"
							cEmisDc := AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA)
						Else
							cEmisDc := SA1->A1_CGC
						EndIf
					EndIf

				EndIf
			Else
				SA2->( dbSetOrder(1) )
				SA2->( MsSeek( xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA) )
				If !SA2->( EOF() ) .And. SA2->A2_FILIAL == xFilial("SA2");
									.And. AllTrim(SA2->A2_COD) == AllTrim(SF1->F1_FORNECE);
									.And. AllTrim(SA2->A2_LOJA) == AllTrim(SF1->F1_LOJA)

					cCod 	:= SA2->A2_COD
					cLoja 	:= SA2->A2_LOJA

					If lNumProp

						nForCli := 2
					Else
						If SA2->A2_TIPO == "X"
							cEmisDc := AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA)
						Else
							cEmisDc := SA2->A2_CGC
						EndIf
					EndIf

				EndIf
			EndIf			
				
			//|Analisa se irá buscar as rotas do pedido de compras ou do fornecedor |
			cPCompra	:= SFP001()
			If !Empty(cPCompra)
				dbSelectArea("ZZE")
				ZZE->(dbSetOrder(1))	//ZZE_FILIAL+ZZE_NUM+ZZE_CTRANS
				lAtualRota := ZZE->(dbSeek(xFilial("ZZE") + cPCompra /*+ SF1->F1_TRANSP*/))
			
			EndIf
			
			if ! lAtualRota
				dbSelectArea("ZZ0")
				ZZ0->(dbSetOrder(1))	//ZZ0_FILIAL+ZZ0_CODFOR+ZZ0_LOJA+ZZ0_CTRANS
				lAtualRota := ZZ0->(dbSeek(xFilial("ZZ0") + cCod + cLoja /*+ SF1->F1_TRANSP*/))
			
			EndIf
			
			//Necessário pois se a rota do cadastro de fornecedor não existir, o sistema grava o trevo em
			//branco e ao tentar desclassificar uma nota com o trecho em branco, o sistema gera um erro
			If ! lAtualRota 
				If ! Isblind()
					Aviso("Atencao","Não existe rota padrão do fornecedor cadastrada. A rota será obtida através da NFe para cadastrar o trecho no documento de carga",{"OK"})
				EndIf
				
				Return .t.
			EndIf

			//|Formata as variaveis de acordo com os campos |
			cF1_CDTPDC 	:= AllTrim(cF1_CDTPDC) + Space( (TamSX3("GW1_CDTPDC")[1]) - (Len( AllTrim(cF1_CDTPDC) )) )
			cSerie 		:= AllTrim(cSerie) + Space( (TamSX3("GW1_SERDC" )[1]) - (Len( AllTrim(cSerie) )) )
			cDoc 		:= AllTrim(cDoc) + Space( (TamSX3("GW1_NRDC" )[1]) - (Len( AllTrim(cDoc) )) )

			If lNumProp
				cEmisDc := OMSM011COD(cCod,cLoja,nForCli,,)
			EndIf

			cChvGWU	:= xFilial("GWU") + cF1_CDTPDC + cEmisDc + cSerie + cDoc

			dbSelectArea("GWU")
			GWU->(dbSetOrder(1))	//GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ

			Begin Transaction

			//|Deleta os trechos criados automaticamente pelo sistema |
			If GWU->(dbSeek(cChvGWU))

				While !GWU->(EoF()) .And. (GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC) == cChvGWU

					lDeletou	:= .T.

					RecLock("GWU",.F.)
					GWU->(dbDelete())
					GWU->(MsUnLock())

					GWU->(dbSkip())

				EndDo

			EndIf

			//|Cria a nova rota |
			If lDeletou

				dbSelectArea("SA4")
				SA4->(dbSetOrder(1))
				If SA4->(dbSeek(xFilial("SA4") + SF1->F1_TRANSP))
					cCgcTransp	:= SA4->A4_CGC
				EndIf

				lAtualRota := .T.
				If !Empty(cPCompra)

					dbSelectArea("ZZE")
					ZZE->(dbSetOrder(1))	//ZZE_FILIAL+ZZE_NUM+ZZE_CTRANS
					If ZZE->(dbSeek(xFilial("ZZE") + cPCompra /*+ SF1->F1_TRANSP*/))

						While !ZZE->(EoF()) .And. ZZE->(ZZE_FILIAL+ZZE_NUM+ZZE_CTRANS) == (xFilial("ZZE") + cPCompra + SF1->F1_TRANSP)
							lAtualRota := .F.
							nSeq	:= StrZero(Val(nSeq)+1,TamSX3("GWU_SEQ")[1])

							//|Busca UF |
							If (nPos := aScan(aUF, {|x| x[1] == ZZE->ZZE_UFDEST})) > 0
								cCodUF	:= aUF[nPos,2]
							EndIf

							If RecLock("GWU",.T.)
								GWU->GWU_FILIAL	:= xFilial("GWU")
								GWU->GWU_CDTPDC	:= cF1_CDTPDC
								GWU->GWU_EMISDC	:= cEmisDc
								GWU->GWU_SEQ	:= nSeq
								GWU->GWU_SERDC	:= cSerie
								GWU->GWU_NRDC	:= cDoc
								GWU->GWU_CDTRP	:= cCgcTransp
								GWU->GWU_NRCIDD	:= cCodUF + ZZE->ZZE_CIDDES
								GWU->GWU_PAGAR	:= IIF(AllTrim(ZZE->ZZE_MODALI) == "1","2","1")

								If (nPos := aScan(aUF, {|x| x[1] == ZZE->ZZE_UFORIG})) > 0
									cCodUF	:= aUF[nPos,2]
								EndIf

								GWU->GWU_NRCIDO	:= cCodUF + ZZE->ZZE_CIDORI

								GWU->(MsUnLock())

							Else

								DisarmTransaction()
								MsgStop("Não foi possível incluir os trechos da nota fiscal, favor procurar o setor de TI!",FunName())
								Exit

							EndIf

							ZZE->(dbSkip())

						EndDo

					EndIf

				EndIf	//|Busca rotas do fornecedor |

				If lAtualRota //Se não houver rota no pedido pega a rota do fornecedor
					dbSelectArea("ZZ0")
					ZZ0->(dbSetOrder(1))	//ZZ0_FILIAL+ZZ0_CODFOR+ZZ0_LOJA+ZZ0_CTRANS
					If ZZ0->(dbSeek(xFilial("ZZ0") + cCod + cLoja /*+ SF1->F1_TRANSP*/))

						While !ZZ0->(EoF()) .And. ZZ0->(ZZ0_FILIAL+ZZ0_CODFOR+ZZ0_LOJA+ZZ0_CTRANS) == (xFilial("ZZ0") + cCod + cLoja + SF1->F1_TRANSP)

							//|Busca UF |
							If (nPos := aScan(aUF, {|x| x[1] == ZZ0->ZZ0_UFDEST})) > 0
								cCodUF	:= aUF[nPos,2]
							EndIf

							nSeq	:= StrZero(Val(nSeq)+1,TamSX3("GWU_SEQ")[1])

							If RecLock("GWU",.T.)
								GWU->GWU_FILIAL	:= xFilial("GWU")
								GWU->GWU_CDTPDC	:= cF1_CDTPDC
								GWU->GWU_EMISDC	:= cEmisDc
								GWU->GWU_SEQ	:= nSeq
								GWU->GWU_SERDC	:= cSerie
								GWU->GWU_NRDC	:= cDoc
								GWU->GWU_CDTRP	:= cCgcTransp
								GWU->GWU_NRCIDD	:= cCodUF + ZZ0->ZZ0_CIDDES
                                GWU->GWU_PAGAR	:= IIF(AllTrim(ZZ0->ZZ0_MODALI) == "1","2","1")

								If (nPos := aScan(aUF, {|x| x[1] == ZZ0->ZZ0_UFORIG})) > 0
									cCodUF	:= aUF[nPos,2]
								EndIf

								GWU->GWU_NRCIDO	:= cCodUF + ZZ0->ZZ0_CIDORI

								GWU->(MsUnLock())

							Else

								DisarmTransaction()
								MsgStop("Não foi possível incluir os trechos da nota fiscal, favor procurar o setor de TI!",FunName())
								Exit

							EndIf

							ZZ0->(dbSkip())

						EndDo

					EndIf

				EndIf

			EndIf

			End Transaction

		EndIf

	EndIf

	RestArea(aAreaSA4)
	RestArea(aAreaSX5)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
	RestArea(aAreaGWU)
	RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} SFP001
Analisa se a rota virá do Pedido de Compra
@author  Pontin
@since   17/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SFP001()

	Local cPedIni	:= ""
	Local aAreaSD1	:= SD1->(GetArea())

	dbSelectArea("SD1")
	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

	cPedIni	:= SD1->D1_PEDIDO

	While !SD1->(EoF()) .And. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

		If cPedIni <> SD1->D1_PEDIDO
			cPedIni	:= ""
			Exit
		EndIf

		SD1->(dbSkip())

	EndDo

	RestArea(aAreaSD1)

Return cPedIni
