#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MT100LOK
@description PONTO DE ENTRADA - VALID LINHA DO DOCUMENTO DE ENTRADA
@author Revisao por Fernando - portari fiscal - colocar AutoGrlog em todos os retornos .F.
@since 23/01/02
@version 1.0
@type function
/*/
User Function MT100LOK()

	Local lConta	:= .F.
	Local cConta 	:= ""
	Local lRetorno	:= Paramixb[1]

	Local cCod		:= ""
	Local cCLVL		:= ""
	Local cForInd	:= ""
	Local cNumPed	:= SPACE(6)
	Local cItemPed	:= SPACE(2)
	Local nVunit	:= 0
	Local nToler	:= 0
	Local cContrat	:= ""
	Local lPassei   := .F.
	Local cIemCon   := Alltrim(GetNewPar("MV_YITCVER","I0202")) //Projeto contrato de verbas - Se o item for I0202, validar para ser obrigatorio preencher o contrato
	Local xxn

	Public SFLAG 	:= 1
	Public sIPI 	:= ""

	Private cTes	:= ""
	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	Private cPTes	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TES"})
	Private cPCod	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})
	Private cPAlmox	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_LOCAL"})
	Private cPCLVL	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CLVL"})
	Private cPItemCta := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_ITEMCTA"})
	Private cPConta	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CONTA"})
	Private cPSI	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_YSI"})
	Private cPContrat := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_YCONTR"})
	Private cPREGRA	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_YREGRA"})
	Private cPNFOri   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_NFORI"})
	Private nPVunit   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_VUNIT"})
	Private cPNumPed  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_PEDIDO"})
	Private cPItemPed := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_ITEMPC"})
	Private cPForInd  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_YFORIND"})
	Private cPCF  	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CF"})
	Private cPQuant   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_QUANT"})
	Private cPSeriOri := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_SERIORI"})
	Private cPTotal   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TOTAL"})
	Private cPLoteCTL := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_LOTECTL"})
	Private cPCodRef  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_YCODREF"})
	Private cPIdentb6 := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_IDENTB6"})
	Private cPItem 	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_ITEM"})
	Private cPCtrVer  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_YCTRVER"})
	Private cPDtDigit := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_DTDIGIT"})
	Private cPTicket  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_YTICKET"})
	Private cPFornece := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_FORNECE"})
	Private cPLoja 	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_LOJA"})
	Private cPSubItem := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_YSUBITE"})	
	Private cFornMPM  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_FORNMP"})	
	Private cLjFrMPM  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_LOJAMP"})	

	Private cArqSB1	:= ""
	Private cIndSB1	:= 0
	Private cRegSB1	:= 0

	Private cArqSBM	:= ""
	Private cIndSBM	:= 0
	Private cRegSBM	:= 0

	Private cArqSF4	:= ""
	Private cIndSF4	:= 0
	Private cRegSF4	:= 0

	Private cArqSC7	:= ""
	Private cIndSC7	:= 0
	Private cRegSC7	:= 0

	Private cArqSF1	:= ""
	Private cIndSF1	:= 0
	Private cRegSF1	:= 0

	Private kt_NfMsFr := .F. // Inserido por Marcos Alberto em 08/12/11 para atender ao lançamento de nota fiscal de serviço de massa

	Private xftFornec := ""
	Private xftLoja := ""


	If FwIsInCallStack('U_GATI001')
		U_GTPE004()
		If l103Auto
			Return .T.
		EndIf
	EndIf

	If IsInCallStack("U_COPYDOCE") .And. IsBlind()

		Return(.T.)

	EndIf

	//Tratamento para Totvs Colaboracao 2.0
	If GetMv("MV_COMCOL1") <> 2 .And. Upper(Alltrim(FUNNAME())) == "SCHEDCOMCOL"
		Return (.T.)
	EndIf

	If GdDeleted(N)
		Return .T.
	EndIf

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	//Armazena as variaveis / conteudo dos campos
	cTes		:= aCols[n,cPTes]
	cCod		:= aCols[n,cPCod]
	cAlmox		:= aCols[n,cPAlmox]
	cCLVL		:= aCols[n,cPCLVL]
	cItemCta	:= aCols[n,cPItemCta]
	cConta		:= aCols[n,cPConta]
	cSI     	:= aCols[n,cPSI]
	cSubItem := aCols[n,cPSubItem]	

	// Por Marcos Alberto Soprani para resolver problema de classificação de nota pelo projeto Portaria Fiscal - em 25/09/19.
	If FwIsInCallStack('U_TACLNFJB')
		cNumPed  := aCols[n,cPNumPed]
		cItemPed := aCols[n,cPItemPed]
		SC7->(dbSetOrder(1))
		If SC7->(dbSeek(xFilial("SC7") + cNumPed + cItemPed))
			Gdfieldput("D1_CLVL"    , SC7->C7_CLVL, n)
			Gdfieldput("D1_YAPLIC"  , SC7->C7_YAPLIC, n)
			aCols[n,cPCLVL] := SC7->C7_CLVL
			cCLVL           := SC7->C7_CLVL
			If SB1->(DbSeek(xFilial("SB1")+cCod))
				If Alltrim(SB1->B1_TIPO) == "MD"
					If SUBS(SC7->C7_CLVL,1,1)=="3"
						cConta	:=	SB1->B1_YCTRIND
					Else
						cConta	:=	SB1->B1_YCTRADM
					EndIf
				Else
					cConta	:=	SB1->B1_CONTA
				EndIf
				Gdfieldput('D1_CONTA',cConta,n)
				aCols[n,cPConta]	:=	cConta
			EndIf
		EndIf

	EndIf

	//ticket 10588
	If AllTrim(cCod) == "3060301" .And. cCLVL <> "1101"
		MsgBox("Para o produto 3060301 (juros sobre capital próprio), a classe de valor deve ser 1101.", "MT100LOK(x1)", "STOP")
		AutoGrLog("MT100LOK ==> Para o produto 3060301 (juros sobre capital próprio), a classe de valor deve ser 1101.")
		lRetorno := .F.
	EndIf

	IF cEmpAnt <> '02'
		cContrat	:= aCols[n,cPContrat]
	ELSE
		cContrat	:= ''
	ENDIF
	cREGRA		:= aCols[n,cPREGRA]
	cNFOri		:= aCols[n,cPNFOri]

	if !GdDeleted(n) .and. Alltrim(GdFieldGet("D1_CONTA",n)) <> "41301001" // .and. !Empty(Gdfieldget('D1_CONTA',n)) .And. Substr(Gdfieldget('D1_CONTA',n),1,1) == '6' .And. !Empty(Gdfieldget('D1_CLVL',n))
		CTH->(DbSetOrder(1))
		If CTH->(DbSeek(xFilial("CTH")+Gdfieldget('D1_CLVL',n))) .And. CTH->CTH_YATRIB == 'C' .And. Gdfieldget('D1_YAPLIC',n) $ ' _0'
			MsgBox("A Conta e a Classe de valor exigem que a Aplicação seja Informada e diferente de zero!", "MT100LOK(x2)", "STOP")
			AutoGrLog("MT100LOK ==> A Conta e a Classe de valor exigem que a Aplicação seja Informada e diferente de zero!")
			lRetorno	:=	.F.
			Return(lRetorno)
		endif
	endif

	If !GdDeleted(n) .And. !Empty(GdFieldGet("D1_CONTA",n)) .And. !Empty(Gdfieldget('D1_CLVL',n))
		If U_BFG81VCL(Gdfieldget('D1_CLVL',n)) .And. U_BFG81VCO(GdFieldGet("D1_CONTA",n))
			If Empty(GdFieldGet("D1_YDRIVER",n))
				MsgBox("A conta e a classe de valor selecionadas exigem que o driver seja informado!", "MT100LOK(x3)", "STOP")
				AutoGrLog("MT100LOK ==> A conta e a classe de valor selecionadas exigem que o driver seja informado!")
				lRetorno	:=	.F.
			EndIF
		EndIf
	EndIf

	If UPPER(ALLTRIM(FUNNAME())) $ "MATA100,MATA103" .and. GdDeleted(n) == .F.
		if empty(cTes)
			MsgBox("Digite a Tes, pois e campo OBRIGATORIO....", "MT100LOK(x4)", "STOP")
			AutoGrLog("MT100LOK ==> Digite a Tes, pois e campo OBRIGATORIO...")
			lRetorno := .F.
		endIf
	endIf

	If  M->CTIPO == "C" .and. GdDeleted(n) == .F. .and. Upper(Alltrim(Funname())) $ "MATA100,MATA103"
		If Empty(cNFOri)
			lretorno := .F.
		EndIf
	EndIf

	//Obrigatorio Classe de Valor para MD
	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+cCod,.F.)

	DbSelectArea("ZCN")
	ZCN->(DbSetOrder(2))
	ZCN->(DbSeek(xFilial("ZCN")+cCod+cAlmox))

	DbSelectArea("SF4")
	cArqSF4 := Alias()
	cIndSF4 := IndexOrd()
	cRegSF4 := Recno()
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+cTes,.F.)

	//Executa validacao referente Almoxarifado Comum
	If !GdDeleted(n)
		If !U_fValProdComum(cCod,cAlmox,"MT100LOK","C") //Paramentros da Funcao Produto/Almoxarifado/NomeProgroma/TipoMovimento(C=Compra/T=Transferencia)
			lRetorno := .F.
			Return(lRetorno)
		EndIf
	EndIf

	//Executa validacao do Item Contabil de Marketing
	lConta 	:= .F.
	//Valida Conta de Marketing
	If Substr(cConta,1,5) == '31401' .OR. Substr(cConta,1,5) == '31406'
		IF ALLTRIM(cConta) <> '31401017'
			lConta 	:= .T.
		ENDIF
	EndIf
	//Valida a Digitacao do Item Contabil
	IF SUBSTR(ALLTRIM(cItemCta),1,1) == 'I' .AND. EMPTY(cSI)
		MsgBox("Favor informar o cliente para este Item Contábil", "MT100LOK(x4)", "ALERT")
		AutoGrLog("MT100LOK ==> Favor informar o cliente para este Item Contábil!")
		lRetorno := .F.
		Return(lRetorno)
	ENDIF

	If lConta .And. ( Empty(cItemCta) .Or. Empty(cSI) )
		MsgBox("Para contas do Marketing (31401/31406), é obrigatório informar o Item Contábil e Cliente da AI","MT100LOK(x4)","ALERT")
		AutoGrLog("MT100LOK ==> Para contas do Marketing (31401/31406), é obrigatório informar o Item Contábil e Cliente da AI")
		lRetorno := .F.
		Return(lRetorno)
	EndIf

	lRetorno := U_fValItemCta("XX", lConta, cCLVL, cItemCta, cSubItem)

	IF lRetorno == .F.
		Return(lRetorno)
	ENDIF

	IF SF4->F4_MSBLQL = "1" .And. !GdDeleted(N)
		MsgBox("TES BLOQUEADO","MT100LOK(x5)","ALERT")
		AutoGrLog("MT100LOK ==> TES BLOQUEADO")
		RETURN(.F.)
	END IF

	DbSelectArea("SBM")
	cArqSBM := Alias()
	cIndSBM := IndexOrd()
	cRegSBM := Recno()
	DbSetOrder(1)
	DbSeek(xFilial("SBM")+SB1->B1_GRUPO,.F.)

	//IF SM0->M0_CODIGO = "01"
	If !GdDeleted(N)
		IF Subs(cCLVL,1,1) = "8" .AND. Alltrim(SF4->F4_ESTOQUE) == "S"
			MsgBox("TES Usada Invalida - Este material e do tipo MD e nao devera atualizar estoque!","MT100LOK(x6)","ALERT")
			AutoGrLog("MT100LOK ==> TES Usada Invalida - Este material e do tipo MD e nao devera atualizar estoque!")
			lRetorno := .F.
		ELSE
			//Verifica se o Produto e do Tipo MD
			IF cREGRA = "N"
				If Alltrim(ZCN->ZCN_MD) == "S"
					IF SBM->BM_YCON_MD = "N"
						//Para Produto MD so pode utilizar TES que nao atualiza Estoque
						If Alltrim(SF4->F4_ESTOQUE) == "S"
							MsgBox("TES Usada Invalida - Este material e do tipo MD e nao devera atualizar estoque!","MT100LOK(x7)","ALERT")
							AutoGrLog("MT100LOK ==> TES Usada Invalida - Este material e do tipo MD e nao devera atualizar estoque!")
							lRetorno := .F.
						EndIf
						//Verifica se a Classe de Valor esta em branco
						If Empty(cCLVL)
							MsgBox("Classe de Valor em branco para produto MD, favor preencher a mesma para continuar!","MT100LOK(x8)","ALERT")
							AutoGrLog("MT100LOK ==> Classe de Valor em branco para produto MD, favor preencher a mesma para continuar!")
							lRetorno := .F.
						EndIf
					ELSE
						If cempant == "01"
							If Alltrim(SF4->F4_ESTOQUE) == "N"
								MsgBox("TES Usada Invalida - Este material e do tipo MD e devera atualizar estoque!","MT100LOK(x9)","ALERT")
								AutoGrLog("MT100LOK ==> TES Usada Invalida - Este material e do tipo MD e nao devera atualizar estoque!")
								lRetorno := .F.
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		//Verifica se a Classe de Valor esta em branco quando a conta contábil se tratar de conta de custo. Por Marcos Alberto em 01/12/11
		If Empty(cCLVL) .and. Substr(cConta,1,1) $ "6/3"
			MsgBox("Classe de Valor em branco para conta contábil de Custo/Despesa, favor preencher a mesma para continuar!","MT100LOK(xA)","ALERT")
			AutoGrLog("MT100LOK ==> Classe de Valor em branco para conta contábil de Custo/Despesa, favor preencher a mesma para continuar!")
			lRetorno := .F.
		EndIf
	ENDIF
	//ENDIF

	/*
	//ticket 18778 - solicitado desabilitar esta rotina
	//Verifica se a TES do Produto esta em Branco
	If Alltrim(SB1->B1_TE) == "" .and. !GDDeleted() .And. !IsInCallStack("U_TACLNFJB") .And. !IsInCallStack("U_BACP0012")
	Private aRadio := {"Atualizar Cad. Produto com TES da NF? ","Informar Nova TES? "}
	Private	nRadio := 2

	//Monta janela
	@ 0,0 TO 070,450 DIALOG oDlg1 TITLE "Cad. Produto esta com a TES em branco. O que deseja fazer ?"
	@ 000,010 TO 30,150 TITLE "Opcoes"
	@ 007,020 RADIO aRadio VAR nRadio
	@ 010,160 BMPBUTTON TYPE 1 ACTION fAtualiza()
	@ 010,190 BMPBUTTON TYPE 2 ACTION fSair()
	ACTIVATE DIALOG oDlg1 CENTER
	EndIf
	*/
	//Verifica se ja foi  informado o campo de alteração de ipi -- codigo fiscal.  MADALENO
	SFLAG := "1"
	//If Alltrim(SB1->B1_YALTIPI) == "" .and. !GDDeleted()
	If Alltrim(SB1->B1_YALTNCM) == "" .and. !GDDeleted() .And. !IsInCallStack("U_TACLNFJB") .And. !IsInCallStack("U_BACP0012") .And. !IsInCallStack("U_PNFM0002") .And. !IsInCallStack("U_PNFM0005") .And. !IsInCallStack("U_JOBFATPARTE")
		WHILE SFLAG = "1"
			Private sIPI := SB1->B1_POSIPI //SPACE(10)

			@ 96,42 TO 280,660 DIALOG oEntra TITLE "CODIGO FISCAL DO PRODUTO: " + Alltrim(SB1->B1_COD) + " " + Alltrim(SB1->B1_DESC)
			@ 8,12 TO 84,150
			@ 23,21 SAY "Digite Pos.IPI/NCM : "
			@ 23,88 Get sIPI SIZE 35,10 PICTURE "@R9999.99.99" Object oGet F3 "SYD"
			@ 55,50 BUTTON "_Submeter" SIZE 30,15 ACTION fAtua_5() //Close(oEntra)  // Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 55,20 BUTTON "_Submeter" SIZE 30,15 ACTION Execute(fSubmit)
			//@ 55,90 BUTTON "_Abortar"  SIZE 30,15 ACTION Close(oEntra)// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 55,60 BUTTON "_Abortar"  SIZE 30,15 ACTION Execute(fAborta)
			ACTIVATE DIALOG oEntra CENTERED

		END
	EndIf

	//validando a natureza e o processo de exportacao
	IF SM0->M0_CODIGO <> '06' .AND. !GdDeleted(N)
		nPosNatu  := aScan(aHeader,{|x| x[2]=="D1_YNATURE"})
		If !Empty(Acols[n,nPosNatu])
			dbSelectArea("SED")
			dbSetOrder(1)
			dbSeek(xFilial("SED")+AllTrim(Acols[n,nPosNatu] ))
			cValida := SED->ED_YVALEXP

			If cValida = "S"
				nPosProce  := aScan(aHeader,{|x| x[2]=="D1_YPROCES"})
				if alltrim(Acols[n,nPosProce]) = ""
					MsgBox("Favor informar o processo","MT100LOK(xB)","ALERT")
					AutoGrLog("MT100LOK ==> Favor informar o processo")
					lRetorno := .F.
				End if
			end if
		end if
	ENDIF

	//Inserido por Wanisay, no dia 01/02/08, para validar preco informado na NFE x PC.
	nToler := GETMV("MV_YTOLER")

	nVunit   := aCols[n,nPVunit]
	cNumPed  := aCols[n,cPNumPed]
	cItemPed := aCols[n,cPItemPed]
	cForInd  := aCols[n,cPForInd]

	//ticket 10750
	If !Empty(cNumPed)
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(XFilial("SC7") + cNumPed + cItemPed))
			If AllTrim(cAlmox) <> AllTrim(SC7->C7_LOCAL) .And. !Empty(SC7->C7_LOCAL)
				MsgBox("O almoxarifado deve ser o " + AllTrim(SC7->C7_LOCAL) + ", como está no pedido de compras.", "MT100LOK(xC)", "STOP")
				AutoGrLog("MT100LOK ==> O almoxarifado deve ser o " + AllTrim(SC7->C7_LOCAL) + ", como está no pedido de compras.")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	If cEmpAnt == "07" .and. SB1->B1_TIPO <> "PA"   // Tratamento feito para atender a OS effetivo: 0312-14, que liberada a digitação de nota fiscal de entrada de MP sem pedido de compras

		lRetorno := .T.
	Else

		// Ticket: 25464 - Automacao JK
		If !IsInCallStack("U_JOBFATPARTE")

			IF M->CTIPO == "N" .AND. SF4->F4_DUPLIC == 'S' .AND. !GdDeleted(N) .AND. cEmpAnt <> "02" .AND. cA100For <> '000534' .AND. cA100For <> '002912'
				IF ( SUBSTR(cCod,1,1) < '7' .AND. SUBSTR(cCod,1,1) <> '3') .or. (SB1->B1_TIPO == "PA" .and. Substr(aCols[n,cPCF],2,3) == "124" )// Incerido Filtro di tipo PA em 30/08/12 por Marcos Alberto Soprani.
					IF EMPTY(ALLTRIM(cNumPed)) .AND. cEmpAnt <> '06'
						If !Substr(aCols[n,Ascan(aHeader,{|x| x[2] == "D1_CF     "})],1,1) == "3" //Autorizado pelo Enelcio 25/05/2010 - Nao bloquear pedidos de importacao
							If !(aCols[n,cPQUANT] == 0 .and. SF4->F4_QTDZERO == "1" .and. !Empty(aCols[n,cPNFORI]) .and. !Empty(aCols[n,cPSERIORI]) )
								MsgBox("Pedido de compra não informado. Favor verificar!!!", "MT100LOK(xD)", "ALERT")
								AutoGrLog("MT100LOK ==> Pedido de compra não informado. Favor verificar!!!")
								lRetorno := .F.
							Else
								//kt_NfMsFr := .T.
							EndIf
						EndIf
					ENDIF
				ENDIF
				IF SUBSTR(cCod,1,1) == '3' .AND. EMPTY(ALLTRIM(cNumPed)) .AND. !(cEmpAnt) $ "06/03/08/09/10/11"
					MsgBox("Esta NF está sem Pedido de Compra. Favor verificar!!!", "MT100LOK(xE)", "ALERT")
					AutoGrLog("MT100LOK ==> Esta NF está sem Pedido de Compra. Favor verificar!!!")
				ENDIF
			ELSE
				IF cA100For == '000534'
					lRetorno := .T.
				ENDIF
			ENDIF

		EndIf

	EndIf

	cForn	  := SUBSTR(GETMV("MV_YNFORI"),10,6)
	cLojaFor  := SUBSTR(GETMV("MV_YNFORI"),16,2)
	cNfOri2   := SUBSTR(GETMV("MV_YNFORI"),1,6)
	cSerOri2  := SUBSTR(GETMV("MV_YNFORI"),7,3)

	DbSelectArea("SF1")
	cArqSF1 := Alias()
	cIndSF1 := IndexOrd()
	cRegSF1 := Recno()
	DbSetOrder(2)

	IF DDEMISSAO < DDATABASE - GETMV("MV_YDIASNF")
		MsgBox("Data de Emissao fora de um periodo valido. Favor procurar o departamento contabil!", "MT100LOK(xF)", "ALERT")
		AutoGrLog("MT100LOK ==> Data de Emissao fora de um periodo valido. Favor procurar o departamento contabil!")
		lRetorno := .F.
	ENDIF

	If cEmpAnt <> "12" .or. (cEmpAnt == "12" .and. dtos(dDatabase) > '20111231') // Conforme OS Effettivo 1088-11 de 15/12/11
		IF (SUBSTR(cCLVL,1,1) == '8') .AND. !SUBSTR(cREGRA,1,1) $ 'I/P' .AND. !GdDeleted(N)
			MsgBox("O campo Regra devera ser preenchido quando a Classe de Valor iniciar com 8.", "MT100LOK(xG)", "ALERT")
			AutoGrLog("MT100LOK ==> O campo Regra devera ser preenchido quando a Classe de Valor iniciar com 8.")
			lRetorno := .F.
		ENDIF
	EndIf

	IF LEN(ALLTRIM(cNfiscal)) < 6 .AND. cFormul <> 'S'
		MsgBox("O numero da nota fiscal esta preenchido com menos de 6 digitos. Favor corrigir!", "MT100LOK(xH)", "ALERT")
		AutoGrLog("MT100LOK ==> O numero da nota fiscal esta preenchido com menos de 6 digitos. Favor corrigir!")
		lRetorno := .F.
	ENDIF

	IF SUBSTR(SF4->F4_CF,2,3) == '101' .AND. GdDeleted(n) == .F. //.And. Empty(Alltrim(M->F1_HAWB)) //Compra de materia prima
		DbSelectArea("SC7")
		cArqSC7 := Alias()
		cIndSC7 := IndexOrd()
		cRegSC7 := Recno()
		DbSetOrder(1)
		DbSeek(xFilial("SC7")+cNumPed+cItemPed,.T.)
		PRECO__PEDIDO := 0

		IF Found()
			// VERIFICANDO SE O PRODUTO E DOLAR
			IF SC7->C7_MOEDA = 2  .OR. SC7->C7_MOEDA = 5
				//A Taxa gravada no pedido sempre será maior do que a taxa do sistema para que a personalizacao funcione.
				//Por isso a necessidade de somar R$ 0.01 na taxa do pedido que e uma referencia.
				cFornece := U_MontaSQLIN(GetMV("MV_YFORMOE"),'/',6)
				nTaxa := 1 * RECMOEDA(DDEMISSAO-1, SC7->C7_MOEDA ) + 0.01

				cQuery0 := 	""
				cQuery0 +=	"UPDATE "+RetSqlName("SC7")+" SET C7_TXMOEDA = '"+ALLTRIM(STR(nTaxa))+"' "
				cQuery0 +=	" WHERE C7_NUM     = '"+cNumPed+"' "
				cQuery0 +=	" AND   C7_ITEM    = '"+cItemPed+"' "
				cQuery0 +=	" AND   C7_FORNECE NOT IN (" + cFornece + ") "
				cQuery0 +=	" AND   D_E_L_E_T_ = ''  "
				TCSQLExec(cQuery0)

				// Solicitado por diogo martinez para arredondar o valor para 3 casas decimais
				IF SC7->C7_FORNECE $ cFornece
					PRECO__PEDIDO := ROUND(SC7->C7_PRECO * SC7->C7_TXMOEDA,3)
				ELSE
					PRECO__PEDIDO := ROUND(SC7->C7_PRECO * RECMOEDA(DDEMISSAO-1, SC7->C7_MOEDA ),3)
				ENDIF

				PRECO__PEDIDO := ROUND(PRECO__PEDIDO,3)

				//(20/11/14 - Carlos) -> Alteração devido a implantação do SIGAEIC.
				//SF1->F1_HAWB - ocorre em processos oriundos do SIGAEIC. Trata-se de Nacionalização com utilização do módulo.
				If Empty(Alltrim(SF1->F1_HAWB)) .And. !fTolerancia(aCols[n, cPCod])

					IF (nVunit - nToler) >  PRECO__PEDIDO
						MsgBox("Preco digitado na NF maior que o preco digitado no pedido!!!", "MT100LOK(xI)", "ALERT")
						AutoGrLog("MT100LOK ==> Preco digitado na NF maior que o preco digitado no pedido!!!")

						For xxn := 1 to Len(aHeader)
							xcCampo := Trim(aHeader[xxn][2])
							If xcCampo == "D1_VUNIT"
								aCols[n][xxn] := 0
								lRetorno := .F.
								Exit
							Endif
						Next

						For xxn := 1 to Len(aHeader)
							xcCampo := Trim(aHeader[xxn][2])
							If xcCampo == "D1_TOTAL"
								aCols[n][xxn] := 0
								lRetorno := .F.
								Exit
							Endif
						Next

					ENDIF
				EndIf
			ENDIF
		ENDIF
	ENDIF

	// Implementado por Marcos Alberto Soprani em 29/03/12.
	// Em 28/03/12 tanto o Antonio Marcio, via rotina de importação de XML, quanto o Robert fazendo teste com um lançamento qualquer de nota, ambos com pedido de compras, estava conseguindo
	// lançar notas com valores diferentes do pedido de compras.
	If !Empty(cNumPed)
		SC7->(dbSetOrder(1))
		If SC7->(dbSeek(xFilial("SC7")+cNumPed+cItemPed,.T.))

			If SC7->C7_MOEDA == 1

				If !fTolerancia(aCols[n, cPCod])

					If (nVunit - nToler) > SC7->C7_PRECO
						MsgBox("Preço digitado na NF maior que o preco digitado no pedido!!!"+CHR(13)+CHR(13)+"Impossível prosseguir.", "MT100LOK(xJ)", "STOP")
						AutoGrLog("MT100LOK ==> Preço digitado na NF maior que o preco digitado no pedido!!!"+CHR(13)+CHR(13)+"Impossível prosseguir.")
						lRetorno := .F.
					EndIf

				EndIf

			EndIf

			If SC7->C7_MOEDA == 0
				RecLock("SC7",.F.)
				SC7->C7_MOEDA := 1
				MsUnLock()
				MsgBox("Pedido de compras sem MOEDA cadastrada!!!"+CHR(13)+CHR(13)+"Impossível prosseguir."+CHR(13)+CHR(13)+"Interrompa o processo e reinicie que vai funcionar.", "MT100LOK(xK)", "STOP")
				AutoGrLog("MT100LOK ==> Pedido de compras sem MOEDA cadastrada!!!"+CHR(13)+CHR(13)+"Impossível prosseguir."+CHR(13)+CHR(13)+"Interrompa o processo e reinicie que vai funcionar.")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	IF (SUBSTR(cCLVL,1,1) == '8' .OR. ALLTRIM(cCLVL) == '2130' .OR. ALLTRIM(cCLVL) == '1045' .OR. ALLTRIM(cCLVL) == '3145' .OR. ALLTRIM(cCLVL) == '3184' .OR. ALLTRIM(cCLVL) == '3185')  .AND. EMPTY(cContrat)
		MsgBox("O campo contrato deverá ser preenchido quando a classe de valor iniciar com 8.", "MT100LOK(xL)", "ALERT")
		AutoGrLog("MT100LOK ==> O campo contrato deverá ser preenchido quando a classe de valor iniciar com 8.")
		lRetorno := .F.
	ENDIF

	IF !EMPTY(cContrat)
		DbSelectArea("SC3")
		DbSetOrder(1)
		DbSeek(xFilial("SC3")+cContrat)
		lPassei := .F.

		WHILE !EOF() .AND. SC3->C3_NUM == cContrat
			IF ALLTRIM(cCLVL) == ALLTRIM(SC3->C3_YCLVL)
				lPassei := .T.
				IF SC3->C3_MSBLQL == '1'
					MsgBox("Este contrato está bloqueado.", "MT100LOK(xM)", "STOP")
					AutoGrLog("MT100LOK ==> Este contrato está bloqueado.")
					lRetorno := .F.
				ENDIF
				IF dDatabase < SC3->C3_DATPRI .OR. dDatabase > SC3->C3_DATPRF
					MSGBOX("Esta NF não poderá ser inclusa pois a data está fora da vigência do contrato.", "MT100LOK(xN)", "STOP")
					AutoGrLog("MT100LOK ==> Esta NF não poderá ser inclusa pois a data está fora da vigência do contrato.")
					lRetorno := .F.
				ENDIF
			ENDIF

			DbSelectArea("SC3")
			DbSkip()
		END

		IF !lPassei
			MsgBox("A classe de valor deste item da NF deverá ser igual a classe de valor do contrato informado.", "MT100LOK(xO)", "ALERT")
			AutoGrLog("MT100LOK ==> A classe de valor deste item da NF deverá ser igual a classe de valor do contrato informado.")
			lRetorno := .F.
		ENDIF
	ENDIF

	// A partir de 04/10/11 todos as notas fiscais que não possírem pedido de compras serão impedidas de serem lançadas.
	// Esta decisão foi todas pelo Sr. Enélcio e Sr. Robert acompanhadas pelos Srs. Wanisay e Marcos Alberto em 30/09/11.
	// Rotina implementada por Marcos Alberto em 03/10/11.
	If Upper(Alltrim(FunName())) $ "MATA100,MATA103" .and. GdDeleted(n) == .F. .and. 1 == 2 // Aguardar segunda ordem da Diretoria. Em 03/10/11
		If cTipo == "N" .or. ( cTipo <> "N" .and. Empty(aCols[n,cPNFORI]) )
			If Empty(aCols[n,cPNumPed])
				If !aCols[n,cPTes] $ GetMv("MV_YTESSPC")
					MsgBox("A partir de 04/10/11 é necessário informar o pedido de compras para este tipo de nota fiscal de entrada. Favor verificar...", "MT100LOK(xP)", "STOP")
					AutoGrLog("MT100LOK ==> A partir de 04/10/11 é necessário informar o pedido de compras para este tipo de nota fiscal de entrada. Favor verificar...")
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//  Definição originada a partir da OS effettivo 0292-13 feita pela Tania.
	//  A definição foi apresentada por Robert e Claudia em 17/04/13 com acompanhamento de Marcos Alberto. Esta definição não possui maiores bloqueios devido a dificuldade em sistematização, porém,
	// uma das exigências e a assinatura no verso da nota por pessoa autorizada. Sem esta assinatura, a nota não poderá ser lançada.

	frTratExce := .F.
	// Tratativa incluída para controlar uma vulnerabilidade do sistema e atender ao ticket 25574.
	If Upper(Alltrim(cEspecie)) $ "NFS" .and. Substr(aCols[n,cPCod],1,3) == "101" .and. aCols[n,cPQuant] == 0
		kt_NfMsFr  := .T.
		//frTratExce := .F.
	Else
		If cA100For $ "008590/009108/009028/008998/009505/003990/004257/002887" .and. Alltrim(aCols[n,cPCod]) $ "1010160/1010194/1010206/1010214/1010217" .and. aCols[n,cPQuant] == 0 .and. !Empty(aCols[n,cPNFOri])
			If MsgNOYES("Para prosseguir com o lançamento desta nota fiscal é necessário certificar-se de que ela foi assinada por pessoa autorizada de dentro da empresa." + CHR(13) + CHR(13) + "Deseja prosseguir?", "MT100LOK(17)")
				frTratExce := .T.
			EndIf
		EndIf
	EndIf

	// A partir de 13/10/11 o sistema passará a bloquear o lançamento do CTR referente transporte de MASSA. Incluido por Marcos Alberto
	// Em 14/10/11 foi necessário filtrar o código 1010127 da regra de frete porque ele é um ESMALTE...
	// Em 03/01/14 por solicitação da Fabiana Corona e aprovação do Fabio Sá foi retirada a empresa JK do tratamento de frete sobre MASSA.
	msNfCteFch := .F.
	If dtos(dDataBase) >= "20111013" .and. !frTratExce .and. cEmpAnt <> "06" .and. !GetMv("MV_YLIBFRT", , .F.)   // O default é .F., se for .T. o sistema salta

		If Upper(Alltrim(cEspecie)) $ "CTR/CTE" .or. kt_NfMsFr

			If Substr(aCols[n,cPCod],1,3) == "101" .and. !aCols[n,cPCod] $ "1010127        /1010113        /1010107        /1010213        /1010229        /1010251        /1010265        /1010271        /1010332        " //Thiago Haagensen - Ticket 25578 - Adicionado o produto 1010332 sem tabela de frete. (Linha 617).

				// Tratamento efetuado em 08/12/11 para atender a mais uma situação de frete de massa.
				kt_DtDig := dDataBase
				If Upper(Alltrim(cEspecie)) $ "CTR/CTE"

					kt_DtDig := aCols[n,cPDtDigit]

				Else

					// Tratamento implementado em 27/03/14 para atender nova regra de rateio de frete para MASSA.
					// Este tratamento é específico para o transportador 008318 e para os fornecedores de massa 009852 e 003286

					xftFornec  := cA100For
					xftLoja    := cLoja
					msRefBusca := cNFiscal + '#' + cA100For + '#' + cLoja + '#' + dtos(ddEmissao)  

					FR006 := " SELECT SF1.F1_FORNECE, "
					FR006 += "        SF1.F1_LOJA "
					FR006 += " FROM " + RetSqlName("ZLL") + " ZLL(NOLOCK) "
					FR006 += "      INNER JOIN " + RetSqlName("SF1") + " SF1(NOLOCK) ON SF1.F1_FILIAL = '" + xFilial("SF1") + "' "
					FR006 += "                                       AND SF1.F1_CHVNFE = ZLL.ZLL_CHNFE "
					FR006 += "                                       AND SF1.D_E_L_E_T_ = ' ' "
					FR006 += " WHERE ZLL.ZLL_FILIAL = '" + xFilial("ZLL") + "' "
					FR006 += "       AND CAST(ZLL.ZLL_NFSERV AS VARCHAR(MAX)) LIKE '%" + msRefBusca + "%' "
					FR006 += "       AND ZLL.D_E_L_E_T_ = ' ' "					
					TcQuery FR006 New Alias "FR06"
					dbSelectArea("FR06")
					dbGoTop()
					xftFornec := FR06->F1_FORNECE
					xftLoja   := FR06->F1_LOJA
					FR06->(dbCloseArea())

					A0027 := " SELECT DISTINCT D1_DTDIGIT
					A0027 += "   FROM " + RetSqlName("SD1")
					A0027 += "  WHERE D1_FILIAL = '" + xFilial("SD1") + "'
					A0027 += "    AND D1_DOC = '" + aCols[n,cPNFOri] + "'
					A0027 += "    AND D1_SERIE = '" + aCols[n,cPSeriOri] + "'
					A0027 += "    AND D1_FORNECE = '" + xftFornec + "'
					A0027 += "    AND D1_LOJA = '" + xftLoja + "'
					A0027 += "    AND D1_DTDIGIT = '" + dtos(dDataBase) + "'
					A0027 += "    AND D1_COD = '" + aCols[n,cPCod] + "'
					A0027 += "    AND D_E_L_E_T_ = ' '
					TcQuery A0027 New Alias "A027"
					dbSelectArea("A027")
					dbGoTop()
					kt_DtDig := stod(A027->D1_DTDIGIT)
					A027->(dbCloseArea())
					If Empty(kt_DtDig)

						// Para os casos em que nao exite ticket de balanca - fechamento de mes (movidek 25574)
						msNfCteFch := .T.
						A0027 := " SELECT DISTINCT D1_DTDIGIT
						A0027 += "   FROM " + RetSqlName("SD1")
						A0027 += "  WHERE D1_FILIAL = '" + xFilial("SD1") + "'
						A0027 += "    AND D1_DOC = '" + aCols[n,cPNFOri] + "'
						A0027 += "    AND D1_SERIE = '" + aCols[n,cPSeriOri] + "'
						A0027 += "    AND D1_FORNECE = '" + aCols[n,cFornMPM] + "'
						A0027 += "    AND D1_LOJA = '" + aCols[n,cLjFrMPM] + "'
						A0027 += "    AND D1_DTDIGIT = '" + dtos(dDataBase) + "'
						A0027 += "    AND D1_COD = '" + aCols[n,cPCod] + "'
						A0027 += "    AND D_E_L_E_T_ = ' '
						TcQuery A0027 New Alias "A027"
						dbSelectArea("A027")
						dbGoTop()
						kt_DtDig := stod(A027->D1_DTDIGIT)
						A027->(dbCloseArea())
						If Empty(kt_DtDig)
							MsgBox("Nota Fiscal de Origem não localizada para este fornecedor para esta data de digitação!!!", "MT100LOK(xQ)", "STOP")
							AutoGrLog("MT100LOK ==> Nota Fiscal de Origem não localizada para este fornecedor para esta data de digitação!!!")
							lRetorno := .F.
						Else
							xftFornec := aCols[n,cFornMPM]
							xftLoja   := aCols[n,cLjFrMPM]						
						EndIf

					EndIf

				EndIf

				If kt_DtDig == dDataBase

					// Considerando que pode ter quebra na nota fiscal origem, faz-se necessário usar uma query
					//If !FwIsInCallStack('U_GATI001') .Or. (FwIsInCallStack('U_GATI001') .And. !(Upper(Alltrim(cEspecie)) $ "CTR/CTE"))

					If Upper(Alltrim(cEspecie)) $ "CTR/CTE"

						If !msNfCteFch

							If !Type("xtVetNfo") == "U"

								cDocOri := xtVetNfo[n][1]
								cSerieOri := xtVetNfo[n][2]
								cFornOri := xtVetNfo[n][3]
								cLojaOri := xtVetNfo[n][4]								

							Else

								oLoadXML := TLoadXMLCTe():New(ZAA->ZAA_XML, 1)
								oNFeResulStruct := oLoadXML:GetCTe()

								nPos := oNFeResulStruct:oResult:oCTeItens:GetCount()

								cDocOri := oNFeResulStruct:oResult:oCTeItens:GetItem(nPos):cDoc
								cSerieOri := oNFeResulStruct:oResult:oCTeItens:GetItem(nPos):cSerie
								cFornOri := oNFeResulStruct:oResult:oCTeItens:GetItem(nPos):cFornece
								cLojaOri := oNFeResulStruct:oResult:oCTeItens:GetItem(nPos):cLoja								

							EndIf

						Else

							cDocOri   := aCols[n,cPNFOri]
							cSerieOri := aCols[n,cPSeriOri]
							cFornOri  := aCols[n,cLjFrMPM]
							cLojaOri  := aCols[n,cLjFrMPM]	

						EndIf

						A0002 := " SELECT SUM(D1_QUANT) QUANT, SUM(D1_YTICKET) TICKET, SUM(D1_TOTAL) VLRTOT
						A0002 += "   FROM " + RetSqlName("SD1")
						A0002 += "  WHERE D1_FILIAL = '" + xFilial("SD1") + "'
						A0002 += "    AND D1_DOC = '" + cDocOri + "'
						A0002 += "    AND D1_SERIE = '" + cSerieOri + "'
						A0002 += "    AND D1_FORNECE = '" + cFornOri + "'
						A0002 += "    AND D1_LOJA = '" + cLojaOri + "'
						A0002 += "    AND D1_COD = '" + aCols[n,cPCod] + "'
						A0002 += "    AND D_E_L_E_T_ = ' '

						TcQuery A0002 New Alias "A002"
						dbSelectArea("A002")
						dbGoTop()
						xy_Quant 		:= A002->QUANT
						xy_Tickt 		:= A002->TICKET
						xy_VlrTt 		:= A002->VLRTOT
						A002->(dbCloseArea())

						GetCompPreco()

					Else

						A0002 := " SELECT SUM(D1_QUANT) QUANT, SUM(D1_QUANT) TICKET, SUM(D1_TOTAL) VLRTOT "
						A0002 += "   FROM " + RetSqlName("SD1") + " "
						A0002 += "  WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
						A0002 += "    AND D1_DOC = '" + aCols[n,cPNFOri] + "' "
						A0002 += "    AND D1_SERIE = '" + aCols[n,cPSeriOri] + "' "
						A0002 += "    AND D1_FORNECE = '" + xftFornec + "' "
						A0002 += "    AND D1_LOJA = '" + xftLoja + "' "
						A0002 += "    AND D1_DTDIGIT = '" + dtos(dDataBase) + "' "
						A0002 += "    AND D1_COD = '" + aCols[n,cPCod] + "' "
						A0002 += "    AND D_E_L_E_T_ = ' '

						TcQuery A0002 New Alias "A002"
						dbSelectArea("A002")
						dbGoTop()
						xy_Quant 		:= A002->QUANT
						xy_Tickt 		:= A002->TICKET
						xy_VlrTt 		:= A002->VLRTOT
						A002->(dbCloseArea())

					EndIf

					// Exceção à regra para o ticket 25574, pois o fornecedor do serviço também é transportador e emite CTE para o mesmo produto. 
					msCampVlr := "AIB_FRETE"
					If Upper(Alltrim(cEspecie)) == "NFS" .and. cA100For == "004790"
						msCampVlr := "AIB_PRCCOM"
					EndIf

					// Busca os Valores do Frete na Tabela de Preço
					A0001 := " SELECT TOP 1 " + msCampVlr + " AIB_FRETE, AIB_YAPLFR, AIB_YTOLER
					A0001 += "   FROM "+RetSqlName("AIB")+" AIB
					A0001 += "  INNER JOIN "+RetSqlName("AIA")+" AIA ON AIA_FILIAL = '"+xFilial("AIA")+"'
					A0001 += "                       AND AIA_CODTAB = AIB_CODTAB
					A0001 += "                       AND AIA_CODFOR = AIB_CODFOR
					A0001 += "                       AND AIA_LOJFOR = AIB_LOJFOR
					A0001 += "                       AND AIA_DATDE <= '"+dtos(dDataBase)+"'
					A0001 += "                       AND AIA_DATATE >= '"+dtos(dDataBase)+"'
					A0001 += "                       AND AIA.D_E_L_E_T_ = ' '
					A0001 += "  WHERE AIB_FILIAL = '"+xFilial("AIB")+"'
					A0001 += "    AND AIB_CODPRO = '"+aCols[n,cPCod]+"'
					A0001 += "    AND AIB_CODFOR = '"+cA100For+"'
					A0001 += "    AND AIB_LOJFOR = '"+cLoja+"'
					A0001 += "    AND AIB_DATVIG >= '"+dtos(dDataBase)+"'
					A0001 += "    AND AIB.D_E_L_E_T_ = ' '
					TcQuery A0001 New Alias "A001"
					dbSelectArea("A001")
					dbGoTop()

					xk_FrtOk := .T.
					xk_QtdOk := .T.
					If A001->AIB_YAPLFR == "01"     // SOBRE QUANT. N.FISCAL
						If xy_Quant > 0
							xy_VrFrt := NoRound(aCols[n,cPTotal] / xy_Quant,2)
							If xy_VrFrt > A001->AIB_FRETE + A001->AIB_YTOLER
								xk_FrtOk := .F.
							EndIf
						Else
							xk_QtdOk := .F.
						EndIf

					ElseIf A001->AIB_YAPLFR == "02" // SOBRE PESO TICKET N.FISCAL
						If xy_Tickt > 0
							xy_VrFrt := NoRound(aCols[n,cPTotal] / xy_Tickt,2)
							If xy_VrFrt > A001->AIB_FRETE + A001->AIB_YTOLER
								xk_FrtOk := .F.
							EndIf
						Else
							xk_QtdOk := .F.
						EndIf

					ElseIf A001->AIB_YAPLFR == "03" // TOTAL - SOMA ENTRE FRETE (TICKET) + VALOR MERCADORIA
						If xy_Tickt > 0
							xy_VrFrt := NoRound(( aCols[n,cPTotal] + xy_VlrTt ) / xy_Tickt,2)
							If xy_VrFrt > A001->AIB_FRETE + A001->AIB_YTOLER
								xk_FrtOk := .F.
							EndIf
						Else
							xk_QtdOk := .F.
						EndIf

					ElseIf A001->AIB_YAPLFR == "04" // LOCAÇAO
						MsgBox("A princípio para este frete foi definido que deveria ser incluido um pedido de compras e o CTR seria lançado como NFE. Favor verificar!!!", "MT100LOK(xR)", "STOP")
						AutoGrLog("MT100LOK ==> A princípio para este frete foi definido que deveria ser incluido um pedido de compras e o CTR seria lançado como NFE. Favor verificar!!!")
						lRetorno := .F.

					ElseIf A001->AIB_YAPLFR == "05" // SOBRE QUANT. N.FISCAL com fator de conversão
						If xy_Quant > 0
							DbSelectArea("SB1")
							DbSetOrder(1)
							DbSeek(xFilial("SB1")+aCols[n,cPCod])
							xy_VrFrt := NoRound(aCols[n,cPTotal] / (xy_Quant*SB1->B1_CONV),2)
							If xy_VrFrt > A001->AIB_FRETE + A001->AIB_YTOLER
								xk_FrtOk := .F.
							EndIf
						Else
							xk_QtdOk := .F.
						EndIf

					Else

						MsgBox("Tabela de frete sem regra definida. Favor verificar!!!", , "MT100LOK(xS)", "STOP")
						AutoGrLog("MT100LOK ==> Tabela de frete sem regra definida. Favor verificar!!!")
						lRetorno := .F.

					EndIf
					A001->(dbCloseArea())

					//Retirar a validação abaixo para entrada do pedido do fornecedor 009303
					If !xk_FrtOk
						MsgBox("Valor do frete informado está maior que o valor da tabela de preço. Favor verificar!!!", "MT100LOK(xT)", "STOP")
						AutoGrLog("MT100LOK ==> Valor do frete informado está maior que o valor da tabela de preço. Favor verificar!!!")
						lRetorno := .F.
					EndIf

					If !xk_QtdOk
						MsgBox("Problema ao identificar a quantidade da Nota Fiscal de Origem. Favor verificar!!!", "MT100LOK(xU)", "STOP")
						AutoGrLog("MT100LOK ==> Problema ao identificar a quantidade da Nota Fiscal de Origem. Favor verificar!!!")
						lretorno := .F.
					EndIf

					//EndIf

				Else

					MsgBox("A Data de Digitação do CTR não pode ser diferente da Data de Digitação da Nota Fiscal de Entrada. Favor verificar!!!", "MT100LOK(xV)", "STOP")
					AutoGrLog("MT100LOK ==> A Data de Digitação do CTR não pode ser diferente da Data de Digitação da Nota Fiscal de Entrada. Favor verificar!!!")
					lretorno := .F.

				EndIf

			EndIf

		EndIf

	EndIf

	// Processo de Devolução. Incluído por Marcos Alberto em 11/10/11 a pedido da Diretoria.
	// Rotinas envolvidas: BIA267, SF1100I, SF1100E, SD1100I, MT100LOK, MT100GRV
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+aCols[n,cPCod]))
	If cTipo == "D" .and. SB1->B1_TIPO == "PA" .and. cEmpAnt <> "06" //Thiago Haagensen - Ticket 27100 - Exceção à regra de estorno de cancelamento para o processo de devolução no comercial para a empresa “06” JK.
		A0001 := " SELECT COUNT(*) CONTAD
		A0001 += "   FROM "+RetSqlName("Z26")+" Z26"
		A0001 += "  INNER JOIN "+RetSqlName("Z25")+" Z25 ON Z25_FILIAL = '"+xFilial("Z25")+"'
		A0001 += "                       AND Z25_NUM = Z26_NUMPRC
		A0001 += "                       AND Z25_APRADM <> ' '
		A0001 += "                       AND Z25.D_E_L_E_T_ = ' '
		A0001 += "  WHERE Z26_FILIAL = '"+xFilial("Z26")+"'
		A0001 += "    AND Z26_NFISC = '"+aCols[n,cPNFOri]+"'
		A0001 += "    AND Z26_SERIE = '"+aCols[n,cPSeriOri]+"'
		A0001 += "    AND Z26_ITEMNF = '  '
		A0001 += "    AND Z26_OBS = ' '
		A0001 += "    AND Z26.D_E_L_E_T_ = ' '
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		If A001->CONTAD < 1
			MsgBox("Não existe um processo de Devolução cadastrado para esta Nota Fiscal de Vendas!!!"+CHR(13)+CHR(13)+" Ou, não foi apresentado o parecer COMERCIAL!!!", "MT100LOK(xX)", "STOP")
			AutoGrLog("MT100LOK ==> Não existe um processo de Devolução cadastrado para esta Nota Fiscal de Vendas!!!"+CHR(13)+CHR(13)+" Ou, não foi apresentado o parecer COMERCIAL!!!")
			lretorno := .F.
		EndIf
		A001->(dbCloseArea())
	EndIf

	//************************** Cadastrar o lote automaticamente ******************************
	// Inserido por Marcos Alberto Soprani em 04/09/12 conforme OS Effettivo 1960-12
	If Alltrim(GetMv("MV_RASTRO")) == "S" .and. !Upper(Alltrim(cEspecie)) $ "CTR/CTE"
		If SB1->B1_RASTRO == "L"
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+aCols[n,cPTes]))
			If SF4->F4_ESTOQUE == "S" .and. aCols[n,cPQuant] <> 0
				If Empty(aCols[n,cPLoteCTL])
					MsgBox("Para Produto Acabado é necessário informar o número do LOTE!!!", "MT100LOK(xY)", "STOP")
					AutoGrLog("MT100LOK ==> Para Produto Acabado é necessário informar o número do LOTE!!!")
					lretorno := .F.
				Else

					If (AllTrim(SB1->B1_YPCGMR3) <> 'J') //Vinilico

						If !ExistCpo("ZZ9",aCols[n,cPLoteCTL] + aCols[n,cPCod],1)
							MsgBox("O Lote informado não existe para este Produto!!!", "MT100LOK(xZ)", "STOP")
							AutoGrLog("MT100LOK ==> O Lote informado não existe para este Produto!!!")
							lretorno := .F.
						EndIf

					EndIf

				EndIf
			EndIf
		EndIf
	EndIf

	//******************** Controle de Retorno de Poder de terceiros para custo **********************
	// Inserido por Marcos Alberto Soprani em 19/04/13
	If Substr(aCols[n,cPCF],2,3) $ "902/903"
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+aCols[n,cPTes]))
		If SF4->F4_PODER3 == "D" .and. SF4->F4_ESTOQUE <> "S"
			If Empty(aCols[n,cPCodRef])
				MsgBox("Nota Fiscal de Retorno de Remessa para Industrialização" + CHR(13) + CHR(13) + "É necessário informar o CÓDIGO da REFERÊNCIA (Código do produto que retornou industrializado)!!!", "MT100LOK(xW)", "STOP")
				AutoGrLog("MT100LOK ==> Nota Fiscal de Retorno de Remessa para Industrialização" + CHR(13) + CHR(13) + "É necessário informar o CÓDIGO da REFERÊNCIA (Código do produto que retornou industrializado)!!!")
				lretorno := .F.
			EndIf
		EndIf
	EndIf

	//******************** Não permitir de produtos tipo MC creditem ICMS **********************
	// Inserido por Marcos Alberto Soprani em 17/09/12 conforme OS Effettivo 2033-12
	If SB1->B1_TIPO == "MC"
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+aCols[n,cPTes]))
		If SF4->F4_CREDICM == "S"
			MsgBox("Produtos cujo tipo de Produto for MC não poderão creditar ICMS!!!", "MT100LOK(y)", "STOP")
			AutoGrLog("MT100LOK ==> Produtos cujo tipo de Produto for MC não poderão creditar ICMS!")
			lretorno := .F.
		EndIf
	EndIf

	//******************** Validação do Valor unitário do Poder de Terceiros *******************
	// Inserido por Marcos Alberto Soprani em 01/03/13 ... conforme identificado pela Tania.
	If SF4->F4_PODER3 $ "R/D" .and. !cTipo $ "B/D"
		nvPrUnit := aCols[n,nPVunit]
		nvIdenB6 := aCols[n,cPIdentb6]
		nvProdut := aCols[n,cPCod]
		SB6->(dbSetOrder(3))
		If SB6->(dbSeek(xFilial("SB6")+nvIdenB6+nvProdut+"R"))
			If Round(nvPrUnit,2) <> Round(SB6->B6_PRUNIT,2)
				MsgBox("Valor unitário do item divergente do controle de Poder de Terceiros!!! Favor verificar com a Contabilidade!!!", "MT100LOK(y1)", "STOP")
				AutoGrLog("MT100LOK ==> Valor unitário do item divergente do controle de Poder de Terceiros!!! Favor verificar com a Contabilidade!!!")
				lretorno := .F.
			EndIf
		Else
			MsgBox("Problema com a identificação do Poder de Terceiros", "MT100LOK(y2)", "STOP")
			AutoGrLog("MT100LOK ==> Problema com a identificação do Poder de Terceiros")
			lretorno := .F.
		EndIf
	EndIf

	//***************************** Validação do Valor unitário do Poder de Terceiros ******************************
	// Inserido por Marcos Alberto Soprani em 07/01/15 ... para melhorar o controle de retorno de poder de terceiros
	If cEmpAnt == "01" .and. aCols[n,cPTes] $ "057/089" .and. Empty(aCols[n,cPCodRef])
		MsgBox("O campo CODREF não foi preenchido. Sem esta informação não será possível continuar com o lançamento da nota, uma vez que, esta informação é importante para fechamento mensal do custo dos produtos beneficiados. Favor verificar!!!", "MT100LOK(y3)", "STOP")
		AutoGrLog("MT100LOK ==> O campo CODREF não foi preenchido. Sem esta informação não será possível continuar com o lançamento da nota, uma vez que, esta informação é importante para fechamento mensal do custo dos produtos beneficiados. Favor verificar!!!")
		lretorno := .F.
	EndIf

	//RUBENS JUNIOR - 05/08/14 - PEDIDO DO WANISAY, PARA NAO PRECISAR DE RODAR A QUERY QUE ELE RODA TODO MES PARA CORRIGIR O SD1
	If lretorno
		If(Substr(aCols[n,cPConta],1,5) == '31401') .Or. (Substr(aCols[n,cPConta],1,5) == '31404') .Or. (Substr(aCols[n,cPConta],1,5) == '31406')
			If(Empty(aCols[n,cPSI]) .Or. Empty(aCols[n,cPItemCta]))
				// Conforme effettivo 0231-15 esta regra não se aplica a MUNDI
				If cEmpAnt <> "13"
					MsgBox("Para a Conta "+Alltrim(aCols[n,cPConta])+ " Deve-se preencher os campos CLIENTE AI e ITEM DA CONTA", "MT100LOK(y4)", "STOP")
					AutoGrLog("MT100LOK ==> Para a Conta "+Alltrim(aCols[n,cPConta])+ " Deve-se preencher os campos CLIENTE AI e ITEM DA CONTA")
					lretorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	// Tratamento incluido por Marcos Alberto Soprani para atender a OS effettivo 1040-15
	// Rotina ainda nao concluída... não é necessário fazer nada por enquanto... em construção
	If !Empty(cNumPed)

		QR004 := " SELECT SUM(QUANTD1) QTDD1, SUM(QUANTC7) QTDC7
		QR004 += "   FROM (SELECT ISNULL(SUM(D1_QUANT), 0) QUANTD1, 0 QUANTC7
		QR004 += "           FROM " + RetSqlName("SD1")
		QR004 += "          WHERE D1_FILIAL = '"+xFilial("SD1")+"'
		QR004 += "            AND D1_FORNECE = '"+cA100For+"'
		QR004 += "            AND D1_LOJA = '"+cLoja+"'
		QR004 += "            AND D1_COD = '"+aCols[n,cPCod]+"'
		QR004 += "            AND D1_PEDIDO = '"+cNumPed+"'
		QR004 += "            AND D1_ITEMPC = '"+cItemPed+"'
		QR004 += "            AND D1_DOC <> '"+cNFiscal+"'
		QR004 += "            AND D1_SERIE <> '"+cSerie+"'
		QR004 += "            AND D1_ITEM <> '"+aCols[n,cPItem]+"'
		QR004 += "            AND D_E_L_E_T_ = ' '
		QR004 += "          UNION ALL
		QR004 += "         SELECT 0 QUANTD1, SUM(C7_QUANT) QUANTC7
		QR004 += "           FROM " + RetSqlName("SC7")
		QR004 += "          WHERE C7_FILIAL = '"+xFilial("SC7")+"'
		QR004 += "            AND C7_NUM = '"+cNumPed+"'
		QR004 += "            AND C7_ITEM = '"+cItemPed+"'
		QR004 += "            AND C7_FORNECE = '"+cA100For+"'
		QR004 += "            AND C7_LOJA = '"+cLoja+"'
		QR004 += "            AND D_E_L_E_T_ = ' ') AS TBL
		QRlIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR004),'QR04',.T.,.T.)
		dbSelectArea("QR04")
		dbGoTop()
		kjQujEnt := QR04->QTDD1
		kjQtdPc  := QR04->QTDC7
		QR04->(dbCloseArea())
		Ferase(QRlIndex+GetDBExtension())
		Ferase(QRlIndex+OrdBagExt())

		If (aCols[n,cPQuant] + kjQujEnt) > kjQtdPc

			If !fTolerancia(aCols[n, cPCod])

				MsgBox('QUANTIDADE INCORRETA. A quantidade deste item da Nota somada a quantidade já lançada no sistema para o Pedido em questão: '+cNumPed+' item: '+cItemPed+', ultrapassou a quantidade original pedida. Favor entrar em contato com o Setor de COMPRAS para averiguação!!!',"MT100LOK(y5)","ALERT")
				AutoGrLog("MT100LOK ==> QUANTIDADE INCORRETA. A quantidade deste item da Nota somada a quantidade já lançada no sistema para o Pedido em questão: "+cNumPed+" item: "+cItemPed+", ultrapassou a quantidade original pedida. Favor entrar em contato com o Setor de COMPRAS para averiguação!!!")
				lretorno := .F.

			EndIf

		EndIf

	EndIf

	//FERNANDO/FACILE em 04/02/2015
	//Validar OP para entrada de NF VITCER
	If lretorno .And. (INCLUI .OR. ALTERA)
		lretorno := U_FOPVCR01(N)
	EndIf

	//Projeto contrato de verbas - Se o item for I0202, validar para ser obrigatorio preencher o contrato
	If lRetorno .and. !GdDeleted(N) .and. (INCLUI .Or. ALTERA) .and. !Empty(cIemCon) .and. Alltrim(aCols[n,cPItemCta]) == cIemCon .and. Empty(aCols[n,cPCtrVer])
		lRetorno := .F.
		Msgbox("Para item contábil igual '"+cIemCon+"' o campo 'Contrato Ver' deve ser preenchido.","MT100LOK(y6)","STOP")
		AutoGrLog("MT100LOK ==> Para item contábil igual '"+cIemCon+"' o campo 'Contrato Ver' deve ser preenchido.")
	endif

	// Tiago Rossini Coradini - 22/06/2017 - OS: 2709-16 e 0893-16
	If lRetorno .And. !GdDeleted(N) .And. (Inclui .Or. Altera) .And. !Empty(aCols[n,cPTes])

		cMovEst := Posicione("SF4", 1, xFilial("SF4") + aCols[n,cPTes], "F4_ESTOQUE")
		cNtSped := Posicione("CT1", 1, xFilial("CT1") + aCols[n,cPConta], "CT1_NTSPED")
		cxfProd := aCols[n,cPCod]

		If cMovEst == "N" .and. Substr(cxfProd,1,1) == "4" .and. cNtSped <> "01"

			If (cMovEst == "S" .And. cNtSped <> "01") .Or. (cMovEst == "N" .And. cNtSped <> "04")

				lRetorno := .F.

				Msgbox("Favor verificar a Natureza da Operação no cadastro da conta contábil do item: "+ AllTrim(aCols[n,cPItem]) +" da nota, pois o mesmo não corresponde a esta aplicação", "MT100LOK(10)", "STOP")
				AutoGrLog("MT100LOK ==> Favor verificar a Natureza da Operação no cadastro da conta contábil do item: "+ AllTrim(aCols[n,cPItem]) +" da nota, pois o mesmo não corresponde a esta aplicação.")

			EndIf

		EndIf

	EndIf

	// Em 23/03/20 - por Marcos Alberto Soprani em atendimento ao ticket 19569
	If lRetorno .And. !GdDeleted(N) .And. (Inclui .Or. Altera)

		msMovEst := Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_ESTOQUE")
		msAtrbCt := Posicione("CTH", 1, xFilial("CTH") + cCLVL, "CTH_YATRIB")
		msCtaAtv := Posicione("SB1", 1, xFilial("SB1") + cCod, "B1_CONTA")
		msCtaIND := Posicione("SB1", 1, xFilial("SB1") + cCod, "B1_YCTRIND")
		msCtaADM := Posicione("SB1", 1, xFilial("SB1") + cCod, "B1_YCTRADM")

		If Alltrim(cREGRA) == "V" .and. Substr(cConta,1,7) <> "2110899"  

			Msgbox("Para itens de nota cuja regra é V a conta deverá obrigatoriamente se iniciada com 21108990.", "MT100LOK(15)", "STOP")
			AutoGrLog("MT100LOK(15) ==> Para itens de nota cuja regra é V a conta deverá obrigatoriamente se iniciada com 21108990.")
			lRetorno := .F.

		ElseIf msMovEst == "S"

			If ! ( Substr(cConta,1,3) == "113" .or. Alltrim(cConta) == Alltrim(msCtaAtv) ) 
				Msgbox("Para itens de nota que atualizam estoque a conta contábil obrigatoriamente tem que ser iniciada com 113 e/ou igual à conta do Cadastro de Produto.", "MT100LOK(11)", "STOP")
				AutoGrLog("MT100LOK(11) ==> Para itens de nota que atualizam estoque a conta contábil obrigatoriamente tem que ser iniciada com 113 ou igual à conta do Cadastro de Produto.")
				lRetorno := .F.
			EndIf

		Else

			If msAtrbCt == "C"
				If ! ( Substr(cConta,1,1) == "6" .or. Alltrim(cConta) == Alltrim(msCtaIND) )
					Msgbox("Para itens de nota que NÃO atualizam estoque e Abrib Cont for igual C=Custo, obrigatoriamente tem que ser iniciada com 6 e/ou igual à contaIND do Cadastro de Produto.", "MT100LOK(12)", "STOP")
					AutoGrLog("MT100LOK(12) ==> Para itens de nota que NÃO atualizam estoque e Abrib Cont for igual C=Custo, obrigatoriamente tem que ser iniciada com 6 e/ou igual à contaIND do Cadastro de Produto.")
					lRetorno := .F.
				EndIf

			ElseIf msAtrbCt == "D"
				If ! ( Substr(cConta,1,1) == "3" .or. Alltrim(cConta) == Alltrim(msCtaADM) )
					Msgbox("Para itens de nota que NÃO atualizam estoque e Abrib Cont for igual D=Despesa, obrigatoriamente tem que ser iniciada com 3 e/ou igual à contaADM do Cadastro de Produto.", "MT100LOK(13)", "STOP")
					AutoGrLog("MT100LOK(13) ==> Para itens de nota que NÃO atualizam estoque e Abrib Cont for igual D=Despesa, obrigatoriamente tem que ser iniciada com 3 e/ou igual à contaADM do Cadastro de Produto.")
					lRetorno := .F.
				EndIf

			ElseIf msAtrbCt $ "A/I"
				If Substr(cConta,1,5) <> "16503"
					Msgbox("Para itens de nota que NÃO atualizam estoque e Abrib Cont for igual I=ImobilizadoIND e/ou A=ImobilizadoADM, obrigatoriamente tem que ser iniciada com 16503.", "MT100LOK(14)", "STOP")
					AutoGrLog("MT100LOK(13) ==> Para itens de nota que NÃO atualizam estoque e Abrib Cont for igual I=ImobilizadoIND e/ou A=ImobilizadoADM, obrigatoriamente tem que ser iniciada com 16503.")
					lRetorno := .F.
				EndIf
			EndIf

		EndIf

	EndIf

	If lRetorno .And. !GdDeleted(N) .And. (Inclui .Or. Altera)

		// Valida Subitem de projeto
		If !U_BIAF160(cCLVL, cItemCta, cSubItem)

			MsgBox("A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!", "MT100LOK(y7)", "STOP")

			AutoGrLog("MT100LOK ==> A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!")

			lRetorno := .F.

		EndIf

	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	If cArqSBM <> ""
		dbSelectArea(cArqSBM)
		dbSetOrder(cIndSBM)
		dbGoTo(cRegSBM)
		RetIndex("SBM")
	EndIf

	If cArqSF4 <> ""
		dbSelectArea(cArqSF4)
		dbSetOrder(cIndSF4)
		dbGoTo(cRegSF4)
		RetIndex("SF4")
	EndIf

	If cArqSC7 <> ""
		dbSelectArea(cArqSC7)
		dbSetOrder(cIndSC7)
		dbGoTo(cRegSC7)
		RetIndex("SC7")
	EndIf

	If cArqSF1 <> ""
		dbSelectArea(cArqSF1)
		dbSetOrder(cIndSF1)
		dbGoTo(cRegSF1)
		RetIndex("SF1")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

Return(lRetorno)

//****************************************************************************************
//----------------------------------------------------------------------------------------
//****************************************************************************************
Static Function fAtua_5()

	IF ALLTRIM(sIPI) <> "" // VERIFICANDO SE =FOI PEENCHIDOMADALENO
		RecLock("SB1",.F.)
		SB1->B1_POSIPI := sIPI
		SB1->B1_YALTNCM := alltrim(upper(cUserName))
		//SB1->B1_YALTIPI := alltrim(upper(cUserName))
		MsUnlock()
		SFLAG := "2"
		Close(oEntra)
	END IF

Return

/*DESABILITADO DE ACORDO COM SOLITIAÇÃO DO TICKET 18778
//****************************************************************************************
//------------------------ Atuliza Tes no Cadastro de Produto ----------------------------
//****************************************************************************************
Static Function fAtualiza()

If nRadio == 1 			//Atualiza Cad. Produto com TES da NF
RecLock("SB1",.F.)
SB1->B1_TE := cTes
MsUnlock()
Close(oDlg1)
lretorno := .T.
Else                    //Cad. Produto esta com a TES em branco
cNovaTes := SPACE(3)
@ 0,0 TO 100,250 DIALOG oDlg2 TITLE "Informe a TES"
@ 010,010 SAY "Informe a Nova TES:"; @10,70 GET cNovaTes PICT "@!R"
@ 030,050 BMPBUTTON TYPE 1 ACTION fAtualiza2()
@ 030,080 BMPBUTTON TYPE 2 ACTION fSair2()
ACTIVATE DIALOG oDlg2 CENTERED
EndIf

Return()
*/
/*
//****************************************************************************************
//-------------------------- Grava a Nova Tes Informada  ---------------------------------
//****************************************************************************************
Static Function fAtualiza2()

RecLock("SB1",.F.)
SB1->B1_TE := cNovaTes
MsUnlock()
lretorno := .T.
Close(oDlg2)
Close(oDlg1)

Return()
*/

/*DESABILITADO DE ACORDO COM SOLITIAÇÃO DO TICKET 18778
//****************************************************************************************
//---------------------------------  Fecha Tela 1  ---------------------------------------
//****************************************************************************************
Static Function fSair()

Close(oDlg1)

Return()
*/
/*
//****************************************************************************************
//---------------------------------  Fecha Tela 2  ---------------------------------------
//****************************************************************************************
Static Function fSair2()

Close(oDlg2)
Close(oDlg1)

Return()
*/


Static Function GetCompPreco()

	Local cArea := GetArea()
	//corrigi problema de validação de NFe complemento com tipo complemento igual a preço
	//quantidade cte origem referenciado zerada
	//buscando a nota fiscal que está sendo referenciada no Cte origem
	If (AllTrim(cTipo) == 'C' .And. AllTrim(cTpCompl) == '1' .And. xy_Quant <= 0) 

		A0002 := " SELECT F1_CHVNFE
		A0002 += "   FROM " + RetSqlName("SF1")
		A0002 += "  WHERE F1_FILIAL = '"+xFilial("SF1")+"'
		A0002 += "    AND F1_DOC = '"+cDocOri+"'
		A0002 += "    AND F1_SERIE = '"+cSerieOri+"'
		A0002 += "    AND F1_FORNECE = '"+cFornOri+"'
		A0002 += "    AND F1_LOJA = '"+cLojaOri+"'
		A0002 += "    AND D_E_L_E_T_ = ' '

		TcQuery A0002 New Alias "A002"
		dbSelectArea("A002")
		dbGoTop()
		__cChaveNFe		:= A002->F1_CHVNFE
		A002->(dbCloseArea())

		If (!Empty(__cChaveNFe))

			DbSelectArea('ZAA')
			ZAA->(DbSetOrder(1))
			If (ZAA->(DbSeek(__cChaveNFe)))

				oLoadXML := TLoadXMLCTe():New(ZAA->ZAA_XML, 1)
				oNFeResulStruct := oLoadXML:GetCTe()

				nPos := oNFeResulStruct:oResult:oCTeItens:GetCount()

				if (nPos == 1)

					cDocOri := oNFeResulStruct:oResult:oCTeItens:GetItem(nPos):cDoc
					cSerieOri := oNFeResulStruct:oResult:oCTeItens:GetItem(nPos):cSerie
					cFornOri := oNFeResulStruct:oResult:oCTeItens:GetItem(nPos):cFornece
					cLojaOri := oNFeResulStruct:oResult:oCTeItens:GetItem(nPos):cLoja	

					A0002 := " SELECT SUM(D1_QUANT) QUANT, SUM(D1_YTICKET) TICKET, SUM(D1_TOTAL) VLRTOT
					A0002 += "   FROM " + RetSqlName("SD1")
					A0002 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
					A0002 += "    AND D1_DOC = '"+cDocOri+"'
					A0002 += "    AND D1_SERIE = '"+cSerieOri+"'
					A0002 += "    AND D1_FORNECE = '"+cFornOri+"'
					A0002 += "    AND D1_LOJA = '"+cLojaOri+"'
					A0002 += "    AND D1_COD = '"+aCols[n,cPCod]+"'
					A0002 += "    AND D_E_L_E_T_ = ' '

					TcQuery A0002 New Alias "A002"
					dbSelectArea("A002")
					dbGoTop()
					xy_Quant 		:= A002->QUANT
					xy_Tickt 		:= A002->TICKET
					xy_VlrTt 		:= A002->VLRTOT
					A002->(dbCloseArea())

				EndIf

			EndIf

		EndIf
	EndIf

	RestArea(cArea)

Return

// Analisa se o produto esta associado ao cadastro de tolerancia de recebimento
Static Function fTolerancia(cProd)

	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cGrupo := ""

	DbSelectArea("SB1")
	DbSetOrder(1)
	If SB1->(MsSeek(xFilial("SB1") + cProd))

		cGrupo := SB1->B1_GRUPO

	EndIf

	cSQL := " SELECT AIC_CODIGO "
	cSQL += " FROM " + RetSQLName("AIC")
	cSQL += " WHERE AIC_FILIAL = " + ValToSQL(xFilial("AIC"))
	cSQL += " AND AIC_PQTDE > 0 "
	cSQL += " AND AIC_PPRECO > 0 "
	cSQL += " AND (AIC_PRODUT = " + ValToSQL(cProd) + " OR AIC_GRUPO = " + ValToSQL(cGrupo) + ")"
	cSQL += " AND D_E_L_E_T_ = ''

	TcQuery cSQL New Alias (cQry)

	lRet := !Empty((cQry)->AIC_CODIGO)

	(cQry)->(dbCloseArea())

Return(lRet)
