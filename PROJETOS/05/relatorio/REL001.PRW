#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RWMAKE.CH"

/*
------------------------------------------------------------------------------------------------------------
Função	: REL001
Tipo		: Conferência de expedição
DescriÃ§Ã£o	: 
Retorno	: Nil
------------------------------------------------------------------------------------------------------------
*/

//ADMIN
 
User Function REL001()

	Local oReport
	Local cPerg	:= "REL001"


	 /*
	Local aParam := {"08", "01"}	
	RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2],,,"COM")
	//__cInternet  := 'x'
	*/
	
	 

	//|Cria as Perguntas |
	FP001(cPerg)
	
	Pergunte(cPerg, .T.)
	oReport := ReportDef()
	oReport:PrintDialog()
	
Return()



/*
------------------------------------------------------------------------------------------------------------
Função		: CriaPerg
Tipo		: Função de UsuÃ¡rio
DescriÃ§Ã£o	: Cria o grupo de perguntas
ParÃ¢metros	:
Retorno	:
------------------------------------------------------------------------------------------------------------
*/
Static Function FP001()
 
    //http://tdn.totvs.com/pages/releaseview.action?pageId=244740739

 
    dbSelectArea('SX5')
 

	u_zPutSX1("REL001","01", "Emissao De ?",   "MV_PAR01","MVCH01","D",08,0,"G", "","","","","","","","", "Informe a data inicial a ser considerada")
	u_zPutSX1("REL001","02", "Emissao Ate ?",  "MV_PAR02","MVCH02","D",08,0,"G", "","","","","","","","", "Informe a data final   a ser considerada")	
	u_zPutSX1("REL001","03", "Cliente De ?",   "MV_PAR03","MVCH03","C",TamSX3('A1_COD')[01], 0, "G", "", "SA1", "",  "", "",  "", "", "", "Informe o cliente inicial")
	u_zPutSX1("REL001","04", "Cliente ate ?",  "MV_PAR04","MVCH04","C",TamSX3('A1_COD')[01], 0, "G", "", "SA1", "",  "", "",  "", "", "", "Informe o cliente final")
	u_zPutSX1("REL001","05", "Vendedor De ?",  "MV_PAR05","MVCH05","C",TamSX3('A3_COD')[01], 0, "G", "", "SA3", "",  "", "",  "", "", "", "Informe o vendedor inicial")
	u_zPutSX1("REL001","06", "Vendedor De ?",  "MV_PAR06","MVCH06","C",TamSX3('A3_COD')[01], 0, "G", "", "SA3", "",  "", "",  "", "", "", "Informe o vendedor final")
	u_zPutSX1("REL001","07", "Atendidas ?",    "MV_PAR07","MVCH07","N", 01,                  0, "C", "",    "", "",  "Todos", "Sim", "Nao", "", "", "")
 
    u_zPutSX1("REL001","08", "Produto De ?",   "MV_PAR08","MVCH08","C",TamSX3('B1_COD')[01], 0, "G", "", "SB1", "",  "", "",  "", "", "", "Informe o produto inicial")
	u_zPutSX1("REL001","09", "Produto ate ?",  "MV_PAR09","MVCH09","C",TamSX3('B1_COD')[01], 0, "G", "", "SB1", "",  "", "",  "", "", "", "Informe o produto final")
	u_zPutSX1("REL001","10", "Motivo De ?",    "MV_PAR10","MVCH10","C",TamSX3('X5_CHAVE')[01], 0, "G", "", "Z1", "",  "", "",  "", "", "", "Informe o motivo inicial")
	u_zPutSX1("REL001","11", "Motivo ate ?",   "MV_PAR11","MVCH11","C",TamSX3('X5_CHAVE')[01], 0, "G", "", "Z1", "",  "", "",  "", "", "", "Informe o motivo final")
	
Return

 

/*
------------------------------------------------------------------------------------------------------------
Função		: ReportDef
Tipo		: Função estática
DescriÃ§Ã£o	: Criar o objeto TReport para impressÃ£o
ParÃ¢metros	:
Retorno		: Objeto
------------------------------------------------------------------------------------------------------------
*/
Static Function ReportDef()

	Local oReport
	Local oSecCE

	oReport := TReport():New("REL001","Conferencia de motivo de assistência PV","REL001",{|oReport| PrintReport(oReport)},"Conferencia de motivo de assistência PV")
	
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
	//oReport:SetLeftMargin(2)
	oReport:oPage:SetPageNumber(1)
	oReport:SetColSpace(10)
	oReport:SetLandscape() //Paisagem
	
	oSecCE := TRSection():New(oReport,"CE")	
	
 
	TRCell():New(oSecCE, "FILIAL"	    ,"", "FILIALx" ,"",01,/**/	)
	TRCell():New(oSecCE, "PEDIDO"	    ,"", "PEDIDO" ,"",01,/**/	)		
	TRCell():New(oSecCE, "CLINOME"	    ,"", "CLINOME"	,"",20,/**/	)
	TRCell():New(oSecCE, "ITEM"		    ,"", "ITEM"	,"",01,/**/	)		
	TRCell():New(oSecCE, "PRODNOME"	    ,"", "PRODNOME"	,"",20,/**/	)	 
	TRCell():New(oSecCE, "UMEDIDA"		 ,"", "UMEDIDA"	,"",01,/**/	)	
	TRCell():New(oSecCE, "SOLICITACAO"	,"", "SOLICITACAO","",01,/**/	)	
	TRCell():New(oSecCE, "ATENDIDA"		,"", "ATENDIDA"	 ,"",01,/**/	)	
	TRCell():New(oSecCE, "VALOR"		,"", "VALOR" ,"",01,/**/	)	
	TRCell():New(oSecCE, "EMISSAO"		,"", "EMISSAO"	,"",01,/**/	)	
	TRCell():New(oSecCE, "DETALHE"		,"", "MOTIVO"	,"",01,/**/	)	
	TRCell():New(oSecCE, "DESCDET"		,"", "DESCMOTIVO"	,"",20,/**/	)	
	TRCell():New(oSecCE, "VENDCOD"	    ,"", "VENDCOD"	,"",01,/**/	)	
	TRCell():New(oSecCE, "VENDNOME"	,"", "VENDNOME","",20,/**/	)	
	TRCell():New(oSecCE, "NOTA"	        ,"", "NOTA"	 ,"",03,/**/	)	


	
Return oReport

/*
------------------------------------------------------------------------------------------------------------
Função		: PrintReport
Tipo		: Função estática
DescriÃ§Ã£o	: Cria a consulta e imprime o relatÃ³rio
ParÃ¢metros	: 1 = Objeto TReport 
Retorno		: 
------------------------------------------------------------------------------------------------------------
*/
Static Function PrintReport(oReport)
	
	Local oSecCE 	:= oReport:Section(1) 
	Local cQuery 	:= "" 


	cQuery += " SELECT  "

	cQuery += "  TRIM(SC5.C5_FILIAL) AS FILIALx "
	cQuery += " ,SC6.C6_NUM    AS PEDIDO "
	cQuery += " ,TRIM(SA1.A1_COD)||' - '||TRIM(SA1.A1_NOME)    AS CLINOME "		
	cQuery += " ,SC6.C6_ITEM   AS ITEM	 "
	cQuery += " ,TRIM(SB1.B1_COD)||' - '||TRIM(SB1.B1_DESC)    AS PRODNOME "	
	cQuery += " ,TRIM(SC6.C6_UM)     AS UMEDIDA "
	cQuery += " ,SC6.C6_QTDVEN AS SOLICITACAO  "
	cQuery += " ,SC6.C6_QTDENT AS ATENDIDA "	
	cQuery += " ,SC6.C6_VALOR  AS VALOR	 "
	cQuery += " ,SC5.C5_EMISSAO  AS C5_EMISSAO	 "
	cQuery += " ,substring(SC5.C5_EMISSAO, 7, 2)||'/'||substring(SC5.C5_EMISSAO, 5, 2)||'/'||substring(SC5.C5_EMISSAO, 1, 4) AS EMISSAO  "
	cQuery += " ,TRIM(SC6.C6_YDETPED) AS DETALHE	 "
	cQuery += " ,TRIM(SX5.X5_DESCRI)  AS DESCDET	 "
	cQuery += " ,TRIM(SC6.C6_NOTA) AS NOTA "
	cQuery += " ,TRIM(SA3.A3_COD)  AS VENDCOD "
	cQuery += " ,TRIM(SA3.A3_NOME) AS VENDNOME "

	cQuery +="  FROM "+RetSQLName("SC5")+" SC5  "

	cQuery += "  INNER  JOIN  "+RetSQLName("SA1")+" SA1  "
	cQuery += " ON SA1.A1_COD = SC5.C5_CLIENTE	  "
	cQuery += " AND SA1.D_E_L_E_T_ != '*' "

	cQuery += " INNER	JOIN  "+RetSQLName("SC6")+" SC6    "
	cQuery += " ON SC6.C6_FILIAL = SC5.C5_FILIAL "
	cQuery += " AND SC6.C6_NUM = SC5.C5_NUM "
	cQuery += " AND SC6.D_E_L_E_T_ != '*' "


	cQuery += " INNER	JOIN  "+RetSQLName("SA3")+" SA3    "
	cQuery += " ON  SA3.A3_COD = SC5.C5_VEND1  "  
	cQuery += " AND SA3.D_E_L_E_T_ != '*'	 "
	
	cQuery += " INNER	JOIN "+RetSQLName("SB1")+" SB1  "
	cQuery += " ON SB1.B1_FILIAL = '01' "
	cQuery += " AND SB1.B1_COD = SC6.C6_PRODUTO "
	cQuery += " AND SB1.D_E_L_E_T_ != '*' "	

	cQuery+= " INNER JOIN " + RetSQLName("SX5")+ " SX5 "
	cQuery+= " ON SX5.D_E_L_E_T_ = '' "
	cQuery+= " AND SX5.X5_FILIAL = '"+xFilial("SX5")+"' " 
	cQuery+= " AND SX5.X5_TABELA = 'Z1'" 
	cQuery+= " AND SX5.X5_CHAVE = SC6.C6_YDETPED" 

	cQuery += " WHERE  0=0 "
	
	cQuery += " AND SC6.C6_YDETPED != '' "

	cQuery += " AND SC5.C5_EMISSAO BETWEEN "+ValToSql(%Exp:MV_PAR01%)+" AND "+ValToSql(%Exp:MV_PAR02%)+" "

	cQuery += " AND SA1.A1_COD  BETWEEN "+ValToSql(%Exp:MV_PAR03%)+" AND "+ValToSql(%Exp:MV_PAR04%)+" "	

	cQuery += " AND SA3.A3_COD BETWEEN "+ValToSql(%Exp:MV_PAR05%)+" AND "+ValToSql(%Exp:MV_PAR06%)+" "


	If MV_PAR07 = 2 // 1 = "Todos",  
		cQuery += " AND SC6.C6_QTDENT > 0
	ElseIF MV_PAR07 = 3
		cQuery += " AND SC6.C6_QTDENT = 0
	EndIf

	cQuery += " AND SB1.B1_COD BETWEEN "+ValToSql(%Exp:MV_PAR08%)+" AND "+ValToSql(%Exp:MV_PAR09%)+" "
	cQuery += " AND SC6.C6_YDETPED BETWEEN "+ValToSql(%Exp:MV_PAR10%)+" AND "+ValToSql(%Exp:MV_PAR11%)+" "


	cQuery += "  ORDER BY SC6.C6_NUM DESC   "

	TcQuery cQuery new alias "cAlias"
	
	oSecCE:EndQuery()	
	cAlias->(DBGotop())	
 
	

	While !(cAlias->(EoF()))

		oSecCE:Init()
		oSecCE:Cell("FILIAL"):SetValue(cAlias->FILIALx)
		oSecCE:Cell("PEDIDO"):SetValue(cAlias->PEDIDO)		
		oSecCE:Cell("CLINOME"):SetValue(cAlias->CLINOME)						
		oSecCE:Cell("ITEM"):SetValue(cAlias->ITEM)		
		oSecCE:Cell("PRODNOME"):SetValue(cAlias->PRODNOME)
		oSecCE:Cell("UMEDIDA"):SetValue(cAlias->UMEDIDA)
		oSecCE:Cell("SOLICITACAO"):SetValue(cAlias->SOLICITACAO)

		oSecCE:Cell("EMISSAO"):SetValue(cAlias->EMISSAO)
		oSecCE:Cell("DETALHE"):SetValue(cAlias->DETALHE)
		oSecCE:Cell("DESCDET"):SetValue(cAlias->DESCDET)

		oSecCE:Cell("ATENDIDA"):SetValue(cAlias->ATENDIDA)
		oSecCE:Cell("VALOR"):SetValue(cAlias->VALOR)

		oSecCE:Cell("NOTA"):SetValue(cAlias->NOTA)
		oSecCE:Cell("VENDCOD"):SetValue(cAlias->VENDCOD)
		oSecCE:Cell("VENDNOME"):SetValue(cAlias->VENDNOME)

		oSecCE:PrintLine()
		cAlias->(dbSkip())

	EndDo
	
	oSecCE:Finish()
 
	
Return
