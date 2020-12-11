/*
M460FIM - Gravação da NF saida
Ponto-de-Entrada: M460FIM - Gravação da NF saida
link: https://tdn.totvs.com/pages/releaseview.action?pageId=6784180
*/

User function M460FIM()
	Local cMsg := ""

	If SF4->F4_DUPLIC == "S" .And. !Empty(SF2->F2_DUPL)
		cMsg += "Deseja agendar o envio por e-mail dos boletos gerados na emissão do documento de saída "
		cMsg += "Número " + AllTrim(SF2->F2_DOC) + " Série " + AllTrim(SF2->F2_SERIE) + " Cliente " + SF2->F2_CLIENTE + "-" + SF2->F2_LOJA + Chr(13) + Chr(10)
		cMsg += AllTrim(SA1->A1_NOME) + "?" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		cMsg += "Obs.: Os boletos serão enviados após o documento saída receber a chave de autorização SEFAZ."

		If Aviso("Schedule Boletos", cMsg, {"Sim", "Não"}, 3) == 1
			RecLock("SF2", .F.)
			SF2->F2_YSCHBOL := "S"
			SF2->F2_YBOLENV := "N"
			MsUnlock()
		End If
	End If

	//INICIO - Alterado para atender à função ChvNfe()
	Posicione("SD2", 3, xFilial( "SD2" ) + SF2 -> ( F2_DOC + F2_SERIE ), " FOUND() " )
	Posicione("SC5", 1, xFilial( "SC5" ) + SD2 -> D2_PEDIDO , " FOUND() " )

	IF At( " - Chave: ", SC5 -> C5_MENNOTA ) > 0
		ChvNfe()
	ENDIF
	//FIM

Return


//Função: ChvNfe()
//Descrição: Realiza a gravação da chave da nota fiscal de remessa para os XML's que foram importados e geraram pedidos
Static Function ChvNfe()

	IF ! Empty( SF2->F2_CHVNFE )
		RETURN
	ENDIF

	//"Serie: " + oIdent:_SERIE:TEXT + " Nota: "+ oIdent:_NNF:TEXT + " - Originada de XML, poder de 3o" + " - Chave: " + cChaveNFE + " - CNPJ: " + cCNPJForn
	//======================================================================================================================================================

	nPosIni := At( " - Chave: ", SC5 -> C5_MENNOTA ) + Len( " - Chave: " )
	nPosFim := At( " ", allTrim( SubStr ( SC5 -> C5_MENNOTA, nPosIni ) ) )

	cChaveNFE := SubStr ( SC5 -> C5_MENNOTA, nPosIni, nPosFim )

	RecLock( "SF2", .F. )
	SF2->F2_CHVNFE := cChaveNFE
	SF2-> ( msUnLock() )

 	cSerieNf	:= SF2 -> F2_SERIE
 	cNumNf		:= SF2 -> F2_DOC

	IF Posicione( "SF3", 5, xFilial("SF3") + cSerieNf + cNumNf +  SA1->A1_COD + SA1->A1_LOJA, "FOUND()" )
		cKeyGroup := xFilial("SF3") + cSerieNf + cNumNf +  SA1->A1_COD + SA1->A1_LOJA
		SF3 -> ( dbEval( {|| RecLock( "SF3", .F. ), SF3->F3_CHVNFE := cChaveNFE, msUnLock() },,{ || ! eof() .and. cKeyGroup == SF3-> ( F3_FILIAL + F3_SERIE + F3_NFISCAL + F3_CLIEFOR + F3_LOJA )} ) )
	ENDIF

	IF Posicione( "SFT", 1, xFilial("SFT") + "S" + cSerieNf + cNumNf +  SA1->A1_COD + SA1->A1_LOJA, "FOUND()" )
		cKeyGroup := xFilial("SFT") + "S" + cSerieNf + cNumNf +  SA1->A1_COD + SA1->A1_LOJA
		SFT-> ( dbEval( {|| RecLock( "SFT", .F. ), SFT->FT_CHVNFE := cChaveNFE, msUnLock() },,{ || ! eof() .and. cKeyGroup == SFT-> ( FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA )} ) )
	ENDIF


Return