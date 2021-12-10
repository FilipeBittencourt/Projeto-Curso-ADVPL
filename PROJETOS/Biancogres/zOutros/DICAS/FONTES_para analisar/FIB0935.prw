#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FIB0935   �Autor  �Renato Coelho       � Data �  18/06/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Relat�rio de Compromisso de Pagamento                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Contas a Pagar                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FIB0935()

		Private lAdjustToLegacy := .T.
		Private lDisableSetup   := .T.
		Private cPerg     := "FIB0837"
		Private wNumAnt  := Space(6)
		Private nLin     := 150
		Private nLimEsq  := 30
		Private nLimDir  := 2350
		Private nMrgMeio := 0
		Private nAltLgr  := 80
		Private nLargLgr := 270
		Private nAltCab  := 115
		Private nMrgSup  := 10
		Private nMrgInf  := 10
		Private nMrgEsq  := 10
		Private nMrgDir  := 10
		Private cTitulo  := "COMPROMISSO DE PAGAMENTO DE FRETE"
		Private nAltFonCab := 0
		Private aItensPed := {}  
		Private nAcond := 0           
		Private cProd := ''
		Private cDescProd := ''
		SetPrvt("wDescFin,xNomeCob,cNumPed,cChave1,cChave2,wTitulo,wParcela,wVencto,wValor,wTotal")
		SetPrvt("wEmissao,xEndCob,xTelCob,xCgcCob,xCidCob,xEstCob,xCodigo,xLoja,xNome,xEnd,xCep,xMun")
		SetPrvt("xEst,xCgc,xInscr,xTel,wNome,wBanco,wAgencia,wConta,xFilCob")
		SetPrvt("cNum,dVencto,dEmissao,nValTot,nValAdic,nValFre,cRota,cDesc,cForn,cLoja,nAux")
		SetPrvt("nTot,nTotP,nCxs,nPlt,nFrt,nAdc,nPed,nDes,nDia,nOut")   
		SetPrvt("bIgual,cDocSerZ05,cOriSerZ05,cProcesZ05,cNomeZ05,nTotDocZ05,nVolumeZ05,nPalletZ05,nVlrdocZ05,nVlrkmZ05,nVlrpedZ05,nVlrdesZ05,nVlrdiaZ05,nVlroutZ05,nTotpZ05")

		ValidPerg()

		//Pergunta
		/*
		If !Pergunte("FIB0837")
			MsgStop("Opera��o cancelada.","Compromisso de Pagamento de Frete.")
			Return
		EndIf
		*/
		Processa( {|| fImpRel() }, "Aguarde...", "Gerando Compromisso de Pagamento de Frete...",.F.)

		Return

		Static Function fImpRel()

		Local cWorkArea := GetNextAlias() 
		Local cWorkItens:= GetNextAlias()  
		Local cSQL		:= ""            
		Local cNF		:= ""		        
		Local cSerie	:= ""
		Local cForCli	:= ""	

	 

		Local aInfoRel  := {} 
		Local aAux 		:= {}  

		Local nTotalNF	:= 0
		Local nX		:= 0
		Local nW		:= 0 
		Local nCxNF		:= 0 				
		Local cF1F2 := "F1"
		Local  cUser  :=  ""
		local  cUserDT  := "" 


		//Montagem do Objeto para Impress�o
		Private oPrint := FWMSPrinter():New("FIB0837",IMP_PDF,lAdjustToLegacy,,lDisableSetup,,,,,.F.)

		//Define a Resolu��o
		oPrint:SetResolution(72)

		//Define orienta��o da p�gina para Paisagem, considerando (3508px X 2480px)
		oPrint:SetPortrait()

		oPrint:SetMargin(10,10,10,10) // nEsquerda, nSuperior, nDireita, nInferior

		//Define o tipo de papel utilizado
		//oPrint:SetPage(9)
		oPrint:SetPaperSize(DMPAPER_A4)

		//Define o diretorio de grava��o do arquivo. Caso n�o exiata o sistema define o temp do SO
		//oPrint:cPathPDF := "c:\Temp\"

		//Defini��o da Logomarca
		cFileLogo := GetSrvProfString('Startpath','') + 'logonova' + '.bmp'

		//Define as fontes utilizadas
		oFont1 := TFont():New('Courier New' ,,-10,,.F.,,,,.F.,.F.)
		oFont2 := TFont():New('Courier New' ,,-10,,.T.,,,,.F.,.F.)
		oFont3 := TFont():New('Arial'       ,,-14,,.T.,,,,.F.,.F.)

		//Define a Altura da Fonte do Titulo
		//
		nAltFonCab := oPrint:GetTextheight( "COMPROMISSO DE PAGAMENTO DE FRETE", oFont3)

		//Inicia p�gina
		oPrint:StartPage()                             

		nAux := 0    

				  
  
		cSQL := " SELECT 	
		cSQL += "  RTRIM(LTRIM(GW1.GW1_USUIMP)) AS USUIMP, "
        cSQL += " SUBSTRING(GW1.GW1_DTLIB, 7, 2)+'/'+SUBSTRING(GW1.GW1_DTLIB, 5, 2)+'/'+SUBSTRING(GW1.GW1_DTLIB, 1, 4)+' '+GW1.GW1_HRLIB AS 'DTLIB', "
		cSQL += "  GW1.GW1_FILIAL,                          	 	"	 	
		cSQL += "  GW1.GW1_NRROM	'ROMANEIO',                  	"
		cSQL += "  GW1.GW1_NRDC	'DC'    ,              	 	     	"
		cSQL += "  GW4.GW4_NRDF	'CTRC'  ,             	 	     	"
		cSQL += "  GW1.GW1_DANFE	'DANFE' ,  			 	 	 	"
		cSQL += "  GW1.GW1_CDTPDC	'TIPO'  ,         		 	 	"
		cSQL += "  GW1.GW1_QTVOL	'VOLUME',	             	 	"
		cSQL += "  GW1.GW1_DSESP	'DSVOL',	                 	"
		cSQL += "  GU3.R_E_C_N_O_  'GU3REC',             	     	"	 	
		cSQL += "  A.GWJ_NRPF		'PREFATURA',			 	 	"
		cSQL += "  A.GWJ_DTVCTO    'DTVCTO',                	 	"
		cSQL += "  A.GWJ_DTEMFA    'EMISSAO',                    	" 
		cSQL += " A.GWF_NRCALC    'NRDOC',							"

		cSQL += "  ( SELECT           	 						 	"  
		cSQL += "		ISNULL(SUM(GWM_VLFRET),0) 'VLFRET'			"
		cSQL += "    FROM " + RetSQLName("GWM") + "  GWM         	"

		cSQL += "    WHERE GWM.D_E_L_E_T_=''                     	"
		cSQL += "    AND GWM.GWM_FILIAL  = GW1.GW1_FILIAL   	 	"
		cSQL += "    AND GWM.GWM_NRDC	= GW1.GW1_NRDC     	     	"
		cSQL += "    AND GWM.GWM_SERDC	= GW1.GW1_SERDC          	"        
		cSQL += "    AND A.GWF_NRCALC   = GWM.GWM_NRDOC             "
					
		cSQL += "      AND GWM.GWM_EMISDC  = GW1.GW1_EMISDC 	 	"
		cSQL += "      AND GWM.GWM_CDTPDC  = GW1.GW1_CDTPDC   	 	" 	
		cSQL += "  ) 'VLFRET',										"

		cSQL += "  A.GV9_NRNEG 'NRNEG',                             "
		cSQL += "  A.GV9_CDCLFR,                                  	"
		cSQL += "  GUB.GUB_DSCLFR 'DSCROTA' ,   						"
		cSQL += " 	     RTRIM(LTRIM(GW3.GW3_CC)) AS CTT  "

		cSQL += "  FROM " + RetSQLName("GW1") + " GW1              "

		cSQL += "  INNER JOIN " + RetSQLName("GU3") + "  GU3 ON	 	"
		cSQL += "  GU3.D_E_L_E_T_	  = '' 					     	"
		cSQL += "  AND GU3.GU3_FILIAL = ''		                 	"
		cSQL += "  AND GU3.GU3_CDEMIT = GW1.GW1_CDREM		     	"

		cSQL += "  INNER JOIN " + RetSQLName("GW4") + "  GW4 ON  	"
		cSQL += "  GW4.D_E_L_E_T_     =''                        	"
		cSQL += "  AND GW4.GW4_FILIAL = GW1.GW1_FILIAL 		     	"
		cSQL += "  AND GW4.GW4_NRDC   = GW1.GW1_NRDC   		     	"

		cSQL += "  INNER JOIN (                                  	"
		//cSQL += "  LEFT JOIN (                                  	"

		cSQL += " 	SELECT                              	 	 	"
		cSQL += " 	     GWF.GWF_FILPRE,                         	" 	
		cSQL += " 	     GWJ.GWJ_NRPF,                		 	 	"
		cSQL += " 	     GWF.GWF_NRROM,                 	 	 	"
		cSQL += " 	     GWJ.GWJ_DTEMFA,                	 	 	"
		cSQL += " 	     GWJ.GWJ_DTVCTO,                	 	 	"
		cSQL += " 	     GWF.GWF_NRDF,	                	 	 	"
		cSQL += " 	     GWF.GWF_NRCALC,                	 	 	"
		cSQL += " 	     GWI.GWI_VLFRET,                         	"

		cSQL += " 	     GV9.GV9_NRNEG,                          	"
		cSQL += " 	     GV9.GV9_CDCLFR               	 		 	"

		cSQL += " 	FROM " + RetSQLName("GWF") + " GWF           	" 
		cSQL += " 	                                             	"
		cSQL += " 	INNER JOIN " + RetSQLName("GWJ") + " GWJ ON  	"
		cSQL += " 	GWJ.D_E_L_E_T_	 = ''               	 	 	"
		cSQL += " 	AND GWF.GWF_FILPRE = GWJ.GWJ_FILIAL 	 	 	"
		cSQL += " 	AND GWF.GWF_NRPREF = GWJ.GWJ_NRPF   	 	 	"

		cSQL += " 	INNER JOIN " + RetSQLName("GWI") + " GWI ON  	"
		cSQL += " 	GWI.D_E_L_E_T_	   = ''             	 	 	"
		cSQL += " 	AND GWI.GWI_FILIAL = GWF.GWF_FILIAL 	 	 	"
		cSQL += " 	AND GWI.GWI_FILIAL = GWJ.GWJ_FILIAL 	 	 	"
		cSQL += " 	AND GWI.GWI_NRCALC = GWF.GWF_NRCALC          	"

		cSQL += " 	INNER JOIN  " + RetSQLName("GWG") + " GWG ON 	"
		cSQL += " 	GWF.D_E_L_E_T_ = ''                          	"
		cSQL += " 	AND GWF.GWF_FILIAL  = GWG.GWG_FILIAL         	"
		cSQL += " 	AND  GWF.GWF_NRCALC = GWG.GWG_NRCALC         	"

		cSQL += " 	INNER JOIN " + RetSQLName("GV9") + " GV9 ON  	"
		cSQL += " 	GV9.D_E_L_E_T_ 	   =''                       	"
		cSQL += " 	AND GV9.GV9_FILIAL = '"+xFilial("GV9")+"'    	"
		cSQL += " 	AND GV9.GV9_NRNEG  = GWG.GWG_NRNEG       	 	"
		cSQL += " 	AND GV9.GV9_NRTAB  = GWG.GWG_NRTAB           	"
		cSQL += " 	AND GV9.GV9_CDCLFR = GWG.GWG_CDCLFR          	"
		cSQL += " 	AND GV9.GV9_CDEMIT = GWG.GWG_CDEMIT          	"
		cSQL += " 	                                             	"
		cSQL += " 	WHERE GWF.D_E_L_E_T_ = '' )  A ON           	"           	  
		cSQL += " 	A.GWF_FILPRE		 = GW1.GW1_FILIAL        	"
		cSQL += " 	AND A.GWF_NRDF		 = GW4.GW4_NRDF           	"

		cSQL += " LEFT JOIN " + RetSQLName("GUB")+ " GUB ON 		"
		cSQL += " GUB.D_E_L_E_T_ 	 	= ''			  			"	
		cSQL += " AND GUB.GUB_FILIAL 	= '"+xFilial("GUB")+"'		"	
		cSQL += " AND GUB.GUB_CDCLFR 	= GV9_CDCLFR 				"

		cSQL += " LEFT JOIN " + RetSQLName("GW3")+ " GW3 ON 		"
		cSQL += " GW3.D_E_L_E_T_ 	 	= ''			  			"	
		cSQL += " AND GW3.GW3_FILIAL 	= '"+xFilial("GW3")+"'		"	
		cSQL += " AND A.GWF_NRDF		= GW3_NRDF "   	

		cSQL += " WHERE GW1.D_E_L_E_T_=''                   	   	"
		cSQL += " AND GW1.GW1_FILIAL 	= '"+xFilial("GW1")+"'    	"
		cSQL += " AND GW1.GW1_NRROM  	= '"+ GWN->GWN_NRROM + "' 	"
		cSQL += " ORDER BY GW1.GW1_DTLIB "

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cWorkArea, .T., .F. )   

														
		While (cWorkArea)->(!Eof())


			
			If Alltrim((cWorkArea)->(TIPO)) == "NFS"
				
				cSQL := " SELECT 												 		"
				cSQL += " SF2.R_E_C_N_O_  'SF2REC',							      		"
				cSQL += " SA1.R_E_C_N_O_  'SA1REC', 	 							 		"
				cSQL += " SA4.R_E_C_N_O_  'SA4REC' 	 							 		"
				cSQL += " FROM " + RetSQLName("SF2") + " SF2           					"
																					
				cSQL += " INNER JOIN " + RetSQLName("SA1") + " SA1 ON  				    "
				cSQL += " SA1.D_E_L_E_T_	    =''  								  		"

				cSQL += " AND SA1.A1_COD 	= SF2.F2_CLIENTE 					  		"
					
				cSQL += " INNER JOIN " + RetSQLName("SA4") + " SA4 ON  				    "
				cSQL += " SA4.D_E_L_E_T_	    =''  								  		" 
				cSQL += " AND SA4.A4_FILIAL	= '"+xFilial("SA4")+"' 					    "

				cSQL += " 	INNER JOIN " + RetSQLName("GW1") + " GW1 ON F2_CHVNFE = GW1.GW1_DANFE   AND GW1.GW1_FILIAL = '"+xFilial("GW1")+"' "
				cSQL += " 	INNER JOIN " + RetSQLName("GWN") + " GWN ON GWN.GWN_NRROM = GW1.GW1_NRROM   AND GWN.GWN_FILIAL = '"+xFilial("GWN")+"' " 	 
				cSQL += "   INNER JOIN " + RetSQLName("GU3") + " GU3 ON GU3.GU3_CDEMIT = GWN.GWN_CDTRP   "         

				cSQL += " WHERE F2_CHVNFE	= '" + Alltrim((cWorkArea)->(DANFE))+ "' 	"
				cSQL += " AND  F2_FILIAL = '"+xFilial("SF2")+"' " 	 
				cSQL += " AND SA4.A4_CGC = GU3.GU3_IDFED


			 dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cWorkItens, .T., .F. )			

				cF1F2 := "F2"
				If (cWorkItens)->(!Eof())
				
				
						SF2->(dbGoto((cWorkItens)->(SF2REC)))
						SA1->(dbGoto((cWorkItens)->(SA1REC)))      
					
						aAux := { (cWorkArea)->(DC)					,;  // 01 - Documento de Carga
								(cWorkArea)->(CTRC)					,;  // 02 - CTE
								SF2->F2_DOC							,;  // 03 - Nota Fiscal	 
								SF2->F2_SERIE						,;  // 04 - Serie
								SA1->A1_NOME						,;  // 05 - Nome do Cliente/Fornecedor
								SF2->F2_VALBRUT  					,;  // 06 - Valor da Nota Fiscal
								0								   	,;  // 07 -
								(cWorkArea)->(DSVOL) 			  	,;  // 08 - 
								(cWorkArea)->(VOLUME)				,;  // 09 -
								fRetProc(1,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)		,;  // 10 -
								(cWorkArea)->(VLFRET)    								,;  // 11 -
								(cWorkItens)->(SA4REC)									 ,;  // 12 -
								(cWorkArea)->(CTT)    								;  // 13 - CENTRO DE CUSTO
								}
								
								
				Endif    		

			// FAZENDO ESSE SQL PARA  TRATAR OS TIPOS DE BENEFICIAMENTO. 
			Else
				
				cSQL := " SELECT 												 		"
				cSQL += " SF1.R_E_C_N_O_  'SF1REC',							      		"
				cSQL += " SA1.R_E_C_N_O_  'SA1REC', 	 							 		"
				cSQL += " SA4.R_E_C_N_O_  'SA4REC' 	 							 		"
				cSQL += " FROM " + RetSQLName("SF1") + " SF1           					"
																					
				cSQL += " INNER JOIN " + RetSQLName("SA1") + " SA1 ON  				    "
				cSQL += " SA1.D_E_L_E_T_	    = ''  								  		"

				cSQL += " AND SA1.A1_COD 	= SF1.F1_FORNECE 					  		"
					
				cSQL += " INNER JOIN " + RetSQLName("SA4") + " SA4 ON  				    "
				cSQL += " SA4.D_E_L_E_T_	    = ''  								  		" 
				cSQL += " AND SA4.A4_FILIAL	= '"+xFilial("SA4")+"' 					    "

	      cSQL += " 	INNER JOIN " + RetSQLName("GW1") + " GW1 ON F1_CHVNFE = GW1.GW1_DANFE   AND GW1.GW1_FILIAL = '"+xFilial("GW1")+"' "
				cSQL += " 	INNER JOIN " + RetSQLName("GWN") + " GWN ON GWN.GWN_NRROM = GW1.GW1_NRROM   AND GWN.GWN_FILIAL = '"+xFilial("GWN")+"' " 	 
				cSQL += "   INNER JOIN " + RetSQLName("GU3") + " GU3 ON GU3.GU3_CDEMIT = GWN.GWN_CDTRP     "      

				cSQL += " WHERE F1_CHVNFE	= '" + Alltrim((cWorkArea)->(DANFE))+ "' 	"
				cSQL += " AND  F1_FILIAL = '"+xFilial("SF1")+"' " 	 
				cSQL += " AND SA4.A4_CGC = GU3.GU3_IDFED						
				


				dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cWorkItens, .T., .F. )     
				
				
				If (cWorkItens)->(!Eof())
				
						SF1->(dbGoto((cWorkItens)->(SF1REC)))
						SA1->(dbGoto((cWorkItens)->(SA1REC)))      
					
						aAux := { (cWorkArea)->(DC)				,;  // 01 - Documento de Carga
								(cWorkArea)->(CTRC)				,;  // 02 - CTE
								SF1->F1_DOC						,;  // 03 - Nota Fiscal	 
								SF1->F1_SERIE					,;  // 04 - Serie
								SA1->A1_NOME					,;  // 05 - Nome do Cliente/Fornecedor
								SF1->F1_VALBRUT  				,;  // 06 - Valor da Nota Fiscal
								0								,;  // 07 - 
								(cWorkArea)->(DSVOL) 			,;  // 08 -  
								(cWorkArea)->(VOLUME)			,;  // 09 - 
								fRetProc(2,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA),;  // 10 - 
								(cWorkArea)->(VLFRET)    			,;  // 11 - 
								(cWorkItens)->(SA4REC)				 ,;  // 12 - 
								(cWorkArea)->(CTT)    								;  // 13 - CENTRO DE CUSTO
								}
								
								
				Endif    		


			Endif  	                                       
			
			(cWorkItens)->(dbCloseArea())

			If Len(aAux)  <= 0
				Aviso("Atencao","Dados da nota fiscal chave ' " + cValToChar(Alltrim((cWorkArea)->(DANFE)))+ "' ,  n�o foram encontrados nos documentos(NF) de entrada/saida. ")  
					return .f.
			Endif

				cUser  := (cWorkArea)->(USUIMP)
				cUserDT  := (cWorkArea)->(DTLIB)
				cCTT := (cWorkArea)->(CTT)
				 
			
			//________________________________________________________________________________________________________________
			//                                                                                                                |
			// Autor: Controle de montagem da estrtura dos dados                                                              | 
			//________________________________________________________________________________________________________________|
				
			nPos := aScan(aInfoRel,{|x| Alltrim(x[1]) == (cWorkArea)->(ROMANEIO) })
			
			If nPos < 1
			
				aAdd( aInfoRel, { (cWorkArea)->(ROMANEIO)   ,; // 01 - Codigo do Romaneio
									0						  										,; // 02 - Volume
									(cWorkArea)->(GU3REC)	  					,; // 03 - Recno da Emitente/Transportadora
									aAux[11]     			  					,; // 04 - Valor do Frete
									(cWorkArea)->(EMISSAO)   					,; // 05 - Emissao
									(cWorkArea)->(DTVCTO)    					,; // 06 - Vencimento
									(cWorkArea)->(PREFATURA) 					,; // 07 - Fatura
									(cWorkArea)->(NRNEG)	  					,; // 08 - Numero da Negociacao	
									(cWorkArea)->(DSCROTA) 	  				    ,; // 09 -									
									{ aAux }}) 					              
			Else                                          

				//__________________________________________________________________________________________________
				//                                                                                                  |
				// Descricao : A soma dos valores parciais compoe o Valor Total. Logo, e necessario atualiza-lo     |
				//__________________________________________________________________________________________________|
			
				aInfoRel[nPos][4] += aAux[11]                
				
				aAdd( aInfoRel[nPos][10],  aAux )				
				   						
			Endif      

			

			aAux := {}
			
			(cWorkArea)->(dbSkip())   			
		EndDo  

			
		(cWorkArea)->(dbCloseArea()) 


		//__________________________________________________________________________________________________
		//                                                                                                  |
		// Descricao : Dinamica do fluxo de impressao                                                       |
		//__________________________________________________________________________________________________|

		For nX := 1 To Len(aInfoRel)
							
					aAux := aClone(aInfoRel[nX][10])  
					nAux := nAux + 1
				
					//_______________________________________________________________________________________
					//                                                                                       |
					// Impressao da linha tracejada                                                          |
					//_______________________________________________________________________________________|
					
					oPrint:Say (nLin, nLimEsq, Replicate("- ",76), oFont1,,,,)
					
					//_______________________________________________________________________________________
					//                                                                                       |
					// Descricao : Codigo do Romaneio                                                        |
					//_______________________________________________________________________________________|
								
					cNum 	  := GWN->GWN_NRROM    // Codigo do Romaneio       
					//dEmissao  := aInfoRel[nX][5]  	// Data de Emissao do Romaneio
					dEmissao  := DTOC(GWN->GWN_DTIMPL)  // Data de Emissao do Romaneio
					dVencto   := aInfoRel[nX][6]   		// Data de Vencimento da Pre-Fatura
					nValTot   := aInfoRel[nX][4]   		// Valor Total do Frete
					cRota     := aInfoRel[nX][8]		// Codigo da Negociacao
					cDesc     := aInfoRel[nX][9]   		// Descricao da Rota / Negociacao 
					nValFre	  := aInfoRel[nX][4]   		// Valor da Rota
					 
					 
					
					nLin := nLin+80
					
					oPrint:Box(nLin, nLimEsq, nLin+nAltCab, nLimDir,"-3")
					oPrint:SayBitmap(nLin+(nAltCab-nAltLgr)/2, nLimEsq+20, cFileLogo, nLargLgr, nAltLgr)
					oPrint:SayAlign(nLin+(nAltCab-nAltFonCab)/2, nLimEsq, cTitulo, oFont3, (nLimDir-nLimEsq)+nMrgEsq, nAltCab, CLR_BLACK, 2, 0)
					oPrint:SayAlign(nLin+(nAltCab-nAltFonCab)/2, nLimEsq, AllTrim(SM0->M0_FILIAL), oFont3, (nLimDir-nLimEsq)-nMrgDir, nAltCab, CLR_BLACK, 1, 0)
					
					nLin := nLin+nAltCab+40
					
					nMrgMeio := nMrgEsq+((nLimDir-nLimEsq)/2)+9
					
					oPrint:Say (nLin, nLimEsq, "SACADO", oFont2,,,,) 
					oPrint:Say (nLin, nMrgMeio, "CEDENTE", oFont2,,,,)
					
					nLin += 5
					
					oPrint:Box(nLin, nLimEsq, nLin+nAltCab+20, nMrgEsq+((nLimDir-nLimEsq)/2) -10,"-3")
					oPrint:Box(nLin, nMrgMeio, nLin+nAltCab+20, nLimDir,"-3")
					
					nLinAux := nLin+nAltCab+60
					
					nLin += 30
					
					xNomecob  := AllTrim(SM0->M0_NOME)
					xEndcob   := AllTrim(SM0->M0_ENDCOB)
					xTelcob   := AllTrim(SM0->M0_TEL)
					xCgccob   := TransForm(SM0->M0_CGC,"@R 99.999.999/9999-99")
					xCidcob   := AllTrim(SM0->M0_CIDCOB)
					xEstcob   := SM0->M0_ESTCOB
					xFilCob   := AllTrim(SM0->M0_FILIAL)
															
					
					//______________________________________________________________________________________________
					//                                                                                       		|
					// Descricao : Posiciona sobre o Emitente/Transportadora responsavel pelo envio da mercadoria   |
					//______________________________________________________________________________________________|
					
					//GU3->(dbGoto(aInfoRel[nX][3]))
					
					//_____________________________________________________________________________________________________
					//                                                                                       			   |
					// Descricao : Verifica as condicoes que determinam se o Emitente pode ser o Cliente ou o Fornecedor   |
					//_____________________________________________________________________________________________________|
					/*
					If GU3->GU3_CLIEN =="1"
						
						xCgc	  := TransForm(Posicione("SA1",3,xFilial("SA1")+Alltrim(GU3->GU3_IDFED),"A1_CGC"),"@R 99.999.999/9999-99")
						xCodigo   := "000478"//AllTrim(SA1->A1_COD)
						xLoja     := "01" //AllTrim(SA1->A1_LOJA)
						xNome     := "TRANSPORTADORA XXXXX" //AllTrim(SA1->A1_NOME)
						xEnd      := AllTrim(SA1->A1_END )
						xCep      := AllTrim(SA1->A1_CEP)
						xMun      := AllTrim(SA1->A1_MUN )   
						xEst      := AllTrim(SA1->A1_EST)       
						xInscr    := AllTrim(SA1->A1_INSCR)
						xTel      := AllTrim(SA1->A1_TEL) ,
						0
					Else
						xCgc	  := TransForm(Posicione("SA2",3,xFilial("SA2")+Alltrim(GU3->GU3_IDFED),"A2_CGC"),"@R 99.999.999/9999-99")
						xCodigo   := AllTrim(SA2->A2_COD)
						xLoja     := AllTrim(SA2->A2_LOJA)
						xNome     := AllTrim(SA2->A2_NOME)
						xEnd      := AllTrim(SA2->A2_END )
						xCep      := AllTrim(SA2->A2_CEP)
						xMun      := AllTrim(SA2->A2_MUN )   
						xEst      := AllTrim(SA2->A2_EST)       
						xInscr    := AllTrim(SA2->A2_INSCR)
						xTel      := AllTrim(SA2->A2_TEL) 
					Endif 
					*/  
					
					//If !Empty( Posicione("SA4",3,xFilial("SA4")+Alltrim(aInfoRel[nX][12]),"A4_CGC")) 
					
					SA4->(dbGoto(aAux[nX][12]))                                  
					
					xCgc	  := SA4->A4_CGC 
					xCodigo   := SA4->A4_COD 
					xLoja     := "" //SA4->
					xNome     := SA4->A4_NOME
					xEnd      := SA4->A4_END
					xCep      := SA4->A4_CEP
					xMun      := SA4->A4_MUN
					xEst      := SA4->A4_EST
					xInscr    := SA4->A4_YINSCR
					xTel      := SA4->A4_TEL
					//Endif 	
					
					
					oPrint:Say (nLin, nLimEsq+20, xNomecob, oFont1,,,,)
					oPrint:Say (nLin, nMrgMeio+20, xCodigo+"/" + xLoja + " - "+xNome, oFont1,,,,)
					
					nLin += 30
					
					oPrint:Say (nLin, nLimEsq+20, xEndcob+", "+xCidcob+" - "+xEstcob, oFont1,,,,)
					
					oPrint:Say (nLin, nMrgMeio+20, xEnd+","+xMun+" - "+xEst, oFont1,,,,)
					nLin += 30
					oPrint:Say (nLin, nLimEsq+20, "Tel.: "+xTelcob, oFont1,,,,)
					oPrint:Say (nLin, nMrgMeio+20,"Tel.: "+xTel, oFont1,,,,)
					
					nLin += 30
					oPrint:Say (nLin, nLimEsq+20 , "CNPJ: "+xCgccob, oFont1,,,,)
					oPrint:Say (nLin, nMrgMeio+20, "CNPJ: "+xCgc+Space(10)+"IE: "+xInscr,oFont1,,,,)
					
					nLin := nLinAux
					
					oPrint:Say(nLin, nLimEsq, "DADOS DO COMPROMISSO/ROMANEIO", oFont2,,,,)
					
					nLin += 5
					
					oPrint:Box(nLin, nLimEsq, nLin+nAltCab+50, nLimDir,"-3")
					
					nLinAux := nLin+nAltCab+60
					
					nLin += 30
					
					oPrint:Say (nLin, nLimEsq+20, "Numero......: " + cNum + " ", oFont1,,,,) 
					//oPrint:Say (nLin, nLimEsq+235, cNum + IIf(cProvis = "S"," - [PROVIS�O]",""), oFont2,,,,) 
					oPrint:Say (nLin, nMrgMeio+20, "Vencimento........: ", oFont1,,,,)
					
					//oPrint:Say (nLin, nMrgMeio+330, DtoC(StoD(dVencto)), oFont2,,,,)
					oPrint:Say (nLin, nMrgMeio+330, DtoC(StoD(dVencto)), oFont2,,,,)
					
					nLin += 30
					
					oPrint:Say (nLin, nLimEsq+20, "Emissao.....: ", oFont1,,,,)
					//oPrint:Say (nLin, nLimEsq+235, DtoC(StoD(dEmissao)), oFont2,,,,) 
					//oPrint:Say (nLin, nLimEsq+235, DtoC(StoD(dEmissao)), oFont2,,,,)
					oPrint:Say (nLin, nLimEsq+235, dEmissao, oFont2,,,,)
					
					
					oPrint:Say (nLin, nMrgMeio+20, "Valor Rota (R$)...: ", oFont1,,,,)
					oPrint:Say (nLin, nMrgMeio+330, AllTrim(TransForm(nValFre,"@E 999,999,999.99")), oFont2,,,,)
					
					nLin += 30
					
					oPrint:Say (nLin, nLimEsq+20, "C. de Custo.: "+cValToChar(AllTrim(cCTT))+"", oFont1,,,,)
					//oPrint:Say (nLin, nLimEsq+235, AllTrim(cCusto), oFont2,,,,)   
					
					oPrint:Say (nLin, nMrgMeio+20, "Desconto (R$).....: ", oFont1,,,,)
					oPrint:Say (nLin, nMrgMeio+330,/*AllTrim(TransForm(nDescon,"@E 999,999,999.99"))*/ "---", oFont2,,,,)
					
					nLin += 30
					
					oPrint:Say (nLin, nLimEsq+20, "Codigo Rota / Negociacao.: " + AllTrim(cRota) +" ", oFont1,,,,)
					//oPrint:Say (nLin, nLimEsq+235, AllTrim(cRota), oFont2,,,,)  
					
					oPrint:Say (nLin, nMrgMeio+20, "Desp. Adic. (R$)..: ---", oFont1,,,,)
					oPrint:Say (nLin, nMrgMeio+330, "---"/*AllTrim(TransForm(nValAdic,"@E 999,999,999.99"))*/, oFont2,,,,)
					
					nLin += 30
					
					oPrint:Say (nLin, nLimEsq+20, "Operacao: " + cValToChar(IIF(cF1F2 == "F2", "VENDA","DEVOLUCAO/NEGOCIACAO")) + " ", oFont1,,,,)
					//oPrint:Say (nLin, nLimEsq+235, AllTrim(cDesc), oFont2,,,,)   
					
					oPrint:Say (nLin, nMrgMeio+20, "Frete Total (R$)..: ", oFont1,,,,)
					oPrint:Say (nLin, nMrgMeio+330, AllTrim(TransForm(nValTot,"@E 999,999,999.99")), oFont2,,,,)
					
					nLin := nLinAux + 30
					
					oPrint:Say (nLin, nLimEsq, "COMPOSICAO DO(S) CONHECIMENTO(S) DE TRANSPORTE", oFont2,,,,)
					
					nLin += 5
					
					oPrint:Line(nLin, nLimEsq, nLin, nLimDir   , , "-3")
					
					//________________________________________________________________________________________________________________
					//                                                                                                                | 
					// Descricao : Cabecalho dos itens do Frete                                                                       |
					//________________________________________________________________________________________________________________|
					
					oPrint:Say (nLin+30, nLimEsq+20,   "Num. CTRC", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+190,  "NF Orig.", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+345,  "Cliente", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+683, "  Total NF", oFont2,,,,)    
					oPrint:Say (nLin+30, nLimEsq+860,  " Proc", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+970, "Caixas", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+1100, "Pallet", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+1237, "Frete", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+1387, "Rota", oFont2,,,,)
					/*oPrint:Say (nLin+30, nLimEsq+1387, "Ad. KM", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+1537, "Ped�gio", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+1687, "Descarga", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+1837, "Di�ria", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+1987, "Outros", oFont2,,,,)
					oPrint:Say (nLin+30, nLimEsq+2097, "Tot. Frete", oFont2,,,,)*/
				
					
					nTotP:= 0
					nTot := 0
					nCxs := 0
					nPlt := 0
					nFrt := 0
					nAdc := 0
					nPed := 0
					nDes := 0
					nDia := 0
					nOut := 0   
					
					bIgual := .F.                                                                                                     
					cDocSerZ05 := ''
					cProcesZ05 := ''
					cNomeZ05   := ''
					cOriSerZ05 := ''
					nTotDocZ05 := 0
					nVolumeZ05 := 0
					nPalletZ05 := 0
					nVlrdocZ05 := 0
					nVlrkmZ05  := 0
					nVlrpedZ05 := 0
					nVlrdesZ05 := 0
					nVlrdiaZ05 := 0
					nVlroutZ05 := 0
					nTotpZ05   := 0
					nCxNF	   := 0 
						
					//____________________________________________________________________________________________________________________________________________________________
					//                                                                                                                                                            | 
					// Descricao : Impress�o aglutinando dos CTR                                                                                                                  |
					//____________________________________________________________________________________________________________________________________________________________|
																																												
					cPegaRota := ""
					For nW := 1 To Len(aAux)
							
							cDocSerZ05 := Alltrim(aAux[nW][2]) + " " + aAux[nW][3] 
							cOriSerZ05 := aAux[nW][4]   
							cNomeZ05   := aAux[nW][5]	

						
							
							// Tratamento de Beneficiamento sobre frete de Venda   
							
							// Teste
							//nTotDocZ05 := Z05->Z05_TOTDOC    
							
							nVolumeZ05 := IIF(Z05->Z05_PROCES == 'T',Z05->Z05_VOLUME,0)
							
							If Alltrim(aAux[nW][8])$ ("PALETES/PALLETS")
								nCxNF	   := 0 
								nPalletZ05 := aAux[nW][9]           
								nPlt	   += nPalletZ05
								
								
							Elseif Alltrim(aAux[nW][8]) $ ("CAIXAS")
								nPalletZ05 	:= 0 
								nCxNF 		:= aAux[nW][9]
								nCxs  		+= nCxNF 
							
							Endif  
																									
							// Teste
							//nVlrdocZ05 := IIf(xfilial("Z05")== '01',Z05->Z05_VLRDOC,Z05->Z05_VLRPAL)   
							nVlrdocZ05 := aAux[nW][11]
							nFrt	   += nVlrdocZ05
							
							nTotDocZ05 	:= aAux[nW][6]	
							nTot 		+= nTotDocZ05
							
							
							nVlrkmZ05  := Z05->Z05_VLRKM
							nVlrpedZ05 := Z05->Z05_VLRPED  
							
							nVlrdesZ05 := Z05->Z05_VLRDES      
							nVlrdiaZ05 := Z05->Z05_VLRDIA
							nVlroutZ05 := Z05->Z05_VLROUT
							
							//nTotpZ05   := IIf(xfilial("Z05")== '01',Z05->Z05_VLRDOC,Z05->Z05_VLRPAL)+Z05->Z05_VLRKM+Z05->Z05_VLRPED+Z05->Z05_VLRDES+Z05->Z05_VLRDIA+Z05->Z05_VLROUT
							nTotpZ05   := aAux[nW][11]
							nTotP	   += nTotpZ05
							
							nLinAux := nLin+30
							oPrint:Line(nLin, nLimEsq, nLin+30, nLimEsq, , "-3")
							oPrint:Line(nLin, nLimDir, nLin+30, nLimDir, , "-3")
							oPrint:Say (nLinAux+30, nLimEsq+20, Alltrim(cDocSerZ05) + "/" + Alltrim(cOriSerZ05) , oFont1,,,,)     
							//cPegaRota += Trecho( Alltrim(aAux[nW][3]), Alltrim(cOriSerZ05) )
							oPrint:Say (nLinAux+30, nLimEsq+345, SubStr(cNomeZ05,1,22), oFont1,,,,) //Redu��o para inclu��o de somat�rio e campo de processo
							
							//oPrint:Say (nLinAux+30, nLimEsq+889, cProcesZ05, oFont1,,,,)
							oPrint:Say (nLinAux+30, nLimEsq+889, aAux[nW][10], oFont1,,,,) 							// Tipo de Produto (T: Termo; i :Injetado )
							
							oPrint:Say (nLinAux+30, nLimEsq+683, TransForm(nTotDocZ05,"@E 999,999.99"), oFont1,,,,)
							oPrint:Say (nLinAux+30, nLimEsq+950, TransForm(nCxNF,"@E 999999"), oFont1,,,,)  
							oPrint:Say (nLinAux+30, nLimEsq+1060, TransForm(nPalletZ05,"@E 999999"), oFont1,,,,)  
							oPrint:Say (nLinAux+30, nLimEsq+1180, TransForm(nVlrdocZ05,"@E 999,999.99"), oFont1,,,,)

							oPrint:Say (nLinAux+30, nLimEsq+1387, Trecho( Alltrim(aAux[nW][3]), Alltrim(cOriSerZ05) ), oFont1,,,,)
							/*oPrint:Say (nLinAux+30, nLimEsq+1340, TransForm(nVlrkmZ05,"@E 9,999.99"), oFont1,,,,)
							oPrint:Say (nLinAux+30, nLimEsq+1500, TransForm(nVlrpedZ05,"@E 9,999.99"), oFont1,,,,)
							oPrint:Say (nLinAux+30, nLimEsq+1660, TransForm(nVlrdesZ05,"@E 9,999.99"), oFont1,,,,)
							oPrint:Say (nLinAux+30, nLimEsq+1820, TransForm(nVlrdiaZ05,"@E 999.99"), oFont1,,,,)
							oPrint:Say (nLinAux+30, nLimEsq+1970, TransForm(nVlroutZ05,"@E 999.99"), oFont1,,,,)
							oPrint:Say (nLinAux+30, nLimEsq+2090, TransForm(nTotpZ05,"@E 999,999.99"), oFont1,,,,)  
							*/
							bIgual := .T. 
							cOriSerZ05 := AllTrim(Z05->Z05_DOCORI)+"-"+Z05->Z05_SERORI
							cProcesZ05 := Z05->Z05_PROCES  
							cNomeZ05   := Posicione("SA1",1,xFilial("SA1")+Z05->Z05_CLIENT+Z05->Z05_LJCLI,"A1_NOME")
							nTotDocZ05 := Z05->Z05_TOTDOC
							nVolumeZ05 := IIF(Z05->Z05_PROCES == 'T',Z05->Z05_VOLUME,0)
							nPalletZ05 := Z05->Z05_PALLET 
							nVlrdocZ05 := IIf(xfilial("Z05")== '01',Z05->Z05_VLRDOC,Z05->Z05_VLRPAL)   
							/*nVlrkmZ05  := Z05->Z05_VLRKM
							nVlrpedZ05 := Z05->Z05_VLRPED  
							nVlrdesZ05 := Z05->Z05_VLRDES    
							nVlrdiaZ05 := Z05->Z05_VLRDIA
							nVlroutZ05 := Z05->Z05_VLROUT
							nTotpZ05   := IIf(xfilial("Z05")== '01',Z05->Z05_VLRDOC,Z05->Z05_VLRPAL)+Z05->Z05_VLRKM+Z05->Z05_VLRPED+Z05->Z05_VLRDES+Z05->Z05_VLRDIA+Z05->Z05_VLROUT
							*/
							nLin += 30
						
						
							nTotP += IIF(xfilial("Z05")== '01',Z05->Z05_VLRDOC,Z05->Z05_VLRPAL)+Z05->Z05_VLRKM+Z05->Z05_VLRPED+Z05->Z05_VLRDES+Z05->Z05_VLRDIA+Z05->Z05_VLROUT
							
							//nTot += Z05->Z05_TOTDOC
							//nCxs += IIF(Z05->Z05_PROCES == 'T',Z05->Z05_VOLUME,0)
						
						
							nPlt += Z05->Z05_PALLET
						
						
							nFrt += IIF(xfilial("Z05")== '01',Z05->Z05_VLRDOC,Z05->Z05_VLRPAL)
							nAdc += Z05->Z05_VLRKM
							nPed += Z05->Z05_VLRPED

							nDes += Z05->Z05_VLRDES
							nDia += Z05->Z05_VLRDIA
							nOut += Z05->Z05_VLROUT
										
							cDocSerZ05 := AllTrim(Z05->Z05_DOC)+"-"+Z05->Z05_SERIE 
						
							nAcond := 0           
							cProd := ''
							cDescProd := ''
					
					Next nW
					

					nLinAux := nLin+30
					oPrint:Line(nLin, nLimEsq, nLin+30, nLimEsq, , "-3")
					oPrint:Line(nLin, nLimDir, nLin+30, nLimDir, , "-3")       
					oPrint:Say (nLinAux+30, nLimEsq+340, "TOTAIS ----------->", oFont2,,,,)
					oPrint:Say (nLinAux+30, nLimEsq+623, TransForm(nTot,"@E 999,999,999.99"), oFont2,,,,)
					oPrint:Say (nLinAux+30, nLimEsq+950, TransForm(nCxs,"@E 999999"), oFont2,,,,)
					oPrint:Say (nLinAux+30, nLimEsq+1060, TransForm(nPlt,"@E 999999"), oFont2,,,,)
					oPrint:Say (nLinAux+30, nLimEsq+1180, TransForm(nFrt,"@E 999,999.99"), oFont2,,,,)
					/*
					oPrint:Say (nLinAux+30, nLimEsq+1340, TransForm(nAdc,"@E 9,999.99"), oFont2,,,,)
					oPrint:Say (nLinAux+30, nLimEsq+1500, TransForm(nPed,"@E 9,999.99"), oFont2,,,,)
					oPrint:Say (nLinAux+30, nLimEsq+1660, TransForm(nDes,"@E 9,999.99"), oFont2,,,,)
					oPrint:Say (nLinAux+30, nLimEsq+1820, TransForm(nDia,"@E 999.99"), oFont2,,,,)
					oPrint:Say (nLinAux+30, nLimEsq+1970, TransForm(nOut,"@E 9,999.99"), oFont2,,,,)	 
					oPrint:Say (nLinAux+30, nLimEsq+2090, TransForm(nTotP,"@E 999,999.99"), oFont2,,,,)
					*/
					nLin += 30
					
					oPrint:Line(nLin, nLimEsq, nLin+50, nLimEsq, , "-3")
					oPrint:Line(nLin, nLimDir, nLin+50, nLimDir, , "-3")
					
					nLin += 50
					
					oPrint:Line(nLin, nLimEsq, nLin, nLimDir   , , "-3")
					
					nLin += 40
					/*
					////////////////////////////////////////////////////////////////////////////////////////////////////////////
					//ROTAS
					oPrint:Say (nLin, nLimEsq, "ROTAS", oFont2,,,,)					
					nLin += 5					
					oPrint:Line(nLin, nLimEsq, nLin, nLimDir   , , "-3")
				
					aRota := StrTokArr(cPegaRota,"|")	
					For nW := 1 To Len(aRota)
						IF!Empty(cValToChar(aRota[nW]))
							nLinAux := nLin+30
							oPrint:Line(nLin, nLimEsq, nLin+30, nLimEsq, , "-3")
							oPrint:Line(nLin, nLimDir, nLin+30, nLimDir, , "-3")
							oPrint:Say (nLinAux, nLimEsq+20, cValToChar(aRota[nW]) , oFont1,,,,)
							nLin += 30
							nLinAux := nLin+30
						EndIF						
					Next nW			
					

					//fechando rodap� de sess�o das rotas
					nLinAux := nLin+30					
					oPrint:Line(nLin, nLimEsq, nLin+50, nLimEsq, , "-3")
					oPrint:Line(nLin, nLimDir, nLin+50, nLimDir, , "-3")				
					nLin += 50					
					oPrint:Line(nLin, nLimEsq, nLin, nLimDir   , , "-3")					
					nLin += 40
					//Fim das ROTAS
					////////////////////////////////////////////////////////////////////////////////////////////////////////////
					*/
					//OBSERVACAO
					oPrint:Say (nLin, nLimEsq, "OBSERVACAO", oFont2,,,,)
					
					nLin += 5
					
					oPrint:Line(nLin, nLimEsq, nLin, nLimDir   , , "-3")
				
					//Observa��o 01
					nLinAux := nLin+30
					oPrint:Line(nLin, nLimEsq, nLin+30, nLimEsq, , "-3")
					oPrint:Line(nLin, nLimDir, nLin+30, nLimDir, , "-3")					
					//oPrint:Say (nLinAux, nLimEsq+20, AllTrim(MV_PAR06), oFont1,,,,)					
					nLin += 30
					
					//Observa��o 02
					nLinAux := nLin+30
					oPrint:Line(nLin, nLimEsq, nLin+30, nLimEsq, , "-3")
					oPrint:Line(nLin, nLimDir, nLin+30, nLimDir, , "-3")					
					//oPrint:Say (nLinAux, nLimEsq+20, AllTrim(MV_PAR07), oFont1,,,,)
					nLin += 30

					//Observa��o 03
					nLinAux := nLin+30
					oPrint:Line(nLin, nLimEsq, nLin+30, nLimEsq, , "-3")
					oPrint:Line(nLin, nLimDir, nLin+30, nLimDir, , "-3")					
					//oPrint:Say (nLinAux, nLimEsq+20, AllTrim(MV_PAR08), oFont1,,,,)
					nLin += 30

					//Observa��o 04
					nLinAux := nLin+30
					//oPrint:Say (nLinAux, nLimEsq+20, AllTrim(MV_PAR09), oFont1,,,,)
					oPrint:Line(nLin, nLimEsq, nLin+50, nLimEsq, , "-3")
					oPrint:Line(nLin, nLimDir, nLin+50, nLimDir, , "-3")
				
				
					nLin += 50					
					oPrint:Line(nLin, nLimEsq, nLin, nLimDir   , , "-3")
					//Fim das OBSERVACAO
					
					nLin += 40

					oPrint:Say (nLin, nLimEsq, "LANCAMENTO E AUTORIZACAO", oFont2,,,,)
					
					nLin += 5
					oPrint:Box(nLin, nLimEsq, nLin+(nAltCab*2)+30, nLimDir,"-3")
					nTamSec := (nLimDir-nLimEsq)/3  //Tamanho das secoes
					
					nLin += 60      
					
					//oPrint:SayAlign(nLin, nLimEsq, "__________/__________/__________", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					//oPrint:SayAlign(nLin, nLimEsq+nTamSec, "__________/__________/__________", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					// Teste
					//oPrint:SayAlign(nLin, nLimEsq, DtoC(StoD(cTrab->Z04_DTDIGI)), oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					
		 
					//oPrint:SayAlign(nLin, nLimEsq, AllTrim(cValToChar(cUser))+" "+cValToChar(cUserDT), oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
				    oPrint:SayAlign(nLin, nLimEsq+nTamSec, DtoC(ddatabase), oFont1, nTamSec, 30, CLR_BLACK, 2, 0)					
					oPrint:SayAlign(nLin, nLimEsq+(nTamSec*2), "__________/__________/__________", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					//oPrint:SayAlign(nLin, nLimEsq+(nTamSec*2), "Liberado: "+cValToChar(cUserAlt)+"", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					nLin += 30
					oPrint:SayAlign(nLin, nLimEsq, "Data de Lancamento", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					//oPrint:SayAlign(nLin, nLimEsq, , oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					
					oPrint:SayAlign(nLin, nLimEsq+nTamSec, "Data de Emissao", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					oPrint:SayAlign(nLin, nLimEsq+(nTamSec*2), "Data da Aprovacao", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					//oPrint:SayAlign(nLin, nLimEsq+(nTamSec*2), cValToChar(cDTAlt), oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
						   
		   
					nLin += 90
					
					//oPrint:SayAlign(nLin, nLimEsq, "________________________________", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					//oPrint:SayAlign(nLin, nLimEsq+nTamSec, "________________________________", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					oPrint:SayAlign(nLin, nLimEsq+(nTamSec*2), "________________________________", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					
					nLin += 30
					
					// Cancelamento do usuario
					//oPrint:SayAlign(nLin, nLimEsq, AllTrim(cTrab->Z04_USER), oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					
					//oPrint:SayAlign(nLin, nLimEsq+nTamSec, AllTrim(cUserName), oFont1, nTamSec, 30, CLR_BLACK, 2, 0) 
					oPrint:SayAlign(nLin, nLimEsq+nTamSec, "Supervisao", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
					oPrint:SayAlign(nLin, nLimEsq+(nTamSec*2), "Gerencia/Diretoria", oFont1, nTamSec, 30, CLR_BLACK, 2, 0)
						
					nLin += 170
					
					/* Teste
					If (Mod(nAux,2) = 0)                              
						oPrint:Say (nLin, nLimEsq, Replicate("- ",76), oFont1,,,,)
						nLin := 150
						//oPrint:Say (nLin, nLimEsq, Replicate("- ",76), oFont1,,,,)
						oPrint:EndPage()
						oPrint:StartPage()
					EndIf
					*/ 
					
					oPrint:Say (nLin, nLimEsq, Replicate("- ",76), oFont1,,,,)
					nLin := 150
					//oPrint:Say (nLin, nLimEsq, Replicate("- ",76), oFont1,,,,)
					oPrint:EndPage()
					oPrint:StartPage()
					
		Next nX


		// Termina a p�gina

		oPrint:EndPage()

		// Mostra tela de visualiza��o de impress�o
		oPrint:Preview()

		Return Nil



		Static Function _CriaTrab()

		Local cQuery1, cCondicao,cCaps := 0, cCapsFinal, i, j, cTemp := 0
		cQuery1 := ""
		cCaps	:= replace(allTrim(MV_PAR11),"*","','")
		cCondicao:=""

		cQuery1 += "SELECT  * "
		cQuery1 += "FROM "+RetSqlName("Z04")+" Z04 "
		cQuery1 += "WHERE Z04.D_E_L_E_T_ = '' "  
		cQuery1 += "AND Z04_FILIAL = '" + xFilial("Z04") + "' "
		cQuery1 += "AND Z04_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		cQuery1 += "AND Z04_DTEMIS BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' "
		cQuery1 += "ORDER BY Z04_NUM "

		TcQuery cQuery1 New Alias "cTrab"

Return


//Verifica a existencia das Perguntas (SX1) se n�o existir inclui.
Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

//Grupo/Ordem/Pergunta/Perg Spa/Perg Eng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Numero Frete de   :","","","mv_ch1" ,"C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Numero Frete ate  :","","","mv_ch2" ,"C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Dta Emiss�o de    :","","","mv_ch3" ,"D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Dta Emiss�o at�   :","","","mv_ch4" ,"D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return    
           
/*
*/
Static Function fRetProc( nTipo,cNota,cSerie,cCliente,cLoja)

	Local cRet := ""
       
    If nTipo < 2  
		
		BeginSql Alias "cTrab2"
				%noparser%
				
				SELECT TOP 1 
					CASE 
						WHEN SUBSTRING(D2_COD,1,1) = '6' THEN 'T' 
						ELSE 
							CASE 
								WHEN SUBSTRING(D2_COD,1,1) = '3' 
									THEN 'T' 
								ELSE 
									CASE 
										WHEN SUBSTRING(D2_COD,1,1) = '4' 
											THEN 'I' 
											ELSE 'O' 
									END 
							END 
					END AS 'PROCES',
				SUM(D2_TOTAL) AS 'TOTAL'         
				
				FROM %Table:SD2% 
				
				WHERE D2_FILIAL = %xFilial:SD2%  
				
					AND D2_DOC = %Exp:cNota%
					AND D2_SERIE = %Exp:cSerie%
					AND D2_CLIENTE = %Exp:cCliente%
					AND D2_LOJA = %Exp:cLoja%
					AND %notDel%
					GROUP BY SUBSTRING(D2_COD,1,1)
				
					ORDER BY 2 DESC
				
		 EndSql
	
	Else
		 //________________________________________________________________________________________________ 
		 //                                                                                                | 
		 // Descricao : Produtos para os quais ha Documento de Entrada                                     |
		 //________________________________________________________________________________________________|
		 
		 BeginSql Alias "cTrab2"
				
				%noparser%
			
				SELECT TOP 1 
					CASE 
						WHEN SUBSTRING(D1_COD,1,1) = '6' THEN 'T' 
						ELSE 
							CASE 
								WHEN SUBSTRING(D1_COD,1,1) = '3' 
									THEN 'T' 
								ELSE 
									CASE 
										WHEN SUBSTRING(D1_COD,1,1) = '4' 
											THEN 'I' 
											ELSE 'O' 
									END 
							END 
					END AS 'PROCES',
				SUM(D1_TOTAL) AS 'TOTAL'         
				
				FROM %Table:SD1% 
				
				WHERE D1_FILIAL = %xFilial:SD1%  
				
					AND D1_DOC = %Exp:cNota%
					AND D1_SERIE = %Exp:cSerie%
					AND D1_FORNECE = %Exp:cCliente%
					AND D1_LOJA = %Exp:cLoja%
					AND %notDel%
					GROUP BY SUBSTRING(D1_COD,1,1)
				
				 ORDER BY 2 DESC
	 	 EndSql
	Endif 	
	
	dbSelectArea("cTrab2")

	cRet := cTrab2->PROCES

	cTrab2->(dbCloseArea())

Return cRet



Static Function Trecho(doc, serie)
			
			Local aUF		 := {}
			Local trecho := ""
			Local cQuery := ""
			Local cCodUFO := ""
			Local cCodUFD := ""
			Local cCodCIDO := ""
			Local cCodCIDD := ""
			
			

		 //|Regi�o Norte |
			aAdd(aUF,{"RO","11"})
			aAdd(aUF,{"AC","12"})
			aAdd(aUF,{"AM","13"})
			aAdd(aUF,{"RR","14"})
			aAdd(aUF,{"PA","15"})
			aAdd(aUF,{"AP","16"})
			aAdd(aUF,{"TO","17"})

			//|Regi�o Nordeste |
			aAdd(aUF,{"MA","21"})
			aAdd(aUF,{"PI","22"})
			aAdd(aUF,{"CE","23"})
			aAdd(aUF,{"RN","24"})
			aAdd(aUF,{"PB","25"})
			aAdd(aUF,{"PE","26"})
			aAdd(aUF,{"AL","27"})
			aAdd(aUF,{"SE","28"})
			aAdd(aUF,{"BA","29"})

			//|Regi�o Sudeste |
			aAdd(aUF,{"MG","31"})
			aAdd(aUF,{"ES","32"})
			aAdd(aUF,{"RJ","33"})
			aAdd(aUF,{"SP","35"})

			//|Regi�o Sul |
			aAdd(aUF,{"PR","41"})
			aAdd(aUF,{"SC","42"})
			aAdd(aUF,{"RS","43"})

			//|Regi�o Centro-Oeste |
			aAdd(aUF,{"MS","50"})
			aAdd(aUF,{"MT","51"})
			aAdd(aUF,{"GO","52"})
			aAdd(aUF,{"DF","53"})	 
	   
	  
			cQuery += " SELECT  GWU_SEQ , "
			cQuery += " SUBSTRING(GWU_NRCIDO, 1, 2) UFO,  "	   
			cQuery += " SUBSTRING(GWU_NRCIDO, 3, 6) CIDO, "
			cQuery += " GWU_NRCIDO, "

			cQuery += " SUBSTRING(GWU_NRCIDD, 1, 2) UFD, "
			cQuery += " SUBSTRING(GWU_NRCIDD, 3, 6) CIDD,	"	
			cQuery += " GWU_NRCIDD, "
			cQuery += " RTRIM(LTRIM(GWU_NRDC))+'/'+RTRIM(LTRIM(GWU_SERDC)) AS DOCNF    " 
			
			cQuery += " FROM " + RetSQLName("GWU") + " 		
			cQuery += " WHERE GWU_NRDC = " + ValToSql(doc)
			cQuery += " AND GWU_SERDC = " + ValToSql(serie)
			cQuery += " AND GWU_FILIAL = '" + xFilial("GWU") + "' "
			cQuery += " AND D_E_L_E_T_ = ''    "			
			cQuery += " ORDER BY GWU_NRDC , GWU_SEQ  "

		

		TcQuery cQuery new alias "DAtrecho" 
    DAtrecho->(DBGotop())   

		While !DAtrecho->(EOF()) 

				If (nPos := aScan(aUF, {|x| x[2] == cValToChar(DAtrecho->UFO)})) > 0
						cCodUFO	:= aUF[nPos,1]
						cCodCIDO :=  DAtrecho->CIDO

						cQuery := " select top 1   RTRIM(LTRIM(CC2_MUN))+' ('+RTRIM(LTRIM(CC2_EST))+') >> ' CIDORI  from CC2150 where CC2_EST = " + ValToSql(cCodUFO) + " AND CC2_CODMUN = " + ValToSql(cCodCIDO) + ""
			
   					TcQuery cQuery new alias "CIDORI" 

						If CIDORI->(!Eof())
							trecho +=  ""+ALLTRIM(cValToChar(CIDORI->CIDORI))+ ""
						EndIf
						CIDORI->(dbCloseArea()) 

				Endif
    
		 
				
				If (nPos := aScan(aUF, {|x| x[2] == cValToChar(DAtrecho->UFD)})) > 0
						cCodUFD	:= aUF[nPos,1]
						cCodCIDD :=  DAtrecho->CIDD
						cQuery := " select top 1   RTRIM(LTRIM(CC2_MUN))+' ('+RTRIM(LTRIM(CC2_EST))+')' CIDODE  from CC2150 where CC2_EST = " + ValToSql(cCodUFD) + " AND CC2_CODMUN = " + ValToSql(cCodCIDD) + ""
			
   					TcQuery cQuery new alias "CIDODE" 
						If CIDODE->(!Eof())
							trecho +=  " "+ALLTRIM(cValToChar(CIDODE->CIDODE))+ " "
						EndIf
						CIDODE->(dbCloseArea()) 
				EndIf
    
        DAtrecho->(dbSkip())

    EndDo 		

    DAtrecho->(dbCloseArea()) 

	

Return trecho
