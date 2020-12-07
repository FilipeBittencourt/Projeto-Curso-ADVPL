#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0031; Return()

/*
|-----------------------------------------------------------|
| Classe: | TEntregaEPI																			|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 28/03/16																			  |
|-----------------------------------------------------------|
| Desc.:	|	Classe para geração automatica de entrega de 		|
| 				|	EPI ao efetuar baixa da pré-requisição  				|
|-----------------------------------------------------------|
| OS:			|	1130-16 - Carlos Junqueira											|
|-----------------------------------------------------------|
*/

// IDENTIFICADORES DE LINHA
#DEFINE LIN1 "LIN1"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN 100

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// IDENTIFICADORES DE JANELA
#DEFINE WND "WND"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Equipamento de Proteção Individual (EPI)"
#DEFINE TIT_WND_EPI "Dados do EPI: "


Class TEntregaEPI From LongClassName
	
	Data oLst // Lista com os dados do funcionario e EPI
	Data nIndex // Indice da lista
	Data lVldIte // Identifica se o item da lista é valido
	
	Data oFntBold // Fonte
	Data oDlg // Janela principal
	Data cNumCA // Numero da CA
	Data cMotEnt // Motivo da Entrega da EPI
	Data aMotEnt // Array com o Motivo da EPI
	
	Data oColetor // Objeto da janela do coletor de dados
	
	Data oMovIntEPI // Movimentação Interna de EPI
	
	Method New() Constructor
	Method CreateWin() // Cria janela dinamicamente
	Method Add(cMatFun, cCodEPI, nQtdEnt, cNumLoc) // Adiciona item a lista
	Method Exist() // Verifica se existe item na lista
	Method ExistPrdEPI(cCodFun, cCodEPI) // Verifica se o código do Produto/EPI está amarrado à função do requisitante (Matrícula) na tabela TNB.
	Method fConfirm() // Confima operacao
	Method fCancel() // Cancela operacao
	Method VldNumCA() // Valida Numero da CA
	Method Validate() // Valida todas as operacoes
	Method Save() // Salva informaoes do EPI
	Method Update(nIndex) // Atualiza informaoes do EPI devolvido
	Method Insert(nIndex) // Insere informaoes do EPI
	Method Delete(cNumSeq) // Deleta registro na tabela TNF

EndClass


Method New(oColetor) Class TEntregaEPI
Default oColetor := Nil	
	
	::oLst := ArrayList():New()
	::nIndex := 1
	
	::oFntBold := TFont():New('Arial',,14,,.T.)	
	::lVldIte := .T.
		
	::cNumCA := Space(12)
	::cMotEnt := Space(14)
	::aMotEnt := {}
	
	aAdd(::aMotEnt, "1-Admissional")
	aAdd(::aMotEnt, "2-Desgaste")
	aAdd(::aMotEnt, "3-Defeito")
	aAdd(::aMotEnt, "4-Perda")
	aAdd(::aMotEnt, "5-Roubo")
	aAdd(::aMotEnt, "6-Demissional")
	aAdd(::aMotEnt, "7-Higienização")
	aAdd(::aMotEnt, "8-Outros")
	
	::oColetor := oColetor
	
	::oMovIntEPI := TMovimentoInternoEPI():New()
		
Return()


Method CreateWin() Class TEntregaEPI
Local nHeight := 140
Local nWidth := 315
	
	If !Empty(::oColetor)

		nHeight := 240
		nWidth := 280
	
	Else

		nHeight := 140
		nWidth := 315
				
	EndIf
	
	// Cria Dialog padrão
	::oDlg := MsDialog():New(0, 0, nHeight, nWidth, TIT_MAIN_WND,,,,DS_MODALFRAME,,,,,.T.)
	::oDlg:cName := "oDlg"
	::oDlg:lCentered := .T.
	::oDlg:lEscClose := .F.
	::oDlg:bValid := {|| .F. }

	
	// Barra de botoes
	oBtnBar := FWButtonBar():New()
	oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
	oBtnBar:AddBtnText("OK", "OK", {|| ::fConfirm() },,,CONTROL_ALIGN_LEFT,.T.)	
	oBtnBar:AddBtnText("Cancelar", "Cancelar", {|| ::fCancel() },,,CONTROL_ALIGN_LEFT,.T.)
	

	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(::oDlg, .F., .T.)
	
	// Adiciona linha ao Layer
	oLayer:AddLine(LIN1, 100, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN1)
	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND, TIT_WND_EPI, 100, .F. ,.T.,, LIN1, { || })
	
	oLayer:SetWinTitle(COL, WND, TIT_WND_EPI + ::oLst:GetItem(::nIndex):cCodEPI , LIN1)
	
	// Retorna paimel da janela do Layer
	oPnlLin1 := oLayer:GetWinPanel(COL, WND, LIN1)
			

	// Numero do Documento
	oSayNumCA := TSay():Create(oPnlLin1)
	oSayNumCA:cName := "oSayNumCA"
	oSayNumCA:cCaption := "Número CA"
	oSayNumCA:nLeft := 06
	oSayNumCA:nTop := 06
	oSayNumCA:nWidth := 85
	oSayNumCA:nHeight := 30
	oSayNumCA:lReadOnly := .T.
	oSayNumCA:nClrText := CLR_HBLUE
	oSayNumCA:oFont := ::oFntBold
	oSayNumCA:cToolTip := "Número do Certificado de Aprovação (CA)"
	
	oGetNumCA := TGet():Create(oPnlLin1)
	oGetNumCA:cName := "oGetNumCA"
	oGetNumCA:nLeft := 06
	oGetNumCA:nTop := 22
	oGetNumCA:nWidth := 85
	oGetNumCA:nHeight := 20
	oGetNumCA:cVariable := "::cNumCA"
	oGetNumCA:bSetGet := bSetGet(::cNumCA)
	oGetNumCA:Picture := PesqPict("TNF", "TNF_NUMCAP")
	oGetNumCA:cToolTip := "Número do Certificado de Aprovação (CA)"
	//oGetNumCA:Disable()
	//oGetNumCA:bValid := {|| fVldNumCA(cNumCA) }
	

	// Motivo da Entrega
	oSayMotEnt := TSay():Create(oPnlLin1)
	oSayMotEnt:cName := "oSayMotEnt"
	oSayMotEnt:cCaption := "Motivo Entrega"
	oSayMotEnt:nLeft := 105
	oSayMotEnt:nTop := 06
	oSayMotEnt:nWidth := 85
	oSayMotEnt:nHeight := 20
	oSayMotEnt:nClrText := CLR_HBLUE
	oSayMotEnt:oFont := ::oFntBold
	oSayMotEnt:cToolTip := "Motivo da Entrega"	
			
	oCbMotEnt := TComboBox():Create(oPnlLin1)
	oCbMotEnt:cName := "oCbMotEnt"
	oCbMotEnt:nLeft := 105
	oCbMotEnt:nTop := 22
	oCbMotEnt:nWidth := 100
	oCbMotEnt:nHeight := 20
	oCbMotEnt:bSetGet := bSetGet(::cMotEnt)
	oCbMotEnt:aItems := ::aMotEnt
	oCbMotEnt:nAt := 2
	oCbMotEnt:cToolTip := "Motivo da Entrega"
			
	::oDlg:Activate()
	
Return()


Method Add(cMatFun, cCodEPI, nQtdEnt, cNumLoc) Class TEntregaEPI
Local oIT := TIEntregaEPI():New()
		 	
	oIT:cMatFun := cMatFun
	oIT:cCodFun := Posicione("SRA", 1, xFilial("SRA") + SubStr(cMatFun, 3, 6), "RA_CODFUNC")
	oIT:cCodEPI := cCodEPI
	oIT:nQtdEnt := nQtdEnt
	oIT:cNumLoc := cNumLoc

	// Busca dados do CA por Fornecedor
	DbSelectArea("TN3")
	DbSetOrder(2)
	If TN3->(DbSeek(xFilial("TN3") + cCodEPI))
	
		While !TN3->(Eof()) .And. TN3->TN3_CODEPI == cCodEPI .And. Empty(oIT:cNumCA)
		
			// Avalia data de vencimento do numero do CA
			If TN3->TN3_DTVENC >= dDataBase
				
				oIT:cNumCA := TN3->TN3_NUMCAP
				oIT:cCodFor := TN3->TN3_FORNEC
				oIT:cLojFor := TN3->TN3_LOJA
				
			EndIf
			
			TN3->(DbSkip())
						
		EndDo
	
	EndIf
	
	// Somente adiciona a lista se existir numero de CA e amarração de Produto/EPI à função do requisitante (Matrícula) na tabela TNB.
	If !Empty(oIT:cNumCA) .And. ::ExistPrdEPI(oIT:cCodFun, oIT:cCodEPI)
	
		::oLst:Add(oIT)
		
	EndIf

Return()


Method Exist() Class TEntregaEPI
Local lRet := .T.
	
	lRet := ::oLst:GetCount() > 0
	
Return(lRet)


Method fConfirm() Class TEntregaEPI
	
	If ::lVldIte := ::VldNumCA()
		
		::oLst:GetItem(::nIndex):cNumCA := ::cNumCA
		::oLst:GetItem(::nIndex):cMotEnt := ::cMotEnt

		::oDlg:bValid := {|| .T. }
		::oDlg:End()

	EndIf

Return()


Method fCancel() Class TEntregaEPI

	::lVldIte := .F.
	
	::oDlg:bValid := {|| .T. }
	::oDlg:End()

Return()


Method VldNumCA() Class TEntregaEPI
Local aArea := GetArea()
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()
Local cTN3 := RetSQLName("TN3")

	// Validado se o numero da CA está amarrada a alguma EPI X Fornecedor e se esta dentro da validade
	cSQL := " SELECT TN3_FORNEC, TN3_LOJA "
	cSQL += " FROM "+ cTN3
	cSQL += " WHERE TN3_CODEPI = "+ ValToSQL(::oLst:GetItem(::nIndex):cCodEPI)
	cSQL += " AND TN3_NUMCAP = "+ ValToSQL(::cNumCA)
	cSQL += " AND TN3_DTVENC >= "+ ValToSQL(dDataBase)
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	If !Empty((cQry)->TN3_FORNEC)
		
		::oLst:GetItem(::nIndex):cCodFor := (cQry)->TN3_FORNEC
		::oLst:GetItem(::nIndex):cLojFor := (cQry)->TN3_LOJA
		
	Else

		lRet := .F.
		
		If Empty(::oColetor)
			MsgInfo("Atenção, o número da CA não está amarrado ao cadastro de EPI x Fornecedor.")
		Else
			::oColetor:DlgMensagem("O número da CA não está amarrado ao cadastro de EPI x Fornecedor.", "VALIDACAO DE CA", "ALERT")
		EndIf
		
	EndIf
		
	(cQry)->(DbCloseArea())
								
	RestArea(aArea)		

Return(lRet)


Method ExistPrdEPI(cCodFun, cCodEPI) Class TEntregaEPI
Local lRet := .T.
	
	DbSelectArea("TNB")
	DbSetOrder(1)
	lRet := TNB->(DbSeek(xFilial("TNB") + PadR(cCodFun, TamSX3("TNB_CODFUN")[01]) + cCodEPI))
	
Return(lRet)


Method Validate() Class TEntregaEPI
Local lRet := .T.

	If ::Exist()

		::nIndex := 1
		
		While ::nIndex <= ::oLst:GetCount() .And. ::lVldIte
	
			::cNumCA := ::oLst:GetItem(::nIndex):cNumCA
			::cMotEnt := ""
				
			::CreateWin()
			
			::nIndex++
			
		EndDo
				
		lRet := (::nIndex - 1) == ::oLst:GetCount() .And. ::lVldIte
  
	EndIf
	
Return(lRet)


Method Save(cNumDoc) Class TEntregaEPI
Local nCount := 0

	If ::Exist()
	
		// Adiciona Lista de Movimentações Internas
		::oMovIntEPI:Add(cNumDoc)
	
		For nCount := 1 To ::oLst:GetCount()
			
			// Somente atualiza a devolucao da EPI para motivos de entrega diferentes de 'Admissao'
			If SubStr(::oLst:GetItem(nCount):cMotEnt, 1, 1) <> "1"
				
				::Update(nCount)
				
			EndIf
			
			::Insert(nCount)
			
		Next
	
	EndIf
	
Return()


Method Update(nIndex) Class TEntregaEPI
Local aArea := GetArea()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cTNF := RetSQLName("TNF")
						
	cSQL := " SELECT TNF_QTDENT, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + cTNF
	cSQL += " WHERE TNF_FILIAL = "+ ValToSQL(xFilial("TNF"))
	cSQL += " AND TNF_MAT = "+ ValToSQL(SubStr(::oLst:GetItem(nIndex):cMatFun, 3, 6))
	cSQL += " AND TNF_CODEPI = "+ ValToSQL(::oLst:GetItem(nIndex):cCodEPI)
	cSQL += " AND TNF_INDDEV <> '1' "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY TNF_DTENTR "
	
	TcQuery cSQL New Alias (cQry)			
	
	If (cQry)->RECNO > 0
	
		DbSelectArea("TNF")
		TNF->(DbGoTo((cQry)->RECNO))
			
		RecLock('TNF', .F.)
				
			TNF->TNF_QTDEVO := TNF->TNF_QTDENT
			TNF->TNF_DTDEVO := dDataBase
			TNF->TNF_LOCDV := ::oLst:GetItem(nIndex):cNumLoc
			TNF->TNF_INDDEV := "1"
		
		TNF->(MsUnlock())
					
	EndIf	
	
	(cQry)->(DbCloseArea())
								
	RestArea(aArea)

Return()


Method Insert(nIndex) Class TEntregaEPI
Local nCusMed := 0
Local cNumSeq := ""

	RecLock("TNF", .T.)
		
		TNF->TNF_FILIAL := xFilial("TNF")
		TNF->TNF_CODEPI := ::oLst:GetItem(nIndex):cCodEPI
		TNF->TNF_FORNEC := ::oLst:GetItem(nIndex):cCodFor
		TNF->TNF_LOJA := ::oLst:GetItem(nIndex):cLojFor
		TNF->TNF_NUMCAP := ::oLst:GetItem(nIndex):cNumCA
		TNF->TNF_MAT := SubStr(::oLst:GetItem(nIndex):cMatFun, 3, 6)
		TNF->TNF_CODFUN := ::oLst:GetItem(nIndex):cCodFun
		TNF->TNF_DTENTR := dDataBase
		TNF->TNF_HRENTR := Time()
		TNF->TNF_QTDENT := ::oLst:GetItem(nIndex):nQtdEnt
		TNF->TNF_MOTIVO := ::oLst:GetItem(nIndex):cMotEnt
		TNF->TNF_LOCAL := ::oLst:GetItem(nIndex):cNumLoc
		TNF->TNF_EPIEFI := "1"
		TNF->TNF_INDDEV := "2"
		TNF->TNF_DTRECI := dDataBase
		
		// Retorna Custo Medio e Numero Sequencial da Movimentação Interna
		::oMovIntEPI:Get(::oLst:GetItem(nIndex):cCodEPI, ::oLst:GetItem(nIndex):nQtdEnt, @nCusMed, @cNumSeq)
		
		TNF->TNF_CUSTO := nCusMed
		TNF->TNF_NUMSEQ := cNumSeq
			
	TNF->(MsUnlock())
	
Return()


Method Delete(cNumSeq) Class TEntregaEPI
Local aArea := GetArea()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cTNF := RetSQLName("TNF")
						
	cSQL := " SELECT R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + cTNF
	cSQL += " WHERE TNF_FILIAL = "+ ValToSQL(xFilial("TNF"))
	cSQL += " AND TNF_NUMSEQ = "+ ValToSQL(cNumSeq)
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	If (cQry)->RECNO > 0
	
		DbSelectArea("TNF")
		TNF->(DbGoTo((cQry)->RECNO))
			
		RecLock('TNF', .F.)
			TNF->(DbDelete())
		TNF->(MsUnlock())
					
	EndIf	
	
	(cQry)->(DbCloseArea())
								
	RestArea(aArea)

Return()