#INCLUDE "PROTHEUS.CH"   
#INCLUDE "TOPCONN.CH"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao     ≥ FROPRE03 ≥ Autor ≥ FERNANDO ROCHA        ≥ Data ≥08/05/2015≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao  ≥ RELATORIO DE LOG DE MOVIMENTACAO DE RESERVAS/EMPENHOS	   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso        ≥ BIANCOGRES                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function FROPRE03()
Private oReport,oSection1,oSection2,oSection3

Private cPerg 		:= "FROPRE03"
Private aRegs 		:= {}
Private cAliasTemp	 	:=  GetNextAlias()

oReport:=ReportDef()
oReport:PrintDialog()


Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ReportDef ≥ Autor ≥Claudio D. de Souza    ≥ Data ≥28/06/2006≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥A funcao estatica ReportDef devera ser criada para todos os ≥±±
±±≥          ≥relatorios que poderao ser agendados pelo usuario.          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ExpO1: Objeto do relatÛrio                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥Nenhum                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥   DATA   ≥ Programador   ≥Manutencao efetuada                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥          ≥               ≥                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function ReportDef()
Local cReport := "FROPRE03"
Local cTitulo := "Log de Movimentacao de Reservas/Empenhos"
Local cDescri := "Log de Movimentacao de Reservas/Empenhos"
Local bReport := { |oReport|	oReport:SetTitle( oReport:Title() ),	ReportPrint( oReport ) }
Local cMoeda

ValPerg()

Pergunte(cPerg , .F. )
oReport  := TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
//oReport:SetLandScape()
oReport:SetPortrait()

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Define a 1a. secao do relatorio Valores nas Moedas   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oSection1 := TRSection():New( oReport  ,"RC",cAliasTemp, {} )
TRCell():New(oSection1	,"C5_NUM"	  		,,"Pedido"	  			,"@!", 6,/*lPixel*/, {||  } )
TRCell():New(oSection1	,"C6_ITEM"			,,"Item"				,"@!", 4,/*lPixel*/, {|| 	} )
TRCell():New(oSection1	,"C6_PRODUTO"	  	,,"Codigo"				,"@!", 10,/*lPixel*/, {||   } )
TRCell():New(oSection1	,"DESCRICAO"  		,,"Desc.Produto"		,"@!", 30,/*lPixel*/, {||   } )
TRCell():New(oSection1	,"C6_QTDVEN"	  	,,"Qtde"				,"@E 999,999.99", 10,/*lPixel*/, {||   } )
TRCell():New(oSection1	,"SALDO_PED"	  	,,"Sld.A Lib."			,"@E 999,999.99", 10,/*lPixel*/, {||   } )

oSection2 := TRSection():New( oSection1  ,"RC_Item",cAliasTemp, {} )
TRCell():New(oSection2	,"ARQUIVO"  		,,"Arquivo"		   		,"@!", 5,/*lPixel*/, {||  } ) 
TRCell():New(oSection2	,"STATUS"  			,,"Status"		   		,"@!", 10,/*lPixel*/, {||   } )
TRCell():New(oSection2	,"DOC"  			,,"Documento"	   		,"@!", 10,/*lPixel*/, {||  } )
TRCell():New(oSection2	,"EMISSAO"			,,"Emiss„o"		  		,"@!", 10,/*lPixel*/, {||   } )
TRCell():New(oSection2	,"HORA"  			,,"Hora"		   		,"@!", 6,/*lPixel*/, {||   } )
TRCell():New(oSection2	,"USUARIO" 			,,"Usuario"		   		,"@!", 10,/*lPixel*/, {||   } )
TRCell():New(oSection2	,"LOTE"  			,,"Lote"				,"@!", 8,/*lPixel*/, {||     } )
TRCell():New(oSection2	,"QUANT"	  		,,"Qtde"				,"@E 999,999.99", 10,/*lPixel*/, {||   } )
TRCell():New(oSection2	,"DATENT"  	 		,,"Dt.Entrega"			,"@!", 10,/*lPixel*/, {||   } )
oSection2:nLeftMargin := 10

oSection3 := TRSection():New( oSection2  ,"RC_Item_Reserva",cAliasTemp, {} )
TRCell():New(oSection3	,"PZ2_CONT" 		,,"Rotina"				,"@!", 10,/*lPixel*/, {||    } )
TRCell():New(oSection3	,"PZ2_CAMPO" 		,,"Processo"			,"@!", 10,/*lPixel*/, {||     } )
TRCell():New(oSection3	,"PZ2_CODMOT" 		,,"Motivo"				,"@!", 3,/*lPixel*/, {||     } ) 
TRCell():New(oSection3	,"PZ2_USURES" 		,,"Responsavel"			,"@!", 10,/*lPixel*/, {||     } ) 
TRCell():New(oSection3	,"PZ2_DATA" 		,,"Data"				,"@!", 10,/*lPixel*/, {||   } )
TRCell():New(oSection3	,"PZ2_HORA" 		,,"Hora"				,"@!", 6,/*lPixel*/, {||   } ) 
TRCell():New(oSection3	,"OBS"	 			,,"ObservaÁ„o"			,"@!", 60,/*lPixel*/, {||    } ) 
oSection3:nLeftMargin := 20



Return oReport

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ReportPrint∫Autor  ≥Claudio D. de Souza ∫ Data ≥  23/06/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Query de impressao do relatorio                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SIGAATF                                                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function ReportPrint( oReport )
	
	Local cChave	:= ""
	Local cWhere	:= ""
	Local cQuebra	:= .T.
	Local CSQL 		:= ""
	
	Local oSec1 := oReport:Section(1)
	Local oSec2 := oSec1:Section(1)
	Local oSec3 := oSec2:Section(1)
	 
		 	
	CSQL := "select * from FNC_ROP_REL_LOG_RESERVA_"+AllTrim(CEMPANT)+"('"+MV_PAR01+"','"+MV_PAR01+"','"+MV_PAR02+"','"+MV_PAR03+"',' ', '20991231') order by C5_NUM, C6_ITEM, EMISSAO, ARQUIVO, ID, PZ2_DATA, PZ2_HORA"
	
	TCQUERY CSQL New Alias (cAliasTemp)	
	
	oSec1:Init()
	While !((cAliasTemp)->(Eof()))
		
		oSec1:Cell("C5_NUM"		):SetValue((cAliasTemp)->C5_NUM   			)
		oSec1:Cell("C6_ITEM"	):SetValue((cAliasTemp)->C6_ITEM   			)
        oSec1:Cell("C6_PRODUTO"	):SetValue((cAliasTemp)->C6_PRODUTO   		)
        oSec1:Cell("DESCRICAO"	):SetValue((cAliasTemp)->DESCRICAO   		)
        oSec1:Cell("C6_QTDVEN"  ):SetValue((cAliasTemp)->C6_QTDVEN        	)
        oSec1:Cell("SALDO_PED"  ):SetValue((cAliasTemp)->SALDO_PED       	)
        
        oSec1:PrintLine()
        
        cChave1 := (cAliasTemp)->(C5_NUM+C6_ITEM)
        
        oSec2:Init()
        While !(cAliasTemp)->(Eof()) .And.	(cAliasTemp)->(C5_NUM+C6_ITEM) == cChave1
        	
        	
        	oSec2:Cell("ARQUIVO"  		):SetValue( (cAliasTemp)->ARQUIVO   				) 
			oSec2:Cell("STATUS"  		):SetValue( (cAliasTemp)->STATUS   					)
			oSec2:Cell("DOC"  			):SetValue( (cAliasTemp)->DOC   					)
			oSec2:Cell("EMISSAO"		):SetValue( DTOC(STOD((cAliasTemp)->EMISSAO))   	)
			oSec2:Cell("HORA"  			):SetValue( (cAliasTemp)->HORA   					)
			oSec2:Cell("USUARIO" 		):SetValue( (cAliasTemp)->USUARIO   				)
			oSec2:Cell("LOTE"  			):SetValue( (cAliasTemp)->LOTE     					)
			oSec2:Cell("QUANT"	  		):SetValue( (cAliasTemp)->QUANT   					)
			oSec2:Cell("DATENT"  		):SetValue( DTOC(STOD((cAliasTemp)->DATENT))   		)
			oSec2:PrintLine()
        	
        	cChave2 := (cAliasTemp)->(C5_NUM+C6_ITEM)+AllTrim(Str((cAliasTemp)->ID))
        	
			oSec3:Init()
			While !(cAliasTemp)->(Eof())  .And.	(cAliasTemp)->(C5_NUM+C6_ITEM)+AllTrim(Str((cAliasTemp)->ID)) == cChave2
				
				oSec3:Cell("PZ2_CONT" 		):SetValue(  (cAliasTemp)->PZ2_CONT     )
				oSec3:Cell("PZ2_CAMPO" 		):SetValue(  (cAliasTemp)->PZ2_CAMPO     )
				oSec3:Cell("PZ2_CODMOT" 	):SetValue( (cAliasTemp)->PZ2_CODMOT     ) 
				oSec3:Cell("PZ2_USURES" 	):SetValue(  (cAliasTemp)->PZ2_USURES     ) 
				oSec3:Cell("PZ2_DATA" 		):SetValue(  DTOC(STOD((cAliasTemp)->PZ2_DATA))   )
				oSec3:Cell("PZ2_HORA" 		):SetValue( (cAliasTemp)->PZ2_HORA     ) 
				oSec3:Cell("OBS"	 		):SetValue(  (cAliasTemp)->OBS     ) 
				
				oSec3:PrintLine()
				
				(cAliasTemp)->(DbSkip())
				        	
        	EndDo()
        	oSec3:Finish()
        	
        EndDo
        oSec2:Finish()
	
	EndDo
	 oSec1:Finish()

	(cAliasTemp)->(DbCloseArea())

Return Nil


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±≥ValPerg - Funcao para criar o grupo de perguntas SX1 se nao existir    ≥±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function ValPerg()
Local i,j,nX
Local aTRegs := {}
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

cPerg := PADR(cPerg,10)

//DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
aAdd(aTRegs,{"Pedido?"		,"C", 6,0,0,"G","","","","","","","",""})
aAdd(aTRegs,{"Item De?"		,"C", 2,0,0,"G","","","","","","","",""})
aAdd(aTRegs,{"Item Ate?"	,"C", 2,0,0,"G","","","","","","","",""})

//Criar aRegs na ordem do vetor Temporario
aRegs := {}
For I := 1 To Len(aTRegs)
	aAdd(aRegs,{cPerg, StrZero(I,2), aTRegs[I][1], aTRegs[I][1], aTRegs[I][1],;
	"mv_ch"+Alltrim(Str(I)), aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],;
	aTRegs[I][6],aTRegs[I][7],"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",;
	aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","",;
	"",aTRegs[I][12],"","","",aTRegs[I][13],""})
Next I

//Grava no SX1 se ja nao existir
dbSelectArea("SX1")
For i:=1 to Len(aRegs)

	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Else
		RecLock("SX1",.F.)
		For j:=3 to FCount()
			If j <= Len(aRegs[i])
				If SubStr(FieldName(j),1,6) <> "X1_CNT"
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	EndIf
	
	//HELP DAS PERGUNTAS
	aHelpPor := {}
	__aRet := STRTOKARR(aTRegs[I][14],"#")
	FOR nX := 1 To Len(__aRet)
		AADD(aHelpPor,__aRet[nX])
	NEXT nX
	PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)
	
Next

RETURN                	
