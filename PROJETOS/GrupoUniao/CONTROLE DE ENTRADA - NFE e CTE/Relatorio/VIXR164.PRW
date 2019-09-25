#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RWMAKE.CH"

/*
------------------------------------------------------------------------------------------------------------
Função		: VIXR164
Tipo		: Função de Usuário
Descrição	: 
Uso			: SIGACOM - Menu
Parâmetros	:
Retorno	: Nil
------------------------------------------------------------------------------------------------------------
*/

//U_VIXR164
 
User Function VIXR164()

	Local oReport
	Local cPerg	:= "VIXR164"
	
	//|Cria as Perguntas |
	FP001(cPerg)
	
	Pergunte(cPerg, .T.)
	oReport := ReportDef()
	oReport:PrintDialog()
	
Return()



/*
------------------------------------------------------------------------------------------------------------
Função		: CriaPerg
Tipo		: Função de Usuário
Descrição	: Cria o grupo de perguntas
Parâmetros	:
Retorno	:
------------------------------------------------------------------------------------------------------------
*/
Static Function FP001()
	
	//http://tdn.totvs.com/pages/releaseview.action?pageId=244740739
	u_zPutSX1("VIXR164","01","Emissão De ?"		,""	,""	,"mv_ch1","D",10		,0,0,"G","",""		,"",""	,"MV_PAR01")
	u_zPutSX1("VIXR164","02","Emissão Ate ?"		,""	,""	,"mv_ch2","D",10	,0,0,"G","",""		,"",""	,"MV_PAR02")		
	u_zPutSX1("VIXR164","03","Fornecedor De ?"	,""	,""	,"mv_ch3","C",TAMSX3("A2_COD")[1]	,0,0,"G","","SA2"		,"",""	,"MV_PAR03")
	u_zPutSX1("VIXR164","04","Fornecedor Ate ?"	,""	,""	,"mv_ch4","C",TAMSX3("A2_COD")[1]	,0,0,"G","","SA2"		,"",""	,"MV_PAR04")

Return

/*
------------------------------------------------------------------------------------------------------------
Função		: ReportDef
Tipo		: Função estática
Descrição	: Criar o objeto TReport para impressão
Parâmetros	:
Retorno		: Objeto
------------------------------------------------------------------------------------------------------------
*/
Static Function ReportDef()

	Local oReport
	Local oSecCE
	Local oBreak

	oReport := TReport():New("VIXR164","Relatório de erros CT-e & NF-e","VIXR164",{|oReport| PrintReport(oReport)},"Relatório de erros CT-e & NF-e")
	
	oReport:oPage:nPaperSize	:= 9  //Papel A4
	oReport:nFontBody			:= 9
	oReport:nLineHeight			:= 60
	oReport:cFontBody 			:= "Courier New"
	oReport:lBold 				:= .F.
	oReport:lUnderLine 			:= .F.
	oReport:lHeaderVisible 		:= .T.
	oReport:lFooterVisible 		:= .F.
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:SetLeftMargin(2)
	oReport:oPage:SetPageNumber(1)
	oReport:SetColSpace(10)
	oReport:SetLandscape() //Paisagem
	
	oSecCE := TRSection():New(oReport,"CE")

	TRCell():New(oSecCE, "Filial"	    ,"", "Filial"		,/**/,20,/**/	)	
	TRCell():New(oSecCE, "NumSerie"	    ,"", "Doc"			,/**/,40,/**/	)	 
	TRCell():New(oSecCE, "CODIGO"	    ,"", "Cod.For"		,/**/,20,/**/	)	 
	TRCell():New(oSecCE, "NOMEFORNE"	,"", "Fornec."		,/**/,100,/**/	)
	TRCell():New(oSecCE, "EMISSAO"		,"", "Dt.Emissao"	, /**/,30,/**/	)	
	TRCell():New(oSecCE, "VALOR"        ,"", "Vlr.NF"       ,"@E 999,999,999.99", 50)

	TRCell():New(oSecCE, "YINFO1"		,"", "ErroXML"		    ,/**/,100,/**/	)
	TRCell():New(oSecCE, "YINFO2"		,"", "ErroTotvsCol."	,/**/,100,/**/	)
	TRCell():New(oSecCE, "USERLIB"		,"", "UserLib."			,/**/,30,/**/	)
	TRCell():New(oSecCE, "MOTIVO"		,"", "MotivoLib."		    ,/**/,100,/**/	)	

	/*TRFunction():New(oSecCE:Cell("YINFO1"),NIL,"ErroXML",,NIL,NIL,NIL,.F.,.T.)
	TRFunction():New(oSecCE:Cell("YINFO2"),NIL,"ErroTotvsCol.",,NIL,NIL,NIL,.F.,.T.)
	TRFunction():New(oSecCE:Cell("MOTIVO"),NIL,"MotivoLib.",,NIL,NIL,NIL,.F.,.T.)*/

	
Return oReport

/*
------------------------------------------------------------------------------------------------------------
Função		: PrintReport
Tipo		: Função estática
Descrição	: Cria a consulta e imprime o relatório
Parâmetros	: 1 = Objeto TReport 
Retorno		: 
------------------------------------------------------------------------------------------------------------
*/
Static Function PrintReport(oReport)
	
	Local oSecCE 	:= oReport:Section(1) 
	Local cAlias 	:= GetNextAlias()

	BeginSQL Alias cAlias

			SELECT DISTINCT 

			'' AS FILIAL
			,'NFe '+SDS.DS_DOC+'-'+SDS.DS_SERIE AS NumSerie 
			,SA2.A2_COD as 	 CODIGO
			,LTRIM(RTRIM(SA2.A2_NOME)) 	as 	 NOMEFORNE 
			,convert(date,SDS.DS_EMISSA,103) AS EMISSAO
			,SDS.DS_VALMERC   AS VALOR
		,ISNULL( CONVERT( VARCHAR(4096), CONVERT(VARBINARY(4096), SDS.DS_YINFONF)), '') AS YINFO1	
		,ISNULL( CONVERT( VARCHAR(4096), CONVERT(VARBINARY(4096), SDS.DS_DOCLOG )),'') AS YINFO2 
		,SDS.DS_YUSERLB  AS USERLIB
		,ISNULL( CONVERT( VARCHAR(4096), CONVERT(VARBINARY(4096),SDS.DS_YMOTIVO )),'') AS MOTIVO	
			


				FROM   %table:SDS% SDS

				INNER JOIN  %table:SA2% SA2 ON SDS.DS_CNPJ = SA2.A2_CGC

				WHERE SDS.D_E_L_E_T_ = ''

				AND SDS.DS_EMISSA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 

				AND SA2.A2_NOME BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
				
				AND SDS.DS_YINFONF <> ''


			UNION  

			SELECT DISTINCT

			GXG.GXG_FILIAL AS FILIAL
			,'CTe '+LTRIM(RTRIM(GXG.GXG_NRDF))+'-'+GXG.GXG_SERDF AS NumSerie 
			,SA4.A4_COD as 	CODIGO
			,LTRIM(RTRIM(SA4.A4_NOME)) 	as 	 NOMEFORNE  
			,convert(date,GXG.GXG_DTEMIS,103) AS EMISSAO
			,GXG.GXG_VLDF AS VALOR 
			,ISNULL( CONVERT( VARCHAR(4096), CONVERT(VARBINARY(4096), GXG.GXG_YBLMOT)),'') AS YINFO1 			
			,ISNULL( CONVERT( VARCHAR(4096), CONVERT(VARBINARY(4096), GXG.GXG_OBS)),'') AS YINFO2
			, GXG.GXG_YUSERL AS USERLIB
			,ISNULL( CONVERT( VARCHAR(4096), CONVERT(VARBINARY(4096),GXG.GXG_YMOTIV )),'') AS MOTIVO 
			
			FROM   %table:GXG% GXG

			INNER JOIN %table:SA4% SA4  ON GXG.GXG_EMISDF = SA4.A4_CGC		 
			
			AND GXG.GXG_DTEMIS BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 			

			WHERE GXG.D_E_L_E_T_ = '' 	 			
			AND GXG.GXG_YBLMOT <> ''

			
	EndSQL

	oSecCE:EndQuery()	
	(cAlias)->(DbGoTop())
	oSecCE:Init()

	While !(cAlias)->(EoF())

		oSecCE:Cell("YINFO1"):SetValue((cAlias)->YINFO1)
		oSecCE:Cell("YINFO2"):SetValue((cAlias)->YINFO2)
		oSecCE:Cell("MOTIVO"):SetValue((cAlias)->MOTIVO)

		oSecCE:PrintLine()
		(cAlias)->(dbSkip())

	EndDo

	oSecCE:Finish()
	
Return