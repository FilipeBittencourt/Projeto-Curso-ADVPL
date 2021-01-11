#INCLUDE "RWMAKE.CH"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"

User Function BIA272(lPrintFile, cNumBco)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA272
Empresa   := Biancogres Ceramica S.A.
Data      := 21/11/11
Uso       := Financeiro
Aplicação := Impressão de boleta bancária - Banco do Brasil e Bradesco
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local	aPergs     := {}
Private lExec      := .F.
Private cIndexName := ''
Private cIndexKey  := ''
Private cFilter    := ''
Private wqJrs      := .F.
Private jkJuros    := 0
Private jVenctOr   := ctod("  /  /  ")
Private jSalOri    := 0
Private lPrintLeg 	:= .F.
Private lFimPage	:= .T.			
Private oPrint		
// Variaveis para controle de impressao em arquivo
Private cPasBol := "\P10\COB\BOLETO\"
Private cHtmlFile := ""
Default lPrintFile := .F.
Default cNumBco := ""
PRIVATE M->DV1_ASBAC := ''
PRIVATE M->DV2_ASBAC := ''

MsgSTOP("Rotina desativada! A emissão de boletos deve ser feita utilizando o Portal de Clientes.", "Atenção")
Return

Tamanho  := "M"
titulo   := "Impressão de Boleto com Código de Barras"
cDesc1   := "Este programa destina-se a impressão de Boleto com Código de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BIA272"
lEnd     := .F.
cPerg    := "BIA272"
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0

dbSelectArea("SE1")
fPerg := "BIA272"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()

dbSelectArea( "SX1" )
dbSetOrder(1)
If dbSeek( PADR(fPerg,fTamX1) + "09" )
	RecLock("SX1",.F.)
	SX1->X1_CNT01 := dtoc(dDataBase)
	MsUnlock()
EndIf

	// Impressao em arquivo
	If lPrintFile
	 	
	 	ddDatOld := dDataBase
	 	
	 	cIndexName := Criatrab(Nil,.F.)
		cIndexKey	:= "E1_NUMBCO"

		cFilter	+= " E1_FILIAL == '"+xFilial("SE1")+"'
		cFilter	+= " .AND. E1_NUMBCO == '"+cNumBco+"'
		
		IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "")
				
		cHtmlFile := cPasBol + cNumBco + ".HTML"
				
		Mb272Rel(lPrintFile)

		RetIndex("SE1")
		Ferase(cIndexName+OrdBagExt())		
		
	Else

		If !Pergunte(fPerg,.T.)
			Return
		EndIf
		
		ddDatOld  := dDataBase	
		//dDataBase := MV_PAR09
		
		nCol := oMainWnd:nClientWidth
		nLin := oMainWnd:nClientHeight
		
		cIndexName	:= Criatrab(Nil,.F.)
		cIndexKey	:= "E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)+E1_PORTADO+E1_CLIENTE"
		
		cFilter		+= " E1_FILIAL == '"+xFilial("SE1")+"'
		cFilter		+= " .and. E1_SALDO > 0
		cFilter		+= " .and. E1_PREFIXO >= '"+MV_PAR01+"'
		cFilter		+= " .and. E1_PREFIXO <= '"+MV_PAR02+"'
		cFilter		+= " .and. E1_NUM >= '"+MV_PAR03+"'
		cFilter		+= " .and. E1_NUM <= '"+MV_PAR04+"'
		cFilter		+= " .and. E1_CLIENTE >= '"+MV_PAR05+"'
		cFilter		+= " .and. E1_CLIENTE <= '"+MV_PAR06+"'
		cFilter		+= " .and. !Empty(SE1->E1_NUMBCO)
		// Incluído em 23/07/12 por Marcos Alberto Soprani conforme Effettivo 0873-12
		If !Empty(Alltrim(cRepAtu))
			cFilter		+= " .and. E1_VEND1 = '"+cRepAtu+"'
			cFilter		+= " .and. dtos(E1_VENCTO) >= '"+dtos(dDataBase)+"'
			cFilter		+= " .and. dtos(E1_VENCTO) <= '"+dtos(MV_PAR08)+"'
		Else
			//Permite a impressão de Boletos Vencidos somente para o Contas a Receber. Demais acessos somente a vencer - Ranisses em 28/07/2015
			If U_VALOPER("021",.F.)
   			cFilter		+= " .and. dtos(E1_VENCTO) >= '"+dtos(MV_PAR07)+"'
				cFilter		+= " .and. dtos(E1_VENCTO) <= '"+dtos(MV_PAR08)+"'
				dDataBase 	:= MV_PAR09
    	Else
				cFilter		+= " .and. dtos(E1_VENCTO) >= '"+dtos(dDataBase)+"'
				cFilter		+= " .and. dtos(E1_VENCTO) <= '"+dtos(MV_PAR08)+"'
			EndIf
		EndIf		
		
		// Tiago Rossini - OS: 0870-15 - Clebes Jose Andre
		// Somente o usuário do Vagner podera imprimir títulos em cartório
		If __cUserID <> "000093"
			
			// Tiago Rossini - OS: 1814-13 - Clebes Jose Andre
			// Verifica se o titulo esta em cartório
			cFilter	+= " .And. U_BIAF011(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO) "	
			
		EndIf
		
		
		IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
		
		dbSelectArea("SE1")
		#IFNDEF TOP
			dbSetIndex(cIndexName + OrdBagExt())
		#ENDIF
		
		dbGoTop()
		
		@ nLin*.001, nCol*.001 TO nLin*.750, nCol*.900 Dialog oDlg TITLE "Seleção de Titulos"
		@ nLin*.004, nCol*.003 TO nLin*.350, nCol*.450 Browse "SE1" MARK "E1_OK"
		@ nLin*.355, nCol*.410 BmpButton Type 01 Action (lExec := .T.,Close(oDlg))
		@ nLin*.355, nCol*.380 BmpButton TYPE 02 Action (dDataBase := ddDatOld, lExec := .F., Close(oDlg))
		Activate Dialog oDlg Centered
		
		dbGoTop()
		If lExec
			Processa({|lEnd|Mb272Rel()})
		Endif
		
		RetIndex("SE1")
		Ferase(cIndexName+OrdBagExt())
		
	EndIf

Return(cHtmlFile)

User Function BIA272P(cListaId)

	Local nI			:= 0
	Private oPrint 				:= TMSPrinter():New("Boleto Gráfico")
	Private	lFimPage	:= .F.			
	Private lPrintLeg	:= .T.

	MsgSTOP("Rotina desativada! A emissão de boletos deve ser feita utilizando o Portal de Clientes.", "Atenção")
	Return
	
	aList	:= StrTokArr( cListaID, "_" )
	
	For nI	:=1 To Len(aList)
		
		lFimPage	:= .F.
		If (nI == Len(aList))
			lFimPage	:= .T.	
		EndIf
		
		If (!Empty(aList[nI]))
			Mb272Rel(.F., aList[nI])
		EndIf
		
		
	Next nI

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Mb272Rel ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Monta Estrutura do Relatório                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Mb272Rel(lPrintFile, cIdRecno)

Local nX          := 0
Local cNroDoc     :=  " "
Local aDadosEmp   := {If (cEmpAnt == "07", "LM-COMERCIO ATACAD. DE MAT. CONST. LTDA.", AllTrim(SM0->M0_NOMECOM)),; //[1]Nome da Empresa
AllTrim(SM0->M0_ENDCOB),; //[2]Endereço
AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB,; //[3]Complemento
"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; //[4]CEP
"PABX/FAX: "+SM0->M0_TEL,; //[5]Telefones
"CNPJ: "+Transform(SM0->M0_CGC ,"@R 99.999.999/9999-99"),; //[6]CGC
"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}  //[7]I.E
Local aDadosTit
Local aDadosBanco
Local aDatSacado
Local aBolText    	:= { "","","" }
Local nI          	:= 1
Local aCB_RN_NN   	:= {}
Local nVlrAbat		:= 0
Local nVlrDesc		:= 0 // Valor de desconto - utilizado somente para titulos PR
Local nBanco		:= ""
Local nAgen			:= ""
Local nConta		:= ""
Local nCart			:= ""
Private nVlrAcre	:= 0
Private oRecAnt		:= TRecebimentoAntecipado():New()

// Variavel para controle de impressao em arquivo
Default lPrintFile	:= .F.
		
	// Tiago Rossini Coradini - Tratamento para salvar boleto HTML via chamada RPC.
	If (!lPrintLeg)
	
		If lPrintFile //.And. FunName() == "RPC"
			
			lPreview := .F. // Impressão sem previa
			lRpc := .T. // Impressão sem interface com o usuario
			
			oPrint := TMSPrinter():New("Boleto Gráfico",,,,,,lPreview,,lRpc)
	 		
		Else
			oPrint := TMSPrinter():New("Boleto Gráfico")
		EndIf
	
	EndIf
	
oPrint:SetPortrait()
oPrint:StartPage()
DbSelectArea("SE1")
DbGotop()

If (lPrintLeg)
	DbGoto(Val(cIdRecno))
EndIf

ProcRegua(RecCount())

//While SE1->(!EOF())
While	SE1->(!EOF())
	
	If !lPrintFile
		
		IncProc()
	
	    //Quando nao estiver selecionado despreza o registro
	    If (!lPrintLeg)
	        dbSelectArea("SE1")	
			If !Marked("E1_OK")
				DbSelectArea("SE1")
				DbSkip()
				Loop
			EndIf
		EndIf
		
	EndIf
		
	nVlrAcre	:= 0
	wqJrs     := .F.
	jkJuros   := 0
	jVenctOr  := SE1->E1_VENCTO
	jSalOri   := SE1->E1_SALDO - nVlrAbat
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	
	nBanco	:= SE1->E1_PORTADO
	nAgen	:= SE1->E1_AGEDEP
	nConta	:= SE1->E1_CONTA
	
	If SE1->E1_PORTADO == "001"
	
		nCart	:= "17"
	
	ElseIf SE1->E1_PORTADO == "021"
	
		nCart	:= "11"
		
	Else
		
		nCart	:= "09"
		
	EndIf
	
	mb_MnPrt := ""
	If SA1->A1_YDTPRO >= 6
		mb_MnPrt := "PROTESTAR APÓS "+Alltrim(Str(SA1->A1_YDTPRO))+" DIAS CORRIDOS"
	Else
		mb_MnPrt := "PROTESTAR APÓS "+Alltrim(Str(SA1->A1_YDTPRO))+" DIAS UTEIS"
	EndIf
	
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6") + nBanco + nAgen + nConta,.T.)
	
	// Banestes nao digito da conta
	If nBanco == "021"
		
		cConta := AllTrim(SA6->A6_NUMCON)
		cDigCon := ""
		
	Else	
		
		cConta := Substr(SA6->A6_NUMCON, 1, Len(AllTrim(SA6->A6_NUMCON))-1)
		cDigCon := Substr(SA6->A6_NUMCON, Len(AllTrim(SA6->A6_NUMCON)), 1)
		
	EndIf
	
	dbSelectArea("SE1")
	aDadosBanco  := {SA6->A6_COD                                                                                       ,; 	// [1]Numero do Banco
	SA6->A6_NREDUZ                                                                                                     ,; 	// [2]Nome do Banco
	Substr(SA6->A6_AGENCIA, 1, 4)+IIF(!Empty(Substr(SA6->A6_AGENCIA, 5, 1)), "-"+Substr(SA6->A6_AGENCIA, 5, 1), "")    ,; 	// [3]Agência
	cConta,; 	// [4]Conta Corrente
	cDigCon,; 	// [5]Dígito da conta corrente
	nCart                                                                                                               }  // [6]Codigo da Carteira
	
	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {AllTrim(SA1->A1_NOME)              ,;    // [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;    // [2]Código
		AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO)   ,;    // [3]Endereço
		AllTrim(SA1->A1_MUN )                               ,;    // [4]Cidade
		SA1->A1_EST                                         ,;    // [5]Estado
		SA1->A1_CEP                                         ,;    // [6]CEP
		SA1->A1_CGC										                      ,;  	// [7]CGC
		SA1->A1_PESSOA										                   }    // [8]PESSOA
	Else
		aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]Código
		AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
		AllTrim(SA1->A1_MUNC)	                            ,;   	// [4]Cidade
		SA1->A1_ESTC	                                    ,;   	// [5]Estado
		SA1->A1_CEPC                                        ,;   	// [6]CEP
		SA1->A1_CGC												 		              ,;		// [7]CGC
		SA1->A1_PESSOA												               }		// [8]PESSOA
	Endif
	
	// Esta parte do programa foi copiada igualmente do fonte BLTCDBB
	//Cobranca de Tarifa, apenas para titulos de ST
	If SA1->A1_YTFGNRE == "S" //Apenas para clientes com cobranca de GNRE
		If SE1->E1_YCLASSE == "1"
			//Tratamento da OS 3382-15 em 02/09/2015
			
			oTafNFRE	:= TAFTarifaGNRE():New()
			nVlrAcre	:= oTafNFRE:TarifaPorEstado(SE1->E1_YUFCLI)
			
				
			/*If cEmpAnt == "07" .And. Alltrim(SE1->E1_YEMP) == "0599" .And. Alltrim(SE1->E1_YUFCLI) $ "SP_MG" 
				If Dtos(SE1->E1_EMISSAO) >= "20150903"
					If Alltrim(SE1->E1_YUFCLI) == "MG"
						nVlrAcre	:= GetMv("MV_YVLBLMG")
					ElseIf Alltrim(SE1->E1_YUFCLI) == "SP"
						nVlrAcre	:= GetMv("MV_YVLBLSP")
					End If
				Else
					nVlrAcre	:= 0
				EndIf
			Else			
				If Alltrim(SE1->E1_YUFCLI) == "MG"
					nVlrAcre	:= GetMv("MV_YVLBLMG")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "ES"
					nVlrAcre	:= GetMv("MV_YVLBLES")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "SP"
					nVlrAcre	:= GetMv("MV_YVLBLSP")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "BA"
					nVlrAcre	:= GetMv("MV_YVLBLBA")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "RJ"
					nVlrAcre	:= GetMv("MV_YVLBLRJ")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "AL"
					nVlrAcre	:= GetMv("MV_YVLBLAL")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "RS"
					nVlrAcre	:= GetMv("MV_YVLBLRS")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "PR"
					nVlrAcre	:= GetMv("MV_YVLBLPR")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "SC"
					nVlrAcre	:= GetMv("MV_YVLBLSC")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "AP"
					nVlrAcre	:= GetMv("MV_YVLBLAP")
				ElseIf Alltrim(SE1->E1_YUFCLI) == "PE"
					nVlrAcre	:= GetMv("MV_YVLBLPE")			
				Else
					nVlrAcre	:= 0
				End If
			EndIf
			*/
			
		EndIf
	EndIf
	
	
	If !lPrintFile	
	
		nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)		
		
		// Implementado por Marcos Alberto Soprani em 27/07/12 conforme OS Effettivo 0872-12
		If (SE1->E1_VENCTO < dDataBase .And. Marked("E1_OK")) .Or. (SE1->E1_VENCTO < dDataBase .And. lPrintLeg)
			wqJrs := .T.
			If MsgNOYES("Deseja calcular o juros para esta boleta?")
				//jkJuros   := fa070Juros(1, SE1->E1_SALDO-nVlrAbat) 							//DESATIVADO EM 29/07/13 POIS O SISTEMA NÃO ESTAVA CANCULANDO JUROS DE ACORDO COM O BANCO.
				//jkJuros	:= ROUND(SE1->E1_PORCJUR*SE1->E1_VALOR/100,2) * (DDATABASE-SE1->E1_VENCTO) 	//DESATIVADO EM 10/03/2015 CONFORME OS 1027-15 - ALTERAÇÃO NO CALCULO DO JUROS
				jkJuros	:= NOROUND(SE1->E1_PORCJUR*SE1->E1_VALOR/100,2) * (DDATABASE-SE1->E1_VENCTO) 		//1103-15 EM 25/03/2015 os arquivos de CNAB foram configurados para não arredondar o valor o juros.
			EndIf
			jVenctOr  := SE1->E1_VENCTO
			jSalOri   := SE1->E1_SALDO - nVlrAbat
		EndIf
		
	EndIf
	
	cNroDoc	:= SE1->E1_NUMBCO
	
	// Desconto consedido - utilizado somento para titulos PR
	If oRecAnt:TituloPr() .And. SE1->E1_DECRESC > 0
		nVlrDesc := SE1->E1_DECRESC
	EndIf
	
	//Monta codigo de barras
	aCB_RN_NN := Ret_B272(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, Subs(aDadosBanco[1],1,3), aDadosBanco[3], aDadosBanco[4], aDadosBanco[5],;
												cNroDoc, ((SE1->E1_SALDO + jkJuros - (nVlrAbat + nVlrDesc) + nVlrAcre)), "17", "9"	)
	
	dbSelectArea("SE1")
	aDadosTit	:= {(SE1->E1_NUM)+" "+Alltrim(SE1->E1_PARCELA),; // [1] Número do título/Parcela
	SE1->E1_EMISSAO,; // [2] Data da emissão do título
	dDataBase,;	// [3] Data da emissão do boleto
	IIF(SE1->E1_VENCTO < dDataBase, dDataBase, SE1->E1_VENCTO),; // [4] Data do vencimento
	(SE1->E1_SALDO + jkJuros - nVlrAbat),; // [5] Valor do título
	aCB_RN_NN[3],; // [6] Nosso número (Ver fórmula para calculo)
	SE1->E1_PREFIXO,; // [7] Prefixo da NF
	SE1->E1_TIPO,; // [8] Tipo do Titulo
	SE1->E1_PEDIDO,; // [9] Numero do pedido de venda
	oRecAnt:TituloPr(),;
	nVlrDesc} // [11] Valor de desconto

	If lPrintFile
		
		Impr272(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,lPrintFile)
		
	Else

		dbSelectArea("SE1")
		
		If Marked("E1_OK") .Or. lPrintLeg
			Impr272(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
			nX := nX + 1
			dbSelectArea("SE1")
		EndIf
		
	EndIf
	
	dbSkip()

	nI++

	If (lPrintLeg) //executar apenas uma vez
		Exit
	EndIf
EndDo

	
	If (lFimPage)	
	
		oPrint:EndPage()
	
		If lPrintfile
		
			If File(cHtmlFile)
				fErase(cHtmlFile)
			EndIf		
			
			If !oPrint:SaveAsHtml(cHtmlFile)
				oPrint:Preview()
				oPrint:SaveAsHtml(cHtmlFile)
			EndIf
		
		Else
			oPrint:Preview()
		EndIf
	
	EndIf
Return()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Mb272Rel ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Impressão do Relatório                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Impr272(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,lPrintFile)

Local oFont8
Local oFont11c

Local oFont10
Local oFont14
Local oFont16n
Local oFont15
Local oFont14n
Local oFont24
Local nI := 0

Default lPrintFile := .F.

oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()

// Verifica se o título é proveniente de Fatura
ddfArea := GetArea()
cl_Duplic := ""
If Alltrim(aDadosTit[8]) == "FT"
	TK001 := " SELECT DISTINCT RTRIM(E1_NUM)+'/'+E1_PARCELA DUPLIC
	TK001 += " FROM " + RetSqlName("SE1")
	TK001 += " WHERE  E1_FILIAL  = '"+xFilial("SE1")+"'
	TK001 += "    AND E1_FATPREF = '"+aDadosTit[7]+"'
	TK001 += "    AND E1_FATURA  = '"+Substr(aDadosTit[1],1,9)+"'
	TK001 += "    AND E1_YPARCFT = '"+Substr(aDadosTit[1],11,1)+"'
	TK001 += "    AND E1_TIPOFAT = '"+aDadosTit[8]+"'
	TK001 += "    AND E1_FLAGFAT = 'S'
	TK001 += "    AND D_E_L_E_T_ = ' '
	TcQuery TK001 New Alias "TK01"
	dbSelectArea("TK01")
	dbGoTop()
	While !Eof()
		cl_Duplic += TK01->DUPLIC+" "
		dbSelectArea("TK01")
		dbSkip()
	End
	TK01->(dbCloseArea())
EndIf
RestArea(ddfArea)

/*************************************************************************************************************************************************/
/* PRIMEIRA PARTE */
/*************************************************************************************************************************************************/
nRow1 := 0

oPrint:Line (0150,500,0070, 500)
oPrint:Line (0150,710,0070, 710)

If aDadosBanco[1] == "001"
	oPrint:Say  (0084,100,"Banco do Brasil"                                   ,oFont11 ) //aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (0075,513,aDadosBanco[1]+"-9"                                 ,oFont20 ) // [1]Numero do Banco	
ElseIf aDadosBanco[1] == "021"
	oPrint:Say  (0084,100,"Banestes"                                          ,oFont11 ) //aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (0075,513,aDadosBanco[1]+"-3"                                 ,oFont20 ) // [1]Numero do Banco
ElseIf aDadosBanco[1] == "237"
	oPrint:Say  (0084,100,"Bradesco"                                          ,oFont11 ) //aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (0075,513,aDadosBanco[1]+"-2"                                 ,oFont20 ) // [1]Numero do Banco
EndIf

oPrint:Say  (nRow1+0084,1900,"Comprovante de Entrega"                       ,oFont10 )
oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

oPrint:Say  (nRow1+0150,100 ,"Beneficiário",oFont8)
oPrint:Say  (nRow1+0200,100 ,aDadosEmp[1]                                   ,oFont10 ) //Nome + CNPJ

oPrint:Say  (nRow1+0150,1060,"Agência/Código Beneficiário"                       ,oFont8 )

If aDadosBanco[1] == "237" .And. cEmpAnt == "07"
	sf_RefBco := AllTrim(aDadosBanco[3]) + "-4" + "/0000" + AllTrim(aDadosBanco[4]) + aDadosBanco[5] + "-5"
Else
	sf_RefBco := aDadosBanco[3]+"/"+aDadosBanco[4]+""+aDadosBanco[5]
EndIf

oPrint:Say  (nRow1+0200,1060,sf_RefBco                                      ,oFont10 )

oPrint:Say  (nRow1+0150,1510,"Nro.Documento"                                ,oFont8 )
oPrint:Say  (nRow1+0200,1510,aDadosTit[7]+aDadosTit[1]                      ,oFont10 ) //Prefixo +Numero+Parcela

oPrint:Say  (nRow1+0250,100 ,"Pagador"                                       ,oFont8 )
oPrint:Say  (nRow1+0300,100 ,aDatSacado[1]                                  ,oFont10 ) //Nome

oPrint:Say  (nRow1+0250,1060,"Vencimento"                                   ,oFont8 )
oPrint:Say  (nRow1+0300,1060,dtoc(aDadosTit[4])                             ,oFont10 )

oPrint:Say  (nRow1+0250,1510,"Valor do Documento"                           ,oFont8 )
sf_VrlTt := AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))
oPrint:Say  (nRow1+0300,1550, sf_VrlTt                                      ,oFont10 )

oPrint:Say  (nRow1+0400,0100,"Recebi(emos) o bloqueto/título"               ,oFont10 )
oPrint:Say  (nRow1+0450,0100,"com as características acima."                ,oFont10 )
oPrint:Say  (nRow1+0350,1060,"Data"                                         ,oFont8 )
oPrint:Say  (nRow1+0350,1410,"Assinatura"                                   ,oFont8 )
oPrint:Say  (nRow1+0450,1060,"Data"                                         ,oFont8 )
oPrint:Say  (nRow1+0450,1410,"Entregador"                                   ,oFont8 )

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 )
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 )
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

oPrint:Say  (nRow1+0165,1910,"(  )Mudou-se"                                	,oFont8)
oPrint:Say  (nRow1+0205,1910,"(  )Ausente"                                  ,oFont8)
oPrint:Say  (nRow1+0245,1910,"(  )Não existe nº indicado"                  	,oFont8)
oPrint:Say  (nRow1+0285,1910,"(  )Recusado"                                	,oFont8)
oPrint:Say  (nRow1+0325,1910,"(  )Não procurado"                            ,oFont8)
oPrint:Say  (nRow1+0365,1910,"(  )Endereço insuficiente"                  	,oFont8)
oPrint:Say  (nRow1+0405,1910,"(  )Desconhecido"                             ,oFont8)
oPrint:Say  (nRow1+0445,1910,"(  )Falecido"                                 ,oFont8)
oPrint:Say  (nRow1+0485,1910,"(  )Outros(anotar no verso)"                  ,oFont8)

/*************************************************************************************************************************************************/
/* SEGUNDA PARTE */
/*************************************************************************************************************************************************/
nRow2 := 0

For nI := 100 to 2300 step 50   //Pontilhado separador
	oPrint:Line(0580, nI,0580, nI+30)
Next nI

oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
oPrint:Line (nRow2+0710,710,nRow2+0630, 710)
If aDadosBanco[1] == "001"
	oPrint:Say  (nRow2+0644,100,"Banco do Brasil"                               ,oFont11 ) //aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-9"                             ,oFont20 ) // [1]Numero do Banco
ElseIf aDadosBanco[1] == "021"
	oPrint:Say  (nRow2+0644,100,"Banestes"                                      ,oFont11 ) //aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-3"                             ,oFont20 ) // [1]Numero do Banco
ElseIf aDadosBanco[1] == "237"
	oPrint:Say  (nRow2+0644,100,"Bradesco"                                      ,oFont11 ) //aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-2"                             ,oFont20 ) // [1]Numero do Banco
EndIf
oPrint:Say  (nRow2+0644,1800,"Recibo do Pagador",oFont10)

oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

oPrint:Line (nRow2+0910,500,nRow2+1050,500)
oPrint:Line (nRow2+0980,750,nRow2+1050,750)
oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

oPrint:Say  (nRow2+0710,100 ,"Local de Pagamento",oFont8)
If aDadosBanco[1] == "001"
	
	If lPrintFile .Or. aDadosTit[10] // Titulo provisorio de RA
		oPrint:Say  (nRow2+0725,400 ,"Preferencialmente no BANCO DO BRASIL",oFont10)
	Else
		oPrint:Say  (nRow2+0725,400 ,"Até o vencimento, preferencialmente no BANCO DO BRASIL",oFont10)
		oPrint:Say  (nRow2+0765,400 ,"Após o vencimento, somente no BANCO DO BRASIL"  ,oFont10)
	EndIf

ElseIf aDadosBanco[1] == "021"
	oPrint:Say  (nRow2+0725,400 ,"Até o vencimento, preferencialmente no BANESTES",oFont10)
	oPrint:Say  (nRow2+0765,400 ,"Após o vencimento, somente no BANESTES"  ,oFont10)	
ElseIf aDadosBanco[1] == "237"
	oPrint:Say  (nRow2+0725,400 ,"Até o vencimento, preferencialmente no BRADESCO",oFont10)
	oPrint:Say  (nRow2+0765,400 ,"Após o vencimento, somente no BRADESCO"  ,oFont10)
EndIf

oPrint:Say  (nRow2+0710,1810,"Vencimento"                                     ,oFont8)
cString	:= dtoc(aDadosTit[4])
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0750,nCol,cString                                          ,oFont11c)

oPrint:Say  (nRow2+0810,100 ,"Beneficiário"                                        ,oFont8)
oPrint:Say  (nRow2+0850,100 ,aDadosEmp[1]+"                  - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow2+0810,1810,"Agência/Código Beneficiário"                         ,oFont8)

If aDadosBanco[1] == "237" .And. cEmpAnt == "07"
	cString := AllTrim(aDadosBanco[3]) + "-4" + "/0000" + AllTrim(aDadosBanco[4]) + aDadosBanco[5] + "-5"
Else
	cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+""+aDadosBanco[5])
EndIf

nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0850,nCol,cString                                          ,oFont11c)

oPrint:Say  (nRow2+0910,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (nRow2+0940,100, dtoc(aDadosTit[2])                               ,oFont10)

oPrint:Say  (nRow2+0910,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow2+0940,605 ,aDadosTit[7]+aDadosTit[1]					            	,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow2+0910,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (nRow2+0940,1050,"DM"									                          	,oFont10) //Tipo do Titulo

oPrint:Say  (nRow2+0910,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow2+0940,1400,"N"                                              ,oFont10)

oPrint:Say  (nRow2+0910,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow2+0940,1550,dtoc(aDadosTit[3])                               ,oFont10) // Data impressao

oPrint:Say  (nRow2+0910,1810,"Nosso Número"                                   ,oFont8)
cString := aCB_RN_NN[3]

If aDadosBanco[1] == "001"
	nDvnn   := modulo11(aCB_RN_NN[3])
	cString := aCB_RN_NN[3] + '-' + AllTrim(Str(nDvnn))
ElseIf aDadosBanco[1] == "021" 
	cString := Transform(cString, "@R 99999999-99")
ElseIf aDadosBanco[1] == "237"
	cString := aDadosBanco[6]+aCB_RN_NN[3]
	cString := Transform(cString, "@R 99/99/999999999-9")
EndIf
nCol := 1900+(374-(len(cString)*22))
oPrint:Say  (nRow2+0940,nCol,cString                                          ,oFont11c)

oPrint:Say  (nRow2+0980,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow2+0980,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow2+1010,555 ,aDadosBanco[6]                                  	,oFont10)

oPrint:Say  (nRow2+0980,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow2+1010,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow2+0980,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow2+0980,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow2+0980,1810,"Valor do Documento"                          	  ,oFont8)
cString := AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+1010,nCol,cString ,oFont11c)

oPrint:Say  (nRow2+1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)",oFont8)

	If lPrintFile .Or. aDadosTit[10] // Titulo provisorio de RA
	
		xkMensa1 := "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA "+dtoc(aDadosTit[4])
		xkMensa2 := "Boleto referente ao pedido de venda: "+ AllTrim(Upper(aDadosTit[9]))
		oPrint:Say  (nRow2+1100,100 , xkMensa1                                                                       ,oFont15)
		oPrint:Say  (nRow2+1170,100 , xkMensa2                                                                       ,oFont11)
		
		If aDadosTit[11] > 0 // Boleto com desconto 		
			xkMensa3 := "Desconto concedido: "+ AllTrim(Transform(aDadosTit[11],"@E 999,999,999.99"))
			__nVal := 1240
			oPrint:Say(nRow2 + __nVal, 100, xkMensa3, oFont11)
		EndIf
	
	ElseIf !wqJrs

		//CALCULANDO JUROS POR DIA
		ssJUROS := (6/30)
		sJUROS_DIA := ((ssJUROS/100)*aDadosTit[5])
		oPrint:Say  (nRow2+1100,100 , "JUROS POR UM DIA: * R$ " + Alltrim(Transform(sJUROS_DIA,"@E 99,999,999.99"))  ,oFont10)
		oPrint:Say  (nRow2+1150,100 , mb_MnPrt                                                                       ,oFont10)
		
	Else
		
		xkMensa1 := "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA "+dtoc(aDadosTit[4])
		xkMensa2 := "Vencimento Original: "+ dtoc(jVenctOr) + "   Valor Original: "+ Alltrim(Transform(jSalOri,"@E 99,999,999.99")) + "   Encargos: " + Alltrim(Transform(jkJuros,"@E 99,999,999.99")) + IIF(!Empty(nVlrAcre), "   GNRE " + Alltrim(Transform(nVlrAcre,"@E 99,999,999.99")), "")
		oPrint:Say  (nRow2+1100,100 , xkMensa1                                                                       ,oFont10)
		oPrint:Say  (nRow2+1150,100 , xkMensa2                                                                       ,oFont10)
		
	EndIf
	
If !Empty(cl_Duplic)
	oPrint:Say  (nRow2+1200,100 , "Fatura Ref NF/Parcela:"                                                       ,oFont10)
	oPrint:Say  (nRow2+1250,150 , Substr(cl_Duplic,   1, 81)                                                     ,oFont10)
	oPrint:Say  (nRow2+1300,150 , Substr(cl_Duplic,  82, 81)                                                     ,oFont10)
	oPrint:Say  (nRow2+1350,150 , Substr(cl_Duplic, 183, 81)                                                     ,oFont10)
EndIf

oPrint:Say  (nRow2+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow2+1120,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow2+1190,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow2+1260,1810,"(+)Outros Acréscimos"                           ,oFont8)

If nVlrAcre > 0
	cString2 := Alltrim(Transform(nVlrAcre,"@E 99,999,999.99"))                                   // Tarifa Bancaria
Else
	cString2 := ""
EndIf

nCol := 1810+(374-(len(cString2)*22))
oPrint:Say  (nRow2+1290,nCol,cString2 ,oFont11c)
oPrint:Say  (nRow2+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow2+1400,100 ,"Pagador"                                         ,oFont8)
oPrint:Say  (nRow2+1430,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
oPrint:Say  (nRow2+1483,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow2+1536,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)  // CEP+Cidade+Estado

if aDatSacado[8] = "J"
	oPrint:Say  (nRow2+1430,1750 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow2+1430,1750 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow2+1589,1850,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

oPrint:Say  (nRow2+1605,100 ,"Sacador/Avalista",oFont8)
oPrint:Say  (nRow2+1645,1700,"Autenticação Mecânica",oFont8)

oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 )
oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )

/*************************************************************************************************************************************************/
/* TERCEIRA PARTE */
/*************************************************************************************************************************************************/
nRow3 := 0

For nI := 100 to 2300 step 50   //Pontilhado separador
	oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)
Next nI

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

If aDadosBanco[1] == "001"
	oPrint:Say  (nRow3+1934,100,"Banco do Brasil"                               ,oFont11 )  //aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-9"                             ,oFont20 )  // [1]Numero do Banco
ElseIf aDadosBanco[1] == "021"
	oPrint:Say  (nRow3+1934,100,"Banestes"                                      ,oFont11 )  //aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-3"                             ,oFont20 )  // [1]Numero do Banco
ElseIf aDadosBanco[1] == "237"
	oPrint:Say  (nRow3+1934,100,"Bradesco"                                      ,oFont11 )  //aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-2"                             ,oFont20 )  // [1]Numero do Banco
EndIf
oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2]                                      ,oFont15n ) //	Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento"                             ,oFont8)
If aDadosBanco[1] == "001"
	
	If lPrintFile .Or. aDadosTit[10] // Titulo provisorio de RA
		oPrint:Say  (nRow3+2015,400 ,"Preferencialmente no BANCO DO BRASIL",oFont10)
	Else
		oPrint:Say  (nRow3+2015,400 ,"Até o vencimento, preferencialmente no BANCO DO BRASIL",oFont10)
		oPrint:Say  (nRow3+2055,400 ,"Após o vencimento, somente no BANCO DO BRASIL"  ,oFont10)		
	EndIf

ElseIf aDadosBanco[1] == "021"
	oPrint:Say  (nRow3+2015,400 ,"Até o vencimento, preferencialmente no BANESTES",oFont10)
	oPrint:Say  (nRow3+2055,400 ,"Após o vencimento, somente no BANESTES"  ,oFont10)
		
ElseIf aDadosBanco[1] == "237"
	oPrint:Say  (nRow3+2015,400 ,"Até o vencimento, preferencialmente no BRADESCO",oFont10)
	oPrint:Say  (nRow3+2055,400 ,"Após o vencimento, somente no BRADESCO"  ,oFont10)
EndIf

oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2040,nCol,cString                                          ,oFont11c)

oPrint:Say  (nRow3+2100,100 ,"Beneficiário",oFont8)
oPrint:Say  (nRow3+2140,100 ,aDadosEmp[1]+"                  - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+2100,1810,"Agência/Código Beneficiário",oFont8)

If aDadosBanco[1] == "237" .And. cEmpAnt == "07"
	cString := AllTrim(aDadosBanco[3]) + "-4" + "/0000" + AllTrim(aDadosBanco[4]) + aDadosBanco[5] + "-5"
Else
	cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+""+aDadosBanco[5])
EndIf

nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2140,nCol,cString                                          ,oFont11c)

oPrint:Say  (nRow3+2200,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say (nRow3+2230,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

oPrint:Say  (nRow3+2200,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow3+2230,605 ,aDadosTit[7]+aDadosTit[1]						            ,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+2200,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (nRow3+2230,1050,"DM"									                           	,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+2200,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow3+2230,1400,"N"                                              ,oFont10)

oPrint:Say  (nRow3+2200,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow3+2230,1550,dtoc(aDadosTit[3])                               ,oFont10) // Data impressao

oPrint:Say  (nRow3+2200,1810,"Nosso Número"                                   ,oFont8)
cString := aCB_RN_NN[3]
If aDadosBanco[1] == "001"
	nDvnn   := modulo11(aCB_RN_NN[3])
	cString := aCB_RN_NN[3] + '-' + AllTrim(Str(nDvnn))
ElseIf aDadosBanco[1] == "021"
	cString := Transform(cString, "@R 99999999-99")
ElseIf aDadosBanco[1] == "237"
	cString := aDadosBanco[6]+"/"+aCB_RN_NN[3]
	cString := Transform(cString, "@R 99/99/999999999-9")
EndIf
nCol    := 1900+(374-(len(cString)*22))
oPrint:Say  (nRow3+2230,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2270,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow3+2270,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow3+2300,555 ,aDadosBanco[6]                                   ,oFont10)

oPrint:Say  (nRow3+2270,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow3+2300,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow3+2270,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow3+2270,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow3+2270,1810,"Valor do Documento"                             ,oFont8)
cString := AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2300,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)",oFont8)

	If lPrintFile .Or. aDadosTit[10] // Titulo provisorio de RA

		xkMensa1 := "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA "+dtoc(aDadosTit[4])
		xkMensa2 := "Boleto referente ao pedido de venda: "+ AllTrim(Upper(aDadosTit[9]))
		oPrint:Say  (nRow3+2390,100 , xkMensa1                                                                            ,oFont15)
		oPrint:Say  (nRow3+2460,100 , xkMensa2                                                                            ,oFont11)
	
		If aDadosTit[11] > 0 // Boleto com desconto 		
			xkMensa3 := "Desconto concedido: "+ AllTrim(Transform(aDadosTit[11],"@E 999,999,999.99"))
			oPrint:Say(nRow3 + 2530, 100, xkMensa3, oFont11)
		EndIf
	
	ElseIf !wqJrs 

		//CALCULANDO JUROS POR DIA
		ssJUROS := (6/30)
		sJUROS_DIA := ((ssJUROS/100)*aDadosTit[5])
		oPrint:Say  (nRow3+2390,100 , "JUROS POR UM DIA: * R$ " + Alltrim(Transform(sJUROS_DIA,"@E 99,999,999.99"))       ,oFont10)
		oPrint:Say  (nRow3+2440,100 , mb_MnPrt                                                                            ,oFont10)
		
	Else
		
		xkMensa1 := "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA "+dtoc(aDadosTit[4])
		xkMensa2 := "Vencimento Original: "+ dtoc(jVenctOr) + "   Valor Original: "+ Alltrim(Transform(jSalOri,"@E 99,999,999.99")) + "   Encargos: " + Alltrim(Transform(jkJuros,"@E 99,999,999.99")) + IIF(!Empty(nVlrAcre), "   GNRE " + Alltrim(Transform(nVlrAcre,"@E 99,999,999.99")), "")
		oPrint:Say  (nRow3+2390,100 , xkMensa1                                                                            ,oFont10)
		oPrint:Say  (nRow3+2440,100 , xkMensa2                                                                            ,oFont10)
		
	EndIf

If !Empty(cl_Duplic)
	oPrint:Say  (nRow3+2490,100 , "Fatura Ref NF/Parcela:"                                                            ,oFont10)
	oPrint:Say  (nRow3+2540,150 , Substr(cl_Duplic,   1, 81)                                                          ,oFont10)
	oPrint:Say  (nRow3+2640,150 , Substr(cl_Duplic,  82, 81)                                                          ,oFont10)
	oPrint:Say  (nRow3+2740,150 , Substr(cl_Duplic, 183, 81)                                                          ,oFont10)
EndIf

oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow3+2410,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"                           ,oFont8)

If nVlrAcre > 0
	cString2 := Alltrim(Transform(nVlrAcre,"@E 99,999,999.99")) //Tarifa Bancaria
Else
	cString2 := ""
EndIf

nCol := 1810+(374-(len(cString2)*22))
oPrint:Say  (nRow2+2580,nCol,cString2 ,oFont11c)
oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow3+2690,100 ,"Pagador"                                         ,oFont8)
oPrint:Say  (nRow3+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2700,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) 	// CGC
Else
	oPrint:Say  (nRow3+2700,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99")     ,oFont10) 	// CPF
EndIf

oPrint:Say  (nRow3+2753,400 ,aDatSacado[3]                                              ,oFont10)
oPrint:Say  (nRow3+2806,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]     ,oFont10) // CEP+Cidade+Estado
oPrint:Say  (nRow3+2806,1750,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)            ,oFont10)

oPrint:Say  (nRow3+2815,100 ,"Sacador/Avalista"                                         ,oFont8)
oPrint:Say  (nRow3+2855,1700,"Autenticação Mecânica - Ficha de Compensação"             ,oFont8)

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

MSBAR("INT25",25.0,1.3,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.030,1.4,Nil,Nil,"A",.F.)

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+3200, nI, nRow3+3200, nI+30)
Next nI

oPrint:EndPage()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Ret_B272 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Monta Estrutura do Relatório                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Ret_B272(	cPrefixo, cNumero, cParcela, cTipo, cBanco, cAgencia, cConta, cDacCC, cNroDoc, nValor, cCart, cMoeda	)

Local cNosso		  := ""
Local cDigNosso		:= ""
Local nNum			  := ""
Local cCampoL		  := ""
Local cFatorValor	:= ""
Local cLivre		  := ""
Local cDigBarra	 	:= ""
Local cBarra		  := ""
Local cParte1		  := ""
Local cDig1			  := ""
Local cParte2		  := ""
Local cDig2			  := ""
Local cParte3		  := ""
Local cDig3			  := ""
Local cParte4		  := ""
Local cParte5		  := ""
Local cDigital		:= ""
Local aRet			  := {}
Local cAno        := "00" // Referencias de programas antigos apontaram para esta regra

	cAgencia := StrZero(Val(cAgencia),4)
		
	If SE1->E1_PORTADO == "001"
	
		cCart	:= "17"
	
	ElseIf SE1->E1_PORTADO == "021"
	
		cCart	:= "11"
		
	Else
		
		cCart	:= "09"
		
	EndIf
	
	cNosso   := ""
	
	//Nosso Numero
	nNum   := ALLTRIM(SE1->E1_NUMBCO)
	cNosso := ALLTRIM(SE1->E1_NUMBCO)
	
	If nValor > 0
		cFatorValor  := U_FAT272()+Strzero(nValor*100,10)
	Else
		cFatorValor  := U_FAT272()+strzero((SE1->E1_VALOR)*100,10)
	EndIf
	
	cConvenio := SUBST(SE1->E1_NUMBCO,1,7)
	
	If SE1->E1_PORTADO == "001"
	
		cCampoL := "000000"+Alltrim(nNum)+cCart
		
	ElseIf SE1->E1_PORTADO == "021"
	
		cCampoL := U_BIAF122(cNosso, cConta, "4", cBanco)
	
	ElseIf SE1->E1_PORTADO == "237"
		
		cCodEmpr := U_BIAF068()
		
		cCampoL := cAgencia + cCart + Subs(SE1->E1_NUMBCO,1,11) + cCodEmpr + "0"
		
	EndIf
	
	// campo do codigo de barra
	cLivre := cBanco + cMoeda + cFatorValor + cCampoL
	cDigBarra := U_BIA272A( cLivre )
	cBarra := Substr(cLivre,1,4)+cDigBarra+cFatorValor+Substr(cCampoL,1,25)
	
	// composicao da linha digitavel
	cParte1  := cBanco+cMoeda
	cParte1  += Substr(cBarra, 20, 5)
	cDig1    := U_DigBB272( cParte1, 1 )
	cParte2  := Substr(cBarra, 25, 10 )
	cDig2    := U_DigBB272( cParte2, 2 )
	cParte3  := Substr(cBarra, 35, 10)
	cDig3    := U_DigBB272( cParte3, 2 )
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital := substr(cParte1,1,5)+"."+substr(cParte1,6,4)+cDig1+" "+;
	substr(cParte2,1,5)+"."+substr(cParte2,6,5)+cDig2+" "+;
	substr(cParte3,1,5)+"."+substr(cParte3,6,5)+cDig3+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
Return aRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ DigBB272 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Para calculo da linha digitavel do Banco do Brasil         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function DigBB272(cVariavel,nOp)

Local aMultiplic := {}
Local _cRet      := " "
Local aBaseNum   := {}
Local cDigVer    := 0
Local nB         := 0
Local nC         := 0
Local nSum       := 0
Local _cNossoNum := ""
Local _cCalcdig  := ""
cbase  := cVariavel
IF nOp == 1
	aBaseNum   := { 2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2}
ELSE
	aBaseNum   := { 1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1}
ENDIF

For nB := 1 To Len(cbase)
	nMultiplic := Val(Subs(cbase,nB,1) ) * aBaseNum[nB]
	Aadd(aMultiplic,StrZero(nMultiplic,2) )
next nB

For nC := 1 To Len(aMultiplic)
	nAlgarism1 := Val(Subs(aMultiplic[nC],1,1) )
	nAlgarism2 := Val(Subs(aMultiplic[nC],2,1) )
	nSum       := nSum + nAlgarism1 + nAlgarism2
Next nC

cDigVer := 10 - Mod(nSum,10)

IF cDigVer == 10
	cDigVer := 0
Endif

Return(str(cDigVer,1,0))

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ FAT272   ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Calculo do FATOR1  de vencimento para linha digitavel      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User function FAT272()

sfDtVcto := SE1->E1_VENCTO
If SE1->E1_VENCTO < dDataBase
	sfDtVcto := dDataBase
EndIf

If Len(Alltrim(Substr(dtoc(sfDtVcto),7,4))) = 4
	cData := Substr(dtoc(sfDtVcto),7,4)+Substr(dtoc(sfDtVcto),4,2)+Substr(dtoc(sfDtVcto),1,2)
Else
	cData := "20"+Substr(dtoc(sfDtVcto),7,2)+Substr(dtoc(sfDtVcto),4,2)+Substr(dtoc(sfDtVcto),1,2)
EndIf
cFator := Str(1000+(stod(cData)-stod("20000703")),4)

Return(cFator)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA272A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Calculo do digito Verificador do Código de Barras          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA272A(cVariavel)

Local Auxi := 0, sumdig := 0
Local aBasecalc := { 4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2}
Local nMult     := 0
Local nD        := 0
Local nE        := 0
Local aMult     := {}
Local nDigbar   := 0
Local nSoma     := 0
cbase  := cVariavel

For nD := 1 To Len(cbase)
	nMult := Val(Subs(cbase,nD,1) ) * aBasecalc[nD]
	Aadd(aMult,StrZero(nMult,2) )
next nD

nSoma := 0
nAlgarism1 := 0
nAlgarism2 := 0
For nE := 1 To Len(aMult)
	nAlgarism1 := Val(aMult[nE])
	nSoma      := nSoma + nAlgarism1
Next nC
nDigbar := 11 - Mod(nSoma,11)

IF nDigbar == 0  .or. nDigbar == 1 .or. nDigbar == 10 .or. nDigbar == 11
	nDigbar := 1
Endif

Return(str(nDigbar,1,0))

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Modulo11 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Calculo do digito Verificador do nosso numero              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Modulo11(cData)

Local L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End

Return(D)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","De Prefixo           ?","","","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Prefixo          ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","De Título            ?","","","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Ate Título           ?","","","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","De Cliente           ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA1"})
aAdd(aRegs,{cPerg,"06","Ate Cliente          ?","","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA1"})
aAdd(aRegs,{cPerg,"07","Do Vencimento        ?","","","mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Ate Vencimento       ?","","","mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Data de Referência   ?","","","mv_ch9","D",08,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})
For i := 1 to Len(aRegs)
	if !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return()