#include "rwmake.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} BIA863
@author Ranisses A. Corona
@since 30/05/2014
@version 1.0
@description Grava informações adicionais no Cadastro de Cliente
@obs Replicação do Cadastro de Clientes para as demais Empresas Protheus
@obs Replicação do Cadastro de Clientes para Ecosis 
@obs Adequação para o processo BIZAGI
@obs Melhorias para o processo de Rede de Compras e revisão do fonte.
@obs Alteração e unificacao na funcao que define o Grupo de Tributacao 
@type function
/*/

User Function BIA863()

	CONOUT('Iniciando o BIA863...')

	Private xCodRe  := ""

	Private cArqCT1	:= ""
	Private cIndCT1	:= 0
	Private cRegCT1	:= 0

	Private cArqSIX	:= ""
	Private cIndSIX	:= 0
	Private cRegSIX	:= 0

	Private cCdRgFin := ""

	DbSelectArea("CT1")
	cArqCT1 := Alias()
	cIndCT1 := IndexOrd()
	cRegCT1 := Recno()

	DbSelectArea("SIX")
	cArqSIX := Alias()
	cIndSIX := IndexOrd()
	cRegSIX := Recno()

	//Retira "TAB" da Razao Social, Endereco, Telefone, Contato...
	M->A1_NOME		:= U_fDelTab(M->A1_NOME)
	M->A1_NREDUZ	:= U_fDelTab(M->A1_NREDUZ)
	M->A1_END		:= U_fDelTab(M->A1_END)
	M->A1_ENDCOB	:= U_fDelTab(M->A1_ENDCOB)
	M->A1_ENDREC	:= U_fDelTab(M->A1_ENDREC)
	M->A1_BAIRRO	:= U_fDelTab(M->A1_BAIRRO)
	M->A1_COMPLEM	:= U_fDelTab(M->A1_COMPLEM)
	M->A1_TEL		:= U_fDelTab(M->A1_TEL)
	M->A1_FAX		:= U_fDelTab(M->A1_FAX)
	M->A1_CONTATO	:= U_fDelTab(M->A1_CONTATO)
	M->A1_EMAIL		:= U_fDelTab(M->A1_EMAIL)
	M->A1_YMAILNF	:= U_fDelTab(M->A1_YMAILNF)

	//Define o Grupo de Tributacao
	M->A1_GRPTRIB	:= U_fGetGrTr(M->A1_SUFRAMA,M->A1_CALCSUF,M->A1_TIPO,M->A1_CONTRIB,M->A1_INSCR,M->A1_SATIV1,M->A1_TPJ)

	//Definie Regra Cobranca
	If Empty(Alltrim(M->A1_YCDGREG)) 
		cCdRgFin	:= U_fRegCobr(Alltrim(M->A1_EST), Alltrim(M->A1_CGC), Alltrim(M->A1_GRPVEN), Alltrim(M->A1_COD))
		If cCdRgFin <> Alltrim(M->A1_YCDGREG)		
			M->A1_YCDGREG := cCdRgFin
		EndIf
	Else
		cCdRgFin := M->A1_YCDGREG
	EndIf
	
	If !Empty(Alltrim(M->A1_GRPVEN)) .And. (M->A1_GRPVEN <> SA1->A1_GRPVEN)
		cCdRgFin	:= U_fRegCobr(Alltrim(M->A1_EST), Alltrim(M->A1_CGC), Alltrim(M->A1_GRPVEN), Alltrim(M->A1_COD))
	EndIf

	//Solicitado pelo Vagner no dia 26/08/10
	If cEmpAnt <> "02" .And. M->A1_SATIV1 == '000099'
		M->A1_YDTPRO := 3
	EndIf

	//Fernando/Facile em 02/03/2017 - gravando valor default do campo NLOJA caso nao tenha sido preenchido
	If Empty(AllTrim(M->A1_YNLOJA))
		M->A1_YNLOJA := AllTrim(SUBSTR(M->A1_NREDUZ,1,15))+'/'+AllTrim(SUBSTR(M->A1_MUN,1,11))+'/'+M->A1_EST
	EndIf

	//Replica cadastro do Cliente para demais empresas - IMPORTANTE - NAO ALTERAR A ORDEM NA CHAMADA DAS FUNCOES
	If (Inclui .or. Altera) .And. cEmpAnt <> "02"

		//Cadastrar de Conta Contabil
		Processa({|| fGravCT1() }, "Aguarde...", "Cadastrando Conta Contabil...",.F.)

		//Atualizar as informações de Rede de Compras
		//TODO REMOVER
		//Avaliação caso tenha atualizado o grupo, poderá impactar na rede de compras
		IF M->A1_GRPVEN != SA1->A1_GRPVEN

			cQryRED	:= GetNextAlias()

			IF TRIM( M->A1_GRPVEN) != ""
				sqlRed := "SELECT MAX(Z79_REDE) REDE from Z79010 where Z79_CODGRP = '"+ M->A1_GRPVEN +"' and D_E_L_E_T_ = ''"
			Else
				sqlRed := "SELECT MAX(Z79_REDE) REDE from Z79010 where Z79_CODCLI = '"+ M->A1_COD +"' and Z79_LOJCLI = '"+M->A1_LOJA+"' and D_E_L_E_T_ = ''"
			EndIf
			TcQuery sqlRed New Alias (cQryRED)

			If !(cQryRED)->(Eof())
				M->A1_YREDCOM := (cQryRED)->REDE
			EndIf

			(cQryRED)->(DbCloseArea())

		END IF

		//Replicar Cadastro Cliente
		Processa( {|| fReplCli() }, "Aguarde...", "Replicando Cadastro de Cliente...",.F.)

		//Atualizar informações Crédito do Grupo de Cliente
		If ALTERA .And. U_VALOPER("040",.F.) .And. Alltrim(M->A1_GRPVEN) <> "" .And. Alltrim(M->A1_YTIPOLC) == "G"
			Processa( {|| fGrpVen(M->A1_RISCO,M->A1_LC,M->A1_VENCLC,M->A1_GRPVEN) }, "Aguarde...", "Atualizando informações de Crédito...",.F.)
		EndIf

		//Cadastrar Contatos
		Processa({|| fGravSU5() }, "Aguarde...", "Cadastrando Contatos...",.F.)

		//DESATIVADO EM 12/08/2021 - REPLICACAO NO CADASTRO DE CLIENTE / CORRIGIDO AS SPs EOS_VALID_EXP_OC_XXXX QUE GRAVA O CLIENTE NO ECOSIS
		//Replica Cadastro de Clientes no Sistema Ecosis
		//Processa({|| ImpCliECO() }, "Aguarde...", "Replicando Clientes para sistema Ecosis...",.F.)

	EndIf

	SA1->(MsUnLock())
	SA1->(dbcommitall())

	If cArqCT1 <> ""
		dbSelectArea(cArqCT1)
		dbSetOrder(cIndCT1)
		dbGoTo(cRegCT1)
		RetIndex("CT1")
	EndIf

	If cArqSIX <> ""
		dbSelectArea(cArqSIX)
		dbSetOrder(cIndSIX)
		dbGoTo(cRegSIX)
	EndIf

Return

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ fGravCT1³ Autor ³                         ³ Data ³ 12/03/01 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Cria plano de Contas novo para cliente novo.                ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGravCT1()

	Local cCTAFIDC
	local cCT1Filial:=xFilial("CT1")
	local cCVDFilial:=xFilial("CVD")

	If Inclui .Or. Altera
		IF SUBSTR(ALLTRIM(M->A1_CONTA),9,6) <> ALLTRIM(M->A1_COD)
			M->A1_CONTA := SUBSTR(M->A1_CONTA,1,8)+ALLTRIM(M->A1_COD)
			MsgBox("Conta contabil informada incorretamente! O sistema realizara a correção automaticamente","BIA863","INFO")
			//Aviso("BIA863","Conta contabil informada incorretamente! O sistema realizara a correção automaticamente",{"OK"})
		ENDIF

		If !Empty(M->A1_CONTA) //.And. M->A1_EST <> "EX"

			DbSelectArea("CT1")

			CT1->(DbSetOrder(2))
			CT1->(DbGoBottom())
			xCodRe := Soma1(CT1->CT1_RES)

			DbSelectArea("CT1")
			CT1->(DbSetOrder(1))

			If CT1->(!DbSeek(cCT1Filial+M->A1_CONTA,.F.))

				if CT1->(RecLock("CT1",.T.))
					CT1->CT1_FILIAL		:= cCT1Filial
					CT1->CT1_CONTA		:= M->A1_CONTA
					CT1->CT1_DESC01		:= M->A1_NOME
					CT1->CT1_CLASSE		:= "2"
					CT1->CT1_NORMAL		:= "1"
					CT1->CT1_BLOQ 		:= "2"
					CT1->CT1_RES    	:= xCodRe
					CT1->CT1_CTASUP   	:= "11201001"
					CT1->CT1_GRUPO		:= "1"
					CT1->CT1_CVD02		:= "5"
					CT1->CT1_CVD03		:= "5"
					CT1->CT1_CVD04		:= "5"
					CT1->CT1_CVD05		:= "5"
					CT1->CT1_CVC02   	:= "5"
					CT1->CT1_CVC03   	:= "5"
					CT1->CT1_CVC04   	:= "5"
					CT1->CT1_CVC05   	:= "5"
					CT1->CT1_DC				:= CTBDIGCONT(CT1->CT1_CONTA)
					CT1->CT1_BOOK			:= "001"
					CT1->CT1_CCOBRG		:= "2"
					CT1->CT1_ITOBRG		:= "2"
					CT1->CT1_CLOBRG		:= "2"
					CT1->CT1_LALUR		:= "0"
					CT1->CT1_DTEXIS		:= dDataBase
					CT1->CT1_INDNAT		:= '1'
					CT1->CT1_NTSPED		:= "01"
					CT1->CT1_SPEDST		:= "2"
					CT1->(MsUnlock())

					if CVD->(RECLOCK("CVD",.T.))
						CVD->CVD_FILIAL	:= cCVDFilial
						CVD->CVD_ENTREF	:= "10"
						CVD->CVD_CODPLA	:= "002"
						CVD->CVD_CONTA	:=  M->A1_CONTA
						CVD->CVD_CTAREF	:= "1.01.02.02.01"
						CVD->(MSUNLOCK())
					endif

				endif

			Endif

			if (FIDC():isFIDCEnabled())

				cCTAFIDC:="11201013"
				cCTAFIDC+=subStr(M->A1_CONTA,9)

				xCodRe:=Soma1(xCodRe)

				If CT1->(!DbSeek(cCT1Filial+cCTAFIDC,.F.))

					if CT1->(RecLock("CT1",.T.))
						CT1->CT1_FILIAL		:= cCT1Filial
						CT1->CT1_CONTA		:= cCTAFIDC
						CT1->CT1_DESC01		:= M->A1_NOME
						CT1->CT1_CLASSE		:= "2"
						CT1->CT1_NORMAL		:= "2"
						CT1->CT1_BLOQ 		:= "2"
						CT1->CT1_RES    	:= xCodRe
						CT1->CT1_CTASUP   	:= "11201013"
						CT1->CT1_GRUPO		:= "1"
						CT1->CT1_CVD02		:= "5"
						CT1->CT1_CVD03		:= "5"
						CT1->CT1_CVD04		:= "5"
						CT1->CT1_CVD05		:= "5"
						CT1->CT1_CVC02   	:= "5"
						CT1->CT1_CVC03   	:= "5"
						CT1->CT1_CVC04   	:= "5"
						CT1->CT1_CVC05   	:= "5"
						CT1->CT1_DC			:= CTBDIGCONT(cCTAFIDC)
						CT1->CT1_BOOK		:= "001"
						CT1->CT1_CCOBRG		:= "2"
						CT1->CT1_ITOBRG		:= "2"
						CT1->CT1_CLOBRG		:= "2"
						CT1->CT1_LALUR		:= "0"
						CT1->CT1_DTEXIS		:= dDataBase
						CT1->CT1_INDNAT		:= '1'
						CT1->CT1_NTSPED		:= "01"
						CT1->CT1_SPEDST		:= "2"
						CT1->(MsUnlock())

						if CVD->(RECLOCK("CVD",.T.))
							CVD->CVD_FILIAL	:= cCVDFilial
							CVD->CVD_ENTREF	:= "10"
							CVD->CVD_CODPLA	:= "002"
							CVD->CVD_CONTA	:=  cCTAFIDC
							CVD->CVD_CTAREF	:= "1.01.02.02.01"
							CVD->(MSUNLOCK())
						endif

					endif

				endif

			endif

			DbCommitAll()

		endif

	Endif

Return

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³         ³ Autor ³                         ³ Data ³          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Grava a Tabela SU5 - Contatos                               ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGravSU5()

	DbSelectArea("SU5")
	DbSetOrder(1)
	If !DbSeek(xFilial("SU5")+M->A1_COD,.F.)
		RecLock("SU5",.T.)
		SU5->U5_FILIAL	:= XFILIAL("SA1")
		SU5->U5_CODCONT := M->A1_COD
		SU5->U5_CONTAT	:= M->A1_NREDUZ
		SU5->U5_FONE    := M->A1_TEL
		SU5->U5_EMAIL	:= M->A1_EMAIL
		MsUnLock()
	Endif

Return

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³fReplCli ³ Autor ³                         ³ Data ³          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Replica o cadastro de Cliente para Biancogres/Incesa/LM     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fReplCli()

	Local aEmp		:= {"01","05","07","12","13","14","16","17"} //Define empresas para replicação do cadastro de clientes
	Local xx		:= 0 //Variavel de Controle do For/Next
	Local __EMPRESA	:= ""
	Local n			:= 0
	Local cIndex	:= ""
	Local cArq		:= ""
	Local cInd		:= ""

	//Executa a replicação para todas as empresas definidas no parametro aEmp
	For xx := 1 to Len(aEmp)

		//Zerando Variaveis
		__EMPRESA	:= aEmp[xx]+"0"
		cIndex		:= ""
		cArq		:= ""
		cInd		:= ""

		//NÃO REPLICA PARA EMPRESA CORRENTE
		If cEmpAnt <> aEmp[xx]

			//Abrir base correspondente SA1 E Setando os Indices
			cArq:="SA1"+__EMPRESA
			DbSelectArea("SIX")
			DbSetOrder(1)
			DbSeek("SA1")

			Do while .not. eof() .and. INDICE=="SA1"
				cIndex+=cArq+SIX->ORDEM
				DbSkip()
			EndDo

			If chkfile("_SA1")
				DbSelectArea("_SA1")
				DbCloseArea()
			EndIf

			Use &cArq Alias "_SA1" Shared New Via "TopConn"

			For n:=1 to 15 step 7
				cInd := Subs(cIndex,n,7)
				DbSetIndex(cInd)
			Next

			//Verificando se vai incluir ou alterar
			If Inclui
				dbSelectArea("_SA1")
				RecLock("_SA1",.T.)
			elseif altera
				ccSQL := "SELECT * FROM SA1"+__EMPRESA
				ccSQL += " WHERE	A1_COD = '"+M->A1_COD+"' AND  "
				ccSQL += "		A1_LOJA = '"+M->A1_LOJA+"' AND "
				ccSQL += "		D_E_L_E_T_ = '' "
				If chkfile("_AuxCli")
					dbSelectArea("_AuxCli")
					dbCloseArea()
				EndIf
				TCQUERY ccSQL ALIAS "_AuxCli" NEW
				if _AuxCli->(eof())
					dbSelectArea("_SA1")
					dbSetOrder(1)
					dbSeek(xFilial("_SA1")+M->A1_COD+M->A1_LOJA)
					RecLock("_SA1",.T.)
				else
					dbSelectArea("_SA1")
					dbSetOrder(1)
					dbSeek(xFilial("_SA1")+M->A1_COD+M->A1_LOJA)
					RecLock("_SA1",.F.)
				end if
			Else
				dbSelectArea("_SA1")
				dbSetOrder(1)
				dbSeek(xFilial("_SA1")+M->A1_COD+M->A1_LOJA)
				RecLock("_SA1",.F.)
				dbDelete()
				msUnlock()
			End If

			_SA1->A1_FILIAL  := M->A1_FILIAL
			_SA1->A1_COD     := M->A1_COD
			_SA1->A1_LOJA    := M->A1_LOJA
			_SA1->A1_NOME    := U_fDelTab(M->A1_NOME)
			_SA1->A1_CGC     := M->A1_CGC
			_SA1->A1_PESSOA  := M->A1_PESSOA
			_SA1->A1_NREDUZ  := M->A1_NREDUZ
			_SA1->A1_TIPO    := M->A1_TIPO
			_SA1->A1_END     := U_fDelTab(M->A1_END)
			_SA1->A1_EST     := M->A1_EST
			_SA1->A1_MUN     := M->A1_MUN
			_SA1->A1_BAIRRO  := M->A1_BAIRRO
			_SA1->A1_COMPLEM  := M->A1_COMPLEM
			_SA1->A1_CEP     := M->A1_CEP
			_SA1->A1_NATUREZ := M->A1_NATUREZ
			_SA1->A1_ATIVIDA := M->A1_ATIVIDA
			_SA1->A1_YCLIAGR := M->A1_YCLIAGR
			_SA1->A1_TEL     := U_fDelTab(M->A1_TEL)
			_SA1->A1_TELEX   := M->A1_TELEX
			_SA1->A1_FAX     := M->A1_FAX
			_SA1->A1_CONTATO := M->A1_CONTATO
			_SA1->A1_ENDCOB  := M->A1_ENDCOB
			_SA1->A1_ENDREC  := M->A1_ENDREC
			_SA1->A1_MUNC    := M->A1_MUNC
			_SA1->A1_ENDENT  := M->A1_ENDENT
			_SA1->A1_ESTC    := M->A1_ESTC
			_SA1->A1_BAIRROC := M->A1_BAIRROC
			_SA1->A1_CEPC    := M->A1_CEPC

			If SA1->(FieldPos("A1_YCODMUN")) > 0

				_SA1->A1_YCODMUN := M->A1_YCODMUN

			EndIf

			_SA1->A1_INSCR   := M->A1_INSCR
			_SA1->A1_INSCRM  := M->A1_INSCRM

			//Vendedor e Comissão Biancogres
			_SA1->A1_VEND		:= M->A1_VEND
			_SA1->A1_COMIS		:= M->A1_COMIS
			_SA1->A1_YVENDB2	:= M->A1_YVENDB2
			_SA1->A1_YCOMB2		:= M->A1_YCOMB2
			_SA1->A1_YVENDB3	:= M->A1_YVENDB3
			_SA1->A1_YCOMB3		:= M->A1_YCOMB3

			//Vendedor e Comissão Incesa
			_SA1->A1_YVENDI		:= M->A1_YVENDI
			_SA1->A1_YCOMISI	:= M->A1_YCOMISI
			_SA1->A1_YVENDI2	:= M->A1_YVENDI2
			_SA1->A1_YCOMI2		:= M->A1_YCOMI2
			_SA1->A1_YVENDI3	:= M->A1_YVENDI3
			_SA1->A1_YCOMI3		:= M->A1_YCOMI3

			//Vendedor e Comissão Bellacasa
			_SA1->A1_YVENBE1	:= M->A1_YVENBE1
			_SA1->A1_YVENBE2	:= M->A1_YVENBE2
			_SA1->A1_YVENBE3	:= M->A1_YVENBE3
			_SA1->A1_YCOMBE1	:= M->A1_YCOMBE1
			_SA1->A1_YCOMBE2	:= M->A1_YCOMBE2
			_SA1->A1_YCOMBE3	:= M->A1_YCOMBE3

			//Vendedor e Comissão Mundialli
			_SA1->A1_YVENML1	:= M->A1_YVENML1
			_SA1->A1_YVENML2	:= M->A1_YVENML2
			_SA1->A1_YVENML3	:= M->A1_YVENML3
			_SA1->A1_YCOMML1	:= M->A1_YCOMML1
			_SA1->A1_YCOMML2	:= M->A1_YCOMML2
			_SA1->A1_YCOMML3	:= M->A1_YCOMML3

			//Vendedor e Comissão Vitcer
			_SA1->A1_YVENVT1	:= M->A1_YVENVT1
			_SA1->A1_YVENVT2	:= M->A1_YVENVT2
			_SA1->A1_YVENVT3	:= M->A1_YVENVT3
			_SA1->A1_YCOMVT1	:= M->A1_YCOMVT1
			_SA1->A1_YCOMVT2	:= M->A1_YCOMVT2
			_SA1->A1_YCOMVT3	:= M->A1_YCOMVT3

			//Vendedor e Comissão pegasus
			_SA1->A1_YVENPEG	:= M->A1_YVENPEG
			_SA1->A1_YCOMPEG	:= M->A1_YCOMPEG

			//Vendedor e Comissão Vinilico
			_SA1->A1_YVENVI1	:= M->A1_YVENVI1
			_SA1->A1_YCOMVI1	:= M->A1_YCOMVI1


			_SA1->A1_REGIAO  	:= M->A1_REGIAO
			_SA1->A1_CONTA   	:= M->A1_CONTA
			_SA1->A1_BCO1    	:= M->A1_BCO1
			_SA1->A1_BCO2    	:= M->A1_BCO2
			_SA1->A1_BCO3    	:= M->A1_BCO3
			_SA1->A1_BCO4    	:= M->A1_BCO4
			_SA1->A1_BCO5    	:= M->A1_BCO5
			_SA1->A1_TRANSP  	:= M->A1_TRANSP
			_SA1->A1_TPFRET  	:= M->A1_TPFRET
			_SA1->A1_COND    	:= M->A1_COND
			_SA1->A1_DESC    	:= M->A1_DESC
			_SA1->A1_CLASSE  	:= M->A1_CLASSE
			_SA1->A1_PRIOR   	:= M->A1_PRIOR
			_SA1->A1_YBLQDIR 	:= M->A1_YBLQDIR

			_SA1->A1_RISCO   	:= M->A1_RISCO		//Igual nas duas empresas
			_SA1->A1_LC      	:= M->A1_LC			//Igual nas duas empresas
			_SA1->A1_VENCLC  	:= M->A1_VENCLC		//Igual nas duas empresas
			//_SA1->A1_MCOMPRA 	:= M->A1_MCOMPRA
			_SA1->A1_TEMVIS  	:= M->A1_TEMVIS
			_SA1->A1_ULTVIS  	:= M->A1_ULTVIS
			_SA1->A1_MENSAGE 	:= M->A1_MENSAGE
			_SA1->A1_SUFRAMA 	:= M->A1_SUFRAMA
			_SA1->A1_TRANSF  	:= M->A1_TRANSF
			_SA1->A1_TABELA  	:= M->A1_TABELA
			_SA1->A1_INCISS  	:= M->A1_INCISS
			//_SA1->A1_SALTEMP := M->A1_SALTEMP
			_SA1->A1_AGREG   	:= M->A1_AGREG
			_SA1->A1_CARGO1  	:= M->A1_CARGO1
			_SA1->A1_CONTAT2 	:= M->A1_CONTAT2
			_SA1->A1_CARGO2  	:= M->A1_CARGO2
			_SA1->A1_CONTAT3 	:= M->A1_CONTAT3
			_SA1->A1_CARGO3  	:= M->A1_CARGO3
			_SA1->A1_SUPER   	:= M->A1_SUPER
			_SA1->A1_RTEC    	:= M->A1_RTEC
			_SA1->A1_ALIQIR  	:= M->A1_ALIQIR
			_SA1->A1_OBSERV  	:= M->A1_OBSERV
			_SA1->A1_CALCSUF 	:= M->A1_CALCSUF
			_SA1->A1_RG      	:= M->A1_RG
			_SA1->A1_DTNASC  	:= M->A1_DTNASC
			//_SA1->A1_SALPEDB := M->A1_SALPEDB
			_SA1->A1_CLIFAT  	:= M->A1_CLIFAT
			_SA1->A1_GRPTRIB 	:= M->A1_GRPTRIB
			_SA1->A1_BAIRROE 	:= M->A1_BAIRROE
			_SA1->A1_CEPE    	:= M->A1_CEPE
			_SA1->A1_MUNE    	:= M->A1_MUNE
			_SA1->A1_ESTE    	:= M->A1_ESTE
			_SA1->A1_SATIV1  	:= M->A1_SATIV1
			_SA1->A1_SATIV2  	:= M->A1_SATIV2
			_SA1->A1_SATIV3  	:= M->A1_SATIV3
			_SA1->A1_SATIV4  	:= M->A1_SATIV4
			_SA1->A1_SATIV5  	:= M->A1_SATIV5
			_SA1->A1_SATIV6  	:= M->A1_SATIV6
			_SA1->A1_SATIV7  	:= M->A1_SATIV7
			_SA1->A1_SATIV8  	:= M->A1_SATIV8
			_SA1->A1_EMAIL   	:= M->A1_EMAIL

			If INCLUI // Retirar esse trecho quando o campo for criado no Bizagi

				M->A1_YEMABOL	:= M->A1_EMAIL

			EndIf

			_SA1->A1_YEMABOL  	:= M->A1_YEMABOL
			_SA1->A1_HPAGE   	:= M->A1_HPAGE
			_SA1->A1_DPMATV  	:= M->A1_DPMATV
			_SA1->A1_CODMUN  	:= M->A1_CODMUN
			_SA1->A1_YCXPOST 	:= M->A1_YCXPOST
			_SA1->A1_YPAIS   	:= M->A1_YPAIS
			_SA1->A1_CODHIST 	:= M->A1_CODHIST
			_SA1->A1_YCONT1  	:= M->A1_YCONT1
			_SA1->A1_PAIS    	:= M->A1_PAIS
			_SA1->A1_CODPAIS 	:= M->A1_CODPAIS
			_SA1->A1_YCONT2  	:= M->A1_YCONT2
			_SA1->A1_RECINSS 	:= M->A1_RECINSS
			_SA1->A1_TMPSTD  	:= M->A1_TMPSTD
			_SA1->A1_AVACLI1 	:= M->A1_AVACLI1
			_SA1->A1_AVACLI2 	:= M->A1_AVACLI2
			_SA1->A1_AVACLI3 	:= M->A1_AVACLI3
			_SA1->A1_AVACLI4 	:= M->A1_AVACLI4
			_SA1->A1_AVACLI5 	:= M->A1_AVACLI5
			_SA1->A1_AVACLI6 	:= M->A1_AVACLI6
			_SA1->A1_CLASVEN 	:= M->A1_CLASVEN
			_SA1->A1_CODAGE  	:= M->A1_CODAGE
			_SA1->A1_CODMARC 	:= M->A1_CODMARC
			_SA1->A1_COMAGE  	:= M->A1_COMAGE
			_SA1->A1_CONDPAG 	:= M->A1_CONDPAG
			_SA1->A1_CXPOSTA 	:= M->A1_CXPOSTA
			_SA1->A1_DEST_1  	:= M->A1_DEST_1
			_SA1->A1_DEST_2  	:= M->A1_DEST_2
			_SA1->A1_DEST_3  	:= M->A1_DEST_3
			_SA1->A1_DIASPAG 	:= M->A1_DIASPAG
			_SA1->A1_ESTADO  	:= M->A1_ESTADO
			_SA1->A1_FORMVIS 	:= M->A1_FORMVIS
			_SA1->A1_OBS     	:= M->A1_OBS
			_SA1->A1_RECCOFI 	:= M->A1_RECCOFI
			_SA1->A1_RECCSLL 	:= M->A1_RECCSLL
			_SA1->A1_RECPIS  	:= M->A1_RECPIS
			_SA1->A1_TIPCLI  	:= M->A1_TIPCLI
			_SA1->A1_TMPVIS  	:= M->A1_TMPVIS
			_SA1->A1_YRECR   	:= M->A1_YRECR
			_SA1->A1_YGERFAT 	:= M->A1_YGERFAT
			_SA1->A1_DDI     	:= M->A1_DDI
			_SA1->A1_DDD     	:= M->A1_DDD
			_SA1->A1_PFISICA 	:= M->A1_PFISICA
			_SA1->A1_MOEDALC 	:= M->A1_MOEDALC
			_SA1->A1_RECISS  	:= M->A1_RECISS
			_SA1->A1_TIPPER  	:= M->A1_TIPPER
			_SA1->A1_COD_MUN 	:= M->A1_COD_MUN
			_SA1->A1_B2B     	:= M->A1_B2B
			_SA1->A1_GRPVEN  	:= M->A1_GRPVEN
			_SA1->A1_CODMOB  	:= M->A1_CODMOB
			_SA1->A1_CLICNV  	:= M->A1_CLICNV
			_SA1->A1_SITUA   	:= M->A1_SITUA
			_SA1->A1_ABATIMP 	:= M->A1_ABATIMP
			_SA1->A1_YCADEXP 	:= M->A1_YCADEXP
			_SA1->A1_YCADRL  	:= M->A1_YCADRL
			_SA1->A1_YULTALT 	:= M->A1_YULTALT
			_SA1->A1_YREGESP 	:= M->A1_YREGESP
			_SA1->A1_YEMAIL  	:= M->A1_YEMAIL
			_SA1->A1_YDTVENC 	:= M->A1_YDTVENC
			_SA1->A1_YTIPOLC 	:= M->A1_YTIPOLC
			_SA1->A1_YATUCLI 	:= M->A1_YATUCLI
			_SA1->A1_FOMEZER 	:= M->A1_FOMEZER
			_SA1->A1_YMAILNF 	:= M->A1_YMAILNF
			_SA1->A1_YDTPRO  	:= M->A1_YDTPRO
			_SA1->A1_YTFGNRE 	:= M->A1_YTFGNRE
			_SA1->A1_MSBLQL		:= M->A1_MSBLQL
			_SA1->A1_YAVALCL	:= M->A1_YAVALCL
			_SA1->A1_YPALETE	:= M->A1_YPALETE
			_SA1->A1_CONTRIB	:= M->A1_CONTRIB //O.S 4595-15
			_SA1->A1_IENCONT	:= M->A1_IENCONT //O.S 4595-15
			_SA1->A1_YBIZAGI	:= M->A1_YBIZAGI //O.S 4631-15
			_SA1->A1_YNLOJA		:= M->A1_YNLOJA //Fernando - projeto promotores
			_SA1->A1_TPJ		:= M->A1_TPJ 	// TICKET 1765
			_SA1->A1_MSEXP		:= ""			// Ticket 5373
			_SA1->A1_YSITGRP    := M->A1_YSITGRP //Ticket 7369
			_SA1->A1_YREDCOM	:= M->A1_YREDCOM
			_SA1->A1_YTPSEG		:= M->A1_YTPSEG 	//Ticket 9042
			_SA1->A1_YCAT		:= M->A1_YCAT		//Ticket 9042
			_SA1->A1_YTRTESP	:= M->A1_YTRTESP	//Ticket 9042
			_SA1->A1_YOBSROM	:= M->A1_YOBSROM	//Ticket 9335
			_SA1->A1_YLOTRES	:= M->A1_YLOTRES 	//Ticket 9335
			_SA1->A1_YCDGREG	:= M->A1_YCDGREG
			_SA1->A1_YSUMCE		:= M->A1_YSUMCE
			_SA1->A1_YCTAADI	:= M->A1_YCTAADI	//Conta Adiantamento RA

			_SA1->A1_YFORMA 	:= U_valYFORMA(__EMPRESA, M->A1_YCDGREG)

			_SA1->(MsUnlock())
			dbcommitAll()
			dbSelectArea("_SA1")
			dbCloseArea()

		EndIf
	Next

Return


/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ImpCliECO³ Autor ³Ranisss A. Corona        ³ Data ³ 26/08/11 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Replica o Cadastro de Cliente para o Sistema Ecosis          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCliECO()

	Local aEmp		:= {"01","05","13","14"}
	Local x			:= 0
	Local nTable	:= ""
	Local cSql 		:= ""
	Local nDB		:= AllTrim(U_DBNAME()) //Retorna a Database utilizada no ambiente.

	//Replica para as empresas que utilizam o Ecosis
	For x := 1 to Len(aEmp)

		//Define a tabela por Empresa
		If aEmp[x] == "01"
			nTable	:= ""
		Else
			nTable	:= "_"+aEmp[x]+"_"
		EndIf

		cSql := "INSERT INTO DADOS"+nTable+"EOS..EMP_EMPRESA (cod_empresa, emp_razao_social, emp_endereco, emp_endereco_num, emp_cidade, emp_uf, emp_bairro, emp_cep) "
		cSql += "SELECT A1_COD+A1_LOJA AS CODIGO_EMP, SUBSTRING(A1_NOME,1,60) AS RAZAO_SOCIAL, SUBSTRING(A1_END,1,60) AS ENDERECO, SUBSTRING(A1_COMPLEM,1,15) AS COMPLEMENTO, "
		cSql += "       SUBSTRING(A1_MUN,1,60) AS CIDADE, A1_EST AS ESTADO, SUBSTRING(A1_BAIRRO,1,60) AS BAIRRO, A1_CEP AS CEP "
		cSql += "FROM "+nDB+"..SA1"+aEmp[x]+"0 WITH (NOLOCK) "
		cSql += "LEFT JOIN DADOS"+nTable+"EOS..EMP_EMPRESA WITH (NOLOCK) ON A1_COD+A1_LOJA COLLATE Latin1_General_BIN = cod_empresa "
		cSql += "WHERE A1_FILIAL = '  ' AND A1_MSBLQL <> '1' AND D_E_L_E_T_ = ''  AND cod_empresa is null"
		TcSqlExec(cSql)

	Next

Return

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³fGrpVen ³ Autor ³Ranisss A. Corona        ³ Data ³ 17/02/17 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Atualiza informação do Credito no Grupo de Clientes          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGrpVen(cRisco,nLC,dVencLC,cGrpVen)

	Local aEmp		:= {"01","05","07","12","13","14","16","17"}
	Local x			:= 0

	For x := 1 to Len(aEmp)
		cSql := ("UPDATE SA1"+aEmp[x]+"0 SET A1_RISCO = '"+cRisco+"', A1_LC = '"+Alltrim(Str(nLC))+"', A1_VENCLC = '"+Dtos(dVencLC)+"', A1_MSEXP = '', A1_YCDGREG = '"+cCdRgFin+"' WHERE A1_GRPVEN = '"+cGrpVen+"' AND A1_YTIPOLC = 'G' AND D_E_L_E_T_ = ''")
		TcSqlExec(cSql)
	Next

Return



/*INICIANDO NOVO PADRÃO*/
User Function valYFORMA(__EMPRESA, __GRUPO)
	Local iYForma	:= ""
	Local Enter 	:= CHR(13)+CHR(10)
	Local cSQL 		:= ""
	Local cQryTMP	:= GetNextAlias()

	cSQL += "SELECT ZK1.ZK1_TPCOM" + Enter
	cSQL += "FROM ZK0010 ZK0 WITH(NOLOCK)" + Enter
	cSQL += "	INNER JOIN ZK1010 ZK1 WITH(NOLOCK)" + Enter
	cSQL += "		ON ZK0.ZK0_FILIAL = ZK1.ZK1_FILIAL" + Enter
	cSQL += "			AND ZK0.ZK0_CODREG = ZK1.ZK1_CODREG" + Enter
	cSQL += "			AND ZK1.ZK1_CODEMP = '" + Substr(__EMPRESA,1,2) + "'" + Enter
	cSQL += "			AND ZK1.D_E_L_E_T_ = ''" + Enter
	cSQL += "WHERE ZK0.ZK0_FILIAL = '" + xFilial("ZK0") + "'" + Enter
	cSQL += "	AND ZK0.ZK0_CODGRU = '" + __GRUPO + "'" + Enter
	cSQL += "	AND ZK0.D_E_L_E_T_ = ''" + Enter
	TcQuery cSQL New Alias (cQryTMP)

	If (cQryTMP)->(Eof()) .Or. (cQryTMP)->ZK1_TPCOM == "0"
		iYForma := "3"
	Else
		iYForma := "1"
	EndIf

	(cQryTMP)->(DbCloseArea())

Return iYForma
