#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BFATTE01
@description Tela de Propostas de Engenharia
@author Fernando Rocha
@since 18/10/2016
@version 1.0
@param lObraAc, logical, [se esta executando filtrado pelo cadastro de Obra]
@type function
/*/

User Function BFATTE01(lObraAc)
	//teste
	Local aIndDAK	 	:= {}
	Local cCondicao	 	:= ""
	Local cQryAux

	Default lObraAc 	:= .F.

	Private cCadastro	:= " Proposta de Engenharia "
	Private cNumZZO		:= ""

	Private aRotina   := {}
	aAdd(aRotina ,{"Pesquisar"    	,'PesqBrw'				,0, 1})
	aAdd(aRotina ,{"Visualizar"   	,'U_BFTE01MA("V")'    	,0, 2})

	If (lObraAc)
		aAdd(aRotina ,{"Incluir"	,'U_BFTE01MA("I")'    	,0, 3})
	EndIf

	aAdd(aRotina ,{"Revisão"   		,'U_BFTE01MA("A")'    	,0, 4})
	aAdd(aRotina ,{"Aprovação"		,'U_BFTE01MA("P")'    	,0, 4})
	aAdd(aRotina ,{"Definir Cliente" ,'U_BFTE01CL()'    	,0, 4})
	aAdd(aRotina ,{"Alterar Status"  ,'U_BFTE01MA("T")'    	,0, 4})

	If (!lObraAc)
		aAdd(aRotina ,{"WF Aprovacao"	,'U_BFATWF01()'    	,0, 4})
	EndIf

	aAdd(aRotina ,{"Excluir"      	,'U_BFTE01MA("E")'    	,0, 5})
	aAdd(aRotina ,{"Imprimir"     	,'U_BFATRE01'    		,0, 2})
	aAdd(aRotina ,{"Legenda"      	,'U_BFTE01LE'    	  	,0, 4})

	//Legenda
	Private aCores    := {	{  'Z68_STATUS=="0"'	, 'BR_BRANCO' 	},;
	{  'Z68_STATUS=="1"'	, 'BR_AMARELO' 	},;
	{  'Z68_STATUS=="2"'	, 'BR_VERDE' 	},;
	{  'Z68_STATUS=="3"'	, 'BR_VERMELHO'	},;
	{  'Z68_STATUS=="4"'	, 'BR_AZUL'		},;
	{  'Z68_STATUS=="5"'	, 'BR_PRETO'	} }

	//Filtro pelo cadastro de Obras
	If (lObraAc)

		cNumZZO := ZZO->ZZO_NUM
		cCondicao := "Z68_FILIAL == '"+XFilial("Z68")+"' .And. Z68_NUMZZO == '"+cNumZZO+"'"

		bFiltraBrw := {|| FilBrowse("Z68",@aIndDAK,@cCondicao) }
		Z68->( Eval( bFiltraBrw ) )

	EndIf

	dbSelectArea("Z68")
	dbGoTop()
	mBrowse(6,1,22,75, "Z68",,,,,,aCores)

	EndFilBrw("Z68",aIndDAK)

Return

User Function BFTE01LE()
	Local aLegenda := {	{ 'BR_BRANCO'	,	"Nova Prosposta" 		},;
	{ 'BR_AMARELO'	,   "Revisada"  			},;
	{ 'BR_VERDE'	,   "Aprovada"			  	},;
	{ 'BR_AZUL'		,   "Pedido Gerado"		  	},;
	{ 'BR_VERMELHO'	,   "Rejeitada"			  	},;
	{ 'BR_PRETO'	,   "Vencida"			  	} }

	BRWLEGENDA( cCadastro, "Legenda", aLegenda )
Return

User Function BFTE01MA(_cOpca)

	Local _cAliasTmp
	Local i

	SetPrvt("WOPCAO,LVISUALIZAR,LINCLUIR,LALTERAR,LEXCLUIR,NOPCE")
	SetPrvt("NOPCG,COPCAO,NUSADO,AHEADER,ACOLS,I,LCANDEL")
	SetPrvt("WFILIAL,CTITULO,CALIASENCHOICE,CALIASGETD")
	SetPrvt("CLINOK,CTUDOK,CFIELDOK,ACPOENCHOICE,LRET")
	SetPrvt("oEncZ68")

	LCANDEL := .T.

	Private nprox 	:= 0
	Private _aSize 	:= MSADVSIZE()
	Private cNumZ68

	wOpcao      := _cOpca
	lVisualizar := .F.
	lIncluir    := .F.
	lExcluir    := .F.
	lAlterar	:= .F.

	Private lAprova := .F.
	Private lAltStatus := .F.
	Private nDiasVenc := GetNewPar("MV_YDVCPE", 15)  //Dias para vencimento de proposta

	Private cRevisa := ""
	Private aAltEnch
	Private oGetDados

	//variaveis para Rodape Customizado
	Private oDlg
	Private oGetTotBR
	Private nGetTotBR := 0
	Private oGetTotBA
	Private nGetTotBA := 0
	Private oGetTotFR
	Private nGetTotFR := 0

	///vetor para parcelas de contrato
	Private aParcContr	:= {}

	If (wOpcao == "P")
		lAprova := .T.
		wOpcao := "A"
	EndIf

	If (wOpcao == "T")
		lAltStatus := .T.
		wOpcao := "A"
	EndIf

	Do Case
		Case wOpcao == "V" .Or. wOpcao == "T"; lVisualizar := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "I" ; lIncluir    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "INCLUIR"
		Case wOpcao == "A" ; lAlterar    := .T. ; nOpcE := 4 ; nOpcG := 4 ; cOpcao := "ALTERAR"
		Case wOpcao == "E" ; lExcluir    := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "EXCLUIR"
	EndCase

	If lAlterar .And. !(Z68->Z68_STATUS $ "0#1#2#3#5")   //Revisao
		MsgAlert("Status não permitido para Revisão!","[BFATTE01] Propostas de Engenharia")
		Return
	EndIf

	If lExcluir .And. !(Z68->Z68_STATUS $ "0#1")   //Exclusao
		MsgAlert("Status não permitido para Exclusão!","[BFATTE01] Propostas de Engenharia")
		Return
	EndIf

	If lAlterar .And. lAprova .And. !(Z68->Z68_STATUS $ "0#1")
		MsgAlert("Status não permitido para Aprovação!","[BFATTE01] Propostas de Engenharia")
		Return
	EndIf

	If lAlterar .And. lAprova
		//Validar usuario aprovador
		If ( CUSERNAME <> Z68->Z68_USUAPR ) .And. ( !U_VALOPER("E01") )
			MsgAlert("Esta proposta deve ser aprovada por: "+Z68->Z68_USUAPR,"ATENÇÃO: USUÁRIO NÃO PERMITIDO.", "OP E01")
			Return
		EndIf
	EndIf

	RegToMemory("Z68",(cOpcao=="INCLUIR"))

	If  lIncluir

		//cNumZ68 := GetSxeNum("Z68","Z68_NUM")

		//Substituindo funcao GetSxeNum porque a numeracao no License Server se perde o tempo inteiro
		IF !Z68GetNum(@cNumZ68)
			Return
		EndIf


		M->Z68_NUM 		:= cNumZ68
		M->Z68_REV 		:= "01"
		M->Z68_EMISSA	:= dDataBase
		M->Z68_HREMIS	:= SubStr(Time(),1,5)
		M->Z68_NUMZZO	:= cNumZZO

		M->Z68_CODVEN	:= ZZO->ZZO_VEND
		M->Z68_NOMCLI 	:= ZZO->ZZO_NOMCLI
		M->Z68_END		:= ZZO->ZZO_ENDCLI
		M->Z68_COMPL	:= ZZO->ZZO_COMPLC
		M->Z68_BAIRRO	:= ZZO->ZZO_BAIRRC
		M->Z68_EST		:= ZZO->ZZO_ESTCLI
		M->Z68_CODMUN	:= ZZO->ZZO_CODMC
		M->Z68_MUN		:= ZZO->ZZO_MUNC
		M->Z68_CNPJ		:= ZZO->ZZO_CNPJ
		M->Z68_CNOME	:= ZZO->ZZO_CONT1
		M->Z68_CTEL		:= ZZO->ZZO_TELC1

	EndIf

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("Z69")
	nUsado  := 0
	aHeader := {}
	While !eof() .and. SX3->X3_ARQUIVO == "Z69"
		If  X3USO(SX3->X3_USADO) .and. SX3->X3_NIVEL <= cNivel .And. !(Alltrim(SX3->X3_CAMPO) $ "Z69_NUM#Z69_REV")

			nUsado := nUsado + 1

			aadd(aHeader,{ trim(SX3->X3_TITULO),SX3->X3_CAMPO   , ;
			SX3->X3_PICTURE     ,SX3->X3_TAMANHO , ;
			SX3->X3_DECIMAL     ,SX3->X3_VALID , ;
			SX3->X3_USADO       ,SX3->X3_TIPO    , ;
			SX3->X3_ARQUIVO     ,SX3->X3_CONTEXT } )
		End
		dbSkip()
	End

	SB1->(DbSetOrder(1))

	If  lIncluir
		aCols             := {array(nUsado+1)}
		aCols[1,nUsado+1] := .F.
		For i := 1 to nUsado

			if Alltrim(aHeader[i,2]) == "Z69_ITEM"
				aCols[1,i] := "01"
			else
				aCols[1,i] := CriaVar(aHeader[i,2])
			endif
		Next
	Else
		aCols:={}
		DbSelectArea("Z69")
		DbSetOrder(1)
		DbSeek(xFilial("Z69")+M->Z68_NUM+M->Z68_REV)
		While !eof() .and. Z69->(Z69_FILIAL+Z69_NUM+Z69_REV) == (xFilial("Z69")+M->Z68_NUM+M->Z68_REV)

			aadd(aCols,array(nUsado+1))
			For i := 1 to nUsado
				aCols[len(aCols),i]    := FieldGet(FieldPos(aHeader[i,2]))
			Next

			If SB1->(DbSeek(XFilial("SB1")+Z69->Z69_CODPRO))
				aCols[len(aCols),aScan(aHeader,{|x| AllTrim(x[2])=="Z69_DESPRO" })] := SB1->B1_DESC
				aCols[len(aCols),aScan(aHeader,{|x| AllTrim(x[2])=="Z69_UM" })] := SB1->B1_UM
			EndIf

			__CPROD := aCols[len(aCols),aScan(aHeader,{|x| AllTrim(x[2])=="Z69_CODPRO"})]
			__NQTD := aCols[len(aCols),aScan(aHeader,{|x| AllTrim(x[2])=="Z69_QTDVEN"})]

			aCols[len(aCols),aScan(aHeader,{|x| AllTrim(x[2])=="Z69_FRTEST" })] := Z69FRTGET(M->Z68_FRTUNI,__CPROD, __NQTD)

			aCols[len(aCols),nUsado+1] := .F.

			//Totais no Rodape customizado
			nGetTotBR += Z69->Z69_QTDVEN
			nGetTotBA += Z69->Z69_VALOR

			dbSkip()
		End
	End

	//Controle de Revisao - Tem que ser inclusao de uma nova linha
	//Aprovacao - tem que popular a revisao anterior e as parcelas para caso de alteracao de desconto
	If lAlterar

		cQryAux := GetNextAlias()
		BeginSql Alias cQryAux
			%NOPARSER%
			select REV = max(Z68_REV) from Z68010 where Z68_FILIAL = %XFILIAL:Z68% and Z68_NUM = %EXP:M->Z68_NUM% and D_E_L_E_T_= ''
		EndSql

		If !(cQryAux)->(Eof())
			cRevisa	 := (cQryAux)->REV

			If !lAprova
				M->Z68_REV := Soma1(cRevisa,2)  //Para aprovacao so faz na gravacao final caso tenha alterado o desconto
			EndIf
		Else
			MsgAlert("RevisÃ£o anterior não encontrada - entrar em contato com a TI!","BFATTE01")
			return
		EndIf

		//Popular parcelar de contrato da revisao anterior no array para alteracao
		ZA5->(DbSetOrder(1))
		If ZA5->(DbSeek(xFilial("ZA5") + M->Z68_NUM + cRevisa ))
			aParcContr := {}
			While !ZA5->(Eof()) .And. ZA5->(ZA5_FILIAL+ZA5_NUM+ZA5_REV) == (xFilial("ZA5") + M->Z68_NUM + cRevisa )

				aAdd(aParcContr, {0, cToD(""), .F.})

				aParcContr[Len(aParcContr)][1] := ZA5->ZA5_VALOR
				aParcContr[Len(aParcContr)][2] := ZA5->ZA5_DATA
				aParcContr[Len(aParcContr)][3] := .F.

				ZA5->(DbSkip())
			EndDo
		EndIf

		If !lAprova .And. !lAltStatus
			M->Z68_STATUS := "1"
			M->Z68_OBSAPR := ""

			lIncluir := .T.
			nOpcE := 3
			nOpcG := 3
		EndIf

	EndIf

	//Controle de Aprovacao
	If lAlterar .And. lAprova

		//definicao do comercial
		//Validade para "dentro do mês" e para as propostas feitas a partir do dia 20, validade de 15 dias.
		if ( Day(dDataBase) <= 20 )
			M->Z68_DTVALI := Lastday(dDataBase,  0)
		else
			M->Z68_DTVALI := dDataBase + nDiasVenc
		endif

		aAltEnch := {"Z68_STATUS", "Z68_OBSAPR"} //campos para alterar

	EndIf

	//Controle de Alterar Status
	If lAlterar .And. lAltStatus

		aAltEnch := {"Z68_SITOBR", "Z68_PERD", "Z68_YMOTIV"} //campos para alterar
		nOpcG := 2
		LCANDEL := .F.

	EndIf

	//Inicializa variaveis
	cTitulo        := "Proposta de Engenharia"
	cAliasEnchoice := "Z68"
	cAliasGetD     := "Z69"
	cLinOk         := "U_BFT01LOK()"
	cTudOk         := "U_BFT01TOK()"
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {}

	aButtons := {}

	//If lVisualizar .Or. lAprova	
	If U_VALOPER("003",.F.) //Apenas para Diretores e Gerentes
		aAdd(aButtons , {'',{|| U_BFTE01MC() },'Margem Operacional'} )
	EndIf
	//EndIf

	aAdd(aButtons , {'',{|| U_BF01PARC() },'Parcelas Contrato'} )

	lRet := RMod3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,aAltEnch,3,aButtons,,250)

	If  lRet .And. !lVisualizar
		fProcessa()
		ConfirmSX8()

		//Checagem de Aprovacao
		_lAutoAprov := .T.
		_cTxtAprov := ""
		_cMarca	   := ""
		_aUsrAprov := {"",""}

		cAliasApr := GetNextAlias()
		BeginSql Alias cAliasApr
			%NoParser%
			SELECT MAX(Z69_DESC) Z69_DESC, MAX(Z69_DESP) Z69_DESP FROM %TABLE:Z69% WHERE Z69_FILIAL = %XFILIAL:Z69% and Z69_NUM = %EXP:Z68->Z68_NUM% and Z69_REV = %EXP:Z68->Z68_REV% and Z69_DESP > 0 and %NotDel%
		EndSql

		(cAliasApr)->(DbGoTop())
		If !(cAliasApr)->(Eof()) .And. (cAliasApr)->Z69_DESP > 0
			_lAutoAprov := .F.
			_cTxtAprov := "Proposta com desconto fora da política."

			//Posicona primeiro item para buscar a Marca
			Z69->(DbSetOrder(1))
			If Z69->(DbSeek(XFilial("Z69")+Z68->Z68_NUM+Z68->Z68_REV))

				SB1->(DbSetOrder(1))
				SB1->(DbSeek(XFilial("SB1")+Z69->Z69_CODPRO))

				ZZ7->(DbSetOrder(1))
				If ZZ7->(DbSeek(XFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ))
					_cMarca := ZZ7->ZZ7_EMP
				EndIf
			EndIf

			_aUsrAprov := U_BFATAPRO(Z68->Z68_CODVEN, "1", "E", _cMarca, Z68->Z68_CODCLI, Z68->Z68_LOJCLI, Z68->Z68_CODVEN)
		EndIf
		(cAliasApr)->(DbCloseArea())

		//Se condicao de pagamento for Contrato - deve haver aprovacao pelo gerante - solicitcao da Camila e-mail dia 26/08
		If (Z68->Z68_COND == "142")
			_lAutoAprov := .F.
			_cTxtAprov := "Condição de pagamento 142 - Contrato."
		EndIf

		If ( _lAutoAprov )

			RecLock("Z68",.F.)
			Z68->Z68_STATUS	:= "2"
			Z68->Z68_DTAPRO	:= dDataBase
			Z68->Z68_HRAPRO	:= SubStr(Time(),1,5)
			Z68->Z68_USUAPR	:= "AUTO"
			if ( Day(dDataBase) <= 20 )
				Z68->Z68_DTVALI := Lastday(dDataBase,  0)
			else
				Z68->Z68_DTVALI := dDataBase + nDiasVenc
			endif
			Z68->(MsUnlock())

		Else

			If !lAprova

				RecLock("Z68",.F.)
				Z68->Z68_USUAPR	:= _aUsrAprov[2]
				Z68->(MsUnlock())

				MsgInfo(_cTxtAprov+CRLF+"Precisa de aprovação de "+_aUsrAprov[2]+".","APROVAÇÃO DE DESCONTO")

			EndIf

		EndIf

		//Atualizar Status da Obra
		If lIncluir

			ZZO->(DbSetOrder(1))
			If ZZO->(DbSeek(XFilial("ZZO")+M->Z68_NUMZZO))
				RecLock("ZZO",.F.)
				ZZO->ZZO_STATUS := "1"
				ZZO->(MsUnlock())
			EndIf

		EndIf

		If lAlterar .And. lAltStatus

			RecLock("Z68",.F.)
			Z68->Z68_ALTSTA	:= dDataBase
			Z68->(MsUnlock())

			If ( M->Z68_SITOBR == "3" )

				ZZO->(DbSetOrder(1))
				If ZZO->(DbSeek(XFilial("ZZO")+M->Z68_NUMZZO))
					RecLock("ZZO",.F.)
					ZZO->ZZO_STATUS := "3"
					ZZO->(MsUnlock())
				EndIf

			ElseIf ( M->Z68_SITOBR == "4" )

				ZZO->(DbSetOrder(1))
				If ZZO->(DbSeek(XFilial("ZZO")+M->Z68_NUMZZO))
					RecLock("ZZO",.F.)
					ZZO->ZZO_STATUS := "4"
					ZZO->(MsUnlock())
				EndIf

			EndIf

		EndIf

		///Workflow de aprovacao
		If ( lAlterar .And. lAprova ) .Or. ( _lAutoAprov )
			U_BFATWF01()
		EndIf

	Else
		RollBackSX8()
	End

Return

User Function BFT01TOK
	Local lRet := .T.

	If lAprova .And. !( M->Z68_STATUS $ "2#3" )
		MsgAlert("Modo Aprovação - o STATUS precisa ser Aprovado ou Rejeitado.","BFATTE01")
		lRet := .F.
	EndIf

	If lRet .And. lAprova .And. Empty(M->Z68_OBSAPR)
		MsgAlert("Modo Aprovação - a OBSERVAÇÃO da aprovação precisa ser preenchida.","BFATTE01")
		lRet := .F.
	EndIf

	If lRet .And. M->Z68_COND == "142"
		lRet := U_BF01PARC()

		If !lRet
			MsgAlert("Obrigado a Informar as Parcelas do Contrato corretamente.","Condição de pagamento 142")
		EndIf

	EndIf

Return(lRet)

User Function BFT01LOK()
	Local lRet := .T.

	AtuTotais()

Return(lRet)

Static Function AtuTotais()
	Local I

	_nTotQtd := 0
	_nTotVal := 0
	_nTotFrt := 0
	__nPQtd	:= aScan(aHeader, {|x| AllTrim(x[2]) == "Z69_QTDVEN" })
	__nPVal	:= aScan(aHeader, {|x| AllTrim(x[2]) == "Z69_VALOR" })
	__nPFrt	:= aScan(aHeader, {|x| AllTrim(x[2]) == "Z69_FRTEST" })

	FOR I := 1 To Len(ACOLS)

		If ACOLS[I][Len(AHEADER)+1]
			loop
		EndIf

		_nTotQtd += ACOLS[I][__nPQtd]
		_nTotVal += ACOLS[I][__nPVal]
		_nTotFrt += ACOLS[I][__nPFrt]

	NEXT I

	nGetTotBR := _nTotQtd
	oGetTotBR:Refresh()
	nGetTotBA := _nTotVal
	oGetTotBA:Refresh()
	nGetTotFR := _nTotFrt
	oGetTotFR:Refresh()
	oDlg:Refresh()

Return

Static Function fProcessa()
	Local I,J
	Local lAltApr := .F.
	Local cNumZ68

	If lExcluir

		BEGIN TRANSACTION

			Z69->(DbSetOrder(1))
			If Z69->(DbSeek(XFilial("Z69")+M->Z68_NUM+M->Z68_REV))

				While !Z69->(Eof()) .And. Z69->(Z69_FILIAL+Z69_NUM+Z69_REV) == (xFilial("Z69")+M->Z68_NUM+M->Z68_REV)

					RecLock("Z69",.F.)
					Z69->(DbDelete())
					Z69->(MsUnlock())

					Z69->(DbSkip())
				EndDo

			EndIf

			Z68->(DbSetOrder(1))
			If Z68->(DbSeek(XFilial("Z68")+M->Z68_NUM+M->Z68_REV))

				RecLock("Z68",.F.)
				Z68->(DbDelete())
				Z68->(MsUnlock())

			EndIf

		END TRANSACTION

		Return
	EndIf

	//Checkar se no modo Aprovacao houve alteracao de desconto
	If lAprova
		__nLin := 0
		__cChvRevAtu := XFilial("Z69")+M->Z68_NUM+M->Z68_REV
		Z69->(DbSetOrder(1))
		If Z69->(DbSeek(__cChvRevAtu))

			While !Z69->(Eof()) .And. Z69->(Z69_FILIAL+Z69_NUM+Z69_REV) == (__cChvRevAtu)

				__nLin++

				If ACOLS[__nLin][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DESP"})] <> Z69->Z69_DESP
					lIncluir := .T.
					lAltApr	 := .T.
					M->Z68_REV := Soma1(cRevisa,2)
					M->Z68_OBSAPR := M->Z68_OBSAPR + CRLF + "Desconto do item "+AllTrim(Str(__nLin))+" alterado pelo Aprovador - de "+Transform(Z69->Z69_DESP,"@E 999.99")+"% para "+Transform(ACOLS[__nLin][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DESP"})],"@E 999.99")+"%"
				EndIf

				Z69->(DbSkip())
			EndDo

		EndIf
	EndIf

	//Gravacao dos dados
	BEGIN TRANSACTION

		//Procurar revisao anterior e marcar como Rejeitada
		If lIncluir .And. !Empty(cRevisa)

			Z68->(DbSetOrder(1))
			If Z68->(DbSeek(XFilial("Z68")+M->Z68_NUM+cRevisa))

				RecLock("Z68",.F.)
				Z68->Z68_STATUS := "3"
				Z68->Z68_DTAPRO	:= CTOD(" ")
				Z68->Z68_HRAPRO	:= Space(5)

				If lAprova
					Z68->Z68_USUAPR	:= "APR.ALT.DESC"
				Else
					Z68->Z68_USUAPR	:= "REVISADA"
				EndIf

				Z68->Z68_DTVALI := CTOD(" ")
				Z68->(MsUnlock())

			EndIf

		EndIf

		If lIncluir .And. Empty(cRevisa)

			//Confimando a ultima numeracao na transaction do Salvar 
			IF !Z68GetNum(@cNumZ68)
				DisarmTransaction()
				Return
			ELSE
				M->Z68_NUM := cNumZ68
			ENDIF

		Else

			cNumZ68 := M->Z68_NUM

		EndIf

		//Inclusao ou Alteracao
		If lIncluir
			RecLock("Z68",.T.)
			Z68->Z68_FILIAL	:= XFilial("Z68")
			Z68->Z68_NUM	:= cNumZ68
			Z68->Z68_REV	:= M->Z68_REV
		Else
			RecLock("Z68",.F.)
		EndIf

		Z68->Z68_STATUS  := M->Z68_STATUS

		//Nova Revisao - atualizar a data hora
		If lIncluir .And. !Empty(cRevisa)
			Z68->Z68_EMISSA  := dDataBase
			Z68->Z68_HREMIS  := SubStr(Time(),1,5)
		Else
			Z68->Z68_EMISSA  := M->Z68_EMISSA
			Z68->Z68_HREMIS  := M->Z68_HREMIS
		EndIf

		Z68->Z68_USUINC  	:= CUSERNAME
		Z68->Z68_EMPFAT		:= M->Z68_EMPFAT
		Z68->Z68_CODVEN  	:= M->Z68_CODVEN
		Z68->Z68_CLICAD  	:= M->Z68_CLICAD
		Z68->Z68_CODCLI  	:= M->Z68_CODCLI
		Z68->Z68_LOJCLI		:= M->Z68_LOJCLI
		Z68->Z68_ALIQ	 	:= M->Z68_ALIQ
		Z68->Z68_NOMCLI  	:= M->Z68_NOMCLI
		Z68->Z68_STATUS  	:= M->Z68_STATUS
		Z68->Z68_COND    	:= M->Z68_COND
		Z68->Z68_OBS     	:= M->Z68_OBS
		Z68->Z68_OBSIMP  	:= M->Z68_OBSIMP
		Z68->Z68_OBSAPR  	:= M->Z68_OBSAPR
		Z68->Z68_END     	:= M->Z68_END
		Z68->Z68_LINHA   	:= M->Z68_LINHA
		Z68->Z68_COMPL  	:= M->Z68_COMPL
		Z68->Z68_BAIRRO  	:= M->Z68_BAIRRO
		Z68->Z68_EST     	:= M->Z68_EST
		Z68->Z68_CODMUN  	:= M->Z68_CODMUN
		Z68->Z68_MUN     	:= M->Z68_MUN
		Z68->Z68_CNPJ    	:= M->Z68_CNPJ
		Z68->Z68_CNOME   	:= M->Z68_CNOME
		Z68->Z68_CTEL    	:= M->Z68_CTEL
		Z68->Z68_CEMAIL  	:= M->Z68_CEMAIL
		Z68->Z68_CEP     	:= M->Z68_CEP
		Z68->Z68_INSCR   	:= M->Z68_INSCR
		Z68->Z68_NUMZZO  	:= M->Z68_NUMZZO
		Z68->Z68_APTOMO  	:= M->Z68_APTOMO
		Z68->Z68_APVLPR  	:= M->Z68_APVLPR
		Z68->Z68_SITOBR		:= M->Z68_SITOBR
		Z68->Z68_PERD		:= M->Z68_PERD
		Z68->Z68_YMOTIV		:= M->Z68_YMOTIV
		Z68->Z68_FRTUNI		:= M->Z68_FRTUNI
		
		If Z68->(FieldPos("Z68_TPNEG")) > 0
			Z68->Z68_TPNEG	:= M->Z68_TPNEG
    	EndIf
  
		
		

		//Aprovacao - gravar data/hora
		If lAlterar .And. lAprova

			Z68->Z68_DTAPRO		:= dDataBase
			Z68->Z68_HRAPRO		:= SubStr(Time(),1,5)
			Z68->Z68_USUAPR		:= CUSERNAME
			Z68->Z68_DTVALI		:= M->Z68_DTVALI

			If ( lAltApr )
				Z68->Z68_TIPAPR := "2" //aprovado com alteracao de desconto
			Else
				Z68->Z68_TIPAPR := "1" //aprovado normal
			EndIf

		EndIf

		Z68->(MsUnlock())

		FOR I := 1 To Len(ACOLS)

			If ACOLS[I][Len(AHEADER)+1]
				loop
			EndIf

			__cItem := ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_ITEM"})]

			Z69->(DbSetOrder(1))
			If Z69->(DbSeek(M->(Z68_FILIAL+Z68_NUM+Z68_REV+__cItem)))
				RecLock("Z69",.F.)
			Else
				RecLock("Z69",.T.)
				Z69->Z69_FILIAL	:= XFilial("Z69")
				Z69->Z69_NUM 	:= cNumZ68
				Z69->Z69_REV 	:= M->Z68_REV
				Z69->Z69_ITEM	:= __cItem
			EndIf

			Z69->Z69_CODPRO	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_CODPRO"})]
			Z69->Z69_QTDVEN	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_QTDVEN"})]
			Z69->Z69_PRCTAB	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_PRCTAB"})]
			Z69->Z69_PRCVEN	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_PRCVEN"})]
			Z69->Z69_VALOR 	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_VALOR"})]
			Z69->Z69_DESP  	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DESP"})]
			Z69->Z69_DESC  	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DESC"})]
			Z69->Z69_DTNECE	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DTNECE"})]
			Z69->Z69_DTDISP	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DTDISP"})]
			Z69->Z69_DPAL  	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DPAL"})]
			Z69->Z69_DCAT  	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DCAT"})]
			Z69->Z69_DREG  	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DREG"})]
			Z69->Z69_DGER  	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DGER"})]
			Z69->Z69_DNV  	:= ACOLS[I][aScan(AHEADER,{|x| AllTrim(x[2]) == "Z69_DNV"})]

			Z69->(MsUnlock())

		NEXT I

		//Salvar parcelas de contrato
		fSalvaParc()

	END TRANSACTION

Return

Static Function RMod3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aButtons,aCordW,nSizeHeader)
	Local lRet, nOpca := 0,cSaveMenuh,nReg:=(cAlias1)->(Recno())
	Local nDlgHeight
	Local nDlgWidth
	Local nDiffWidth := 0
	Local nDiffHeight := 0
	Local lMDI := .F.
	Local lPlugin := .F.
	Local nTop := 32
	Local aSize := {}
	Local _aAltField := Nil

	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}

	private aTELA:=Array(0,0)
	private aGets:=Array(0)

	If IsPlugin()
		lPlugin := .T.
	EndIf

	nOpcE := If(nOpcE==Nil,3,nOpcE)
	nOpcG := If(nOpcG==Nil,3,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas:=Iif(nLinhas==Nil,99,nLinhas)

	If SetMDIChild()
		oMainWnd:ReadClientCoors()
		nDlgHeight := oMainWnd:nHeight
		nDlgWidth := oMainWnd:nWidth
		lMdi := .T.
		nDiffWidth := 2
		If lPlugin
			nDiffHeight := 25
		EndIf
	Else
		If lPlugin
			nDlgHeight := oMainWnd:nHeight-55
			nDlgWidth	:= oMainWnd:nWidth-12
			nDiffHeight := 80
			nTop := 10
		Else
			nDlgHeight := oMainWnd:nHeight-50
			nDlgWidth	:= oMainWnd:nWidth-27
		Endif
		nDiffWidth := 7
	EndIf

	If lAlterar .And. lAprova
		_aAltField := {"Z69_DESP"}
	EndIf

	Default aCordW := {nTop,000,nDlgHeight,nDlgWidth}
	Default nSizeHeader := 110

	Aadd(aSize,nSizeHeader)

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 45, .T. , .T. })
	AAdd(_aObjects, {100, 50, .T. , .T. })
	AAdd(_aObjects, {100, 5, .T. , .T. })                      

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE cTitulo From _aSize[7],0 To _aSize[6],_aSize[5] Pixel of oMainWnd
	If lMdi
		oDlg:lMaximized := .T.
	EndIf

	oEncZ68 := Msmget():New(cAlias1,nReg,nOpcE,,,,aMyEncho,{_aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,3], _aPosObj[1,4]},aAltEnchoice,3,,,,oDlg,,lVirtual,,,,,,,,.F.)

	_nPosRoda := (oMainWnd:nHeight/2)-nDiffHeight
	_nTamRoda := 50

	oGetDados := MsGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"+Z69_ITEM",LCANDEL,_aAltField,nFreeze,,nLinhas,cFieldOk,,,,oDlg)

	If lAlterar .And. lAprova
		//altera combo de status para so ter as opcoes aprova e rejeita
		oEncZ68:aentryctrls[3]:aitems := {  oEncZ68:aentryctrls[3]:aitems[3],  oEncZ68:aentryctrls[3]:aitems[4] }
	EndIf

	_nLRoda := 100

	@ _aPosObj[3,1], _nLRoda+7 		SAY 	oSayTotBR PROMPT "Total Qtde:" SIZE 100, 010 OF oDlg PIXEL
	@ _aPosObj[3,1], _nLRoda+57 	MSGET 	oGetTotBR VAR nGetTotBR SIZE 070, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL WHEN .F.
	@ _aPosObj[3,1], _nLRoda+137 	SAY 	oSayTotBA PROMPT "Total Valor:" SIZE 100, 010 OF oDlg PIXEL
	@ _aPosObj[3,1], _nLRoda+187 	MSGET 	oGetTotBA VAR nGetTotBA SIZE 070, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL WHEN .F.
	@ _aPosObj[3,1], _nLRoda+267 	SAY 	oSayTotFR PROMPT "Total Frete:" SIZE 100, 010 OF oDlg PIXEL
	@ _aPosObj[3,1], _nLRoda+317 	MSGET 	oGetTotFR VAR nGetTotFR SIZE 070, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL WHEN .F.

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons),)

	lRet:=(nOpca==1)
Return lRet

/*/{Protheus.doc} Z68CLIWH
@description WHEN dos campos dependentes do cliente cadastro sim o nao na tela da proposta
@author Fernando Rocha
@since 19/10/2016
@type function
/*/
User Function Z68CLIWH()
Return M->Z68_CLICAD == "N"

/*/{Protheus.doc} ZZOCLIWH
@description WHEN dos campos dependentes do cliente cadastro sim o nao na tela da Obra
@author Fernando Rocha
@since 19/10/2016
@type function
/*/
User Function ZZOCLIWH()
Return M->ZZO_CLICAD == "N"

/*/{Protheus.doc} BF01DCLI
@description Gatilho - busca dados do cliente
@author Fernando Rocha
@since 19/10/2016
@type function
/*/
User Function BF01DCLI()
	Local _aAreaA1 := SA1->(GetArea())

	If ( M->Z68_CLICAD == "S" )

		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(XFilial("SA1")+M->Z68_CODCLI+M->Z68_LOJCLI))

			M->Z68_NOMCLI 	:= SA1->A1_NOME
			M->Z68_END		:= SA1->A1_END
			M->Z68_COMPL	:= SA1->A1_COMPLEM
			M->Z68_BAIRRO	:= SA1->A1_BAIRRO
			M->Z68_EST		:= SA1->A1_EST
			M->Z68_CODMUN	:= SA1->A1_COD_MUN
			M->Z68_MUN		:= SA1->A1_MUN
			M->Z68_CNPJ		:= SA1->A1_CGC

			Return(M->Z68_CODCLI)

		Else

			Alert("Cliente não localizado!")
			Return("")

		EndIf

	EndIf

	RestArea(_aAreaA1)
Return(M->Z68_CODCLI)

/*/{Protheus.doc} Z68ALQGE
@description Validacao busca do clientem Generico
@author ferna
@since 19/10/2016
@type function
/*/
User Function Z68ALQGE()
	Local cAliasTmp
	Local cCodCli

	If Empty(M->Z68_EST)
		MsgAlert("Favor preencher a UF do cliente primeiro.")
		M->Z68_ALIQ := 0
		Return .T.
	EndIf

	//função int foi usado para resolver um problema de aliquota quebrada
	//na epoca o codigo do cliente tinha 6 digitos e a forma q foi modelado a função não permitia troca com baixo impacto 
	
	cCodCli := "G"+AllTrim(M->Z68_EST)+"I"+StrZero(INT(M->Z68_ALIQ),2)

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NoParser%

		SELECT A1_COD, A1_LOJA FROM %TABLE:SA1% WHERE A1_FILIAL = '  ' and A1_COD = %EXP:cCodCli% and A1_LOJA = '01' and %NotDel%

	EndSql

	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof())

		M->Z68_CODCLI := (cAliasTmp)->A1_COD
		M->Z68_LOJCLI := (cAliasTmp)->A1_LOJA
		(cAliasTmp)->(DbCloseArea())

	Else

		MsgAlert("Cliente não Localizado!")
		M->Z68_ALIQ := 0
		(cAliasTmp)->(DbCloseArea())
		Return .F.

	EndIf

Return .T.

/*/{Protheus.doc} BF01QTD
@description Gatilho campo Z69_QTDVEN
@author Fernando Rocha
@since 19/10/2016
@type function
/*/
User Function BF01QTD()

	Local aAreaB1 	:= SB1->(GetArea())
	Local wnProduto	:= Gdfieldget("Z69_CODPRO" ,N)
	Local wnQtdven	:= Gdfieldget("Z69_QTDVEN" ,N)
	Local wnQtdOrig	:= wnQtdven
	Local wnUnsven	:= 0

	If Empty(wnProduto)
		Return 0
	EndIf

	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(XFilial("SB1")+wnProduto))
		Return 0
	EndIf

	If SB1->B1_TIPCONV == "D"
		wnUnsven:= (wnQtdven / SB1->B1_CONV)
	Else
		wnUnsven:= (wnQtdven * SB1->B1_CONV)
	EndIf

	If SB1->B1_TIPO == "PA"
		wxInteiro := INT(wnUnsven)
		wxDecimal := (wnUnsven - INT(wnUnsven))

		If wxDecimal == 0
			wnQtdven	:= wnQtdOrig
		Else
			wnUnsven := wxInteiro + 1
			If SB1->B1_TIPCONV == "D"
				wnQtdven := (wnUnsven * SB1->B1_CONV)
			Else
				wnQtdven := (wnUnsven / SB1->B1_CONV)
			EndIf
		EndIf
	EndIf

	Gdfieldput("Z69_QTDVEN",wnQtdven,N)

	If wnQtdven <> wnQtdOrig
		MsgAlert("Quantidade Original na 1a. Unidade: "+str(wnQtdOrig,10,2)+", alterada para "+str(wnQtdven,10,2),"BFATTE01")
	EndIf

Return(wnQtdven)

/*/{Protheus.doc} BF01PRC
@description Busca do preco de venda
@author Fernando Rocha
@since 19/10/2016
@type function
/*/
User Function BF01PRC()
	Local _nPrcVen := 0
	Local _aImp
	Local _cProduto := Gdfieldget("Z69_CODPRO" ,N)
	Local _cTes
	Local _nDTOT
	Local _aRetPrc
	Local _cEmpFat	:= M->Z68_EMPFAT

	//posiciona Cliente
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(XFilial("SA1")+M->Z68_CODCLI+M->Z68_LOJCLI))

	If ( AllTrim(_cEmpFat) <> AllTrim(CEMPANT) ) 
		//Fernando em 08/07/2016 - executando busca de preco e parametros fiscais na LM porque o pedido de venda seria digitado na LM
		_aRetPrc := U_FROPCPRO(_cEmpFat,"01","U_BF01PRXX", M->Z68_LINHA, M->Z68_CODCLI, M->Z68_LOJCLI, _cProduto, dDataBase) //Fernando - alterado p/ dDataBase em 29/08 - Se a tabela do produto tiver modificada.
	Else
		_aRetPrc := U_BF01PRXX(M->Z68_LINHA, M->Z68_CODCLI, M->Z68_LOJCLI, _cProduto, dDataBase)
	EndIf

	//TES
	_cTes		:= _aRetPrc[1]

	//Buscar aliquotas de imposto
	_aImp		:= _aRetPrc[2]

	//Atualizar aliquota de ICMS no cabecalho para impressao
	If ( SA1->A1_CONTRIB == "1" )
		M->Z68_ALIQ := _aImp[1]+_aImp[3]
	Else
		M->Z68_ALIQ := _aImp[2]+_aImp[3]
	EndIf

	oEncZ68:EnchRefreshAll()
	//FIM>>>Bloco da Aliquota

	//Preco
	_nPrcVen	:= _aRetPrc[3]

	//Fator da condicao de pagamento
	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(XFilial("SE4")+M->Z68_COND)) .And. ( SE4->E4_YMAXDES > 0 )
		_nPrcVen := _nPrcVen * SE4->E4_YMAXDES
	EndIf

	//Salvando o preco de tabela
	Gdfieldput("Z69_PRCTAB", _nPrcVen ,N)

	//Desconto da Politica
	_nDTOT := U_BF01GPOL()

	//Aplicar o desconto
	_nPrcVen := _nPrcVen - (_nPrcVen * (_nDTOT / 100))

	//Arredondamento para 2 casas
	_nPrcVen := Round(_nPrcVen,2)

	if (_nPrcVen > 0 )
		Gdfieldput("Z69_DESC" , NoRound(_nDTOT,2) ,N)
		Gdfieldput("Z69_VALOR", NoRound(Gdfieldget("Z69_QTDVEN",N) * _nPrcVen,2) ,N)
	endif

Return(_nPrcVen)

User Function BF01PRXX(_cLinha, _cCodCli, _cLojCli, _cProduto, _dDEmissa)
	Local _aCampos := {"IT_ALIQICM","IT_ALIQCMP","IT_ALFCCMP"}
	Local _cSubTp := "N "
	Local _cTpOper := "N "
	Local _aRet := {}
	Local _cDIFAL
	Local _cCodTab

	//TES
	If AllTrim(CEMPANT) == "07"
		_cTpOper := "E "
	EndIf

	_cTes		:= MaTesInt(2, _cTpOper, _cCodCli, _cLojCli, "C", _cProduto)
	AAdd(_aRet, _cTes)

	//Buscar aliquotas de imposto
	_aImp		:= U_fGetImp(_aCampos, _cCodCli, _cLojCli, _cProduto, _cTes, 0, 0, 0)
	AAdd(_aRet, _aImp)

	//Bloco abaixo baseado no fDifICM2 do UserLibrary pois tem uma condicao que a aliquota do FECP nao retorna pelo BIAIMPOSTO
	//Somente para retornar a aliquota para gravar no cabecalho da proposta
	_cDIFAL  := "2" //Determina se calcula ou não DIFAL (1-Calcula / 2-Nao Calcula)
	//posiciona TES
	SF4->(DbSetOrder(1))
	If SF4->(DbSeek(XFilial("SF4")+_cTes))
		_cDIFAL := SF4->F4_DIFAL
	EndIf

	//posiciona Cliente
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(XFilial("SA1")+_cCodCli+_cLojCli))

	//posiciona produto
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cProduto))

	If ((Alltrim(SA1->A1_EST) $ "RJ_AL") .Or. (Alltrim(SA1->A1_EST) $ "MG" .And. cEmpAnt == "01")) .And. SA1->A1_TIPO == "F" .And. SA1->A1_CONTRIB == "2" .And. SB1->B1_FECP > 0 .And. Alltrim(SA1->A1_GRPTRIB) $ "005_006_010" .And. _cDIFAL == "1" .And. _aImp[3] == 0
		_aImp[3] := 2
	EndIf

	//Buscar a tabela de preco
	_cCodTab 	:= ""
	If _cLinha == "1"				//BIANCOGRES
		_cCodTab := Tabela("ZF","1E")
	ElseIf _cLinha == "2"		//INCESA
		_cCodTab := Tabela("ZF","2E")
	ElseIf _cLinha == "3"		//BELLACASA
		_cCodTab := Tabela("ZF","3E")
	ElseIf _cLinha == "4"		//MUNDI
		_cCodTab := Tabela("ZF","4E")
	EndIf

	//Preco
	_nPrcVen	:= U_fBuscaPreco(_cLinha,_cCodTab,_cProduto,Dtos(_dDEmissa),_cCodCli,_cLojCli,_cSubTp,_aImp[1],_aImp[2],_aImp[3],_cTes)
	AAdd(_aRet, _nPrcVen)

Return(_aRet)

/*/{Protheus.doc} BF01GAOP
@description Validacao do campo Z69_DTNECE
@author Fernando Rocha
@since 19/10/2016
@type function
/*/
User Function BF01GAOP()

	Local _aArea	:= GetArea()
	Local _cProduto := Gdfieldget("Z69_CODPRO" ,N)
	Local _nQuant	:= Gdfieldget("Z69_QTDVEN" ,N)
	Local _dDataNece:= Gdfieldget("Z69_DTNECE" ,N)
	Local _aRetOP
	Local _dDtRet

	_aRetOP := U_FRRT04PO('', '', _cProduto, _nQuant, 'N', 'E', _dDataNece)

	If _aRetOP[1] <> Nil

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(XFilial("SB1")+_cProduto))

		U_FROPMSG("[BFATTE01] PROPOSTA ENGENHARIA",	"PRODUTO: "+AllTrim(_cProduto)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
		"Qtde Solicitada: "+AllTrim(Str(_nQuant))+CRLF+CRLF+;
		"Previsão de Produção: "+CRLF+;
		"OP: "+_aRetOP[1]+"-"+_aRetOP[2]+"-"+_aRetOP[3]+CRLF+;
		"Data da entrega: "+DTOC(_aRetOP[4]),;
		,,"Produto com PrevisÃ£o de Produção")

		_dDtRet := Max(U_FROPAD3U(dDataBase), _aRetOP[4])
		Gdfieldput("Z69_DTDISP",_dDtRet,N)

	Else

		U_FROPMSG("[BFATTE01] PROPOSTA ENGENHARIA",	"PRODUTO: "+AllTrim(_cProduto)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
		"Não existe programação de produção deste produto com a quantidade solicitada disponível.",;
		,,"Produto sem PrevisÃ£o de Produção")

		Gdfieldput("Z69_DTDISP",CTOD(" "),N)

	EndIf

	RestArea(_aArea)
Return(.T.)

/*/{Protheus.doc} BF01PARC
@description Processamento das parcelas de condicao 142 - Contrato
@author Fernando Rocha
@since 19/10/2016
@type function
/*/
User Function BF01PARC

	Local aArea	:= GetArea()				//Salva a area anterior
	Local aHeadAnt := aClone(aHeader)			//Salva o aHeader
	Local aColsAnt := aClone(aCols)			//Salva o aCols
	Local nAnt := n
	Local lRetParc := .F.

	Local oFont1 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Local oPanel1
	Local oPanel2
	Local oSay1
	Local oSay2
	Local nCount

	Private cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
	Private nNumParc := GetMv("MV_NUMPARC", .F., 12)
	Private OK

	Private aColsEx := {}
	Private aFieldFill := {}
	Private aFields := {"ZA5_VALOR","ZA5_DATA"}
	Private aAlterFields := {}
	Private aHeaderEx := {}
	Private nVlrTotPed := nGetTotBA
	Private oMSNewGetDados1
	Private ap_Esc := .F.

	Private oGetDia
	Private nGetDia := 0
	Private oGetParc
	Private nGetParc := 0
	Private oGetCare
	Private nGetCare := 0
	Private oDlgParc

	If !(M->Z68_COND == "142")
		MsgInfo("Esta função somente pode ser usada para a condição de pagamento 142","Parcelas de Contrato")
		Return(.F.)
	EndIf

	If INCLUI .Or. ALTERA
		aAlterFields:= {"ZA5_VALOR","ZA5_DATA"}
	EndIf

	aHeader := {}
	aCols := {}

	aHeader := fHeader()

	ZA5->(DbSetOrder(1))
	IF ZA5->(DbSeek(xFilial("ZA5") + M->Z68_NUM + M->Z68_REV ))

		While !ZA5->(Eof()) .And. ZA5->(ZA5_FILIAL+ZA5_NUM+ZA5_REV) == (xFilial("ZA5") + M->Z68_NUM + M->Z68_REV )

			aAdd(aCols, {0, cToD(""), .F.})

			aCols[Len(aCols)][1] := ZA5->ZA5_VALOR
			aCols[Len(aCols)][2] := ZA5->ZA5_DATA
			aCols[Len(aCols)][3] := .F.

			ZA5->(DbSkip())
		EndDo

	ELSE

		If Len(aParcContr) > 0

			For nCount := 1 To Len(aParcContr)

				aAdd(aCols, {0, cToD(""), .F.})
				aCols[Len(aCols)][1] := aParcContr[nCount][1]
				aCols[Len(aCols)][2] := aParcContr[nCount][2]
				aCols[Len(aCols)][3] := .F.

			Next

		Else
			aAdd(aCols, {0, cToD(""), .F.})
		EndIf

	ENDIF

	DEFINE MSDIALOG oDlgParc TITLE "Parcelas de Contrato" FROM 000, 000  TO 400, 500 COLORS 0, 16777215 PIXEL

	@ 000, 000 MSPANEL oPanel1 SIZE 250, 026 OF oDlgParc COLORS 0, 16777215 RAISED

	@ 007, 004 SAY oSay1 PROMPT "Parcelas:" SIZE 036, 012 OF oPanel1 FONT oFont1 COLORS 16711680, 16777215 PIXEL
	@ 007, 039 MSGET oGetParc VAR nGetParc SIZE 017, 010 OF oPanel1 COLORS 0, 16777215 PIXEL Picture "@R 99"
	@ 007, 059 SAY oSay2 PROMPT "Dia Vencto.:" SIZE 046, 012 OF oPanel1 FONT oFont1 COLORS 16711680, 16777215 PIXEL
	@ 007, 103 MSGET oGetDia VAR nGetDia SIZE 017, 010 OF oPanel1 COLORS 0, 16777215 PIXEL Picture "@R 99"
	@ 007, 123 SAY oSay3 PROMPT "Carencia:" SIZE 036, 012 OF oPanel1 FONT oFont1 COLORS 16711680, 16777215 PIXEL
	@ 007, 158 MSGET oGetCare VAR nGetCare SIZE 017, 010 OF oPanel1 COLORS 0, 16777215 PIXEL Picture "@R 99"
	@ 006, 183 BUTTON oButSug PROMPT "Sugerir" SIZE 037, 012 OF oPanel1 FONT oFont1 ACTION ( fSugParcela() )PIXEL

	If !(INCLUI .Or. ALTERA)
		oPanel1:lVisible := .F.
	EndIf

	@ 179, 000 MSPANEL oPanel2 SIZE 250, 020 OF oDlgParc COLORS 0, 16777215 RAISED

	If (INCLUI .Or. ALTERA)
		@ 000, 207 BUTTON oButOk PROMPT "Salvar" SIZE 042, 019 OF oPanel2 FONT oFont1 ACTION ( ap_Esc := fVldParcela(), lRetParc := ap_Esc, IIF(lRetParc, oDlgParc:End(),) ) PIXEL
	EndIf

	@ 000, 165 BUTTON oButCanc PROMPT "Cancelar" SIZE 041, 019 OF oPanel2 FONT oFont1 ACTION (lRetParc := .F., ap_Esc := .T., oDlgParc:End()) PIXEL

	oMSNewGetDados1 := MsNewGetDados():New(01, 02, 80, 215, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, nNumParc, "AllwaysTrue", "", "AllwaysTrue", oDlgParc, aHeader, aCols)

	// Don't change the Align Order
	oPanel1:Align 	:= CONTROL_ALIGN_TOP
	oPanel2:Align 	:= CONTROL_ALIGN_BOTTOM

	If (INCLUI .Or. ALTERA)
		oButOk:Align 	:= CONTROL_ALIGN_RIGHT
	EndIf

	oButCanc:Align 	:= CONTROL_ALIGN_RIGHT
	oMSNewGetDados1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgParc CENTERED VALID ap_Esc

	If (lRetParc)
		aParcContr := aClone(oMSNewGetDados1:aCols)
	EndIf

	aHeader	:= aClone(aHeadAnt)
	aCols := aClone(aColsAnt)
	n	:= nAnt
	RestArea(aArea)

Return(lRetParc)

Static Function fHeader()
	Local aHeaderAxu := {}

	AADD(aHeaderAxu,{	"Valor da Parcela",;					//01 - X3TITULO()            //"Valor da Parcela"
	"ZA5_VALOR",;							//02 - X3_CAMPO
	PesqPict("ZA5","ZA5_VALOR"),;  			//03 - X3_PICTURE
	TamSX3("ZA5_VALOR")[1]     ,;			//04 - X3_TAMANHO
	TamSX3("ZA5_VALOR")[2]     ,;			//05 - X3_DECIMAL
	"Positivo()",;							//06 - X3_VALID
	"???????????????",;						//07 - X3_USADO
	"N",;									//08 - X3_TIPO
	"",;									//09 - X3_ARQUIVO
	"" 	} )

	AADD(aHeaderAxu,{	"Data",;												//01 - X3TITULO()		//"Data"
	"ZA5_DATA",;											//02 - X3_CAMPO
	"",;													//03 - X3_PICTURE
	8,;														//04 - X3_TAMANHO
	0,;														//05 - X3_DECIMAL
	"NaoVazio()",;											//06 - X3_VALID
	"???????????????",;										//07 - X3_USADO
	"D",;													//08 - X3_TIPO
	"",;													//09 - X3_ARQUIVO
	"" 	} )													//10 - X3_CONTEXT

Return aHeaderAxu

Static Function fSugParcela()

	Local nParc := nGetParc
	Local nValParc, dDataParc
	Local I

	If ( nParc > 0 )

		aCols := {}

		nValParc := NoRound( nVlrTotPed / nParc ,2)
		dDataParc := DataValida(dDataBase + IIf(nGetCare > 0, nGetCare, 30))
		If (nGetDia > 0)
			dDataParc := STOD( StrZero(Year(dDataParc),4) +  StrZero(Month(dDataParc),2) + StrZero(nGetDia,2) )
		EndIf

		For I := 1 To nParc

			If ( I == nParc )
				nValParc := nValParc + (nVlrTotPed - ( nValParc * nParc ))
			EndIf

			aAdd(aCols, {0, cToD(""), .F.})
			aCols[Len(aCols)][1] := nValParc
			aCols[Len(aCols)][2] := dDataParc
			aCols[Len(aCols)][3] := .F.

			dDataParc := DataValida(dDataParc + 30)
			If (nGetDia > 0)
				dDataParc := STOD( StrZero(Year(dDataParc),4) +  StrZero(Month(dDataParc),2) + StrZero(nGetDia,2) )
			EndIf

		Next I

		oMSNewGetDados1:ACols := AClone(aCols)
		oMSNewGetDados1:oBrowse:Refresh()
		oDlgParc:Refresh()

	EndIf

Return

Static Function fVldParcela()
	Local lRet := .T.
	Local nCount := 1
	Local nMinParc := GetMv("MV_YVRPARM", .F., 4000)
	Local aColsParc := aClone(oMSNewGetDados1:aCols)
	Local nVlrTotPar := 0

	// Ordena array por data
	Asort(aColsParc,,, {|x, y| x[2] < y[2] })

	While nCount <= Len(aColsParc) .And. lRet

		// Item nao deletado
		If !aColsParc[nCount][3]

			// Verificar o Valor
			If aColsParc[nCount][1] > 0

				// Regra nao utilzada pela Vitcer
				If aColsParc[nCount][1] < nMinParc
					MsgAlert('O Valor da Parcela não pode ser menor que '+cValToChar(nMinParc)+'!','Valor da Parcela')
					lRet := .F.
				Else
					nVlrTotPar += aColsParc[nCount][1]
				EndIf

			Else
				MsgAlert('Favor informar um valor válido para a Parcela!','Valor Parcela')
				lRet := .F.
			EndIf

		EndIf

		nCount++

	EndDo

	If nVlrTotPar <> nVlrTotPed
		MsgAlert('O Valor da Total das Parcelas está diferente do Valor Total do Pedido. Favor ajustar!', 'Parcelas Contrato')
		lRet := .F.
	EndIf

	// Se o valor esteja valido, avalia data
	If lRet

		nCount := 1

		While nCount <= Len(aColsParc) .And. lRet

			// Item nao deletado
			If !aColsParc[nCount][3]
				'
				If nCount > 1

					// Data da parcela anterior
					If aColsParc[nCount-1][2] <> Nil

						// Verifica se a data da parcela esta menor ou igual a da parcela anterior
						If aColsParc[nCount][2] <= aColsParc[nCount-1][2]
							MsgAlert('A Data da Parcela não pode ser Menor ou Igual da Parcela Anterior!','Data da Parcela')
							lRet := .F.
						EndIf

					EndIf

				EndIf

			EndIf

			nCount++

		EndDo

	EndIf

Return(lRet)

Static Function fSalvaParc()
	Local nCount := 0
	Local nPos := 0
	Local aColsParc := aClone(aParcContr)
	Local aItDel := {}

	ZA5->(DbSetOrder(1))
	IF ZA5->(DbSeek(xFilial("ZA5") + M->Z68_NUM + M->Z68_REV ))

		While !ZA5->(Eof()) .And. ZA5->(ZA5_FILIAL+ZA5_NUM+ZA5_REV) == (xFilial("ZA5") + M->Z68_NUM + M->Z68_REV )

			RecLock("ZA5",.F.)
			ZA5->(DbDelete())
			ZA5->(MsUnlock())

			ZA5->(DbSkip())
		EndDo

	EndIf

	// Remove itens deletados do array
	For nCount := 1 To Len(aColsParc)

		// Registro deletado
		If aColsParc[nCount][3]
			aAdd(aItDel, nCount)
		EndIf

	Next

	nCount := 0

	If Len(aItDel) > 0

		For nCount := 1 To Len(aItDel)
			aDel(aColsParc, aItDel[nCount])
			aSize(aColsParc, Len(aColsParc)-1)
		Next

	EndIf

	// Orden itens por data
	aSort(aColsParc,,, {|x, y| x[2] < y[2] })

	nCount := 0

	// Insere parcelas
	For nCount := 1 To Len(aColsParc)

		RecLock("ZA5",.T.)
		ZA5->ZA5_FILIAL := XFILIAL("ZA5")
		ZA5->ZA5_NUM := M->Z68_NUM
		ZA5->ZA5_REV := M->Z68_REV
		ZA5->ZA5_VALOR := aColsParc[nCount][1]
		ZA5->ZA5_DATA := aColsParc[nCount][2]
		ZA5->(MsUnlock())

	Next

Return(.T.)

/*/{Protheus.doc} BF01PRZ
@description calculo de prazo medio
@author Fernando Rocha
@since 19/10/2016
@type function
/*/
User Function BF01PRZ()
	Local nDias := 0
	Local nCont := 0

	SE4->(DbSetOrder(1))
	If (Z68->Z68_COND <> "142") .And. SE4->(DbSeek(XFilial("SE4")+Z68->Z68_COND))

		Return SE4->E4_YMEDIA

	Else

		//Calculo pelas parcelas de contrato
		ZA5->(DbSetOrder(1))
		If ZA5->(DbSeek(xFilial("ZA5") + Z68->Z68_NUM + Z68->Z68_REV ))
			While !ZA5->(Eof()) .And. ZA5->(ZA5_FILIAL+ZA5_NUM+ZA5_REV) == (xFilial("ZA5") + Z68->Z68_NUM + Z68->Z68_REV )

				nDias += ( ZA5->ZA5_DATA - dDataBase )
				nCont++

				ZA5->(DbSkip())
			EndDo
		EndIf

		Return Round( nDias / nCont , 0)

	EndIf

Return

/*/{Protheus.doc} BFTE01CL
@description Definir o cliente final para propostas com cliente generico
@author Fernando Rocha
@since 19/10/2016
@type function
/*/
/*/{Protheus.doc} BFTE01CL
//TODO Descrição auto-gerada.
@author Fernando Rocha
@since 09/02/2017
@version undefined

@type function
/*/
User Function BFTE01CL

	Local aPergs := {}
	Local cCodCli := Space(6)
	Local cLojCli := Space(2)
	Local aRet := {Space(6),Space(2)}

	If !( Z68->Z68_CLICAD == "N" )
		MsgAlert("Função somente disponível para Propostas sem cliente cadastrado!","Definir Cliente da Proposta")
		Return
	EndIf

	aAdd( aPergs ,{1,"Cliente",cCodCli,"@!",'.T.',"SA1",'.T.',50,.T.})
	aAdd( aPergs ,{1,"Loja",cLojCli,"@!",'.T.',"",'.T.',10,.T.})

	If !ParamBox(aPergs ,"Definir Cliente da Proposta",aRet)
		Return
	EndIf

	cCodCli := aRet[1]
	cLojCli := aRet[2]

	SA1->(DbSetOrder(1))

	If !SA1->(DbSeek(XFilial("SA1")+cCodCli+cLojCli))
		MsgAlert("Cliente não encontrado!","Definir Cliente da Proposta")
		Return
	Else

		If !MsgNoYes("Tem certeza que deseja associar o Cliente: "+AllTrim(SA1->A1_NOME)+CRLF+;
		"com a proposta número : "+Z68->Z68_NUM+Z68->Z68_REV,"Definir Cliente da Proposta")
			Return
		EndIf

	EndIf

	//Gravando dados
	RecLock("Z68",.F.)
	Z68->Z68_CLICAD := "S"
	Z68->Z68_CODCLI := cCodCli
	Z68->Z68_LOJCLI := cLojCli
	Z68->Z68_NOMCLI := SA1->A1_NOME
	Z68->(MsUnlock())

	MsgInfo("Cliente associado com sucesso!","Definir Cliente da Proposta")

Return


/*/{Protheus.doc} BF1VPROD
@description Validar digitacao do produto na proposta de engenharia
@author Fernando Rocha
@since 09/02/2017
@version undefined
@type function
/*/
User Function BF1VPROD

	Local lRetorno	:= .T.
	Local _aArea	:= GetArea()
	Local _aAreaB1	:= SB1->(GetArea())
	Local _cEmpFat	:= M->Z68_EMPFAT
	Local _cPctLM 	:= AllTrim(GetNewPar("FA_XPCTLM","8_9_D_B"))
	Local _cAliasTmp

	//Validação de produtos OUTSOURCING para cliente sem tratamento especial na LM
	//Obrigar pedidos de prodtudos de pacotes especificos de serem implantados fora da LM - Solic. Claudeir em 28/11/2014
	//Nao pode executar na replicao para empresa de origem

	SB1->(DbSetOrder(1))

	If Alltrim(_cEmpFat) <> "07" 
		If SB1->(DbSeek(XFilial("SB1")+M->Z69_CODPRO)) .And. (SB1->B1_YPCGMR3 $ _cPctLM)

			U_FROPMSG("Proposta Engenharia - Valida Produto", "Produto não permitido para esta Empresa/Cliente."+CRLF+"Favor informar LM no campo 'Empresa NF'.",,2,"Tratamento Especial.")
			lRetorno := .F.

		EndIf
	EndIf


	If lRetorno .And. Alltrim(_cEmpFat) == "07" .And. !Empty(M->Z68_CODCLI) 

		If Alltrim(M->Z68_LINHA) == "1" //BIANCO
			_cTabSA1 := "SA1010"
		Else
			_cTabSA1 := "SA1050"
		EndIf

		CSQL := " SELECT A1_YTRTESP FROM "+_cTabSA1+" WHERE A1_COD = '"+M->Z68_CODCLI+"' AND A1_LOJA = '"+M->Z68_LOJCLI+"' AND D_E_L_E_T_=' ' "

		_cAliasTmp := GetNextAlias()
		TCQUERY CSQL ALIAS (_cAliasTmp) NEW    
		(_cAliasTmp)->(DbGoTop())

		If !(_cAliasTmp)->(Eof()) .And. !(Alltrim((_cAliasTmp)->A1_YTRTESP) == "1")

			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(XFilial("SB1")+M->Z69_CODPRO)) .And. !(SB1->B1_YPCGMR3 $ _cPctLM) 

				U_FROPMSG("Proposta Engenharia - Valida Produto", "Produto não permitido para esta Empresa/Cliente."+CRLF+"Favor informar a empresa de Origem no campo 'Empresa NF'.",,2,"Tratamento Especial.")
				lRetorno := .F.

			EndIf

		EndIf
		(_cAliasTmp)->(DbCloseArea())

	EndIf

	RestArea(_aArea)
	RestArea(_aAreaB1)

Return(lRetorno)

/*/{Protheus.doc} BF01CRPG
@description Gatilho ao alterar a condicao de pagamento - obrigar a digitar novamente as linhas
@author Fernando Rocha
@since 08/08/2017
@version undefined
@type function
/*/
User Function BF01CRPG()

	If lAlterar .and. Z68->Z68_COND <> M->Z68_COND

		If !MsgNoYes("Atenção! Ao alterar a condição de pagamento os preços dos produtos serão reprocessados."+CRLF+"Deseja continuar?","Alteração de Condição de Pagamento")
			Return(Space(3))
		EndIf

		U_BIAMsgRun("Aguarde... Reprocessando Preços de Venda. ",,{|| ProcAltPrc()})
	EndIf

	oGetDados:ForceRefresh()

Return(M->Z68_COND)

Static Function ProcAltPrc()

	Local I
	Local nPrc

	For I := 1 To len(ACOLS)

		N := I

		nPrc := U_BF01PRC()

		Gdfieldput("Z69_PRCVEN", nPrc ,N)

	Next I

Return

/*/{Protheus.doc} Z68GetNum
@description Funcao criada para usar no lugar do GETSXENUM que está fazendo uma bagunça no sistema depois que Ranisses habilitou o Enable Number
@author Fernando Rocha
@since 07/02/2018
/*/
Static Function Z68GetNum(_cNumero)

	Local _CSQL
	Local _cAliasTmp
	Local _lRet := .T.

	_CSQL := " select NUM = isnull(RIGHT('000000' + convert(varchar(6),convert(int, max(Z68_NUM))+1),6),'000001') from "+RetSQLName("Z68")+" Z68 "
	_cAliasTmp := GetNextAlias()
	TCQUERY _CSQL ALIAS (_cAliasTmp) NEW    
	(_cAliasTmp)->(DbGoTop())

	If !(_cAliasTmp)->(Eof())
		_cNumero := (_cAliasTmp)->NUM
	Else
		MsgAlert("ERRO NA GERAÇÃO DO NÚMERO DA PROPOSTA","ATENÇÃO: ENTRAR EM CONTATO COM A TI.")
		_lRet := .F.
	EndIf
	(_cAliasTmp)->(DbCloseArea())

	Z68->(DbSetOrder(1))
	While Z68->(DbSeek(XFilial("Z68")+_cNumero))
		_cNumero := Soma1(_cNumero,Len(_cNumero))
	EndDo

Return(_lRet)

Static Function Z69FRTGET(nFrtTon, cProduto, nQtd)

	Local nFrtIt := 0

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+cProduto))

		nFrtIt := (( SB1->B1_PESO * nQtd )/1000) * nFrtTon

		nFrtIt += (((nQtd/SB1->B1_CONV) * SB1->B1_YPESEMB)/1000) * nFrtTon

	EndIf

Return(nFrtIt)

User Function Z69FRTSX7()

	Local nFrtIt 	:= 0
	Local cProduto 	:= aCols[N,aScan(aHeader,{|x| AllTrim(x[2])=="Z69_CODPRO" })]
	Local nQtd	   	:= aCols[N,aScan(aHeader,{|x| AllTrim(x[2])=="Z69_QTDVEN" })]
	Local nFrtTon	:= M->Z68_FRTUNI

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+cProduto))

		nFrtIt := (( SB1->B1_PESO * nQtd )/1000) * nFrtTon

		nFrtIt += (((nQtd/SB1->B1_CONV) * SB1->B1_YPESEMB)/1000) * nFrtTon

	EndIf

Return(nFrtIt)