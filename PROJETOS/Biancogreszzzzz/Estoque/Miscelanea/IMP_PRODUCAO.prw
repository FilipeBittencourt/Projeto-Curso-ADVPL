#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMP_PRD   ºAutor  ³Fernando Rocha      º Data ³  06/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ IMPORTAR PRODUCAO DO ECOSIS PARA PROTHEUS                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function IMP_PRD(aEmpJob)
Private cLogSD3		:= ""
Private _cTextMail	:= ""
Private _IViaEAuto	:= .T.

Private C_HTML  	:= ""
Private lOK        	:= .F.

Private _aTabImp 	:= {}
Private _aTabDel	:= {}
Private _aTabErro	:= {}

IF ValType(aEmpJob) <> "U"
	PREPARE ENVIRONMENT EMPRESA aEmpJob[1] FILIAL aEmpJob[2] MODULO "EST"
	
	// Rotina retirada de produção em 02/05/12 às 09:37 por Marcos Alberto Soprani. Foi substituida pela rotina BIA292
	Return
	
	ImpPrdProc()
ELSE
	
	// Rotina retirada de produção em 02/05/12 às 09:37 por Marcos Alberto Soprani. Foi substituida pela rotina BIA292
	//MsgSTOP("Rotina retirada de produção em 02/05/12","Atenção")
	//Return
	
	IF !MSGYESNO("Deseja importar a produção do Ecosis para o Protheus agora?","INTEGRAÇÃO ECOSIS X PROTHEUS")
		RETURN
	ELSE
		U_BIAMsgRun("PROCESSANDO IMPORTAÇÃO...",,{|| ImpPrdProc()})
	ENDIF
ENDIF

_cTextMail := GerarMail(cLogSD3)

MemoWrite("\LOGIMPPRD\PRD_"+DTOS(dDataBase)+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+".TXT", cLogSD3)

IF ValType(aEmpJob) <> "U"
	RESET ENVIRONMENT
ENDIF

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa Rotina de Importacao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ImpPrdProc()
Local cAliasTmp
Local dDataPrd
Local cLogAux := ""
Local _cTpMov

//CONSULTAR ETIQUETAS EMITIDAS AINDA NAO IMPORTADAS PARA O PROTHEUS
cAliasTmp := GetNextAlias()
If cEmpAnt == "01"
	BeginSql Alias cAliasTmp
		SELECT
		A.id_mov_prod
		, A.cod_transacao
		, A.cod_produto
		, A.ce_lote
		, A.ce_qtdade
		,substring(convert(varchar(10), B.etiq_data, 112),1,10) DATA
		,substring(convert(varchar(16), B.etiq_data, 120),12,5) HORA
		FROM DADOSEOS..cep_movimento_produto A
		JOIN DADOSEOS..cep_etiqueta_pallet B on B.id_cia = A.id_cia and B.cod_etiqueta = A.ce_numero_docto
		WHERE
		A.id_cia = 1
		and ((A.cod_transacao = 1) or (A.cod_transacao = 64 and A.ce_docto = 'CP'))
		and B.etiq_transito_producao = 0
		and A.ce_lote <> ' '
		and B.cod_endereco not in ('RETIDO')
		and convert(smalldatetime, A.ce_data_movimento, 120) >= convert(smalldatetime,convert(varchar(10),GetDate()-30,112)+' 06:00',120)
		and convert(smalldatetime, A.ce_data_movimento, 120) >= convert(smalldatetime,'20110510 06:00',120)
		and id_mov_prod not in (select D3_YIDECO from SD3010 SD3 where SD3.D3_FILIAL = '01' AND SD3.D3_YIDECO <> ' ' AND (SD3.D3_TM <> '499' OR SD3.D3_YORIMOV = 'PR0') AND SD3.%NotDel%)
		AND A.CE_NUMERO_DOCTO <= 259380
	EndSql
	//and isnull((select D3_YIDECO from SD3010 SD3 where SD3.D3_FILIAL = '01' AND SD3.D3_YIDECO = A.id_mov_prod AND D3_TM <> '499' AND SD3.%NotDel%),0) <= 0
	//and id_mov_prod not in (select D3_YIDECO from SD3010 SD3 where SD3.D3_FILIAL = '01' AND SD3.D3_YIDECO <> ' ' and  SD3.D3_TM <> '499' and SD3.%NotDel%)
	//and A.id_mov_prod not in ('89637','89638','102754','119401')
ElseIf cEmpAnt == "05"
	BeginSql Alias cAliasTmp
		SELECT
		A.id_mov_prod
		, A.cod_transacao
		, A.cod_produto
		, A.ce_lote
		, A.ce_qtdade
		,substring(convert(varchar(10), B.etiq_data, 112),1,10) DATA
		,substring(convert(varchar(16), B.etiq_data, 120),12,5) HORA
		FROM DADOS_05_EOS..cep_movimento_produto A
		JOIN DADOS_05_EOS..cep_etiqueta_pallet B on B.id_cia = A.id_cia and B.cod_etiqueta = A.ce_numero_docto
		WHERE
		A.id_cia = 1
		and ((A.cod_transacao = 1) or (A.cod_transacao = 64 and A.ce_docto = 'CP'))
		and B.etiq_transito_producao = 0
		and A.ce_lote <> ' '
		and B.cod_endereco not in ('RETIDO')
		and convert(smalldatetime, A.ce_data_movimento, 120) >= convert(smalldatetime,convert(varchar(10),GetDate()-30,112)+' 06:00',120)
		and convert(smalldatetime, A.ce_data_movimento, 120) >= convert(smalldatetime,'20120124 06:00',120)
		and convert(smalldatetime, B.etiq_data, 120) >= convert(smalldatetime,'20120124 06:00',120)
		and id_mov_prod not in (select D3_YIDECO from SD3050 SD3 where SD3.D3_FILIAL = '01' AND SD3.D3_YIDECO <> ' ' AND (SD3.D3_TM <> '499' OR SD3.D3_YORIMOV = 'PR0') AND SD3.D_E_L_E_T_ = ' ')
		AND A.CE_NUMERO_DOCTO <= 59058
		and ce_qtdade > 0
	EndSql
	// Incluido e retirada por Marcos Alberto
	// Inicialmente solicitaram disponibilizar esta implementação, entretanto, ela gerava problema nos dias de virada de saldo (decendialmente). Então dia 16/02/12 Jeová solicitou retirá-la.
	//and convert(smalldatetime, A.ce_data_movimento, 120) < convert(smalldatetime,convert(varchar(10),GetDate(),112)+' 06:00',120)
	
EndIf

(cAliasTmp)->(DbGoTop())
While .Not. (cAliasTmp)->(Eof())
	
	//Ajustar a data da movimentacao se for antes de 6 horas da manhã
	dDataPrd := STOD((cAliasTmp)->DATA)
	If (cAliasTmp)->HORA >= "00:00" .AND.(cAliasTmp)->HORA < "06:00"
		dDataPrd := dDataPrd - 1
	EndIf
	
	IF (cAliasTmp)->cod_transacao == 1
		_cTpMov := "500"
	ELSE
		_cTpMov := "501"
	ENDIF
	
	//Processar importacao da producao
	cLogAux := MovSD3(_cTpMov, dDataPrd, (cAliasTmp)->cod_produto , (cAliasTmp)->ce_qtdade , (cAliasTmp)->ce_lote, (cAliasTmp)->id_mov_prod )
	
	IF !Empty(cLogAux)
		cLogSD3 += cLogAux +CRLF
	ENDIF
	
	(cAliasTmp)->(DbSkip())
EndDo

(cAliasTmp)->(DbCloseArea())

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//EXECAUTO PARA INSERIR MOVIMENTO INTERNO
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static function MovSD3(cTipMov,dDataPrd,cProduto,nQuant,cLote, nIDEco)
Local cEnd 			:= "ZZZZ"
Local cLocal		:= ""
Local	nTable		:= ""
Local	nClvl			:= ""
Local _cLogTxt	:= ""
Local _cDoc 		:= ""
Local _cAliasAux
Local _cNumSeq

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .T.

//Define variaveis para uso de cada empresa
If cEmpAnt == "01"
	nTable	:= "%SD3010%"
	nClvl		:= "3000"
	cLocal	:= "02"
Else
	nTable	:= "%SD3050%"
	nClvl		:= "3003"
	cLocal 	:= "04"
EndIf

//VALIDACOES
SB1->(DbSetOrder(1))
if !SB1->(DbSeek(XFilial('SB1')+cProduto))
	_cLogTxt := "PRODUTO "+cProduto+" NAO EXISTE NO PROTHEUS! "
	RETURN(_cLogTxt)
endif

if (nQuant <= 0)
	_cLogTxt := "PRODUTO: "+cProduto+" - NAO E POSSIVEL INSERIR MOVIMENTO COM QUANTIDADE <= 0"
	RETURN(_cLogTxt)
endif

if !Empty(cEnd)
	SBE->(DbSetOrder(1))
	if !SBE->(DbSeek(XFilial('SBE')+cLocal+cEnd))
		_cLogTxt := "ENDERECO: "+cEnd+" - NAO EXISTE NO PROTHEUS"
		RETURN(_cLogTxt)
	endif
endif

IF AllTrim(SB1->B1_YCLASSE) <> '5'
	SG1->(DbSetOrder(1))
	IF !SG1->(DbSeek(xFilial("SG1")+SUBSTR(cProduto,1,7)))
		_cLogTxt := "PRODUTO: "+cProduto+" - Este produto que está sendo produzido não contém estrutura cadastrada! "
		RETURN(_cLogTxt)
	ENDIF
ENDIF

//Busca o proximo numero para Movimento Producao
_cAliasAux := GetNextAlias()
BeginSql Alias _cAliasAux
	select max(D3_DOC) DOC from %Exp:nTable% where %NotDel%
EndSql
_cDoc := SOMA1((_cAliasAux)->DOC,Len((_cAliasAux)->DOC))
(_cAliasAux)->(DbCloseArea())

cCF := iif(Val(cTipMov) > 500,'RE0','DE0')

aMovto := {}
aAdd(aMovto,{"D3_DOC"				,_cDoc            ,NIL})
aAdd(aMovto,{"D3_TM"       	,cTipMov          ,NIL})
aAdd(aMovto,{"D3_EMISSAO"  	,dDataPrd         ,NIL})
aAdd(aMovto,{"D3_CC"       	,"3000"						,NIL})
aAdd(aMovto,{"D3_CLVL"     	,nClvl            ,NIL})
aAdd(aMovto,{"D3_YIDECO"   	,nIDEco           ,NIL})
aAdd(aMovto,{"D3_COD"	  		,SB1->B1_COD	    ,NIL})
aAdd(aMovto,{"D3_UM"	  		,SB1->B1_UM		    ,NIL})
aAdd(aMovto,{"D3_QUANT"  		,nQuant	          ,NIL})
if !Empty(cEnd)
	aAdd(aMovto,{"D3_LOCAL"  		,cLocal		     		,NIL})
	aAdd(aMovto,{"D3_LOCALIZ"		,cEnd   		 			,NIL})
else
	aAdd(aMovto,{"D3_LOCAL"  		,cLocal						,NIL})
endif
if !Empty(cLote)
	aAdd(aMovto,{"D3_LOTECTL"  	,cLote				    ,NIL})
endif
aAdd(aMovto,{"D3_YORIMOV"   ,"PR0"            ,NIL}) // Por Marcos Alberto em 16/04/12 até que mude para o novo programa BIA292

MSExecAuto({|x,y| MATA240(x,y)},aMovto,3)

If lMsErroAuto
	_aAutoErro := GETAUTOGRLOG()
	_cLogTxt += "TM: "+cTipMov+" PRODUTO: "+cProduto+" LOTE: "+cLote+" QTDE.: "+Transform(nQuant,"@E 999,999,999.99")+CRLF+XCONVERRLOG(_aAutoErro)+CRLF
Else
	IF cCF == 'DE0'
		IF (_nPos := aScan(_aTabImp,{|x| x[1] == cProduto .And. x[2] == cLote .And. x[5] == dDataPrd })) > 0
			_aTabImp[_nPos][3] += nQuant
		ELSE
			AAdd(_aTabImp,{cProduto,cLote,nQuant,0,dDataPrd})
		ENDIF
		//CADASTRAR O LOTE AUTOMATICO
		ZZ9->(DbSetOrder(2))
		IF !ZZ9->(DbSeek(XFilial("ZZ9")+PADR(cProduto,15)+PADR(cLote,10)))
			RecLock("ZZ9",.T.)
			ZZ9->ZZ9_LOTE 		:= cLote
			ZZ9->ZZ9_PRODUT 	:= cProduto
			ZZ9->ZZ9_PESO  		:= SB1->B1_PESO
			ZZ9->ZZ9_PECA  		:= SB1->B1_YPECA
			ZZ9->ZZ9_DIVPA 		:= SB1->B1_YDIVPA
			ZZ9->ZZ9_PESEMB 	:= SB1->B1_YPESEMB
			ZZ9->ZZ9_MSBLQL 	:= '2'
			If !Empty(Substr(cLote, 1, 1)) .and. Substr(cLote, 1, 1) < "A" .and. Substr(cProduto,1,1) <> "I"
				ZZ9->ZZ9_RESTRI     := "*"
			EndIf
			ZZ9->(MsUnlock())
		ENDIF
	ELSE
		IF (_nPos := aScan(_aTabDel,{|x| x[1] == cProduto .And. x[2] == cLote .And. x[5] == dDataPrd})) > 0
			_aTabDel[_nPos][3] += nQuant
		ELSE
			AAdd(_aTabDel,{cProduto,cLote,nQuant,0,dDataPrd})
		ENDIF
	ENDIF
EndIf

//SO PRECISA FAZER ENDERECAMENTO PARA AS ENTRADAS
IF cCF == 'DE0'
	_cAliasAux := GetNextAlias()
	BeginSql Alias _cAliasAux
		SELECT D3_NUMSEQ FROM %Exp:nTable% WHERE D3_DOC = %EXP:_cDoc% AND D3_COD = %EXP:cProduto% AND D3_LOTECTL = %EXP:cLote% AND D3_TM = %EXP:cTipMov% AND %NotDel%
	EndSql
	
	IF !(_cAliasAux)->(Eof())
		_cNumSeq := (_cAliasAux)->D3_NUMSEQ
		(_cAliasAux)->(DbCloseArea())
		
		//aCabSDA := {}
		//Aadd( aCabSDA, { 'DA_PRODUTO', SB1->B1_COD	  , Nil } )
		//Aadd( aCabSDA, { 'DA_LOCAL  ', cLocal			    , Nil } )
		//Aadd( aCabSDA, { 'DA_DOC    ', _cDoc			    , Nil } )
		//Aadd( aCabSDA, { 'DA_NUMSEQ ', _cNumSeq 		  , Nil } )
		
		//aLinSDB := {}
		//Aadd( aLinSDB, { 'DB_ITEM   ', "0001"				, NIL } )
		//Aadd( aLinSDB, { 'DB_LOCAL  ', cLocal				, NIL } )
		//Aadd( aLinSDB, { 'DB_LOCALIZ', 'ZZZZ'				, NIL } )
		//Aadd( aLinSDB, { 'DB_QUANT  ', nQuant				, NIL } )
		//Aadd( aLinSDB, { 'DB_PRODUTO', SB1->B1_COD	  , NIL } )
		//Aadd( aLinSDB, { 'DB_DATA   ', dDataPrd			, NIL } )
		
		//Mata265(aCabSDA,{aLinSDB},3)
		
		aCabSDA    := {}
		aItSDB     := {}
		_aItensSDB := {}
		
		//Cabeçalho com a informação do item e NumSeq que sera endereçado.
		aCabSDA := {{"DA_PRODUTO" ,SB1->B1_COD              ,Nil},;
		{            "DA_NUMSEQ"  ,_cNumSeq                 ,Nil} }
		
		//Dados do item que será endereçado
		aItSDB := {{"DB_ITEM"	    ,"0001"	                  ,Nil},;
		{           "DB_ESTORNO"  ," "	                    ,Nil},;
		{           "DB_LOCALIZ"  ,"ZZZZ"                   ,Nil},;
		{           "DB_DATA"	    ,dDataPrd                 ,Nil},;
		{           "DB_QUANT"    ,nQuant                   ,Nil} }
		aadd(_aItensSDB,aitSDB)
		
		LMSERROAUTO := .F.
		lMsHelpAuto := .T.
		lAutoErrNoFile := .T.
		
		//Executa o endereçamento do item
		MATA265( aCabSDA, _aItensSDB, 3)
		
		IF LMSERROAUTO
			_aAutoErro := GETAUTOGRLOG()
			_cLogTxt += XCONVERRLOG(_aAutoErro)
		ELSE
			IF (_nPos := aScan(_aTabImp,{|x| x[1] == cProduto .And. x[2] == cLote .And. x[5] == dDataPrd})) > 0
				_aTabImp[_nPos][4] += nQuant
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN(_cLogTxt)


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//CONVERTER LOG DE ERRO PARA TEXTO SIMPLES
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
STATIC FUNCTION XCONVERRLOG(aAutoErro)
LOCAL cRet := ""
LOCAL nX := 1

FOR nX := 1 to Len(aAutoErro)
	cRet += aAutoErro[nX]+" - "
NEXT nX

RETURN cRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//GERAR O EMAIL COM O LOG DA IMPORTACAO PARA OS RESPONSAVEIS
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
STATIC FUNCTION GerarMail(_cLogErro)
Local I
Local cTexto := ""


cTexto += "<HTML>"
cTexto += "<HEAD><TITLE>IMPORTACAO DA PRODUCAO</TITLE></HEAD>"
cTexto += "<BODY>"

cTexto += "<P><strong>PRODUÇÕES</strong></P>"

FOR I := 1 To Len(_aTabImp)
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_aTabImp[I][1]))
	
	cTexto += "<P>"+"Data: "+DTOC(_aTabImp[I][5])+" Produto: "+_aTabImp[I][1]+" - "+AllTrim(SB1->B1_DESC)+" - Lote: "+_aTabImp[I][2]+" - Qtde Prod.: "+Transform(_aTabImp[I][3],"@E 999,999,999.99")+" - Qtde End.: "+Transform(_aTabImp[I][4],"@E 999,999,999.99")+"</P>"
NEXT I

IF Len(_aTabDel) > 0
	cTexto += "<P><strong>ESTORNOS</strong></P>"
	
	FOR I := 1 To Len(_aTabDel)
		cTexto += "<P>"+"Data: "+DTOC(_aTabDel[I][5])+" Produto: "+_aTabDel[I][1]+" - Lote: "+_aTabDel[I][2]+" - Qtde Prod.: "+Transform(_aTabDel[I][3],"@E 999,999,999.99")+"</P>"
	NEXT I
ENDIF

IF !Empty(_cLogErro)
	cTexto += "<P/>"
	cTexto += "<P><strong>LOG DE ERROS</strong></P>"
	cTexto += "<P>"+_cLogErro+"</P>"
ENDIF

cTexto += "</BODY>"
cTexto += "</HTML>"

PREP_EMAIL(cTexto)

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
²±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²
²±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±²
²±±º PREP_EMAIL          ºAutor  ³FERNANDO ROCHA      º Data ³  25/01/11   º±±²
²±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±²
²±±ºDesc.       ROTINA PARA GERAR O EMAIL E ENVIAR O MESMO                 º±±²
²±±º                                                                       º±±²
²±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±²
²±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION PREP_EMAIL(C_HTML)

If cEmpAnt == "01"
	cRecebe     := "producao.biancogres@biancogres.com.br"	// Email Destinatario
ElseIf cEmpAnt == "05"
	cRecebe     := "producao.incesa@incesa.ind.br" 			// Email Destinatario
EndIf
cAssunto	:= ""+IIF(CEMPANT == "05","INCESA - ","BIANCOGRES - ")+"IMPORTAÇÃO DA PRODUÇÃO ECOSIS > PROTHEUS"

U_BIAEnvMail(,cRecebe,cAssunto,C_HTML)

RETURN
