#include "rwmake.ch"
#include "topconn.ch"
#include "buttom.ch"
#include "ap5mail.ch"


User Function Bia166()

SetPrvt("CQUERY,CWHERE,CDATA")
SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,COLDALIAS")
SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CDADOS,CARQTEMP1,CARQTEMP2,CARQTEMP3")
SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP,LABORTPRINT,LRELABERTO")
SetPrvt("ARETURN,ACAMPOS,ACAMPOSREL,ACONCENC,ADCONCENC")
SetPrvt("CANOPESQ,CMESPESQ")
SetPrvt("NCRCCONTROL,NL,NCONCENC,NMEDIA,NTOTREGS,NTIPOS,NTOTTIPO,NPAGINA,NLASTKEY")

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao	 � BIA166	� Autor � WLADIMIR ILLIUSHENKO  � Data �29/01/2002潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Envio de Cotacoes de Materiais por E-mail.                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so		 � SIGACOM													  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Pergunta se deseja realmente prosseguir com a rotina.						  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cMsg := ""
cMsg += "Esta rotina ira enviar automaticamente um relatorio de   " + chr(13)
cMsg += "cotacao para cada fornecedor relacionado na faixa de     " + chr(13)
cMsg += "cotacoes a ser informada.                                " + chr(13)
cMsg += "                                                         " + chr(13)
cMsg += "DESEJA REALMENTE PROSSEGUIR ?                            "
if !MsgYesNo(cMsg,"ENVIO AUTOMATICO DE COTACOES POR E-MAIL")
	Return
endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Inicializa variaveis.													              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cNomeProg  := "BIA166"
lGravParam := .T.
nLastkey   := 0
nL         := 0
lFalhas    := .F.
lEnviados  := .F.

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Envia controle para a funcao SETPRINT.									        �
//� Verifica Posicao do Formulario na Impressora.							        �
//�                                          								        �
//� Pega os valores passados como parametro: 								        �
//� MV_PAR01 -> Da Cotacao        ?          								        �
//� MV_PAR02 -> Ate Cotacao       ?          								        �
//� MV_PAR03 -> Responsavel       ?          								        �
//� MV_PAR04 -> Setor Responsavel ?          								        �
//� MV_PAR05 -> Tel. Responsavel  ?          								        �
//� MV_PAR06 -> Fax. Responsavel  ?          								        �
//� MV_PAR07 -> E-Mail Responsavel?          								        �
//� MV_PAR08 -> Titulo Padrao     ?          								        �
//� MV_PAR09 -> Copia Para        ?          								        �
//� MV_PAR10 -> Copia Oculta Para ?          								        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
	cMsg += "Voce esta no hambiente de Desenvolvimento, todos os e-mail serao encaminhados "+chr(13)
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪勘�
北矲uncao	 � fCriaTemp� Autor � WLADIMIR ILLIUSHENKO					     潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矰escricao � Cria arquivo temporario para impressao do relatorio.       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static FUNCTION fCriaTemp()
aCampos := {}
AADD(aCampos,{ "FORNCOD"   , "C", 06, 0 })
AADD(aCampos,{ "FORNNOM"   , "C", 40, 0 })
AADD(aCampos,{ "FORNEML"   , "C", 80, 0 })
AADD(aCampos,{ "COTACAO"   , "C", 06, 0 })
AADD(aCampos,{ "MSGERRO"   , "C",100, 0 })
cArqTemp1 := CriaTrab(aCampos, .T.)
DbUseArea(.T.,, cArqTemp1, "RES")
DbCreateInd(cArqTemp1+".001","FORNCOD + COTACAO",{||FORNCOD + COTACAO})
OrdListClear()
OrdListAdd(cArqTemp1+".001")
return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪勘�
北矲uncao	 � fEnvia    � Autor � WLADIMIR ILLIUSHENKO					     潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矰escricao � Envia e-mail das Cotacoes.                                 潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static function fEnvia()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica a existencia de registros para serem relatados                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cQuery := ""
cWhere := ""
cQuery += "SELECT COUNT(SC8.C8_NUM) AS TOTREGS "
cWhere += "FROM "
cWhere += "   "+RetSqlName("SC8")+" SC8, "
cWhere += "   "+RetSqlName("SA2")+" SA2, "
cWhere += "   "+RetSqlName("SB1")+" SB1  "
cWhere += ""
cWhere += "WHERE "
cWhere += "   SC8.C8_FILIAL = '"+xFilial("SC8")+"' AND "
cWhere += "   SC8.C8_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cWhere += "   SC8.D_E_L_E_T_ = '' AND "
cWhere += "   SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND "
cWhere += "   SA2.A2_COD = SC8.C8_FORNECE AND "
cWhere += "   SA2.A2_LOJA = SC8.C8_LOJA AND "
cWhere += "   SA2.D_E_L_E_T_ = '' AND "
cWhere += "   SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cWhere += "   SB1.B1_COD = SC8.C8_PRODUTO AND "
cWhere += "   SB1.D_E_L_E_T_ = '' "
cQuery := cQuery + cWhere
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

If nTotRegs > 0
	cQuery  := ""
	cQuery  += "SELECT "
	cQuery  += "  SC8.C8_NUM, "
	cQuery  += "  SC8.C8_QUANT, "
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
	cQuery  += "  SA2.A2_EMAIL, "
	cQuery  += "  SB1.B1_COD, "
	cQuery  += "  SB1.B1_DESC, "
	cQuery  += "  SB1.B1_UM "
	cWhere  += "ORDER BY "
	cWhere  += "  SA2.A2_COD, "
	cWhere  += "  SB1.B1_DESC "
	cQuery  := cQuery + cWhere
	TCQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs)
	cCodFor := ""
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Cria o arquivo temporario para a geracao da cotacao do primeiro ... �
	//� fornecedor.                                                         �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	aCampos    := {}
	lRelAberto := .T.
	AADD(aCampos,{ "LINHA", "C", 80, 0 })
	cArqTemp2 := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,, cArqTemp2, "REL")
	
	do while QRY->(!EOF())
		
		IncProc("Processando dados...")
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Gera a cotacao somente para os fornecedores que possuirem e-mail.   �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !empty(QRY->A2_EMAIL)
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifica se e um novo fornecedor para que seja gerado o cabecalho...�
			//� da cotacao.                                                         �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if (cCodFor <> QRY->A2_COD) .OR. (nL > 65)
				if nL > 65
					RecLock("REL", .T.); REL->LINHA := replicate(".",70)+" Continua."; REL->(DbUnlock())
					RecLock("REL", .T.); REL->LINHA := CHR(12); REL->(DbUnlock())
				endif
				
				if cCodFor <> QRY->A2_COD
					nPagina := 0
				endif
				
				cCodFor  := QRY->A2_COD
				cMailFor := QRY->A2_EMAIL
				nL       := 0
				nPagina++
				
				RecLock("REL", .T.); REL->LINHA := padl(strzero(day(date()),2) + " DE " + trim(u_mes(date())) + " DE " + strzero(year(date()),4),80); REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padl("Pg.: " + strzero(nPagina,2),80)                   ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("-----------------------------------------",80)     ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("##### ##### ##### ##### ##### ##### #####",80)     ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("#     #   #   #   ##### #     ##### #   #",80)     ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("##### #####   #   #   # ##### #   # #####",80)     ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := padc("-----------------------------------------",80)     ; REL->(DbUnlock()); nL++
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
					RecLock("REL", .T.); REL->LINHA := "Solicitamos de V.Sas. cotacao de precos e demais condicoes comerciais para os "; REL->(DbUnlock()); nL++
					RecLock("REL", .T.); REL->LINHA := "produtos discriminados, conforme padroes abaixo estabelecidos"; REL->(DbUnlock()); nL++
				endif
				RecLock("REL", .T.); REL->LINHA := replicate("_",80)                                         ; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := "COTC..  CODIGO.  DESCRICAO................................  UN  ......QUANTIDADE"; REL->(DbUnlock()); nL++
				RecLock("REL", .T.); REL->LINHA := replicate("-",80)                                         ; REL->(DbUnlock()); nL++
			endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Itens da Cotacao.                                                   �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock()); nL++
			RecLock("REL", .T.); REL->LINHA := QRY->C8_NUM+"  "+padr(QRY->B1_COD,7)+"  "+padr(QRY->B1_DESC,41)+"  "+padr(QRY->B1_UM,2)+"    "+u_rtoc(QRY->C8_QUANT); REL->(DbUnlock()); nL++
			if len(trim(substr(QRY->B1_DESC,42,41))) > 0
				RecLock("REL", .T.); REL->LINHA := space(17)+alltrim(substr(QRY->B1_DESC,42,41)); REL->(DbUnlock()); nL++
			endif
			if len(trim(substr(QRY->B1_DESC,84,41))) > 0
				RecLock("REL", .T.); REL->LINHA := space(17)+alltrim(substr(QRY->B1_DESC,84,41)); REL->(DbUnlock()); nL++
			endif
			if len(trim(substr(QRY->B1_DESC,126,41))) > 0
				RecLock("REL", .T.); REL->LINHA := space(17)+alltrim(substr(QRY->B1_DESC,126,41)); REL->(DbUnlock()); nL++
			endif
			if len(trim(substr(QRY->B1_DESC,168,41))) > 0
				RecLock("REL", .T.); REL->LINHA := space(17)+alltrim(substr(QRY->B1_DESC,168,41)); REL->(DbUnlock()); nL++
			endif
			if len(trim(substr(QRY->B1_DESC,210,41))) > 0
				RecLock("REL", .T.); REL->LINHA := space(17)+alltrim(substr(QRY->B1_DESC,210,41)); REL->(DbUnlock()); nL++
			endif
			if len(trim(substr(QRY->B1_DESC,252,41))) > 0
				RecLock("REL", .T.); REL->LINHA := space(17)+alltrim(substr(QRY->B1_DESC,252,41)); REL->(DbUnlock()); nL++
			endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Registra a cotacao atual como enviada.                              �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !RES->(DBSeek(QRY->A2_COD+QRY->C8_NUM))
				RecLock("RES", .T.)
				RES->FORNCOD := QRY->A2_COD
				RES->FORNNOM := QRY->A2_NOME
				RES->FORNEML := QRY->A2_EMAIL
				RES->COTACAO := QRY->C8_NUM
				RES->(DbUnlock())
			endif
			
		else
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Se o fornecedor atual nao possuir e-mail registra a falha para ...  �
			//� ser exibida posteriormente no relatorio final de envio.             �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !RES->(DBSeek(QRY->A2_COD))
				RecLock("RES", .T.)
				lFalhas      := .T.
				RES->FORNCOD := QRY->A2_COD
				RES->FORNNOM := QRY->A2_NOME
				RES->COTACAO := QRY->C8_NUM
				RES->MSGERRO := "E-MAIL NAO CADASTRADO!!"
				RES->(DbUnlock())
			endif
		endif
		
		QRY->(DbSkip())
		
		if ((cCodFor <> QRY->A2_COD) .OR. QRY->(EOF())) .AND. (REL->(LastRec()) > 0)
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Grava rodape da cotacao e transforma o arquivo temporario em ...    �
			//� arquivo texto para que seja anexado ao e-mail.                      �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			RecLock("REL", .T.); REL->LINHA := replicate("-",80); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := trim(Upper(MV_PAR03)); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := trim(Upper(MV_PAR04)); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "TEL.: " + trim(Upper(MV_PAR05)); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "FAX.: " + trim(Upper(MV_PAR06)); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := trim(lower(MV_PAR07)); REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := ""                                     ; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "ATENCAO!! A VALIDADE DA COTACAO E DE 24H APOS CONFIRMACAO DO RECEBIMENTO."; REL->(DbUnlock()); nL++
			
			cArqTemp3 := cArqTemp2 + ".TXT"
			DBSelectArea("REL")
			Copy to &cArqTemp3 SDF
			DBCloseArea("REL")
			lRelAberto := .F.
			cMailFor := iif(Upper(AllTrim(getenvserver()))=="PRODUCAO",cMailFor,alltrim(GETMV("MV_YEMLTST")))
			
			cMensagem 		:= cTexto
			cAssunto 		:= MV_PAR08
			cRemetente		:= MV_PAR07                        
			aDestinatario 	:= cMailFor
			aCC 			:= MV_PAR09
			aCCO 			:= MV_PAR10
			cErro			:= ""
			cAnexo			:= iif(Upper(AllTrim(getenvserver()))=="PRODUCAO","\SIGAADV\","\SIGADES\")+cArqTemp3

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Envia e-mail e registra possivel falha de envio.                    �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			
			if !U_BIAEnvMail(,aDestinatario,cAssunto,cMensagem,cErro,cAnexo,,aCC,aCCO )
				if !RES->(DBSeek(QRY->A2_COD+QRY->C8_NUM))
					RecLock("RES", .T.)
					lFalhas      := .T.
					RES->FORNCOD := QRY->A2_COD
					RES->FORNNOM := QRY->A2_NOME
					RES->COTACAO := QRY->C8_NUM
					RES->MSGERRO := "FALHA NO ENVIO DO E-MAIL!!"
					RES->(DbUnlock())
					
					RES->(DBGoTop())
					do while !RES->(EOF())
						if RES->FORNCOD == QRY->A2_COD .AND. !empty(RES->COTACAO) .AND. empty(RES->MSGERRO)
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
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Gera Relatorio Final de Envio.                                      �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	if RES->(LastRec()) > 0
		cArqTemp2 := CriaTrab(aCampos, .T.)
		DbUseArea(.T.,, cArqTemp2, "REL")
		
		RecLock("REL", .T.); REL->LINHA := "RELATORIO DE ENVIO DE COTACOES PELO SIGA"   ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "========================================"   ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "PARAMETROS:"   ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Data...............: "+dtoc(date()); REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Da Cotacao.........: "+MV_PAR01    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Ate Cotacao........: "+MV_PAR02    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Responsavel........: "+MV_PAR03    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Setor Responsavel..: "+MV_PAR04    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Tel. Responsavel...: "+MV_PAR05    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Fax. Responsavel...: "+MV_PAR06    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  E-mail Responsavel.: "+MV_PAR07    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Copia Para.........: "+MV_PAR09    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Copia Oculta Para..: "+MV_PAR10    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Titulo Padrao......: "+MV_PAR08    ; REL->(DbUnlock())
		RecLock("REL", .T.); REL->LINHA := "  Texto Padrao.......: "+SUBSTR(cTexto,1,50); REL->(DbUnlock())
		if len(alltrim(substr(cTexto,51,50))) > 0
			RecLock("REL", .T.); REL->LINHA := "                      "+SUBSTR(cTexto,51,50); REL->(DbUnlock())
		endif
		if len(alltrim(substr(cTexto,101,50))) > 0
			RecLock("REL", .T.); REL->LINHA := "                      "+SUBSTR(cTexto,101,50); REL->(DbUnlock())
		endif
		if len(alltrim(substr(cTexto,151,50))) > 0
			RecLock("REL", .T.); REL->LINHA := "                      "+SUBSTR(cTexto,151,50); REL->(DbUnlock())
		endif
		if len(alltrim(substr(cTexto,201,50))) > 0
			RecLock("REL", .T.); REL->LINHA := "                      "+SUBSTR(cTexto,201,50); REL->(DbUnlock())
		endif
		if len(alltrim(substr(cTexto,251,50))) > 0
			RecLock("REL", .T.); REL->LINHA := "                      "+SUBSTR(cTexto,251,50); REL->(DbUnlock())
		endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Inclui no relatorio de envio os fornecedores que tiveram e-mail ... �
		//� enviados com sucesso.                                               �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if lEnviados
			RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "COTACOES ENCAMINHADAS:"; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Forn..  Nome....................................  E-mail......................................"; REL->(DbUnlock())
			ProcRegua(LastRec())
			RES->(DBGoTop())
			do while !RES->(EOF())
				IncProc("Enviando e-mails ...")
				if !empty(RES->COTACAO) .AND. empty(RES->MSGERRO)
					RecLock("REL", .T.); REL->LINHA := "  "+RES->FORNCOD+"  "+padr(RES->FORNNOM,40)+"  "+RES->FORNEML; REL->(DbUnlock())
				endif
				RES->(DbSkip())
			enddo
		endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Inclui no relatorio de envio os fornecedores que tiveram falhas ... �
		//� no envio do e-mail.                                                 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if lFalhas
			RecLock("REL", .T.); REL->LINHA := ""; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "FALHAS:"; REL->(DbUnlock())
			RecLock("REL", .T.); REL->LINHA := "  Forn..  Nome....................................  Falhas......................................"; REL->(DbUnlock())
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
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Transforma o arquivo temporario em arquivo texto para que seja  ... �
		//� enviado por e-mail ao responsavel pelas cotacoes.                   �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		cArqTemp3 := cArqTemp2 + ".TXT"
		DBSelectArea("REL")
		Copy to &cArqTemp3 SDF
		DBCloseArea("REL")
		
		cMensagem 		:= memoread(cArqTemp3)// cTexto
		cAssunto 		:="Re:ENVIO DE COTACOES PELO SIGA" //MV_PAR08
		cRemetente		:= MV_PAR07                        
		aDestinatario 	:= {iif(Upper(AllTrim(getenvserver()))=="PRODUCAO",MV_PAR07,alltrim(GETMV("MV_YEMLTST")))} //cMailFor
		aCC 			:= MV_PAR09
		aCCO 			:= MV_PAR10
		cErro			:= "Problemas na transmissao do relatorio de envio!"
		cAnexo			:= ""
		
		U_BIAEnvMail(,aDestinatario,cAssunto,cMensagem,cErro,cAnexo,,aCC,aCCO )
		
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪勘�
北矲uncao	 砯ApagaTemp� Autor � WLADIMIR ILLIUSHENKO					     潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矰escricao � Exclui a tabela temporaria.							           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static function fApagaTemp()
RES->(DbCloseArea("RES"))
aeval(directory(cArqTemp1+".*"),{ |aFile| FErase(aFile[1])})
aeval(directory(cArqTemp2+".*"),{ |aFile| FErase(aFile[1])}) 
return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪勘�
北矲uncao	 � fFinaliza  � Autor � WLADIMIR ILLIUSHENKO 			        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矰escricao � Finaliza digitacao do corpo do e-mail.                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function fFinaliza()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fecha a caixa de dialogo.                                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
lOk := .F.
Close(oDialog)
Return