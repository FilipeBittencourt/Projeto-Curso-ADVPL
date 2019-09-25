#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RWMAKE.CH"

/*
------------------------------------------------------------------------------------------------------------
Função	: VIXR167
Tipo		: Conferência de expedição
DescriÃ§Ã£o	: 
Retorno	: Nil
------------------------------------------------------------------------------------------------------------
*/

//ADMIN
 
User Function VIXR167()

	Local oReport
	Local cPerg	:= "VIXR167"


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
	u_zPutSX1("VIXR167","01","Dt do pgto De ?"		,""	,""	,"mv_ch1","D",10	,0,0,"G","",""		,"",""	,"MV_PAR01")
	u_zPutSX1("VIXR167","02","Dt do pgto Ate ?"		,""	,""	,"mv_ch2","D",10	,0,0,"G","",""		,"",""	,"MV_PAR02")
	u_zPutSX1("VIXR167","03","Pedido Web De ?"		,""	,""	,"mv_ch3","C",30	,0,0,"G","",""		,"",""	,"MV_PAR03")
	u_zPutSX1("VIXR167","04","Pedido Web Ate ?"		,""	,""	,"mv_ch4","C",30	,0,0,"G","",""		,"",""	,"MV_PAR04")	
	u_zPutSX1("VIXR167","05","Tipo de Pedido ?"   ,"" ,"" ,"mv_ch5","N",01    ,0,0,"C","",""        ,"",""  ,"MV_PAR05", "Pendentes","","","Pendentes","Finalizados","","","Todos","","")   
	u_zPutSX1("VIXR167","06","Cod. Transportadora"	,""	,""	,"mv_ch6","C",50	,0,0,"G","",""		,"",""	,"MV_PAR06")
    
	
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

	oReport := TReport():New("VIXR167","Conferência de expedição","VIXR167",{|oReport| PrintReport(oReport)},"Conferência de expedição")
	
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

	TRCell():New(oSecCE, "PedidoWEB"	    ,"", "Pedido WEB"		,"@!",/**/,/**/	)	
	TRCell():New(oSecCE, "DTLibPgtoPed"	    ,"", "DT Liberação pgto"			,/**/,/**/,/**/	)	
	TRCell():New(oSecCE, "HRLibPgtoPed"	    ,"", "HR Liberação pgto"	,/**/,/**/,/**/	)	 
	TRCell():New(oSecCE, "DTLibPedTIMS"	,"", "DT Liberação Ped TIMS"		,/**/,/**/,/**/	)	
	TRCell():New(oSecCE, "HRLibPedTIMS"		,"", "HR Liberação Ped TIMS"	,/**/,/**/,/**/	)		
 

    TRCell():New(oSecCE, "NotaFiscal"		   ,"", "NFe"			,/**/,/**/,/**/	)	
	TRCell():New(oSecCE, "DTNFE"		,"", "DT NFE"		    ,/**/,/**/,/**/	)	
	TRCell():New(oSecCE, "HRNFE"		,"", "HR NFE"	,/**/,/**/,/**/	)	
	
	TRCell():New(oSecCE, "DTBIP"		,"", "DT BIP"	  ,/**/,/**/,/**/	)	
	TRCell():New(oSecCE, "HRBIP"		,"", "HR BIP"	  ,/**/,/**/,/**/	)	

	TRCell():New(oSecCE, "DTPRIN"		,"", "DT Impressao"	  ,/**/,/**/,/**/	)	
	TRCell():New(oSecCE, "HRPRIN"		,"", "HR Impressao"	  ,/**/,/**/,/**/	)	

	
	TRCell():New(oSecCE, "Rastro"	,"", "Rastro"	  ,/**/,/**/,/**/	)
	TRCell():New(oSecCE, "CodTransp"	,"", "Cod. Transp"	  ,/**/,/**/,/**/	)
	TRCell():New(oSecCE, "NomeTransp"	,"", "Nome Transp"	  ,/**/,/**/,/**/	)


	
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
	Local cMVYTRARAS 	:= GetNewPar("MV_YTRARAS","")

	Local cVT1 := RetFullName("VT1", "09")
    Local cSC5 := RetFullName("SC5", "09")
	Local cSA4 := RetFullName("SA4", "09")
	Local cSF2 := RetFullName("SF2", "09")

	cQuery += "  SELECT                           "
	cQuery += "     VT1.VT1_ORDID as PedidoWEB,             "
	cQuery += "     VT1.VT1_DATAPG AS DTLibPgtoPed,         "
	cQuery += "     VT1.VT1_HORAPG as HRLibPgtoPed,         "
	cQuery += "     SC5_8.C5_YDTLIBP as DTLibPedTIMS,     "
	cQuery += "     SC5_8.C5_YHRLIBP as HRLibPedTIMS,     "
	cQuery += "     SF2.F2_DOC AS NotaFiscal,                   "
	cQuery += "     SF2.F2_EMISSAO AS DTNFE,                   "
	cQuery += "     SF2.F2_HORA AS HRNFE,                      "
	cQuery += "     ZZB.ZZB_DTBIP AS DTBIP ,            "
	cQuery += "     ZZB.ZZB_HRBIP AS HRBIP ,            "
	cQuery += "     ZZB.ZZB_DTPRIN AS DTPRIN ,            "
	cQuery += "     ZZB.ZZB_HRPRIN AS HRPRIN ,            "
	cQuery += "     ZZB.ZZB_RASTRO  AS Rastro,         "
	cQuery += "     SA4.A4_COD   AS CodTransp,         "
	cQuery += "     SA4.A4_NOME  AS NomeTransp         "
	cQuery += "  FROM                                       "
	cQuery += "     "+cVT1+" VT1               "

	cQuery += "     JOIN                                    "
	cQuery += "        "+cSC5+" SC5                           "
	cQuery += "        ON SC5.C5_FILIAL = '01'              "
	cQuery += "        AND SC5.D_E_L_E_T_ = ''              "
	cQuery += "        AND SC5.C5_YPEDWEB = VT1.VT1_ORDID   "
	cQuery += "        AND SC5.C5_YAPI = VT1.VT1_API        "	

	
	cQuery += "     JOIN                                    "
	cQuery += "        "+cSA4+" SA4                         "
	cQuery += "        ON SC5.C5_FILIAL = '01'              "
	cQuery += "        AND SA4.D_E_L_E_T_ = ''              "	 
	cQuery += "        AND SC5.C5_TRANSP = SA4.A4_COD       "

	cQuery += "     JOIN                                    "
	cQuery += "        SC5080 SC5_8                         "
	cQuery += "        ON SC5_8.C5_FILIAL = '01'            "
	cQuery += "        AND SC5_8.D_E_L_E_T_ = ''            "
	cQuery += "        AND SC5_8.C5_YPEDWEB = VT1.VT1_ORDID "
	cQuery += "        AND SC5_8.C5_YAPI = VT1.VT1_API      "

     
     
	cQuery += "   LEFT JOIN									 	"
    cQuery += "  	"+cSF2+" SF2  							"
    cQuery += "  	ON SF2.F2_FILIAL = '01'  				"
    cQuery += "  	AND SF2.D_E_L_E_T_ = '' 				"
    cQuery += "  	AND F2_DOC = SC5.C5_NOTA 		    	"
    cQuery += "  	AND F2_SERIE = SC5.C5_SERIE 			"


	cQuery += "    LEFT JOIN                                "
	cQuery += "        ZZB090 ZZB                           "
	cQuery += "        ON ZZB.ZZB_FILIAL = '01'             "
	cQuery += "        AND ZZB.D_E_L_E_T_ = ''              "
	cQuery += "        AND ZZB.ZZB_DOC = SC5.C5_NOTA        "
	cQuery += "        AND ZZB_SERIE = SC5.C5_SERIE         "
	cQuery += "        AND ZZB.ZZB_DOC <> '' 		        "
	

	cQuery += "  WHERE                                      "
	cQuery += "     VT1.VT1_FILIAL = '01'                   "
	cQuery += "     AND VT1.D_E_L_E_T_ = ''                 "   
	

	cQuery += " AND VT1.VT1_DATAPG BETWEEN "+ValToSql(%Exp:MV_PAR01%)+" AND "+ValToSql(%Exp:MV_PAR02%)+" "
	
	cQuery += " AND VT1.VT1_ORDID BETWEEN "+ValToSql(%Exp:MV_PAR03%)+" AND "+ValToSql(%Exp:MV_PAR04%)+" "


    //if !(Empty(cMVYTRARAS))

		cMVYTRARAS := REPLACE(cMVYTRARAS,",",";")
		cMVYTRARAS := REPLACE(cMVYTRARAS,".",";")
		cMVYTRARAS := REPLACE(cMVYTRARAS,"/",";")

		if MV_PAR05 == 2	
			cQuery += " AND ((SC5.C5_TRANSP IN "+FormatIn(cMVYTRARAS,";")+" AND ZZB.ZZB_RASTRO IS NOT NULL) OR (SC5.C5_TRANSP NOT IN "+FormatIn(cMVYTRARAS,";")+" AND SF2.F2_DOC IS NOT NULL)) "	
		elseif MV_PAR05 == 1
			cQuery += " AND ((SC5.C5_TRANSP IN "+FormatIn(cMVYTRARAS,";")+" AND ZZB.ZZB_RASTRO IS NULL) OR (SC5.C5_TRANSP NOT IN "+FormatIn(cMVYTRARAS,";")+" AND SF2.F2_DOC IS NULL)) "	
		endif

	//endif

	if !(Empty(MV_PAR06))

		cQuery += " AND SA4.A4_COD IN "+FormatIn(MV_PAR06,";")
		
	endif

	//cQuery += "  ORDER BY 2 DESC   "

	TcQuery cQuery new alias "cAlias"
	
	oSecCE:EndQuery()	
	cAlias->(DBGotop())	
 
	oSecCE:Init()

	While !(cAlias->(EoF()))

		oSecCE:Cell("PedidoWEB"):SetValue(cAlias->PedidoWEB)
		oSecCE:Cell("DTLibPgtoPed"):SetValue(stod(cAlias->DTLibPgtoPed))
		oSecCE:Cell("HRLibPgtoPed"):SetValue(cAlias->HRLibPgtoPed)
		oSecCE:Cell("DTLibPedTIMS"):SetValue(stod(cAlias->DTLibPedTIMS))
		oSecCE:Cell("HRLibPedTIMS"):SetValue(cAlias->HRLibPedTIMS)

		oSecCE:Cell("NotaFiscal"):SetValue(cAlias->NotaFiscal)
		oSecCE:Cell("DTNFE"):SetValue(stod(cAlias->DTNFE))
		oSecCE:Cell("HRNFE"):SetValue(cAlias->HRNFE)

		oSecCE:Cell("DTBIP"):SetValue(stod(cAlias->DTBIP))
		oSecCE:Cell("HRBIP"):SetValue(cAlias->HRBIP)
		oSecCE:Cell("Rastro"):SetValue(cAlias->Rastro)

		oSecCE:Cell("DTPRIN"):SetValue(stod(cAlias->DTPRIN))
		oSecCE:Cell("HRPRIN"):SetValue(cAlias->HRPRIN)

		oSecCE:Cell("CodTransp"):SetValue(cAlias->CodTransp)
		oSecCE:Cell("NomeTransp"):SetValue(cAlias->NomeTransp)

		oSecCE:PrintLine()
		cAlias->(dbSkip())

	EndDo
	
	oSecCE:Finish()
 
	
Return
