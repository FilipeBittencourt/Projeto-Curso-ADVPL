#INCLUDE "TOPCONN.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

User function VIXA265()	
	
	Local cCadastro 	:= "Liberar NF-e ou CT-e"	
	Private aSeek := {}, cArqTrb
	Private aRotina := MenuDef()
	Private oBrowse := FWmBrowse():New()

	CriaTabela()
	
	oBrowse:SetAlias( "TMP" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.F.)
	//oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
	//oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:DisableDetails()
	
	//Detalhes das colunas que serão exibidas
	oBrowse:SetColumns(MontaColunas("TMP_FILIAL",  	"FILIAL"	,01,	"@!",	0,	002,	0))
	oBrowse:SetColumns(MontaColunas("TMP_TIPO",    	"TIPO"	 	,02,	"@!",	0,	004,	0))
	oBrowse:SetColumns(MontaColunas("TMP_DOC",     	"DOC"	 	,03,	"@!",	0,	010,	0))
	oBrowse:SetColumns(MontaColunas("TMP_SERIE",   	"SERIE"	 	,04,	"@!",	0,	003,	0))
	oBrowse:SetColumns(MontaColunas("TMP_CODIGO",  	"CODIGO" 	,05,	"@!",	0,	006,	0))
	oBrowse:SetColumns(MontaColunas("TMP_NOME",    	"NOME"	 	,05,	"@!",	0,	150,	0))
	oBrowse:SetColumns(MontaColunas("TMP_EMISSA", 	"EMISSAO" 	,06,	"@!",	0,	010,	0))
	oBrowse:SetColumns(MontaColunas("TMP_VALOR",	"VALOR"	 	,07,	"@E 999,999,999.99", 0,020,0))
	oBrowse:SetColumns(MontaColunas("TMP_INFO1",	"MOTIVO"	,08,	""  , 0,500,0))
	oBrowse:Activate()
	
	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())
		cArqTrb := ""
		TMP->(DbCloseArea())
		delTabTmp('TMP')
    	dbClearAll()
	Endif
    	
return(Nil)

Static Function CriaTabela()

	Local cIndice1, cIndice2, cIndice3
	Local nI := 0
	Local aDados := {}, aFieFilter := {}, aValores := {}

	Local aCampos	:= {}

								  //3 = tipo				   //1 = TAMANHO             //2 =  DECIMAL
	AAdd(aCampos,{"TMP_FILIAL",  TAMSX3('GXG_FILIAL')[3] ,  TAMSX3('GXG_FILIAL')[1] , TAMSX3('GXG_FILIAL')[2]})
	AAdd(aCampos,{"TMP_TIPO",    "C"                     ,  04                      , 0})
	AAdd(aCampos,{"TMP_DOC",     "C"                     ,  09                      , 0})		
	AAdd(aCampos,{"TMP_DOC2",     "C"                     ,  16                      , 0})	
	AAdd(aCampos,{"TMP_SERIE",   TAMSX3('DS_SERIE')[3] ,    TAMSX3('DS_SERIE')[1] ,   TAMSX3('DS_SERIE')[2]})
	AAdd(aCampos,{"TMP_CODIGO",   TAMSX3('A2_COD')[3] ,    TAMSX3('A2_COD')[1] ,   TAMSX3('A2_COD')[2]})
	AAdd(aCampos,{"TMP_NOME",    TAMSX3('A2_NOME')[3] ,     TAMSX3('A2_NOME')[1] ,    TAMSX3('A2_NOME')[2]})
	AAdd(aCampos,{"TMP_EMISSA", TAMSX3('GXG_DTEMIS')[3] ,  TAMSX3('GXG_DTEMIS')[1] , TAMSX3('GXG_DTEMIS')[2]})
	AAdd(aCampos,{"TMP_VALOR",   TAMSX3('GXG_VLDF')[3] ,    TAMSX3('GXG_VLDF')[1] ,   TAMSX3('GXG_VLDF')[2]})
	AAdd(aCampos,{"TMP_INFO1",  TAMSX3('DS_YINFONF')[3] ,  TAMSX3('DS_YINFONF')[1] , TAMSX3('DS_YINFONF')[2]}) // CAMPOS MEMO
	AAdd(aCampos,{"TMP_INFO2",   TAMSX3('DS_YINFONF')[3] ,  TAMSX3('DS_YINFONF')[1] , TAMSX3('DS_YINFONF')[2]}) // CAMPOS MEMO
	AAdd(aCampos,{"TMP_USERLB",   TAMSX3('GXG_YUSERL')[3] ,  TAMSX3('GXG_YUSERL')[1] , TAMSX3('GXG_YUSERL')[2]})
	AAdd(aCampos,{"TMP_MOTIVO",  TAMSX3('DS_YINFONF')[3] ,  TAMSX3('DS_YINFONF')[1] , TAMSX3('DS_YINFONF')[2]}) // CAMPOS MEMO	
	
	
	//Criar tabela temporária
	cArqTrb   := CriaTrab(aCampos,.T.)
	
	//Definir indices da tabela
	cIndice1 := Alltrim(CriaTrab(,.F.))
	cIndice2 := cIndice1
	cIndice3 := cIndice1

	cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
	cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
	cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"

	If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf

	If File(cIndice2+OrdBagExt())
		FErase(cIndice2+OrdBagExt())
	EndIf

	If File(cIndice3+OrdBagExt())
		FErase(cIndice3+OrdBagExt())
	EndIf
	
	//Abrir a tabela
	dbUseArea(.T.,,cArqTrb,"TMP",Nil,.F.)
	
	/*Criar indice*/
	
	IndRegua("TMP", cIndice1, "TMP_DOC"	,,, "Indice DOCUMENTO")
	//IndRegua("TMP", cIndice1, "TMP_CODIGO"	,,, "Indice FORNECEDOR")
	dbClearIndex()
	dbSetIndex(cIndice1+OrdBagExt())
	//dbSetIndex(cIndice2+OrdBagExt())
	//dbSetIndex(cIndice3+OrdBagExt())	 

	
	aValores := PopulaCamp()	
	For nI:= 1 to len(aValores)
		If RecLock("TMP",.t.)
			TMP->TMP_FILIAL := aValores[nI,1]  
			TMP->TMP_TIPO := aValores[nI,2]    
			TMP->TMP_DOC := aValores[nI,3]  			   
			TMP->TMP_DOC2 := aValores[nI,4]
			TMP->TMP_SERIE := aValores[nI,5]   
			TMP->TMP_CODIGO := aValores[nI,6]
			TMP->TMP_NOME := aValores[nI,7]    
			TMP->TMP_EMISSA := aValores[nI,8]
			TMP->TMP_VALOR := aValores[nI,9]
			TMP->TMP_INFO1 := aValores[nI,10]
			MsUnLock()
		Endif
	Next

	
	//Campos que irão compor o combo de pesquisa na tela principal
	Aadd(aSeek,{"Doc"   , {{"","C",06,0, "TMP_DOC"   ,"@!"}}, 1, .T. } )
	//Aadd(aSeek,{"Doc", {{"","C",09,0, "TMP_DOC","@!"}}, 2, .T. } )
	//Aadd(aSeek,{"Nome" , {{"","C",50,0, "TR_NOME" ,"@!"}}, 3, .T. } )
	
	/*
	//Campos que irão compor a tela de filtro
	Aadd(aFieFilter,{"TR_ID"	, "ID"   , "C", 06, 0,"@!"})
	Aadd(aFieFilter,{"TR_LOGIN"	, "Login", "C", 20, 0,"@!"})
	Aadd(aFieFilter,{"TR_NOME"	, "Nome" , "C", 50, 0,"@!"})
	*/
	dbSelectArea("TMP")
	TMP->(DbGoTop())
	oBrowse:Refresh()
Return

 
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0
	
	
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}
 
Static Function MenuDef()

	Local aArea		:= GetArea()
	Local aRotina 	:= {}
	AADD(aRotina, {"Liberar" , "U_ValLib"	, 0 , 4, 0, nil } )
	AADD(aRotina, {"Rejeitar" , "U_ValRej"	, 0 , 4, 0, nil } )

Return( aRotina )
 

Static Function PopulaCamp()

	Local cAlias 	:= GetNextAlias()
	Local  aValores := {}

		BeginSQL Alias cAlias

		SELECT DISTINCT 

		'' AS FILIAL
		,'NF-e' AS TIPO
		,SDS.DS_DOC AS DOC
		,'' AS DOC2
		,SDS.DS_SERIE AS SERIE
		//,'NFe '+SDS.DS_DOC+'-'+SDS.DS_SERIE AS NumSerie 
		,SA2.A2_COD as 	 CODIGO
		,LTRIM(RTRIM(SA2.A2_NOME)) 	as 	 NOME 
		,convert(date,SDS.DS_EMISSA,103) AS EMISSAO
		,SDS.DS_VALMERC   AS VALOR
		,ISNULL(CONVERT(VARCHAR(1024), CONVERT(VARBINARY(1024), SDS.DS_YINFONF)), '') AS YINFO1	
		,ISNULL(CONVERT(VARCHAR(1024), CONVERT(VARBINARY(1024), SDS.DS_DOCLOG )),'') AS YINFO2 
		,SDS.DS_YUSERLB  AS USERLIB
		,ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),SDS.DS_YMOTIVO )),'') AS MOTIVO 	

			FROM   %table:SDS% SDS

			INNER JOIN  %table:SA2% SA2 ON SDS.DS_CNPJ = SA2.A2_CGC

			WHERE SDS.D_E_L_E_T_ = ''
			AND SDS.DS_YVLDXML = '1' 
			AND SDS.DS_YUSERLB = ''


		UNION  

		SELECT DISTINCT 

			GXG.GXG_FILIAL AS FILIAL
			,'CT-e' AS TIPO	
			,LTRIM(RTRIM(GXG.GXG_NRDF)) AS DOC 
			,LTRIM(RTRIM(GXG.GXG_NRIMP)) AS DOC2
			,GXG.GXG_SERDF AS SERIE
			,SA4.A4_COD as 	CODIGO
			,LTRIM(RTRIM(SA4.A4_NOME)) 	as 	 NOME  
			,convert(date,GXG.GXG_DTEMIS,103) AS EMISSAO
			,GXG.GXG_VLDF AS VALOR 
			, ISNULL(CONVERT(VARCHAR(1024), CONVERT(VARBINARY(1024), GXG.GXG_YBLMOT)),'') AS YINFO1 			
			, ISNULL(CONVERT(VARCHAR(1024), CONVERT(VARBINARY(1024), GXG.GXG_OBS)),'') AS YINFO2
			,GXG.GXG_YUSERL AS USERLIB
			,ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),GXG.GXG_YMOTIV )),'') AS MOTIVO 

			FROM   %table:GXG% GXG

			INNER JOIN %table:SA4% SA4  ON GXG.GXG_EMISDF = SA4.A4_CGC		 				

			WHERE GXG.D_E_L_E_T_ = '' 
			AND SA4.D_E_L_E_T_ = '' 
			AND SA4.A4_MSBLQL <> '1'
			AND (GXG.GXG_YVLDXM = '5' OR (GXG.GXG_YVLDXM <> '' AND GXG.GXG_EDISIT = '5' ))
			AND GXG.GXG_YUSERL = ''

			order by TIPO desc , EMISSAO
			
	EndSQL
	 
	//Array contendo os campos da tabela temporária
	(cAlias)->(dbGoTop())
	While (cAlias)->(!Eof()) 

		/*popular a tabela*/
		aadd(aValores,{(cAlias)->FILIAL,;
		(cAlias)->TIPO,;
		(cAlias)->DOC,;
		(cAlias)->DOC2,;
		(cAlias)->SERIE,;			
		(cAlias)->CODIGO,;
		(cAlias)->NOME,;
		(cAlias)->EMISSAO,;
		(cAlias)->VALOR,;
		(cAlias)->YINFO1,;
		(cAlias)->YINFO2,;		
		(cAlias)->USERLIB,;
		(cAlias)->MOTIVO})
		(cAlias)->(dbSkip())

	EndDo	

Return( aValores )

 
//==================================================
//Validação para liberar o CT-e ou NF-e
//==================================================
User Function ValLib()

	Local cUsrAux	:= ""
	Local cPswAux	:= ""
	Local cMtvAux	:= ""
	Local aAreaGXG :=  GXG->(GetArea()) 
	Local aAreaSDS :=  SDS->(GetArea()) 
	Local aValores := {}	

	If TMP->TMP_TIPO == "CT-e"

		GXG->(DbSetOrder(1)) // GXG_FILIAL, GXG_NRIMP, R_E_C_N_O_, D_E_L_E_T_
		If (GXG->(DbSeek(xFilial("GXG")+TMP->TMP_DOC2)))

			If U_VIXA259(@cUsrAux, @cPswAux, .T. , @cMtvAux)				
			 
				RecLock("GXG", .F.)
					GXG->GXG_YVLDXM  := "2"  //- X3_CBOX =  "1=Importado;2=Importado com erro;3=Rejeitado;4=Processado;5=Erro Impeditivo"					
					GXG->GXG_YUSERL  := cUsrAux  
					GXG->GXG_YMOTIV  := cMtvAux 
				GXG->(MsUnLock())
				MsgInfo("O <b>"+cValToChar(TMP->TMP_TIPO)+" - "+cValToChar(TMP->TMP_DOC)+"</b>  foi liberado.", "Aviso" )
				 
			EndIf 

		EndIf


	ElseIf TMP->TMP_TIPO == "NF-e" 

		SDS->(DbSetOrder(1))  //DS_FILIAL, DS_DOC, DS_SERIE, DS_FORNEC, DS_LOJA, R_E_C_N_O_, D_E_L_E_T_
		If (SDS->(DbSeek(xFilial("SDS")+TMP->TMP_DOC+TMP->TMP_SERIE+TMP->TMP_CODIGO)))

			If U_VIXA259(@cUsrAux, @cPswAux, .T. , @cMtvAux)				
			 
				RecLock("SDS", .F.)
					SDS->DS_YVLDXML := "2"  //0=Xml Ok;1=Bloqueado;2=Desbloqueado;3=Rejeitado
					SDS->DS_YUSERLB := cUsrAux 
					SDS->DS_YMOTIVO := cMtvAux 
				SDS->(MsUnLock())
				MsgInfo("O <b>"+cValToChar(TMP->TMP_TIPO)+" - "+cValToChar(TMP->TMP_DOC)+"</b>  foi liberado.", "Aviso" )
				 
			EndIf 

		EndIf

	EndIf 

	RestArea(aAreaGXG) 
	RestArea(aAreaSDS) 
	

	//Deleta a tabela temporaria e recria e atualiza o Browse
	TMP->(DbCloseArea())
	delTabTmp('TMP')
	dbClearAll()
	CriaTabela()


Return

//==================================================
//Rejeita o CT-e ou NF-e
//==================================================
User Function ValRej()

	Local cUsrAux	:= ""
	Local cPswAux	:= ""
	Local cMtvAux	:= ""
	Local aAreaGXG :=  GXG->(GetArea()) 
	Local aAreaSDS :=  SDS->(GetArea()) 
	Local aValores := {}

	If TMP->TMP_TIPO == "CT-e"

		GXG->(DbSetOrder(1)) // GXG_FILIAL, GXG_NRIMP, R_E_C_N_O_, D_E_L_E_T_
		If (GXG->(DbSeek(xFilial("GXG")+TMP->TMP_DOC2)))

			If U_VIXA259(@cUsrAux, @cPswAux, .T. , @cMtvAux)				
			 
				RecLock("GXG", .F.)
					GXG->GXG_YVLDXM  := "3"  //- X3_CBOX =  "1=Importado;2=Importado com erro;3=Rejeitado;4=Processado;5=Erro Impeditivo"					
					GXG->GXG_YUSERL  := cUsrAux  
					GXG->GXG_YMOTIV  := cMtvAux 
				GXG->(MsUnLock())
				MsgInfo("O <b>"+cValToChar(TMP->TMP_TIPO)+" - "+cValToChar(TMP->TMP_DOC)+"</b>  foi Rejeitado.", "Aviso" )
				 
			EndIf 

		EndIf


	ElseIf TMP->TMP_TIPO == "NF-e" 

		SDS->(DbSetOrder(1))  //DS_FILIAL, DS_DOC, DS_SERIE, DS_FORNEC, DS_LOJA, R_E_C_N_O_, D_E_L_E_T_
		If (SDS->(DbSeek(xFilial("SDS")+TMP->TMP_DOC+TMP->TMP_SERIE+TMP->TMP_CODIGO)))

			If U_VIXA259(@cUsrAux, @cPswAux, .T. , @cMtvAux)				
			 
				RecLock("SDS", .F.)
					SDS->DS_YVLDXML := "3"  //0=Xml Ok;1=Bloqueado;2=Desbloqueado;3=Rejeitado
					SDS->DS_YUSERLB := cUsrAux 
					SDS->DS_YMOTIVO := cMtvAux 
				SDS->(MsUnLock())
				MsgInfo("O <b>"+cValToChar(TMP->TMP_TIPO)+" - "+cValToChar(TMP->TMP_DOC)+"</b>  foi Rejeitado.", "Aviso" )
				 
			EndIf 

		EndIf

	EndIf 

	RestArea(aAreaGXG) 
	RestArea(aAreaSDS) 
	

	//Deleta a tabela temporaria e recria e atualiza o Browse
	TMP->(DbCloseArea())
	delTabTmp('TMP')
	dbClearAll()
	CriaTabela()

Return
