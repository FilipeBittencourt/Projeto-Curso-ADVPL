#include "rwmake.ch"
#include "topconn.ch"
#include "buttom.ch"
#include "ap5mail.ch"


User Function BIA169()

	SetPrvt("CQUERY,CWHERE,CDATA")
	SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,COLDALIAS")
	SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CDADOS,CARQTEMP1,CARQTEMP2,CARQTEMP3")
	SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP,LABORTPRINT,LRELABERTO")
	SetPrvt("ARETURN,ACAMPOS,ACAMPOSREL,ACONCENC,ADCONCENC")
	SetPrvt("CANOPESQ,CMESPESQ,CMAILDEST")
	SetPrvt("NCRCCONTROL,NL,NCONCENC,NMEDIA,NTOTREGS,NTIPOS,NTOTTIPO,NPAGINA,NLASTKEY,NP,NX,NLARGURA")
	SetPrvt("LOK")

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao	 ³ BIA169	³ Autor ³ WLADIMIR ILLIUSHENKO  ³ Data ³19/03/2002³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Envio de Follow-up de Compras                              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso		 ³ SIGACOM													              ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pergunta se deseja realmente prosseguir com a rotina.						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg := ""
	cMsg += "Esta rotina ira enviar automaticamente um relatorio de   " + chr(13)
	cMsg += "Follow-Up de compras para cada fornecedor relacionado na " + chr(13)
	cMsg += "faixa de data de entrega e emissao informadas nos        " + chr(13)
	cMsg += "parametros e que estejam em aberto.                      " + chr(13)
	cMsg += "DESEJA REALMENTE PROSSEGUIR ?                            "
	if !MsgYesNo(cMsg,"ENVIO AUTOMATICO DE FOLLOW-UP DE COMPRAS POR E-MAIL")
		Return
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis.													              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomeProg  := "BIA169"
	lGravParam := .T.
	nLastkey   := 0
	nL         := 0
	lFalhas    := .F.
	lEnviados  := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.									        ³
	//³ Verifica Posicao do Formulario na Impressora.							        ³
	//³                                          								        ³
	//³ Pega os valores passados como parametro: 								        ³
	//³ MV_PAR01 -> Da Data Entrega   ?          								        ³
	//³ MV_PAR02 -> Ate Data Entrega  ?          								        ³
	//³ MV_PAR03 -> Da Data Emissao   ?          								        ³
	//³ MV_PAR04 -> Ate Data Emissao  ?          								        ³
	//³ MV_PAR05 -> Responsavel       ?          								        ³
	//³ MV_PAR06 -> Setor Responsavel ?          								        ³
	//³ MV_PAR07 -> Tel. Responsavel  ?          								        ³
	//³ MV_PAR08 -> Fax. Responsavel  ?          								        ³
	//³ MV_PAR09 -> E-Mail Responsavel?          								        ³
	//³ MV_PAR10 -> Titulo Padrao     ?          								        ³
	//³ MV_PAR11 -> Copia Para        ?          								        ³
	//³ MV_PAR12 -> Copia Oculta Para ?          								        ³
	//³ MV_PAR13 -> Do Fornecedor     ?          								        ³
	//³ MV_PAR14 -> Ate Fornecedor    ?          								        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cNomeProg,lGravParam)
	if lastkey()==27 .OR. nLastKey==27
		Return
	endif

	lOk    := .T.
	cTexto := ""
	do while lOk
		@ 000,000 TO 150,350 DIALOG oDialog TITLE "E-Mail"
		@ 005,005 SAY "Texto padrao dos e-mails."
		@ 020,005 GET cTexto SIZE 130,050 MEMO
		@ 060,140 BMPBUTTON TYPE BT_OK ACTION fFinaliza()
		ACTIVATE DIALOG oDialog CENTERED
	enddo

	if Upper(AllTrim(getenvserver())) <> "PRODUCAO"
		cMsg := ""
		cMsg += "ATENCAO!! "+chr(13)
		cMsg += "Voce esta no ambiente de Desenvolvimento, todos os e-mail serao encaminhados "+chr(13)
		cMsg += "para a conta '"+alltrim(GETMV("MV_YEMLTST"))+"', conforme o parametro MV_YEMLTST."+chr(13)
		cMsg += "" + chr(13)
		cMsg += "DESEJA PROSSEGUIR ?"
		if !MsgYesNo(cMsg,"AVISO")
			Return
		endif
	endif

	Processa({|| fCriaTemp() })
	Processa({|| fEnvia()    })
	Processa({|| fApagaTemp()})
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fCriaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria arquivo temporario para impressao do relatorio.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION fCriaTemp()
	aCampos := {}
	AADD(aCampos,{ "FORNCOD"   , "C", 06, 0 })
	AADD(aCampos,{ "FORNNOM"   , "C", 40, 0 })
	AADD(aCampos,{ "FORNEML"   , "C", 80, 0 })
	AADD(aCampos,{ "AUTORIZ"   , "C", 06, 0 })
	AADD(aCampos,{ "MSGERRO"   , "C",100, 0 })
	cArqTemp1 := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,, cArqTemp1, "RES")
	DbCreateInd(cArqTemp1+".001","FORNCOD + AUTORIZ",{||FORNCOD + AUTORIZ})
	OrdListClear()
	OrdListAdd(cArqTemp1+".001")
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fEnvia    ³ Autor ³ WLADIMIR ILLIUSHENKO					     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia e-mail das Autorizacoes de Entrega                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function fEnvia()

	Local nX

	cQuery := ""
	cWhere := ""
	cQuery += "SELECT COUNT(SC7.C7_NUM) AS TOTREGS "
	cWhere += "FROM "
	cWhere += RetSQLName("SC7")+" SC7, "
	cWhere += RetSQLName("SA2")+" SA2  "
	cWhere += ""
	cWhere += "WHERE "
	cWhere += "   SC7.C7_FILIAL = '"+xFilial("SC7")+"' AND "
	cWhere += "   SC7.C7_DATPRF BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND "
	cWhere += "   SC7.C7_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND "
	cWhere += "   SC7.C7_FORNECE BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"' AND "
	cWhere += "   SC7.C7_RESIDUO = '' AND "
	cWhere += "   SC7.C7_ENCER = '' AND "
	cWhere += "   SC7.C7_QTDACLA = 0 AND "
	cWhere += "   SC7.C7_QUANT-SC7.C7_QUJE > 0 AND "
	//cWhere += "   SUBSTRING(SC7.C7_NUM,1,1) = 'A' AND "
	cWhere += "   SC7.D_E_L_E_T_ = '' AND "
	cWhere += "   SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND "
	cWhere += "   SA2.A2_COD = SC7.C7_FORNECE AND "
	cWhere += "   SA2.A2_LOJA = SC7.C7_LOJA AND "
	cWhere += "   SA2.D_E_L_E_T_ = '' "
	cQuery := cQuery + cWhere
	TCQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())

	if nTotRegs > 0
		cQuery  := ""
		cQuery  += "SELECT "
		cQuery  += "  SC7.C7_NUM, "
		cQuery  += "  SC7.C7_PRODUTO, "
		cQuery  += "  SC7.C7_DESCRI, "
		cQuery  += "  SC7.C7_QUANT, "
		cQuery  += "  SC7.C7_UM, "
		cQuery  += "  SC7.C7_DATPRF, "
		cQuery  += "  SC7.C7_EMISSAO, "
		cQuery  += "  SA2.A2_COD,  "
		cQuery  += "  SA2.A2_NOME, "
		cQuery  += "  SA2.A2_END, "
		cQuery  += "  SA2.A2_MUN, "
		cQuery  += "  SA2.A2_EST, "
		cQuery  += "  SA2.A2_CEP, "
		cQuery  += "  SA2.A2_CGC, "
		cQuery  += "  SA2.A2_INSCR, "
		cQuery  += "  SA2.A2_TEL, "
		cQuery  += "  SA2.A2_FAX, "
		cQuery  += "  SA2.A2_CONTATO, "
		cQuery  += "  SA2.A2_EMAIL "
		cWhere  += "ORDER BY "
		cWhere  += "  SA2.A2_COD "
		cQuery  := cQuery + cWhere
		TCQuery cQuery Alias "QRY" New

		ProcRegua(nTotRegs)
		cCodFor := ""

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria o arquivo temporario para a geracao da Altorizacao do primeiro.³
		//³ fornecedor.                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCampos    := {}
		lRelAberto := .T.
		nLargura   := 80
		AADD(aCampos,{ "LINHA", "C", nLargura, 0 })
		cArqTemp2 := CriaTrab(aCampos, .T.)
		DbUseArea(.T.,, cArqTemp2, "REL")

		do while QRY->(!EOF())

			IncProc("Processando dados...")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se e um novo fornecedor para que seja gerado o cabecalho...³
			//³ da autorizacao.                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if (cCodFor <> QRY->A2_COD) .OR. (nL > 65)
				if nL > 65
					RecLock("REL", .T.); REL->LINHA := replicate(".",70)+" Continua."; REL->(DbUnlock())
					RecLock("REL", .T.); REL->LINHA := CHR(12); REL->(DbUnlock())
				endif

				if cCodFor <> QRY->A2_COD
					nPagina := 0
				endif

				cCodFor  := QRY->A2_COD
				nL       := 0
				nPagina++

				RecLock("REL", .T.); REL->LINHA := padl(strzero(day(date()),2) + " DE " + trim(u_mes(date())) + " DE " + strzero(year(date()),4),nLargura); REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padl("Pg.: " + strzero(nPagina,2),nLargura)                   ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("-----------------------------------------------------",nLargura)     ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("##### ##### #     #     ##### #   #       #   # #####",nLargura)     ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("###   #   # #     #     #   # # # #  ###  #   # #####",nLargura)     ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("#     ##### ##### ##### ##### ## ##       ##### #    ",nLargura)     ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("-----------------------------------------------------",nLargura)     ; REL->(DbUnlock()); nL++
				if nPagina == 1
					RecLock("REL", .T.); REL->LINHA := "DE..:"                                                   ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "  BIANCOGRES CERAMICA S/A, Av.Talma Rodrigues Ribeiro, 1145 Civit II"; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "  Av.Talma Rodrigues Ribeiro, 1145 Civit II, Serra (ES) "; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "  CGC: 02.077.546/0001-76"                               ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "  IE.: 081936443"                                        ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "  Cep: 29.168-080"                                       ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := ""                                                        ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "PARA:"                                                   ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "  " + QRY->A2_COD + " - " + QRY->A2_NOME                ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "  " + trim(QRY->A2_END) + ", "+trim(QRY->A2_MUN)+" ("+QRY->A2_EST+")"; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "  CONTATO: " + QRY->A2_CONTATO                           ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := ""                                                        ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := ""                                                        ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := ""                                                        ; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "Solicitamos nos informar o(s) numeros(s) da(s) nota(s) que porventura  atenderam"; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "as pendencias abaixo em atraso, bem como, as datas  de  saida,  transportadora e"; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "numero  dos  conhecimentos  de  transporte.   Caso  ainda  nao  atenderam  essas"; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "pendencias  favor  informarem  a  data  das  novas  previsoes.                  "; REL->(DbUnlock()); nL++
				endif
				RecLock("REL", .T.); REL->LINHA := replicate("_",nLargura)                                         ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := "PEDIDO  CODIGO.  DESCRICAO..................  QUANTIDADE  UN  DT.ENTR.  DT.EMIS."; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := replicate("-",nLargura)                                         ; REL->(DbUnlock()); nL++
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Itens da Autorizacao de Entrega.                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock()); nL++
			RecLock("REL", .T.); REL->LINHA := QRY->C7_NUM+"  "+padr(QRY->C7_PRODUTO,7)+"  "+padr(QRY->C7_DESCRI,27)+"  "+u_rtoc(QRY->C7_QUANT,"@E 999,999.99")+"  "+padr(QRY->C7_UM,2)+"  "+padr(dtoc(u_stod(QRY->C7_DATPRF)),08)+"  "+padr(dtoc(u_stod(QRY->C7_EMISSAO)),08); REL->(DbUnlock()); nL++

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o restante da descricao do produto.                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nP := 0
			for nX := 1 to 6
				nP += 28
				if len(trim(substr(QRY->C7_DESCRI,nP,27))) > 0
					RecLock("REL", .T.); REL->LINHA := space(17)+alltrim(substr(QRY->C7_DESCRI,nP,27)); REL->(DbUnlock()); nL++
				endif
			next

			cMailDest := MV_PAR09
			lOk      := .F.
			if !empty(QRY->A2_EMAIL)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Registra a autorizacao atual como enviada.                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if !RES->(DBSeek(QRY->A2_COD))
					RecLock("RES", .T.)
					RES->FORNCOD := QRY->A2_COD
					RES->FORNNOM := QRY->A2_NOME
					RES->FORNEML := QRY->A2_EMAIL
					RES->AUTORIZ := QRY->C7_NUM
					RES->(DbUnlock())
				endif

				cMailDest := QRY->A2_EMAIL
				lOk      := .T.
			else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se o fornecedor atual nao possuir e-mail registra a falha para ...  ³
				//³ ser exibida posteriormente no relatorio final de envio.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if !RES->(DBSeek(QRY->A2_COD))
					RecLock("RES", .T.)
					lFalhas      := .T.
					RES->FORNCOD := QRY->A2_COD
					RES->FORNNOM := QRY->A2_NOME
					RES->AUTORIZ := QRY->C7_NUM
					RES->MSGERRO := "E-MAIL NAO CADASTRADO!!"
					RES->(DbUnlock())
				endif
			endif

			QRY->(DbSkip())

			if ((cCodFor <> QRY->A2_COD) .OR. QRY->(EOF())) .AND. (REL->(LastRec()) > 0)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava rodape da autorizacao e transforma o arquivo temporario em ...³
				//³ arquivo texto para que seja anexado ao e-mail.                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("REL", .T.); REL->LINHA := replicate("-",nLargura); REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := "Atenciosamente,"; REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := trim(Upper(MV_PAR05)); REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := trim(Upper(MV_PAR06)); REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := "TEL.: " + trim(Upper(MV_PAR07)); REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := "FAX.: " + trim(Upper(MV_PAR08)); REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := trim(lower(MV_PAR09)); REL->(DbUnlock())

				cArqTemp3 := cArqTemp2 + ".TXT"
				DBSelectArea("REL")
				Copy to &cArqTemp3 SDF
				DBCloseArea("REL")
				lRelAberto := .F.
				cMailDest := iif(Upper(AllTrim(getenvserver()))=="PRODUCAO",cMailDest,alltrim(GETMV("MV_YEMLTST")))

				cMensagem 		:= cTexto
				cAssunto 		:= MV_PAR10+iif(!lOk," ERRO: FOR. S/ E-MAIL","")
				cRemetente		:= MV_PAR09                        
				aDestinatario 	:= cMailDest
				aCC 			:= MV_PAR11
				aCCO 			:= MV_PAR12
				cErro			:= ""
				cAnexo			:= iif(Upper(AllTrim(getenvserver()))=="PRODUCAO","\SIGAADV\","\SIGADES\")+cArqTemp3

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia e-mail e registra possivel falha de envio.                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				if !U_BIAEnvMail(,aDestinatario,cAssunto,cMensagem,cErro,cAnexo,,aCC,aCCO )
					if !RES->(DBSeek(QRY->A2_COD+QRY->C7_NUM))
						RecLock("RES", .T.)
						lFalhas      := .T.
						RES->FORNCOD := QRY->A2_COD
						RES->FORNNOM := QRY->A2_NOME
						RES->AUTORIZ := QRY->C7_NUM
						RES->MSGERRO := "FALHA NO ENVIO DO E-MAIL!!"
						RES->(DbUnlock())

						RES->(DBGoTop())
						do while !RES->(EOF())
							if RES->FORNCOD == QRY->A2_COD .AND. !empty(RES->AUTORIZ) .AND. empty(RES->MSGERRO)
								RecLock("RES", .F.)
								DELET
								RES->(DbUnlock())
							endif
							RES->(DbSkip())
						enddo
					endif
				else
					lEnviados := .T.
				endif

				FErase(cArqTemp2+".*")

				if !QRY->(EOF())
					cArqTemp2 := CriaTrab(aCampos, .T.)
					DbUseArea(.T.,, cArqTemp2, "REL")
					lRelAberto := .T.
				endif
			endif
		enddo
		QRY->(DbCloseArea())
		if lRelAberto
			REL->(DbCloseArea())
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Relatorio Final de Envio.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if RES->(LastRec()) > 0
			cArqTemp2 := CriaTrab(aCampos, .T.)
			DbUseArea(.T.,, cArqTemp2, "REL")

			RecLock("REL", .T.); REL->LINHA := "RELATORIO DE ENVIO DO FOLLOW-UP DE COMPRAS PELO SIGA"   ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "===================================================="   ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "PARAMETROS:"   ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Data...............: "+dtoc(date()); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Da Entrega.........: "+dtoc(MV_PAR01); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Ate Entrega........: "+dtoc(MV_PAR02); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Da Emissao.........: "+dtoc(MV_PAR03); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Ate Emissao........: "+dtoc(MV_PAR04); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Responsavel........: "+MV_PAR05      ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Setor Responsavel..: "+MV_PAR06      ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Tel. Responsavel...: "+MV_PAR07      ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Fax. Responsavel...: "+MV_PAR08      ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  E-mail Responsavel.: "+MV_PAR09      ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Copia Para.........: "+MV_PAR10      ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Copia Oculta Para..: "+MV_PAR11      ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Titulo Padrao......: "+MV_PAR12      ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Texto Padrao.......: "+SUBSTR(cTexto,1,58); REL->(DbUnlock())
			nP := 0
			for nX := 1 to 15
				nP += 59
				if len(alltrim(substr(cTexto,nP,58))) > 0
					RecLock("REL", .T.); REL->LINHA := space(22)+SUBSTR(cTexto,nP,58); REL->(DbUnlock())
				endif
			next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inclui no relatorio de envio os fornecedores que tiveram e-mail ... ³
			//³ enviados com sucesso.                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if lEnviados
				RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := "FOLLOW-UP ENCAMINHADOS:"; REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := "  Forn..  Nome....................................  E-mail......................"; REL->(DbUnlock())
				ProcRegua(LastRec())
				RES->(DBGoTop())
				do while !RES->(EOF())
					IncProc("Enviando e-mails ...")
					if !empty(RES->AUTORIZ) .AND. empty(RES->MSGERRO)
						RecLock("REL", .T.); REL->LINHA := "  "+RES->FORNCOD+"  "+padr(RES->FORNNOM,40)+"  "+RES->FORNEML; REL->(DbUnlock())
					endif
					RES->(DbSkip())
				enddo
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inclui no relatorio de envio os fornecedores que tiveram falhas ... ³
			//³ no envio do e-mail.                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if lFalhas
				RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := "FALHAS:"; REL->(DbUnlock())
				RecLock("REL", .T.); REL->LINHA := "  Forn..  Nome....................................  Falhas......................"; REL->(DbUnlock())
				ProcRegua(LastRec())
				RES->(DBGoTop())
				do while !RES->(EOF())
					IncProc("Gerando relatorio de falhas ...")
					if !empty(RES->MSGERRO)
						RecLock("REL", .T.); REL->LINHA := "  "+RES->FORNCOD+"  "+padr(RES->FORNNOM,40)+"  "+RES->MSGERRO; REL->(DbUnlock())
					endif
					RES->(DbSkip())
				enddo
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Transforma o arquivo temporario em arquivo texto para que seja  ... ³
			//³ enviado por e-mail ao responsavel pelas cotacoes.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cArqTemp3 := cArqTemp2 + ".TXT"
			DBSelectArea("REL")
			Copy to &cArqTemp3 SDF
			DBCloseArea("REL")

			cMensagem 		:= memoread(cArqTemp3)// cTexto
			cAssunto 		:="Re:ENVIO DE FOLLOW-UP PELO SIGA"
			cRemetente		:= MV_PAR09                        
			aDestinatario 	:= {iif(Upper(AllTrim(getenvserver()))=="PRODUCAO",MV_PAR09,alltrim(GETMV("MV_YEMLTST")))}
			aCC 			:= MV_PAR11
			aCCO 			:= MV_PAR12
			cErro			:= "Problemas na transmissao do relatorio de envio!"
			cAnexo			:= ""

			if !U_BIAEnvMail(,aDestinatario,cAssunto,cMensagem,cErro,cAnexo,,aCC,aCCO )
				alert("Problemas na transmissao do relatorio de envio!")
			endif

			FErase(cArqTemp2+".*")
		endif
	else
		alert("Nao ha dados que satisfacam os parametros para serem listados.")
	endif
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fApagaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui a tabela temporaria.							           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function fApagaTemp()
	RES->(DbCloseArea("RES"))
	aeval(directory(cArqTemp1+".*"),{ |aFile| FErase(aFile[1])})
	aeval(directory(cArqTemp2+".*"),{ |aFile| FErase(aFile[1])})
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fFinaliza  ³ Autor ³ WLADIMIR ILLIUSHENKO 			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Finaliza digitacao do corpo do e-mail.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fFinaliza()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha a caixa de dialogo.                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lOk := .F.
	Close(oDialog)
Return