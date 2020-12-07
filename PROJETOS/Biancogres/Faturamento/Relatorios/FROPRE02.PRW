#INCLUDE "PROTHEUS.CH"   
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³ FROPRE02 ³ Autor ³ FERNANDO ROCHA        ³ Data ³30/03/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ RELATORIO DE ANALISE DE PONTAS E ARREMATE				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ BIANCOGRES                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FROPRE02()
Private oReport,oSection1,oSection2

Private cPerg 		:= "FROPRE02"
Private aRegs 		:= {}
Private cQuery	 	:= "FROPRE02"+AllTrim(__CUSERID)

oReport:=ReportDef()
oReport:PrintDialog()

If Select(cQuery) > 0
	(cQuery)->(DbCloseArea())
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Claudio D. de Souza    ³ Data ³28/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cReport := "FROPRE02"
Local cTitulo := "Analise de Pontas e Arremate de Lote"
Local cDescri := "Analise de Pontas e Arremate de Lote"
Local bReport := { |oReport|	oReport:SetTitle( oReport:Title() ),	ReportPrint( oReport ) }
Local cMoeda

ValPerg()

Pergunte(cPerg , .F. )
oReport  := TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
oReport:SetLandScape()
//oReport:SetPortrait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a 1a. secao do relatorio Valores nas Moedas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New( oReport  ,"01",cQuery, {} )                                                       
TRCell():New(oSection1	,"PEDIDO"	  		,,"Pedido"	  			,"@!", 6,/*lPixel*/, {|| (cQUERY)->PEDIDO } )
TRCell():New(oSection1	,"NOME"	   			,,"Cliente"	  			,"@!", 30,/*lPixel*/, {|| (cQUERY)->NOME } )
TRCell():New(oSection1	,"REPRESENTANTE"	,,"Representante"	  	,"@!", 20,/*lPixel*/, {|| (cQUERY)->REPRESENTANTE } )
TRCell():New(oSection1	,"ATENDENTE"		,,"Atendente"  			,"@!", 20,/*lPixel*/, {|| (cQUERY)->ATENDENTE } )
TRCell():New(oSection1	,"DATA_EMPENHO"		,,"Data Emp."	  		,"@!", 10,/*lPixel*/, {|| DTOC(STOD((cQUERY)->DATA_EMPENHO))  } )
TRCell():New(oSection1	,"COD_PRODUTO"	  	,,"Codigo"				,"@!", 10,/*lPixel*/, {|| (cQUERY)->COD_PRODUTO  } )
TRCell():New(oSection1	,"PRODUTO"  		,,"Desc.Produto"		,"@!", 30,/*lPixel*/, {|| (cQUERY)->PRODUTO  } )
TRCell():New(oSection1	,"LOTE"  			,,"Lote"				,"@!", 8,/*lPixel*/, {|| (cQUERY)->LOTE    } )
TRCell():New(oSection1	,"QTD_LIB"  		,,"Qtde"				,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->QTD_LIB  } )
TRCell():New(oSection1	,"SALDO_LOTE"  		,,"Saldo Lote"			,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->SALDO_LOTE  } )
TRCell():New(oSection1	,"Q_UM_PALETE"  	,,"Qt.Um Palete"		,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->Q_UM_PALETE  } )
TRCell():New(oSection1	,"MOTIVO"	  		,,"Motivo"				,"@!", 30,/*lPixel*/, {|| (cQUERY)->MOTIVO  } )

oSection1:SetTotalInLine(.F.)
TRFunction():New(oSection1:Cell("SALDO_LOTE"),, "SUM",/*oBreak*/,"Total de Ponta", /*cPicture*/, /*uFormula*/, .T. /*lEndSection*/, .F./*lEndReport*/, .F. /*lEndPage*/)

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintºAutor  ³Claudio D. de Souza º Data ³  23/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Query de impressao do relatorio                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport )
Local cChave
Local cWhere	:= ""
Local cQuebra	:= .T.
Local CSQL 		:= ""


If MV_PAR01 == 1
	oReport:SetTitle("Geração de Pontas")
Else
	oReport:SetTitle("Arremate de Lotes")
EndIf

oSection1:BeginQuery()
                            
If MV_PAR04 == 2
	CSQL := "exec SP_CONSULTA_PONTAS_ARREMATE_"+AllTrim(CEMPANT)+" "+AllTrim(Str(MV_PAR01))+", '"+DTOS(MV_PAR02)+"', '"+DTOS(MV_PAR03)+"'"
Else
	CSQL := "exec SP_CONSULTA_PONTAS_ARREMATE_"+AllTrim(CEMPANT)+" "+AllTrim(Str(4))+", '"+DTOS(MV_PAR02)+"', '"+DTOS(MV_PAR03)+"'"
EndIf

TCQUERY CSQL New Alias (CQUERY)

oSection1:EndQuery()
oSection1:Print()

Return Nil


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±³ValPerg - Funcao para criar o grupo de perguntas SX1 se nao existir    ³±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function ValPerg()
Local i,j,nX
Local aTRegs := {}
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

cPerg := PADR(cPerg,10)

//DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
aAdd(aTRegs,{"Tipo Relatorio?"		,"N", 1,0,0,"C","","Geracao Pontas","Arremate Lote","","","","",""})
aAdd(aTRegs,{"Dt.Empenho De?"		,"D", 8,0,0,"G","","","","","","","",""})
aAdd(aTRegs,{"Dt.Empenho Ate?"		,"D", 8,0,0,"G","","","","","","","",""})
aAdd(aTRegs,{"Sel.Manual do Lote?"	,"N", 1,0,0,"C","","Sim","Nao","","","","",""})

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
