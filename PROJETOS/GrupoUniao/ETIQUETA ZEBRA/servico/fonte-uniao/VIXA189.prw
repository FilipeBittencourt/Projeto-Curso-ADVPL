#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE 'FWMVCDEF.CH'
#include "TOPCONN.CH"
#include "shell.ch"

#Define cPerg 'VIXA189'
#DEFINE ENTER Chr(10) + Chr(13)

/*/{Protheus.doc} VIXA189
Controle de rastreamento Sigep
@author henrique
@since 02/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function VIXA189()

	Local oFWLayer		:= Nil
	Local aCoors			:= FWGetDialogSize(oMainWnd)

	Private cImpressora	:= ''
	Private cImpZebra	:= SuperGetMV("MV_YIMPZEB",.F.,"000015")

	Private cLocalArm		:= ''
	Private cEmpArmaz		:= ''
	Private oDlg	   			:= Nil

	Private cCliente 		:= Space(AVSX3('F2_CLIENTE'	, 3))
	Private cNome			:= Space(AVSX3('A1_NOME'		, 3))
	Private cLoja 		:= Space(AVSX3('F2_LOJA'		, 3))
	Private cEmail		:= Space(AVSX3('A1_YEMAIL'	, 3))
	Private dEmissaoDe 	:= CTOD('')
	Private dEmissaoAte 	:= CTOD('')
	Private cTipoTit		:= '3'

	Private oCliente		:= Nil
	Private oLoja			:= Nil
	Private oNome			:= Nil
	Private oBrwDoc		:= Nil
	Private oEmail		:= nil
	Private oTitulos		:= Nil

	Private cAliasSF2 	:= GetNextAlias()
	Private cAliasZZB 	:= GetNextAlias()
	Private cAliasPLP 	:= GetNextAlias()
	Private aHeadSF2  	:= {}
	Private aHeadZZB  	:= {}
	Private aHeadPLP  	:= {}
	Private aHeadFEC  	:= {}
	Private oSigep		:= ServSigep():New()

	Private oBrowserPLP := nil

	CriaPerg()

	Pergunte(cPerg, .F.)
	cLocalArm := MV_PAR01
	If MV_PAR01 == 1
		cLocalArm 	:= '0801'
		cEmpArmaz  	:= '0801 - TIMS'
	ElseIf MV_PAR01 == 2
		cLocalArm 	:= '0105'
		cEmpArmaz  	:= '0105 - VILA VELHA'
	Else
		cLocalArm 	:= ''
		cEmpArmaz	:= ''
	EndIf

	If Empty(MV_PAR01)
		Aviso("Atencao","Favor informar o local de separação dos produtos",{"OK"})//"Atençao","O operador não foi localizado para realizar o atendimento",{"OK"})

		If .T.
			If !Pergunte(cPerg, .T.)
				Return
			Else
				cLocalArm := MV_PAR01
			EndIf
		EndIf
	Endif

	SF2SQL()
	AtualizaRastro()
	AtualizaPLP()
	SlqPLPFechadas()

	DEFINE MSDIALOG oDlg TITLE "Controle de rastreamento SIGEP - Empresa Armazenadora: "+cEmpArmaz  FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlg,.F.,.T.)

		//Adiciona Janelas as colunas
		oFWLayer:AddLine('UP'	,65,.F.)
		oFWLayer:AddLine('DOWN'	,35,.F.)

		oFWLayer:AddCollumn('NFABERTA' 		,080 ,.F., 'UP')
		oFWLayer:AddCollumn('RASTROS' 		,020 ,.T., 'UP')
		oFWLayer:AddCollumn('NFFECHADA' 	,070 ,.F., 'DOWN')
		oFWLayer:AddCollumn('PLP' 			,030 ,.T., 'DOWN')
		//oFWLayer:AddCollumn('BOTOES' 		,010 ,.T., 'DOWN')

		//Criação do Painei para divisão da tela para os elementos
		oJanNFAberta	:= oFWLayer:GetColPanel('NFABERTA'	,'UP')
		oJanRastro		:= oFWLayer:GetColPanel('RASTROS'	,'UP')
		oJanNFFechad	:= oFWLayer:GetColPanel('NFFECHADA','DOWN')
		oJanPLP		:= oFWLayer:GetColPanel('PLP'		,'DOWN')
		//oJanBotoes		:= oFWLayer:GetColPanel('BOTOES'	,'DOWN')

		//Browse
		oBrowseUp := FWMBrowse():New()
		oBrowseUp:SetSeeAll(.F.)
		oBrowseUp:SetOwner(oJanNFAberta)
		oBrowseUp:SetDescription("Notas em aberto")
		oBrowseUp:SetAlias('TRBSF2')
		oBrowseUp:SetFields(aHeadSF2)
		oBrowseUp:SetMenuDef('')
		oBrowseUp:DisableDetails()
		oBrowseUp:SetProfileID('1')
		oBrowseUp:ForceQuitButton()
		//oBrowseUp:SetSeek(.T.,CriaSeek())
		oBrowseUp:Activate()

		//Browse
		oBrowserRas := FWMBrowse():New()
		oBrowserRas:SetSeeAll(.F.)
		oBrowserRas:SetOwner(oJanRastro)
		oBrowserRas:SetDescription("Rastreamento")
		oBrowserRas:SetAlias('TRBZZB')
		oBrowserRas:SetFields(aHeadZZB)
		oBrowserRas:SetMenuDef('')
		oBrowserRas:DisableDetails()
		oBrowserRas:SetProfileID('2')
		oBrowserRas:ForceQuitButton()
		oBrowserRas:Activate()

		//Browse
		oBrowserPLP := FWMBrowse():New()
		oBrowserPLP:SetSeeAll(.F.)
		oBrowserPLP:SetOwner(oJanNFFechad)
		oBrowserPLP:SetDescription("Faltando PLP")
		oBrowserPLP:SetAlias('TRBPLP')
		oBrowserPLP:SetFields(aHeadPLP)
		oBrowserPLP:SetMenuDef('')
		oBrowserPLP:DisableDetails()
		oBrowserPLP:SetProfileID('3')
		oBrowserPLP:ForceQuitButton()
		oBrowserPLP:Activate()

		//Browse
		oBrwPLPFech := FWMBrowse():New()
		oBrwPLPFech:SetSeeAll(.F.)
		oBrwPLPFech:SetOwner(oJanPLP)
		oBrwPLPFech:SetDescription("PLP")
		oBrwPLPFech:SetAlias('TRBFEC')
		oBrwPLPFech:SetFields(aHeadFEC)
		oBrwPLPFech:SetMenuDef('VIXA189')
		oBrwPLPFech:DisableDetails()
		oBrwPLPFech:SetProfileID('4')
		oBrwPLPFech:ForceQuitButton()
		oBrwPLPFech:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

	If SELECT('TRBSF2') > 0
		TRBSF2->(DbCloseArea())
	EndIf

	If SELECT('TRBZZB') > 0
		TRBZZB->(DbCloseArea())
	EndIf

	If SELECT('TRBPLP') > 0
		TRBPLP->(DbCloseArea())
	EndIf

	If SELECT('TRBFEC') > 0
		TRBFEC->(DbCloseArea())
	EndIf

	FreeObj(oSigep)

Return

/*/{Protheus.doc} MenuDef
Rotina para montagem do menu
@author henrique
@since 12/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
	Local aRotina 	:= {}
	Local aRotina1 	:= {  	{"Todas"			,'StaticCall(VIXA189, ImpAR, "" , 1)',0,4},;
								{"Escolher"		,'StaticCall(VIXA189, ImpAR, "" , 2)',0,4}}
	Local aRotina2 	:= {  	{"Todas"			,'StaticCall(VIXA189, ImpEtiqueta, "" , 1)',0,4},;
								{"Escolher"		,'StaticCall(VIXA189, ImpEtiqueta, "" , 2)',0,4}}

	ADD OPTION aRotina TITLE 'Cód de barras' 	ACTION 'Processa( {|| StaticCall(VIXA189, TelaCodBarras)}, "Aguarde...", "Obtendo os rastros.",.F.)'				OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE 'Gerar Etiqueta' ACTION 'Processa( {|| StaticCall(VIXA189, GeraEtiqueta)}, "Aguarde...", "Abrindo tela Código de barras",.F.)'	OPERATION 3 	ACCESS 0
	ADD OPTION aRotina TITLE 'Gerar PLP'		ACTION 'Processa( {|| StaticCall(VIXA189, GeraPLP)}, "Aguarde...", "Gerando PLP.",.F.)'								OPERATION 3	ACCESS 0

	ADD OPTION aRotina TITLE 'Imp Todos' 		ACTION 'Processa( {|| StaticCall(VIXA189, ImpRelPLP, , .T.)}, "Aguarde...", "Imprimindo PLP.",.F.) '				OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE 'Imp PLP' 		ACTION 'Processa( {|| StaticCall(VIXA189, ImpRelPLP)}, "Aguarde...", "Imprimindo PLP.",.F.) '						OPERATION 3	ACCESS 0

	ADD OPTION aRotina TITLE 'Imp AR' 			ACTION aRotina1				OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE 'Imp Etiqueta' 	ACTION aRotina2				OPERATION 3	ACCESS 0

	ADD OPTION aRotina TITLE 'Impressora' 		ACTION 'Processa( {|| StaticCall(VIXA189, SelImpressora)}, "Aguarde...", "",.F.)'		OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE 'Impressora Zebra'	ACTION 'Processa( {|| StaticCall(VIXA189, SelImpZebra)}, "Aguarde...", "",.F.)'		OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE 'Info Local' 		ACTION 'Processa( {|| StaticCall(VIXA189, InfoArmazem)}, "Aguarde...", "",.F.)'		OPERATION 3	ACCESS 0

Return aRotina

/*/{Protheus.doc} SF2SQL
Monta a tabela temporária do browse para mostrar as notas sem rastreamento
@author henrique
@since 02/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function SF2SQL()
	Local cTrab		:= ''
	Local aStru		:= {}
	Local i			:= 0
	Local cTransp := SuperGetMV("MV_Y189TRA",.F.,'000901/000902/000903/000703')


	If !Empty(cTransp)
		cTransp := ' AND SF2.F2_TRANSP IN ' + FormatIn(cTransp,'/')
	Else
		cTransp := " AND 1 = 1 "
	End If

	cTransp := '% '+cTransp+' %'

	BeginSql alias cAliasSF2
		SELECT DISTINCT //Colocado por causa a quantidade de itens na tabela VT4
			A1_COD, A1_LOJA, A1_NOME, F2_DOC, F2_SERIE, F2_EMISSAO, F2_VOLUME1
			, SA4.A4_COD, SA4.A4_NOME, SA4.A4_YSERVIC
			, SA1.A1_END, SA1.A1_COMPLEM, SA1.A1_BAIRRO, SA1.A1_EST, SA1.A1_MUN, SA1.A1_CEP, A1_CGC, D2_PEDIDO
		FROM
			%table:SF2% SF2
			JOIN %table:SD2% SD2 ON (
										D2_FILIAL 	   = F2_FILIAL
										AND D2_DOC	   = F2_DOC
										AND D2_SERIE   = F2_SERIE
										AND D2_CLIENTE = F2_CLIENTE
										AND D2_LOJA    = F2_LOJA
										AND SF2.%NotDel%
									)
			JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND SA1.%NotDel% AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA
			JOIN %table:SA4% SA4 ON A4_FILIAL = %xFilial:SA4% AND SA4.%NotDel% AND SA4.A4_COD = SF2.F2_TRANSP
			JOIN %table:SC5% SC5 ON C5_FILIAL = %xFilial:SC5% AND SC5.%NotDel% AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE
			LEFT JOIN %table:VT1% VT1 ON VT1_FILIAL = %xFilial:VT1% AND VT1.%NotDel% AND SC5.C5_NUM = VT1.VT1_NUMPED
 			LEFT JOIN %table:VT4% VT4 ON VT4_FILIAL = %xFilial:VT4% AND VT4.%NotDel% AND VT4.VT4_ORDID = VT1.VT1_ORDID AND VT4_EMPFOR+VT4_FILFOR = %Exp:cLocalArm%
			LEFT JOIN %table:ZZB% ZZB ON ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel% AND ZZB.ZZB_DOC = SF2.F2_DOC AND ZZB.ZZB_SERIE = SF2.F2_SERIE
		WHERE
			SF2.F2_FILIAL = %xFilial:SF2% AND SF2.%NotDel%
			AND SF2.F2_TIPO = 'N' AND SF2.F2_EMISSAO >= '20170315'
			%Exp:cTransp%
			AND ZZB.ZZB_DOC IS NULL
		ORDER BY
			F2_DOC

	EndSql

	If Select('TRBSF2') > 1
		TRBSF2->(DbCloseArea())
	EndIf

	aStru := (cAliasSF2)->(dbStruct())
	aStru := U_FormatStruction(aStru)

	cTrab := CriaTrab(aStru)
	dbUseArea(.T.,,cTrab,"TRBSF2")
	IndRegua("TRBSF2", cTrab, "F2_DOC+F2_SERIE",,,	"Indexando registros...")

	(cAliasSF2)->(dbGoTop())
	While (cAliasSF2)->(!Eof())
		RecLock('TRBSF2', .T.)

		For i := 1 to Len(aStru)

			If aStru[i, 2] == 'D'
				TRBSF2->&(aStru[i, 1]) := STOD((CALIASSF2)->&(aStru[i, 1]))
			Else
				TRBSF2->&(aStru[i, 1]) := (CALIASSF2)->&(aStru[i, 1])
			EndIf

		Next

		TRBSF2->(MsUnLock())
		(cAliasSF2)->(DbSkip())
	EndDo

	TRBSF2->(DbGoTop())

	aHeadSF2 := {}

	For i := 1 to Len(aStru)
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(aStru[i, 1]) //.and. !aStru[i, 1] $ "U5_OPERADO/A1_LOJA/A1_CGC/A1_EST"
			aAdd(aHeadSF2,{SX3->X3_TITULO,;
				aStru[i, 1],;
				SX3->X3_TIPO,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_PICTURE} )
		Endif
	Next

	(cAliasSF2)->(DbCloseArea())

Return

/*/{Protheus.doc} AtualizaRastro
Atualiza o browse que contém os código de rastreamento
@author henrique
@since 05/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function AtualizaRastro(oSigep)
	Local cTrab	:= ''
	Local aStru	:= {}
	Local i		:= 0

	BeginSql alias cAliasZZB
		SELECT ZZB_RASTRO, ZZB_SERVIC
		FROM (	SELECT LEFT(ZZB.ZZB_RASTRO, 2) TIPO
				FROM %Table:ZZB% ZZB
				WHERE ZZB.ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel%
					AND ZZB_DOC = ''
				GROUP BY LEFT(ZZB.ZZB_RASTRO, 2)
			) RAST

		CROSS APPLY (
				SELECT TOP 10 ZZB_RASTRO, ZZB_SERVIC
				FROM %Table:ZZB% ZZB
				WHERE ZZB.ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel%
					AND ZZB_DOC = '' AND RAST.TIPO = LEFT(ZZB.ZZB_RASTRO, 2)
			) ZZB
		ORDER BY
			ZZB_RASTRO

	EndSql

	If Select('TRBZZB') > 1
		TRBZZB->(DbCloseArea())
	EndIf

	aStru := (cAliasZZB)->(dbStruct())
	cTrab := CriaTrab(aStru)
	dbUseArea(.T.,,cTrab,"TRBZZB")

	(cAliasZZB)->(dbGoTop())
	While !(cAliasZZB)->(Eof())
		RecLock('TRBZZB', .T.)

		For i := 1 to Len(aStru)
			TRBZZB->&(aStru[i, 1]) := (cAliasZZB)->&(aStru[i, 1])
		Next

		TRBZZB->(MsUnLock())
		(cAliasZZB)->(DbSkip())

	EndDo

	TRBZZB->(DbGoTop())

	aHeadZZB := {}

	For i := 1 to Len(aStru)
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(aStru[i, 1]) .and. !aStru[i, 1] $ "ZZB_SERVIC"
			aAdd(aHeadZZB,{SX3->X3_TITULO,;
				aStru[i, 1],;
				SX3->X3_TIPO,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_PICTURE} )
		Endif
	Next

	(cAliasZZB)->(DbCloseArea())

Return


/*/{Protheus.doc} AtualizaPLP
Atualiza o browse que contém as PLP do últimos 2 dias úteis
@author henrique
@since 15/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function AtualizaPLP()
	Local cTrab	:= ''
	Local aStru	:= {}
	Local i		:= 0

	Local cTransp := SuperGetMV("MV_Y189TRA",.F.,'000901/000902/000903/000703')


	If !Empty(cTransp)
		cTransp := ' AND SF2.F2_TRANSP IN ' + FormatIn(cTransp,'/')
	Else
		cTransp := " AND 1 = 1 "
	End If

	cTransp := '% '+cTransp+' %'

	BeginSql alias cAliasPLP
		SELECT
			A1_COD, A1_LOJA, A1_NOME, F2_DOC, F2_SERIE, CONVERT(DATE,F2_EMISSAO) AS F2_EMISSAO, ZZB_VOLUME, SA4.A4_COD, SA4.A4_NOME
			, SA1.A1_END, SA1.A1_COMPLEM, SA1.A1_BAIRRO, SA1.A1_EST, SA1.A1_MUN, SA1.A1_CEP, A1_CGC
			, SA1.A1_TEL, SA1.A1_DDD, A1_EMAIL
			, ZZB.ZZB_RASTRO, A4_YSERVIC
			, SF2.F2_VALBRUT, SF2.F2_VOLUME1
			, VT1_API, VT1_ORDID, VT1_SEQUEN, F2_PBRUTO * 1000 F2_PBRUTO
			, VT1_IDCART
		FROM
			%table:SF2% SF2
			JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND SA1.%NotDel% AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA
			JOIN %table:SA4% SA4 ON A4_FILIAL = %xFilial:SA4% AND SA4.%NotDel% AND SA4.A4_COD = SF2.F2_TRANSP
			JOIN %table:ZZB% ZZB ON ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel% AND ZZB.ZZB_DOC = SF2.F2_DOC AND ZZB.ZZB_SERIE = SF2.F2_SERIE
			JOIN %table:SC5% SC5 ON C5_FILIAL = %xFilial:SC5% AND SC5.%NotDel% AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE
			left JOIN %table:VT1% VT1 ON VT1_FILIAL = %xFilial:VT1% AND VT1.%NotDel% AND SC5.C5_NUM = VT1.VT1_NUMPED
 			OUTER APPLY (SELECT TOP 1 * FROM %table:VT4% VT4 WHERE VT4_FILIAL = %xFilial:VT4% AND VT4.%NotDel% AND VT4.VT4_ORDID = VT1.VT1_ORDID AND VT4_EMPFOR+VT4_FILFOR = %Exp:cLocalArm%)	VT4

		WHERE
			SF2.F2_FILIAL = %xFilial:SF2% AND SF2.%NotDel%
			AND SF2.F2_TIPO = 'N' AND SF2.F2_EMISSAO >= '20170315'
			%Exp:cTransp%
			AND ZZB.ZZB_PLP = ''
		ORDER BY
			ZZB.ZZB_RASTRO DESC, F2_DOC
	EndSql

	If Select('TRBPLP') > 1
		TRBPLP->(DbCloseArea())
	EndIf

	aStru := (cAliasPLP)->(dbStruct())
	cTrab := CriaTrab(aStru)
	dbUseArea(.T.,,cTrab,"TRBPLP")
	IndRegua("TRBPLP", cTrab, "F2_DOC+F2_SERIE",,,"Indexando registros...")

	(cAliasPLP)->(dbGoTop())
	While (cAliasPLP)->(!Eof())
		RecLock('TRBPLP', .T.)

		For i := 1 to Len(aStru)
			TRBPLP->&(aStru[i, 1]) := (cAliasPLP)->&(aStru[i, 1])
		Next

		TRBPLP->(MsUnLock())
		(cAliasPLP)->(DbSkip())
	EndDo

	TRBPLP->(DbGoTop())

	aHeadPLP := {}

	For i := 1 to Len(aStru)
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(aStru[i, 1]) //.and. !aStru[i, 1] $ "U5_OPERADO/A1_LOJA/A1_CGC/A1_EST"
			aAdd(aHeadPLP,{SX3->X3_TITULO,;
				aStru[i, 1],;
				SX3->X3_TIPO,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_PICTURE} )
		Endif
	Next

	(cAliasPLP)->(DbCloseArea())

	If oBrowserPLP <> Nil
		oBrowserPLP:Refresh()
	EndIf

Return

/*/{Protheus.doc} SlqPLPFechadas
Obtem as PLP para impressão
@author henrique
@since 12/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SlqPLPFechadas()
	Local cTrab		:= ''
	Local aStru		:= {}
	Local i			:= 0
	Local cAlias 		:= GetNextAlias()
	Local cDataFecha	:= DtoS( DataValida(dDataBase-1, .F.) )

	BeginSql alias cAlias
		SELECT
			DISTINCT ZZB_PLP, CONVERT(DATE,ZZB_FECHAM) AS ZZB_FECHAM
		FROM
			%Table:ZZB% ZZB
			JOIN %table:SC5% SC5 ON C5_FILIAL = %xFilial:SC5% AND SC5.%NotDel% AND ZZB.ZZB_DOC = SC5.C5_NOTA AND ZZB.ZZB_SERIE = SC5.C5_SERIE
			LEFT JOIN %table:VT1% VT1 ON VT1_FILIAL = %xFilial:VT1% AND VT1.%NotDel% AND SC5.C5_NUM = VT1.VT1_NUMPED
 			LEFT JOIN %table:VT4% VT4 ON VT4_FILIAL = %xFilial:VT4% AND VT4.%NotDel% AND VT4.VT4_ORDID = VT1.VT1_ORDID AND VT4_EMPFOR+VT4_FILFOR = %Exp:cLocalArm%

		WHERE
			ZZB.ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel%
			AND ZZB_FECHAM >= %Exp:cDataFecha%
		ORDER BY
			ZZB_PLP DESC

	EndSql

	If Select('TRBFEC') > 1
		TRBFEC->(DbCloseArea())
	EndIf

	aStru := (cAlias)->(dbStruct())
	cTrab := CriaTrab(aStru)
	dbUseArea(.T.,,cTrab,"TRBFEC")

	(cAlias)->(dbGoTop())
	While (cAlias)->(!Eof())
		RecLock('TRBFEC', .T.)

		For i := 1 to Len(aStru)
			TRBFEC->&(aStru[i, 1]) := (cAlias)->&(aStru[i, 1])
		Next

		TRBFEC->(MsUnLock())
		(cAlias)->(DbSkip())
	EndDo

	TRBFEC->(DbGoTop())

	aHeadFEC := {}

	For i := 1 to Len(aStru)
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(aStru[i, 1]) //.and. !aStru[i, 1] $ "U5_OPERADO/A1_LOJA/A1_CGC/A1_EST"
			aAdd(aHeadFEC,{SX3->X3_TITULO,;
				aStru[i, 1],;
				SX3->X3_TIPO,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_PICTURE} )
		Endif
	Next

	(cAlias)->(DbCloseArea())

Return

/*/{Protheus.doc} GeraRastro
Monta uma tela para obter uma sequencia de números de rastros nos correios
@author henrique
@since 05/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function GeraRastro(cServico)
	Local cRet			:= ''
	Local nI			:= 0
	Local nQuantidade	:= 30
	Local nPos			:= 0
	//Local cIncRastro	:= ''
	Local cRastro		:= ''

	Default cServico	:= SuperGetMv("MV_YSIGCOD", .F., '04669') //'41068'
	cServico := AllTrim(cServico)

	oSigep:LimpCampos()

	nPos := aScan(oSigep:aServicos, {|x|AllTrim(x[1])==cServico})

	If nPos == 0
		Aviso("Atenção",'O serviço "'+cServico+'" informado na transportadora não foi implementado ou não faz parte do contrato da empresa!',{"Voltar"})
		//FreeObj(oSigep)
		Return .F.
	EndIf

	//cIncRastro 	:= oSigep:aServicos[nPos, 3]
	nQuantidade	:= oSigep:aServicos[nPos, 5]

	TRBZZB->(DbGoTop())
	While !TRBZZB->(Eof())
		If cServico == AllTrim(TRBZZB->ZZB_SERVIC)
			Return
		EndIf

		TRBZZB->(DbSkip())
	EndDo

	oSigep:nQuantidade 	:= nQuantidade
	oSigep:cServico 		:= cServico
	cRet := oSigep:ReservarEtiquetas()

	For nI := 1 To Len(oSigep:aEtiquetas)

		cRastro := oSigep:aEtiquetas[nI, 3]
		If SubStr(cRastro, 11,1) == ' '
			cRastro := GeraDigitoVerificador(cRastro)
		EndIf

		If SubStr(cRastro, 11,1) <> ' '
			RecLock('ZZB', .T.)
				ZZB_FILIAL		:= xFilial('ZZB')
				ZZB_RASTRO		:= cRastro
				ZZB_EMISSA		:= dDataBase
				ZZB_SERVIC 	:= cServico
			ZZB->(MsUnLock())
		Else
			Aviso("Atenção",'Não foi possível obter o dígito verificador do código do Rastreio nos correios, favor tentar mais tarde!',{"Voltar"})
		EndIf

	Next

	AtualizaRastro()
	oBrowserRas:Refresh()

	//FreeObj(oSigep)

Return

/*/{Protheus.doc} GeraEtiqueta
Gerar um registro na tabela ZZB com o dados de rastreamento
@author henrique
@since 05/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraEtiqueta()

	Local aAreaZZB	:= ZZB->(GetArea())
	Local nVolume		:= max(TRBSF2->F2_VOLUME1, 1)
	Local nI			:= 0
//	Local cIncRastro	:= ''
	Local cServico	:= ''
	//Local oSigep		:= Nil

	Local aME2			:= {}
	Local oBjMEnvios 	:= MEnviosRastreamento():New()

	TRBZZB->(DbGoTop())

	cServico := AllTrim(TRBSF2->A4_YSERVIC)

	If Empty(cServico)
		Return
	EndIf

    If oBjMEnvios:IsME2(,,,TRBSF2->D2_PEDIDO)

    	aME2 := oBjMEnvios:GetAtuRastro()

		If aME2[1]

			DownloadME2(aME2[2])

		Else

			Aviso("ATENCAO", "Pedido identificado como Mercado Envios, porem ocorreu erro na busca!" + ENTER + ENTER + aME2[2], {"Ok"}, 3)

		EndIf

		SF2SQL()
		//AtualizaRastro()
		AtualizaPLP()
		SlqPLPFechadas()

		oBrowserRas:Refresh()
		oBrowseUp:Refresh()
		oBrowserPLP:Refresh()
		oBrwPLPFech:Refresh()

    Else

		//oSigep := ServSigep():New()
		oSigep:LimpCampos()

		For nI := 1 To nVolume

			DbSelectArea('ZZB')
			DbSetOrder(2)

			nPos := aScan(oSigep:aServicos, {|x|AllTrim(x[1])==cServico})

			If nPos == 0
				//FreeObj(oSigep)
				Aviso("Atenção",'O serviço "'+cServico+'" informado na transportadora não foi implementado ou não faz parte do contrato da empresa!',{"Voltar"})
				Return .F.
			EndIf

	//		cIncRastro := oSigep:aServicos[nPos, 3]
			GeraRastro(cServico)

			While ! TRBZZB->(Eof())
				If cServico == AllTrim(TRBZZB->ZZB_SERVIC)

					If ZZB->(DbSeek(xFilial('ZZB')+TRBZZB->ZZB_RASTRO))

						RecLock('ZZB', .F.)
							ZZB->ZZB_DOC		:= TRBSF2->F2_DOC
							ZZB->ZZB_SERIE	:= TRBSF2->F2_SERIE
							ZZB->ZZB_CLIENT	:= TRBSF2->A1_COD
							ZZB->ZZB_LOJA		:= TRBSF2->A1_LOJA
							ZZB->ZZB_EMISNF	:= TRBSF2->F2_EMISSAO
							ZZB->ZZB_VOLUME	:= cValToChar(nI)+'/'+ cValToChar(nVolume)

							//|Facile - Projeto Zebra
							If ZZB->(FieldPos("ZZB_DTBIP")) > 0
								ZZB->ZZB_DTBIP	:= dDataBase
								ZZB->ZZB_HRBIP	:= SubStr(Time(),1,5)
							EndIf
						ZZB->(MsUnLock())

						Exit

					EndIf

				EndIf

				TRBZZB->(DbSkip())

			EndDo

			AtualizaRastro()

		Next

		AtualizaPLP()
		SF2SQL()
		oBrowserRas:Refresh()
		oBrowseUp:Refresh()

	EndIf

	RestArea(aAreaZZB)

Return()

/*/{Protheus.doc} GeraPLP
Gera a PLP nos correios
@author henrique
@since 05/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraPLP()

	//Local oSigep		:= ServSigep():New()
	Local oSigDest	:= Nil
	Local cNota		:= ''
	Local cSerie	:= ''
	Local aAreaZZB	:= ZZB->(GetArea())
	Local cControle	:= ''
	Local aEndereco	:= {}

	oSigep:LimpCampos()

	TRBPLP->(DbGoTop())
	While !TRBPLP->(Eof())

		cNota	:= TRBPLP->F2_DOC
		cSerie	:= TRBPLP->F2_SERIE

		BeginSql alias cAliasPLP
			SELECT
				SD2.D2_PESO*1000 D2_PESO, SB1.B1_COD, SB1.B1_DESC, SB1.B1_YAPLICA, SB5.B5_CEME, B5_COMPRLC, B5_LARGLC, B5_ALTURLC
				, SD2.D2_PRCVEN, SD2.D2_TOTAL
			FROM
				%Table:SD2% SD2
				JOIN %Table:SB1% SB1 ON B1_FILIAL = %xFilial:SB1% AND SB1.%NotDel% AND SB1.B1_COD = SD2.D2_COD
				JOIN %Table:SB5% SB5 ON B5_FILIAL = %xFilial:SB5% AND SB5.%NotDel% AND SB5.B5_COD = SD2.D2_COD
				JOIN %Table:ZZB% ZZB ON ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel% AND ZZB_DOC = SD2.D2_DOC AND ZZB_SERIE = SD2.D2_SERIE
				LEFT JOIN %table:VT1% VT1 ON VT1_FILIAL = %xFilial:VT1% AND VT1.%NotDel% AND VT1.VT1_NUMPED = SD2.D2_PEDIDO
 				LEFT JOIN %table:VT4% VT4 ON VT4_FILIAL = %xFilial:VT4% AND VT4.%NotDel% AND VT4.VT4_ORDID = VT1.VT1_ORDID AND VT4_EMPFOR+VT4_FILFOR = %Exp:cLocalArm%
			WHERE
				SD2.D2_FILIAL = %xFilial:SD2% AND SD2.%NotDel%
				AND SD2.D2_DOC = %Exp:cNota%
				AND SD2.D2_SERIE = %Exp:cSerie%
			ORDER BY
				SD2.D2_ITEM

		EndSql

		oSigDest := SigPLPDestinatario():New()

		oSigDest:cTipoObj		:= '002' 				// 001 - Envelope ; 002 - Pacote/Caixa; 003 - Rolo / Cilindro
		oSigDest:cCliente		:= TRBPLP->A1_COD
		oSigDest:cNomeCli		:= TRBPLP->A1_NOME
		oSigDest:cNota		:= TRBPLP->F2_DOC
		oSigDest:cSerie		:= TRBPLP->F2_SERIE
		oSigDest:cEtiqueta	:= TRBPLP->ZZB_RASTRO

	   aEndereco	:= TrataEnd(TRBPLP->A1_END)

		oSigDest:cEndCli		:= aEndereco[1]
		oSigDest:cNumCli		:= aEndereco[2]
		oSigDest:cComplemento	:= TRBPLP->A1_COMPLEM
		oSigDest:cBairro		:= TRBPLP->A1_BAIRRO
		oSigDest:cMunicipio		:= TRBPLP->A1_MUN
		oSigDest:cUF			:= TRBPLP->A1_EST
		oSigDest:cCEP			:= TRBPLP->A1_CEP
		oSigDest:nValorNota		:= TRBPLP->F2_VALBRUT
		oSigDest:nVolume		:= TRBPLP->F2_VOLUME1

		If Len(AllTrim(TRBPLP->A1_DDD)) > 2
			oSigDest:cTelefone	:= TRBPLP->(SubStr(AllTrim(A1_DDD), 2, 2) + AllTrim(A1_TEL))

		Else
			oSigDest:cTelefone	:= TRBPLP->(AllTrim(A1_DDD) + AllTrim(A1_TEL))

		EndIf

		oSigDest:cEmail		:= TRBPLP->A1_EMAIL
		oSigDest:nCubagem		:= 0
		oSigDest:nPeso		:= TRBPLP->F2_PBRUTO
		oSigDest:cDescprod	:= (cAliasPLP)->B5_CEME
		oSigDest:nValor		:= TRBPLP->F2_VALBRUT
		oSigDest:nAltura		:= (cAliasPLP)->B5_ALTURLC
		oSigDest:nLargura		:= (cAliasPLP)->B5_LARGLC
		oSigDest:nCompr		:= (cAliasPLP)->B5_COMPRLC
		oSigDest:cServPostag	:= iif(Empty(TRBPLP->A4_YSERVIC), '41068', AllTrim(TRBPLP->A4_YSERVIC))
		oSigDest:nDiamentro	:= 0

		aAdd(oSigep:aDestinatarios, oSigDest)

		TRBPLP->(DbSkip())

		(cAliasPLP)->(DbCloseArea())

	EndDo

	cControle := NumeControle()
	oSigep:cNumControle := cControle

	If oSigep:GerarPLP()

		DbSelectArea('ZZB')
		DbSetOrder(2)

		Begin Transaction
			TRBPLP->(DbGoTop())

			While !TRBPLP->(Eof())

				If ZZB->(DbSeek(xFilial('ZZB')+TRBPLP->ZZB_RASTRO))
					RecLock('ZZB', .F.)
						ZZB->ZZB_PLP 		:= oSigep:cNumPLP
						ZZB->ZZB_FECHAM	:= dDataBase
						ZZB->ZZB_CONTRO	:= cControle
					ZZB->(MsUnLock())

				EndIf

				RecLock('VT7', .T.)

					VT7->VT7_FILIAL	:= xFilial('VT7')
					VT7->VT7_ORDID	:= TRBPLP->VT1_ORDID
					VT7->VT7_SEQUEN	:= TRBPLP->VT1_SEQUEN
					VT7->VT7_API	:= TRBPLP->VT1_API
					VT7->VT7_DOC	:= TRBPLP->F2_DOC
					VT7->VT7_SERIE	:= TRBPLP->F2_SERIE
					VT7->VT7_CODRAS	:= TRBPLP->ZZB_RASTRO

				VT7->(MsUnLock())

				TRBPLP->(DbSkip())

			EndDo

			RestArea(aAreaZZB)

		End Transaction

		If MsgNOYes('Deseja imprimir a PLP?')
			ImpRelPLP(oSigep:cNumPLP, .T.)
		EndIf

		SlqPLPFechadas()
		AtualizaPLP()

		oBrowserRas:Refresh()
		oBrowseUp:Refresh()

	Else
		Aviso("Atenção","A PLP não foi gerada, favor tentar novamente!",{"Voltar"})

	EndIf

	TRBPLP->(DbGoTop())

Return

/*/{Protheus.doc} ImpRelPLP
Imprime o relatório de PLP
@author henrique
@since 06/12/2016
@version 1.0
@param cPLP, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ImpRelPLP(cPLP, lImpTodos)

	Local oPrint 	:= TMSPrinter():New("Correios PLP")

	Local oFont09 		:= TFont():New("ARIAL",,009,,.F.,,,,,.F.,.F.)
	Local oFont09N 		:= TFont():New("ARIAL",,009,,.T.,,,,,.F.,.F.)
	Local nI 				:= 0
	Local lImpBoxRastro	:= .T.
	Local nPosInc			:= 0
	Local cAlias			:= GetNextAlias()
	Local nMaxRastro		:= 13
	Local nMaxRodape		:= 9
	Local nQdeIens		:= 0
	Local cTotalizador	:= ''
	Local nPagina			:= 0
	Local nTotalLinha		:= 0
	Local nTotalPagina	:= 0
	Local aTotalPLP		:= {}
	Local cServico		:= ''
	Local cDescServ		:= ''
	Local lImpLista		:= SuperGetMv("MV_YIMPLP", .F., .T.)
	Local aME2			:= {}
	Local oBjMEnvios 	:= MEnviosRastreamento():New()

	Default cPLP  := ''
	Default lImpTodos := .F.

	If Empty(cPLP)
		If TRBFEC->(Eof())
			Return
		Else
			cPLP := TRBFEC->ZZB_PLP
		EndIf
	EndIf

    If oBjMEnvios:IsME2(,,cPLP)

    	aME2 := oBjMEnvios:GetAtuRastro(.F.)

		If aME2[1]

			DownloadME2(aME2[2])

		Else

			Aviso("ATENCAO", "Pedido identificado como Mercado Envios, porem ocorreu erro na busca!" + ENTER + ENTER + aME2[2], {"Ok"}, 3)

		EndIf

    	Return()

    EndIf

	BeginSql alias cAlias
		SELECT
			ZZB.ZZB_RASTRO, ZZB_VOLUME, SA1.A1_CEP, F2_PBRUTO * 1000 F2_PBRUTO, SF2.F2_VALBRUT, F2_DOC, F2_SERIE, SF2.F2_VOLUME1
			,  A4_YSERVIC, SA4.A4_NOME, A1_COD, A1_LOJA, A1_NOME
		FROM
			%table:SF2% SF2
			JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND SA1.%NotDel% AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA
			JOIN %table:SA4% SA4 ON A4_FILIAL = %xFilial:SA4% AND SA4.%NotDel% AND SA4.A4_COD = SF2.F2_TRANSP
			JOIN %table:ZZB% ZZB ON ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel% AND ZZB.ZZB_DOC = SF2.F2_DOC AND ZZB.ZZB_SERIE = SF2.F2_SERIE
		WHERE
			SF2.F2_FILIAL = %xFilial:SF2% AND SF2.%NotDel%
			AND ZZB_PLP = %Exp:cPLP%
		ORDER BY
			F2_DOC

	EndSql

	If lImpLista
		oPrint:SetLandscape() 		// Paisagem
		//oPrint:Setup()
		oPrint:StartPage()
	EndIf

	nPagina := 0
	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())
		nTotalLinha += max(1, (cAlias)->F2_VOLUME1)
		(cAlias)->(DbSkip())

	EndDo

	nTotalPagina := NoRound( nTotalLinha / nMaxRastro, 0)

	//Caso uma página tem memos itens que o máximo permitido
	nTotalPagina += iif(mod( nTotalLinha , nMaxRastro) > 0 , 1, 0)

	//Caso a última página tenha mesmo itens que o máximo permitido, porém tenha mais que o máximo para impressão do rodapé
	nTotalPagina += iif(mod( nTotalLinha , nMaxRastro) > nMaxRodape , 1, 0)


	nQdeIens := 0

   	oSigep:LimpCampos()

	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())

		cServico := AllTrim((calias)->A4_YSERVIC)

		nPos := aScan(oSigep:aServicos, {|x|AllTrim(x[1])==cServico})

		If nPos == 0
			//FreeObj(oSigep)
			Aviso("Atenção",'O serviço "'+cServico+'" informado na transportadora não foi implementado ou não faz parte do contrato da empresa!',{"Voltar"})
			Return .F.
		EndIf

		cDescServ := oSigep:aServicos[nPos, 4]

		If lImpLista
		//Se passar da quantidade de itens por página, pula para a próxima
			If nQdeIens  == nMaxRastro
				nQdeIens := 0
				oPrint:EndPage()
				oPrint:StartPage()
				lImpBoxRastro := .T.
			EndIf

			If nQdeIens == 0
				nPagina ++
				MontaCab(oPrint, cPLP, cTotalizador, nPagina, nTotalPagina)
			EndIF

			nQdeIens ++
			nPosInc := ((nQdeIens - 1) * 130 )

			If lImpBoxRastro
				oPrint:Box( 0616 + nPosInc , 0060, 0746+ nPosInc, 3312 )
			EndIf

			oPrint:Say( 0640 + nPosInc, 0070, (calias)->ZZB_RASTRO			,oFont09N,1400 )
			oPrint:Say( 0690 + nPosInc, 0070, 'Serviço:' + cServico			,oFont09,1400 )
			oPrint:Say( 0640 + nPosInc, 0350, (calias)->A1_CEP				,oFont09N,1400 )
			oPrint:Say( 0640 + nPosInc, 0570, Transform((calias)->F2_PBRUTO,"@E 999999"),oFont09N,1400 )
			oPrint:Say( 0640 + nPosInc, 0710, "S"								,oFont09,1400 )
			oPrint:Say( 0640 + nPosInc, 0790, "N"								,oFont09,1400 )
			oPrint:Say( 0640 + nPosInc, 0880, "S"								,oFont09,1400 )
			oPrint:Say( 0640 + nPosInc, 1040, Transform((calias)->F2_VALBRUT,"@E 999,999,999.99") ,oFont09,1400 )
			oPrint:Say( 0640 + nPosInc, 1350, (calias)->F2_DOC				,oFont09,1400 )
			oPrint:Say( 0690 + nPosInc, 1500, 'Observação:'					,oFont09,1400 )
			//oPrint:Say( 0640 + nPosInc, 1630, cValToChar(nI)+'/'+ cValToChar((calias)->F2_VOLUME1)		,oFont09,1400 )
			oPrint:Say( 0640 + nPosInc, 1630, (calias)->ZZB_VOLUME			,oFont09,1400 )
			oPrint:Say( 0640 + nPosInc, 1800, (calias)->A1_NOME				,oFont09,1400 )

			lImpBoxRastro := !lImpBoxRastro
		EndIf

		nPosPlP := 0

		If Len(aTotalPLP) > 0
			nPosPlP := aScan(aTotalPLP, {|x|x[1] == cServico })
		EndIf

		If nPosPlP > 0
			aTotalPLP[nPosPlP, 3] += 1
		Else
			aAdd(aTotalPLP, {cServico, cDescServ, 1})
		EndIf

		(cAlias)->(DbSkip())

	EndDo

	//FreeObj(oSigep)

	If lImpLista
		//O sistema cabe  rastros com o rodapé por página por isso se tiver mais de 8 deverá pula a página
		If nQdeIens > nMaxRodape
			oPrint:EndPage()
			oPrint:StartPage()
			nPagina++
			MontaCab(oPrint, cPLP, cTotalizador, nPagina, nTotalPagina)
		EndIf

		oPrint:Box( 1786, 0060, 2310, 3312 )
		oPrint:Say( 1801, 0070,"Totalizador:"					,oFont09N,1400 )
		oPrint:Say( 1801, 0420,""					,oFont09 ,1400 )

		oPrint:Say( 1810, 2350,"Carinho e Assinatura / Matrícula dos correios"	, oFont09N ,1400 )
		oPrint:Say( 2100, 2350,"________________________________________"	,oFont09N ,1400 )

		oPrint:Say( 1830, 0830,"APRESENTAR ESTE LISTA EM CASO DE PEDIDO DE INFORMAÇÕES"	,oFont09N ,1400 )
		oPrint:Say( 1900, 0830,"Estou ciente do disposto na cláusula terceira do contrato de prestação de Serviço."	,oFont09N ,1400 )

		oPrint:Say( 2050, 0900,"_____________________________________________________________________"	,oFont09N ,1400 )
		oPrint:Say( 2120, 1280,"ASSINATURA DO REMETENTE"					,oFont09N ,1400 )
		oPrint:Say( 2190, 1150,"Obs: 1ª via Unidade de Postagem e 2ª via cliente"					,oFont09N ,1400 )

		oPrint:EndPage()
	 	//oPrint:Preview()
	  	oPrint:Print(, 2)

	EndIf

	FreeObj(oPrint)

	//Rel_PLP_Barra(cPLP, aTotalPLP)
	Rel2_PLP_Barra(cPLP, aTotalPLP)

    If lImpTodos
	    ImpEtiqueta(cPLP)
	    ImpAR(cPLP)
	EndIf

Return

/*/{Protheus.doc} MontaCab
Monta o cabeçalho do relatório PLP
@author henrique
@since 12/12/2016
@version 1.0
@param oPrint, objeto, (Descrição do parâmetro)
@param cPLP, character, (Descrição do parâmetro)
@param cTotalizador, character, (Descrição do parâmetro)
@param nPagina, numérico, (Descrição do parâmetro)
@param nTotalPagina, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MontaCab(oPrint, cPLP, cTotalizador, nPagina, nTotalPagina)
	Local oFont09N 		:= TFont():New("ARIAL",,009,,.T.,,,,,.F.,.F.)
	Local oFont10 		:= TFont():New("ARIAL",,010,,.F.,,,,,.F.,.F.)
	Local oFont15 		:= TFont():New("ARIAL",,015,,.F.,,,,,.F.,.F.)
	Local oFont18 		:= TFont():New("ARIAL",,018,,.F.,,,,,.F.,.F.)
	//Local oAcesso			:= SigAcesso():New()

	oPrint:SayBitmap( 020,050,"\Imagens\logo_correios.png",400,120 )  //"C:\Temp\Correios\logo_correios.png"

	oPrint:Say( 0070, 0610,"EMPRESA BRASILEIRA DE CORREIOS E TELÉGRAFOS",oFont15,1400 )

	//Cabeçalho
	oPrint:Box( 0225, 0060, 0556, 3312 )

	oPrint:Say( 0240, 1300,"LISTA DE POSTAGEM"			,oFont18,1400 )
	oPrint:Say( 0320, 0070,"N° da Lista:"					,oFont09N,1400 )
	oPrint:Say( 0320, 0420,cPLP								,oFont10,1400 )

	oPrint:Say( 0370, 0070,"Contrato:"						,oFont09N,1400 )
	oPrint:Say( 0370, 0420, oSigep:cContrato				,oFont10,1400 )

	oPrint:Say( 0430, 0070,"Cód Administrativo:"			,oFont09N,1400 )
	oPrint:Say( 0430, 0420, oSigep:cCodAdm				,oFont10,1400 )

	oPrint:Say( 0490, 0070,"Cartão:"						,oFont09N,1400 )
	oPrint:Say( 0490, 0420, oSigep:cCartao				,oFont10,1400 )

	//2 COLUNA
	oPrint:Say( 0320, 0850,"Remetene:"						,oFont09N,1400 )
	oPrint:Say( 0320, 1060,SM0->M0_NOMECOM					,oFont10,1400 )

	oPrint:Say( 0370, 0850,"Cliente:"						,oFont09N,1400 )
	oPrint:Say( 0370, 1060,"VIXPAR"							,oFont10,1400 )

	oPrint:Say( 0430, 0850,"Endereço:"						,oFont09N,1400 )
	oPrint:Say( 0430, 1060,AllTrim(SM0->M0_ENDCOB)+'-'+ AllTrim(SM0->M0_BAIRCOB) ,oFont10,1400 )

	oPrint:Say( 0490, 0850,AllTrim(SM0->M0_CIDCOB)+'/'+SM0->M0_ESTCOB +;
							'- CEP : ' + SM0->M0_CEPCOB ,oFont10,1400 )

	//3 COLUNA
	oPrint:Say( 0490, 2730,"Telefone:"						,oFont09N,1400 )
	oPrint:Say( 0490, 2900,SM0->M0_TEL						,oFont10,1400 )

	//Titulos Rastro
	oPrint:Say( 0570, 0070, "N° do Objeto"					,oFont09N,1400 )
	oPrint:Say( 0570, 0350, "CEP"							,oFont09N,1400 )
	oPrint:Say( 0570, 0580, "Peso"							,oFont09N,1400 )
	oPrint:Say( 0570, 0700, "AR"							,oFont09N,1400 )
	oPrint:Say( 0570, 0790, "MP"							,oFont09N,1400 )
	oPrint:Say( 0570, 0880, "VD"							,oFont09N,1400 )
	oPrint:Say( 0570, 1040, "Valor Declarado"				,oFont09N,1400 )
	oPrint:Say( 0570, 1350, "Nota Fiscal"					,oFont09N,1400 )
	oPrint:Say( 0570, 1600, "Volume"						,oFont09N,1400 )
	oPrint:Say( 0570, 1800, "Destinatário"					,oFont09N,1400 )

	oPrint:Say( 2340, 0070, "Data de emissão:"+ DTOC(dDataBase)						,oFont09N ,1400 )
	oPrint:Say( 2340, 3000, "Página: "+ cValToChar(nPagina) + ' de '+ cValToChar(nTotalPagina),oFont09N ,1400 )

	//FreeObj(oAcesso)

Return

/*/{Protheus.doc} ImpAR
Relatório do voucher dos correios
@author henrique
@since 12/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ImpAR(cPLP, cTipo)
	Local oPrinter 	:= TMSPrinter():New("Correios PLP")
	Local nQdeEtiq	:= 0
	Local nPos			:= 0
	Local nPosBarra	:= 0
	Local nI			:= 0
	Local cImag001	:=	"\Imagens\logo_correios.png"
	Local cImag002	:=	"\Imagens\Cole_Aqui.png"
	Local oArial44  	:=	TFont():New("Arial",,22,,.F.,,,,,.F.,.F.)
	Local oFont11		:=	TFont():New("",,11,,.T.,,,,,.F.,.F.)
	Local oFont09		:=	TFont():New("",,09,,.T.,,,,,.F.,.F.)
	Local oFont08  	:=	TFont():New("",,08,,.F.,,,,,.F.,.F.)
	Local oFont05		:=	TFont():New("",,05,,.T.,,,,,.F.,.F.)
	Local cRastrosSel	:= ''
	Local cAlias		:= Nil
	Local cRastro		:= ''
	Local aEndere		:= {}
	//Local oAcesso		:= SigAcesso():New(.F.)
  	Local aME2			:= {}
	Local oBjMEnvios 	:= MEnviosRastreamento():New()

   	Default cPLP 	:= ''
	Default cTipo := 1

	If Empty(cPLP)
		If TRBFEC->(Eof())
			Return
		Else
			cPLP := TRBFEC->ZZB_PLP
		EndIf
	EndIf

    If oBjMEnvios:IsME2(,,cPLP)

    	aME2 := oBjMEnvios:GetAtuRastro(.F.)

		If aME2[1]

			DownloadME2(aME2[2])

		Else

			Aviso("ATENCAO", "Pedido identificado como Mercado Envios, porem ocorreu erro na busca!" + ENTER + ENTER + aME2[2], {"Ok"}, 3)

		EndIf

    	Return()

    EndIf



	cAlias := GetNextAlias()

	BeginSql Alias cAlias
		SELECT
			Cast('  ' as Char(2)) as ZZB_OK
		   , ZZB.ZZB_RASTRO
			, A1_COD, A1_LOJA, A1_NOME, A1_END, A1_BAIRRO, SA1.A1_MUN, SA1.A1_EST, SA1.A1_COMPLEM, A1_CEP
			, SF2.F2_VOLUME1
		FROM
			%table:ZZB% ZZB
			JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND SA1.%NotDel% AND SA1.A1_COD = ZZB.ZZB_CLIENT AND SA1.A1_LOJA = ZZB.ZZB_LOJA
			JOIN %table:SF2% SF2 ON SF2.F2_FILIAL = %xFilial:SF2% AND SF2.%NotDel% AND SF2.F2_DOC = ZZB.ZZB_DOC AND SF2.F2_SERIE = ZZB.ZZB_SERIE
		WHERE
			ZZB.ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel%
			AND ZZB_PLP = %Exp:cPLP%
	EndSql


    If cTipo == 2 //Seleção de registros
		If !TelaSelecao(cAlias, 'ZZB_OK', 'ZZB_RASTRO', @cRastrosSel)
			(cAlias)->(DbCloseArea())
			Return

		EndIf

	EndIf

	oPrinter:SetPortrait()  	// Retrato
	//oPrinter:Setup()
	oPrinter:StartPage()

	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())
		If cTipo == 2
	  		//Imprime só o que está selecionado
	  		If !(cAlias)->ZZB_RASTRO $ cRastrosSel
	  			(cAlias)->(DbSkip())
	  			Loop
	  		EndIf

	  	EndIf

		If nQdeEtiq >= 3
			oPrinter:EndPage()
			oPrinter:StartPage()
			nPos 		:= 0
			nQdeEtiq 	:= 0
		EndIf

		nQdeEtiq ++

		nPos := (nQdeEtiq - 1) * 1168

		oPrinter:SayBitMap(0025+nPos,0148,cImag001,0293,0068)
		oPrinter:SayBitMap(0211+nPos,0049,cImag002,0056,0183)
		oPrinter:SayBitMap(0826+nPos,0049,cImag002,0056,0183)

		oPrinter:Box(0011+nPos,0122,1155+nPos,2450)
		oPrinter:Box(0011+nPos,0122,0111+nPos,2450)
		oPrinter:Box(0111+nPos,2003,0711+nPos,2450)
		oPrinter:Box(0711+nPos,2003,1155+nPos,2450)

		oPrinter:Box(0011+nPos,0037,1155+nPos,0108)
		oPrinter:Box(0111+nPos,1254,0977+nPos,2003)
		oPrinter:Box(0915+nPos,0122,0977+nPos,1254)
		oPrinter:Box(0977+nPos,0122,1065+nPos,1579)
		oPrinter:Box(0977+nPos,1579,1065+nPos,2003)
		oPrinter:Box(1065+nPos,1579,1155+nPos,2003)

		oPrinter:Say(0018+nPos,0580, "SIGEP",oArial44,,0)
		oPrinter:Say(0015+nPos,0899, "AVISO DE",oFont11,,0)
		oPrinter:Say(0058+nPos,0901, "RECEBIMENTO",oFont11,,0)
		oPrinter:Say(0033+nPos,1274, "CONTRATO "+oSigep:cContrato,oFont11,,0)

		aEndere := TrataEnd(AllTrim((cAlias)->A1_END))

		oPrinter:Say(0130+nPos,0140,"DESTINATARIO:"		, oFont09,,0)
		oPrinter:Say(0180+nPos,0140, AllTrim((cAlias)->A1_NOME)		, oFont09,,0)
		oPrinter:Say(0230+nPos,0140, aEndere[1]+', '+aEndere[2]		,oFont09,,0)
		oPrinter:Say(0280+nPos,0140, AllTrim((cAlias)->A1_BAIRRO)	,oFont09,,0)
		oPrinter:Say(0330+nPos,0140, AllTrim((cAlias)->A1_CEP)+ '  '+AllTrim((cAlias)->A1_MUN) + '-'+ AllTrim((cAlias)->A1_EST), oFont09,,0)

		//           Centimetros              milimetros
		nPosBarra := 3.9+((nQdeEtiq-1)*10) - ((nQdeEtiq-1)*0.1)
		cRastro := AllTrim((cAlias)->ZZB_RASTRO)

		cSigla 	:= SubStr(cRastro, 1, 2)
		cRastro 	:= StrTran(cRastro, 'BR', '')
		cRastro 	:= StrTran(cRastro, cSigla, 'AR')+cSigla

		oPrinter:Say(0423+nPos,0526, cRastro	,oFont09,,0)
		MSBAR3('CODE128',nPosBarra,2.6, cRastro, oPrinter,.F.,,.T.,0.030,1,.F.,oFont05,'CODE128',.F.)

		oPrinter:Say(0630+nPos,0140, "REMETENTE: "+AllTrim(SM0->M0_NOMECOM)	, oFont09,,0)
		oPrinter:Say(0680+nPos,0140, "ENDEREÇO PARA DEVOLUÇÃO DO OBJETO:"		, oFont09,,0)
		oPrinter:Say(0730+nPos,0140, AllTrim(SM0->M0_ENDCOB)					, oFont09,,0)
		oPrinter:Say(0780+nPos,0140, AllTrim(SM0->M0_COMPCOB)+', '+ AllTrim(SM0->M0_BAIRCOB)					, oFont09,,0)
		oPrinter:Say(0830+nPos,0140, SM0->M0_CEPCOB +'  '+ AllTrim(SM0->M0_CIDCOB)+'-'+SM0->M0_ESTCOB  		, oFont09,,0)
		oPrinter:Say(0127+nPos,1289, "TENTATIVAS DE ENTREGA",oFont08,,0)

		oPrinter:Say(0200+nPos,1290,"1º _____/_____/_____       ______:______ h",oFont08,,0)
		oPrinter:Say(0275+nPos,1290,"2º _____/_____/_____       ______:______ h",oFont08,,0)
		oPrinter:Say(0350+nPos,1290,"3º _____/_____/_____       ______:______ h",oFont08,,0)
		oPrinter:Say(0576+nPos,1297,"MOTIVO DE DEVOLUÇÃO:",oFont08,,0)

		oPrinter:Box(0640+nPos,1303,0687+nPos,1350)
		oPrinter:Box(0700+nPos,1303,0747+nPos,1350)
		oPrinter:Box(0760+nPos,1303,0807+nPos,1350)
		oPrinter:Box(0820+nPos,1303,0867+nPos,1350)
		oPrinter:Box(0880+nPos,1303,0927+nPos,1350)

		oPrinter:Box(0640+nPos,1647,0687+nPos,1694)
		oPrinter:Box(0700+nPos,1647,0747+nPos,1694)
		oPrinter:Box(0760+nPos,1647,0807+nPos,1694)
		oPrinter:Box(0820+nPos,1647,0867+nPos,1694)

		oPrinter:Say(0642+nPos,1318,"1",oFont08,,0)
		oPrinter:Say(0702+nPos,1318,"2",oFont08,,0)
		oPrinter:Say(0762+nPos,1318,"3",oFont08,,0)
		oPrinter:Say(0822+nPos,1318,"4",oFont08,,0)
		oPrinter:Say(0882+nPos,1318,"9",oFont08,,0)

		oPrinter:Say(0642+nPos,1662,"5",oFont08,,0)
		oPrinter:Say(0702+nPos,1662,"6",oFont08,,0)
		oPrinter:Say(0762+nPos,1662,"7",oFont08,,0)
		oPrinter:Say(0822+nPos,1662,"8",oFont08,,0)

		oPrinter:Say(0655+nPos,1365,"Modou-se",oFont05,,0)
		oPrinter:Say(0715+nPos,1365,"Endereço insuficiente",oFont05,,0)
		oPrinter:Say(0775+nPos,1365,"Não Existe o Número",oFont05,,0)
		oPrinter:Say(0835+nPos,1365,"Desconhecido",oFont05,,0)
		oPrinter:Say(0900+nPos,1365,"Outros ______________________________",oFont05,,0)

		oPrinter:Say(0655+nPos,1713,"Recusado",oFont05,,0)
		oPrinter:Say(0715+nPos,1713,"Não Procurado",oFont05,,0)
		oPrinter:Say(0775+nPos,1713,"Ausente",oFont05,,0)
		oPrinter:Say(0835+nPos,1713,"Falecido",oFont05,,0)

		oPrinter:Say(0130+nPos,2175,"CARIMBO",oFont05,,0)
		oPrinter:Say(0160+nPos,2120,"UNIDADE DE ENTREGA",oFont05,,0)
		oPrinter:Say(0719+nPos,2048,"REBRICA E MATRÍCULA DO CARTEIRO",oFont05,,0)
		oPrinter:Say(0920+nPos,0135,"DECLARAÇÃO DE CONTEÚDO",oFont05,,0)
		oPrinter:Say(0984+nPos,0135,"ASSINATURA DO RECEBEDOR",oFont05,,0)
		oPrinter:Say(1071+nPos,0135,"NOME LEGÍVEL DO RECEBEDOR",oFont05,,0)
		oPrinter:Say(0984+nPos,1592,"DATA DE ENTREGA",oFont05,,0)
		oPrinter:Say(1071+nPos,1592,"Nº DOC. DE IDENTIDADE",oFont05,,0)

    	(cAlias)->(DbSkip())
 	EndDo

	oPrinter:EndPage()
	//oPrinter:Preview()
	oPrinter:Print()

   	(cAlias)->(DbCloseArea())

   	FreeObj(oPrinter)

Return

/*/{Protheus.doc} ImpEtiqueta
Imprime a etiqueta dos correios
@author henrique
@since 12/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ImpEtiqueta(cPLP, cTipo)
	Local oFont03  	:=	TFont():New("Times New roman",,01,,.F.,,,,,.F.,.F.)
	Local oFont05  	:=	TFont():New("Arial",,05,,.F.,,,,,.F.,.F.)
	Local oFont06N  	:=	TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Local oFont08  	:=	TFont():New("Arial",,08,,.F.,,,,,.F.,.F.)
	Local oFont13  	:=	TFont():New("Arial",,13,,.F.,,,,,.F.,.F.)
	Local oFont13N  	:=	TFont():New("Arial",,13,,.T.,,,,,.F.,.F.)

	Local nPosC 		:= 0
	Local nPosL 		:= 0
	Local nQde			:= 0
	Local nPosBarraL	:= 0
	Local nPosBarraC	:= 0
	Local nPosDML		:= 0
	Local nPosDMC		:= 0
	Local cImag001	:= '\Imagens\lgrl.bmp'
	Local cImag002	:=	''// "\Imagens\PAC.png"
//	Local cImag003	:=	"\Imagens\SEDEX.png"
	Local cAlias		:= ''
	Local cPeso		:= ''
	Local cCodDtMatr	:= ''
	Local cRastrosSel	:= ''
	Local nJ 			:= 0
	//Local oSigep		:= Nil
	Local nPos			:= 0
	Local oBjMEnvios 	:= MEnviosRastreamento():New()
	Local aME2			:= {}
	Local cTransp := SuperGetMV("MV_Y189TRA",.F.,'000901/000902/000903/000703')

	//|Facile - Projeto Zebra |
	Local nImpEsc		:= 0
	Local cLocImp		:= Space(TamSX3("CB5_CODIGO")[1])
	Local cCodPAC		:= SuperGetMV("MV_YCONPAC",.F.,'41068,41211,04669')
	Local lZebra		:= .F.
	Local oObjImprime	:= TFZImprimeEtiqueta():New()
	Local aArea			:= {}
	Local aAreaSC5		:= {}
	Local aAreaSA1		:= {}

	Default cPLP 		:= ''
	Default cTipo 	:= 1

	If !Empty(cTransp)
		cTransp := ' AND SF2.F2_TRANSP IN ' + FormatIn(cTransp,'/')
	Else
		cTransp := " AND 1 = 1 "
	End If

	cTransp := '% '+cTransp+' %'


	cImag001 := ImagEmp(cImag001)

	If Empty(cPLP)
		If TRBFEC->(Eof())
			Return
		Else
			cPLP := TRBFEC->ZZB_PLP
		EndIf
	EndIf

	//|Permite imprimir a etiqueta na Zebra |
	//nImpEsc	:= Aviso("Impressão de Etiqueta", "Favor selecionar o tipo de impressão da Etiqueta.", {"Zebra","Laser","Fechar"}, 1)
	If Empty(cImpZebra)
		nImpEsc := 2
	Else
		nImpEsc := 1
	EndIf

	//|Escolhido impressora Zebra |
	If nImpEsc == 1

		lZebra	:= .T.

	EndIf

    If oBjMEnvios:IsME2(,,cPLP)

    	aME2 := oBjMEnvios:GetAtuRastro(.F.,lZebra)

		If aME2[1]

			//|Imprime a Etiqueta ZPL |
			If lZebra

				oObjImprime:cPrinter	:= cImpZebra
				oObjImprime:cEtiqZPL	:= aME2[2]
				If oObjImprime:ImprimeZPL()

					MsgInfo("Etiqueta impressa com sucesso na Zebra!!",FunName())

				EndIf

			Else
				DownloadME2(aME2[2])
			EndIf

		Else

			Aviso("ATENCAO", "Pedido identificado como Mercado Envios, porem ocorreu erro na busca!" + ENTER + ENTER + aME2[2], {"Ok"}, 3)

		EndIf

    	Return()

    EndIf

	dbSelectArea("ZZB")

	cAlias := GetNextAlias()

	BeginSql alias cAlias
		SELECT
			Cast('  ' as Char(2)) as ZZB_OK
		   , ZZB.ZZB_RASTRO, ZZB.R_E_C_N_O_ AS RECZZB
		   , A1_NOME, SA1.A1_CEP, SA1.A1_END, A1_BAIRRO, SA1.A1_MUN, SA1.A1_EST, SA1.A1_COMPLEM, A1_DDD, A1_TEL, A1_FILIAL, A1_COD, A1_LOJA
		   , SF2.F2_DOC, SF2.F2_PBRUTO * 1000 F2_PBRUTO, SF2.F2_VOLUME1, F2_VALBRUT
		   , SC5.C5_FILIAL, SC5.C5_NUM
		   , A4_YSERVIC
		FROM
			%table:SF2% SF2
			JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND SA1.%NotDel% AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA
			JOIN %table:SA4% SA4 ON A4_FILIAL = %xFilial:SA4% AND SA4.%NotDel% AND SA4.A4_COD = SF2.F2_TRANSP
			JOIN %table:ZZB% ZZB ON ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel% AND ZZB.ZZB_DOC = SF2.F2_DOC AND ZZB.ZZB_SERIE = SF2.F2_SERIE
			JOIN %table:SC5% SC5 ON C5_FILIAL = %xFilial:SC5% AND SC5.%NotDel% AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE
		WHERE
			SF2.F2_FILIAL = %xFilial:SF2% AND SF2.%NotDel%
			AND SF2.F2_TIPO = 'N' AND SF2.F2_EMISSAO >= '20170315'
			%Exp:cTransp%
			AND ZZB.ZZB_PLP = %Exp:cPLP%
		ORDER BY
			ZZB_RASTRO
	EndSql

	If cTipo == 2 //Seleção de registros
		If !TelaSelecao(cAlias, 'ZZB_OK', 'ZZB_RASTRO', @cRastrosSel)
			(cAlias)->(DbCloseArea())
			Return

		EndIf

	EndIf

	If !lZebra
		lAdjustToLegacy := .T. //.F.
		lDisableSetup := .T.
		oPrinter := FWMSPrinter():New('Etiqueta', IMP_SPOOL, lAdjustToLegacy, , lDisableSetup)
		oPrinter:SetResolution(100)
		oPrinter:SetPortrait()
		oPrinter:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressão em IMP_PDF

		oPrinter:StartPage()
	EndIf

  	(cAlias)->(DbGoTop())
  	//oSigep := ServSigep():New()

   	oSigep:LimpCampos()
  	While !(cAlias)->(Eof())

		  If cTipo == 2 //Seleção
  			//Imprime só o que está selecionado
  			If !(cAlias)->ZZB_RASTRO $ cRastrosSel
  				(cAlias)->(DbSkip())
  				Loop
  			EndIf

  		EndIf

		//|Facile - Projeto Zebra
		ZZB->(dbGoTo((cAlias)->RECZZB))

		If ZZB->(Recno()) == (cAlias)->RECZZB

			RecLock("ZZB",.F.)
			If ZZB->(FieldPos("ZZB_DTPRIN")) > 0
				ZZB->ZZB_DTPRIN	:= dDataBase
				ZZB->ZZB_HRPRIN	:= SubStr(Time(),1,5)
			EndIf
			ZZB->(MsUnLock())

		EndIf

		//|Impressão na Zebra |
		If lZebra

			aArea			:= GetArea()
			aAreaSC5		:= SC5->(GetArea())
			aAreaSA1		:= SA1->(GetArea())

			oObjImprime:LimpVar()

			oObjImprime:cChvSC5			:= (cAlias)->C5_FILIAL + (cAlias)->C5_NUM
			oObjImprime:nSC5Indice		:= 1
			oObjImprime:cChvSA1			:= (cAlias)->A1_FILIAL + (cAlias)->A1_COD  + (cAlias)->A1_LOJA
			oObjImprime:nSA1Indice		:= 1

			oObjImprime:cRastro			:= AllTrim((cAlias)->ZZB_RASTRO)
			oObjImprime:cCodServ		:= SubStr((cAlias)->A4_YSERVIC, 1, 5)
			oObjImprime:nVlrDeclarado	:= Round((cAlias)->F2_VALBRUT, 0)
			oObjImprime:cNumLog			:= "0"
			oObjImprime:cPLP			:= cPLP
			oObjImprime:cContrato		:= (cAlias)->A4_YSERVIC
			oObjImprime:cTpContrato		:= IIf(AllTrim((cAlias)->A4_YSERVIC) $ cCodPAC,"PAC","SEDEX")
			oObjImprime:cCartao			:= ""

			oObjImprime:cPrinter		:= cImpZebra

			//|Monta o ZPL e envia para a impressora selecionada |
			oObjImprime:MontaZPL()

			RestArea(aAreaSA1)
			RestArea(aAreaSC5)
			RestArea(aArea)

			(cAlias)->(dbSkip())
			Loop

  		EndIf

  		nQde ++

  		If nQde > 4
  			nQde := 1
  			oPrinter:EndPage()
  			oPrinter:StartPage()
  		EndIf

  		If nQde == 1
  			nPosC 		:= 0
  			nPosL 		:= 0
  			nPosBarraL	:= 0
  			nPosBarraC	:= 0
  			nPosDML	:= 0
			nPosDMC	:= 0

			oPrinter:Say(2000,0110, PADL( ".", 125, '.'),oFont13,,0)
			oPrinter:Say(2000,1672, PADL( ".", 125, '.'),oFont13,,0)

			for nJ := 1 to 330
				oPrinter:Say(0020+(nJ*12),1610, ".",oFont13,,0)
			Next

  		ElseIf nQde == 2
  			nPosC 		:= 1580
  			nPosL 		:= 0
  			nPosBarraL	:= 0
  			nPosBarraC	:= 13.3
  			nPosDML	:= 0
			nPosDMC	:= 410
  		ElseIf nQde == 3
  			nPosC 		:= 0
  			nPosL 		:= 2050
  			nPosBarraL	:= 17.3
  			nPosBarraC	:= 0
  			nPosDML	:= 567
			nPosDMC	:= 0
  		Else
  			nPosC 		:= 1580
  			nPosL 		:= 2050
  			nPosBarraL	:= 17.3
  			nPosBarraC	:= 13.3
  			nPosDML	:= 567
			nPosDMC	:= 410
  		EndIf

		cCodDtMatr := CodDataMatrix(cAlias, '0')

		oPrinter:DataMatrix(145+nPosDMC,113+nPosDML, cCodDtMatr, 1)

		nPos := aScan(oSigep:aServicos, {|x|AllTrim(x[1])==AllTrim((cAlias)->A4_YSERVIC)})

		cImag002 := ''
		If nPos > 0
			cImag002 := ImagEmp( oSigep:aServicos[nPos, 6] )
		EndIf

		oPrinter:SayBitMap(0072+nPosL, 0100+nPosC, cImag002, 0420, 0280)
		oPrinter:SayBitMap(0150+nPosL, 1000+nPosC, cImag001, 0520, 0120)
		oPrinter:Box(0970+nPosL,0110+nPosC,1700+nPosL,1540+nPosC, '+1')

		cPeso := cValToChar( ROUND((cAlias)->F2_PBRUTO / Max((cAlias)->F2_VOLUME1, 1), 0))

		MSBA_HEN("CODE128" , nPosL, nPosC, AllTrim((cAlias)->ZZB_RASTRO), oPrinter,.F.   ,     ,.T.  ,10.780  , 2.05   ,.F.    ,oFont03 ,'A'  , .F.,,,, 7)
		MSBA_HEN('CODE128' , 820+nPosL, nPosC+50, AllTrim((cAlias)->A1_CEP) , oPrinter,.F.   ,     ,.T.  ,10.780  , 2.05   ,.F.    ,oFont03 ,'C'  , .F.,,,, 7)

		oPrinter:Say(0220+nPosL,0140+nPosC, "9912327460 /2013 /DR-ES",oFont08,,0)
		oPrinter:Say(0270+nPosL,0260+nPosC, "VIXPAR",oFont08,,0)

		oPrinter:Say(0455+nPosL,0110+nPosC, "NF: "+StrTran((cAlias)->F2_DOC, '0', '') ,oFont13N,,0)
		oPrinter:Say(0455+nPosL,0570+nPosC, "PEDIDO: "+(cAlias)->C5_NUM,oFont13N,,0)
		oPrinter:Say(0455+nPosL,1070+nPosC, "Peso(g): "+cPeso,oFont13N,,0)

		oPrinter:Say(0515+nPosL,0660+nPosC, (cAlias)->ZZB_RASTRO,oFont13N,,0)
		//oPrinter:Say(0515+nPosL,0660+nPosC, 'PN415203941BR',oFont13N,,0)

		oPrinter:Say(0890+nPosL,0125+nPosC, "Nome Legível: _______________________________________________",oFont13N,,0)
		oPrinter:Say(0950+nPosL,0125+nPosC, "Documento:",oFont13N,,0)
		oPrinter:Say(0950+nPosL,0850+nPosC, "Rubrica",oFont13N,,0)

		oPrinter:Say(1010+nPosL,0125+nPosC, "Destinatário:",oFont13,,0)
		oPrinter:Say(1060+nPosL,0125+nPosC, AllTrim((cAlias)->A1_NOME),oFont13,,0)
		oPrinter:Say(1110+nPosL,0125+nPosC, AllTrim((cAlias)->A1_END),oFont13,,0)
		oPrinter:Say(1160+nPosL,0125+nPosC, AllTrim((cAlias)->A1_BAIRRO),oFont13,,0)
		oPrinter:Say(1210+nPosL,0125+nPosC, Transform((cAlias)->A1_CEP, '@R 99999-999')+ ' ' + AllTrim((cAlias)->A1_MUN)+ '/'+(cAlias)->A1_EST,oFont13,,0)
		oPrinter:Say(1260+nPosL,0125+nPosC, SubStr((cAlias)->A1_COMPLEM, 1, 70),oFont13,,0)

		oPrinter:Say(1310+nPosL,0125+nPosC,"AR"  ,oFont13N,,0)
		oPrinter:Say(1360+nPosL,0125+nPosC,"Obs:",oFont13N,,0)

		//oPrinter:Say(1400+nPosL,1050+nPosC,"AR"  ,oFont13N,,0)
		//oPrinter:Say(1460+nPosL,1050+nPosC,"Obs:",oFont13N,,0)

		oPrinter:Say(1740+nPosL,0110+nPosC, "Remetente",oFont13,,0)
		oPrinter:Say(1790+nPosL,0110+nPosC, SM0->M0_NOMECOM,oFont13,,0)
		oPrinter:Say(1840+nPosL,0110+nPosC, AllTrim(SM0->M0_ENDCOB),oFont13,,0)
		oPrinter:Say(1890+nPosL,0110+nPosC, AllTrim(SM0->M0_BAIRCOB),oFont13,,0)
		oPrinter:Say(1940+nPosL,0110+nPosC, Transform(SM0->M0_CEPCOB, '@R 99999-999')+ ' ' + AllTrim(SM0->M0_CIDCOB)+ '/'+SM0->M0_ESTCOB,oFont13,,0)

		(cAlias)->(DbSkip())

	EndDo

	//FreeObj(oSigep)

	If !lZebra
		oPrinter:EndPage()
		//oPrinter:Preview()
		oPrinter:Print()
		FreeObj(oPrinter)
	EndIf

	(cAlias)->(DbCloseArea())

Return

Static Function MSBA_HEN(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix, nTam, nTop, nLeft, nBottom, nWidth2)
   Local nI   := 0
   Local nPos := 0

   Local oBrush1	:= nil
   Local nSpace	:= 0
   Local nSpaceZero	:= 0

   	Default nTop		:= 550
	Default nLeft 	:= 180
	Default nBottom	:= 810
	Default nWidth2	:= 180


   oBar:= CBBAR():New(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
	nTop		+= nRow
	nLeft 		+= nCol
	nBottom	+= nRow
	nWidth2	+= nCol + nTam
	nSpace 	:= nWidth2-nLeft
	nSpaceZero := 1 * (Round(nTam / 7, 4))
  	oBrush1 := TBrush():New( , CLR_BLACK )

  	For nI := 1 to Len(oBar:cConteudo)

  		If Substr(oBar:cConteudo, nI, 1) == '1'
  			If nI > 1 .AND. Substr(oBar:cConteudo, nI-1, 1) == '0'
		  		nLeft 	+= nSpaceZero
				nWidth2	+= nSpaceZero
			EndIf
  			//Alert('Left: '+cValToChar(nLeft) + " | Width "+ cValToChar(nWidth) )
	  		oPrint:FillRect( {nTop, nLeft, nBottom, nWidth2}, oBrush1 )
	  	EndIf

		nLeft 		+= nSpace
		nWidth2		+= nSpace

  	Next

  // oBar:Draw()
Return

/*/{Protheus.doc} TelaCodBarras
Cria uma tela para digitação do código de barras da nota fiscal
@author henrique
@since 12/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function TelaCodBarras()
	Local oSChave 	:= nil
	Local oSDesc   	:= nil
	Local oDlg	   		:= nil
	Local cTexto   	:= ''
	Local oBtnSair	:= nil
	Local oFont50 	:= TFont():New("ARIAL",,050,,.T.,,,,,.F.,.F.)
	Local oFont20 	:= TFont():New("ARIAL",,020,,.T.,,,,,.F.,.F.)

	Private oGChave	:= Nil
	Private cGChave	:= Space(AVSX3('F2_CHVNFE', 3))

	cTexto := "Favor informar o código de barras da DANFE."

	DEFINE MSDIALOG oDlg TITLE "Código de barras" FROM 000, 000  TO 230, 550 PIXEL
		@ 005, 007 SAY oSDesc 	PROMPT cTexto                      			SIZE 163, 037 OF oDlg PIXEL
		@ 030, 007 SAY oSChave 	PROMPT "Insira o código de barras da Danfe" 	SIZE 150, 015 OF oDlg FONT oFont20 PIXEL

		@ 055, 007 MSGET oGChave  VAR cGChave      	SIZE 260, 020 OF oDlg FONT oFont50 VALID AnaliChave(cGChave) PIXEL
		@ 100, 230 BUTTON oBtnSair PROMPT "Sair"     	SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} AnaliChave
Analisa se a chave da nota fiscal existe e já atribui um rastro para ele
@author henrique
@since 12/12/2016
@version 1.0
@param cChave, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AnaliChave(cChave)

	Local cAlias  	 := ""
	Local oBjMEnvios := MEnviosRastreamento():New()
	//Local oInvoice 	 := MLEInvoice():New()
	Local aRet		 := ""
	Local cModFrete		:= ""

	Local cTransp := SuperGetMV("MV_Y189TRA",.F.,'000901/000902/000903/000703')


	If !Empty(cTransp)
		cTransp := ' AND SF2.F2_TRANSP IN ' + FormatIn(cTransp,'/')
	Else
		cTransp := " AND 1 = 1 "
	End If

	cTransp := '% '+cTransp+' %'


	If Empty(cChave)
		Return
	Endif

	If Len(AllTrim(cChave)) < 44
		Aviso("Atenção","A chave informada está incompleta!",{"Voltar"})
		Return
	EndIf

	cAlias := GetNextAlias()

	BeginSql Alias cAlias

		SELECT
		    F2_DOC,
		    F2_SERIE,
		    F2_TRANSP,
		    F2_CLIENTE,
		    F2_LOJA,
		    F2_EMISSAO,
		    F2_CHVNFE,
		    (
		        SELECT TOP 1
		            D2_CF
		        FROM
		            %table:SD2% SD2
		        WHERE
		            D2_FILIAL = F2_FILIAL
		            AND D2_DOC = F2_DOC
		            AND D2_SERIE = F2_SERIE
		            AND D2_CLIENTE = F2_CLIENTE
		            AND D2_LOJA = F2_LOJA
		            AND SD2.D_E_L_E_T_ = ""
		    ) D2_CF,
		    A1_INSCR,
		    ZZB_DOC,
		    SA4.A4_YSERVIC,
		    VT1_MODFRE,
		    VT1_IDCART,
		    VT1_ORDID,
		    VT1_SEQUEN,
		    VT1_API
		FROM
		    %table:SF2% SF2
		    JOIN %table:SC5% SC5 ON (
		                           C5_FILIAL = %xFilial:SC5%
		                           AND SC5.D_E_L_E_T_ = ""
		                           AND SF2.F2_DOC = SC5.C5_NOTA
		                           AND SF2.F2_SERIE = SC5.C5_SERIE
		                       )
		    JOIN %table:SA1% SA1 ON (
		                           A1_FILIAL = %xFilial:SA1%
		                           AND SA1.D_E_L_E_T_ = ""
		                           AND SF2.F2_CLIENTE = SA1.A1_COD
		                           AND SF2.F2_LOJA = SA1.A1_LOJA
		                       )
		    JOIN %table:SA4% SA4 ON (
		                           A4_FILIAL = %xFilial:SA4%
		                           AND SA4.D_E_L_E_T_ = ""
		                           AND SA4.A4_COD = SF2.F2_TRANSP
		                       )
		    LEFT JOIN %table:VT1% VT1 ON (
		                                VT1_FILIAL = %xFilial:VT1%
		                                AND VT1.D_E_L_E_T_ = ""
		                                AND SC5.C5_NUM = VT1.VT1_NUMPED
		                            )
		    LEFT JOIN %table:VT4% VT4 ON (
		                                VT4_FILIAL = %xFilial:VT4%
		                                AND VT4.D_E_L_E_T_ = ""
		                                AND VT4.VT4_ORDID = VT1.VT1_ORDID
		                                AND VT4_EMPFOR + VT4_FILFOR = %Exp:cLocalArm%
		                            )
		    LEFT JOIN %table:ZZB% ZZB ON (
		                                ZZB_FILIAL = %xFilial:ZZB%
		                                AND ZZB.D_E_L_E_T_ = ' '
		                                AND ZZB.ZZB_DOC = SF2.F2_DOC
		                                AND ZZB.ZZB_SERIE = SF2.F2_SERIE
		                            )
		WHERE
		    SF2.F2_FILIAL = %xFilial:SF2%
		    AND SF2.D_E_L_E_T_ = ""
		    AND SF2.F2_TIPO = 'N'
		   	%Exp:cTransp%
		    AND F2_CHVNFE = %Exp:cChave%

	EndSql

	If (cAlias)->(Eof())
		Aviso("Atenção","Nota fiscal não existe ou o transporte não é Correios!",{"Voltar"})

	ElseIf ! Empty ((cAlias)->ZZB_DOC)
		Aviso("Atenção","A nota já foi atribuida a um rastreio!",{"Voltar"})

	Else

		cModFrete := AllTrim((cAlias)->VT1_MODFRE)

		If cModFrete == "ME2" //IsME2(AllTrim((cAlias)->VT1_SEQUEN, (cAlias)->VT1_ORDID))[1]

			/*
			oInvoice:cChave			:= (cAlias)->F2_CHVNFE
			oInvoice:cCFOP			:= (cAlias)->D2_CF
			oInvoice:InscEstadual 	:= (cAlias)->A1_INSCR
			oInvoice:cPedidoMP 		:= AllTrim((cAlias)->VT1_SEQUEN)

			oInvoice:Criar()
			*/

			oBjMEnvios:cOrdId	:= (cAlias)->VT1_ORDID
			oBjMEnvios:cSequen  := (cAlias)->VT1_SEQUEN
			oBjMEnvios:cIdCart  := (cAlias)->VT1_IDCART
			oBjMEnvios:cApi     := (cAlias)->VT1_API
			oBjMEnvios:cDoc     := (cAlias)->F2_DOC
			oBjMEnvios:cSerie   := (cAlias)->F2_SERIE
			oBjMEnvios:cCliente := (cAlias)->F2_CLIENTE
			oBjMEnvios:cLoja    := (cAlias)->F2_LOJA
			oBjMEnvios:cEmissao := (cAlias)->F2_EMISSAO
			oBjMEnvios:cServico := (cAlias)->A4_YSERVIC

			//oBjMEnvios:cIdCart := "2000000037468606" // TESTE

			aRet := oBjMEnvios:GetAtuRastro()

			If aRet[1]

				DownloadME2(aRet[2])

				SF2SQL()
				//AtualizaRastro()
				AtualizaPLP()
				SlqPLPFechadas()

				oBrowserRas:Refresh()
				oBrowseUp:Refresh()
				oBrowserPLP:Refresh()
				oBrwPLPFech:Refresh()

			Else

				Aviso("ATENCAO", "Pedido identificado como Mercado Envios, porem ocorreu erro na busca!" + ENTER + ENTER + aRet[2], {"Ok"}, 3)

			EndIf

		Else

			GeraRastro((cAlias)->A4_YSERVIC)
			AtualizaRastro()

			SF2SQL()
			oBrowserRas:Refresh()
			oBrowseUp:Refresh()

			TRBSF2->(DbSetOrder(1))

			If TRBSF2->(DbSeek((cAlias)->(F2_DOC+F2_SERIE)))
				GeraEtiqueta()
			EndIf

			AtualizaRastro()
			SF2SQL()
			oBrowserRas:Refresh()
			oBrowseUp:Refresh()

		EndIf

	EndIf

	cGChave	:= Space(AVSX3('F2_CHVNFE', 3))
	oGChave:Refresh()

	oGChave:SetFocus()

Return()

Static Function DownloadME2(cUrl)

	Local cHeaderRet := ""
	Local cArqui 	 := ""
	Local cFile 	 := "MEnvios" + __cUserID + "-" + dToS(Date()) + "-" + StrTran(Time(), ":", "") + ".pdf"
	Local cDirTmp  	 := AllTrim(GetTempPath())
	Local nHandle 	 := 0
	Local nRet		 := 0
	Local oPrtMe2	 := Nil

	Default cUrl := ""

	If ! Empty(cUrl)

		If !File(cDirTmp+cFile)

			nHandle := FCreate(cDirTmp + cFile)

			cArqui := HTTPGET(cUrl,,,,@cHeaderRet)

			FWrite(nHandle, cArqui)

			FClose(nHandle)

		EndIf

	    ImpMEnvio(cDirTmp+cFile)

	EndIf

Return()

/*/{Protheus.doc} NumeControle
Obtem o próximo número de controle da rastro
@author henrique
@since 13/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function NumeControle()
	Local cRet		:= '000001'
	Local cAlias	:= GetNextAlias()

	BeginSql Alias cAlias
		SELECT MAX(ZZB_CONTRO) ZZB_CONTRO
		FROM %Table:ZZB% ZZB
		WHERE ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel%

	EndSql

	If !(cAlias)->(Eof())
		cRet := Soma1((cAlias)->ZZB_CONTRO)
	EndIf

	(cAlias)->(DbCloseArea())

Return cRet

Static Function ProxPLPME()

	Local cRet		:= ""
	Local cAlias	:= GetNextAlias()

	BeginSql Alias cAlias

		SELECT ISNULL(MAX(ZZB_PLP), "ME0000000") ZZB_PLP
		FROM %Table:ZZB% ZZB
		WHERE ZZB_FILIAL = %xFilial:ZZB%
				AND SUBSTRING(ZZB.ZZB_PLP, 1, 2) = 'ME'
				AND ZZB.%NotDel%

	EndSql

	If !(cAlias)->(Eof())
		cRet := Soma1((cAlias)->ZZB_PLP)
	EndIf

	(cAlias)->(DbCloseArea())

Return cRet

/*/{Protheus.doc} CodDataMatrix
(long_description)
@author henrique
@since 13/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CodDataMatrix(cAlias, cNumLog)
	Local cRet				:= ''
	//Local oSigAcesso		:= SigAcesso():New()
	Local cCepDest		:= (cAlias)->A1_CEP //8
	Local cCompDestCep	:= '00000' //5
	Local cCepOrigem		:= SM0->M0_CEPCOB//8
	Local cComOrigCep		:= '00000' //5
	Local cValidDestCep	:= ' ' //1
	Local cIDV				:= '51' //2
	Local cCodRastro		:= SubStr((cAlias)->ZZB_RASTRO, 1, 13) //13
	Local cServAdici		:= PADR('250119', 12, '0')  //12
	Local cCartaoPost		:= oSigep:cCartao //10
	Local cCodServ		:= SubStr((cAlias)->A4_YSERVIC, 1, 5) //05
	Local cAgrupame		:= '00' //2
	Local cNumLograd		:= PADL(cNumLog, 5, '0')//5
	Local cCompLogr		:= PADR((cAlias)->A1_COMPLEM, 20, ' ') //20
	Local cValor			:= cValTochar(Round((cAlias)->F2_VALBRUT, 0)) //5
	Local cDDD_Tel		:= PADL((cAlias)->(A1_DDD+A1_TEL), 12, '0') //12
	Local cLatitude		:= '-00.000000' //10
	Local cLongitude		:= '-00.000000' //10
	Local cSeparador		:= '|' //1
	Local cReservClient	:= Space(30) //30

	//Variáveis para cálculo do digito verificador do CEP
	Local nI 				:= 0
	Local nValorAcum		:= 0
	Local nMultipli		:= 0

	If Len(AllTrim((cAlias)-A1_DDD)) > 2
		cDDD_Tel	:= (cAlias)->(SubStr(AllTrim(A1_DDD), 2, 2) + AllTrim(A1_TEL))
	Else
		cDDD_Tel	:= (cAlias)->(AllTrim(A1_DDD) + AllTrim(A1_TEL))
	EndIf

	For nI := 1 To Len(cCepDest)
		nValorAcum += Val( SubStr(cCepDest, nI, 1))
	Next

	nMultipli := NoRound( nValorAcum / 10, 0)
	nMultipli += iif(mod( nValorAcum , 10) > 0 , 1, 0)
	nMultipli := nMultipli * 10

	cValidDestCep := cValToChar(nMultipli - nValorAcum)

	cRet := cCepDest + cCompDestCep + cCepOrigem + cComOrigCep + ;
			cValidDestCep + cIDV + cCodRastro + cServAdici + cCartaoPost +;
			cCodServ + cAgrupame + cNumLograd + cCompLogr + cValor + cDDD_Tel +;
			cLatitude + cLongitude + cSeparador + cReservClient

Return cRet

/*/{Protheus.doc} TelaSelecao
(long_description)
@author henrique
@since 13/12/2016
@version 1.0
@param cAlias, character, (Descrição do parâmetro)
@param cCampoExtra, character, (Descrição do parâmetro)
@return cSeek - Campo que será criado o Indice
@return cRastrosSel - Relação dos códigos de rastreamento selecionados
@example
(examples)
@see (links_or_references)
/*/
Static Function TelaSelecao(cAlias, cCampoExtra, cSeek, cRastrosSel)
	Local aStru 		:= {}
	Local cTrab		:= ''
	Local aHeader		:= {}
	Local aSize 		:= MsAdvSize()
	Local oDlgSel		:= Nil
	Local oMark		:= Nil
	Local i			:= 0
	Local lProcessa	:= .F.

	If Select('TRBSEL') > 1
		TRBSEL->(DbCloseArea())
	EndIf

	aStru := (cAlias)->(dbStruct())
	cTrab := CriaTrab(aStru)
	dbUseArea(.T.,,cTrab,"TRBSEL")
	IndRegua("TRBSEL", cTrab, cSeek,,,	"Indexando registros...")

	(cAlias)->(dbGoTop())
	While (cAlias)->(!Eof())
		RecLock('TRBSEL', .T.)

		For i := 1 to Len(aStru)
			TRBSEL->&(aStru[i, 1]) := (cAlias)->&(aStru[i, 1])
		Next

		TRBSEL->(MsUnLock())
		(cAlias)->(DbSkip())
	EndDo

	TRBSEL->(DbGoTop())

	aHeader := {}

	For i := 1 to Len(aStru)
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(aStru[i, 1]) //.and. !aStru[i, 1] $ "U5_OPERADO/A1_LOJA/A1_CGC/A1_EST"
			aAdd(aHeader,{SX3->X3_TITULO,;
				aStru[i, 1],;
				SX3->X3_TIPO,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_PICTURE} )
		Endif
	Next

	oDlgSel := MSDialog():New( aSize[7],aSize[1],600,800,"Seleção de Dados",,,.F.,,,,,,.T.,,,.T. )

		oMark := FWMarkBrowse():New()
		oMark:SetSeeAll(.F.)
		oMark:SetFieldMark(cCampoExtra)
		oMark:SetOwner(oDlgSel)
		oMark:SetDescription("Etiqueta")
		oMark:SetAlias('TRBSEL')
		oMark:SetFields(aHeader)
		oMark:SetMenuDef('')//
		oMark:DisableDetails()
		oMark:SetProfileID('5')
		oMark:ForceQuitButton()
		oMark:SetSeek(.T.,CriaSeek(cCampoExtra, cSeek))
		oMark:Activate()

		@ 283, 280 BUTTON oBtnSair PROMPT "OK"     			SIZE 050, 012 OF oDlgSel ACTION {||lProcessa := .T., oDlgSel:End()} PIXEL
		@ 283, 340 BUTTON oBtnSair PROMPT "Sair"     			SIZE 050, 012 OF oDlgSel ACTION {||lProcessa := .F., oDlgSel:End()} PIXEL

	oDlgSel:Activate(,,,.T.)

	cRastrosSel := ''
	If lProcessa
		TRBSEL->(DbGoTop())
		While !TRBSEL->(Eof())
			If TRBSEL->&(cCampoExtra) == oMark:Mark()
				cRastrosSel += TRBSEL->&(cSeek) + '/'
			EndIf

			TRBSEL->(DbSkip())
		EndDo

		TRBSEL->(DbGoTop())
	EndIf

Return lProcessa


/*/{Protheus.doc} CriaSeek
(long_description)
@author henrique
@since 13/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CriaSeek(cTab, cSeek)

	Local _aSeek := {}

	Aadd(_aSeek,{'Rastro' , {{cTab,'C',TamSX3(cSeek)[1],'Rastro','@!'}}, 1, .T. } )

Return _aSeek

/*/{Protheus.doc} ImagEmp
(long_description)
@author henrique
@since 14/12/2016
@version 1.0
@param cImagem, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function ImagEmp(cImagem)
	Local cArquivo	:= ''
	Local cExtensao 	:= ''
	Local cDiretorio	:= ''

	SplitPath(cImagem,/*cDrive*/,@cDiretorio, @cArquivo, @cExtensao)

	//Alert(GetSrvProfString("Startpath",""))

	cImagem := cDiretorio+cArquivo+cEmpAnt+cFilAnt+cExtensao
	If !File(cImagem)
		cImagem := cDiretorio+cArquivo+cEmpAnt+cExtensao
	EndIF

	If !File(cImagem)
		cImagem := cDiretorio+cArquivo+cExtensao
	EndIF

Return cImagem


/*/{Protheus.doc} CriaPerg
Cria grupo de pergutnas
@author henrique
@since 14/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function CriaPerg()

	u_zPutSX1(cPerg,"01","Local?"		,"","","mv_ch1","N",1,0,0,"C","","","","","mv_par01","0801-TIMS","","","","0105-VILA VELHA")

Return


/*/{Protheus.doc} InfoArmazem
Rotina para o usuário informar qual a empresa que armazena os produtos a serem separados.
@author henrique
@since 14/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function InfoArmazem()
	Local cBkpArm := cLocalArm

	If Pergunte(cPerg, .T.)
		If MV_PAR01 == 1
			cLocalArm := '0801'
			cEmpArmaz  	:= '0801 - TIMS'
		ElseIf MV_PAR01 == 2
			cLocalArm := '0105'
			cEmpArmaz  	:= '0105 - VILA VELHA'
		Else
			cLocalArm := ''
			cEmpArmaz	:= ''
		EndIf

	EndIf

	If cBkpArm != cLocalArm
		SF2SQL()
		AtualizaRastro()
		AtualizaPLP()
		SlqPLPFechadas()

		oBrowserRas:Refresh()
		oBrowseUp:Refresh()
		oBrowserPLP:Refresh()
		oBrwPLPFech:Refresh()
		oDlg:cTitle := "Controle de rastreamento SIGEP - Empresa Armazenadora: "+cEmpArmaz
		oDlg:Refresh()
	EndIf

	//DEFINE MSDIALOG oDlg

Return


/*/{Protheus.doc} TrataTel
(long_description)
@author henrique
@since 23/12/2016
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function TrataEnd(cEnd)
	Local cEnder	:= cEnd
	Local cNumero	:= ''
	Local nPosInc	:= 0
	Local nPosFim	:= 0
	Local cEndRest:= ''

	If Empty(cEnd)
		Return {'', ''}
	EndIf

	nPosInc := At('N°', UPPER(cEnd))

	If nPosInc > 0
		cEndRest := SubStr(cEnder, nPosInc, Len(cEnder)-nPosInc)

		nPosFim := At(',', cEndRest)
		If nPosFim <= 0
			nPosFim := 10

		EndIf

		cNumero := SubStr(cEnd, nPosInc + 2, nPosFim-1)

	EndIf

	If Empty(cNumero)
		nPosInc := Rat(',', UPPER(cEnd))

		If nPosInc > 0
			cNumero := SubStr(cEnd, nPosInc + 1, 10)

		EndIf

	EndIf

	If Empty(cNumero)
		cNumero := 'S/N'
	Else
		cEnder := StrTran(cEnder, ', '+cNumero, '')
		cEnder := StrTran(cEnder, ','+cNumero, '')
		cEnder := StrTran(cEnder, cNumero, '')
	EndIf

Return {cEnder, cNumero}

/*/{Protheus.doc} Rel_PLP_Barra
Relatório de PLP com código de barras
@author henrique
@since 02/03/2017
@version 1.0
@param oPrint, objeto, (Descrição do parâmetro)
@param cPLP, character, (Descrição do parâmetro)
@param cTotalizador, character, (Descrição do parâmetro)
@param nPagina, numérico, (Descrição do parâmetro)
@param nTotalPagina, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function Rel_PLP_Barra(cPLP, aTotalPLP)

	Local oPrint 	:= TMSPrinter():New("Correios PLP")

	Local oFont08N 		:= TFont():New("ARIAL",,008,,.T.,,,,,.F.,.F.)
	Local oFont10N 		:= TFont():New("ARIAL",,010,,.T.,,,,,.F.,.F.)
	Local oFont10 		:= TFont():New("ARIAL",,010,,.F.,,,,,.F.,.F.)
	Local oFont13N 		:= TFont():New("ARIAL",,013,,.T.,,,,,.F.,.F.)
	Local oFont18 		:= TFont():New("ARIAL",,018,,.F.,,,,,.F.,.F.)
//	Local oAcesso			:= Nil
	Local nI, nJ, nX		:= 0
	Local nPos				:= 0
	Local nTop				:= 370
	Local nLeft 			:= 1550
	Local nBottom			:= 510
	Local nWidth			:= 1550
	Local nTotal			:= 0

	oPrint:StartPage()

	If Len(aTotalPLP) == 0
		Return
	EndIf

	//oPrint:SetLandscape() 		// Paisagem
	//oPrint:Setup()

//	oAcesso			:= SigAcesso():New()
	//Cabeçalho

	For nI := 1 to 2
		nTotal := 0
		nPos := (nI-1)*0770

		oPrint:SayBitmap( 0105+nPos,0360,"C:\Temp\Correios\logo_correios.png",280,84 )

		oPrint:Say( 0140+nPos, 0700,"EMPRESA BRASILEIRA DE CORREIOS E TELÉGRAFOS",oFont13N,1400 )

		oPrint:Box( 0225+nPos, 0350, 0310+nPos, 2100 )
		oPrint:Box( 0310+nPos, 0350, 0580+nPos, 2100 )
		oPrint:Box( 0580+nPos, 0350, 0830+nPos, 2100 )

		oPrint:Say( 0240+nPos, 800,"PRÉ - LISTA DE POSTAGEM - PLP - SIGEP WEB" 			, oFont10N,1400 )

		MSBA_HEN('CODE128' , nPos, 0, AllTrim(cPLP) , oPrint,.F.   ,     ,.T.  ,  ,   ,.F.    ,oFont08N ,'C'  , .F.,,,, 8, nTop, nLeft, nBottom, nWidth)

		oPrint:Say( 0320+nPos, 0360,"SIGEP WEB - Gerenciador de Postagem dos Correios:"	, oFont08N,1400 )
		oPrint:Say( 0320+nPos, 1700,"Nº PLP: " + cPLP											, oFont08N,1400 )
		oPrint:Say( 0370+nPos, 0360,"Contrato: " +oSigep:cContrato							, oFont08N,1400 )
		oPrint:Say( 0420+nPos, 0360,"Cliente: VIXPAR"											, oFont08N,1400 )
		oPrint:Say( 0470+nPos, 0360,"Telefone de contato:" + SM0->M0_TEL					, oFont08N,1400 )
		oPrint:Say( 0520+nPos, 0360,"E-mail de contato: atendimento@hipervarejo.com.br"	, oFont08N,1400 )

		oPrint:Say( 0590+nPos, 0360,"Cod Serviço:"											, oFont08N,1400 )
		oPrint:Say( 0590+nPos, 0750,"Quantidade:"												, oFont08N,1400 )
		oPrint:Say( 0590+nPos, 1150,"Serviço" 													, oFont08N,1400 )

		For nX := 1 to Len(aTotalPLP)
			oPrint:Say( 0640+nPos + ((nX -1) * 45), 0360, aTotalPLP[nX, 1]					, oFont08N,1400 )
			oPrint:Say( 0640+nPos + ((nX -1) * 45), 0750, cValToChar(aTotalPLP[nX, 3])		, oFont08N,1400 )
			oPrint:Say( 0640+nPos + ((nX -1) * 45), 1150, aTotalPLP[nX, 2] 					, oFont08N,1400 )
			nTotal += aTotalPLP[nX, 3]
		Next

		oPrint:Say( 0780+nPos, 0360,"Total:"													, oFont08N,1400 )
		oPrint:Say( 0780+nPos, 0750, cValToChar(nTotal)										, oFont08N,1400 )

		oPrint:Say( 0590+nPos, 1550,"Data Entrega: _____/_____/_________"					, oFont08N,1400 )
		oPrint:Say( 0650+nPos, 1550,"________________________________"						, oFont08N,1400 )
		oPrint:Say( 0690+nPos, 1550,"Assinatura / Matrícula dos Correios"					, oFont08N,1400 )

		If nI == 1
			For nJ := 1 to 50
				oPrint:Say( 0820, 0350 + ((nJ - 1)*35), '_'								, oFont10N, 20 )
			Next

			oPrint:Say( 0750, 1550,"1ª Via - Correios"										, oFont08N,1400 )
		Else
			oPrint:Say( 0750+nPos, 1550,"2ª Via - Cliente"									, oFont08N,1400 )
		EndIf

	Next

    oPrint:EndPage()
    oPrint:Print()

	//FreeObj(oAcesso)
Return


/*/{Protheus.doc} Rel2_PLP_Barra
(long_description)
@author henrique
@since 03/03/2017
@version 1.0
@param cPLP, character, (Descrição do parâmetro)
@param aTotalPLP, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function Rel2_PLP_Barra(cPLP, aTotalPLP)

	Local oPrint 	:= TMSPrinter():New("Correios PLP Barra")

	Local oFont08N 		:= TFont():New("ARIAL",,010,,.T.,,,,,.F.,.F.)
	Local oFont12N 		:= TFont():New("ARIAL",,010,,.T.,,,,,.F.,.F.)
	Local oFont10N 		:= TFont():New("ARIAL",,010,,.T.,,,,,.F.,.F.)
	Local oFont10 		:= TFont():New("ARIAL",,010,,.F.,,,,,.F.,.F.)
	Local oFont14N 		:= TFont():New("ARIAL",,013,,.T.,,,,,.F.,.F.)
	Local oFont18 		:= TFont():New("ARIAL",,018,,.F.,,,,,.F.,.F.)
	//Local oAcesso			:= Nil
	Local nI, nJ, nX		:= 0
	Local nPos				:= 0
	Local nTop				:= 370
	Local nLeft 			:= 1650
	Local nBottom			:= 610
	Local nWidth			:= 1650
	Local nTotal			:= 0

	oPrint:StartPage()

	If Len(aTotalPLP) == 0
		Return
	EndIf

	//oPrint:SetLandscape() 		// Paisagem
	//oPrint:Setup()
	oPrint:SetPortrait()
	//oAcesso			:= SigAcesso():New()
	//Cabeçalho

	For nI := 1 to 2
		nTotal := 0
		nPos := (nI-1)*1040

		oPrint:SayBitmap( 0105+nPos,0060,"C:\Temp\Correios\logo_correios.png",280,84 )

		oPrint:Say( 0140+nPos, 0400,"EMPRESA BRASILEIRA DE CORREIOS E TELÉGRAFOS",oFont14N,1400 )

		oPrint:Box( 0225+nPos, 0050, 0310+nPos, 2400 )
		oPrint:Box( 0310+nPos, 0050, 0680+nPos, 2400 )
		oPrint:Box( 0680+nPos, 0050, 1030+nPos, 2400 )

		oPrint:Say( 0240+nPos, 0780,"PRÉ - LISTA DE POSTAGEM - PLP - SIGEP WEB" 			, oFont14N,1400 )

		MSBA_HEN('CODE128' , nPos, 0, AllTrim(cPLP) , oPrint,.F.   ,     ,.T.  ,  ,   ,.F.,oFont08N ,'C'  , .F.,,,, 7, nTop, nLeft, nBottom, nWidth)

		oPrint:Say( 0320+nPos, 0060,"SIGEP WEB - Gerenciador de Postagem dos Correios:"	, oFont08N,1400 )
		oPrint:Say( 0320+nPos, 1780,"Nº PLP: " + cPLP											, oFont08N,1400 )
		oPrint:Say( 0390+nPos, 0060,"Contrato: " +oSigep:cContrato							, oFont08N,1400 )
		oPrint:Say( 0460+nPos, 0060,"Cliente: VIXPAR"											, oFont08N,1400 )
		oPrint:Say( 0530+nPos, 0060,"Telefone de contato:" + SM0->M0_TEL					, oFont08N,1400 )
		oPrint:Say( 0600+nPos, 0060,"E-mail de contato: atendimento@hipervarejo.com.br"	, oFont08N,1400 )

		oPrint:Say( 0690+nPos, 0060,"Cod Serviço:"											, oFont08N,1400 )
		oPrint:Say( 0690+nPos, 0560,"Quantidade:"												, oFont08N,1400 )
		oPrint:Say( 0690+nPos, 1060,"Serviço" 													, oFont08N,1400 )

		For nX := 1 to Len(aTotalPLP)
			oPrint:Say( 0770+nPos + ((nX -1) * 65), 0060, aTotalPLP[nX, 1]					, oFont08N,1400 )
			oPrint:Say( 0770+nPos + ((nX -1) * 65), 0560, cValToChar(aTotalPLP[nX, 3])	, oFont08N,1400 )
			oPrint:Say( 0770+nPos + ((nX -1) * 65), 1060, aTotalPLP[nX, 2] 				, oFont08N,1400 )
			nTotal += aTotalPLP[nX, 3]
		Next

		oPrint:Say( 0950+nPos, 0060,"Total:"													, oFont08N,1400 )
		oPrint:Say( 0950+nPos, 0560, cValToChar(nTotal)										, oFont08N,1400 )

		oPrint:Say( 0730+nPos, 1650,"Data Entrega: _____/_____/_________"					, oFont08N,1400 )
		oPrint:Say( 0820+nPos, 1650,"________________________________"						, oFont08N,1400 )
		oPrint:Say( 0890+nPos, 1650,"Assinatura / Matrícula dos Correios"					, oFont08N,1400 )

		If nI == 1
			For nJ := 1 to 68
				oPrint:Say( 1060, 0050 + ((nJ - 1)*35), '_'								, oFont10N, 20 )
			Next

			oPrint:Say( 0950, 1650,"1ª Via - Correios"										, oFont08N,1400 )
		Else
			oPrint:Say( 0950+nPos, 1650,"2ª Via - Cliente"									, oFont08N,1400 )
		EndIf

	Next

    oPrint:EndPage()
    oPrint:Print()

	//FreeObj(oAcesso)
	FreeObj(oPrint)
Return

/*/{Protheus.doc} SelImpressora
(long_description)
@author henrique
@since 03/03/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function SelImpressora()
	Local lRet := .F.
	Local oBtnSair	:= nil
	Local oBtnOK		:= nil
	Local aImpress 	:= GetImpWindows(.F.) //Lista de impressoras disponíveis - A 1ª é a impressora padrão
	Local cImpress	:= Space(20)
	Local cConfImp	:= GetPrinterSession()

	DEFINE MSDIALOG oDlg TITLE "Seleção da Impressora" FROM 000, 000  TO 230, 350 PIXEL
		@ 015, 028 COMBOBOX cImpress ITEMS aImpress  	SIZE 120, 010 PIXEL OF oDlg
		@ 030, 094 BUTTON oBtnSair PROMPT "OK"     	SIZE 037, 012 OF oDlg ACTION {||lRet := .T., oDlg:End()} PIXEL
		@ 030, 134 BUTTON oBtnOK PROMPT "Sair"     	SIZE 037, 012 OF oDlg ACTION {||lRet := .F., oDlg:End()} PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	If lRet
		cImpressora := cImpress
		WriteProfString(cConfImp,"DEFAULT",cImpress,.T.) //Altera a impressora default do usuário
	EndIf

Return


/*/{Protheus.doc} SelImpressora
(long_description)
@author henrique
@since 03/03/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SelImpZebra()

	DEFINE MSDIALOG oDlgLI TITLE "Selecione a Impressora Zebra" From 50,50 to 120,280 PIXEL

		@ 06,05 SAY "Imp. Zebra:" SIZE 50,8 OF oDlgLI PIXEL
		@ 05,60 MSGET oGetLI VAR cImpZebra F3 'CB5' SIZE 50,06 WHEN .T. PICTURE '@!' OF oDlgLI PIXEL
		DEFINE SBUTTON FROM 21,083 TYPE 1 ACTION (oDlgLI:End()) ENABLE Of oDlgLI

	ACTIVATE DIALOG oDlgLI CENTERED

	If !Empty(cImpZebra)
		PutMV("MV_YIMPZEB",cImpZebra)
	EndIf

Return



User Function AcertaRastro()
	Local oB2CSchdHabPrd := B2CSchdHabPrd():New() //Objeto criado apenas para iniciar o ambiente
	Local cAlias := ''
	Local oSigep := ''
	Local cRastro:= ''
	Local aParam := {'09', '01'}

	oB2CSchdHabPrd:cEmp := aParam[1]
	oB2CSchdHabPrd:cFil := aParam[2]

	oB2CSchdHabPrd:IniciaAmb()

	cAlias := GetNextAlias()
	oSigep := ServSigep():New()

	BEGINSQL Alias cAlias
		SELECT R_E_C_N_O_ AS RECZZB, ZZB_RASTRO
		 FROM ZZB090 WHERE ZZB_FILIAL = '01' AND SUBSTRING(ZZB_RASTRO, 11, 1) = ''
	EndSql

	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())
		cRastro := oSigep:GeraDigitoVerificador((cAlias)->ZZB_RASTRO)

		ZZB->(DbGoTo((cAlias)->RECZZB))
		RecLock('ZZB', .F.)
			ZZB->ZZB_RASTRO := cRastro
		ZZB->(MsUnLock())


		(cAlias)->(DbSkip())
	EndDo

	oB2CSchdHabPrd:FinalAmb()
Return

/*/{Protheus.doc} ImpMEnvio
Imprime o PDF
@author henrique.reis
@since 30/05/2018
@version 1.0
@param cNameFile, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ImpMEnvio(cNameFile)

	Local aImpress 	:= {}
	Local cConfImp	:= GetPrinterSession()

	If Empty(cImpressora) //Variável privada
		aImpress := GetImpWindows(.F.)
		If Len(aImpress) > 0
			cImpressora := aImpress[1]
		Else
			Aviso("Atencao","Não foi encontrado impressora instalado neste computador, favor entrar em contato com a TI (Infra-estrutura)",{"OK"})
		EndIf
	EndIf

	If ! Empty(cImpressora)
		If at('\\', cImpressora) <= 0
			cImpressora := '\\' + AllTrim(ComputerName()) + '\'+cImpressora
		EndIf

		cRet := WaitRun('print /d:"'+cImpressora +'" '+cNameFile, SW_HIDE)

		If cRet == 0
			If File(cNameFile)
				FErase(cNameFile)
			Endif
		EndIf
	EndIf

Return()

/*
User Function Exemplo()
	Local cSecao := "", cChave := "", cMensagem := ""
	Local nValor := 0, nRecuperado := 0
	//+----------------------------------------------------------------------------+
	//|Exemplifica o uso da função GetProfInt                                      |
	//+----------------------------------------------------------------------------+
	cSecao := "SecaoExemplo"
	cChave := "ChaveExemplo"
	nValor := 86887

	WriteProfString(cSecao, cChave, NToC(nValor, 10))
	nRecuperado := GetProfInt(cSecao, cChave, 0)

	cMensagem += "Seção [" + cSecao + "], chave [" + cChave + ;    "] e conteúdo [" + cValToChar(nValor) + "] " + ;

	IIf(!(nRecuperado == nValor), "não ", " ") + "gravado e recuperado com sucesso!"
	//+----------------------------------------------------------------------------+
	//|Apresenta uma mensagem com os resultados obtidos                            |

	//+----------------------------------------------------------------------------+
	Return MsgInfo(cMensagem, "Exemplo do GetProfInt"
*/
