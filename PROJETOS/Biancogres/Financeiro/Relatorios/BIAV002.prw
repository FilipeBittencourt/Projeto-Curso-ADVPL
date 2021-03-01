#INCLUDE "FINR130.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#include "topconn.ch"

#DEFINE QUEBR				1
#DEFINE CLIENT				2
#DEFINE TITUL				3
#DEFINE TIPO				4
#DEFINE NATUREZA			5
#DEFINE EMISSAO				6
#DEFINE VENCTO				7
#DEFINE VENCREA				8
#DEFINE BANC				9
#DEFINE VL_ORIG				10
#DEFINE VL_NOMINAL			11
#DEFINE VL_CORRIG			12
#DEFINE VL_VENCIDO			13
#DEFINE NUMBC				14
#DEFINE VL_JUROS			15
#DEFINE ATRASO				16
#DEFINE HISTORICO			17
#DEFINE VL_SOMA				18
#DEFINE CATEGORIA			19
#DEFINE SEGMENTO			20
#DEFINE RISCO				21
#DEFINE DATA_BASE			22
#DEFINE PREFIXO			    23
#DEFINE MARCA			    24

Static lFWCodFil		:= .T.
Static __lTempLOT
Static cDBType			:= Alltrim(Upper(TCGetDB()))
Static lSQL				:= !(cDBType $"ORACLE|POSTGRES|DB2|INFORMIX")
STATIC _nTamSEQ
STATIC cAliasProc
Static lProcCriad		:= .F.
Static lBQ10925			:= SuperGetMV("MV_BQ10925",,"2") == "1"
Static __cCliHashNatu	:= ''
Static cProcedure		:= IIF(FindFunction("GetSPName"), GetSPName("FIN002","11"), "FIN002")
Static __lProcSaldoTit	:= ExistProc( cProcedure, IDProcFinXFun() )
Static __lFound			:= .F.
// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*/

?
Perda - FINR130

Programação idêntica ao FINR130 para preenchimento do Perda utilizado no PowerBI 

*/
USER Function BIAV002(lAuto)
Local oReport
Private cMVBR10925 	:= SuperGetMv("MV_BR10925", ,"2")
Private dDtVenc 	:= ddatabase
Private lAbortPrint	:= .F.
Private aSelFil	:= {}
Private lSchedule := .F.

	Default lAuto := .F.
	
	lSchedule := lAuto
	
	oReport := ReportDef()
	
	If lSchedule
		
		oReport:nRemoteType := NO_REMOTE
		
		oReport:Print()
	
	Else
	
		oReport:PrintDialog()
		
	EndIf

Return()


Static Function ReportDef()
Local oReport	:= NIL
Local oSection1	:= NIL
Local oSection2	:= NIL
Local cPictTit	:= ""
Local nTamVal 	:= 0
Local nTamCli	:= 0
Local nTamQueb	:= 0
Local nTamJur	:= 0
Local nTamNBco	:= 0

oReport := TReport():New("FINR130",STR0005,"FIN130",{|oReport| ReportPrint(oReport)},STR0001+STR0002)

oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.) // Imprime o total em linhas
/*
GESTAO - inicio */
oReport:SetUseGC(.F.)
/* GESTAO - fim
*/

	If !lSchedule
		
		Pergunte("FIN130",.F.)
		
	EndIf

//?
//?Variaveis utilizadas para parametros	  								?
//?mv_par01		 // Do Cliente 	 										?
//?mv_par02		 // Ate o Cliente										?
//?mv_par03		 // Do Prefixo											?
//?mv_par04		 // Ate o prefixo 										?
//?mv_par05		 // Do Titulo											?
//?mv_par06		 // Ate o Titulo										?
//?mv_par07		 // Do Banco											?
//?mv_par08		 // Ate o Banco											?
//?mv_par09		 // Do Vencimento 										?
//?mv_par10		 // Ate o Vencimento									?
//?mv_par11		 // Da Natureza											?
//?mv_par12		 // Ate a Natureza										?
//?mv_par13		 // Da Emissao											?
//?mv_par14		 // Ate a Emissao										?
//?mv_par15		 // Qual Moeda											?
//?mv_par16		 // Imprime provisorios									?
//?mv_par17		 // Reajuste pelo vecto									?
//?mv_par18		 // Impr Tit em Descont									?
//?mv_par19		 // Relatorio Anal/Sint									?
//?mv_par20		 // Consid Data Base?  									?
//?mv_par21		 // Consid Filiais  ?  									?
//?mv_par22		 // da filial											?
//?mv_par23		 // a flial 											?
//?mv_par24		 // Da loja  											?
//?mv_par25		 // Ate a loja											?
//?mv_par26		 // Consid Adiantam.?									?
//?mv_par27		 // Da data contab. ?									?
//?mv_par28		 // Ate data contab.?									?
//?mv_par29		 // Imprime Nome    ?									?
//?mv_par30		 // Outras Moedas   ?									?
//?mv_par31       // Imprimir os Tipos										?
//?mv_par32       // Nao Imprimir Tipos									?
//?mv_par33       // Abatimentos  - Lista/Nao Lista/Despreza				?
//?mv_par34       // Consid. Fluxo Caixa									?
//?mv_par35       // Salta pagina Cliente									?
//?mv_par36       // Data Base												?
//?mv_par37       // Compoe Saldo por: Data da Baixa, Credito ou DtDigit	?
//?mv_par38       // Tit. Emissao Futura								  	?
//?mv_par41       // Compensacao entre filiais?						  	?
//?mv_par42       // Seleciona filiais (GESTAO)	


cPictTit := PesqPict("SE1","E1_VALOR")
nTamDte	 := TamSx3("E1_EMISSAO")[1]

If(cPaisLoc != "BRA")

	nTamCli := TamSX3("E1_CLIENTE")[1] + TamSX3("E1_LOJA")[1]+ 8
	nTamTit	 := TamSX3("E1_PREFIXO")[1] + TamSX3("E1_NUM")[1] + TamSX3("E1_PARCELA")[1] + 37
	nTamVal	 := TamSx3("E1_VALOR")[1] + 9

Else

	nTamCli	 := TamSX3("E1_CLIENTE")[1] + TamSX3("E1_LOJA")[1] + 22
	nTamVal	 := TamSx3("E1_VALOR")[1]
	nTamTit	 := TamSX3("E1_PREFIXO")[1] + TamSX3("E1_NUM")[1] + TamSX3("E1_PARCELA")[1] + 29 
	
	
EndIf

nTamBan	 := TamSX3("E1_PORTADO")[1] + TamSX3("E1_SITUACA")[1] + 1
nTamQueb := nTamCli + nTamTit + nTamBan + TamSX3("E1_TIPO")[1] + TamSX3("E1_NATUREZ")[1] + TamSX3("E1_EMISSAO")[1] +;
		  	TamSX3("E1_VENCTO")[1] + TamSX3("E1_VENCREA")[1] + nTamBan + 2
nTamJur  := TamSX3("E1_JUROS")[1]

nTamNBco := TamSX3("E1_NUMBCO")[1]+20

//Secao 1 --> Analitico
oSection1 := TRSection():New(oReport,STR0079,{"SE1","SA1"},;
				{STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0047})
//Secao 2 --> Sintetico
oSection2 := TRSection():New(oReport,STR0081)
TRCell():New(oSection1,"CLIENTE",,STR0056,,nTamCli,.F.,,,,,,,.F.)  //"Codigo-Lj-Nome do Cliente"
TRCell():New(oSection1,"TITULO",,STR0057+CRLF+STR0058,,nTamTit,.F.,,,,,,,.T.)  //"Prf-Numero" + "Parcela"
TRCell():New(oSection1,"E1_TIPO","SE1",STR0059,,,.F.,,,,,,,.F.)  //"TP"
TRCell():New(oSection1,"E1_NATUREZ","SE1",STR0060,,+12,.F.,,,,,,,.F.)  //"Natureza"
TRCell():New(oSection1,"E1_EMISSAO","SE1",STR0061+CRLF+STR0062,,nTamDte,.F.,,,,,,,.F.)  //"Data de" + "Emissao"
If(cPaisLoc == "BRA")

	TRCell():New(oSection1,"E1_VENCTO"	,"SE1",STR0063+CRLF+STR0064,,nTamDte,.F.,,,,,,,.F.)  //"Vencto" + "Titulo"

EndIf
TRCell():New(oSection1,"E1_VENCREA","SE1",STR0063+CRLF+STR0065,,nTamDte,.F.,,,,,,,.F.)  //"Vencto" + "Real"
TRCell():New(oSection1,"BANCO",,STR0083,,nTamBan,.F.,,,,,,,.F.)  //"Bco St"
TRCell():New(oSection1,"VAL_ORIG",,STR0067,cPictTit,nTamVal+22,.F.,,,,,,,.T.)  //"Valor Original"
TRCell():New(oSection1,"VAL_NOMI",,STR0068+CRLF+STR0069,cPictTit,nTamVal+16,.F.,,,,,,,.T.)  //"Tit Vencidos" + "Valor Nominal"
TRCell():New(oSection1,"VAL_CORR",,STR0068+CRLF+STR0070,cPictTit,nTamVal+16,.F.,,,,,,,.T.)  //"Tit Vencidos" + "Valor Corrigido"
TRCell():New(oSection1,"VAL_VENC",,STR0071+CRLF+STR0069,cPictTit,nTamVal+22,.F.,,,,,,,.T.)  //"Titulos a Vencer" + "Valor Nominal"
TRCell():New(oSection1,"E1_NUMBCO","SE1",STR0072+CRLF+STR0066,,nTamNBco,.F.,,,,,,,.T.)  //"Num" + "Banco"
TRCell():New(oSection1,"JUROS",,STR0073+CRLF+STR0074,cPictTit,nTamJur+6,.F.,,,,,,,.T.)  //"Vlr.juros ou" + "permanencia"
TRCell():New(oSection1,"DIA_ATR",,STR0075+CRLF+STR0076,,10,.F.,,,,,,,.T.)  //"Dias" + "Atraso"
TRCell():New(oSection1,"E1_HIST" ,"SE1",STR0077,,20,.F.,,,,,,,.T.)  //"Historico" 19
TRCell():New(oSection1,"VAL_SOMA",,STR0078,cPictTit,38,.F.,,,,,,,.T.)  //"(Vencidos+Vencer)"

TRCell():New(oSection2,"QUEBRA",,STR0008,,nTamQueb-nTamVal,.F.,,,,,,,.T.)
TRCell():New(oSection2,"TOT_NOMI",,STR0068+CRLF+STR0069,cPictTit,nTamVal,.F.,,,,,,,.T.)
TRCell():New(oSection2,"TOT_CORR",,STR0068+CRLF+STR0070,cPictTit,nTamVal,.F.,,,,,,,.T.)
TRCell():New(oSection2,"TOT_VENC",,STR0071+CRLF+STR0069,cPictTit,nTamVal,.F.,,,,,,,.T.)
TRCell():New(oSection2,"TOT_JUROS",,STR0073+CRLF+STR0074,cPictTit,nTamVal,.F.,,,,,,,.T.)
TRCell():New(oSection2,"TOT_SOMA",,STR0078,cPictTit,nTamVal,.F.,,,,,,,.T.)

oSection1:Cell("BANCO")   :SetHeaderAlign("CENTER")
oSection1:Cell("VAL_ORIG"):SetHeaderAlign("CENTER")
oSection1:Cell("VAL_NOMI"):SetHeaderAlign("CENTER")
oSection1:Cell("VAL_CORR"):SetHeaderAlign("CENTER")
oSection1:Cell("VAL_VENC"):SetHeaderAlign("CENTER")
oSection1:Cell("E1_NUMBCO"):SetHeaderAlign("CENTER")
oSection1:Cell("JUROS")   :SetHeaderAlign("CENTER")
oSection1:Cell("DIA_ATR") :SetHeaderAlign("LEFT")
oSection1:Cell("E1_HIST") :SetHeaderAlign("CENTER")
oSection1:Cell("VAL_SOMA"):SetHeaderAlign("LEFT")

Return oReport


Static Function ReportPrint(oReport)
Local cDataBase

		
Local oSection1  	:= oReport:Section(1)
Local oSection2  	:= oReport:Section(2)
Local nOrdem 		:= oSection1:GetOrder()
Local oBreak
Local oBreak2
Local oTotVenc
Local oTotCorr

Local aDados[24]
Local nRegEmp 		:= SM0->(RecNo())
Local nRegSM0 		:= SM0->(Recno())
Local nAtuSM0 		:= SM0->(Recno())
Local dOldDtBase 	:= dDataBase
Local dOldData		:= dDatabase

Local CbCont
Local cCond1		:= ""
Local cCond2
Local nTit0			:= 0
Local nTit1			:= 0
Local nTit2			:= 0
Local nTit3			:= 0
Local nTit4			:= 0
Local nTit5			:= 0
Local nTotJ			:= 0
Local nTot0			:= 0
Local nTot1			:= 0
Local nTot2			:= 0
Local nTot3			:= 0
Local nTot4			:= 0
Local nTotTit		:= 0
Local nTotJur		:= 0
Local nTotFil0		:= 0
Local nTotFil1		:= 0
Local nTotFil2		:= 0
Local nTotFil3		:= 0
Local nTotFil4		:= 0
Local nTotFilTit	:= 0
Local nTotFilJ		:= 0
Local nAtraso		:= 0
Local nTotAbat		:= 0
Local nSaldo		:= 0
Local dDataReaj
Local dDataAnt 		:= dDataBase
Local lQuebra
Local nMesTit0 		:= 0
Local nMesTit1 		:= 0
Local nMesTit2		:= 0
Local nMesTit3 		:= 0
Local nMesTit4 		:= 0
Local nMesTTit 		:= 0
Local nMesTitj	 	:= 0
Local cIndexSe1
Local cChaveSe1
Local nIndexSE1
Local dDtCtb		:= CTOD("//")
Local cTipos  		:= ""
Local nTotVenc		:= 0
Local nTotMes		:= 0
Local nTotGeral 	:= 0
Local nTotTitMes	:= 0
Local nTotFil		:= 0
Local cNomFor		:= ""
Local cNumBco		:= ""
Local cNomNat		:= ""
Local cNomFil		:= ""
Local cCarAnt 		:= ""
Local cCarAnt2		:= ""
Local cFilAntSE1	:= ""
Local cCampo		:= ""
Local lClcMultLj	:= ( SuperGetMv("MV_JURTIPO",,"") == "L" ) .Or. ( SuperGetMv("MV_LJINTFS", ,.F.) )
Local nMulta		:= 0
// *************************************************
// Utilizada para guardar os abatimentos baixados *
// que devem subtrair o saldo do titulo principal.*
// *************************************************
Local nBx			:= 0
Local aAbatBaixa	:= {}
Local aStru			:= SE1->(dbStruct())
Local aTamCli  		:= TAMSX3("E1_CLIENTE")
Local lF130Qry 		:= ExistBlock("F130QRY")
// variavel  abaixo criada p/pegar o nr de casas decimais da moeda
Local ndecs			:= 0
Local nDescont		:= 0
Local nVlrOrig		:= 0
Local cFilDe		:= ""
Local cFilAte		:= ""
Local cMoeda		:= ""
Local dUltBaixa		:= STOD("")
Local dVencRea		:= STOD("")
Local cFltUsrSA1	:= ""
Local cFilUserSA1 := oSection1:GetADVPLExp("SA1")
Local nGem 			:= 0
Local aFiliais 		:= {}
Local lTotFil		:= (mv_par21 == 1 .And. SM0->(Reccount()) > 1)	// Totaliza e quebra por filial
Local aAreaSE5
Local lFR130Tel   	:= ExistBlock("FR130TELC")
Local cCampoCli   	:= ""
Local nLenFil		:= 0
Local nX			:= 0
Local nValPCC	  	:= 0
Local cFilQry		:= ""
Local cFilSE1		:= ""
Local cFilSE5		:= ""
Local lHasLot		:= HasTemplate("LOT")
Local lTemGEM		:= ExistTemplate("GEMDESCTO") .And. HasTemplate("LOT")
Local lAS400		:= (Upper(TcSrvType()) != "AS/400" .And. Upper(TcSrvType()) != "ISERIES")
Local cMvDesFin		:= SuperGetMV("MV_DESCFIN",,"I")
Local lFJurCst		:= Existblock("FJURCST")	// Ponto de entrada para calculo de juros
Local cCorpBak		:= ""
Local cRepTit		:= oReport:Title()
Local lRelCabec		:= .F.
Local cFilNat 		:= SE1->E1_NATUREZ
Local lAbatIMPBx  	:= .F.
Local aRecSE1Cmp	:= {}
//GESTAO - inicio
Local nFilAtu		:= 0
Local nLenSelFil	:= 0
Local nTamUnNeg		:= 0
Local nTamEmp		:= 0
Local nTotEmp		:= 0
Local nTotEmpJ		:= 0
Local nTotEmp0		:= 0
Local nTotEmp1		:= 0
Local nTotEmp2		:= 0
Local nTotEmp3		:= 0
Local nTotEmp4		:= 0
Local nTotTitEmp	:= 0
Local cNomEmp		:= ""
Local cTmpFil		:= ""
Local cQryFilSE1	:= ""
Local cQryFilSE5	:= ""
Local lContinua		:= .F.
Local lTotEmp		:= .F.
Local aTmpFil		:= {}
Local aSM0			:= {}
Local oBrkFil		:= Nil
Local oBrkEmp		:= Nil
Local oBrkNat		:= Nil
Local nRecnoSE1		:= 0
Local aAux			:= {}
Local nI			:= 0
Local lEmpLog		:= .F.
Local cSeq			:= ""
Local nRecSA1		:= 0
Local nTotReg		:= 0
Local nVa			:= 0
//GESTAO - fim
Local cCampos		:= ""
Local lMSSQL		:= "MSSQL"$Upper(TCGetDB())
Local lMySQL		:= "MYSQL"$Upper(TCGetDB())
Local lOracle		:= "ORACLE"$Upper(TCGetDB())
Local cQuery		:= ""
Local cQueryP		:= ""
Local cQuery1		:= ""
Local cQuery2		:= ""
Local cQuery3		:= ""
Local cQry			:= ""
Local cQryAux		:= ""
Local cQryImp		:= ""
Local cSelect		:= ""
Local cOper			:= IIf((Alltrim(Upper(TcGetDb()))) $ 'ORACLE.POSTGRES.DB2.INFORMIX' ,'||','+')
Local lBanco		:= Upper(TcGetDb())$'ORACLE.POSTGRES.DB2.INFORMIX'
Local lNvl			:= Upper(TcGetDb())$'INFORMIX'
Local lExistAba		:= .F. // 
Local lVl_Corr		:= .T.
Local cListDesc		:= FN022LSTCB(2)	//Obtem a lista de situacos de cobrancas Descontadas
Local cTipoIn		:= ""
Local lMvJurTin		:= SuperGetMv("MV_JURTIN",,.F.)
Local lFValAcess	:= ExistFunc('FValAcess')
Local xCnt01		:= CTOD("  /  /  ")
Local lDvc			:= oReport:nDevice == 4
Local cMvMoeda		:= SuperGetMv("MV_MOEDA",,"")
Local cCodEmp

Private cTitulo		:= ""
Private dBaixa		:= dDataBase
Private nAbatim		:= 0 
Private nJuros		:= 0
Private lImpSintTbl	:= oReport:lXlsTable .And. mv_par19 == 1
Private nTotal		:= 0
Private cMVBR10925 	:= SuperGetMv("MV_BR10925", ,"2")
Private cFilterUser	:= ""
Default __lTempLOT	:= HasTemplate("LOT")

IF EXISTBLOCK("F130FILT")
	cTipos	:=	EXECBLOCK("F130FILT",.f.,.f.)
ENDIF

If mv_par15 = 0
	mv_par15 := 1
EndIf

nDecs  := Msdecimais(mv_par15)
cMoeda := Alltrim(Str(mv_par15,2))

//GESTAO - inicio
If MV_PAR42 == 1
	If Empty(aSelFil)
		AdmSelecFil("FIN130",42,.F.,@aSelFil,"SE1",.F.)
	Endif
Else
	Aadd(aSelFil,cFilAnt)
Endif

If !Empty(aSelFil) .and. mv_par42 = 1
	If len(aSelFil) > 1			
		nI := 1							
		If ascan(aSelFil, cFilAnt) != 0 .and. aSelFil[nI] !=  cFilAnt	
			aSelFil[ascan(aSelFil, cFilAnt)] := aSelFil[nI]
			aSelFil[nI] := cFilAnt	
		EndIf				
	EndIf	
EndIf

nLenSelFil := Len(aSelFil)
lTotFil := (nLenSelFil > 1)
nTamEmp := Len(FWSM0LayOut(,1))
nTamUnNeg := Len(FWSM0LayOut(,2))
lTotEmp := .F.


If nLenSelFil > 1
	nX := 1
	While nX < nLenSelFil .And. !lTotEmp
		nX++
		lTotEmp := !(Substr(aSelFil[nX-1],1,nTamEmp) == Substr(aSelFil[nX],1,nTamEmp))
	Enddo
Else
	nTotTmp := .F.
Endif
cQryFilSE1 := GetRngFil( aSelFil, "SE1", .T., @cTmpFil)
Aadd(aTmpFil,cTmpFil)
cQryFilSE5 := GetRngFil( aSelFil, "SE5", .T., @cTmpFil)
Aadd(aTmpFil,cTmpFil)
//GESTAO - fim

oSection1:Cell("CLIENTE"   ):SetBlock( { || aDados[CLIENT]    			})
oSection1:Cell("TITULO"    ):SetBlock( { || aDados[TITUL]     			})
oSection1:Cell("E1_TIPO"   ):SetBlock( { || aDados[TIPO]      			})
oSection1:Cell("E1_NATUREZ"):SetBlock( { || MascNat(aDados[NATUREZA]) 	})
oSection1:Cell("E1_EMISSAO"):SetBlock( { || aDados[EMISSAO]   			})
If(cPaisLoc == "BRA")

	oSection1:Cell("E1_VENCTO" ):SetBlock( { || aDados[VENCTO]    		})

EndIf
oSection1:Cell("E1_VENCREA"):SetBlock( { || aDados[VENCREA]   			})
oSection1:Cell("BANCO"     ):SetBlock( { || aDados[BANC]      			})
oSection1:Cell("VAL_ORIG"  ):SetBlock( { || aDados[VL_ORIG]				})
oSection1:Cell("VAL_NOMI"  ):SetBlock( { || aDados[VL_NOMINAL]			})
oSection1:Cell("VAL_CORR"  ):SetBlock( { || aDados[VL_CORRIG]			})
oSection1:Cell("VAL_VENC"  ):SetBlock( { || aDados[VL_VENCIDO]			})
oSection1:Cell("E1_NUMBCO" ):SetBlock( { || aDados[NUMBC]     			})
oSection1:Cell("JUROS"     ):SetBlock( { || aDados[VL_JUROS]  			})
oSection1:Cell("DIA_ATR"   ):SetBlock( { || aDados[ATRASO]    			})
oSection1:Cell("E1_HIST"   ):SetBlock( { || aDados[HISTORICO] 			})
oSection1:Cell("VAL_SOMA"  ):SetBlock( { || aDados[VL_SOMA]   			})

oSection1:Cell("VAL_SOMA"):Enable()

//Cabecalho do Relatorio sintetico
If mv_par19 == 2 //1 = Analitico - 2 = Sintetico
	oSection2:SetHeaderPage()
Endif


/* Exclusao de titulos ja executados na data base e naquela empresa */
   

   
//Relatorio Analitico
TRPosition():New(oSection1,"SA1",1,{|| xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA})

//Define as quebras da sessao, conforme a ordem escolhida
If nOrdem == 5 //natureza
	oBreak := TRBreak():New(oSection1, {|| Iif(!MV_MULNATR,SE1->E1_FILIAL + SE1->E1_NATUREZ,aDados[NATUREZA])} , {|| STR0037 + " " + cNomNat })
	oBrkNat := oBreak
	If MV_MULNATR
		oBreak:OnBreak( { |x,y| cNomNat := FR130RetNat(x), FR130TotSoma( oTotCorr, oTotVenc, @nTotVenc, @nTotGeral, nOrdem ) } )
	EndIf
Elseif nOrdem == 4 .Or. nOrdem == 6 //Data do vencimento e emissao
 	oBreak  := TRBreak():New(oSection1, {|| SE1->E1_FILIAL + Iif(nOrdem == 4, Iif(mv_par40 = 2, Dtos(SE1->E1_VENCTO), Dtos(SE1->E1_VENCREA)), Dtos(SE1->E1_EMISSAO))} , {|| STR0037 + DtoC(dDtVenc) }) //"S U B - T O T A L ---->"
 	oBreak2 := TRBreak():New(oSection1, {|| SE1->E1_FILIAL + Iif(nOrdem == 4, SubStr(Iif(mv_par40 = 2, Dtos(SE1->E1_VENCTO), Dtos(SE1->E1_VENCREA)),1,6), Substr(Dtos(SE1->E1_EMISSAO),1,6))} , {|| STR0041 + "("+AllTrim(Str(nTotTitMes))+" "+Iif(nTotTitMes > 1, OemToAnsi(STR0039), OemToAnsi(STR0040))+")"} ) //"T O T A L  D O  M E S --->"
    If mv_par19 == 1 //1 = Analitico   2 = Sintetico
    	TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBreak2,,,,.F.,.F.)
    	TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBreak2,,,,.F.,.F.)
    	TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBreak2,,,,.F.,.F.)
    	TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBreak2,,,,.F.,.F.)
    	TRFunction():New(oSection1:Cell("JUROS"),"","SUM",oBreak2,,,,.F.,.F.)
    	TRFunction():New(oSection1:Cell("VAL_SOMA"),"","ONPRINT",oBreak2,,PesqPict("SE1","E1_VALOR"),{|lSection, lReport| If(lReport, nTotGeral, nTotMes)},.F.,.F.)
    Endif
 Elseif nOrdem == 3 //Banco
	oBreak := TRBreak():New(oSection1, {|| SE1->E1_FILIAL + SE1->E1_PORTADO} , {|| STR0037 + cNumBco}) //"S U B - T O T A L --->"
 Elseif nOrdem == 1 .Or. nOrdem == 8 //Cliente ou Codigo do Cliente
 	oBreak := TRBreak():New(oSection1, {|| SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA)} , {|| STR0037 + cNomFor}) //"S U B - T O T A L --->"
   	oBreak:OnBreak( { |x,y| cNomFor, FR130TotSoma( oTotCorr, oTotVenc, @nTotVenc, @nTotGeral ) } )
 ElseIf nOrdem == 9 // Banco/Situacao
	oBreak := TRBreak():New(oSection1, {|| SE1->E1_FILIAL + SE1->E1_PORTADO+SE1->E1_SITUACA} , {|| STR0037 + cNumBco + " " + SubStr(cCarAnt2,1,2) + " "+SubStr(cCarAnt2,3,20) }) //"S U B - T O T A L --->"
	oBreak:OnBreak( { |x,y| cCarAnt2 := Situcob(x,cFilAntSE1) } )
ElseIf nOrdem == 7 //vencto e banco
	oBreak := TRBreak():New(oSection1, {||SE1->E1_FILIAL + IIf(MV_PAR40=2,DtoC(SE1->E1_VENCTO)+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,DtoC(SE1->E1_VENCREA)+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA)},;
	{||STR0037 + DtoC(dDtVenc) + IIf(!Empty(cNumBco), " - " + STR0066 + " " + cNumBco + " " + ;
	GetAdvfVal("SA6","A6_NOME",xFilial("SA6") + AllTrim(cNumBco),1),"")},.F.,"",.F.)
Endif

If lTotFil .Or. !(mv_par22 == mv_par23)
	oBrkFil := TRBreak():New(oSection1,{|| SE1->E1_FILIAL },{|| STR0043+" "+ cNomFil })	//"T O T A L   F I L I A L ----> "
	// "Salta pagina por cliente?" igual a "Sim" e a ordem eh por cliente ou codigo do cliente
	If mv_par35 == 1 .And. (nOrdem == 1 .Or. nOrdem == 8)
		oBrkFil:OnPrintTotal( { || oReport:EndPage() } )	// Finaliza pagina atual
	Else
		oBrkFil:OnPrintTotal( { || oReport:SkipLine()} )
	EndIf
	If mv_par19 == 1	//1- Analitico  2-Sintetico
		TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBrkFil,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBrkFil,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBrkFil,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBrkFil,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBrkFil,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_SOMA"),"","ONPRINT",oBrkFil,,PesqPict("SE1","E1_VALOR"),{|lSection,lReport| If(lReport, nTotGeral, nTotFil)},.F.,.F.)
	EndIf
EndIf
/*
GESTAO - inicio */
/* quebra por empresa */
If lTotEmp
	oBrkEmp := TRBreak():New(oSection1,{|| Substr(SE1->E1_FILIAL,1,nTamEmp)},{|| STR0082 + " " + cNomEmp })		//"T O T A L  E M P R E S A -->"
	// "Salta pagina por cliente?" igual a "Sim" e a ordem eh por cliente ou codigo do cliente
	If mv_par35 == 1 .And. (nOrdem == 1 .Or. nOrdem == 8)
		oBrkEmp:OnPrintTotal( { || oReport:EndPage() } )	// Finaliza pagina atual
	Else
		oBrkEmp:OnPrintTotal( { || oReport:SkipLine()} )
	EndIf
	If mv_par19 == 1	//1- Analitico  2-Sintetico
		TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_SOMA"),"","ONPRINT",oBrkEmp,,PesqPict("SE1","E1_VALOR"),{|lSection,lReport| If(lReport, nTotGeral, nTotEmp)},.F.,.F.)
	EndIf
Endif
/* GESTAO - fim
*/
If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
	//Altera o texto do Total Geral
	oReport:SetTotalText({|| STR0038 + "(" + AllTrim(Str(nTotTit))+" "+If(nTotTit > 1, STR0039, STR0040)+")"})
	TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBreak,,,,.F.,.T.)
	oTotCorr := TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBreak,,,,.F.,.T.)
	oTotVenc := TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("JUROS"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VAL_SOMA"),"","ONPRINT",oBreak,,PesqPict("SE1","E1_VALOR"),{|lSection, lReport| If (lReport, nTotGeral, nTotVenc)},.F.,.T.)

Endif


If Select("__SE1") == 0
	ChkFile("SE1",.F.,"__SE1")
Else
	DbSelectArea("__SE1")
EndIf


If mv_par21 == 2
	cFilDe  := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	cFilAte := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
ELSE
	cFilDe := mv_par22	// Todas as filiais
	cFilAte:= mv_par23
Endif


//Acerta a database de acordo com o parametro
If mv_par20 == 1    // Considera Data Base
	dBaixa := dDataBase := mv_par36
Else
	If dDataBase < MV_PAR36
		dBaixa := dDataBase := mv_par36
	EndIf
Endif

cDataBase := DTOS(dDataBase)

//cSql := "DELETE FROM __BI_PB_CRE  WHERE DATA_BASE = '"+cDataBase+"' and TIPO = 'CRE'"
//TcSqlExec(cSql)

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())

//oReport:NoUserFilter()  

oSection1:Init()
oSection2:Init()
ExcTitMes(dDataBase)
insertDados(aDados, dDataBase)

U_wfSend02() // Thiago Haagensen - Ticket 26109 - Notificação por e-mail

/*
GESTAO - inicio */
If nLenSelFil == 0
	// Cria vetor com os codigos das filiais da empresa corrente
	aFiliais := FinRetFil()
	lContinua := SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
Else
	aFiliais := Aclone(aSelFil)
	cFilDe := aSelFil[1]
	cFilAte := aSelFil[nLenSelFil]
	nFilAtu := 1
	lContinua := nFilAtu <= nLenSelFil
	aSM0 := FWLoadSM0()
Endif
/* GESTAO - fim
*/
While lContinua

	If lAbortPrint
		EXIT
	Endif

	If !lRelCabec
   		If mv_par19 == 1  //1 = Analitico - 2 = Sintetico
			cTitulo := oReport:Title() + STR0080 + " " + cMvMoeda + cMoeda  //"Posicao dos Titulos a Receber"+" - Analitico"
		Else
			cTitulo := oReport:Title() + STR0080 + " " + cMvMoeda + cMoeda  //"Posicao dos Titulos a Receber"+" - Sintetico"
		EndIf
	EndIf

	If !lRelCabec
		If mv_par19 == 1   //1 = Analitico - 2 = Sintetico
			cTitulo += STR0026 //" - Analitico"
		Else
			cTitulo += STR0027 //" - Sintetico"
		EndIf
	EndIf

	dbSelectArea("SE1")
	/*
	GESTAO - inicio */
	If nLenSelFil > 0
		aAux := getArea()
		nPosFil := Ascan(aSM0,{|sm0| sm0[SM0_CODFIL] == aSelFil[nFilAtu]})
		SM0->(DbGoTo(aSM0[nPosFil,SM0_RECNO]))
	Endif
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	
	If nLenSelFil > 0 .and. len(aAux) > 0
		dbSelectArea("SM0")
		dbSeek(cEmpAnt+cFilAnt,.T.)
		RestArea(aAux)
	EndIf	
	/* GESTAO - fim
	*/


	If cCorpBak<>xFilial("SE1")
		cCorpBak	:= xFilial("SE1")
	Else
		/*
		GESTAO - inicio */
		If nLenSelFil == 0
			dbSelectArea("SM0")
			SM0->(DbSkip())
			lContinua := SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
		Else
			nFilAtu++
			lContinua := (nFilAtu <= nLenSelFil)
		Endif
		/* GESTAO - fim
		*/
		Loop
	EndIf

	Set Softseek On
	cFilSE5		:= xFilial("SE5")
	cFilSE1		:= xFilial("SE1")
	lVerCmpFil	:= !Empty(cFilSE1) .And. !Empty(cFilSE5) .And. Len(aFiliais) > 1
	
	// Verifica se deve montar filtro de filiais para compensacao em filiais diferentes
	If mv_par20 == 1 .And. lVerCmpFil
		nLenFil	:= Len( aFiliais )
		cFilQry	:= ""
		For nX := 1 To nLenFil
			If aFiliais[nX] != cFilSE5
				If !Empty( cFilQry )
					cFilQry += ", "
				Endif
				cFilQry += "'" + aFiliais[nX] + "'"
			EndIf
		Next nX
	EndIf
	
	If ( mv_par41 == 1 ) .and. lVerCmpFil

			cQuery := "SELECT "
			cQuery += " SE1.R_E_C_N_O_ RecnoSE1, SE5.R_E_C_N_O_ RecnoSE5"
			cQuery += " FROM " + RetSQLName( "SE5" ) + " SE5 ," + RetSQLName( "SE1" ) + " SE1  "
			/*
			GESTAO - inicio */
			If nLenSelFil == 0 .AND. !Empty(cFilQry)
				cQuery += " WHERE SE5.E5_FILIAL IN ("+cFilQry+") "
			Else
				cQuery += " WHERE SE5.E5_FILIAL " + cQryFilSE5
			Endif
			/* GESTAO - fim
			*/
			cQuery += " AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "
			cQuery += " AND SE5.E5_NUMERO = SE1.E1_NUM "
			cQuery += " AND SE5.E5_PARCELA = SE1.E1_PARCELA "
			cQuery += " AND SE5.E5_TIPO = SE1.E1_TIPO "
			cQuery += " AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "
			cQuery += " AND SE5.E5_LOJA = SE1.E1_LOJA "
			cQuery += " AND SE5.E5_MOTBX IN ('CMP','CEC')"
			cQuery += " AND SE5.D_E_L_E_T_ = ''"
			cQuery += " AND SE1.R_E_C_N_O_ IN ( "
			cQuery += " 		SELECT SE1.R_E_C_N_O_"
			cQuery += " 			FROM " + RetSQLName( "SE1" ) + " SE1  "
			cQuery += " 			WHERE SE1.E1_FILIAL = '"+xFilial('SE1')+"' AND"
			cQuery += " 			SE1.D_E_L_E_T_ = ' ' "
			cQuery += " 			AND E1_CLIENTE between '" + mv_par01 + "' AND '" + mv_par02 + "'"
			cQuery += " 			AND E1_LOJA    between '" + mv_par24 + "' AND '" + mv_par25 + "'"
			cQuery += " 			AND E1_PREFIXO between '" + mv_par03 + "' AND '" + mv_par04 + "'"
			cQuery += " 			AND E1_NUM     between '" + mv_par05 + "' AND '" + mv_par06 + "'"
			cQuery += " 			AND E1_PORTADO between '" + mv_par07 + "' AND '" + mv_par08 + "'"
			If mv_par40 == 2
				cQuery += " 		AND E1_VENCTO between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
			Else
				cQuery += " 		AND E1_VENCREA between	 '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
			Endif
			cQuery += " 			AND E1_NATUREZ BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"'"
			cQuery += " 			AND E1_EMISSAO between '" + DTOS(mv_par13)  + "' "
			If ( MV_PAR38 == 2 ) .and. mv_par14 >= mv_par36
				cQuery += " 		AND '" + DtoS(mv_par36) + "'"
			Else
				cQuery += " 		AND '" + DTOS(mv_par14) + "'"
			Endif

			cQuery += " 			AND E1_LOJA    between '" + mv_par24        + "' AND '" + mv_par25 + "'"

			cQuery += " 			AND E1_EMIS1  Between '"+ DTOS(mv_par27)+"' AND '"+DTOS(mv_par28)+"'"
			If !Empty(mv_par31) // Deseja imprimir apenas os tipos do parametro 31
				cQuery += " 		AND E1_TIPO IN "+FormatIn(mv_par31,";")
			ElseIf !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
				cQuery += " 		AND E1_TIPO NOT IN "+FormatIn(mv_par32,";")
			EndIf
			If mv_par18 == 2
				cQuery += " 		AND E1_SITUACA NOT IN " + FormatIn(cListDesc,"|")			//sitcob
			Endif
			If mv_par20 == 2
				cQuery += ' 		AND E1_SALDO <> 0'
			Endif
			If mv_par34 == 1
				cQuery += " 		AND E1_FLUXO <> 'N'"
			Endif
			
			/* GESTAO - inicio */
			If FWModeAccess("SE1",3) == "E"
				cQuery += " AND E1_FILIAL " + cQryFilSE1
			Else
				If MV_PAR42 == 1
					cQuery += " AND E1_FILORIG " + FR130InFilial()
				Else
					cQuery += " AND E1_FILIAL = '" + xFilial("SE1") + "'"
				EndIf
			Endif
			/* GESTAO - fim
			*/

			
			If mv_par30 == 2 // nao imprime
				cQuery += " 		AND E1_MOEDA = "+cMoeda
			Endif
			cQuery += " ) "
			cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
			ProcLogIni( {},"FINR130" )
			ProcLogAtu("INICIO")
	        ProcLogAtu("INICIO",STR0084) // QUERY DE PESQUISA INICIAL DE COMPENSACOES
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCOMP",.T.,.T.)
	        ProcLogAtu("FIM",STR0084) // FIM DA QUERY DE PESQUISA INICIAL DE COMPENSACOES
			While TRBCOMP->(!EOF())
				aadd( aRecSE1Cmp , { TRBCOMP->(RecnoSE1)} )
				TRBCOMP->(dbSkip())
			EndDo
			TRBCOMP->(dbCloseArea())
	Endif
	dbSelectArea( "SE1" )
	
	cFilterUser := oSection1:GetSqlExp("SE1")
	cFltUsrSA1 := SA1->(oSection1:GetSqlExp("SA1"))
	cQueryP := ""
	cCampos := ""
	cQuery  := ""
	If nOrdem = 1
		aEval(SE1->(DbStruct()),{|e| If(!Alltrim(e[1])$"E1_FILIAL#E1_NOMCLI#E1_CLIENTE#E1_LOJA#E1_PREFIXO#E1_NUM#E1_PARCELA#E1_TIPO" .and. e[2]<> "M", cCampos += ","+AllTrim(e[1]),Nil)})
		cSelect:= "SELECT E1_FILIAL, E1_NOMCLI, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM,E1_PARCELA, E1_TIPO, R_E_C_N_O_ , " + SubStr(cCampos,2)
	Else
		aEval(SE1->(DbStruct()),{|e| If( !Alltrim(e[1])$"E1_FILIAL" .And. e[2]<> "M", cCampos += ","+AllTrim(e[1]),Nil)})
		cSelect:= "SELECT E1_FILIAL, " + SubStr(cCampos,2) + ", R_E_C_N_O_ " 
	EndIf
	
	cQuery += "  FROM "+	RetSqlName("SE1") + " SE1 , " + RetSqlName("SA1") + " SA1 "
	cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND A1_FILIAL = '" + xFilial("SA1") + "' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA "
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' "
	
	If !empty(cFilterUser)
    	cQueryP += " AND ("+ cFilterUser +")"
	EndIf
	If !empty(cFltUsrSA1)
		cQueryP += " AND ("+ cFltUsrSA1 +")"
	EndIf

	IF nOrdem = 1 .and. !lRelCabec
		cChaveSe1 := "E1_FILIAL, E1_NOMCLI, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO"
		cOrder := SqlOrder(cChaveSe1)
		cCond1	:= "SE1->E1_CLIENTE <= mv_par02"
		cCond2	:= "SE1->E1_CLIENTE + SE1->E1_LOJA"
		cTitulo	+= STR0017  //" - Por Cliente"
		lRelCabec := .T.
	Elseif nOrdem = 2 .and. !lRelCabec
		SE1->(dbSetOrder(1))
		cOrder := SqlOrder(IndexKey())		
		cCond1	:= "SE1->E1_NUM <= mv_par06"
		cCond2	:= "SE1->E1_NUM"
		cTitulo	+= STR0018  //" - Por Numero"
		lRelCabec := .T.
	Elseif nOrdem = 3 .and. !lRelCabec
		SE1->(dbSetOrder(4))
		cOrder := SqlOrder(IndexKey())
		cCond1	:= "SE1->E1_PORTADO <= mv_par08"
		cCond2	:= "SE1->E1_PORTADO"
		cTitulo	+= STR0019  //" - Por Banco"
		lRelCabec := .T.
	Elseif nOrdem = 4  .and. !lRelCabec
		SE1->(dbSetOrder(7))
		cOrder := SqlOrder(IndexKey())
		cCond1	:= Iif(mv_par40 = 2, "SE1->E1_VENCTO", "SE1->E1_VENCREA")+" <= mv_par10"
		cCond2	:= Iif(mv_par40 = 2, "SE1->E1_VENCTO", "SE1->E1_VENCREA")
		cTitulo	+= STR0020  //" - Por Data de Vencimento"
		lRelCabec := .T.
	Elseif nOrdem = 5 .and. !lRelCabec
		SE1->(dbSetOrder(3))
		cOrder := SqlOrder(IndexKey())
		cCond1	:= "SE1->E1_NATUREZ <= mv_par12"
		cCond2	:= "SE1->E1_NATUREZ"
		cTitulo	+= STR0021  //" - Por Natureza"
		lRelCabec := .T.
	Elseif nOrdem = 6 .and. !lRelCabec
		SE1->(dbSetOrder(6))
		cOrder := SqlOrder(IndexKey())
		cCond1	:= "SE1->E1_EMISSAO <= mv_par14"
		cCond2	:= "SE1->E1_EMISSAO"
		cTitulo	+= STR0042  //" - Por Emissao"
		lRelCabec := .T.
	Elseif nOrdem == 7 .and. !lRelCabec
		cChaveSe1 := "E1_FILIAL+DTOS("+Iif(mv_par40 = 2, "E1_VENCTO", "E1_VENCREA")+")+E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		cOrder := SqlOrder(cChaveSe1)
		cCond1	:= Iif(mv_par40 = 2, "SE1->E1_VENCTO", "SE1->E1_VENCREA")+" <= mv_par10"
		cCond2	:= "DtoS("+Iif(mv_par40 = 2, "SE1->E1_VENCTO", "SE1->E1_VENCREA")+")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA"
		cTitulo	+= STR0023  //" - Por Vencto/Banco"
		lRelCabec := .T.
	Elseif nOrdem = 8 .and. !lRelCabec
		SE1->(dbSetOrder(2))
		cOrder := SqlOrder(IndexKey())
		cCond1	:= "SE1->E1_CLIENTE <= mv_par02"
		cCond2	:= "SE1->E1_CLIENTE"
		cTitulo	+= STR0024  //" - Por Cod.Cliente"
		lRelCabec := .T.
	Elseif nOrdem = 9  .and. !lRelCabec
		cChave := "E1_FILIAL+E1_PORTADO+E1_SITUACA+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		cOrder := SqlOrder(cChave)
		cCond1	:= "SE1->E1_PORTADO <= mv_par08"
		cCond2	:= "SE1->E1_PORTADO+SE1->E1_SITUACA"
		cTitulo	+= STR0025 //" - Por Banco e Situacao"
		lRelCabec := .T.
	ElseIf nOrdem == 10 .and. !lRelCabec
		cChave := "E1_FILIAL+E1_NUM+E1_TIPO+E1_PREFIXO+E1_PARCELA"
		cOrder := SqlOrder(cChave)
		cCond1	:= "SE1->E1_NUM <= mv_par06"
		cCond2	:= "SE1->E1_NUM"
		cTitulo	+= STR0048 //" - Numero/Prefixo"
		lRelCabec := .T.
	Endif

	oReport:SetTitle(cTitulo)

	Set Softseek Off

		cQryImp := " AND SE1.E1_CLIENTE between '" + mv_par01        + "' AND '" + mv_par02 + "'"
		cQryImp += " AND SE1.E1_LOJA    between '" + mv_par24        + "' AND '" + mv_par25 + "'"
		cQryImp += " AND SE1.E1_PREFIXO between '" + mv_par03        + "' AND '" + mv_par04 + "'"
		cQryImp += " AND SE1.E1_NUM     between '" + mv_par05        + "' AND '" + mv_par06 + "'"
		cQryImp += " AND SE1.E1_PORTADO between '" + mv_par07        + "' AND '" + mv_par08 + "'"
		
		If mv_par40 == 2
			cQryImp += " AND SE1.E1_VENCTO between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
		Else
			cQryImp += " AND SE1.E1_VENCREA between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
		Endif
		
		cQryImp += " AND SE1.E1_NATUREZ BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"'"
		cQryImp += " AND SE1.E1_EMISSAO between '" + DTOS(mv_par13)  + "' "
		
		If ( MV_PAR38 == 2 ) .and. mv_par14 >= mv_par36
			cQryImp += " AND '" + DtoS(mv_par36) + "'"
		Else
			cQryImp += " AND '" + DTOS(mv_par14) + "'"
		Endif

		cQryImp += " AND SE1.E1_LOJA    between '" + mv_par24        + "' AND '" + mv_par25 + "'"

		cQryImp += " AND SE1.E1_EMIS1  Between '"+ DTOS(mv_par27)+"' AND '"+DTOS(mv_par28)+"'"
		
		If !Empty(mv_par31) // Deseja imprimir apenas os tipos do parametro 31
			cQryImp += " AND SE1.E1_TIPO IN "+FormatIn(mv_par31,";") 
		ElseIf !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
			cQryImp += " AND SE1.E1_TIPO NOT IN "+FormatIn(mv_par32,";")
		EndIf
		
		If mv_par18 == 2
			cQryImp += " AND SE1.E1_SITUACA NOT IN " + FormatIn(cListDesc,"|")			//sitcob
		Endif
		
		If mv_par20 == 2
			cQryImp += ' AND SE1.E1_SALDO <> 0'
		Endif
		cQueryP	+= cQryImp
		
		If mv_par34 == 1
			cQueryP += " AND ( SE1.E1_FLUXO <> 'N' "
			cQueryP += " AND E1_TITPAI NOT IN ("
			cQueryP += " SELECT SE11.E1_PREFIXO || SE11.E1_NUM || SE11.E1_PARCELA || SE11.E1_TIPO || SE11.E1_CLIENTE || SE11.E1_LOJA "  
			cQueryP += " FROM "+RetSqlName("SE1") + " SE11, "+RetSqlName("SA1") + " SA11 "
			cQueryP += " WHERE SE11.E1_FILIAL = '" + xFilial("SE1") + "' AND SE11.E1_CLIENTE = SA11.A1_COD AND SE11.E1_LOJA = SA11.A1_LOJA "
			cQueryP += " AND SE11.D_E_L_E_T_ = ' ' AND SA11.D_E_L_E_T_ = ' ' " + StrTran(cQryImp, "SE1.", "SE11.")
			If FWModeAccess("SE1",3) == "E"
				cQueryP += " AND SE1.E1_FILIAL " + cQryFilSE1
			Else
				If MV_PAR42 == 1
					cQueryP += " AND SE1.E1_FILORIG " + FR130InFilial()
				Else
					cQueryP += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
				EndIf
			Endif
		
			
			If mv_par30 == 2 // nao imprime
				cQueryP += " AND SE1.E1_MOEDA = "+cMoeda
			Endif
			cQueryP += ") ) "
		Endif
		
		//GESTAO - fim
		If FWModeAccess("SE1",3) == "E"
			cQueryP += " AND SE1.E1_FILIAL " + cQryFilSE1
		Else
			If MV_PAR42 == 1
				cQueryP += " AND SE1.E1_FILORIG " + FR130InFilial()
			Else
				cQueryP += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
			EndIf
		Endif
		
		If mv_par30 == 2 // nao imprime
			cQueryP += " AND SE1.E1_MOEDA = "+cMoeda
		Endif

        
	    If lF130Qry
			cQueryP += ExecBlock("F130QRY",.f.,.f.)
		Endif
		
		cQuery += cQueryP
		
		If MV_PAR43 == 1
			If TcSrvType() != "AS/400"
				cQuery += " AND SE1.R_E_C_N_O_ NOT IN (SELECT PAI.FJU_RECPAI FROM "+ RetSqlName("FJU")+" PAI " 
				cQuery += " WHERE PAI.D_E_L_E_T_ = ' ' AND "
				cQuery += " PAI.FJU_CART = 'R' AND "
				cQuery += " PAI.FJU_DTEXCL >= '" + DTOS(dDataBase) + "' "
				cQuery += " AND PAI.FJU_EMIS1 <= '" + DTOS(dDataBase) + "') "	
				
				cQuery += " AND SE1.E1_TITPAI NOT IN ( SELECT "	
				
				If lMSSQL
					cQuery += " PAI.FJU_PREPAI +  PAI.FJU_NUMPAI + PAI.FJU_PARPAI + PAI.FJU_TIPPAI + PAI.FJU_FORPAI  + PAI.FJU_LOJPAI " 
				Elseif lMySQL        
					cQuery += " CONCAT(PAI.FJU_PREPAI,PAI.FJU_NUMPAI, PAI.FJU_PARPAI, PAI.FJU_TIPPAI, PAI.FJU_FORPAI, PAI.FJU_LOJPAI) "
				Else
					cQuery += " PAI.FJU_PREPAI || PAI.FJU_NUMPAI || PAI.FJU_PARPAI || PAI.FJU_TIPPAI || PAI.FJU_FORPAI || PAI.FJU_LOJPAI AS RESULTFJU" 
				EndIf
				
				cQuery += " FROM " + RetSqlName("FJU")+" PAI "
				cQuery += " WHERE PAI.D_E_L_E_T_ = ' ' AND "
				cQuery += " PAI.FJU_CART = 'R' AND "
				cQuery += " PAI.FJU_RECPAI>0 AND "
				cQuery += " PAI.FJU_DTEXCL >= '" + DTOS(dDataBase) + "' "
				cQry := cQuery
				cQuery += " AND PAI.FJU_EMIS1 <= '" + DTOS(dDataBase) + "') "
				cQry += " AND PAI.FJU_EMIS1 <= '" + DTOS(dDataBase) + "')) "	

				cQryAux += " UNION "
		  	
		  		If nOrdem = 1
					cQryAux += " SELECT SE1.E1_FILIAL, SE1.E1_NOMCLI, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.R_E_C_N_O_,  " + SubStr(cCampos,2)
		  		Else
					cQryAux += " SELECT SE1.E1_FILIAL, " + SubStr(cCampos,2) + ", SE1.R_E_C_N_O_ " 
		  		Endif
		  	
				cQryAux += " FROM "+ RetSqlName("SE1")+" SE1,"+ RetSqlName("FJU") +" FJU"
				cQryAux += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
				cQryAux += " AND FJU.FJU_FILIAL	 = '" + xFilial("FJU") + "'"
				cQryAux += " AND SE1.E1_PREFIXO 	= FJU.FJU_PREFIX "
				cQryAux += " AND SE1.E1_NUM 		= FJU.FJU_NUM "
				cQryAux += " AND SE1.E1_PARCELA 	= FJU.FJU_PARCEL "
				cQryAux += " AND SE1.E1_TIPO 	= FJU.FJU_TIPO "
				cQryAux += " AND SE1.E1_CLIENTE	= FJU.FJU_CLIFOR "
				cQryAux += " AND SE1.E1_LOJA 	= FJU.FJU_LOJA "
				cQryAux += " AND FJU.FJU_EMIS   <= '" + DTOS(dDataBase) +"'"
				cQryAux += " AND FJU.FJU_DTEXCL >= '" + DTOS(dDataBase) +"'"
				cQryAux += " AND FJU.FJU_CART = 'R' "
				cQryAux += " AND SE1.R_E_C_N_O_ = FJU.FJU_RECORI "
				
				cQryAux += " AND FJU.FJU_RECORI IN ( SELECT MAX(FJU_RECORI) "
 
				cQryAux +=   "FROM "+ RetSqlName("FJU")+" LASTFJU "
				cQryAux +=   "WHERE LASTFJU.FJU_FILIAL = FJU.FJU_FILIAL "
				cQryAux +=   "AND LASTFJU.FJU_PREFIX = FJU.FJU_PREFIX "
				cQryAux +=   "AND LASTFJU.FJU_NUM = FJU.FJU_NUM "
				cQryAux +=   "AND LASTFJU.FJU_PARCEL = FJU.FJU_PARCEL "
				cQryAux +=   "AND LASTFJU.FJU_TIPO = FJU.FJU_TIPO "
				cQryAux +=   "AND LASTFJU.FJU_CLIFOR = FJU.FJU_CLIFOR "
				cQryAux +=   "AND LASTFJU.FJU_LOJA = FJU.FJU_LOJA "	
				cQryAux +=   "AND FJU.FJU_DTEXCL = LASTFJU.FJU_DTEXCL "
				cQryAux +=   "GROUP BY FJU_FILIAL "
				cQryAux += "       ,FJU_PREFIX "
				cQryAux += "       ,FJU_NUM "
				cQryAux += "       ,FJU_PARCEL "
				cQryAux += "       ,FJU_CLIFOR "
				cQryAux += "       ,FJU_LOJA ) "
  
				cQryAux += " AND SE1.D_E_L_E_T_ = '*' " 
				cQryAux += " AND FJU.D_E_L_E_T_ = ' ' " 
					
				cQryAux += " AND " 
				cQryAux += " (SELECT COUNT(*) " 
				cQryAux += " FROM "+ RetSqlName("SE1")+" NOTDEL " 
				cQryAux += " WHERE NOTDEL.E1_FILIAL = FJU.FJU_FILIAL "         
				cQryAux += " AND NOTDEL.E1_PREFIXO = FJU.FJU_PREFIX     "      
				cQryAux += " AND NOTDEL.E1_NUM = FJU.FJU_NUM            "
				cQryAux += " AND NOTDEL.E1_PARCELA = FJU.FJU_PARCEL      "
				cQryAux += " AND NOTDEL.E1_TIPO = FJU.FJU_TIPO "        
				cQryAux += " AND NOTDEL.E1_CLIENTE = FJU.FJU_CLIFOR       "     
				cQryAux += " AND NOTDEL.E1_LOJA = FJU.FJU_LOJA  	"
				cQryAux += " AND FJU.FJU_CART = 'R' "
				cQryAux += " AND FJU.FJU_RECPAI = 0 "
				cQryAux += " AND NOTDEL.E1_EMISSAO   <= '" + DTOS(dDataBase) +"'"
				cQryAux += " AND NOTDEL.D_E_L_E_T_ = '') = 0 "
				
				cQryAux += " AND FJU.FJU_RECORI NOT IN (SELECT PAI.FJU_RECPAI FROM "+ RetSqlName("FJU")+" PAI " 
				cQryAux += " WHERE PAI.D_E_L_E_T_ = ' ' AND "
				cQryAux += " PAI.FJU_CART = 'R' AND "
				cQryAux += " PAI.FJU_DTEXCL >= '" + DTOS(dDataBase) + "' "
				cQryAux += " AND PAI.FJU_EMIS1 <= '" + DTOS(dDataBase) + "') "
				
				cQryAux += " AND FJU.FJU_TITPAI NOT IN ( SELECT "
				
				If lMSSQL
					cQryAux += " PAI.FJU_PREPAI +  PAI.FJU_NUMPAI + PAI.FJU_PARPAI + PAI.FJU_TIPPAI + PAI.FJU_FORPAI  + PAI.FJU_LOJPAI " 
				Elseif lMySQL        
					cQryAux += " CONCAT(PAI.FJU_PREPAI,PAI.FJU_NUMPAI, PAI.FJU_PARPAI, PAI.FJU_TIPPAI, PAI.FJU_FORPAI, PAI.FJU_LOJPAI) "
				Else
					cQryAux += " PAI.FJU_PREPAI || PAI.FJU_NUMPAI || PAI.FJU_PARPAI || PAI.FJU_TIPPAI || PAI.FJU_FORPAI || PAI.FJU_LOJPAI " 
				EndIf
				
				cQryAux += " FROM " + RetSqlName("FJU")+ " PAI " 
				cQryAux += " WHERE  PAI.D_E_L_E_T_ = ' ' " 
				cQryAux += " AND PAI.FJU_CART = 'R' " 
				cQryAux += " AND PAI.FJU_DTEXCL >= '" + DTOS(dDataBase) +"'"
				cQryAux += " AND PAI.FJU_EMIS1 <= '" + DTOS(dDataBase) +"'"
				cQryAux += " AND PAI.FJU_RECPAI>0)" 
				cQuery += cQryAux+ cQueryP
				cQry += cQryAux+ cQueryP
				cQryAux:= ""
			Endif	
		EndIf				

		// Fase 1 - Query 1 somente os titulos sem os abatimentos
		cQuery1 := StrTran(cSelect, 'R_E_C_N_O_', 'SE1.R_E_C_N_O_') + cQuery 		
		
		// Fase 2 - Query 2 somente os abatimentos dos titulos listados na Query1
		cQuery2 := cSelect + " FROM " + RetSQLName( "SE1" ) + " TMP " 
		cQuery2 += " WHERE TMP.E1_TIPO LIKE '%-' AND "
		If !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
			cQuery2 += " TMP.E1_TIPO NOT IN "+FormatIn(mv_par32,";") + " AND " 
		EndIf
		cQuery2 += "    TMP.E1_FILIAL = '" + xFilial("SE1") + "' AND "
		cQuery2 += IIF(lOracle, " 	LTRIM(RTRIM(TMP.E1_TITPAI)) IN ( ", " 	TMP.E1_TITPAI IN ( ")
		
		If lBanco 
			If lNvl
				cQuery2 += "	SELECT NVL(SE1.E1_PREFIXO " + cOper + " SE1.E1_NUM " + cOper 
			Else
				cQuery2 += "	SELECT " + IIF(lOracle, "LTRIM(RTRIM(", "") + " COALESCE(SE1.E1_PREFIXO " + cOper + " SE1.E1_NUM " + cOper
			EndIf
			cQuery2 += "	SE1.E1_PARCELA " + cOper + " SE1.E1_TIPO " + cOper + " SE1.E1_CLIENTE " + cOper + " SE1.E1_LOJA, ' ') " + IIF(lOracle, "))", "") + " AS SE1ABT "
		Else
			cQuery2 += "	SELECT SE1.E1_PREFIXO " + cOper + " SE1.E1_NUM " + cOper 
			cQuery2 += "	SE1.E1_PARCELA " + cOper + " SE1.E1_TIPO " + cOper + " SE1.E1_CLIENTE " + cOper + " SE1.E1_LOJA "
		EndIf 
		
		cQuery2 += If(!Empty(cQry), cQry, cQuery)  	
		
		IF MV_PAR43 == 2
				cQuery2 += " AND TMP.D_E_L_E_T_ = ' ' "
		ENDIF
		
		cQuery2 := ChangeQuery(cQuery2)
		// Fase 3 - Novo temporario unindo Query1+Query2 ( Titulos + Abatimentos )
		cQuery3 := StrTran(cQuery1, "FOR READ ONLY", "" )  + " UNION " + StrTran(cQuery2, "FOR READ ONLY", "" ) + " ORDER BY " + cOrder
		cQuery3 := ChangeQuery(cQuery3)
		dbSelectArea("SE1")
		dbCloseArea()
		dbSelectArea("SA1")

		If MV_PAR33 == 3
			cQuery1 := (cQuery1 + " ORDER BY " + cOrder)
			cQuery1 := ChangeQuery(cQuery1)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery1), 'SE1', .F., .T.)
		Else
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery3), 'SE1', .F., .T.)
		Endif

		For nI := 1 to Len(aStru)
			If aStru[nI,2] != 'C'
				TCSetField('SE1', aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
			Endif
		Next
	
	If MV_MULNATR .And. nOrdem == 5

		// No relatorio analitico desabilita secao de totais quando MV_MULNATR e ordenacao por natureza,
		// para forcar a utilizacao da totalizacao com oBreak e TRFunction da oSection1.
		If mv_par19 == 1
			oSection2:Disable()
		EndIf
		/*
		GESTAO - inicio */
		If nLenSelFil == 0
			Finr135(cTipos, .F., @nTot0, @nTot1, @nTot2, @nTot3, @nTotTit, @nTotJ, oReport, aDados, @oSection2, aStru)
		Else
			cTitBkp := cTitulo
			Finr135(cTipos, .F., @nTotFil0, @nTotFil1, @nTotFil2, @nTotFil3, @nTotFilTit, @nTotFilJ, oReport, aDados, @oSection2, aStru)
			nTot0 += nTotFil0
			nTot1 += nTotFil1
			nTot2 += nTotFil2
			nTot3 += nTotFil3
			nTot4 += nTotFil4
			nTotJ += nTotFilJ
			nTotTit += nTotFilTit
			cNomFil := cFilAnt + " - " + AllTrim(SM0->M0_FILIAL)
			cNomEmp := Substr(cFilAnt,1,nTamEmp) + " - " + AllTrim(SM0->M0_NOMECOM)
			cTitulo := cTitBkp
		Endif
		/* GESTAO - fim
		*/
		dbSelectArea("SE1")
		dbCloseArea()
		ChKFile("SE1")
		dbSelectArea("SE1")
		dbSetOrder(1)

		/*
		GESTAO - inicio */
		If nLenSelFil == 0
			dbSelectArea("SM0")
			dbSkip()
			lContinua := SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
		Else
			nFilAtu++
			lContinua := (nFilAtu <= nLenSelFil)
			If lContinua
				If oBrkNat:Execute()
					oBrkNat:PrintTotal()
				Endif
				If nTotFil0 <> 0
					oBrkFil:PrintTotal()
				Endif
				Store 0 To nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ
				If !(Substr(aSelFil[nFilAtu-1],1,nTamEmp) == Substr(aSelFil[nFilAtu],1,nTamEmp))
					If nTotEmp0 <> 0
						oBrkEmp:PrintTotal()
					Endif
					nTotEmp0 := 0
					nTotEmp1 := 0
					nTotEmp2 := 0
					nTotEmp3 := 0
					nTotEmp4 := 0
					nTotEmpJ := 0
					nTotTitEmp := 0
				Endif
			Endif
		Endif
		/* GESTAO - fim
		*/
		If Empty(xFilial("SE1"))
			Exit
		Endif
		Loop

	Endif


   
   
	While !Eof() .And. SE1->E1_FILIAL == cFilSE1 .And. &cCond1

		Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5
		If mv_par19 == 1
			Store 0 To nTot0,nTot1,nTot2,nTot3,nTot4,nTotJ
		EndIf

		
		dDataAnt := Iif(nOrdem == 6 , SE1->E1_EMISSAO,  Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA))

		cCarAnt := &cCond2
		cFilAntSE1 := SE1->E1_FILIAL

		While !Eof() .And. SE1->E1_FILIAL == cFilSE1 .And. &cCond2 == cCarAnt

			dbSelectArea("SE1")
			
			If !Fr130Cond(cTipos)
				SE1->(DbSkip())
				Loop
			EndIf
					
			dDtCtb	:=	CTOD("//")
			dDtCtb	:= Iif(Empty(SE1->E1_EMIS1),SE1->E1_EMISSAO,SE1->E1_EMIS1)

			
			dbSelectArea("SE1")

			If dDtCtb < mv_par27 .Or. dDtCtb > mv_par28
				SE1->( dbSkip() )
				Loop
			Endif

		
			If !Empty(cFilUserSA1)
				dbSelectArea("SA1")
				If MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
					If !SA1->(&cFilUserSA1)
						SE1->(dbSkip())
						Loop
					EndIf
				Else
					SE1->(dbSkip())
					Loop
				EndIf
			Endif
			
			dbSelectArea("SE1")
			IF (SE1->E1_TIPO $ MVABATIM	+"/"+MVFUABT  .And. mv_par33 != 1) .Or.;
				(SE1->E1_EMISSAO > mv_par36 .and. MV_PAR38 == 2)
				IF !Empty(SE1->E1_TITPAI)
					aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , SE1->E1_TITPAI } )
				Else
					cMTitPai := FTITPAI()
					aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , cMTitPai } )
				EndIf
				SE1->(dbSkip())
				Loop
			Endif

			//Quando Retroagir saldo, data menor que o solicitado e o titulo estiver
			//baixado nao mostrar no relatorio
			If (MV_PAR20 == 1 .and. cMVBR10925 == "1" .and. SE1->E1_EMISSAO <= MV_PAR36 .and. SE1->E1_TIPO $ "PIS/COF/CSL")
				SE1->(dbSkip())
				Loop
			EndIf

			 // Tratamento da correcao monetaria para a Argentina
			If  cPaisLoc=="ARG" .And. mv_par15 <> 1  .And.  SE1->E1_CONVERT=='N'
				SE1->(dbSkip())
				Loop
			Endif

			// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
			If SE1->E1_VENCREA < dDataBase
				If mv_par17 == 2 .And. RecMoeda(SE1->E1_VENCREA,cMoeda) > 0
					dDataReaj := SE1->E1_VENCREA
				Else
					dDataReaj := dDataBase
				EndIf
			Else
				dDataReaj := dDataBase
			EndIf
			Dbselectarea("SE5")
			DbSetorder(7) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
			Dbseek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+ SE1->E1_PARCELA + SE1->E1_TIPO +SE1->E1_CLIENTE )                                                                                 
			If mv_par20 == 1	// Considera Data Base
				nSaldo := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par15,dDataReaj,MV_PAR36,SE1->E1_LOJA,SE5->E5_FILORIG,Iif(mv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0),mv_par37,.T.)
				
				If lVerCmpFil .and. ( mv_par41 == 1 ) .and. ( nSaldo != SE1->E1_SALDO ) .and.;
									 aScan( aRecSE1Cmp , { |x| x[1] == SE1->( R_E_C_N_O_ )} ) > 0
					proclogatu("INICIO",STR0085) 
					nSaldo -= Round(NoRound( xMoeda( FRVlCompFil("R",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,mv_par37,aFiliais,cFilQry,lAS400),;
									SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(mv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA) ),0 ) ),;
									nDecs+1),nDecs)
					proclogatu("FIM",STR0085)
				EndIf
				
				If Str(SE1->E1_VALOR,17,2) == Str(nSaldo,17,2) .And. SE1->E1_DECRESC > 0 .And. SE1->E1_SDDECRE == 0
					nSAldo -= SE1->E1_DECRESC
				Endif
				
				
				If Str(SE1->E1_VALOR,17,2) == Str(nSaldo,17,2) .And. SE1->E1_ACRESC > 0 .And. SE1->E1_SDACRES == 0
					nSAldo += SE1->E1_ACRESC
				Endif

				If SE1->E1_TIPO $ MVABATIM	+"/"+MVFUABT .and. ;
					((SE1->E1_BAIXA <= dDataBase .and. !Empty(SE1->E1_BAIXA)) .or. ;
					 (SE1->E1_MOVIMEN <= dDataBase .and. !Empty(SE1->E1_MOVIMEN))	) .and.;
					 SE1->E1_SALDO == 0
					nSaldo := 0
					IF !Empty(SE1->E1_TITPAI)
						aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , SE1->E1_TITPAI } )
					Else
						cMTitPai := FTITPAI()
						aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , cMTitPai } )
					EndIf
					aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , SE1->E1_TITPAI } )
				Endif
				
				If AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA) <> AllTrim(SE1->E1_CLIENTE)+AllTrim(SE1->E1_LOJA) .and. cMVBR10925 == "1" .And. lBQ10925 
					nRecSA1 := SA1->(Recno())															
					If !SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)) 																	 
						SA1->(DbGoto(nRecSA1))
						nRecSA1 := 0						
					EndIf
				ElseIf cMVBR10925 == "1" .And. lBQ10925
					nRecSA1 := SA1->(Recno())									
				EndIf

				If cPaisLoc=="BRA"
					If (( cMVBR10925 == "1" .and. SE1->E1_EMISSAO <= MV_PAR36 .and. !(SE1->E1_TIPO $ "PIS/COF/CSL").and. !(SE1->E1_TIPO $ MVABATIM) ) ;
							.AND. ( "S" $ (SA1->(A1_RECPIS+A1_RECCOFI+A1_RECCSLL) ) ) ) .Or. (SA1->A1_IRBAX == '1' .And. SE1->E1_EMISSAO <= MV_PAR36 .and. ;
						!(SE1->E1_TIPO $ MVIRF).and. !(SE1->E1_TIPO $ MVABATIM) .AND. ( (SA1->(A1_RECIRRF) $ "1 " ) .And. SA1->A1_TPESSOA == 'EP' ) )
	
						nValPcc := SumAbatPCC(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,dBaixa,SE1->E1_CLIENTE,SE1->E1_LOJA,mv_par15)
						// Se existir, a procedure j?abate o PCC 
						IF __lProcSaldoTit
							nSaldo -= nValPcc
						ENDIF					
						
						If nRecSA1 > 0
							SE5->(DbSetOrder(7))
							cSeq := "01" 				
							while SE5->(MsSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+cSeq));
								.And. nSaldo <> SE1->E1_SALDO .And. AllTrim(SA1->A1_IRBAX) = "1" .And. SE5->E5_VRETIRF > 0			
								nSaldo := Iif(SE5->E5_DATA < mv_par36,  (nSaldo - SE5->E5_VRETIRF), nSaldo)
								cSeq := IIF(cSeq > "08", ALLTRIM(STR(VAL(cSeq)+1)), "0" + ALLTRIM(STR(VAL(cSeq)+1)))  	
							EndDo										
						Endif					
					EndIf
				EndIf
				nRecSA1 := 0				
				If SE1->E1_TIPO == "RA "   //somente para titulos ref adiantamento verifica se nao houve cancelamento da baixa posterior data base (mv_par36)
					nSaldo -= F130TipoBA()
				EndIf
			Else
				nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
			Endif

			// Se titulo do Template GEM
			If __lTempLOT .And.  !Empty(SE1->E1_NCONTR)
				nGem := CMDtPrc(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VENCREA)[2]
				If SE1->E1_VALOR==SE1->E1_SALDO
					nSaldo += nGem
				EndIf
			EndIf

			//Caso exista desconto financeiro (cadastrado na inclusao do titulo),
			//subtrai do valor principal.
			If !(!Empty( SE1->E1_BAIXA ) .AND. SE1->E1_BAIXA < dDatabase) .Or. cMvDesFin == "P" 
				nDescont := FaDescFin("SE1",dBaixa,SE1->E1_SALDO,1,.T.,lTemGem)
				If Mv_par15 > 1
					If SE1->E1_MOEDA == Mv_par15
						nDescont := xMoeda((nDescont),1,Mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
					Else
						nDescont := xMoeda((nDescont),SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
					EndIf
				EndIf
				If nDescont > 0
					nSaldo := nSaldo - nDescont
				Endif
			EndIf

			If ! SE1->E1_TIPO $ MVABATIM	+"/"+MVFUABT
				If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. ;
						!( MV_PAR20 == 2 .And. nSaldo == 0 )  	// deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo

					cFilNat:= SE1->E1_NATUREZ
					lExistAba:= HashNatur(@cTipoIn)
					
					
					If lexistaba						
						aTitImp:= F130RETIMP(cFilNat)
					Else				        
						aTitImp:= {}
					EndIf
					
					If ((nPos := (aScan(aTitImp, {|x| x[1] <> SE1->E1_TIPO }))) > 0 .and. aTitImp[nPos][2]) .OR.;
						aScan(aAbatBaixa, {|x| ALLTRIM(x[2])==ALLTRIM(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)) }) > 0

						//Quando considerar Titulos com emissao futura, eh necessario
						//colocar-se a database para o futuro de forma que a Somaabat()
						//considere os titulos de abatimento
						If mv_par38 == 1
							dOldData := dDataBase
							dDataBase := CTOD("31/12/40")
						Endif

						// Somente verifica abatimentos se existirem titulos deste tipo para o cliente
						If lExistAba
							nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mv_par15,dDataReaj,SE1->E1_CLIENTE,SE1->E1_LOJA)
						Else
							nAbatim := 0
						EndIf

						If mv_par38 == 1
			   				dDataBase := dOldData
						Endif

						If mv_par33 != 1  //somente deve considerar abatimento no saldo se nao listar

							If STR(nSaldo,17,2) == STR(nAbatim,17,2)
								nSaldo := 0
							ElseIf mv_par33 == 2  //Se nao listar ele diminui do saldo								
								nSaldo-= nAbatim
							Endif
						Else
						   
	 					  	nBx := aScan( aAbatBaixa, {|x| x[2]= SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) } )
						  	If (SE1->E1_BAIXA <= dDataBase .and. !Empty(SE1->E1_BAIXA) .and. nBx>0)
						  		aDel( aAbatBaixa , nBx)
						  		aSize(aAbatBaixa, Len(aAbatBaixa)-1)
								 nSaldo-= nAbatim
							EndIf
						EndIf
					Endif
				Endif
			Endif
			nSaldo:=Round(NoRound(nSaldo,3),2)

		   
			If nSaldo <= 0
				SE1->(dbSkip())
				Loop
			Endif
			
			cCodEmp := FWCodEmp()
			
			
			// Retirada de clientes na empresa 01
			If cCodEmp == "01" .and. (SE1->E1_CLIENTE == "010064" .or. SE1->E1_CLIENTE == "004536")
				SE1->(dbSkip())
				Loop
			Endif
			
			If cCodEmp == "05" .and. (SE1->E1_CLIENTE == "000481" .or. SE1->E1_CLIENTE == "010064")
				SE1->(dbSkip())
				Loop
			Endif
			
			If cCodEmp == "07" .and. (SE1->E1_CLIENTE == "000481" .or. SE1->E1_CLIENTE == "004536")
				SE1->(dbSkip())
				Loop
			Endif
			//Ticket 29738
			/*
			If SE1->E1_HIST == "FUNCIONARIO              "
				SE1->(dbSkip())
				Loop
			Endif
			*/
			If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .and. mv_par26 == 2
				SE1->(dbSkip())
				Loop
			Endif
			
			//Ticket 29738
			If AT("PR",SE1->E1_PREFIXO) > 0
				SE1->(dbSkip())
				Loop
			Endif
			
			SA1->( MSSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA) )
			nRecSA1 := SA1->(RECNO())
			
			If SA1->A1_YSITGRP $ "2/3/4"
				// Ticket 13639
				//Caso o cliente esteja em perda será verificado se foi adicionado em perda no ano
				//Caso seja do ano ainda irá considerar, se for de anos anteriores nao irá considerar 
				nContador :=  CliPerdaAno(SE1->E1_CLIENTE, dDataBase)
				if nContador = 0
					SE1->(dbSkip())
					Loop
				end if
			Endif
			
			aDados[CATEGORIA] := SA1->A1_YCAT
			aDados[SEGMENTO] := SA1->A1_YTPSEG
			aDados[RISCO] := SA1->A1_RISCO
			SA6->( MSSeek(cFilial+SE1->E1_PORTADO) )
			dbSelectArea("SE1")

			aDados[CLIENT] := RTrim(SE1->E1_CLIENTE)// + "-" + SE1->E1_LOJA + "-" + IIF(mv_par29 == 1, SubStr(SA1->A1_NREDUZ,1,20), SubStr(SA1->A1_NOME,1,20))
			aDados[TITUL] := SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA
			aDados[PREFIXO] := RTRIM(SE1->E1_PREFIXO)
			aDados[TIPO] := SE1->E1_TIPO
			
			aDados[DATA_BASE] := dDataBase
			aDados[NATUREZA] := SE1->E1_NATUREZ
			aDados[EMISSAO] := SE1->E1_EMISSAO
			aDados[VENCTO] := SE1->E1_VENCTO
			aDados[VENCREA] := SE1->E1_VENCREA
			lVl_Corr := .T.

			If mv_par20 == 1  //Recompoe Saldo Retroativo
			    
			    IF !Empty(SE1->E1_BAIXA)
			    	If SE1->E1_BAIXA <= mv_par36 .Or. !Empty( SE1->E1_PORTADO )
						aDados[BANC] := SE1->E1_PORTADO+" "+SE1->E1_SITUACA
					EndIf
				Else
				   
					If Empty(SE1->E1_BAIXA) .and. SE1->E1_MOVIMEN <= mv_par36
						aDados[BANC] := SE1->E1_PORTADO+" "+SE1->E1_SITUACA
					EndIf
				ENDIF
			Else   // Nao Recompoe Saldo Retroativo
				aDados[BANC] := SE1->E1_PORTADO+" "+SE1->E1_SITUACA
			EndIf
			//Se parametro Tit. Emissao Futura = Sim , e se for titulos de impostos gerados na baixa com data posterior a database, e parametro Recompoe Saldo = Sim => Exibier como Abatimento
			lAbatIMPBx := MV_PAR38 == 1 .AND. SE1->E1_EMISSAO >= MV_PAR36 .AND. MV_PAR20 == 1 .AND. SE1->E1_TIPO $ "PIS/COF/CSL/IRF"
			aDados[VL_ORIG] := Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,Nil)) * If((SE1->E1_TIPO$MVABATIM +"/"+MVFUABT+"/"+MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM) .OR. lAbatIMPBx, -1,1),nDecs+1),nDecs)
			aDados[VL_NOMINAL] :=0
			aDados[VL_CORRIG]:=0
			aDados[VL_VENCIDO]:=0
			
			If SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT 
				dVencRea := Posicione("__SE1",1,xFilial("SE1")+SE1->E1_TITPAI,"E1_VENCREA")
			Else
				dVencRea	:= SE1->E1_VENCREA
			EndIf
			
			If dDataBase > dVencRea	//vencidos
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					aDados[VL_NOMINAL] := nSaldo * If(SE1->E1_TIPO$MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM +"/"+MVFUABT, -1,1)
				EndIf
				
				If !( SE1->E1_TIPO $ MVRECANT + "|" + MV_CRNEG ) .And. ( lFJurCst .Or. !Empty(SE1->E1_VALJUR) .Or. !Empty(SE1->E1_PORCJUR) .Or. lClcMultLj )
					dUltBaixa := SE1->E1_BAIXA
					If MV_PAR20 == 1 // se compoem saldo retroativo verifico se houve baixas 
						If !Empty(dUltBaixa) .And. dDataBase < dUltBaixa
							dUltBaixa := FR130DBX() // Ultima baixa at?DataBase
						EndIf
					EndIf
					
					nJuros := fa070Juros(mv_par15,nSaldo + IIF(MV_PAR33 == 2,nAbatim,0) ,"SE1",dUltBaixa)

					If lClcMultLj
						
						nMulta := LojxRMul(,,,nSaldo + IIF(MV_PAR33 == 2,nAbatim,0),SE1->E1_ACRESC,SE1->E1_VENCREA,dDataBase,,SE1->E1_MULTA,,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,"SE1",.T.)
					
		      	  	ElseIf AllTrim(SE1->E1_ORIGEM) == "FINI055" 
		     	  		If lMvJurTin
							nMulta := ( SE1->E1_PORCJUR / 100 ) * ( SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE )
		      	  		Else
		      	  			nMulta := ( SE1->E1_PORCJUR / 100 ) * SE1->E1_SALDO
		      	  		EndIf

		      	  	Endif
					
				EndIf
				// Se titulo do Template GEM
				If __lTempLOT .And.  !Empty(SE1->E1_NCONTR) .And. SE1->E1_VALOR==SE1->E1_SALDO
					nJuros -= nGem
				EndIf
				dbSelectArea("SE1")
				nVa :=  IIf(lFValAcess,;
							FValAcess(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NATUREZ, Iif(Empty(SE1->E1_BAIXA),.F.,.T.),"","R",,,SE1->E1_MOEDA,mv_par15,SE1->E1_TXMOEDA),;
							0)
				
				If nVA > 0 
					nJuros += nVa
				EndIf
				
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					aDados[VL_CORRIG] := (nSaldo+nJuros+nMulta)* If(SE1->E1_TIPO$MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM +"/"+MVFUABT, -1,1)
					lVl_Corr := .F.
				EndIf

				If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .or. (mv_par33 == 1 .and. SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT)
					nTit0 -= Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nTit1 -= (nSaldo)
					nTit2 -= (nSaldo+nJuros+nMulta)
					nMesTit0 -= Round(NoRound( xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nMesTit1 -= (nSaldo)
					nMesTit2 -= (nSaldo+nJuros+nMulta)
					nTotJur  -= nJuros
					nMesTitj -= nJuros
					nTotFilJ -= nJuros
				Else
					If !SE1->E1_TIPO $ MVABATIM	+"/"+MVFUABT
						nTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
						nTit1 += (nSaldo)
						nTit2 += (nSaldo+nJuros+nMulta)
						nMesTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
						nMesTit1 += (nSaldo)
						nMesTit2 += (nSaldo+nJuros+nMulta)
						nTotJur  += nJuros
						nMesTitj += nJuros
						nTotFilJ += nJuros
					Endif
				Endif
			Else						//a vencer
				nVa := IIf(lFValAcess,;
							FValAcess(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NATUREZ, Iif(Empty(SE1->E1_BAIXA),.F.,.T.),"","R",,,SE1->E1_MOEDA,mv_par15,SE1->E1_TXMOEDA),;
							0)
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					aDados[VL_VENCIDO] := nSaldo * If((SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM +"/"+MVFUABT) .OR. lAbatIMPBx, -1,1)
					aDados[VL_VENCIDO] += nVa
				EndIf

				If ! ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM +"/"+MVFUABT) .and. !lAbatIMPBx
					nTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nTit3 += (nSaldo-nTotAbat) + nVa
					nTit4 += (nSaldo-nTotAbat)  + nVa
					nMesTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nMesTit3 += (nSaldo-nTotAbat)  + nVa
					nMesTit4 += (nSaldo-nTotAbat) + nVa
				Else
					nTit0 -= Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nTit3 -= (nSaldo-nTotAbat)
					nTit4 -= (nSaldo-nTotAbat)
					nMesTit0 -= Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nMesTit3 -= (nSaldo-nTotAbat) + nVa
					nMesTit4 -= (nSaldo-nTotAbat) + nVa
				Endif

			Endif

			If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
				aDados[NUMBC] := SE1->E1_NUMBCO
			EndIf

			If nJuros > 0

				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					aDados[VL_JUROS] := nJuros + nMulta
				EndIf

				nJuros := 0

			Endif

			nMulta := 0

			If dDataBase > SE1->E1_VENCREA .And. !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
				nAtraso:=dDataBase-SE1->E1_VENCTO
				If Dow(SE1->E1_VENCTO) == 1 .Or. Dow(SE1->E1_VENCTO) == 7
					If Dow(dBaixa) == 2 .and. nAtraso <= 2
						nAtraso := 0
					EndIf
				EndIf
				nAtraso:=If(nAtraso<0,0,nAtraso)
				If nAtraso>0
					If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
						aDados[ATRASO] := nAtraso
					EndIf
				EndIf
			Else
				If !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
					nAtraso:=dDataBase-if(dDataBase==SE1->E1_VENCREA,SE1->E1_VENCREA,SE1->E1_VENCTO)
					nAtraso:=If(nAtraso<0,0,nAtraso)
				Else
					nAtraso:=0
				EndIf
				aDados[ATRASO] := nAtraso
			EndIf
			
			cCodEmp := FWCodEmp()

			If !(SE1->E1_NUM == "000305694" .And. cCodEmp == "01")
				aDados[HISTORICO] := SubStr(SE1->E1_HIST,1,25)+IIF(E1_TIPO $ MVPROVIS,"*"," ")+ ;
				Iif(Str(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),17,2) ==Str(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),17,2)," ","P")
				
						
			
				nRecnoSE1 := SE1->(R_E_C_N_O_)
				DbChangeAlias("SE1","SE1QRY")
				DbChangeAlias("__SE1","SE1")
				SE1->(DbGoto(nRecnoSE1))
				//exibe a linha no relatorio
				oSection1:PrintLine()
				DbChangeAlias("SE1","__SE1")
				DbChangeAlias("SE1QRY","SE1")
				aDados[MARCA] := SE1->E1_YEMP
				insertDados(aDados, dDataBase)
			EndIf

			
			dDataAnt := If(nOrdem == 6, SE1->E1_EMISSAO, Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA))

			If lFR130Tel
				cCampoCli := ExecBlock("FR130TELC",.F.,.F.)
				If !SA1->(FieldPos(cCampoCli)) > 0
					cCampoCli := ""
				EndIf
			EndIf

			If nOrdem == 1 //Cliente
				cNomFor := If(mv_par29 == 1, AllTrim(SA1->A1_NREDUZ),AllTrim(SA1->A1_NOME)) +" "+Substr(Iif(!Empty(cCampoCli),SA1->(&cCampocli),SA1->A1_DDD+"-"+SA1->A1_TEL),1,18)
			Elseif nOrdem == 8 //codigo do cliente
				cNomFor := SA1->A1_COD+" "+SA1->A1_LOJA+" "+AllTrim(SA1->A1_NOME)+" "+Substr(Iif(!Empty(cCampoCli),SA1->(&cCampocli),SA1->A1_DDD+"-"+SA1->A1_TEL),1,18)
			Endif

			If nOrdem == 5 //Natureza
				dbSelectArea("SED")
				dbSetOrder(1)
				dbSeek(xFilial("SED")+SE1->E1_NATUREZ)
				cNomNat := SED->ED_CODIGO+" "+SED->ED_DESCRIC
			Endif

			If nOrdem == 7
				cNumBco := SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA
			Else
				cNumBco := SE1->E1_PORTADO
			Endif

			dDtVenc := Iif(nOrdem == 4 .OR. nOrdem == 7, Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA), SE1->E1_EMISSAO)
			nTotVenc:= nTit2+nTit3
			nTotMes := nMesTit2+nMesTit3

			SE1->(dbSkip())

			nTotTit ++
			nMesTTit ++
			nTotFiltit++
			nTit5 ++
			nTotTitEmp++		/* GESTAO */
			nTotReg++
			
			If oReport:nDevice == 6 .And. nTotReg == 60 
				oreport:Pagebreak(.T.)
				oReport:EndPage()	
				nTotReg := 0	
			EndIf
		Enddo
 
		If nOrdem == 3
			SA6->(dbSeek(xFilial()+cCarAnt))
		ELSEIf nOrdem == 7
			SA6->(dbSeek(xFilial()+SUBSTR(cCarAnt,9) ))
		EndIf

		IF nTit5 > 0 .And. nOrdem != 2 .And. nOrdem != 10 .And. mv_par19 == 2 //1 = Analitico - 2 = Sintetico
			SubTot130R(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,nDecs,oReport,,oSection2)
		ElseIf lImpSintTbl
			oReport:SkipLine()
			oReport:ThinLine()			
			SubTot130R(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,nDecs,oReport,,oSection2)		
		Endif

		nTotTitMes	:= nMesTTit
		nTotGeral	+= (nTit2+nTit3)

		
		lQuebra := .F.
		If nOrdem == 4  .and. (Month(Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA)) # Month(dDataAnt) .or. Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA) > mv_par10)
		 	If(mv_par19 == 2) //1 = Analitico - 2 = Sintetico
				lQuebra := .T.
		    Else
			  	nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
			EndIf
		Elseif nOrdem == 6 .and. (Month(SE1->E1_EMISSAO) # Month(dDataAnt) .or. SE1->E1_EMISSAO > mv_par14)
			If(mv_par19 == 2) //1 = Analitico - 2 = Sintetico
				lQuebra := .T.
			Endif
			nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
		Endif

		If lQuebra .and. nMesTTit # 0
			//QUEBRA POR MES
			oReport:SkipLine()
			oReport:ThinLine()
			IMes130R(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ,nDecs,oReport,,oSection2)

			If nOrdem == 4  .and. (Month(Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA)) # Month(dDataAnt) .or.;
			   Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA) > mv_par10) .And. (mv_par19 == 2)
				nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
			EndIf


		Endif

		// Quebra por Cliente.
		// "Salta pagina por cliente?" igual a "Sim" e a ordem eh por cliente ou codigo do cliente
		If mv_par35 == 1 .And. (nOrdem == 1 .Or. nOrdem == 8)
			oBreak:OnPrintTotal( { || oReport:EndPage() } )	// Finaliza pagina atual
		EndIf

		dbSelectArea("SE1")
		
		
		If mv_par33 == 2 .AND. MV_PAR19 == 1
			nTit0 -= nAbatim
			nTit1 -= nAbatim
			nTit2 -= nAbatim
			nAbatim := 0
		Endif
		
		nTot0+=nTit0
		nTot1+=nTit1
		nTot2+=nTit2
		nTot3+=nTit3
		nTot4+=nTit4
		nTotJ+=nTotJur
		/*
		GESTAO - inicio */
		nTotEmp0 += nTit0
		nTotEmp1 += nTit1
		nTotEmp2 += nTit2
		nTotEmp3 += nTit3
		nTotEmp4 += nTit4
		nTotEmpJ += nTotJur
		/* GESTAO - fim
		 */
		nTotFil0+=nTit0
		nTotFil1+=nTit1
		nTotFil2+=nTit2
		nTotFil3+=nTit3
		nTotFil4+=nTit4
		Store 0 To nTit0,nTit1,nTit2,nTit3,nTit4,nTit5,nTotJur,nTotAbat
	Enddo

///    nTotFil := IIf(Empty(nTotFil2),nTotFil0,nTotFil2)  na 10 NAO esa comentado
	If nTotFil0 <> 0
		nTotFil := Iif(nTotFil2>0,nTotFil2+nTotFil3,nTotFil3)  //Iif(mv_par33 == 23, nTotFil0, nTotFil2+nTotFil3)	
		nTotEmp += nTotFil
		cNomFil := cFilAnt + " - " + AllTrim(SM0->M0_FILIAL)
		cNomEmp := Substr(cFilAnt,1,nTamEmp) + " - " + AllTrim(SM0->M0_NOMECOM)
	EndIf

	If mv_par19 == 2 //1= Analitico   2 = Sintetico
		If (nLenSelFil > 1) .Or. (mv_par21 == 1 .And. SM0->(Reccount()) > 1) 		/* GESTAO */
			//Imprimir TOTAL por filial somente quando houver mais do que 1 filial.
			If nTotFil0 <> 0
				oReport:ThinLine()
				IFil130R(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFiltit,nTotFilJ,nDecs,oReport,,oSection2)
				oReport:SkipLine()
			Endif
		Endif
	Endif
	dbSelectArea("SE1")		// voltar para alias existente, se nao, nao funciona

	Store 0 To nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ
	If Empty(xFilial("SE1"))
		Exit
	Endif

	dbSelectArea("SE1")
	dbCloseArea()
	ChKFile("SE1")
	dbSelectArea("SE1")
	dbSetOrder(1)
	
	// Quebra por Cliente.
	// Evitar salto de pagina antes da impressao do total geral
	If mv_par35 == 1 .And. (nOrdem == 1 .Or. nOrdem == 8)	// Cliente ou Codigo do Cliente
		oBreak:OnPrintTotal( { || } )
	EndIf
	/*
	GESTAO - inicio */
	If nLenSelFil == 0
		dbSelectArea("SM0")
		dbSkip()
		lContinua := SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
	Else
		nFilAtu++
		lContinua := (nFilAtu <= nLenSelFil)
		If MV_PAR19 == 2
			If !lContinua .Or. !(Substr(cFilSE1,1,nTamEmp) == Substr(aSelFil[nFilAtu],1,nTamEmp))
				If nTotEmp0 <> 0
					oReport:ThinLine()
					TotGer130R(nTotEmp0,nTotEmp1,nTotEmp2,nTotEmp3,nTotEmp4,nTotTitEmp,nTotEmpJ,nDecs,oReport,,oSection2,STR0082 + " " + cNomEmp)		//"T O T A L  E M P R E S A -->"
					oReport:SkipLine()
				Endif
				nTotEmp0 := 0
				nTotEmp1 := 0
				nTotEmp2 := 0
				nTotEmp3 := 0
				nTotEmp4 := 0
				nTotEmpJ := 0
				nTotTitEmp := 0
			Endif
		Endif
	Endif
	/* GESTAO - fim
	*/
Enddo

// Quebra por Filial.
// Evitar salto de pagina antes da impressao do total geral
If mv_par35 == 1 .And. lTotFil .And. (nOrdem == 1 .Or. nOrdem == 8)
	oBrkFil:OnPrintTotal( { || } )
EndIf

SM0->(dbGoTo(nRegSM0))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

//Total geral para o Relatorio Sintetico
If mv_par19 == 2 .And. nOrdem != 2 .And. nOrdem != 10 //1 = Analitico - 2 = Sintetico
	oReport:SkipLine()
	oReport:ThinLine()
	TotGer130R(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nDecs,oReport,,oSection2)
Endif

oSection1:Finish()
//totalizador para formato tabela.
If lImpSintTbl
	oReport:SkipLine()
	oReport:ThinLine()
	TotGer130R(nTot0,nTot1,nTotal,nTot3,nTot4,nTotTit,nTotJ,nDecs,oReport,,oSection2)
EndIf
oSection2:Finish()

dbSelectArea("SE1")
dbCloseArea()
ChKFile("SE1")
dbSelectArea("SE1")
dbSetOrder(1)
If lProcCriad
	If TCSPExist( cAliasProc )
		DelProc(cAliasProc)
		cAliasProc := NIL
	EndIf
EndIf	

SM0->(dbGoTo(nRegEmp))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

//Acerta a database de acordo com a database real do sistema
dDataBase := dOldDtBase

Return


Static Function SubTot130R(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,nDecs,oReport,aDados,oSection)

Local cQuebra := ""
Local cCarteira	:= ""

If nOrdem = 1
	//mv_par29 - Imprime Nome?
	cQuebra := If(mv_par29 == 1,Substr(SA1->A1_NREDUZ,1,30),Substr(SA1->A1_NOME,1,30)) + " " + STR0054 + Right(cCarAnt,2)+Iif(mv_par21==1,STR0055+cFilAnt + " - " + Alltrim(SM0->M0_FILIAL),"")//"Loja - "###" Filial - "
Elseif nOrdem == 4 .or. nOrdem == 6
	cQuebra := PadR(STR0037,28) + DtoC(cCarAnt) + "  " + If(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"  ")
Elseif nOrdem = 3
	cQuebra := PadR(STR0037,28) + If(Empty(SA6->A6_NREDUZ),STR0029,SA6->A6_NREDUZ) + " " + If(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
ElseIf nOrdem == 5 //por Natureza
	SED->( dbSetOrder( 1 ) )
	SED->( dbSeek(cFilial+cCarAnt) )
	cQuebra := PadR(STR0037,28) + cCarAnt + " "+Substr(SED->ED_DESCRIC,1,40) + " " + If(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
Elseif nOrdem == 7
	cQuebra := PadR(STR0037,28) + SubStr(cCarAnt,7,2)+"/"+SubStr(cCarAnt,5,2)+"/"+SubStr(cCarAnt,3,2)+" - "+SubStr(cCarAnt,9,3) + " " +Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
ElseIf nOrdem = 8
   	cQuebra := SA1->A1_COD+" "+Substr(SA1->A1_NOME,1,30) + " " + Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
ElseIf nOrdem = 9
	cCarteira := Situcob(cCarAnt)
	cQuebra := SA6->A6_COD+" "+SA6->A6_NREDUZ + " "+SubStr(cCarteira,3,20) + " " + Iif(mv_par21==1,cFilAnt + " - " + Alltrim(SM0->M0_FILIAL),"")
Endif

if !lImpSintTbl
	HabiCel(oReport, ( nOrdem == 5 .And. MV_MULNATR ) )
EndIf

oSection:Cell("QUEBRA"   ):SetBlock({|| cQuebra})
oSection:Cell("TOT_NOMI" ):SetBlock({|| nTit1  })
oSection:Cell("TOT_CORR" ):SetBlock({|| nTit2  })
oSection:Cell("TOT_VENC" ):SetBlock({|| nTit3  })
oSection:Cell("TOT_SOMA" ):SetBlock({|| nTit2+nTit3})
oSection:Cell("TOT_JUROS"):SetBlock({|| nTotJur})

oSection:PrintLine()

Return .T.


STATIC Function TotGer130R(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nDecs,oReport,aDados,oSection,cTexto)

DEFAULT nDecs := Msdecimais(mv_par15)
DEFAULT cTexto	:= ""		/* GESTAO */

HabiCel(oReport)
/*
GESTAO - inicio */
If Empty(cTexto)
oSection:Cell("QUEBRA"   ):SetBlock({|| STR0038 +"("+ AllTrim(Str(nTotTit)) +" "+ If(nTotTit > 1, STR0039, STR0040) +")"}) //"TOTAL"
Else
	oSection:Cell("QUEBRA"   ):SetBlock({|| cTexto}) //"TOTAL"
Endif
/* GESTAO - fim
*/
oSection:Cell("QUEBRA"   ):SetBlock({|| STR0038 +"("+ AllTrim(Str(nTotTit)) +" "+ If(nTotTit > 1, STR0039, STR0040) +")"}) //"TOTAL"
oSection:Cell("TOT_NOMI" ):SetBlock({|| nTot1  })
oSection:Cell("TOT_CORR" ):SetBlock({|| nTot2  })
oSection:Cell("TOT_VENC" ):SetBlock({|| nTot3  })
oSection:Cell("TOT_SOMA" ):SetBlock({|| If(lImpSintTbl, nTotal, (nTot2+nTot3))})
oSection:PrintLine()

Return .T.


STATIC Function IMes130R(nMesTot0,nMesTot1,nMesTot2,nMesTot3,nMesTot4,nMesTTit,nMesTotJ,nDecs,oReport,aDados,oSection)

HabiCel(oReport)

oSection:Cell("QUEBRA"   ):SetBlock({|| PadR(STR0041,28) + "("+ALLTRIM(STR(nMesTTit))+" "+IIF(nMesTTit > 1,OemToAnsi(STR0039),OemToAnsi(STR0040))+")"})
oSection:Cell("TOT_NOMI" ):SetBlock({|| nMesTot1})
oSection:Cell("TOT_CORR" ):SetBlock({|| nMesTot2})
oSection:Cell("TOT_VENC" ):SetBlock({|| nMesTot3})
oSection:Cell("TOT_SOMA" ):SetBlock({|| nMesTot2+nMesTot3})

oSection:PrintLine()

Return(.T.)


STATIC Function IFil130R(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ,nDecs,oReport,aDados,oSection)

HabiCel(oReport)

oSection:Cell("QUEBRA"   ):SetBlock({|| STR0043 + " " + If(mv_par21==1,cFilAnt+" - " + AllTrim(SM0->M0_FILIAL),"")})  //"T O T A L   F I L I A L ----> "
oSection:Cell("TOT_NOMI" ):SetBlock({|| nTotFil1})
oSection:Cell("TOT_CORR" ):SetBlock({|| nTotFil2})
oSection:Cell("TOT_VENC" ):SetBlock({|| nTotFil3})
oSection:Cell("TOT_JUROS"  ):SetBlock({|| nTotFilJ})
oSection:Cell("TOT_SOMA" ):SetBlock({||nTotFil2+nTotFil3})

If mv_par19 == 1 // 1 = Analitico - 2 = Sintetico
	aDados[VL_ORIG] := nTotFil0
Endif

oSection:PrintLine()

Return .T.


STATIC Function HabiCel(oReport, lMultNat)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)

Default lMultNat := .F.

If mv_par19 == 1 //1 =  Analitico - 2 = Sintetico
	If !lMultNat .And. !lImpSintTbl
		oSection1:Cell("CLIENTE"   ):SetSize(50)
		oSection1:Cell("TITULO"    ):Disable()
		oSection1:Cell("E1_TIPO"   ):Hide()
		oSection1:Cell("E1_NATUREZ"):Hide()
		oSection1:Cell("E1_EMISSAO"):Hide()
		oSection1:Cell("E1_VENCTO" ):Hide()
		oSection1:Cell("E1_VENCREA"):Hide()
		oSection1:Cell("VAL_ORIG"  ):Hide()
		oSection1:Cell("BANCO"     ):Hide()
		oSection1:Cell("DIA_ATR"   ):Hide()
		oSection1:Cell("E1_HIST"   ):Disable()
		oSection1:Cell("VAL_SOMA"  ):Enable()

		oSection1:Cell("CLIENTE"   ):HideHeader()
		oSection1:Cell("E1_TIPO"   ):HideHeader()
		oSection1:Cell("E1_NATUREZ"):HideHeader()
		oSection1:Cell("E1_EMISSAO"):HideHeader()
		oSection1:Cell("E1_VENCTO" ):HideHeader()
		oSection1:Cell("E1_VENCREA"):HideHeader()
		oSection1:Cell("VAL_ORIG"  ):HideHeader()
		oSection1:Cell("BANCO"     ):HideHeader()
		oSection1:Cell("DIA_ATR"   ):HideHeader()
	EndIf
Else
	oSection2:Cell("QUEBRA"   ):SetSize(100)
Endif

Return(.T.)


Static Function fr130IndR()
Local cString

cString := 'SE1->E1_FILIAL=="'+xFilial("SE1")+'".And.'
cString += 'SE1->E1_CLIENTE>="'+mv_par01+'".and.SE1->E1_CLIENTE<="'+mv_par02+'".And.'
cString += 'SE1->E1_PREFIXO>="'+mv_par03+'".and.SE1->E1_PREFIXO<="'+mv_par04+'".And.'
cString += 'SE1->E1_NUM>="'+mv_par05+'".and.SE1->E1_NUM<="'+mv_par06+'".And.'
cString += 'DTOS('+Iif(mv_par40 = 2, 'SE1->E1_VENCTO', 'SE1->E1_VENCREA')+')>="'+DTOS(mv_par09)+'".And.'
cString += 'DTOS('+Iif(mv_par40 = 2, 'SE1->E1_VENCTO', 'SE1->E1_VENCREA')+')<="'+DTOS(mv_par10)+'".And.'
cString += '(SE1->E1_MULTNAT == "1" .OR. (SE1->E1_NATUREZ>="'+mv_par11+'".and.SE1->E1_NATUREZ<="'+mv_par12+'")).And.'
cString += 'DTOS(SE1->E1_EMISSAO)>="'+DTOS(mv_par13)+'".and.DTOS(SE1->E1_EMISSAO)<="'+DTOS(mv_par14)+'"'
If !Empty(mv_par31) // Deseja imprimir apenas os tipos do parametro 31
	cString += '.And.SE1->E1_TIPO$"'+mv_par31+'"'
ElseIf !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
	cString += '.And. !(Alltrim(SE1->E1_TIPO) $ "'+ ALLTRIM(MV_PAR32)+'")'
EndIf
IF mv_par34 == 1  // Apenas titulos que estarao no fluxo de caixa
	cString += '.And.(SE1->E1_FLUXO!="N")'
Endif
Return cString


Static Function SituCob(cCarAnt)
Local aArea		:= GetArea()
Local cCart		:= " "

If !Empty(cCarAnt)
	cCart := cCarAnt+" "+Substr(FN022SITCB( SE1->E1_SITUACA )[9],1,20)
Else
	cCart := "0 "+STR0029
Endif
RestArea(aArea)
Return cCart


Static Function SumAbatPCC(cPrefixo,cNumero,cParcela,dDataRef,cCodCli,cLoja,nMoeda)

Local cAlias	:= Alias()
Local nOrdem	:= indexord()
Local cQuery	:= ""
Local nTotPcc	:= 0

DEFAULT nMoeda	:= 1



	cQryAlias := GetNextAlias()

	cQuery	:= " SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_EMISSAO, E1_VALOR, E1_TXMOEDA, E1_MOEDA, E1_TITPAI, R_E_C_N_O_ RECNO "
	cQuery	+= " FROM "+RetSqlName("SE1")
	cQuery	+= " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND "
	cQuery	+= " E1_PREFIXO = '"+cPrefixo+"' AND "
	cQuery	+= " E1_NUM = '"+cNumero+"' AND "
	cQuery	+= " E1_CLIENTE = '"+cCodCli+"' AND "
	cQuery	+= " E1_LOJA = '"+cLoja+"' AND "
	cQuery	+= " E1_TIPO IN ('" + MVPIS + "','" + MVCOFINS + "','CSL'"
	If SA1->A1_TPESSOA == 'EP'
		cQuery	+= ",'" + MVIRF + "', '" + MVINSS + "') AND "
	Else
		cQuery	+= ") AND "
	EndIf
	cQuery	+= " E1_EMISSAO <= '"+Dtos(dDataRef)+"' AND "
	cQuery	+= " D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias , .F., .T.)

	While (cQryAlias)->( !Eof() )
		If FTITRAPAI((cQryAlias)->E1_TITPAI) //Verifica se o Titulo PAI e um RA e nao abate o PCC
			nTotPcc += xMoeda((cQryAlias)->E1_VALOR,(cQryAlias)->E1_MOEDA,nMoeda,dDataRef,,If(cPaisLoc=="BRA",(cQryAlias)->E1_TXMOEDA,0))
		EndIf
		(cQryAlias)->(dbSkip())
	EndDo

	(cQryAlias)->(dbCloseArea())


DbSelectArea(cAlias)
DbSetOrder(nOrdem)

Return(nTotPcc)

/*
?
?
?
rograma  ?FR130RetNat utor ?Gustavo Henrique  ?Data ?25/05/10   ?
?
escricao ?Retorna codigo e descricao da natureza para quebra do      ?
?         ?relatorio analitico por ordem de natureza.                 ?
?
arametros?EXPC1 - Codigo da natureza para pesquisa                   ?
?
so       ?Financeiro                                                 ?
?
?
?
*/
Static Function FR130RetNat( cCodNat )

SED->( dbSetOrder( 1 ) )
SED->( MsSeek( xFilial("SED") + cCodNat ) )

Return( MascNat(SED->ED_CODIGO) + " - " + SED->ED_DESCRIC + If( mv_par21==1, cFilAnt + " - " + Alltrim(SM0->M0_FILIAL), "" ) )


/*
?
?
?
rograma  ?FR130TotSoma utor ?Gustavo Henrique ?Data ?05/26/10   ?
?
escricao ?Totaliza somatoria da coluna (Vencidos+A Vencer) quando    ?
?         ?selecionado relatorio por ordem de natureza e parametro    ?
?         ?MV_MULNATR ativado.                                        ?
?
so       ?Financeiro                                                 ?
?
?
?
*/
Static Function FR130TotSoma( oTotCorr, oTotVenc, nTotVenc, nTotGeral, nOrdem )



Return .T.

Static Function Fr130Cond(cTipos)
Local lRet := .T.
Local dDtContab
Local aArea		:= getArea()
Local aResult	:= {}
Local lProc		:= cAliasProc <> Nil

DEFAULT _nTamSEQ	:= TAMSX3('E5_SEQ')[1]
// dDtContab para casos em que o campo E1_EMIS1 esteja vazio
dDtContab := Iif(Empty(SE1->E1_EMIS1),SE1->E1_EMISSAO,SE1->E1_EMIS1)


Do Case
Case !Empty(SE1->E1_BAIXA)
	If mv_par20 == 2 .and. SE1->E1_SALDO == 0
		lRet := .F.
	Elseif SE1->E1_SALDO == 0

		If ( MV_PAR37 == 1 ) .and. SE1->E1_BAIXA <= dDataBase
			lRet := .F.
		ElseIf !(cDBType $ "DB2|POSTGRES") .AND. ( ( MV_PAR37 == 2 ) .Or. ( MV_PAR37 == 3 ) ) .AND. !(SE1->E1_TIPO $ MVABATIM)
			If cAliasProc == NIL
				cAliasProc	:= CriaTrab(Nil,.F.)
				cAliasProc:= cAliasProc+"_FR130_"+cEmpAnt
				If TCSPExist( cAliasProc ) .And. !lProcCriad
					DelProc(cAliasProc)					
				EndIf				
									
				lProc := CriaProc(cAliasProc)					
				lProcCriad := lProc						
				
			Else
				If TCSPExist( cAliasProc )
					lProcCriad := .T.
				EndIf
			Endif
			If lProc .AND. TCSPExist( cAliasProc )
				aResult := TCSPExec( cAliasProc , MV_PAR37, SE1->E1_FILIAL ,SE1->E1_PREFIXO ,SE1->E1_NUM ,;
								SE1->E1_PARCELA ,SE1->E1_TIPO ,SE1->E1_CLIENTE ,SE1->E1_LOJA )

				If !Empty(aResult)
					lRet := Iif(StoD(aResult[1]) <= dDataBase, .F., .T.)
				Else
				    MsgInfo('Erro na execu'+chr(29602)+'o da Stored Procedure : '+TcSqlError())				    
				    conout(TcSqlError())
				Endif
			Endif
		Endif
	Endif

Case (MV_PAR33 == 3 .AND. SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT)
	lRet := .F.

Case SE1->E1_TIPO $ MVPROVIS .and. mv_par16 == 2
	lRet := .F.

Case SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .and. mv_par26 == 2
	lRet := .F.
Case !Empty(cTipos)
	If !(SE1->E1_TIPO $ cTipos)
	   lRet := .F.
	Endif
Case mv_par30 == 2 // nao imprime
	
	If SE1->E1_MOEDA != mv_par15 // verifica moeda do campo=moeda parametro
		lRet := .F.
	Endif
EndCase

If !Empty(SE1->E1_BAIXA)
	
	If !lRet .and. (MV_PAR37 == 2 .OR. MV_PAR37 == 3)  .and. mv_par26 == 1 .and. mv_par20 == 1 .and. allTrim(SE1->E1_TIPO) $ MVABATIM .and. SE1->E1_BAIXA >= dDataBase
		lRet := .T.	 	
	EndIf
EndIf

RestArea(aArea)

Return lRet


Static Function F130RETIMP(cFiltro)

Local aTitulos := {}
Local aAreaSE1	:= SE1->(GetArea())

dbSelectArea("SED")
dbSetOrder(1)
If DbSeek (xFilial("SED")+cFiltro)
	If SED->ED_CALCIRF=="S"
     	AADD(aTitulos,{MVIRABT, .T.})
 	EndIf
   	If SED->ED_CALCINS=="S"
       	AADD(aTitulos,{MVINABT,.T.})
   	EndIf
 	If SED->ED_CALCPIS=="S"
    	 AADD(aTitulos,{MVPIABT,.T.})
 	EndIf
   	If SED->ED_CALCCOF=="S"
     	AADD(aTitulos,{MVCFABT,.T.})
 	EndIf
   	If SED->ED_CALCCSL=="S"
     	AADD(aTitulos,{MVCSABT,.T.})
   	EndIf
 	If SED->ED_CALCISS=="S"
     	AADD(aTitulos,{MVISABT,.T.})
	EndIf
EndIf

RestArea(aAreaSE1)

Return aTitulos



Static Function FTITPAI()
Local cAlias := Alias()
Local cTitP
Local cQuery 

cQuery := "SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA FROM "
cQuery += RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'"
cQuery += " AND E1_CLIENTE  = '"+SE1->E1_CLIENTE+"'"
cQuery += " AND E1_LOJA     = '"+SE1->E1_LOJA+"'"
cQuery += " AND E1_PREFIXO  = '"+SE1->E1_PREFIXO+"'"
cQuery += " AND E1_NUM      = '"+SE1->E1_NUM+"'"
cQuery += " AND E1_PARCELA  = '"+SE1->E1_PARCELA+"'"
cQuery += " AND E1_TIPO NOT IN " + F130MontaIn()
cQuery += " AND D_E_L_E_T_  = ' ' "
cQuery += " ORDER BY "+SqlOrder(__SE1->(IndexKey(2)))

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'FTITPAI',.T.,.T.)

If FTITPAI->(!Eof())
	cTitP := PADR(FTITPAI->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),TAMSX3('E1_TITPAI')[1])
EndIf 

FTITPAI->(dbCloseArea())
dbSelectArea(cAlias)

Return cTitP

/*
?
?
?
rograma  130TipoBAutor  icrosiga           ?Data ? 13/08/12   ?
?
esc.     ?Rotina para buscar na SE5 quando titulo eh tipo RA para    ?
?         ?verificar a data de cancelamento que sera gravado no       ?
?         ?campo E5_HIST entre ###[AAAAMMDD]### a fim de compor o     ?
?         ?saldo adequadamente                                        ?
?
so       ?AP                                                         ?
?
?
?
*/


STATIC Function F130TipoBA()
Local aSavArea := GetArea()
Local nPosDtCanc := 0
Local nValor := 0
Local cQuery 

cQuery := "SELECT E5_DATA, E5_HISTOR, E5_VALOR FROM "
cQuery += RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '"+xFilial("SE5")+"'"
cQuery += " AND E5_PREFIXO = '"+SE1->E1_PREFIXO+"'"
cQuery += " AND E5_NUMERO  = '"+SE1->E1_NUM+"'"
cQuery += " AND E5_PARCELA = '"+SE1->E1_PARCELA+"'"
cQuery += " AND E5_TIPO    = '"+SE1->E1_TIPO+"'"
cQuery += " AND E5_CLIFOR  = '"+SE1->E1_CLIENTE+"'"
cQuery += " AND E5_LOJA    = '"+SE1->E1_LOJA+"'"
cQuery += " AND E5_DATA   <= '"+dTos(mv_par36)+"'"
cQuery += " AND E5_TIPODOC = 'BA'"
cQuery += " AND E5_SITUACA = 'C' "
cQuery += " AND E5_HISTOR LIKE '%###[%'"
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'F130TipoBA',.T.,.T.)

While F130TipoBA->(!EOF()) 
	nPosDtCanc := At("###[", F130TipoBA->E5_HISTOR) 
	If STOD(SUBS(F130TipoBA->E5_HISTOR, nPosDtCanc+4,8)) > MV_PAR36
		nValor := F130TipoBA->E5_VALOR
		Exit
	EndIf
	F130TipoBA->(dbSkip())
EndDo

F130TipoBA->(dbCloseArea())

RestArea(aSavArea)

Return nValor

/*
?
?
?
rograma  TITRAPAI utor  elso Carneiro      ?Data ? 15/08/12   ?
?
esc.     ?Verifica se o titulo de abatimento no campo E1_TITPAI e    ?
?         ?RA                                                         ?
?
so       ?FINR130                                                    ?
?
?
?
*/

Static Function FTITRAPAI(cTITPAI)
Local aArea    := GetArea()
Local lRet     := .T.
Local nTamPref := 0
Local nTamNum  := 0
Local nTamParc := 0
Local nTamTipo := 0
Local cTipo    := ""

Local lRaRtImp := FRaRtImp()

If !Empty(cTITPAI) .And. lRaRtImp
	nTamFil  := TAMSX3('E1_FILIAL')[1]
	nTamPref := TAMSX3('E1_PREFIXO')[1]
	nTamNum  := TAMSX3('E1_NUM')[1]
	nTamParc := TAMSX3('E1_PARCELA')[1]
	nTamTipo := TAMSX3('E1_TIPO')[1]
	cTipo    := Subs(cTITPAI,(1+nTamPref+nTamNum+nTamParc),nTamTipo)

	If cTipo $ MVRECANT // Titulo pai e um RA
		lRet := .F.
	EndIf
EndIf
RestArea(aArea)


Return lRet

Static Function CriaProc(cAliasProc)

Local __cTamFil := StrZero(TamSx3("E1_FILIAL")[1],3)
Local __cTamPre := StrZero(TamSx3("E1_PREFIXO")[1],3)
Local __cTamNum := StrZero(TamSx3("E1_NUM")[1],3)
Local __cTamPar := StrZero(TamSx3("E1_PARCELA")[1],3)
Local __cTamTip := StrZero(TamSx3("E1_TIPO")[1],3)
Local __cTamCli := StrZero(TamSx3("E1_CLIENTE")[1],3)
Local __cTamLoj := StrZero(TamSx3("E1_LOJA")[1],3)
Local __nTamSeqData  := ( TamSx3("E5_SEQ")[1] + 8)
Local __nTamSeq  := ( TamSx3("E5_SEQ")[1] )
Local __cTamSeqData  := StrZero( ( __nTamSeq + 8 ) ,3)
Local cQuery	:= ""
Local lOk		:= .T.
Local nPTratRec	:= 0
Local := cFilSE5		:= xFilial("SE5")
Local := cFilSE1		:= xFilial("SE1")
Local := lVerCmpFil	:= !Empty(cFilSE1) .And. !Empty(cFilSE5)

cQuery += "create procedure "+cAliasProc+" ("+CRLF
cQuery += "	@IN_TIPDATA	integer ,"+CRLF
cQuery += "	@IN_FILIAL	char(" 	+ __cTamFil + "),"+CRLF
cQuery += "	@IN_PREFIXO	char(" 	+ __cTamPre + "),"+CRLF
cQuery += "	@IN_NUMERO	char(" 	+ __cTamNum + "),"+CRLF
cQuery += "	@IN_PARCELA	char(" 	+ __cTamPar + "),"+CRLF
cQuery += "	@IN_TIPO	char(" 	+ __cTamTip + "),"+CRLF
cQuery += "	@IN_CLIENTE	char(" 	+ __cTamCli + "),"+CRLF
cQuery += "	@IN_LOJA	char(" 	+ __cTamLoj + "),"+CRLF
cQuery += "	@OUT_RET	char(8) output"+CRLF
cQuery += ") as"+CRLF
cQuery += " " + CRLF

cQuery += "Declare @cFilial Varchar(" 	+ __cTamFil + ")" + CRLF
cQuery += "Declare @cPrefixo Varchar(" 	+ __cTamPre + ")" + CRLF
cQuery += "Declare @cNumero Varchar(" 	+ __cTamNum + ")" + CRLF
cQuery += "Declare @cParcela Varchar(" 	+ __cTamPar + ")" + CRLF
cQuery += "Declare @cTipo Varchar(" 	+ __cTamTip + ")" + CRLF
cQuery += "Declare @cCliente Varchar(" 	+ __cTamCli + ")" + CRLF
cQuery += "Declare @cLoja Varchar(" 	+ __cTamLoj + ")" + CRLF
cQuery += "Declare @cRetSQLSE1 char(3)" + CRLF
cQuery += "Declare @cRetSQLSE5 char(3)" + CRLF
cQuery += "Declare @cMaxDt Varchar("	+__cTamSeqData+")"+ CRLF

cQuery += " " + CRLF
cQuery += "Begin " + CRLF
cQuery += "   " + CRLF

cQuery += "   select @cFilial = @IN_FILIAL" + CRLF
cQuery += "   select @cPrefixo = @IN_PREFIXO " + CRLF
cQuery += "   select @cNumero = @IN_NUMERO" + CRLF
cQuery += "   select @cParcela = @IN_PARCELA" + CRLF
cQuery += "   select @cTipo = @IN_TIPO" + CRLF
cQuery += "   select @cCliente = @IN_CLIENTE" + CRLF
cQuery += "   select @cLoja = @IN_LOJA" + CRLF
cQuery += "   select @cMaxDt = ''" + CRLF
cQuery += "   select @OUT_RET  = ' ' " + CRLF

cQuery += "   "+CRLF

cQuery += "IF (@IN_TIPDATA  > 0) " + CRLF
cQuery += "BEGIN " + CRLF
cQuery += "	IF @IN_TIPDATA = 1 " + CRLF
cQuery += "		SELECT @cMaxDt = IsNull(MAX(B.E5_DATA),' ') FROM " + RetSqlName("SE1") + " SE1, " + RetSqlName("SE5") +" B " + CRLF
cQuery += "		WHERE SE1.E1_FILIAL  = @cFilial  and SE1.E1_PREFIXO  = @cPrefixo  and SE1.E1_NUM  = @cNumero  and SE1.E1_PARCELA  = @cParcela " + CRLF 
cQuery += "		and SE1.E1_TIPO  = @cTipo  and SE1.E1_CLIENTE  = @cCliente  and SE1.E1_LOJA  = @cLoja  and SE1.D_E_L_E_T_  = ' ' " + CRLF 
cQuery += "		and B.D_E_L_E_T_  = ' '  and "
If ( mv_par41 == 1 ) .and. lVerCmpFil
	cQuery += "B.E5_FILORIG  = SE1.E1_FILIAL "
Else
	cQuery += "B.E5_FILIAL  = SE1.E1_FILIAL "
Endif
cQuery += "and B.E5_PREFIXO  = SE1.E1_PREFIXO  and B.E5_NUMERO  = SE1.E1_NUM " + CRLF 
cQuery += "		and B.E5_PARCELA  = SE1.E1_PARCELA  and B.E5_TIPO  = SE1.E1_TIPO  and B.E5_CLIFOR  = SE1.E1_CLIENTE  and B.E5_LOJA  = SE1.E1_LOJA " + CRLF			

cQuery += "	ELSE IF @IN_TIPDATA = 2 " + CRLF
cQuery += "		SELECT @cMaxDt = IsNull(MAX(B.E5_DTDISPO),' ') FROM " + RetSqlName("SE1") + " SE1," + RetSqlName("SE5") + " B " + CRLF
cQuery += "		WHERE SE1.E1_FILIAL  = @cFilial  and SE1.E1_PREFIXO  = @cPrefixo  and SE1.E1_NUM  = @cNumero  and SE1.E1_PARCELA  = @cParcela " + CRLF 
cQuery += "		and SE1.E1_TIPO  = @cTipo  and SE1.E1_CLIENTE  = @cCliente  and SE1.E1_LOJA  = @cLoja  and SE1.D_E_L_E_T_  = ' ' " + CRLF 
cQuery += "		and B.D_E_L_E_T_  = ' '  and "
If ( mv_par41 == 1 ) .and. lVerCmpFil
	cQuery += "B.E5_FILORIG  = SE1.E1_FILIAL "
Else
	cQuery += "B.E5_FILIAL  = SE1.E1_FILIAL "
Endif
cQuery += "and B.E5_PREFIXO  = SE1.E1_PREFIXO  and B.E5_NUMERO  = SE1.E1_NUM " + CRLF 
cQuery += "		and B.E5_PARCELA  = SE1.E1_PARCELA  and B.E5_TIPO  = SE1.E1_TIPO  and B.E5_CLIFOR  = SE1.E1_CLIENTE  and B.E5_LOJA  = SE1.E1_LOJA " + CRLF

cQuery += "	ELSE " + CRLF
cQuery += "		SELECT @cMaxDt = IsNull(MAX(B.E5_DTDIGIT),' ') FROM " + RetSqlName("SE1") + " SE1," + RetSqlName("SE5") + " B " + CRLF
cQuery += "		WHERE SE1.E1_FILIAL  = @cFilial  and SE1.E1_PREFIXO  = @cPrefixo  and SE1.E1_NUM  = @cNumero  and SE1.E1_PARCELA  = @cParcela " + CRLF 
cQuery += "		and SE1.E1_TIPO  = @cTipo  and SE1.E1_CLIENTE  = @cCliente  and SE1.E1_LOJA  = @cLoja  and SE1.D_E_L_E_T_  = ' ' " + CRLF 
cQuery += "		and B.D_E_L_E_T_  = ' '  and "
If ( mv_par41 == 1 ) .and. lVerCmpFil
	cQuery += "B.E5_FILORIG  = SE1.E1_FILIAL "
Else
	cQuery += "B.E5_FILIAL  = SE1.E1_FILIAL "
Endif
cQuery += "and B.E5_PREFIXO  = SE1.E1_PREFIXO  and B.E5_NUMERO  = SE1.E1_NUM " + CRLF   
cQuery += "		and B.E5_PARCELA  = SE1.E1_PARCELA  and B.E5_TIPO  = SE1.E1_TIPO  and B.E5_CLIFOR  = SE1.E1_CLIENTE  and B.E5_LOJA  = SE1.E1_LOJA " + CRLF						
cQuery += "END " + CRLF		

cQuery += "SELECT @OUT_RET  = @cMaxDt " + CRLF
cQuery += "END" + CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", cDBType ) )
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cAliasProc )
	lOk := FinSqlExec(cQuery)
	If !lOk
		UserException( "Erro na cria"+chr(29602)+"o da procedure " + CRLF + TCSqlError()  + CRLF + cQuery )  //
	Endif
EndIf

Return lOk


Static Function FinSqlExec( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno := .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		UserException( "Erro na instru"+chr(29602)+"o de execu"+chr(29602)+"o SQL" + CRLF + TCSqlError()  + CRLF + cStatement )  //
		lRetorno := .F.
	Endif
RECOVER
	lRetorno := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRetorno


STATIC Function	DelProc(cAliasProc)

FinSqlExec( "Drop procedure "+ cAliasProc )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FR130DBX

Busca a data da ultima baixa realizada do titulo a receber at?a
DataBase do sistema.

@author leonardo.casilva

@since 11/04/2014
@version P1180
 
@return
/*/
//-------------------------------------------------------------------
Static Function FR130DBX()

Local dDataRet := SE1->E1_VENCREA
Local cQuery	 := "SELECT"

cQuery += " MAX(SE5.E5_DATA) DBAIXA"
cQuery += " FROM "+ RetSQLName( "SE5" ) + " SE5 "
cQuery += " WHERE SE5.E5_FILIAL = '" + xFilial("SE5")  + "' " 
cQuery += " AND SE5.E5_PREFIXO = '" + SE1->E1_PREFIXO	 + "'"
cQuery += " AND SE5.E5_NUMERO = '"  + SE1->E1_NUM		 + "'"
cQuery += " AND SE5.E5_PARCELA = '" + SE1->E1_PARCELA	 + "'"
cQuery += " AND SE5.E5_TIPO = '" 	 + SE1->E1_TIPO	 	 + "'"
cQuery += " AND SE5.E5_CLIFOR = '"  + SE1->E1_CLIENTE	 + "'"
cQuery += " AND SE5.E5_LOJA = '"	 + SE1->E1_LOJA	 	 + "'"
cQuery += " AND SE5.E5_TIPODOC = 'VL'"
cQuery += " AND SE5.E5_DATA <= '" + DTOS(dDataBase) + "'"  
cQuery += " AND SE5.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBDATA",.T.,.T.)

If TRBDATA->(!EOF())
	If !Empty(AllTrim(TRBDATA->DBAIXA))
		dDataRet := STOD(TRBDATA->DBAIXA)
	Endif
EndIf
TRBDATA->(dbCloseArea())

Return dDataRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FR130InFilial

Formata uma string com todas as filiais selecionadas pelo usuario,
para que seja usada no parametro "IN" da query

@author daniel.mendes

@since 19/05/2014
@version P12
 
@return Retorna uma string com as filiais selecionadas
/*/
//-------------------------------------------------------------------
Static Function FR130InFilial()
Local cRetornoIn := ""
Local nFor := 0

	For nFor := 1 To Len(aSelFil)
		cRetornoIn += aSelFil[nFor] + '|' 
	Next nFor

Return " IN " + FormatIn( SubStr( cRetornoIn , 1 , Len( cRetornoIn ) -1 ) , '|' )

/*
?
?
?
rograma  ashNatur  ?Ronaldo Tapia             ?Data ? 05/04/16   ?
?
esc.     ?Faz querypara verificar se existe abatimento para determi- ?
?         ?cliente                                                   .?
?
so       ?AP                                                         ?
?
?
?
*/ 
Static Function CliPerdaAno(cCliente, dDataBase)

	Local cQuery 
	Local cCodEmpOri
	Local cDataBase
	Local contador
	cCodEmpOri := FWCodEmp()
	cDataBase := DTOS(dDataBase)
	contador  := 0
	
	cQuery := " SELECT COUNT(*) CONT FROM "
	cQuery += " ZAJ010 a "
	cQuery += " WHERE a.ZAJ_CLIENT = '"+cCliente+"'"
	cQuery += "   AND DATEPART(YEAR, a.ZAJ_DATA) = YEAR('"+cDataBase+"') and a.ZAJ_SITANT = '1' and a.ZAJ_SITATU = '2'"
	cQuery += "   AND a.ZAJ_DATA = (SELECT MAX(z.ZAJ_DATA) from ZAJ010 z where z.ZAJ_CLIENT = '"+cCliente+"' AND	DATEPART(YEAR, z.ZAJ_DATA) = YEAR('"+cDataBase+"')  )"
	If chkfile("TITPOS")
		dbSelectArea("TITPOS")
		dbCloseArea()
	EndIf
	
	TcQuery cQuery New Alias "TITPOS"

	While !TITPOS->(Eof())
		if TITPOS->CONT > 0
			contador += TITPOS->CONT
		end if
		
		TITPOS->(DbSkip())
	EndDo
  TITPOS->(DbCloseArea())
  

Return contador

Static Function ExcTitMes(dDataBase)

	Local cQuery 
	Local cCodEmpOri
	Local cDataBase

	cCodEmpOri := FWCodEmp()
	cDataBase := DTOS(dDataBase)
	  
	cQuery := " DELETE FROM "
	cQuery += " __BI_PB_CREPERDA  "
	cQuery += " WHERE EMPORIGEM = '"+cCodEmpOri+"'"
	cQuery += "   AND MONTH(DATA_BASE) = MONTH('"+cDataBase+"')"
	cQuery += "   AND YEAR(DATA_BASE) = YEAR('"+cDataBase+"')"
	
	TcSqlExec(cQuery)

Return

Static Function TitPos(cCliente, cDataBase)

Local cQuery 
Local vlTotal := 0


	cQuery := " SELECT SUM(SE1.E1_SALDO) SALDO FROM "
	cQuery += " SE1010 SE1 "
	cQuery += " WHERE SE1.E1_CLIENTE = '"+cCliente+"'"
	cQuery += "   AND SE1.E1_TIPO not in ('TEL', 'BOL', 'NDC', 'JP', 'PA', 'RC', 'RA')"
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += " UNION ALL "
	cQuery += " SELECT SUM(SE1.E1_SALDO) SALDO FROM "
	cQuery += " SE1050 SE1 "
	cQuery += " WHERE  SE1.E1_CLIENTE = '"+cCliente+"'"
	cQuery += "   AND SE1.E1_TIPO not in ('TEL', 'BOL', 'NDC', 'JP', 'PA', 'RC', 'RA')"
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += " UNION ALL "
	cQuery += " SELECT SUM(SE1.E1_SALDO) SALDO FROM "
	cQuery += " SE1070 SE1 "
	cQuery += " WHERE  SE1.E1_CLIENTE = '"+cCliente+"'"
	cQuery += "   AND SE1.E1_TIPO not in ('TEL', 'BOL', 'NDC', 'JP', 'PA', 'RC', 'RA')"
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += " UNION ALL "
	//Valores baixados após a data base serão somados ao saldo daquela data
	cQuery += " SELECT SUM(SE1.E1_VALOR-SE1.E1_SALDO) SALDO FROM "
	cQuery += " SE1010 SE1 "
	cQuery += " WHERE SE1.E1_CLIENTE = '"+cCliente+"'"
	cQuery += "   AND SE1.E1_TIPO not in ('TEL', 'BOL', 'NDC', 'JP', 'PA', 'RC', 'RA')"
	cQuery += "   AND SE1.E1_BAIXA >=  '"+cDataBase+"'"
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += " UNION ALL "
	cQuery += " SELECT SUM(SE1.E1_VALOR-SE1.E1_SALDO) SALDO FROM "
	cQuery += " SE1050 SE1 "
	cQuery += " WHERE SE1.E1_CLIENTE = '"+cCliente+"'"
	cQuery += "   AND SE1.E1_TIPO not in ('TEL', 'BOL', 'NDC', 'JP', 'PA', 'RC', 'RA')"
	cQuery += "   AND SE1.E1_BAIXA >=  '"+cDataBase+"'"
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += " UNION ALL "
	cQuery += " SELECT SUM(SE1.E1_VALOR-SE1.E1_SALDO) SALDO FROM "
	cQuery += " SE1070 SE1 "
	cQuery += " WHERE SE1.E1_CLIENTE = '"+cCliente+"'"
	cQuery += "   AND SE1.E1_TIPO not in ('TEL', 'BOL', 'NDC', 'JP', 'PA', 'RC', 'RA')"
	cQuery += "   AND SE1.E1_BAIXA >=  '"+cDataBase+"'"
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	
	If chkfile("TITPOS")
		dbSelectArea("TITPOS")
		dbCloseArea()
	EndIf
	
	TcQuery cQuery New Alias "TITPOS"

	While !TITPOS->(Eof())
		if TITPOS->SALDO > 0
			vlTotal += TITPOS->SALDO
		end if
		
		TITPOS->(DbSkip())
	EndDo
  TITPOS->(DbCloseArea())

Return vlTotal


Static Function CliInPerda(cCliente, dtBase)

Local cQuery 
// 

Local binPerda := .F.
/*
	cQuery := " SELECT COUNT(*) CONT FROM"
	cQuery += " __BI_PB_CREPERDA "
	cQuery += " WHERE BK_CLIENTE = '"+cCliente+"'"
	cQuery += " AND DATA_BASE = '"+ dtBase +"' "
	If chkfile("PERDA")
		dbSelectArea("PERDA")
		dbCloseArea()
	EndIf
	
	TcQuery cQuery New Alias "PERDA"

	While !PERDA->(Eof())
		if PERDA->CONT > 0
			binPerda := .T.
		end if
		
		PERDA->(DbSkip())
	EndDo
  PERDA->(DbCloseArea())
*/
Return binPerda

Static Function HashNatur(cTipoIn)

Local cQuery 
Local cAlias := Alias()//- salvo o alias aberto 
// 
Default  __cCliHashNatu := '' 	

Default __lFound := .F.

	
If __cCliHashNatu <> SE1->(E1_CLIENTE+E1_LOJA)
	__cCliHashNatu := SE1->(E1_CLIENTE+E1_LOJA)
	cQuery := " SELECT SE1.E1_CLIENTE,SE1.E1_LOJA FROM "
	cQuery += REtSqlName("SE1")+" SE1 "
	cQuery += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
	cQuery += "   AND SE1.E1_CLIENTE = '"+SE1->E1_CLIENTE+"'"
	cQuery += "   AND SE1.E1_LOJA = '"+SE1->E1_LOJA+"'"
	cQuery += "   AND SE1.E1_TIPO IN "  + F130MontaIn(@cTipoIn)
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY SE1.E1_CLIENTE,SE1.E1_LOJA"
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"HashNatur",.T.,.T.)
	
	__lFound := HashNatur->(!Eof())
	
	HashNatur->(dbCloseArea())		
EndIf 
//- restauro o alias anterior 
dbSelectArea(cAlias)
__cCliHashNatu := '' 

Return __lFound

Static Function F130MontaIn(cTipoIn)
Local cTiposAbt	:= MVABATIM +"|"+MVFUABT
Default cTipoIn   := ""


If cTipoIn == ""
	cTipoIn	:=	StrTran(cTiposAbt,',','/')
	cTipoIn	:=	StrTran(cTipoIn,';','/')
	cTipoIn	:=	StrTran(cTipoIn,'|','/')
	cTipoIn	:=	StrTran(cTipoIn,'\','/')

	cTipoIn := Formatin(cTipoIn,"/")
Endif

Return cTipoIn


Static Function F130Dtano2(cDataX)

Local cData1
Local cAno
Local cMes
Local cDia
Local cData2

	cData1 := right(Dtos(cDataX),6)
	cAno := substr(cData1,1,2)
	cMes := substr(cData1,3,2)
	cDia := substr(cData1,5,2)
	cData2 := cDia +"/"+ cMes +"/"+ cAno


Return cData2

Static Function insertDados(aDados, dDataBase)

    Local cCliente
    Local cTitulo
    Local cNatureza
    Local cVencto
    Local cVlVencido
    Local cVlCorrig
    Local cCategoria
    Local cSegmento
    Local cRisco
    Local cDataBase
    Local cCodEmp
    Local cCodEmpOri
    Local cCodFil
    Local cVlFut
    Local cMarca
    
    
    Local vlVencido
    Local vlNominal
    

	If Empty(aDados[CLIENT]) 
		aDados[CLIENT] := ""
	End If
	
	If Empty(aDados[TITUL]) 
		aDados[TITUL] := ""
	End If
	
	If Empty(aDados[NATUREZA]) 
		aDados[NATUREZA] := ""
	End If
	
	If Empty(aDados[VENCTO]) 
		aDados[VENCTO] := ""
		cVencto := ""
	Else
		cVencto := DTOS(aDados[VENCTO]) 
	End If
	
	If Empty(aDados[VL_VENCIDO]) 
		vlVencido := 0
	Else
		vlVencido := aDados[VL_VENCIDO]
	End If
	
	If Empty(aDados[VL_NOMINAL]) 
		vlNominal := 0
	Else
		vlNominal := aDados[VL_NOMINAL]
	End If
	
	cVlVencido := cValToChar(vlVencido + vlNominal)
	
	If Empty(aDados[VL_ORIG]) 
		cVlCorrig := "0"
	Else
		cVlCorrig := cValToChar(aDados[VL_ORIG])
	End If
	
	If Empty(aDados[CATEGORIA]) 
		aDados[CATEGORIA] := ""
	End If
	aDados[CATEGORIA] := RTRIM(aDados[CATEGORIA])
	
	If Empty(aDados[MARCA]) 
		aDados[MARCA] := ""
	End If
	aDados[MARCA] := RTRIM(aDados[MARCA])
	
	If Empty(aDados[SEGMENTO]) 
		aDados[SEGMENTO] := ""
	End If
	
	If Empty(aDados[RISCO]) 
		aDados[RISCO] := ""
	End If
	
	cCliente := aDados[CLIENT]
    cTitulo := aDados[TITUL] 
    cNatureza := aDados[NATUREZA] 
    
    cCodEmp := FWCodEmp()
    cCodEmpOri := FWCodEmp()
    cCodFil := FWCodFil()
    
    
    
    cCategoria := aDados[CATEGORIA]
    cMarca := aDados[MARCA]
    cSegmento := aDados[SEGMENTO]
    cRisco := aDados[RISCO]
    cDataBase := DTOS(dDataBase)
	cAno := "2018"
	

	If !Empty(aDados[CLIENT]) .and. !CliInPerda("P |01|SA1010||"+cCliente+"01", cDataBase) 
	    cVlFut := cValToChar(TitPos(cCliente, cDataBase))
	    //Inserção de controle de clientes em perda
	    cSql := "INSERT INTO __BI_PB_CLIPERDA(BK_CLIENTE ,ANO,DTENTRADA,DTSAIDA) VALUES ('P |01|SA1010||"+cCliente+cCodEmp+"',"+cAno+" ,'"+cDataBase+"', NULL)"
	    TcSqlExec(cSql)
	    
		If cCodEmp == "01" .Or. cCodEmp == "05" 
	        cSql := "INSERT INTO __BI_PB_CREPERDA  (BK_EMPRESA, BK_FILIAL, BK_CLIENTE, NUM_TIT, NATUREZA, VENCTO, DTBAIXA, SALDO, SALDOFUTURO, CATEGORIA, SEGMENTO, RISCO, DATA_BASE, TIPO, EMPORIGEM, EMPRESA, FILIAL, CLIENTE, MARCA) VALUES"
			cSql += "('P |01|"+cCodEmp+"', 'P |01|"+cCodEmp+cCodFil+"', 'P |01|SA1010||"+cCliente+"01"
			cSql += "', '"+ cTitulo
			cSql += "', '"+ cNatureza
			cSql += "', '"+ cVencto
			cSql += "', '', "+cVlVencido
			cSql += ", "+cVlFut
			cSql += ", '"+cCategoria
			cSql += "', '"+cSegmento
			cSql += "', '"+cRisco
			cSql += "', '"+cDataBase+"', "
			cSql += "'CRE', '"+cCodEmpOri+"',  '"+cCodEmp+"',  '"+cCodFil+"', '"+cCliente+"', '"+cMarca+"')"
			TcSqlExec(cSql)
		End If
		
		If cCodEmp == "07" 
		   //Prefixo Igual a 1 Bianco se nao Incesa
			if aDados[PREFIXO] == "1"
				cCodEmp := "01"
			Else
				cCodEmp := "05"
			End If
	       cSql := "INSERT INTO __BI_PB_CREPERDA  (BK_EMPRESA, BK_FILIAL, BK_CLIENTE, NUM_TIT, NATUREZA, VENCTO, DTBAIXA, SALDO, SALDOFUTURO, CATEGORIA, SEGMENTO, RISCO, DATA_BASE, TIPO, EMPORIGEM, EMPRESA, FILIAL, CLIENTE, MARCA) VALUES"
			cSql += "('P |01|"+cCodEmp+"', 'P |01|"+cCodEmp+cCodFil+"', 'P |01|SA1010||"+cCliente+"01"
			cSql += "', '"+ cTitulo
			cSql += "', '"+ cNatureza
			cSql += "', '"+ cVencto
			cSql += "', '', "+cVlVencido
			cSql += ", "+cVlFut
			cSql += ", '"+cCategoria
			cSql += "', '"+cSegmento
			cSql += "', '"+cRisco
			cSql += "', '"+cDataBase+"', "
			cSql += "'CRE', '"+cCodEmpOri+"',  '"+cCodEmp+"',  '"+cCodFil+"', '"+cCliente+"', '"+cMarca+"')"
			TcSqlExec(cSql)
		End If
		
	End If	

Return Nil
