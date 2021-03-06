#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define cPerg 'VIXA116'

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: VIXA116
Tipo		: Fun��o de Usu�rio
Descri��o	: Gera��o de pedido de compras autom�tico
Uso			: Compras - Menu
Par�metros	:
Retorno	:
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 29/10/2015 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
User Function VIXA116()
	Local aSays		:= {} 
	Local aButtons 	:= {}
	Local lRet 		:= .T.
	Local lIntegDef := .F.
	Local n1Cnt		:= 0   
	Local nOpca 	:= 0
	Private aGrupos := {}
	Private aLinhas := {}

	Private cCadastro := OemToAnsi('Gera��o de pedidos autom�tico')		//"Elim. de res�duos dos Pedidos de Compras"	
	
	CriaPerg()
	Pergunte(cPerg,.F.)
	
	//GetParamBox()

	AADD(aSays,OemToAnsi('Este programa tem o objetivo de gerar pedidos de compras'))
	AADD(aSays,OemToAnsi('por fabricante e a curva do produto'))
	//AADD(aSays,OemToAnsi('STR0004'))

	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.t.) } } )
	AADD(aButtons, { 1,.T.,{|o| CriaPedido(o:oWnd) } } ) 	//Confirma
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} ) 	//Fecha

	FormBatch( cCadastro, aSays, aButtons,,200,445 )	

Return

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: CriaPerg
Tipo		: Fun��o est�tica
Descri��o	: Cria o grupo de perguntas
Par�metros	:
Retorno	: nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 29/10/2015 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function CriaPerg()

	u_zPutSX1(cPerg,'01','Fabricante?'			,''	,''	,'mv_ch1'	,'C', TAMSX3("Z1_COD")[1]	, 0, 0,'G','','SZ1','','','mv_par01','','','','','','','','','','','','','','','','')
	u_zPutSX1(cPerg,'02','Curva De?'			,''	,''	,'mv_ch2'	,'C', 1					  	, 0, 0,'G','',''   ,'','','mv_par02','','','','','','','','','','','','','','','','')	
	u_zPutSX1(cPerg,'03','Curva At�?'	 		,''	,''	,'mv_ch3'	,'C', 1                   	, 0, 0,'G','',''   ,'','','mv_par03','','','','','','','','','','','','','','','','')
	u_zPutSX1(cPerg,'04','Tipo de Compra?'		,''	,''	,'mv_ch4'	,'C', 1						, 0, 1,'C','',''   ,'','','MV_PAR04','Oportunidade','Oportunidade','Oportunidade',,'Demanda','Demanda','Demanda')
	u_zPutSX1(cPerg,'05','Quant. Dias?'			,''	,''	,'mv_ch5'	,'N', 3                   	, 0, 0,'G','',''   ,'','','mv_par05','','','','','','','','','','','','','','','','')
	u_zPutSX1(cPerg,'06','Grupo De?'			,''	,''	,'mv_ch6'	,'C', TAMSX3("BM_GRUPO")[1]	, 0, 0,'G','','SBM','','','mv_par06','','','','','','','','','','','','','','','','')
	u_zPutSX1(cPerg,'07','Grupo Ate?'			,''	,''	,'mv_ch7'	,'C', TAMSX3("BM_GRUPO")[1]	, 0, 0,'G','','SBM','','','mv_par07','','','','','','','','','','','','','','','','')

Return

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: CriaPedido
Tipo		: Fun��o est�tica
Descri��o	: Cria o pedido de compras
Par�metros	:
Retorno	: nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 29/10/2015 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function CriaPedido(oTela)
	Local cEmail := ''
	Local cNomeFab := ''

	cNomeFab := AnaliFabri()
	If AllTrim(cNomeFab) == ''
		Aviso("Aten��o","Fabricante n�o encontrado.",{"Voltar"})
		Return
	EndIf

	If !AnalisaDados()
		Return
	EndIf

	If !MsgYesNo('Ser�(�o) gerado(s) pedido(s) de produto(s) do fabricante "'+cNomeFab+'", gostaria de continuar?')
		Return
	EndIf

	cEmail := AllTrim(UsrRetMail(RetCodUsr()))	

	If AllTrim(cEmail) != ''
		Aviso("Aten��o","O sistema far� a an�lise de produtos a serem comprados e no final enviar� um e-mail para "+cEmail,{"Fechar"})
	Else
		Aviso("Aten��o","O sistema far� a an�lise de produtos a serem comprados, por�m n�o enviar� um e-mail informando o termino da "+;
		"gera��o pois seu usu�rio n�o tem um e-mail cadastrado. Entre em contato com a T.I. para cadastrar um e-mail para este usu�rio",{"Fechar"})
	EndIf

	If MV_PAR04 == 1 .AND. MV_PAR05 > 0
		StartJob( "U_VIXA116I", GetEnvServer(),.F.,{cEmpAnt, cFilAnt, MV_PAR01, MV_PAR02, MV_PAR03, cEmail, MV_PAR05, MV_PAR06, MV_PAR07})
		//U_VIXA116I({cEmpAnt, cFilAnt, MV_PAR01, MV_PAR02, MV_PAR03, cEmail, MV_PAR05, MV_PAR06, MV_PAR07})
	Else
		StartJob( "U_VIXA116I", GetEnvServer(),.F.,{cEmpAnt, cFilAnt, MV_PAR01, MV_PAR02, MV_PAR03, cEmail, 0 , MV_PAR06, MV_PAR07})
		//U_VIXA116I({cEmpAnt, cFilAnt, MV_PAR01, MV_PAR02, MV_PAR03, cEmail, 0 , MV_PAR06, MV_PAR07})
	EndIf	
	oTela:End()
Return

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: CriaPerg
Tipo		: Fun��o est�tica
Descri��o	: Cria o grupo de perguntas
Par�metros	:
Retorno	: nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 29/10/2015 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
User Function VIXA116I(aParametros)
	Local cEmpJob	:= aParametros[1]
	Local cFilJob	:= aParametros[2]
	Local cFabric	:= aParametros[3]
	Local cCurvaDe	:= aParametros[4]
	Local cCurvaAte	:= aParametros[5]
	Local cEmailLog	:= aParametros[6]
	Local nQdeDias	:= aParametros[7]
	Local cGrupoDe	:= aParametros[8]
	Local cGrupoAte	:= aParametros[9]
	Local cAssunto	:= 'Gera��o de pedido de compras autom�tico'
	Local cMensagem	:= 'A gera��o de pedidos de compras foi finalizada'
	Local cAnexos		:= ''
	Local lAbreEmp	:= .F.

	lAbreEmp := Type('cFilAnt') == 'U' 

	If lAbreEmp
		RPCCLEARENV()
		RPCSETENV(cEmpJob,cFilJob,,,"COM")
	EndIf	
 		
	SetFunName('VIXA116')	
	cMensagem += CHR(13)+CHR(10)+CHR(13)+CHR(10)+ ;
	'Segue abaixo, lista de processos executados'+CHR(13)+CHR(10)+;
	U_VIXA038( ,cFabric, cCurvaDe, cCurvaAte, nQdeDias, cGrupoDe, cGrupoAte)

	If AllTrim(cEmailLog) != ''
		U_EnvEmail(cEmailLog,cAssunto,cMensagem,cAnexos, .F.)
	EndIf	

	If lAbreEmp
		RPCCLEARENV()
	EndIf

Return


/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AnaliCli
Tipo		: Fun��o est�tica
Descri��o	: Analisa se a nota fiscal informada est� correta e se a mesma j� foi enviada para a SEFAZ
Par�metros	:
Retorno	: Boolean
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 26/10/2015 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function AnaliFabri()
	Local aArea 	:= GetArea()
	Local cNome	:= ''
	Local cFabric	:= MV_PAR01

	If AllTrim(cFabric) == ''
		Return .T.
	EndIf

	DbSelectArea('SZ1')
	DbSetOrder(1)
	If SZ1->(DbSeek(xFilial('SZ1')+cFabric))
		cNome := SZ1->Z1_FABRIC
	EndIf

	RestArea(aArea)

Return AllTrim(cNome)

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AnalisaDados
Tipo		: Fun��o est�tica
Descri��o	: Analisa se a nota fiscal informada est� correta e se a mesma j� foi enviada para a SEFAZ
Par�metros	:
Retorno	: Boolean
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 26/10/2015 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function AnalisaDados()
	Local lValid 		:= .T. 
	Local cFabric		:= MV_PAR01
	Local cCurvaDe	:= MV_PAR02
	Local cCurvaAte	:= MV_PAR03

	If AllTrim(cFabric) == ''
		Aviso('Aten��o', 'Favor informar o c�digo do fabricante!',{"Fechar"})
		lValid := .F.
		/*	ElseIf AllTrim(cCurvaDe) == ''
		Aviso('Aten��o', 'Favor informar a curva de?',{"Fechar"})
		lValid := .F.
		ElseIf AllTrim(cCurvaAte) == ''
		Aviso('Aten��o', 'Favor informar a curva ate?',{"Fechar"})
		lValid := .F.
		*/	ElseIf !Posicione('SZ1', 1, xFilial('SZ1')+cFabric, 'Found()')
		Aviso('Aten��o', 'Fabricante n�o cadastrado, favor informar um novo c�digo!',{"Fechar"})
		lValid := .F.
	ElseIf cCurvaDe <= ''
		Aviso('Aten��o', 'Favor informar a curva inicial!',{"Fechar"})
		lValid := .F.
	ElseIf cCurvaAte <= ''
		Aviso('Aten��o', 'Favor informar a curva final!',{"Fechar"})
		lValid := .F.
	ElseIf cCurvaDe > cCurvaAte	
		Aviso('Aten��o', 'A curva inicial n�o pode ser maior que a curva final, favor corrigir!',{"Fechar"})
		lValid := .F.
	EndIf

Return lValid


/*/{Protheus.doc} GetParamBox
//TODO Descri��o auto-gerada.
@author leonardo.gomes
@since 15/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GetParamBox()	

	Local cTipo       := ""
	Local aPerg       := {}
	local cTela		  := "TESTE"
	local aParam  	  := { space(TAMSX3("Z1_COD")[1]),space(40),space(40),space(1),space(1),0 }
	local cParGnreImp := SM0->M0_CODIGO+SM0->M0_CODFIL+"VIXR116"
	Local lOkParam    := .F.	

	/*
	u_zPutSX1(cPerg,'01','Fabricante?'	  ,''	,''	,'mv_ch1'	,'C', TAMSX3("Z1_COD")[1]	, 0, 0,'G','','SZ1','','','mv_par01','','','','','','','','','','','','','','','','')	
	u_zPutSX1(cPerg,'02','Curva De?'	  ,'','','mv_ch2','C', 1, 0, 0,'G','','','','','mv_par02','','','','','','','','','','','','','','','','')	
	u_zPutSX1(cPerg,'03','Curva At�?'	  ,'','','mv_ch3','C', 1, 0, 0,'G','','','','','mv_par03','','','','','','','','','','','','','','','','')
	u_zPutSX1(cPerg,'04','Tipo de Compra?','','','mv_ch4','C', 1, 0, 1,'C','','','','','MV_PAR04','Oportunidade','Oportunidade','Oportunidade',,'Demanda','Demanda','Demanda')
	u_zPutSX1(cPerg,'05','Quant. Dias?'	  ,'','','mv_ch5','N', 3, 0, 0,'G','','','','','mv_par05','','','','','','','','','','','','','','','','')
	*/

	MV_PAR01 := aParam[01]
	MV_PAR02 := aParam[02]
	MV_PAR03 := aParam[03]
	MV_PAR04 := aParam[04]
	MV_PAR05 := aParam[05]
	MV_PAR06 := aParam[06]	

	aadd(aPerg,{1,'Fabricante:' ,space(TAMSX3("Z1_COD")[1]),''           ,'StaticCall(VIXA116, GetGrupos, @aGrupos)','SZ1','.T.',TAMSX3("Z1_COD")[1],.T.})
	aadd(aPerg,{1,'Grupo:'      ,space(40)                 ,''           ,'StaticCall(VIXA116, GetLinhas, @aLinhas)',''   ,'.T.',40              ,.T.})	
	aadd(aPerg,{1,'Linha:'      ,space(40)                 ,''           ,'.T.'        ,''   ,'.T.',40              ,.T.})	
	aadd(aPerg,{1,'Curva De:'   ,space(1)                  ,''           ,'.T.'        ,''   ,'.T.',1               ,.T.})
	aadd(aPerg,{1,'Curva At�:'  ,space(1)                  ,''           ,'.T.'        ,''   ,'.T.',1               ,.T.})	
	aAdd(aPerg,{1,"Quant. Dias:",0                         ,"@E 9,999.99","mv_par06>0" ,''   ,'.T.',3               ,.T.})	

	lOkParam := ParamBox(aPerg,cTela,@aParam,,,,,,,cParGnreImp,.T.,.T.)	

	If !lOkParam
		Return .T.
	EndIf

Return


/*/{Protheus.doc} GetGrupos
//TODO Descri��o auto-gerada.
@author leonardo.gomes
@since 15/10/2018
@version 1.0
@return ${return}, ${return_description}
@param aGrupos, array, descricao
@type function
/*/
Static Function GetGrupos(aGrupos)

	Local cTitulo:= OemtoAnsi("Dias da Semana")
	Local MvPar
	Local MvParDef	:="1234567"	
	Local lRet 		:= .T.
	Local lOpt 		:= .F.
	Local cAlias 	:= Alias()
	Local cAliasGrp	:= GetNextAlias()
	Local cQuery    := ""
	Local aHeadSBM  := {}
	Local aSize     := MsAdvSize()
	Local cGrupos   := ""

	aGrupos := {}

	oDlgTrans := MSDialog():New( aSize[7],aSize[1],600,800,"Transmiss�o de Nfs-e",,,.F.,,,,,,.T.,,,.T. )

	BeginSQL alias cAliasGrp

		SELECT DISTINCT
		'' AS BM_OK, SBM.BM_GRUPO, SBM.BM_DESC
		FROM 
		%table:SB1% SB1 (NOLOCK)		
		INNER JOIN
		%table:SBM% SBM (NOLOCK)			
		ON
		SBM.BM_GRUPO = SUBSTRING(SB1.B1_GRUPO,1,2) AND
		SBM.%NotDel%
		WHERE 
		B1_YDESCR2 = %Exp:MV_PAR01% AND 
		SB1.%NotDel%
	EndSQL	

	cQuery := GetLastQuery()[2]

	If Select('TRBSBM') > 1
		TRBSBM->(DbCloseArea())
	EndIf

	aStru := (cAliasGrp)->(dbStruct())
	cTrab := CriaTrab(aStru)
	dbUseArea(.T.,,cTrab,"TRBSBM")
	IndRegua("TRBSBM", cTrab, "BM_GRUPO+BM_DESC",,,"Indexando registros...")

	(cAliasGrp)->(dbGoTop())

	SqlToTrb(cQuery, aStru, "TRBSBM")

	For i := 1 to Len(aStru)
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(aStru[i, 1]) //.and. !aStru[i, 1] $ "F2_OK,E2_NUM,RECNOSF2,E2_NUM,E2_PARCELA,E2_PREFIXO,E2_TIPO,E2_FORNECE,E2_LOJA,ZZL_FABRIC"
			aAdd(aHeadSBM,{;
			SX3->X3_TITULO,;
			aStru[i, 1],;
			SX3->X3_TIPO,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_PICTURE} )					
		Endif
	Next

	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetOwner(oDlgTrans)
	oBrowse:SetFieldMark('BM_OK')
	//oBrowse:SetValid({|| MarkGrupos(@cGrupos) })
	oBrowse:SetDescription("Grupos")
	oBrowse:SetAlias("TRBSBM")
	oBrowse:SetFields(aHeadSBM)
	oBrowse:SetProfileID('1')
	oBrowse:SetMenuDef('')	
	oBrowse:SetAllMark({|| MarkAll()})
	oBrowse:Activate()

	oDlgTrans:Activate(,,,.T.)	
	
	MarkGrupos(@cGrupos)
	
	MV_PAR02 := cGrupos

Return aGrupos

/*/{Protheus.doc} GetLinhas
//TODO Descri��o auto-gerada.
@author leonardo.gomes
@since 15/10/2018
@version 1.0
@return ${return}, ${return_description}
@param aGrupos, array, descricao
@type function
/*/
Static Function GetLinhas(aLinhas)

	Local cTitulo:= OemtoAnsi("Dias da Semana")
	Local MvPar
	Local MvParDef	:="1234567"	
	Local lRet 		:= .T.
	Local lOpt 		:= .F.
	Local cAlias 	:= Alias()
	Local cAliasLin	:= GetNextAlias()
	Local cQuery    := ""
	Local aHeadSBM  := {}
	Local aSize     := MsAdvSize()
	Local cGrupos   := ""

	aGrupos := {}

	oDlgTrans := MSDialog():New( aSize[7],aSize[1],600,800,"Transmiss�o de Nfs-e",,,.F.,,,,,,.T.,,,.T. )

	BeginSQL alias cAliasLin

		SELECT DISTINCT
			' ' AS BM_OK
		   ,SBM.BM_GRUPO
		   ,SBM.BM_DESC
		FROM %table:SBM% SBM
		WHERE 
			SBM.BM_GRUPO NOT IN (cGrupos) AND
			SUBSTRING(SBM.BM_GRUPO,1,2) IN (cGrupos)
		AND SBM.%NotDel%
		ORDER BY SBM.BM_GRUPO	
	
	EndSQL	

	cQuery := GetLastQuery()[2]

	If Select('TRBSBM') > 1
		TRBSBM->(DbCloseArea())
	EndIf

	aStru := (cAliasLin)->(dbStruct())
	cTrab := CriaTrab(aStru)
	dbUseArea(.T.,,cTrab,"TRBSBM")
	IndRegua("TRBSBM", cTrab, "BM_GRUPO+BM_DESC",,,"Indexando registros...")

	(cAliasLin)->(dbGoTop())

	SqlToTrb(cQuery, aStru, "TRBSBM")

	For i := 1 to Len(aStru)
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(aStru[i, 1]) //.and. !aStru[i, 1] $ "F2_OK,E2_NUM,RECNOSF2,E2_NUM,E2_PARCELA,E2_PREFIXO,E2_TIPO,E2_FORNECE,E2_LOJA,ZZL_FABRIC"
			aAdd(aHeadSBM,{;
			SX3->X3_TITULO,;
			aStru[i, 1],;
			SX3->X3_TIPO,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_PICTURE} )					
		Endif
	Next

	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetOwner(oDlgTrans)
	oBrowse:SetFieldMark('BM_OK')
	//oBrowse:SetValid({|| MarkGrupos(@cGrupos) })
	oBrowse:SetDescription("Grupos")
	oBrowse:SetAlias("TRBSBM")
	oBrowse:SetFields(aHeadSBM)
	oBrowse:SetProfileID('1')
	oBrowse:SetMenuDef('')	
	oBrowse:SetAllMark({|| MarkAll()})
	oBrowse:Activate()

	oDlgTrans:Activate(,,,.T.)	
	
	MarkGrupos(@cGrupos)
	
	MV_PAR02 := cGrupos

Return aGrupos

Static Function MarkGrupos(cGrupos)

	Local cMarca := oBrowse:Mark()	
	
	cGrupos := ""

	TRBSBM->(dbGoTop())

	While TRBSBM->(!Eof())		

		If TRBSBM->BM_OK == cMarca
			cGrupos += TRBSBM->BM_GRUPO + ','
		EndIf

		TRBSBM->(dbSkip())

	EndDo
	
Return 

Static Function fOpGrupo(aGrupos, l1Elem, lTipoRet)

	Local cTitulo:=""
	Local MvPar
	Local MvParDef:=""

	Private aSit := {}
	l1Elem := If (l1Elem = Nil , .F. , .T.)

	DEFAULT lTipoRet := .T.

	cAlias := Alias() 					 // Salva Alias Anterior

	IF lTipoRet
		MvPar := (Alltrim(ReadVar()))
		mvRet := Alltrim(ReadVar())	
	EndIF	

	for var:= 1 to Len(aGrupos)
		aadd(aSit, aGrupos[var][2])
		MvParDef += aGrupos[var][1]+','
	next 

	//aSit := {"A - TODOS","B - LIBERADOS","C - BLOQUEADOS"}
	//MvParDef:="ABC"
	cTitulo :="Tipos de Situa��o"

	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,l1Elem)  // Chama funcao f_Opcoes
			MvRet := mvpar                                                                          // Devolve Resultado
		EndIF
	EndIF

	dbSelectArea(cAlias) 								 // Retorna Alias

Return ( IF( lTipoRet , .T. , MvParDef ) )

static Function MarkAll()

	Local cMarca   := oBrowse:Mark()

	TRBSBM->(DbGotop())

	While TRBSBM->(!Eof())
		Reclock('TRBSBM',.F.)
		TRBSBM->BM_OK := IIf(TRBSBM->BM_OK == cMarca,"",cMarca)
		MsUnlock()
		TRBSBM->(DbSkip())
	EndDo

	oBrowse:Refresh(.T.)
Return