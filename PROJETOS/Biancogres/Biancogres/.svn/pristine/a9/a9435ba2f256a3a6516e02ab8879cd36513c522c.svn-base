#INCLUDE "FINR130.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"

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


Static lFWCodFil := FindFunction("FWCodFil")
Static __lTempLOT
Static cDBType	:= Alltrim(Upper(TCGetDB()))
Static lSQL		:= !(cDBType $"ORACLE|POSTGRES|DB2|INFORMIX")
STATIC _nTamSEQ
STATIC cAliasProc
Static lProcCriad := .F.

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*/
??????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?FINR130  ?Autor ?Daniel Tadashi Batori ?Data ?01.08.06 ??
???????????????????????????????????????
??escri?o ?Posi?o dos Titulos a Receber					          ??
???????????????????????????????????????
??intaxe e ?FINR130(void)                                              ??
???????????????????????????????????????
??arametros?                                                           ??
???????????????????????????????????????
??Uso      ?Generico                                                   ??
???????????????????????????????????????
???????????????????????????????????????
??????????????????????????????????????
*/
User Function BIA102R()

Local oReport

Private cMVBR10925 	:= SuperGetMv("MV_BR10925", ,"2") 
Private dDtVenc 	:= ddatabase
Private lAbortPrint	:= .F.
/*
GESTAO - inicio */
Private aSelFil	:= {}
/* GESTAO - fim
 */
conout("BIA102R - ID User: "+AllTrim(__cUserId))

//AjustaSX1()

If FindFunction("TRepInUse") .And. TRepInUse()
 	oReport := ReportDef()
 	oReport:PrintDialog()
Else
	FINR130R3() // Executa vers? anterior do fonte
Endif

Return

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?ReportDef?Autor ?Daniel Batori         ?Data ?01.08.06 ??
???????????????????????????????????????
??escri?o ?Definicao do layout do Relatorio									  ??
???????????????????????????????????????
??intaxe   ?ReportDef(void)                                            ??
???????????????????????????????????????
??Uso      ?Generico                                                   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function ReportDef()
Local oReport  
Local oSection1
Local oSection2
Local cPictTit
Local nTamVal, nTamCli, nTamQueb, nTamJur, nTamNBco

oReport := TReport():New("FINR130",STR0005,"FIN130",{|oReport| ReportPrint(oReport)},STR0001+STR0002)

oReport:DisableOrientation(.T.)// Op?o de impress? no formato Retrato desabilitada devido a n? comportar mais informa?es.
oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.) // Imprime o total em linhas

/*
GESTAO - inicio */
oReport:SetUseGC(.F.)
/* GESTAO - fim
*/

//Nao retire esta chamada. Verifique antes !!!
//Ela ?necessaria para o correto funcionamento da pergunte 36 (Data Base)
PutDtBase()

pergunte("FIN130",.F.)
//??????????????????????????????????????
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
//?mv_par43      // Considera Titulos Excluidos?					  	?
//??????????????????????????????????????

cPictTit := PesqPict("SE1","E1_VALOR")
nTamVal	 := TamSx3("E1_VALOR")[1]
nTamCli	 := TamSX3("E1_CLIENTE")[1] + TamSX3("E1_LOJA")[1] + 20 + 2
nTamTit	 := TamSX3("E1_PREFIXO")[1] + TamSX3("E1_NUM")[1] + TamSX3("E1_PARCELA")[1] + 25 
nTamBan	 := TamSX3("E1_PORTADO")[1] + TamSX3("E1_SITUACA")[1] + 1
nTamDte	 := TamSx3("E1_EMISSAO")[1]+3
nTamQueb := nTamCli + nTamTit + nTamBan + TamSX3("E1_TIPO")[1] + TamSX3("E1_NATUREZ")[1] + TamSX3("E1_EMISSAO")[1] +;
		  	TamSX3("E1_VENCTO")[1] + TamSX3("E1_VENCREA")[1] + nTamBan + 2
nTamJur  := TamSX3("E1_JUROS")[1]

nTamNBco := TamSX3("E1_NUMBCO")[1]+20 

//Secao 1 --> Analitico
oSection1 := TRSection():New(oReport,STR0079,{"SE1","SA1"},;
				{STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0047})
//Secao 2 --> Sintetico
oSection2 := TRSection():New(oReport,STR0081,{"SE1"})
TRCell():New(oSection1,"CLIENTE",,STR0056,,nTamCli,.F.,,,,,,,.F.)  //"Codigo-Lj-Nome do Cliente"
TRCell():New(oSection1,"TITULO",,STR0057+CRLF+STR0058,,nTamTit,.F.,,,,,,,.T.)  //"Prf-Numero" + "Parcela"
TRCell():New(oSection1,"E1_TIPO","SE1",STR0059,,,.F.,,,,,,,.F.)  //"TP"
TRCell():New(oSection1,"E1_NATUREZ","SE1",STR0060,,+12,.F.,,,,,,,.F.)  //"Natureza" 
TRCell():New(oSection1,"E1_EMISSAO","SE1",STR0061+CRLF+STR0062,,nTamDte,.F.,,,,,,,.F.)  //"Data de" + "Emissao"
TRCell():New(oSection1,"E1_VENCTO","SE1",STR0063+CRLF+STR0064,,nTamDte,.F.,,,,,,,.F.)  //"Vencto" + "Titulo"
TRCell():New(oSection1,"E1_VENCREA","SE1",STR0063+CRLF+STR0065,,nTamDte,.F.,,,,,,,.F.)  //"Vencto" + "Real"
TRCell():New(oSection1,"BANCO",,STR0083,,nTamBan,.F.,,,,,,,.F.)  //"Bco St"
TRCell():New(oSection1,"VAL_ORIG",,STR0067,cPictTit,nTamVal+22,.F.,,,,,,,.T.)  //"Valor Original"
TRCell():New(oSection1,"VAL_NOMI",,STR0068+CRLF+STR0069,cPictTit,nTamVal+16,.F.,,,,,,,.T.)  //"Tit Vencidos" + "Valor Nominal"
TRCell():New(oSection1,"VAL_CORR",,STR0068+CRLF+STR0070,cPictTit,nTamVal+16,.F.,,,,,,,.T.)  //"Tit Vencidos" + "Valor Corrigido"
TRCell():New(oSection1,"VAL_VENC",,STR0071+CRLF+STR0069,cPictTit,nTamVal+22,.F.,,,,,,,.T.)  //"Titulos a Vencer" + "Valor Nominal"
TRCell():New(oSection1,"E1_NUMBCO","SE1",STR0072+CRLF+STR0066,,nTamNBco,.F.,,,,,,,.T.)  //"Num" + "Banco"
TRCell():New(oSection1,"JUROS",,STR0073+CRLF+STR0074,cPictTit,nTamJur,.F.,,,,,,,.T.)  //"Vlr.juros ou" + "permanencia"
TRCell():New(oSection1,"DIA_ATR",,STR0075+CRLF+STR0076,,10,.F.,,,,,,,.T.)  //"Dias" + "Atraso"
TRCell():New(oSection1,"E1_HIST" ,"SE1",STR0077,,23,.F.,,,,,,,.T.)  //"Historico" 19
TRCell():New(oSection1,"VAL_SOMA",,STR0078,cPictTit,38,.F.,,,,,,,.T.)  //"(Vencidos+Vencer)"

TRCell():New(oSection2,"QUEBRA",,,,nTamQueb-nTamVal,.F.,,,,,,,.T.)
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

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?eportPrint?Autor ?aniel Batori          ?Data ?0.07.06  ??
???????????????????????????????????????
??escri?o ? funcao estatica ReportDef devera ser criada para todos os  ??
??         ?elatorios que poderao ser agendados pelo usuario.           ??
???????????????????????????????????????
??etorno   ?enhum                                                       ??
???????????????????????????????????????
??arametros?xpO1: Objeto Report do Relat?io                            ??
???????????????????????????????????????
??  DATA   ?Programador   ?anutencao efetuada                          ??
???????????????????????????????????????
??         ?              ?                                            ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function ReportPrint(oReport)
Local oSection1  	:= oReport:Section(1)
Local oSection2  	:= oReport:Section(2)
Local nOrdem 		:= oSection1:GetOrder()
Local oBreak
Local oBreak2
Local oTotVenc
Local oTotCorr
                                                      	
Local aDados[18]
Local nRegEmp 		:= SM0->(RecNo())
Local nRegSM0 		:= SM0->(Recno())
Local nAtuSM0 		:= SM0->(Recno())
Local dOldDtBase 	:= dDataBase
Local dOldData		:= dDatabase

Local CbCont
Local cCond1			:= ""
Local cCond2
Local nTit0			:=0
Local nTit1			:=0
Local nTit2			:=0
Local nTit3			:=0
Local nTit4			:=0
Local nTit5			:=0
Local nTotJ			:=0
Local nTot0			:=0
Local nTot1			:=0
Local nTot2			:=0
Local nTot3			:=0
Local nTot4			:=0
Local nTotTit		:=0
Local nTotJur		:=0
Local nTotFil0		:=0
Local nTotFil1		:=0
Local nTotFil2		:=0
Local nTotFil3		:=0
Local nTotFil4		:=0
Local nTotFilTit	:=0
Local nTotFilJ		:=0
Local nAtraso		:=0
Local nTotAbat		:=0
Local nSaldo		:=0
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
Local dDtCtb   	:= CTOD("//")
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
Local cCarAnt 	:= ""
Local cCarAnt2	:= ""
Local cCampo		:= ""
// *************************************************
// Utilizada para guardar os abatimentos baixados *
// que devem subtrair o saldo do titulo principal.*
// *************************************************
Local nBx,aAbatBaixa	:= {}

#IFDEF TOP
	Local aStru 	:= SE1->(dbStruct()), ni
#ENDIF	

Local aTamCli  		:= TAMSX3("E1_CLIENTE")
Local lF130Qry 		:= ExistBlock("F130QRY")
// variavel  abaixo criada p/pegar o nr de casas decimais da moeda
Local ndecs			:= 0
Local nAbatim		:= 0
Local nDescont		:= 0
Local nVlrOrig		:= 0
Local cFilDe		:= ""
Local cFilAte		:= ""
Local cMoeda		:= ""
Local nJuros  		:=0
Local dUltBaixa		:= STOD("")
Local cFilterUser	:= ""
Local cFilUserSA1 	:= oSection1:GetADVPLExp("SA1")
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
Local aCliAbt		:= {}	// Clientes com titulos de abatimento
Local lFJurCst		:= Existblock("FJURCST")	// Ponto de entrada para calculo de juros

Local cCorpBak    := ""
Local cRepTit		:= oReport:Title()
Local lRelCabec		:= .F.
Local cFilNat 		:= SE1->E1_NATUREZ
Local lAbatIMPBx  	:= .F.
Local aRecSE1Cmp	:= {}
/*
GESTAO - inicio */
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
Local nRecnoSE1   := 0
Local aAux := {}
Local nI := 0
Local lEmpLog := .F.
Local cQryUsu  := ""
/* GESTAO - fim
*/

Private cTitulo 	:= ""
Private dBaixa 		:= dDataBase

Default __lTempLOT := HasTemplate("LOT")
If oReport:lXlsTable
	Alert(STR0086)//Formato de impress? tabela n? suportado neste relat?io
	oReport:CancelPrint()
	Return
Endif
If mv_par15 = 0
	mv_par15 := 1
EndIf
nDecs  := Msdecimais(mv_par15)
cMoeda := Alltrim(Str(mv_par15,2))

/*
GESTAO - inicio */
If MV_PAR42 == 1
	If Empty(aSelFil)
		If  FindFunction("AdmSelecFil")
			AdmSelecFil("FIN130",42,.F.,@aSelFil,"SE1",.F.)
		Else
			aSelFil := AdmGetFil(.F.,.F.,"SE1")
			If Empty(aSelFil)
				Aadd(aSelFil,cFilAnt)
			Endif
		Endif
	Endif
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
/* GESTAO - fim
*/
oSection1:Cell("CLIENTE"   ):SetBlock( { || aDados[CLIENT]    			})
oSection1:Cell("TITULO"    ):SetBlock( { || aDados[TITUL]     			})
oSection1:Cell("E1_TIPO"   ):SetBlock( { || aDados[TIPO]      			})
oSection1:Cell("E1_NATUREZ"):SetBlock( { || MascNat(aDados[NATUREZA]) 	})
oSection1:Cell("E1_EMISSAO"):SetBlock( { || aDados[EMISSAO]   			})
oSection1:Cell("E1_VENCTO" ):SetBlock( { || aDados[VENCTO]    			})
oSection1:Cell("E1_VENCREA"):SetBlock( { || aDados[VENCREA]   			})
oSection1:Cell("BANCO"     ):SetBlock( { || aDados[BANC]      			})
oSection1:Cell("VAL_ORIG"  ):SetBlock( { || aDados[VL_ORIG]   			})
oSection1:Cell("VAL_NOMI"  ):SetBlock( { || aDados[VL_NOMINAL]			})
oSection1:Cell("VAL_CORR"  ):SetBlock( { || aDados[VL_CORRIG] 			})
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
 	oBreak2 := TRBreak():New(oSection1, {|| SE1->E1_FILIAL + Iif(nOrdem == 4, AllTrim(Str(Month(Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA)))), AllTrim(Str(Month(SE1->E1_EMISSAO))))} , {|| STR0041 + "("+AllTrim(Str(nTotTitMes))+" "+Iif(nTotTitMes > 1, OemToAnsi(STR0039), OemToAnsi(STR0040))+")"} ) //"T O T A L  D O  M E S --->"
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
	oBreak:OnBreak( { |x,y| cCarAnt2 := Situcob(x) } )
ElseIf nOrdem == 7 //vencto e banco
	oBreak := TRBreak():New(oSection1, {||SE1->E1_FILIAL + IIf(MV_PAR40=2,DtoC(SE1->E1_VENCTO)+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,DtoC(SE1->E1_VENCREA)+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA)},;
	{||STR0037 + DtoC(dDtVenc) + IIf(!Empty(cNumBco), " - " + STR0066 + " " + cNumBco + " " + ;
	GetAdvfVal("SA6","A6_NOME",xFilial("SA6") + AllTrim(cNumBco),1),"")},.F.,"",.F.)
Endif

//??????????????????????
//?Imprimir TOTAL por filial somente quando ?
//?houver mais do que uma filial.	         ?
//??????????????????????
If lTotFil
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

//Nao retire esta chamada. Verifique antes !!!
//Ela ?necessaria para o correto funcionamento da pergunte 36 (Data Base)
PutDtBase()

//??????????????????????????????????
//?POR MAIS ESTRANHO QUE PARE€A, ESTA FUNCAO DEVE SER CHAMADA AQUI! ?
//?                                                                 ?
//?A fun?o SomaAbat reabre o SE1 com outro nome pela ChkFile para  ?
//?efeito de performance. Se o alias auxiliar para a SumAbat() n?  ?
//?estiver aberto antes da IndRegua, ocorre Erro de & na ChkFile,   ?
//?pois o Filtro do SE1 uptrapassa 255 Caracteres.                  ?
//??????????????????????????????????
//SomaAbat("","","","R")
If Select("__SE1") == 0
	ChkFile("SE1",.F.,"__SE1")
Else
	DbSelectArea("__SE1")
EndIf
//???????????????????????????????
//?Atribui valores as variaveis ref a filiais                ?
//???????????????????????????????
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

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())

If Alltrim(CMODULO) == "FAT"	
	//cQryUsu := " AND E1_VEND1 = '"+CREPATU+"' "
	IF SUBSTRING(cRepAtu,1,1) = "1"
		IF CEMPANT == "01"
			//cQryUsu := "	AND	A3_SUPER = '"+cRepAtu+"' "
			cQryUsu := "	AND	(A1_YVENDB2 = '"+cRepAtu+"' OR  A1_YVENDB3 = '"+cRepAtu+"')  "
		ELSE
			//cQryUsu := "	AND	A3_SUPER = '"+cRepAtu+"' "
			cQryUsu := "	AND	(A1_YVENDI2 = '"+cRepAtu+"' OR  A1_YVENDI3 = '"+cRepAtu+"')  "		
		END IF
	ELSE
		cQryUsu := "	AND	E1_VEND1 = '"+cRepAtu+"' "
	END IF
EndIf

oReport:NoUserFilter()

oSection1:Init()
oSection2:Init()

aFill(aDados,nil)
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
			cTitulo := oReport:Title() + STR0080 + " " + GetMv("MV_MOEDA" +cMoeda)  //"Posicao dos Titulos a Receber"+" - Analitico"
		Else
			cTitulo := oReport:Title() + STR0080 + " " + GetMv("MV_MOEDA" +cMoeda)  //"Posicao dos Titulos a Receber"+" - Sintetico"
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

	// *****************************************
	// Bloco utilizado para nao duplicar      *
	// registros quando Filial compartilhada  *
	// na gest? corporativa. Exempo SE1:     *
	//  Filial  = Compartilhado               *
	//  Unidade = Exclusivo                   *
	//  Empresa = Exclusivo                   *
	// *****************************************
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

	#IFDEF TOP

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
			cQuery += " AND A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA"
			cQuery += " AND SE5.E5_MOTBX = 'CMP'"
			cQuery += " AND SE5.D_E_L_E_T_ = ''"
			cQuery += " AND SE1.R_E_C_N_O_ IN ( "
			cQuery += " 		SELECT SE1.R_E_C_N_O_"
			cQuery += " 			FROM " + RetSQLName( "SE1" ) + " SE1 , "+	RetSqlName("SA1") + " SA1 "
			cQuery += " 			WHERE SE1.E1_FILIAL = '"+xFilial('SE5')+"' AND A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND"
			cQuery += " 			SE1.D_E_L_E_T_ = ' ' "
			cQuery += cQryUsu +" AND SA1.D_E_L_E_T_ = '' "
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
				cQuery += " 		AND E1_SITUACA NOT IN ('2','7')"
			Endif
			If mv_par20 == 2
				cQuery += ' 		AND E1_SALDO <> 0'
			Endif
			If mv_par34 == 1
				cQuery += " 		AND E1_FLUXO <> 'N'"
			Endif
			/* GESTAO - inicio */
			If nLenSelFil == 0
				If mv_par21 == 2
					cQuery +=  " 		AND E1_FILIAL = '" + xFilial("SE1") + "'"
				Else
					If Empty( E1_FILIAL )
						cQuery += "		AND E1_FILORIG between '" + mv_par22 + "' AND '" + mv_par23 + "'"
					Else
						cQuery += " 	AND E1_FILIAL between '" + mv_par22 + "' AND '" + mv_par23 + "'"
					EndIf
				Endif
			Else
				If FWModeAccess("SE1",3) == "E"
					cQuery += " AND E1_FILIAL " + cQryFilSE1
				Else
					If MV_PAR42 == 1
						cQuery += " AND E1_FILORIG " + FR130InFilial()
					Else
						cQuery += " AND E1_FILIAL = '" + xFilial("SE1") + "'"
					EndIf
				Endif
			Endif
			/* GESTAO - fim
			*/

			//?????????????????????
			//?Verifica se deve imprimir outras moedas?
			//?????????????????????
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

		// Verifica os titulos que possuem qualquer tipo de abatimento, para evitar chamada da SumAbat sem necessidade
		cQuery := "SELECT "

		cQuery += "SE1.E1_CLIENTE, SE1.E1_LOJA "
		cQuery += "FROM " + RetSQLName( "SE1" ) + " SE1 "
		cQuery += "WHERE "                                             
		cQuery += "    SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
		cQuery += "AND SE1.E1_TIPO LIKE '%-' "
		cQuery += "AND SE1.D_E_L_E_T_ = ' ' "
		cQuery += "GROUP BY SE1.E1_CLIENTE, SE1.E1_LOJA "

		cQuery := ChangeQuery(cQuery)                   
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBABT",.T.,.T.)	
		
		While TRBABT->( ! EoF() )
			AAdd( aCliAbt, TRBABT->( E1_CLIENTE + E1_LOJA ) )
			TRBABT->( dbSkip() )	
		EndDo                   
		
		dbSelectArea( "SE1" )
		
		TRBABT->( dbCloseArea() )

		cFilterUser := oSection1:GetSqlExp("SE1")
		If nOrdem = 1
			cCampos := ""
			aEval(SE1->(DbStruct()),{|e| If(!Alltrim(e[1])$"E1_FILIAL#E1_NOMCLI#E1_CLIENTE#E1_LOJA#E1_PREFIXO#E1_NUM#E1_PARCELA#E1_TIPO", cCampos += ",SE1."+AllTrim(e[1]),Nil)})
			cQuery := "SELECT E1_FILIAL, E1_NOMCLI, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM,E1_PARCELA, E1_TIPO, SE1.R_E_C_N_O_ , " + SubStr(cCampos,2)
		Else
			cQuery := "SELECT * "
		EndIf

		cQuery += "  FROM "+	RetSqlName("SE1") + " SE1, "+	RetSqlName("SA1") + " SA1"
		cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA"
		cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
		If !empty(cFilterUser)
      		cQuery += " AND ("+ cFilterUser +")"
        EndIf
	#ENDIF
	
	IF nOrdem = 1 .and. !lRelCabec
		#IFDEF TOP
			cChaveSe1 := "E1_FILIAL, E1_NOMCLI, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO"
			cOrder := SqlOrder(cChaveSe1)
		#ELSE
			cChaveSe1 := "E1_FILIAL+E1_NOMCLI+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ENDIF
		cCond1	:= "SE1->E1_CLIENTE <= mv_par02"
		cCond2	:= "SE1->E1_CLIENTE + SE1->E1_LOJA"
		cTitulo	+= STR0017  //" - Por Cliente" 
		lRelCabec := .T.
	ElseIf nOrdem = 2 .and. !lRelCabec
		SE1->(dbSetOrder(1))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par03+mv_par05)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1	:= "SE1->E1_NUM <= mv_par06"
		cCond2	:= "SE1->E1_NUM"
		cTitulo	+= STR0018  //" - Por Numero" 
		lRelCabec := .T.
	Elseif nOrdem = 3 .and. !lRelCabec
		SE1->(dbSetOrder(4))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par07)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1	:= "SE1->E1_PORTADO <= mv_par08"
		cCond2	:= "SE1->E1_PORTADO"
		cTitulo	+= STR0019  //" - Por Banco" 
		lRelCabec := .T.
	Elseif nOrdem = 4  .and. !lRelCabec
		SE1->(dbSetOrder(7))
		#IFNDEF TOP
			dbSeek(cFilial+DTOS(mv_par09))
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1	:= Iif(mv_par40 = 2, "SE1->E1_VENCTO", "SE1->E1_VENCREA")+" <= mv_par10"
		cCond2	:= Iif(mv_par40 = 2, "SE1->E1_VENCTO", "SE1->E1_VENCREA")
		cTitulo	+= STR0020  //" - Por Data de Vencimento"
		lRelCabec := .T.
	Elseif nOrdem = 5 .and. !lRelCabec
		SE1->(dbSetOrder(3))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par11)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1	:= "SE1->E1_NATUREZ <= mv_par12"
		cCond2	:= "SE1->E1_NATUREZ"
		cTitulo	+= STR0021  //" - Por Natureza"
		lRelCabec := .T.
	Elseif nOrdem = 6 .and. !lRelCabec
		SE1->(dbSetOrder(6))
		#IFNDEF TOP
			dbSeek( cFilial+DTOS(mv_par13))
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1	:= "SE1->E1_EMISSAO <= mv_par14"
		cCond2	:= "SE1->E1_EMISSAO"
		cTitulo	+= STR0042  //" - Por Emissao" 
		lRelCabec := .T.
	Elseif nOrdem == 7 .and. !lRelCabec
		cChaveSe1 := "E1_FILIAL+DTOS("+Iif(mv_par40 = 2, "E1_VENCTO", "E1_VENCREA")+")+E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFNDEF TOP
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ELSE
			cOrder := SqlOrder(cChaveSe1)
		#ENDIF
		cCond1	:= Iif(mv_par40 = 2, "SE1->E1_VENCTO", "SE1->E1_VENCREA")+" <= mv_par10"
		cCond2	:= "DtoS("+Iif(mv_par40 = 2, "SE1->E1_VENCTO", "SE1->E1_VENCREA")+")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA"
		cTitulo	+= STR0023  //" - Por Vencto/Banco" 
		lRelCabec := .T.
	Elseif nOrdem = 8 .and. !lRelCabec
		SE1->(dbSetOrder(2))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par01,.T.)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1	:= "SE1->E1_CLIENTE <= mv_par02"
		cCond2	:= "SE1->E1_CLIENTE"
		cTitulo	+= STR0024  //" - Por Cod.Cliente"
		lRelCabec := .T.
	Elseif nOrdem = 9  .and. !lRelCabec
		cChave := "E1_FILIAL+E1_PORTADO+E1_SITUACA+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFNDEF TOP
			dbSelectArea("SE1")
			cIndex := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndex,cChave,,fr130IndR(),OemToAnsi(STR0022))
			nIndex := RetIndex("SE1")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			dbSeek(xFilial("SE1"))
		#ELSE
			cOrder := SqlOrder(cChave)
		#ENDIF
		cCond1	:= "SE1->E1_PORTADO <= mv_par08"
		cCond2	:= "SE1->E1_PORTADO+SE1->E1_SITUACA"
		cTitulo	+= STR0025 //" - Por Banco e Situacao"  
		lRelCabec := .T.
	ElseIf nOrdem == 10 .and. !lRelCabec
		cChave := "E1_FILIAL+E1_NUM+E1_TIPO+E1_PREFIXO+E1_PARCELA"
		#IFNDEF TOP
			dbSelectArea("SE1")
			cIndex := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndex,cChave,,,OemToAnsi(STR0022))
			nIndex := RetIndex("SE1")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			dbSeek(xFilial("SE1")+mv_par05)
		#ELSE
			cOrder := SqlOrder(cChave)
		#ENDIF
		cCond1	:= "SE1->E1_NUM <= mv_par06"
		cCond2	:= "SE1->E1_NUM"
		cTitulo	+= STR0048 //" - Numero/Prefixo"
		lRelCabec := .T.		
	Endif


	oReport:SetTitle(cTitulo)
	
	Set Softseek Off
	
	#IFDEF TOP
		cQuery += cQryUsu +" AND SA1.D_E_L_E_T_ = '' "
		cQuery += " AND SE1.E1_CLIENTE between '" + mv_par01        + "' AND '" + mv_par02 + "'"
		cQuery += " AND SE1.E1_LOJA    between '" + mv_par24        + "' AND '" + mv_par25 + "'"
		cQuery += " AND SE1.E1_PREFIXO between '" + mv_par03        + "' AND '" + mv_par04 + "'"
		cQuery += " AND SE1.E1_NUM     between '" + mv_par05        + "' AND '" + mv_par06 + "'"
		cQuery += " AND SE1.E1_PORTADO between '" + mv_par07        + "' AND '" + mv_par08 + "'"
		If mv_par40 == 2
			cQuery += " AND SE1.E1_VENCTO between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
		Else
			cQuery += " AND SE1.E1_VENCREA between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
		Endif
		cQuery += " AND SE1.E1_NATUREZ BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"'"
		cQuery += " AND SE1.E1_EMISSAO between '" + DTOS(mv_par13)  + "' "
		If ( MV_PAR38 == 2 ) .and. mv_par14 >= mv_par36
			cQuery += " AND '" + DtoS(mv_par36) + "'"
		Else
			cQuery += " AND '" + DTOS(mv_par14) + "'"
		Endif

		cQuery += " AND SE1.E1_LOJA    between '" + mv_par24        + "' AND '" + mv_par25 + "'"

		cQuery += " AND SE1.E1_EMIS1  Between '"+ DTOS(mv_par27)+"' AND '"+DTOS(mv_par28)+"'"
		If !Empty(mv_par31) // Deseja imprimir apenas os tipos do parametro 31
			cQuery += " AND SE1.E1_TIPO IN "+FormatIn(mv_par31,";") 
		ElseIf !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
			cQuery += " AND SE1.E1_TIPO NOT IN "+FormatIn(mv_par32,";")
		EndIf
		If mv_par18 == 2
			cQuery += " AND SE1.E1_SITUACA NOT IN ('2','7')"
		Endif
		If mv_par20 == 2
			cQuery += ' AND SE1.E1_SALDO <> 0'
		Endif
		If mv_par34 == 1
			cQuery += " AND SE1.E1_FLUXO <> 'N'"
		Endif
		/*
		GESTAO - fim */
		If nLenSelFil == 0  
			If mv_par21 == 2
				cQuery +=  " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "'"		
			Else
				If Empty( E1_FILIAL )
					cQuery += " AND SE1.E1_FILORIG between '" + mv_par22 + "' AND '" + mv_par23 + "'"				
				Else
					cQuery += " AND SE1.E1_FILIAL between '" + mv_par22 + "' AND '" + mv_par23 + "'"				
				EndIf
			Endif
		Else
			If FWModeAccess("SE1",3) == "E"
				cQuery += " AND SE1.E1_FILIAL " + cQryFilSE1
			Else
				If MV_PAR42 == 1
					cQuery += " AND SE1.E1_FILORIG " + FR130InFilial()
				Else
					cQuery += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
				EndIf
			Endif
		Endif
		/* GESTAO - fim
		*/
		//?????????????????????
		//?Verifica se deve imprimir outras moedas?
		//?????????????????????
		If mv_par30 == 2 // nao imprime
			cQuery += " AND SE1.E1_MOEDA = "+cMoeda
		Endif

        //?????????????????????????????????????
        //?Ponto de entrada para inclusao de parametros no filtro a ser executado ?
        //?????????????????????????????????????
	    If lF130Qry 
			cQuery += ExecBlock("F130QRY",.f.,.f.)
		Endif
		
		If AliasIndic("FJU")
			If MV_PAR43 == 1
				If TcSrvType() != "AS/400"
					cQuery += " UNION "
			  	
			  		If nOrdem = 1
						cQuery += "SELECT SE1.E1_FILIAL, SE1.E1_NOMCLI, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.R_E_C_N_O_,  " + SubStr(cCampos,2)
			  		Else
						cQuery += "SELECT SE1.*"
			  		Endif
			  	
					cQuery += " FROM "+ RetSqlName("SE1")+" SE1,"+ RetSqlName("FJU") +" FJU"
					cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
					cQuery += " AND FJU.FJU_FILIAL	 = '" + xFilial("FJU") + "'"
					cQuery += " AND SE1.E1_PREFIXO 	= FJU.FJU_PREFIX "
					cQuery += " AND SE1.E1_NUM 		= FJU.FJU_NUM "
					cQuery += " AND SE1.E1_PARCELA 	= FJU.FJU_PARCEL "
					cQuery += " AND SE1.E1_TIPO 	= FJU.FJU_TIPO "
					cQuery += " AND SE1.E1_ClIENTE	= FJU.FJU_CLIFOR "
					cQuery += " AND SE1.E1_LOJA 	= FJU.FJU_LOJA "
					cQuery += " AND FJU.FJU_EMIS   <= '" + DTOS(dDataBase) +"'"
					cQuery += " AND FJU.FJU_DTEXCL >= '" + DTOS(dDataBase) +"'"
					cQuery += " AND SE1.R_E_C_N_O_ = FJU.FJU_RECORI "
					
					cQuery += " AND FJU.FJU_RECORI IN ( SELECT MAX(FJU_RECORI) "
     
					cQuery += "   FROM "+ RetSqlName("FJU")+" LASTFJU "
					cQuery += "   WHERE LASTFJU.FJU_FILIAL = FJU.FJU_FILIAL "
					cQuery += "       AND LASTFJU.FJU_PREFIX = FJU.FJU_PREFIX "
					cQuery += "         AND LASTFJU.FJU_NUM = FJU.FJU_NUM "
					cQuery += "           AND LASTFJU.FJU_PARCEL = FJU.FJU_PARCEL "
					cQuery += "             AND LASTFJU.FJU_CLIFOR = FJU.FJU_CLIFOR "
					cQuery += "            		AND LASTFJU.FJU_LOJA = FJU.FJU_LOJA "	
				    cQuery += " 						AND FJU.FJU_DTEXCL = LASTFJU.FJU_DTEXCL "
						    
					cQuery += "   GROUP BY FJU_FILIAL "
					cQuery += "       ,FJU_PREFIX "
					cQuery += "       ,FJU_NUM "
					cQuery += "       ,FJU_PARCEL "
					cQuery += "       ,FJU_CLIFOR "
					cQuery += "       ,FJU_LOJA ) "
      
					cQuery += " AND SE1.D_E_L_E_T_ = '*' " 
					cQuery += " AND FJU.D_E_L_E_T_ = ' ' " 
						
					cQuery += " AND " 
					cQuery += " (SELECT COUNT(*) " 
					cQuery += " FROM "+ RetSqlName("SE1")+" NOTDEL " 
					cQuery += " WHERE NOTDEL.E1_FILIAL = FJU.FJU_FILIAL "         
					cQuery += " AND NOTDEL.E1_PREFIXO = FJU.FJU_PREFIX     "      
					cQuery += " AND NOTDEL.E1_NUM = FJU.FJU_NUM            "
					cQuery += " AND NOTDEL.E1_PARCELA = FJU.FJU_PARCEL      "        
					cQuery += " AND NOTDEL.E1_CLIENTE = FJU.FJU_CLIFOR       "     
					cQuery += " AND NOTDEL.E1_LOJA = FJU.FJU_LOJA  	"
					cQuery += " AND NOTDEL.E1_EMISSAO   = '" + DTOS(dDataBase) +"'"
					cQuery += " AND NOTDEL.D_E_L_E_T_ = '') = 0 "
	
				Endif	
			Endif
		EndIf				

		cQuery += " ORDER BY "+ cOrder		
		cQuery := ChangeQuery(cQuery)
		
		dbSelectArea("SE1")
		dbCloseArea()
		dbSelectArea("SA1")
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)
		
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next
	#ELSE
		cFilterUser := oSection1:GetADVPLExp("SE1")
		If !Empty(cFilterUser)
			oSection1:SetFilter(cFilterUser)
		Endif
		If nOrdem == 1	
			DbSetfilter( { | |  !(ALLTRIM(Mv_par32) $ ALLTRIM(SE1->E1_TIPO) ) }, '!(ALLTRIM(Mv_par32) $ ALLTRIM(SE1->E1_TIPO) )' )
			SE1->(DBGoTop())
		Else	
			If !Empty(cCond1)
				cCond1	+= " .And. "
			EndIf
			cCond1 += "!(ALLTRIM(Mv_par32) $ ALLTRIM(SE1->E1_TIPO) ) "
		EndIf				  

	#ENDIF

	If MV_MULNATR .And. nOrdem == 5

		// No relatorio analitico desabilita secao de totais quando MV_MULNATR e ordenacao por natureza,
		// para forcar a utilizacao da totalizacao com oBreak e TRFunction da oSection1.
		If mv_par19 == 1
			oSection2:Disable()
		EndIf

		/*
		GESTAO - inicio */
		If nLenSelFil == 0
			Finr135(cTipos, .F., @nTot0, @nTot1, @nTot2, @nTot3, @nTotTit, @nTotJ, oReport, aDados, @oSection2)
		Else
			cTitBkp := cTitulo
			Finr135(cTipos, .F., @nTotFil0, @nTotFil1, @nTotFil2, @nTotFil3, @nTotFilTit, @nTotFilJ, oReport, aDados, @oSection2)
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

		#IFDEF TOP
			dbSelectArea("SE1")
			dbCloseArea()
			ChKFile("SE1")
			dbSelectArea("SE1")
			dbSetOrder(1)
		#ENDIF

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

		//?????????????????????
		//?Carrega data do registro para permitir ?
		//?posterior analise de quebra por mes.   ?
		//?????????????????????
		dDataAnt := Iif(nOrdem == 6 , SE1->E1_EMISSAO,  Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA))

		cCarAnt := &cCond2

		While !Eof() .And. SE1->E1_FILIAL == cFilSE1 .And. &cCond2 == cCarAnt

			dbSelectArea("SE1")
			//????????????????????????????????
			//?e nao atender a condicao para impressao, despreza o registro?
			//????????????????????????????????
			If !Fr130Cond(cTipos)
				SE1->(DbSkip())
				Loop
			EndIf
					// dDtContab para casos em que o campo E1_EMIS1 esteja vazio
			dDtCtb	:=	CTOD("//")	
			dDtCtb	:= Iif(Empty(SE1->E1_EMIS1),SE1->E1_EMISSAO,SE1->E1_EMIS1)

			//?????????????????????
			//?Verifica se esta dentro dos parametros ?
			//?????????????????????
								
			//???????????????????????????????????
			//?Modificado tratamento para o par?etro MV_PAR36(CONSIDERA DATABASE)?
			//?para quando se imprime um relat?io com o par?etro MV_PAR20(SALDO ?
			//?RETROATIVO) = SIM verificando corretamente na SE5 a data de baixa, ?
			//?cr?ito ou digita?o para impress?. 							   ?
			//???????????????????????????????????
			dbSelectArea("SE1")

			#IFDEF TOP

				If dDtCtb < mv_par27 .Or. dDtCtb > mv_par28 
					SE1->( dbSkip() )
					Loop
				Endif

			#ELSE
			
				If mv_par18 == 2 .and. E1_SITUACA $ "27"
					SE1->(dbSkip())
					Loop
				EndIf	

				IF SE1->E1_CLIENTE < mv_par01 .OR. SE1->E1_CLIENTE > mv_par02 .OR. ;
					SE1->E1_PREFIXO < mv_par03 .OR. SE1->E1_PREFIXO > mv_par04 .OR. ;
					SE1->E1_NUM	 	 < mv_par05 .OR. SE1->E1_NUM 		> mv_par06 .OR. ;
					SE1->E1_PORTADO < mv_par07 .OR. SE1->E1_PORTADO > mv_par08 .OR. ;
					Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA) < mv_par09 .OR. ;
					Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA) > mv_par10 .OR. ;
					SE1->E1_NATUREZ < mv_par11 .OR. SE1->E1_NATUREZ > mv_par12 .OR. ;	
					SE1->E1_EMISSAO < mv_par13 .OR. SE1->E1_EMISSAO > mv_par14 .OR. ; 				
					SE1->E1_LOJA    < mv_par24 .OR. SE1->E1_LOJA    > mv_par25 .OR. ;
					dDtCtb          < mv_par27 .OR. dDtCtb          > mv_par28 .OR. ;
					(SE1->E1_EMISSAO > mv_par36 .and. MV_PAR38 == 2)
					SE1->( dbSkip() )
					Loop
				Endif

			#ENDIF

			//????????????????????????????
			//?Filtro de usu?io pela tabela SA1.					 ?
			//????????????????????????????
			If !Empty(cFilUserSA1)
				dbSelectArea("SA1")
				MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
				If !SA1->(&cFilUserSA1)
					SE1->(dbSkip())
					Loop
				EndIf
			Endif			
			//????????????????????????????
			//?Verifica se trata-se de abatimento ou somente titulos?
			//?at?a data base. 									 ?
			//????????????????????????????
			dbSelectArea("SE1")
			IF (SE1->E1_TIPO $ MVABATIM	+"/"+MVFUABT  .And. mv_par33 != 1) .Or.;
				(SE1->E1_EMISSAO > mv_par36 .and. MV_PAR38 == 2)
				IF !Empty(SE1->E1_TITPAI)
					aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , SE1->E1_TITPAI } )
				Else
					cMTitPai := FTITPAI()
					aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , cMTitPai } )
				EndIf
				dbSkip()
				Loop
			Endif

			//Quando Retroagir saldo, data menor que o solicitado e o titulo estiver 
			//baixado nao mostrar no relatorio
			If (MV_PAR20 == 1 .and. cMVBR10925 == "1" .and. SE1->E1_EMISSAO <= MV_PAR36 .and. SE1->E1_TIPO $ "PIS/COF/CSL")
				dbSkip()
				Loop				
			EndIf
			
			 // Tratamento da correcao monetaria para a Argentina
			If  cPaisLoc=="ARG" .And. mv_par15 <> 1  .And.  SE1->E1_CONVERT=='N'
				dbSkip()
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
			
			If mv_par20 == 1	// Considera Data Base
				nSaldo := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par15,dDataReaj,MV_PAR36,SE1->E1_LOJA,,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),mv_par37,.T.)
				//Verifica se existem compensa?es em outras filiais para descontar do saldo, pois a SaldoTit() somente
				//verifica as movimenta?es da filial corrente. Nao deve processar quando existe somente uma filial.
				If lVerCmpFil .and. ( mv_par41 == 1 ) .and. ( nSaldo != SE1->E1_SALDO ) .and.;
									 aScan( aRecSE1Cmp , { |x| x[1] == SE1->( R_E_C_N_O_ )} ) > 0
					proclogatu("INICIO",STR0085) //"PESQUISA DE COMPENSA?O DE MULTI-FILIIAS"
					nSaldo -= Round(NoRound( xMoeda( FRVlCompFil("R",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,mv_par37,aFiliais,cFilQry,lAS400),;
									SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(mv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA) ),0 ) ),;
									nDecs+1),nDecs)
					proclogatu("FIM",STR0085)//Log pesquisa de compensa?o
				EndIf
				// Subtrai decrescimo para recompor o saldo na data escolhida.
				If Str(SE1->E1_VALOR,17,2) == Str(nSaldo,17,2) .And. SE1->E1_DECRESC > 0 .And. SE1->E1_SDDECRE == 0
					nSAldo -= SE1->E1_DECRESC 
				Endif
				
				// Soma Acrescimo para recompor o saldo na data escolhida.
				If Str(SE1->E1_VALOR,17,2) == Str(nSaldo,17,2) .And. SE1->E1_ACRESC > 0 .And. SE1->E1_SDACRES == 0
					nSAldo += SE1->E1_ACRESC
				Endif

				//Se abatimento verifico a data da baixa.
				//Por nao possuirem movimento de baixa no SE5, a saldotit retorna 
				//sempre saldo em aberto quando mv_par33 = 1 (Abatimentos = Lista)
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
				If ( cMVBR10925 == "1" .and. SE1->E1_EMISSAO <= MV_PAR36 .and. !(SE1->E1_TIPO $ "PIS/COF/CSL").and. !(SE1->E1_TIPO $ MVABATIM) ) ;
						.AND. ( "S" $ (SA1->(A1_RECPIS+A1_RECCOFI+A1_RECCSLL) ) )

					nValPcc := SumAbatPCC(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,dBaixa,SE1->E1_CLIENTE,SE1->E1_LOJA,mv_par15)
					nSaldo -= nValPcc
				EndIf				
				If SE1->E1_TIPO == "RA "   //somente para titulos ref adiantamento verifica se nao houve cancelamento da baixa posterior data base (mv_par36)
					nSaldo -= F130TipoBA()
				EndIf
			Else
				nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
			Endif

			// Se titulo do Template GEM
			If __lTempLOT .And. SE1->(FieldPos("E1_NCONTR")) > 0 .And. !Empty(SE1->E1_NCONTR) 
				nGem := CMDtPrc(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VENCREA)[2]
				If SE1->E1_VALOR==SE1->E1_SALDO
					nSaldo += nGem
				EndIf
			EndIf

			//Caso exista desconto financeiro (cadastrado na inclusao do titulo), 
			//subtrai do valor principal.
			If Empty( SE1->E1_BAIXA ) .Or. cMvDesFin == "P"
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
                    
                    //Busca as informa?es para alimentar a array aTitImp utilizando a fun?o F130RETIMP     PTO CRITICO
	                dbSelectArea("__SE1")
			   		dbSetOrder(2)
			   		dbSeek(xFilial("SED")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
					cFilNat:= SE1->E1_NATUREZ				
					aTitImp:= F130RETIMP(cFilNat)				        
					
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
						If aScan( aCliAbt, SE1->(E1_CLIENTE + E1_LOJA) ) > 0
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
							ElseIf mv_par33 == 2 .and. mv_par26 == 1 //Se nao listar ele diminui do saldo
								nSaldo-= nAbatim
							Endif
						Else       
						    // Subtrai o Abatimento caso o mesmo j?tenho sido baixado ou n? esteja listado no relatorios
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
			
		   //????????????????????????????
			//?Desconsidera caso saldo seja menor ou igual a zero   ?
			//????????????????????????????
			If nSaldo <= 0
				dbSkip()
				Loop
			Endif					
			
			If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .and. mv_par26 == 2
				dbSkip()
				Loop
			Endif
			
			SA1->( MSSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA) )
			SA6->( MSSeek(cFilial+SE1->E1_PORTADO) )
			dbSelectArea("SE1")
				
			aDados[CLIENT] := RTrim(SE1->E1_CLIENTE) + "-" + SE1->E1_LOJA + "-" + IIF(mv_par29 == 1, SubStr(SA1->A1_NREDUZ,1,20), SubStr(SA1->A1_NOME,1,20))
			aDados[TITUL] := SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA
			aDados[TIPO] := SE1->E1_TIPO
			aDados[NATUREZA] := SE1->E1_NATUREZ
			aDados[EMISSAO] := SE1->E1_EMISSAO
			aDados[VENCTO] := SE1->E1_VENCTO
			aDados[VENCREA] := SE1->E1_VENCREA

			If mv_par20 == 1  //Recompoe Saldo Retroativo              
			    //Titulo foi Baixado e Data da Baixa e menor ou igual a Data Base do Relat?io
			    IF !Empty(SE1->E1_BAIXA)
			    	If SE1->E1_BAIXA <= mv_par36 .Or. !Empty( SE1->E1_PORTADO )
						aDados[BANC] := SE1->E1_PORTADO+" "+SE1->E1_SITUACA
					EndIf	
				Else                                                                                   
				    //Titulo n? foi Baixado e foi transferido para Carteira e Data Movimento e menor 
				    //ou igual a Data Base do Relat?io
					If Empty(SE1->E1_BAIXA) .and. SE1->E1_MOVIMEN <= mv_par36
						aDados[BANC] := SE1->E1_PORTADO+" "+SE1->E1_SITUACA             
					EndIf
				ENDIF
			Else   // Nao Recompoe Saldo Retroativo
				aDados[BANC] := SE1->E1_PORTADO+" "+SE1->E1_SITUACA 
			EndIf
			//Se parametro Tit. Emissao Futura = Sim , e se for titulos de impostos gerados na baixa com data posterior a database, e parametro Recompoe Saldo = Sim => Exibier como Abatimento  
			lAbatIMPBx := MV_PAR38 == 1 .AND. SE1->E1_EMISSAO >= MV_PAR36 .AND. MV_PAR20 == 1 .AND. SE1->E1_TIPO $ "PIS/COF/CSL/IRF"
			aDados[VL_ORIG] := Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)* If((SE1->E1_TIPO$MVABATIM +"/"+MVFUABT+"/"+MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM) .OR. lAbatIMPBx, -1,1),nDecs+1),nDecs)
			aDados[VL_NOMINAL] :=0
			aDados[VL_CORRIG]:=0    
			aDados[VL_VENCIDO]:=0
			
			If dDataBase > E1_VENCREA	//vencidos
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					aDados[VL_NOMINAL] := nSaldo * If(SE1->E1_TIPO$MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM +"/"+MVFUABT, -1,1)  
				EndIf
				// Somente chamad fa070juros se realmente houver necessidade de calculo de juros			
				If lFJurCst .Or. !Empty(SE1->E1_VALJUR) .Or. !Empty(SE1->E1_PORCJUR)
					dUltBaixa := SE1->E1_BAIXA
					#IFDEF TOP
						If MV_PAR20 == 1 // se compoem saldo retroativo verifico se houve baixas 
							If !Empty(dUltBaixa) .And. dDataBase < dUltBaixa
								dUltBaixa := FR130DBX() // Ultima baixa at?DataBase
							EndIf
						EndIf
					#ENDIF
					nJuros := fa070Juros(mv_par15,nSaldo,"SE1",dUltBaixa)
				EndIf
				// Se titulo do Template GEM
				If __lTempLOT .And. SE1->(FieldPos("E1_NCONTR")) > 0 .And. !Empty(SE1->E1_NCONTR) .And. SE1->E1_VALOR==SE1->E1_SALDO
					nJuros -= nGem
				EndIf
				dbSelectArea("SE1")
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					aDados[VL_CORRIG] := (nSaldo+nJuros)* If(SE1->E1_TIPO$MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM +"/"+MVFUABT, -1,1) 
				EndIf

				If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .or. (mv_par33 == 1 .and. SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT)
					nTit0 -= Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nTit1 -= (nSaldo)
					nTit2 -= (nSaldo+nJuros)
					nMesTit0 -= Round(NoRound( xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nMesTit1 -= (nSaldo)
					nMesTit2 -= (nSaldo+nJuros)
					nTotJur  -= nJuros
					nMesTitj -= nJuros
					nTotFilJ -= nJuros
				Else
					If !SE1->E1_TIPO $ MVABATIM	+"/"+MVFUABT
						nTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)						
						nTit1 += (nSaldo)
						nTit2 += (nSaldo+nJuros)
						nMesTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
						nMesTit1 += (nSaldo)
						nMesTit2 += (nSaldo+nJuros)
						nTotJur  += nJuros
						nMesTitj += nJuros
						nTotFilJ += nJuros
					Endif	
				Endif
			Else						//a vencer
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					aDados[VL_VENCIDO] := nSaldo * If((SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM +"/"+MVFUABT) .OR. lAbatIMPBx, -1,1)
				EndIf

				If ! ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM +"/"+MVFUABT) .and. !lAbatIMPBx
					nTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nTit3 += (nSaldo-nTotAbat)
					nTit4 += (nSaldo-nTotAbat)
					nMesTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nMesTit3 += (nSaldo-nTotAbat)
					nMesTit4 += (nSaldo-nTotAbat)
				Else
					nTit0 -= Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nTit3 -= (nSaldo-nTotAbat)
					nTit4 -= (nSaldo-nTotAbat)
					nMesTit0 -= Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nMesTit3 -= (nSaldo-nTotAbat)
					nMesTit4 -= (nSaldo-nTotAbat)
				Endif

			Endif
			
			If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
				aDados[NUMBC] := SE1->E1_NUMBCO
			EndIf

			If nJuros > 0

				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					aDados[VL_JUROS] := nJuros
				EndIf

				nJuros := 0

			Endif
			
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
            
			If mv_par19 == 1 //1 = Analitico - 2 = Sintetico 18
				aDados[HISTORICO] := SubStr(SE1->E1_HIST,1,25)+IIF(E1_TIPO $ MVPROVIS,"*"," ")+ ;
				Iif(Str(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),17,2) ==Str(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),17,2)," ","P")
				
				//realiza a troca de alias da query que est?como SE1 para a tabela SE1 original
				// pois se cliente customizar relatorio com campo memo, o conteudo n? ?exibido
				If SE1->(FieldPos("R_E_C_N_O_")) > 0 
				  nRecnoSE1 := SE1->R_E_C_N_O_//Campo criado na query
				Else
				  nRecnoSE1 := SE1->(RECNO())//Campo original da tabela SE1
				EndIf

				DbChangeAlias("SE1","SE1QRY")
				DbChangeAlias("__SE1","SE1")
				SE1->(DBGoto(nRecnoSE1))
				//exibe a linha no relatorio
				oSection1:PrintLine()
				DbChangeAlias("SE1","__SE1")
				DbChangeAlias("SE1QRY","SE1")
				
				
				aFill(aDados,nil)
			EndIf

			//?????????????????????
			//?Carrega data do registro para permitir ?
			//?posterior an?ise de quebra por mes.   ?
			//?????????????????????
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

		Enddo

		If nOrdem == 3
			SA6->(dbSeek(xFilial()+cCarAnt))
		ELSEIf nOrdem == 7
			SA6->(dbSeek(xFilial()+SUBSTR(cCarAnt,9) ))
		EndIf
			
		IF nTit5 > 0 .And. nOrdem != 2 .And. nOrdem != 10 .And. mv_par19 == 2 //1 = Analitico - 2 = Sintetico
			SubTot130R(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,nDecs,oReport,,oSection2)
		Endif
		
		nTotTitMes	:= nMesTTit
		nTotGeral	+= (nTit2+nTit3)
					
		//?????????????????????
		//?Verifica quebra por m?	  			    ?
		//?????????????????????
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
		nTotFil := nTotFil2+nTotFil3
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
	
	#IFDEF TOP
		dbSelectArea("SE1")
		dbCloseArea()
		ChKFile("SE1")
		dbSelectArea("SE1")
		dbSetOrder(1)
	#ENDIF

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
oSection2:Finish()

#IFNDEF TOP
	dbSelectArea("SE1")
	dbClearFil()
	RetIndex( "SE1" )
	If !Empty(cIndexSE1)
		FErase (cIndexSE1+OrdBagExt())
	Endif
	dbSetOrder(1)
	/*
	GESTAO - inicio */
	If !Empty(aTmpFil)
		For nBx := 1 To Len(aTmpFil)
			CtbTmpErase(aTmpFil[nBx])
		Next
	Endif
	/* GESTAO - fim
	*/
#ELSE
	dbSelectArea("SE1")
	dbCloseArea()
	ChKFile("SE1")
	dbSelectArea("SE1")
	dbSetOrder(1)
#ENDIF

SM0->(dbGoTo(nRegEmp))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

//Acerta a database de acordo com a database real do sistema
dDataBase := dOldDtBase

Return

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?ubTot130R ?Autor ?Daniel Tadashi Batori ?Data ?03.08.06 ??
???????????????????????????????????????
??escri?o ?mprimir SubTotal do Relatorio										  ??
???????????????????????????????????????
??intaxe e ?SubTot130R()															  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso 	    ?Generico																	  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function SubTot130R(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,nDecs,oReport,aDados,oSection)

Local cQuebra := ""

If nOrdem = 1
	//mv_par29 - Imprime Nome?
	cQuebra := If(mv_par29 == 1,Substr(SA1->A1_NREDUZ,1,30),Substr(SA1->A1_NOME,1,30))+" "+ STR0054 + Right(cCarAnt,2)+Iif(mv_par21==1,STR0055+cFilAnt + " - " + Alltrim(SM0->M0_FILIAL),"")//"Loja - "###" Filial - "
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
   	cQuebra := SA1->A1_COD+" "+Substr(SA1->A1_NOME,1,30)+" " + Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
ElseIf nOrdem = 9
	cCarteira := Situcob(cCarAnt)
	cQuebra := SA6->A6_COD+" "+SA6->A6_NREDUZ + SubStr(cCarteira,1,2) + " "+SubStr(cCarteira,3,20) + " " + Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
Endif

HabiCel(oReport, ( nOrdem == 5 .And. MV_MULNATR ) )

oSection:Cell("QUEBRA"   ):SetBlock({|| cQuebra})
oSection:Cell("TOT_NOMI" ):SetBlock({|| nTit1  })
oSection:Cell("TOT_CORR" ):SetBlock({|| nTit2  })
oSection:Cell("TOT_VENC" ):SetBlock({|| nTit3  })
oSection:Cell("TOT_SOMA" ):SetBlock({|| nTit2+nTit3})
oSection:Cell("TOT_JUROS"):SetBlock({|| nTotJur})   

oSection:PrintLine()

Return .T.

/*/
???????????????????????????????????????
???????????????????????????????????????
????????????-???????????????????????????
??un?o	 ?TotGer130R?Autor ?Paulo Boschetti       ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?Imprimir total do relatorio										   ??
????????????-???????????????????????????
??intaxe e ?TotGer130R()															   ??
???????????????????????????????????????
??arametros?																			   ??
?????????????-??????????????????????????
??Uso      ?Generico																	   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
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
oSection:Cell("TOT_SOMA" ):SetBlock({|| nTot2+nTot3})
oSection:PrintLine()

Return .T.

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?Mes130R	?Autor ?Vinicius Barreira	  ?Data ?12.12.94 ??
???????????????????????????????????????
??escri?o ?MPRIMIR TOTAL DO RELATORIO - QUEBRA POR MES					  ??
???????????????????????????????????????
??intaxe e ?IMes130R()	 															  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
STATIC Function IMes130R(nMesTot0,nMesTot1,nMesTot2,nMesTot3,nMesTot4,nMesTTit,nMesTotJ,nDecs,oReport,aDados,oSection)

HabiCel(oReport)

oSection:Cell("QUEBRA"   ):SetBlock({|| PadR(STR0041,28) + "("+ALLTRIM(STR(nMesTTit))+" "+IIF(nMesTTit > 1,OemToAnsi(STR0039),OemToAnsi(STR0040))+")"})
oSection:Cell("TOT_NOMI" ):SetBlock({|| nMesTot1})
oSection:Cell("TOT_CORR" ):SetBlock({|| nMesTot2})
oSection:Cell("TOT_VENC" ):SetBlock({|| nMesTot3})
oSection:Cell("TOT_SOMA" ):SetBlock({|| nMesTot2+nMesTot3})

oSection:PrintLine()

Return(.T.)

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?IFil130R ?Autor ?Paulo Boschetti  	  ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?Imprimir total do relatorio por filial							  ??
???????????????????????????????????????
??intaxe e ?IFil130R()																  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso 	    ?Generico																	  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
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

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?abiCel	?Autor ?Daniel Tadashi Batori ?Data ?04/08/06 ??
???????????????????????????????????????
??escri?o ?abilita ou desabilita celulas para imprimir totais			  ??
???????????????????????????????????????
??intaxe e ?HabiCel()	 															  ??
???????????????????????????????????????
??arametros?lHabilit->.T. para habilitar e .F. para desabilitar		  ??
??		 ?oReport ->objeto TReport que possui as celulas 				  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
STATIC Function HabiCel(oReport, lMultNat)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)

Default lMultNat := .F.

If mv_par19 == 1 //1 =  Analitico - 2 = Sintetico
	If !lMultNat
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



/*
---------------------------------------------------------- RELEASE 3 ---------------------------------------------
*/



/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?FINR130R3?Autor ?Paulo Boschetti	     ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?Posi?o dos Titulos a Receber 						 	  		  ??
???????????????????????????????????????
??intaxe e ?FINR130R3(void)									  					  ??
???????????????????????????????????????
??Uso		 ?Generico 												  				  ??
???????????????????????????????????????
???????????????????????????????????????
??????????????????????????????????????
/*/
Static Function FINR130R3()
Local cDesc1 :=OemToAnsi(STR0001)  //"Imprime a posi?o dos titulos a receber relativo a data ba-"
Local cDesc2 :=OemToAnsi(STR0002)  //"se do sistema."
Local cDesc3 :=""
Local wnrel
Local cString:="SE1"
Local nRegEmp:=SM0->(RecNo())
Local dOldDtBase := dDataBase
Local dOldData	:= dDatabase

Private titulo  :=""
Private cabec1  :=""
Private cabec2  :=""

Private aLinha  :={}
Private aReturn :={ OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private cPerg	 :="FIN130"
Private nJuros  :=0
Private nLastKey:=0
Private nomeprog:="FINR130"
Private tamanho :="G"

//??????????????
//?Defini?o dos cabe?lhos ?
//??????????????
titulo := OemToAnsi(STR0005)  //"Posicao dos Titulos a Receber"
cabec1 := OemToAnsi(STR0006)  //"Codigo Nome do Cliente      Prf-Numero         TP  Natureza    Data de  Vencto   Vencto  Bco St Valor Original |        Titulos Vencidos          | Titulos a Vencer | Num        Vlr.juros ou  Dias   Historico     "
cabec2 := OemToAnsi(STR0007)  //"                            Parcela                            Emissao  Titulo    Real                         |  Valor Nominal   Valor Corrigido |   Valor Nominal  | Banco       permanencia  Atraso               "

//Nao retire esta chamada. Verifique antes !!!
//Ela ?necessaria para o correto funcionamento da pergunte 36 (Data Base)
PutDtBase()

pergunte("FIN130",.F.)

//?????????????????????????????????????
//?Variaveis utilizadas para parametros												?
//?mv_par01		 // Do Cliente 													   ?
//?mv_par02		 // Ate o Cliente													   ?
//?mv_par03		 // Do Prefixo														   ?
//?mv_par04		 // Ate o prefixo 												   ?
//?mv_par05		 // Do Titulo													      ?
//?mv_par06		 // Ate o Titulo													   ?
//?mv_par07		 // Do Banco														   ?
//?mv_par08		 // Ate o Banco													   ?
//?mv_par09		 // Do Vencimento 												   ?
//?mv_par10		 // Ate o Vencimento												   ?
//?mv_par11		 // Da Natureza														?
//?mv_par12		 // Ate a Natureza													?
//?mv_par13		 // Da Emissao															?
//?mv_par14		 // Ate a Emissao														?
//?mv_par15		 // Qual Moeda															?
//?mv_par16		 // Imprime provisorios												?
//?mv_par17		 // Reajuste pelo vecto												?
//?mv_par18		 // Impr Tit em Descont												?
//?mv_par19		 // Relatorio Anal/Sint												?
//?mv_par20		 // Consid Data Base?  												?
//?mv_par21		 // Consid Filiais  ?  												?
//?mv_par22		 // da filial													      ?
//?mv_par23		 // a flial 												         ?
//?mv_par24		 // Da loja  															?
//?mv_par25		 // Ate a loja															?
//?mv_par26		 // Consid Adiantam.?												?
//?mv_par27		 // Da data contab. ?												?
//?mv_par28		 // Ate data contab.?												?
//?mv_par29		 // Imprime Nome    ?												?
//?mv_par30		 // Outras Moedas   ?												?
//?mv_par31       // Imprimir os Tipos												?
//?mv_par32       // Nao Imprimir Tipos												?
//?mv_par33       // Abatimentos  - Lista/Nao Lista/Despreza					?
//?mv_par34       // Consid. Fluxo Caixa												?
//?mv_par35       // Salta pagina Cliente											?
//?mv_par36       // Data Base													      ?
//?mv_par37       // Compoe Saldo por: Data da Baixa, Credito ou DtDigit  ?
//?MV_PAR38       // Tit. Emissao Futura												?
//?MV_PAR39       // Converte Valores 												?
//?????????????????????????????????????
//?????????????????????
//?Envia controle para a fun?o SETPRINT ?
//?????????????????????

wnrel:="FINR130"            //Nome Default do relatorio em Disco
aOrd :={	OemToAnsi(STR0008),;	//"Por Cliente"
	OemToAnsi(STR0009),;	//"Por Prefixo/Numero"
	OemToAnsi(STR0010),; //"Por Banco"
	OemToAnsi(STR0011),;	//"Por Venc/Cli"
	OemToAnsi(STR0012),;	//"Por Natureza"
	OemToAnsi(STR0013),; //"Por Emissao"
	OemToAnsi(STR0014),;	//"Por Ven\Bco"
	OemToAnsi(STR0015),; //"Por Cod.Cli."
	OemToAnsi(STR0016),; //"Banco/Situacao"
	OemToAnsi(STR0047) } //"Por Numero/Tipo/Prefixo"

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| FA130Imp(@lEnd,wnRel,cString)},titulo)  // Chamada do Relatorio

SM0->(dbGoTo(nRegEmp))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

//Acerta a database de acordo com a database real do sistema
dDataBase := dOldDtBase

Return

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?FA130Imp ?Autor ?Paulo Boschetti		  ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?Imprime relat?io dos T?ulos a Receber						  ??
???????????????????????????????????????
??intaxe e ?FA130Imp(lEnd,WnRel,cString)										  ??
???????????????????????????????????????
??arametros?lEnd	  - A?o do Codeblock				    					  ??
??		 ?wnRel   - T?ulo do relat?io 									  ??
??		 ?cString - Mensagem													  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function FA130Imp(lEnd,WnRel,cString)
Local CbCont
Local CbTxt
Local lContinua 	:= .T.
Local cCond1
Local cCond2
Local cCarAnt
Local nTit0			:=0
Local nTit1			:=0
Local nTit2			:=0
Local nTit3			:=0
Local nTit4			:=0
Local nTit5			:=0
Local nTotJ			:=0
Local nTot0			:=0
Local nTot1			:=0
Local nTot2			:=0
Local nTot3			:=0
Local nTot4			:=0
Local nTotTit		:=0
Local nTotJur		:=0
Local nTotFil0		:=0
Local nTotFil1		:=0
Local nTotFil2		:=0
Local nTotFil3		:=0
Local nTotFil4		:=0
Local nTotFilTit	:=0
Local nTotFilJ		:=0
Local nAtraso		:=0
Local nTotAbat		:=0
Local nSaldo		:=0
Local dDataReaj
Local dDataAnt := dDataBase
Local lQuebra

Local nMesTit0		:= 0
Local nMesTit1 		:= 0
Local nMesTit2 		:= 0
Local nMesTit3 		:= 0
Local nMesTit4 		:= 0
Local nMesTTit	 	:= 0
Local nMesTitj 		:= 0

Local cIndexSe1
Local cChaveSe1
Local nIndexSE1
Local dDtCtb	:=	CTOD("//")
Local cTipos  		:= ""
#IFDEF TOP
	Local aStru 	:= SE1->(dbStruct()), ni
#ENDIF	
Local aTamCli  		:= TAMSX3("E1_CLIENTE")
Local lF130Qry 		:= ExistBlock("F130QRY")
// variavel  abaixo criada p/pegar o nr de casas decimais da moeda
Local ndecs 		:= Msdecimais(mv_par15)
Local nAbatim 		:= 0
Local nDescont		:= 0
Local nVlrOrig		:= 0
Local nGem 			:= 0
Local aFiliais 		:= {}
Local aAreaSE5
Local cCorpBak    := ""
Local lRelCabec		:= .F.  
Local cFilNat 		:= SE1->E1_NATUREZ

// *************************************************
// Utilizada para guardar os abatimentos baixados *
// que devem subtrair o saldo do titulo principal.*
// *************************************************
Local nBx,aAbatBaixa	:= {}
Local nValPCC		:= 0

Local nLenFil		:= 0
Local nX			:= 0
Local cFilQry		:= ""
Local cFilSE1		:= ""
Local cFilSE5		:= ""
Local lHasLot		:= HasTemplate("LOT")
Local lTemGEM		:= ExistTemplate("GEMDESCTO") .And. HasTemplate("LOT")
Local lAS400		:= (Upper(TcSrvType()) != "AS/400" .And. Upper(TcSrvType()) != "ISERIES")
Local cMvDesFin		:= SuperGetMV("MV_DESCFIN",,"I")
Local aCliAbt		:= {}	// Clientes com titulos de abatimento
Local lFJurCst		:= Existblock("FJURCST")	// Ponto de entrada para calculo de juros
Local lAbatIMPBx	:= .F.
Local aRecSE1Cmp	:= {}
Local lArgentina 	:= ( cPaisLoc=="ARG" )
Local lFilterUser	:= .F.
Local lNaoListAbat	:= ( mv_par33 != 1 )
Local lEmissFutura	:= ( MV_PAR38 == 1 )
Local lTamNum 		:= TamSX3("E1_NUM")[1]
Local lTemMov		:= .F.
Local dUltBaixa		:= STOD("")
Local cQryUsu  		:= ""

PRIVATE nRegSM0 	:= SM0->(Recno())
PRIVATE nAtuSM0 	:= SM0->(Recno())
PRIVATE nOrdem		:= 0
PRIVATE dBaixa 		:= dDataBase
PRIVATE cFilDe
PRIVATE cFilAte

Default __lTempLOT 	:= HasTemplate("LOT")

SET CENTURY OFF // Exibe data no formato DD/MM/AA 
//????????????????????????????????
//?Ponto de entrada para Filtrar os tipos sem entrar na tela do ?
//?FINRTIPOS(), localizacao Argentina.                          ?
//??????????????Jose Lucas, Localiza?es Argentina?
IF EXISTBLOCK("F130FILT")
	cTipos	:=	EXECBLOCK("F130FILT",.f.,.f.)
ENDIF

nOrdem:=aReturn[8]
cMoeda:=Alltrim(Str(mv_par15,2))

//???????????????????????????????
//?Vari?eis utilizadas para Impress? do Cabe?lho e Rodap??
//???????????????????????????????
cbtxt 	:= OemtoAnsi(STR0046)
cbcont	:= 1
li 		:= 80
m_pag 	:= 1

//??????????????????????????????????
//?POR MAIS ESTRANHO QUE PARE€A, ESTA FUNCAO DEVE SER CHAMADA AQUI! ?
//?                                                                 ?
//?A fun?o SomaAbat reabre o SE1 com outro nome pela ChkFile para  ?
//?efeito de performance. Se o alias auxiliar para a SumAbat() n?  ?
//?estiver aberto antes da IndRegua, ocorre Erro de & na ChkFile,   ?
//?pois o Filtro do SE1 uptrapassa 255 Caracteres.                  ?
//??????????????????????????????????
//SomaAbat(" "," "," ","R")
If Select("__SE1") == 0
	ChkFile("SE1",.F.,"__SE1")
Else
	DbSelectArea("__SE1")
EndIf
//???????????????????????????????
//?Atribui valores as variaveis ref a filiais                ?
//???????????????????????????????
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

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())

// Cria vetor com os codigos das filiais da empresa corrente
aFiliais := FinRetFil()

if ascan(aFiliais, cFilAnt) != 0 .and. aFiliais[1] != cFilAnt .and. len(aFiliais) > 1
	aFiliais[ascan(aFiliais, cFilAnt)] := aFiliais[1]
	aFiliais[1] := cFilAnt		
EndIf

SetRegua(0)
IncRegua()

// Restringi momentaneamente para SQL e Oracle pois o Parse est?com erro quando trata-se de DB2
If !(cDBType $ "DB2|INFORMIX") .AND. ( ( MV_PAR37 == 2 ) .Or. ( MV_PAR37 == 3 ) )
	If ( cAliasProc == NIL )
		cAliasProc	:= getNextAlias()
	Endif
	#IFDEF TOP
		CriaProc(cAliasProc)
	#ENDIF
Endif

While !Eof() .and. M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
	
	dbSelectArea("SE1")
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	
	// *****************************************
	// Bloco utilizado para nao duplicar      *
	// registros quando Filial compartilhada  *
	// na gest? corporativa. Exempo SE1:     *
	//  Filial  = Compartilhado               *
	//  Unidade = Exclusivo                   *
	//  Empresa = Exclusivo                   *
	// *****************************************
	If Alltrim(CMODULO) == "FAT"
		IF SUBSTRING(cRepAtu,1,1) = "1"
			IF CEMPANT == "01"
				cQryUsu := "	AND	(A1_YVENDB2 = '"+cRepAtu+"' OR  A1_YVENDB3 = '"+cRepAtu+"')  "
			ELSE
				cQryUsu := "	AND	(A1_YVENDI2 = '"+cRepAtu+"' OR  A1_YVENDI3 = '"+cRepAtu+"')  "		
			END IF
		ELSE
			cQryUsu := "	AND	E1_VEND1 = '"+cRepAtu+"' "
		END IF
	EndIf
	
	If cCorpBak<>xFilial("SE1")
		cCorpBak	:= xFilial("SE1")
	Else
		dbSelectArea("SM0")
		SM0->(DbSkip())
		Loop
	EndIf
	Set Softseek On

	cFilSE5		:= xFilial("SE5")
	cFilSE1		:= xFilial("SE1")
	lVerCmpFil	:= !Empty(cFilSE1) .And. !Empty(cFilSE5) .And. Len(aFiliais) > 1
	
	If !lRelCabec
		If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
			titulo := AllTrim(Titulo) + " " + OemToAnsi(STR0080)+ " " + AllTrim(GetMv("MV_MOEDA"+cMoeda))+ OemToAnsi(STR0026)  //" - Analitico"
		
		Else
			titulo := AllTrim(Titulo) + " " + OemToAnsi(STR0080)+ " " + AllTrim(GetMv("MV_MOEDA"+cMoeda)) + OemToAnsi(STR0027)  //" - Sintetico"
			cabec1 := OemToAnsi(STR0044)  //"                                                                                                               |        Titulos Vencidos          | Titulos a Vencer |            Vlr.juros ou             (Vencidos+Vencer)"
			cabec2 := OemToAnsi(STR0045)  //"                                                                                                               |  Valor Nominal   Valor Corrigido |   Valor Nominal  |             permanencia                              "
		EndIf
	EndIf	
	#IFDEF TOP

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
			If Empty(cFilQry) 
				cFilQry := "''"
			EndIf 

			cQuery := "SELECT "
			cQuery += " SE1.R_E_C_N_O_ RecnoSE1, SE5.R_E_C_N_O_ RecnoSE5"
			cQuery += " FROM " + RetSQLName( "SE5" ) + " SE5 ," + RetSQLName( "SE1" ) + " SE1  "
			cQuery += " WHERE SE5.E5_FILIAL IN ("+cFilQry+") "
			cQuery += " AND SE5.E5_PREFIXO = SE1.E1_PREFIXO  "
			cQuery += " AND SE5.E5_NUMERO = SE1.E1_NUM "
			cQuery += " AND SE5.E5_PARCELA = SE1.E1_PARCELA "
			cQuery += " AND SE5.E5_TIPO = SE1.E1_TIPO "
			cQuery += " AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "
			cQuery += " AND SE5.E5_LOJA = SE1.E1_LOJA "
			cQuery += " AND SE5.E5_MOTBX = 'CMP'"
			cQuery += " AND SE5.E5_FILORIG = '"+xFilial("SE5")+"'"
			cQuery += " AND SE5.D_E_L_E_T_ = ''"
			cQuery += " AND SE1.R_E_C_N_O_ IN ( "
			cQuery += " 		SELECT SE1.R_E_C_N_O_"
			cQuery += " 			FROM " + RetSQLName( "SE1" ) + " SE1 , "+	RetSqlName("SA1") + " SA1 "
			cQuery += " 			WHERE SE1.E1_FILIAL = '"+xFilial('SE5')+"' AND A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND"
			cQuery += " 			SE1.D_E_L_E_T_ = ' ' "
			cQuery += cQryUsu +" AND SA1.D_E_L_E_T_ = '' "
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
			If ( !lEmissFutura )
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
				cQuery += " 		AND E1_SITUACA NOT IN ('2','7')"
			Endif
			If mv_par20 == 2
				cQuery += ' 		AND E1_SALDO <> 0'
			Endif
			If mv_par34 == 1
				cQuery += " 		AND E1_FLUXO <> 'N'"
			Endif
			If mv_par21 == 2
				cQuery +=  " 		AND E1_FILIAL = '" + xFilial("SE1") + "'"
			Else
				If Empty( E1_FILIAL )
					cQuery += "		AND E1_FILORIG between '" + mv_par22 + "' AND '" + mv_par23 + "'"
				Else
					cQuery += " 	AND E1_FILIAL between '" + mv_par22 + "' AND '" + mv_par23 + "'"
				EndIf
			Endif

			//?????????????????????
			//?Verifica se deve imprimir outras moedas?
			//?????????????????????
			If mv_par30 == 2 // nao imprime
				cQuery += " 		AND E1_MOEDA = "+cMoeda
			Endif
			cQuery += " ) "
			cQuery += " AND SE1.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCOMP",.T.,.T.)

			While TRBCOMP->(!EOF())
				aadd( aRecSE1Cmp , {TRBCOMP->(RecnoSE1)} )
				TRBCOMP->(dbSkip())
			EndDo
			TRBCOMP->(dbCloseArea())
		Endif
		// Verifica os titulos que possuem qualquer tipo de abatimento, para evitar chamada da SumAbat sem necessidade
		cQuery := "SELECT "

		cQuery += "SE1.E1_CLIENTE, SE1.E1_LOJA "
		cQuery += "FROM " + RetSQLName( "SE1" ) + " SE1 "
		cQuery += "WHERE "                                             
		cQuery += "    SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	   	cQuery += "AND SE1.E1_TIPO LIKE '%-' "
		cQuery += "AND SE1.D_E_L_E_T_ = ' ' "
		cQuery += "GROUP BY SE1.E1_CLIENTE, SE1.E1_LOJA "

		cQuery := ChangeQuery(cQuery)                   
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBABT",.T.,.T.)	
		
		While TRBABT->( ! EoF() )
			AAdd( aCliAbt, TRBABT->( E1_CLIENTE + E1_LOJA ) )
			TRBABT->( dbSkip() )	
		EndDo                   
		
		dbSelectArea( "SE1" )
		
		TRBABT->( dbCloseArea() )
		
		If nOrdem = 1
			cQuery := ""
			aEval(SE1->(DbStruct()),{|e| If(!Alltrim(e[1])$"E1_FILIAL#E1_NOMCLI#E1_CLIENTE#E1_LOJA#E1_PREFIXO#E1_NUM#E1_PARCELA#E1_TIPO", cQuery += ","+AllTrim(e[1]),Nil)})
			cQuery := "SELECT E1_FILIAL, E1_NOMCLI, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM,E1_PARCELA, E1_TIPO, SE1.R_E_C_N_O_, " + SubStr(cQuery,2)
		Else
			cQuery := "SELECT * "
		EndIf
		
		cQuery += "  FROM "+	RetSqlName("SE1") + " SE1, " + RetSqlName("SA1") + " SA1 "
		cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA "
		cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	#ENDIF
	
	IF nOrdem = 1 .and. !lRelCabec
		cChaveSe1 := "E1_FILIAL+E1_NOMCLI+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFDEF TOP
			cOrder := SqlOrder(cChaveSe1)
		#ELSE
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ENDIF
		cCond1 := "E1_CLIENTE <= mv_par02"
		cCond2 := "E1_CLIENTE + E1_LOJA"
		titulo := titulo + OemToAnsi(STR0017)  //" - Por Cliente"
		lRelCabec := .T.
		
	Elseif nOrdem = 2 .and. !lRelCabec
		SE1->(dbSetOrder(1))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par03+mv_par05)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1 := "E1_NUM <= mv_par06"
		cCond2 := "E1_NUM"
		titulo := titulo + OemToAnsi(STR0018)  //" - Por Numero"
		lRelCabec := .T.
	Elseif nOrdem = 3 .and. !lRelCabec
		SE1->(dbSetOrder(4))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par07)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1 := "E1_PORTADO <= mv_par08"
		cCond2 := "E1_PORTADO"
		titulo := titulo + OemToAnsi(STR0019)  //" - Por Banco"
		lRelCabec := .T.
	Elseif nOrdem = 4 .and. !lRelCabec
		SE1->(dbSetOrder(7))
		#IFNDEF TOP
			dbSeek(cFilial+DTOS(mv_par09))
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1 := Iif(mv_par40 = 2, "E1_VENCTO", "E1_VENCREA")+" <= mv_par10"
		cCond2 := Iif(mv_par40 = 2, "E1_VENCTO", "E1_VENCREA")
		titulo := titulo + OemToAnsi(STR0020)  //" - Por Data de Vencimento"
		lRelCabec := .T.
	Elseif nOrdem = 5 .and. !lRelCabec
		SE1->(dbSetOrder(3))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par11)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1 := "E1_NATUREZ <= mv_par12"
		cCond2 := "E1_NATUREZ"
		titulo := titulo + OemToAnsi(STR0021)  //" - Por Natureza"
		lRelCabec := .T.
	Elseif nOrdem = 6 .and. !lRelCabec
		SE1->(dbSetOrder(6))
		#IFNDEF TOP
			dbSeek( cFilial+DTOS(mv_par13))
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1 := "E1_EMISSAO <= mv_par14"
		cCond2 := "E1_EMISSAO"
		titulo := titulo + OemToAnsi(STR0042)  //" - Por Emissao"
		lRelCabec := .T.
	Elseif nOrdem == 7 .and. !lRelCabec
		cChaveSe1 := "E1_FILIAL+DTOS("+Iif(mv_par40 = 2, "E1_VENCTO", "E1_VENCREA")+")+E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFNDEF TOP
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ELSE
			cOrder := SqlOrder(cChaveSe1)
		#ENDIF
		cCond1 := Iif(mv_par40 = 2, "E1_VENCTO", "E1_VENCREA")+" <= mv_par10"
		cCond2 := "DtoS("+Iif(mv_par40 = 2, "E1_VENCTO", "E1_VENCREA")+")+E1_PORTADO+E1_AGEDEP+E1_CONTA"
		titulo := titulo + OemToAnsi(STR0023)  //" - Por Vencto/Banco"
		lRelCabec := .T.
	Elseif nOrdem = 8 .and. !lRelCabec
		SE1->(dbSetOrder(2))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par01,.T.)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1 := "E1_CLIENTE <= mv_par02"
		cCond2 := "E1_CLIENTE"
		titulo := titulo + OemToAnsi(STR0024)  //" - Por Cod.Cliente"
		lRelCabec := .T.
	Elseif nOrdem = 9 .and. !lRelCabec
		cChave := "E1_FILIAL+E1_PORTADO+E1_SITUACA+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFNDEF TOP
			dbSelectArea("SE1")
			cIndex := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndex,cChave,,fr130IndR(),OemToAnsi(STR0022))
			nIndex := RetIndex("SE1")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			dbSeek(xFilial("SE1"))
		#ELSE
			cOrder := SqlOrder(cChave)
		#ENDIF
		cCond1 := "E1_PORTADO <= mv_par08"
		cCond2 := "E1_PORTADO+E1_SITUACA"
		titulo := titulo + OemToAnsi(STR0025)  //" - Por Banco e Situacao"
		lRelCabec := .T.
	ElseIf nOrdem == 10 .and. !lRelCabec
		cChave := "E1_FILIAL+E1_NUM+E1_TIPO+E1_PREFIXO+E1_PARCELA"
		#IFNDEF TOP
			dbSelectArea("SE1")
			cIndex := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndex,cChave,,,OemToAnsi(STR0022))
			nIndex := RetIndex("SE1")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			dbSeek(xFilial("SE1")+mv_par05)
		#ELSE
			cOrder := SqlOrder(cChave)
		#ENDIF
		cCond1 := "E1_NUM <= mv_par06"
		cCond2 := "E1_NUM"
		titulo := titulo + OemToAnsi(STR0048)  //" - Numero/Prefixo"	
		lRelCabec := .T.
	Endif
	
	If mv_par19 <> 1 //1 = Analitico - 2 = Sintetico
		cabec1 := OemToAnsi(STR0044)  //"Nome do Cliente      |        Titulos Vencidos          | Titulos a Vencer |            Vlr.juros ou             (Vencidos+Vencer)"
		cabec2 := OemToAnsi(STR0045)  //"|  Valor Nominal   Valor Corrigido |   Valor Nominal  |             permanencia                              "
	EndIf
	
	cFilterUser:=aReturn[7]
	Set Softseek Off
	lFilterUser := !Empty(cFilterUser)
	#IFDEF TOP
		cQuery += " AND E1_CLIENTE between '" + mv_par01        + "' AND '" + mv_par02 + "'"
		cQuery += " AND E1_LOJA    between '" + mv_par24        + "' AND '" + mv_par25 + "'"
		cQuery += " AND E1_PREFIXO between '" + mv_par03        + "' AND '" + mv_par04 + "'"
		cQuery += " AND E1_NUM     between '" + mv_par05        + "' AND '" + mv_par06 + "'"
		cQuery += " AND E1_PORTADO between '" + mv_par07        + "' AND '" + mv_par08 + "'"
		If mv_par40 == 2
			cQuery += " AND E1_VENCTO between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
		Else
			cQuery += " AND E1_VENCREA between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"		
		Endif
		cQuery += " AND E1_NATUREZ BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"'"
		cQuery += " AND E1_EMISSAO between '" + DTOS(mv_par13)  + "' AND '" + DTOS(mv_par14) + "'"
		cQuery += " AND E1_LOJA    between '" + mv_par24        + "' AND '" + mv_par25 + "'"

		If !lEmissFutura //Nao considerar titulos com emissao futura
			cQuery += " AND E1_EMISSAO <=      '" + DTOS(mv_par36) + "'"
		Endif

		cQuery += " AND ((E1_EMIS1  Between '"+ DTOS(mv_par27)+"' AND '"+DTOS(mv_par28)+"') OR E1_EMISSAO Between '"+DTOS(mv_par27)+"' AND '"+DTOS(mv_par28)+"')"
		If !Empty(mv_par31) // Deseja imprimir apenas os tipos do parametro 31
			cQuery += " AND E1_TIPO IN "+FormatIn(mv_par31,";") 
		ElseIf !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
			cQuery += " AND E1_TIPO NOT IN "+FormatIn(mv_par32,";")
		EndIf
		If mv_par18 == 2
			cQuery += " AND E1_SITUACA NOT IN ('2','7')"
		Endif
		If mv_par20 == 2
			cQuery += " AND E1_SALDO <> 0 "
		Endif
		If mv_par34 == 1
			cQuery += " AND E1_FLUXO <> 'N' "
		Endif  
		If mv_par21 == 2
			cQuery +=  " AND E1_FILIAL = '" + xFilial("SE1") + "'"		
		Else
			If Empty( E1_FILIAL )
				cQuery += " AND E1_FILORIG between '" + mv_par22 + "' AND '" + mv_par23 + "'"
			Else
				cQuery += " AND E1_FILIAL between '" + mv_par22 + "' AND '" + mv_par23 + "'"
			EndIf
		Endif
		If ( !lEmissFutura )
			cQuery += " AND E1_EMISSAO <= '"+DtoS(mv_par36)+"'"
		Endif

		//?????????????????????
		//?Verifica se deve imprimir outras moedas?
		//?????????????????????
		If mv_par30 == 2 // nao imprime
			cQuery += " AND E1_MOEDA = "+cMoeda
		Endif
        //?????????????????????????????????????
        //?Ponto de entrada para inclusao de parametros no filtro a ser executado ?
        //?????????????????????????????????????
		cQuery += " AND SE1.D_E_L_E_T_ = '' "
		cQuery += cQryUsu +" AND SA1.D_E_L_E_T_ = '' "

	    If lF130Qry 
			cQuery += ExecBlock("F130QRY",.f.,.f.)
		Endif

		cQuery += " ORDER BY "+ cOrder
		
		cQuery := ChangeQuery(cQuery)
		
		dbSelectArea("SE1")
		dbCloseArea()
		dbSelectArea("SA1")
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)

		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next
	#ENDIF
	
	If MV_MULNATR .And. nOrdem == 5
		Finr135R3(cTipos, lEnd, @nTot0, @nTot1, @nTot2, @nTot3, @nTotTit, @nTotJ)
		#IFDEF TOP
			dbSelectArea("SE1")
			dbCloseArea()
			ChKFile("SE1")
			dbSelectArea("SE1")
			dbSetOrder(1)
		#ENDIF
		If Empty(xFilial("SE1"))
			Exit
		Endif
		dbSelectArea("SM0")
		dbSkip()
		Loop
	Endif

	While &cCond1 .and. !Eof() .and. lContinua .and. SE1->E1_FILIAL == xFilial("SE1")
	
		IF	lEnd
			@PROW()+1,001 PSAY OemToAnsi(STR0028)  //"CANCELADO PELO OPERADOR"
			Exit
		Endif
		
		Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5
		
		//?????????????????????
		//?Carrega data do registro para permitir ?
		//?posterior analise de quebra por mes.   ?
		//?????????????????????
		dDataAnt := If(nOrdem == 6 , SE1->E1_EMISSAO,  Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA))
		
		cCarAnt := &cCond2

		While &cCond2==cCarAnt .and. !Eof() .and. lContinua .and. SE1->E1_FILIAL == xFilial("SE1")
			     
			IF lEnd
				@PROW()+1,001 PSAY OemToAnsi(STR0028)  //"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIF
			
			dbSelectArea("SE1")

			If !Fr130Cond(cTipos)
				DbSkip()
				Loop
			EndIf

			 // Tratamento da correcao monetaria para a Argentina
			If  lArgentina .And. (mv_par15 <> 1) .And.  SE1->E1_CONVERT=='N'
				dbSkip()
				Loop
			Endif
			//????????????????????????????????
			//?Considera filtro do usuario                                  ?
			//????????????????????????????????
			If lFilterUser .and. !(&cFilterUser)
				dbSkip()
				Loop
			Endif
			//????????????????????????????
			//?Verifica se trata-se de abatimento ou somente titulos?
			//?at?a data base. 									 ?
			//????????????????????????????
			dbSelectArea("SE1")
			IF (lNaoListAbat .AND. SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT) .Or.;
				(!lEmissFutura .AND. SE1->E1_EMISSAO > mv_par36)
				IF !Empty(SE1->E1_TITPAI)
					aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , SE1->E1_TITPAI } )
				Else
					cMTitPai := FTITPAI()
					aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , cMTitPai } )
				EndIf
				dbSkip()
				Loop
			Endif

			//Quando Retroagir saldo, data menor que o solicitado e o titulo estiver 
			//baixado nao mostrar no relatorio
			If (MV_PAR20 == 1 .and. cMVBR10925 == "1" .and. SE1->E1_EMISSAO <= MV_PAR36 .and. SE1->E1_TIPO $ "PIS/COF/CSL")
				dbSkip()
				Loop				
			EndIf			
			
			// dDtContab para casos em que o campo E1_EMIS1 esteja vazio
			dDtCtb	:=	CTOD("//")
			dDtCtb	:= Iif(Empty(SE1->E1_EMIS1),SE1->E1_EMISSAO,SE1->E1_EMIS1)
                    
			#IFDEF TOP

				If dDtCtb < mv_par27 .Or. dDtCtb > mv_par28 
					SE1->( dbSkip() )
					Loop
				Endif
	
			#ELSE
				If mv_par18 == 2 .and. SE1->E1_SITUACA $ "27"
					dbSkip()
					Loop
				Endif
				//?????????????????????
				//?Verifica se esta dentro dos parametros ?
				//?????????????????????
				dbSelectArea("SE1")
				IF SE1->E1_CLIENTE < mv_par01 .OR. SE1->E1_CLIENTE > mv_par02 .OR. ;
					SE1->E1_PREFIXO < mv_par03 .OR. SE1->E1_PREFIXO > mv_par04 .OR. ;
					SE1->E1_NUM	 	 < mv_par05 .OR. SE1->E1_NUM 		> mv_par06 .OR. ;
					SE1->E1_PORTADO < mv_par07 .OR. SE1->E1_PORTADO > mv_par08 .OR. ;
					Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA) < mv_par09 .OR. ;
					Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA) > mv_par10 .OR. ;
					SE1->E1_NATUREZ < mv_par11 .OR. SE1->E1_NATUREZ > mv_par12 .OR. ;
					SE1->E1_EMISSAO < mv_par13 .OR. SE1->E1_EMISSAO > mv_par14 .OR. ;
					SE1->E1_LOJA    < mv_par24 .OR. SE1->E1_LOJA    > mv_par25 .OR. ;
					dDtCtb          < mv_par27 .OR. dDtCtb          > mv_par28 .OR. ;
					(SE1->E1_EMISSAO > mv_par36 .and. !lEmissFutura)
					dbSkip()
					Loop
				Endif
			#ENDIF
			
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
						
			If mv_par20 == 1	// Considera Data Base
				nSaldo := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par15,dDataReaj,MV_PAR36,SE1->E1_LOJA,,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),mv_par37,.T.)
				//Verifica se existem compensa?es em outras filiais para descontar do saldo, pois a SaldoTit() somente
				//verifica as movimenta?es da filial corrente. Nao deve processar quando existe somente uma filial.   
				If lVerCmpFil .and. ( mv_par41 == 1 ) .and. ( nSaldo != SE1->E1_SALDO ) .and.;
									 aScan( aRecSE1Cmp , { |x| x[1] == SE1->( R_E_C_N_O_ ) } ) > 0

					nSaldo -= Round(NoRound(xMoeda(FRVlCompFil("R",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,mv_par37,aFiliais,cFilQry,lAS400),;
									SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(mv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA) ),0 ) ),;
									nDecs+1),nDecs)
				EndIf
 				// Subtrai decrescimo para recompor o saldo na data escolhida.
				If Str(SE1->E1_VALOR,17,2) == Str(nSaldo,17,2) .And. SE1->E1_DECRESC > 0 .And. SE1->E1_SDDECRE == 0
					nSAldo -= SE1->E1_DECRESC
				Endif
				// Soma Acrescimo para recompor o saldo na data escolhida.
				If Str(SE1->E1_VALOR,17,2) == Str(nSaldo,17,2) .And. SE1->E1_ACRESC > 0 .And. SE1->E1_SDACRES == 0
					nSAldo += SE1->E1_ACRESC 
				Endif

				//Se abatimento verifico a data da baixa.
				//Por nao possuirem movimento de baixa no SE5, a saldotit retorna 
				//sempre saldo em aberto quando mv_par33 = 1 (Abatimentos = Lista)
				If SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT .and. ;
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
				Endif 
				
				If ( cMVBR10925 == "1" .and. SE1->E1_EMISSAO <= MV_PAR36 .and. !(SE1->E1_TIPO $ "PIS/COF/CSL").and. !(SE1->E1_TIPO $ MVABATIM) ) ;
					 .AND. ( "S" $ (SA1->(A1_RECPIS+A1_RECCOFI+A1_RECCSLL) ) )
					nValPcc := SumAbatPCC(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,dBaixa,SE1->E1_CLIENTE,SE1->E1_LOJA,mv_par15)
					nSaldo -= nValPcc
				EndIf
				If SE1->E1_TIPO == "RA "   //somente para titulos ref adiantamento verifica se nao houve cancelamento da baixa posterior data base (mv_par36)
					nSaldo -= F130TipoBA()
				EndIf
			Else
				nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
			Endif
			
			// Se titulo do Template GEM
			If __lTempLOT .And. SE1->(FieldPos("E1_NCONTR")) > 0 .And. !Empty(SE1->E1_NCONTR) 
				nGem := CMDtPrc(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VENCREA)[2]
				If SE1->E1_VALOR==SE1->E1_SALDO
					nSaldo += nGem
				EndIf
			EndIf

			//Caso exista desconto financeiro (cadastrado na inclusao do titulo), 
			//subtrai do valor principal.
			If Empty( SE1->E1_BAIXA ) .Or. cMvDesFin == "P"
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
			
			If ! SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT
				If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. ;
						!( MV_PAR20 == 2 .And. nSaldo == 0 )  	// deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
				
				    //Busca as informa?es para alimentar a array aTitImp utilizando a fun?o F130RETIMP 
					dbSelectArea("__SE1")
			   		dbSetOrder(2)
			   		dbSeek(xFilial("SED")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
					cFilNat:= SE1->E1_NATUREZ				
					aTitImp:= F130RETIMP(cFilNat) 

					If ((nPos := (aScan(aTitImp, {|x| x[1] <> SE1->E1_TIPO }))) > 0 .and. aTitImp[nPos][2]) .OR.;
							 aScan(aAbatBaixa, {|x| ALLTRIM(x[2])==ALLTRIM(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)) }) > 0
                		   		
						//Quando considerar Titulos com emissao futura, eh necessario
						//colocar-se a database para o futuro de forma que a Somaabat()
						//considere os titulos de abatimento
						If lEmissFutura
							dOldData := dDataBase
							dDataBase := CTOD("31/12/40")
						Endif
						// Somente verifica abatimentos se existirem titulos deste tipo para o cliente
						If aScan( aCliAbt, SE1->(E1_CLIENTE + E1_LOJA) ) > 0
							nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mv_par15,dDataReaj,SE1->E1_CLIENTE,SE1->E1_LOJA)
						Else
							nAbatim := 0
						EndIf		
		
						If lEmissFutura
							dDataBase := dOldData
						Endif
	
						If mv_par33 != 1  //somente deve considerar abatimento no saldo se nao listar
							If STR(nSaldo,17,2) == STR(nAbatim,17,2)
								nSaldo := 0
							ElseIf mv_par33 == 2 //Se nao listar ele diminui do saldo
								nSaldo-= nAbatim
							Endif      
						Else
						    // Subtrai o Abatimento caso o mesmo j?tenho sido baixado ou n? esteja listado no relatorios
						  	nBx := aScan( aAbatBaixa, {|x| x[2]= SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) } )					  	
							If (SE1->E1_BAIXA <= dDataBase .and. !Empty(SE1->E1_BAIXA) .and. nBx>0)
						  		aDel( aAbatBaixa , nBx)
						  		aSize(aAbatBaixa, Len(aAbatBaixa)-1)
								nSaldo-= nAbatim
							EndIf                                        
						EndIf
					EndIf
				EndIf    
			Endif	
			nSaldo:=Round(NoRound(nSaldo,3),2)
			//????????????????????????????
			//?Desconsidera caso saldo seja menor ou igual a zero   ?
			//????????????????????????????
			If nSaldo <= 0
				dbSkip()
				Loop
			Endif
			
			If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .and. mv_par26 == 2
				dbSkip()
				Loop
			Endif
		
			SA1->( MsSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA) )
			SA6->( MsSeek(cFilial+SE1->E1_PORTADO) )

			IF li > 58
				nAtuSM0 := SM0->(Recno())
				SM0->(dbGoto(nRegSM0))
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
				SM0->(dbGoTo(nAtuSM0))
			EndIF
			
			If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
				
				@li,	0 PSAY SE1->E1_CLIENTE + "-" + SE1->E1_LOJA + "-" +;
					IIF(mv_par29 == 1, SubStr(SA1->A1_NREDUZ,1,20), SubStr(SA1->A1_NOME,1,20))
				li := IIf (aTamCli[1] > 6,li+1,li)
				
				@li, 31 PSAY SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA
				li := if( lTamNum > 9, li+1, li )
				     
				@li, 49 PSAY AllTrim(SE1->E1_TIPO)
				@li, 53 PSAY SE1->E1_NATUREZ
				@li, 64 PSAY SE1->E1_EMISSAO
				@li, 73 PSAY SE1->E1_VENCTO
				@li, 82 PSAY SE1->E1_VENCREA   
				
				If mv_par20 == 1  //Recompoe Saldo Retroativo              
				    //Titulo foi Baixado e Data da Baixa e menor ou igual a Data Base do Relat?io
				    IF !Empty(SE1->E1_BAIXA) 
				    	If SE1->E1_BAIXA <= mv_par36 .Or. !Empty( SE1->E1_PORTADO )
							@li, 92 PSAY SE1->E1_PORTADO+" "+SE1->E1_SITUACA
						EndIf   
					Else                                                                                   
					    //Titulo n? foi Baixado e foi transferido para Carteira e Data Movimento e menor 
				    	//ou igual a Data Base do Relat?io
						If Empty(SE1->E1_BAIXA) .and. SE1->E1_MOVIMEN <= mv_par36
							@li, 92 PSAY SE1->E1_PORTADO+" "+SE1->E1_SITUACA             
						EndIf
					ENDIF
				Else   // Nao Recompoe Saldo Retroativo
					@li, 92 PSAY SE1->E1_PORTADO+" "+SE1->E1_SITUACA 
				EndIf
				lAbatIMPBx := lEmissFutura .AND. SE1->E1_EMISSAO >= MV_PAR36 .AND. MV_PAR20 == 1 .AND. SE1->E1_TIPO $ "PIS/COF/CSL/IRF"
				nVlrOrig := Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))* If((SE1->E1_TIPO$MVABATIM +"/"+MVFUABT+"/"+MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM) .OR. lAbatIMPBx, -1,1),nDecs+1),nDecs)
				@li,98 PSAY nVlrOrig Picture TM(nVlrOrig,16,nDecs)
			Endif 
			
			If dDataBase > E1_VENCREA	//vencidos
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					@li,116 PSAY nSaldo * If((SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM +"/"+MVFUABT) .OR. lAbatIMPBx , -1,1) Picture TM(nSaldo,16,nDecs)
				EndIf 
				nJuros := 0
				// Somente chamad fa070juros se realmente houver necessidade de calculo de juros			
				If lFJurCst .Or. !Empty(SE1->E1_VALJUR) .Or. !Empty(SE1->E1_PORCJUR)
					dUltBaixa := SE1->E1_BAIXA
					#IFDEF TOP
						If MV_PAR20 == 1 // se compoem saldo retroativo verifico se houve baixas 
							If !Empty(dUltBaixa) .And. dDataBase < dUltBaixa
								dUltBaixa := FR130DBX() // Ultima baixa at?DataBase
							EndIf
						EndIf
					#ENDIF
					nJuros := fa070Juros(mv_par15,nSaldo,"SE1",dUltBaixa)
				EndIf	                                                           
				
				// Se titulo do Template GEM4
				If __lTempLOT .And. SE1->(FieldPos("E1_NCONTR")) > 0 .And. !Empty(SE1->E1_NCONTR) .And. SE1->E1_VALOR==SE1->E1_SALDO
					nJuros -= nGem
				EndIf
				dbSelectArea("SE1")
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					@li,133 PSAY (nSaldo+nJuros)* If((SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM +"/"+MVFUABT) .Or. lAbatIMPBx, -1,1) Picture TM(nSaldo+nJuros,16,nDecs)
				EndIf 
				If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .or. (mv_par33 == 1 .and. SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT) 
					nTit0 -= Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nTit1 -= (nSaldo)
					nTit2 -= (nSaldo+nJuros)
					nMesTit0 -= Round(NoRound( xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nMesTit1 -= (nSaldo)
					nMesTit2 -= (nSaldo+nJuros)
					nTotJur  -= nJuros
					nMesTitj -= nJuros
					nTotFilJ -= nJuros
				Else
					If !SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT
						nTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)											
						nTit1 += (nSaldo)
						nTit2 += (nSaldo+nJuros)
						nMesTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
						nMesTit1 += (nSaldo)
						nMesTit2 += (nSaldo+nJuros)
						nTotJur  += nJuros
						nMesTitj += nJuros
						nTotFilJ += nJuros
					Endif	
				Endif
			Else						//a vencer
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					@li,150 PSAY nSaldo * If((SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM +"/"+MVFUABT) .OR. lAbatIMPBx, -1,1) Picture TM(nSaldo,16,nDecs)
				EndIf   
				If ! ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM +"/"+MVFUABT) .and. !lAbatIMPBx
					nTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nTit3 += (nSaldo-nTotAbat)
					nTit4 += (nSaldo-nTotAbat)
					nMesTit0 += Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nMesTit3 += (nSaldo-nTotAbat)
					nMesTit4 += (nSaldo-nTotAbat)
				ElseIF ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG ) .or. (mv_par33 == 1 .and. SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT) .or. lAbatIMPBx
					nTit0 -= Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nTit3 -= (nSaldo-nTotAbat)
					nTit4 -= (nSaldo-nTotAbat)
					nMesTit0 -= Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),ndecs+1),ndecs)
					nMesTit3 -= (nSaldo-nTotAbat)
					nMesTit4 -= (nSaldo-nTotAbat)
				Endif
			Endif
			
			If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
				@ li, 169 PSAY Substr(SE1->E1_NUMBCO,1,15)
			EndIf
			If nJuros > 0
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					@ Li,180 PSAY nJuros Picture Tm(nJuros, 16,nDecs)//PesqPict("SE1","E1_JUROS",16,MV_PAR15)
				EndIf                                      
				nJuros := 0
			Endif
			
			IF dDataBase > SE1->E1_VENCREA .And. !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
				nAtraso:=dDataBase-SE1->E1_VENCTO
				IF Dow(SE1->E1_VENCTO) == 1 .Or. Dow(SE1->E1_VENCTO) == 7
					IF Dow(dBaixa) == 2 .and. nAtraso <= 2
						nAtraso := 0
					EndIF
				EndIF
				nAtraso:=IIF(nAtraso<0,0,nAtraso)
				IF nAtraso>0
					If mv_par19 == 1 //1 = Analitico - 2 = Sintetico                         
						@li ,If(SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM +"/"+MVFUABT, 197,197) PSAY nAtraso Picture "9999"
					EndIf                                                                            
				EndIF
			Else
				If !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
					nAtraso:=dDataBase-if(dDataBase==SE1->E1_VENCREA,SE1->E1_VENCREA,SE1->E1_VENCTO)
					nAtraso:=If(nAtraso<0,0,nAtraso)					
				Else
					nAtraso:=0
				EndIf						                                      
				
				If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
					@li ,If(SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM +"/"+MVFUABT, 197,197) PSAY nAtraso Picture "9999"
				EndIf	
			EndIF
			If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
				@li,203 PSAY SubStr(SE1->E1_HIST,1,16)+ ;
					IIF(E1_TIPO $ MVPROVIS,"*"," ")+ ;
					Iif(Str(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),15,2) == Str(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1,Iif(MV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),15,2),"","P")
			EndIf
			
			//?????????????????????
			//?Carrega data do registro para permitir ?
			//?posterior an?ise de quebra por mes.   ?
			//?????????????????????
			dDataAnt := Iif(nOrdem == 6, SE1->E1_EMISSAO, Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA))
			dbSkip()
			nTotTit ++
			nMesTTit ++
			nTotFiltit++
			nTit5 ++   
			If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
				li++
			EndIf
		Enddo
		
		If nOrdem == 3
			SA6->(dbSeek(xFilial()+cCarAnt))
		EndIf
			
		IF nTit5 > 0 .and. nOrdem != 2 .and. nOrdem != 10 
			SubTot130(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,nDecs)
			If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
				Li++
			EndIf
		Endif
		
		//?????????????????????
		//?Verifica quebra por m?	  			   ?
		//?????????????????????
		lQuebra := .F.
		If nOrdem == 4  .and. (Month(Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA)) # Month(dDataAnt) .or. Iif(mv_par40 = 2, SE1->E1_VENCTO, SE1->E1_VENCREA) > mv_par10)
			lQuebra := .T.
		Elseif nOrdem == 6 .and. (Month(SE1->E1_EMISSAO) # Month(dDataAnt) .or. SE1->E1_EMISSAO > mv_par14)
			lQuebra := .T.
		Endif
		If lQuebra .and. nMesTTit # 0
			ImpMes130(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ,nDecs)
			nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
		Endif
		nTot0+=nTit0
		nTot1+=nTit1
		nTot2+=nTit2
		nTot3+=nTit3
		nTot4+=nTit4
		nTotJ+=nTotJur
		
		nTotFil0+=nTit0
		nTotFil1+=nTit1
		nTotFil2+=nTit2
		nTotFil3+=nTit3
		nTotFil4+=nTit4
		lTemMov	:= .T.
		Store 0 To nTit0,nTit1,nTit2,nTit3,nTit4,nTit5,nTotJur,nTotAbat
	Enddo
	
	dbSelectArea("SE1")		// voltar para alias existente, se nao, nao funciona  
	                                                
	//?????????????????????
	//?Imprimir TOTAL por filial somente quan-?
	//?do houver mais do que 1 filial.        ?
	//?????????????????????
	If mv_par21 == 1 .and. SM0->(Reccount()) > 1 
		If lTemMov 		
			ImpFil130(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFiltit,nTotFilJ,nDecs,nOrdem)
		EndIf
	Endif
	lTemMov := .F.
	Store 0 To nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ
	If Empty(xFilial("SE1"))
		Exit
	Endif
	
	#IFDEF TOP
		dbSelectArea("SE1")
		dbCloseArea()
		ChKFile("SE1")
		dbSelectArea("SE1")
		dbSetOrder(1)
	#ENDIF
	dbSelectArea("SM0")
	dbSkip()
Enddo

SM0->(dbGoTo(nRegSM0))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

If cAliasProc != NIL .And.( MV_PAR37 == 2 .Or. MV_PAR37 == 3 )
	DelProc(cAliasProc)
	cAliasProc := NIL
Endif

IF li != 80
	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	EndIF
	TotGer130(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nDecs)
	Roda(cbcont,cbtxt,"G")
EndIF

Set Device To Screen

#IFNDEF TOP
	dbSelectArea("SE1")
	dbClearFil()
	RetIndex( "SE1" )
	If !Empty(cIndexSE1)
		FErase (cIndexSE1+OrdBagExt())
	Endif
	dbSetOrder(1)
#ELSE
	dbSelectArea("SE1")
	dbCloseArea()
	ChKFile("SE1")
	dbSelectArea("SE1")
	dbSetOrder(1)
#ENDIF

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()
SET CENTURY ON

Return

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?ubTot130 ?Autor ?Paulo Boschetti 		  ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?mprimir SubTotal do Relatorio										  ??
???????????????????????????????????????
??intaxe e ?SubTot130()																  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso 	    ?Generico																	  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function SubTot130(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,nDecs)

Local cCarteira := " "
Local lFR130Tel := ExistBlock("FR130TELC")
Local cCampoCli := ""
Local cTelefone := ""

If lFR130Tel
	cCampoCli := ExecBlock("FR130TELC",.F.,.F.)
	If !SA1->(FieldPos(cCampoCli)) > 0
		cCampoCli := ""
	EndIf
EndIf

cTelefone := Alltrim(Transform(SA1->A1_DDD, PesqPict("SA1","A1_DDD"))+"-"+ Iif(!Empty(cCampoCli),Transform(SA1->(&cCampocli),PesqPict("SA1",cCampoCli)),TransForm(SA1->A1_TEL,PesqPict("SA1","A1_TEL")) ) )

DEFAULT nDecs := Msdecimais(mv_par15)

If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
	li++
EndIf
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
If nOrdem = 1
	@li,000 PSAY IIF(mv_par29 == 1,Substr(SA1->A1_NREDUZ,1,40),Substr(SA1->A1_NOME,1,40))+" "+ cTelefone + " "+ STR0054 + Right(cCarAnt,2)+Iif(mv_par21==1,STR0055+cFilAnt + " - " + Alltrim(SM0->M0_FILIAL),"") //"Loja - "###" Filial - "
Elseif nOrdem == 4 .or. nOrdem == 6
	@li,000 PSAY OemToAnsi(STR0037)  // "S U B - T O T A L ----> "
	@li,028 PSAY cCarAnt
	@li,PCOL()+2 PSAY Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"  ")
Elseif nOrdem = 3
	@li,000 PSAY OemToAnsi(STR0037)  // "S U B - T O T A L ----> "
	@li,028 PSAY Iif(Empty(SA6->A6_NREDUZ),OemToAnsi(STR0029),SA6->A6_NREDUZ) + " " + Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
ElseIf nOrdem == 5
	dbSelectArea("SED")
	dbSeek(cFilial+cCarAnt)
	@li,000 PSAY OemToAnsi(STR0037)  // "S U B - T O T A L ----> "
	@li,028 PSAY cCarAnt + " "+Substr(ED_DESCRIC,1,50) + " " + Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
	dbSelectArea("SE1")
Elseif nOrdem == 7
	@li,000 PSAY OemToAnsi(STR0037)  // "S U B - T O T A L ----> "
	@li,028 PSAY SubStr(cCarAnt,7,2)+"/"+SubStr(cCarAnt,5,2)+"/"+SubStr(cCarAnt,3,2)+" - "+SubStr(cCarAnt,9,3) + " " +Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
ElseIf nOrdem = 8
	@li,000 PSAY SA1->A1_COD+" "+Substr(SA1->A1_NOME,1,40)+" "+ cTelefone + " " + Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
ElseIf nOrdem = 9
	cCarteira := Situcob(cCarAnt)
	@li,000 PSAY SA6->A6_COD+" "+SA6->A6_NREDUZ + SubStr(cCarteira,1,2) + " "+SubStr(cCarteira,3,20) + " " + Iif(mv_par21==1,cFilAnt+ " - " + Alltrim(SM0->M0_FILIAL),"")
Endif
If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
	@li,98 PSAY nTit0		  Picture TM(nTit0,16,nDecs)
Endif 
@li,116 PSAY nTit1		  Picture TM(nTit1,16,nDecs)
@li,133 PSAY nTit2		  Picture TM(nTit2,16,nDecs)
If nOrdem <> 5
	@li,150 PSAY nTit3		  Picture TM(nTit3,16,nDecs)
Else
	@li,151 PSAY nTit3		  Picture TM(nTit3,16,nDecs)
EndIf
If nTotJur > 0
	@li,180 PSAY nTotJur  Picture TM(nTotJur,16,nDecs)
Endif
@li,203 PSAY nTit2+nTit3 Picture TM(nTit2+nTit3,16,nDecs)

li++
If (nOrdem = 1 .Or. nOrdem == 8) .And. mv_par35 == 1 // Salta pag. por cliente
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
Endif
Return .T.

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?TotGer130?Autor ?Paulo Boschetti       ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?Imprimir total do relatorio										  ??
???????????????????????????????????????
??intaxe e ?TotGer130()																  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso      ?Generico																	  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
STATIC Function TotGer130(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nDecs)

DEFAULT nDecs := Msdecimais(mv_par15)

li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF

@li,000 PSAY OemToAnsi(STR0038) //"T O T A L   G E R A L ----> " + " " + Iif(mv_par21==1,cFilAnt,"")
@li,028 PSAY "("+ALLTRIM(STR(nTotTit))+" "+IIF(nTotTit > 1,OemToAnsi(STR0039),OemToAnsi(STR0040))+")"		//"TITULOS"###"TITULO"
If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
	@li,98 PSAY nTot0		  Picture TM(nTot0,16,nDecs)
Endif
@li,116 PSAY nTot1		  Picture TM(nTot1,16,nDecs)
@li,133 PSAY nTot2		  Picture TM(nTot2,16,nDecs)
If nOrdem <> 5
	@li,150 PSAY nTot3		  Picture TM(nTot3,16,nDecs)
Else
	@li,151 PSAY nTot3		  Picture TM(nTot3,16,nDecs)
EndIf
@li,180 PSAY nTotJ		  Picture TM(nTotJ,16,nDecs)
@li,203 PSAY nTot2+nTot3 Picture TM(nTot2+nTot3,16,nDecs)

li++
li++
Return .T.

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?mpMes130 ?Autor ?Vinicius Barreira	  ?Data ?12.12.94 ??
???????????????????????????????????????
??escri?o ?MPRIMIR TOTAL DO RELATORIO - QUEBRA POR MES					  ??
???????????????????????????????????????
??intaxe e ?ImpMes130() 															  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
STATIC Function ImpMes130(nMesTot0,nMesTot1,nMesTot2,nMesTot3,nMesTot4,nMesTTit,nMesTotJ,nDecs)

DEFAULT nDecs := Msdecimais(mv_par15)
li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
@li,000 PSAY OemToAnsi(STR0041)  //"T O T A L   D O  M E S ---> "
@li,028 PSAY "("+ALLTRIM(STR(nMesTTit))+" "+IIF(nMesTTit > 1,OemToAnsi(STR0039),OemToAnsi(STR0040))+")"  //"TITULOS"###"TITULO"
If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
	@li,98 PSAY nMesTot0   Picture TM(nMesTot0,16,nDecs)
Endif
@li,116 PSAY nMesTot1	Picture TM(nMesTot1,16,nDecs)
@li,133 PSAY nMesTot2	Picture TM(nMesTot2,16,nDecs)
@li,151 PSAY nMesTot3	Picture TM(nMesTot3,16,nDecs)
@li,180 PSAY nMesTotJ	Picture TM(nMesTotJ,16,nDecs)
@li,203 PSAY nMesTot2+nMesTot3 Picture TM(nMesTot2+nMesTot3,16,nDecs)
li+=2
Return(.T.)

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?ImpFil130?Autor ?Paulo Boschetti  	  ?Data ?01.06.92 ??
???????????????????????????????????????
??escri?o ?Imprimir total do relatorio										  ??
???????????????????????????????????????
??intaxe e ?ImpFil130()																  ??
???????????????????????????????????????
??arametros?																			  ??
???????????????????????????????????????
??Uso 	    ?Generico																	  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
STATIC Function ImpFil130(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ,nDecs,nOrdem)

DEFAULT nDecs := Msdecimais(mv_par15)

li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
@li,000 PSAY OemToAnsi(STR0043)+" "+Iif(mv_par21==1,cFilAnt+" - " + AllTrim(SM0->M0_FILIAL),"")  //"T O T A L   F I L I A L ----> "
If mv_par19 == 1 //1 = Analitico - 2 = Sintetico
	@li,98 PSAY nTotFil0        Picture TM(nTotFil0,16,nDecs)
Endif
@li,116 PSAY nTotFil1        Picture TM(nTotFil1,16,nDecs)
@li,133 PSAY nTotFil2        Picture TM(nTotFil2,16,nDecs)
If nOrdem <> 5
	@li,150 PSAY nTotFil3		  Picture TM(nTotFil3,16,nDecs)
Else
	@li,151 PSAY nTotFil3		  Picture TM(nTotFil3,16,nDecs)
EndIf
@li,180 PSAY nTotFilJ		  Picture TM(nTotFilJ,16,nDecs)
@li,203 PSAY nTotFil2+nTotFil3 Picture TM(nTotFil2+nTotFil3,16,nDecs)
li+=2
Return .T.

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?r130Indr ?Autor ?Wagner           	  ?Data ?12.12.94 ??
???????????????????????????????????????
??escri?o ?onta Indregua para impressao do relat?io						  ??
???????????????????????????????????????
??Uso		 ?Generico 																  ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
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

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?PutDtBase?Autor ?Mauricio Pequim Jr    ?Data ?18/07/02 ??
???????????????????????????????????????
??escri?o ?Acerta parametro database do relatorio                     ??
???????????????????????????????????????
??so       ?Finr130.prx                                                ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function PutDtBase()
Local _sAlias	:= Alias()

dbSelectArea("SX1")
dbSetOrder(1)
If MsSeek("FIN130    36")
	//Acerto o parametro com a database
	RecLock("SX1",.F.)
	Replace x1_cnt01		With "'"+DTOC(dDataBase)+"'"
	MsUnlock()	
Endif

dbSelectArea(_sAlias)
Return


/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?itucob   ?utor  ?auricio Pequim Jr. ?Data ?3.04.2005   ??
???????????????????????????????????????
??esc.     ?etorna situacao de cobranca do titulo                      ??
???????????????????????????????????????
??so       ?FINR130                                                    ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function SituCob(cCarAnt)

Local aSituaca := {}
Local aArea		:= GetArea()
Local cCart		:= " "

//????????????????????????????????????
//?Monta a tabela de situa?es de T?ulos										 ?
//????????????????????????????????????
dbSelectArea("SX5")
dbSeek(cFilial+"07")
While SX5->X5_FILIAL+SX5->X5_tabela == cFilial+"07"
	cCapital := Capital(X5Descri())
	AADD( aSituaca,{SubStr(SX5->X5_CHAVE,1,2),OemToAnsi(SubStr(cCapital,1,20))})
	dbSkip()
EndDo

nOpcS := (Ascan(aSituaca,{|x| Alltrim(x[1])== Substr(cCarAnt,4,1) }))
If nOpcS > 0
	cCart := aSituaca[nOpcS,1]+aSituaca[nOpcs,2]		
ElseIf Empty(SE1->E1_SITUACA)
	cCart := "0 "+STR0029
Endif
RestArea(aArea)
Return cCart

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?SumAbatPCC?Autor ?Igor Franzoi			 ?Data?9/12/2011 ??
???????????????????????????????????????
??escri?o ?Soma os abatimentos do PCC em caso de saldo retroativo	   ??
???????????????????????????????????????
??so       ?Finr130.prx                                                 ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function SumAbatPCC(cPrefixo,cNumero,cParcela,dDataRef,cCodCli,cLoja,nMoeda)

Local cAlias	:= Alias()
Local nOrdem	:= indexord()
Local cQuery	:= ""
Local nTotPcc	:= 0

DEFAULT nMoeda	:= 1

#IFDEF TOP

	cQryAlias := GetNextAlias()

	cQuery	:= " SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_EMISSAO, E1_VALOR, E1_TXMOEDA, E1_MOEDA, E1_TITPAI, R_E_C_N_O_ RECNO "
	cQuery	+= " FROM "+RetSqlName("SE1")
	cQuery	+= " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND "
	cQuery	+= " E1_PREFIXO = '"+cPrefixo+"' AND "
	cQuery	+= " E1_NUM = '"+cNumero+"' AND "
	cQuery	+= " E1_CLIENTE = '"+cCodCli+"' AND "
	cQuery	+= " E1_LOJA = '"+cLoja+"' AND "
	cQuery	+= " E1_TIPO IN ('PIS','COF','CSL') AND "
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

#ELSE

	If Select("__SE1") == 0
		ChkFile("SE1",.F.,"__SE1")
	Else
		dbSelectArea("__SE1")
	EndIf
	
	dbSetOrder(1)
	dbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela)
	
	While ( !Eof() .and. E1_FILIAL == xFilial("SE1") .and. E1_PREFIXO == cPrefixo .and. E1_NUM == cNumero )
		If ( AllTrim(E1_CLIENTE) == AllTrim(cCodCli) .and. AllTrim(E1_LOJA) == AllTrim(cLoja) )
			If ( E1_TIPO $  "PIS/COF/CSL" .and. E1_EMISSAO <= dDataRef ) .AND. FTITRAPAI( E1_TITPAI) //Verifica se o Titulo PAI e um RA e nao abate o PCC
				nTotPcc += xMoeda(E1_VALOR,E1_MOEDA,nMoeda,dDataRef,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
			EndIf
		EndIf
		dbSkip()
	EndDo
	
#ENDIF

DbSelectArea(cAlias)
DbSetOrder(nOrdem)

Return(nTotPcc)

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?justaSX1 ?utor  ?aphael Zampieri    ?Data ?1.06.2008   ??
???????????????????????????????????????
??esc.     ?justa perguntas da tabela SX1                              ??
??         ?                                                           ??
???????????????????????????????????????
??so       ?FINR130                                                    ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function AjustaSX1()

Local aArea := GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local aRegs		:= {}  
Local nTamTitSX3:= 0       
Local cGrupoSX3	:= ""


dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("E1_NUM")     
nTamTitSX3	:= SX3->X3_TAMANHO
cGrupoSX3	:= SX3->X3_GRPSXG  
dbSetOrder(1)

//            cPerg	Ordem	PergPort         cPerSpa        cPerEng           cVar  Tipo     nTam	 1 2 3    4   cVar01  cDef01  cDefSpa1    cDefEng1    cCont01	        cVar02	   cDef02           cDefSpa2         cDefEng2   cCnt02 cVar03 cDef03   cDefSpa3  cDefEng3  	cCnt03	cVar04	cDef04  cDefSpa4  cDefEng4  cCnt04 	cVar05 	 cDef05	 cDefSpa5  cDefEng5	 cCnt05	 cF3	cGrpSxg  cPyme	 aHelpPor aHelpEng	aHelpSpa  cHelp
AAdd(aRegs,{"FIN130", "05","Do Titulo  ?","?e Titulo  ?","From Bill  ?",  "mv_ch5","C",nTamTitSX3,0,0,"G","","mv_tit_de","",      "",         "",         "",               "",        "",              "",              "",       "",    "",   "",        "",      "",       "",     "",    "",      "",        "",      "",     "",      "",     "",       "",      "",   "",   cGrupoSX3, "S",     "",      "",        "",     ""})
AAdd(aRegs,{"FIN130", "06","Ate o Titulo  ?","? Titulo  ?","To Bill  ?",  "mv_ch6","C",nTamTitSX3,0,0,"G","","mv_tit_ate","",      "",         "",    "ZZZZZZZZZZZZZZZZZZZZ",          "",        "",              "",              "",       "",    "",   "",        "",      "",       "",     "",    "",      "",        "",      "",     "",      "",     "",       "",      "",   "",   cGrupoSX3, "S",     "",      "",        "",     ""})

ValidPerg(aRegs,"FIN130",.T.)

RestArea( aArea )
 
//Inclusao da pergunta: "Considera data - Vencimento ou Vencimento Real"
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

Aadd( aHelpPor, "Informe a data de vencimento que ser?"  )
Aadd( aHelpPor, "considerada na impressao do relat?io "  )

Aadd( aHelpSpa, "Informe la fecha de vencimiento que se "   )
Aadd( aHelpSpa, "considerar?en la impresi? del informe. " )

Aadd( aHelpEng, "Enter expiration date to be considered "  )
Aadd( aHelpEng, "to print the report."                     )


PutSx1( "FIN130", "40","Considera data","Considera fecha","Consider date","mv_chv","N",1,0,1,"C","","","","",;
	"mv_par40","Vencimento Real","Venc. Real","Real Expiration","","Vencimento","Vencimiento","Expiration","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Ajuste da pergunta: "Considera Adiantam. ? - MV_PAR26"
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

Aadd( aHelpPor, "Selecione a op?o ?im?para que os " )
Aadd( aHelpPor, "t?ulos referentes a adiantamentos, " )
Aadd( aHelpPor, "cadastrados sob os tipos ?A e NCC?" )
Aadd( aHelpPor, "devam ser considerados na gera?o do" )
Aadd( aHelpPor, " relat?io, ou ??? caso contr?io.")

Aadd( aHelpSpa, "Elija la opcion ?i?para que los ")
Aadd( aHelpSpa, "titulos referentes a anticipos, ")
Aadd( aHelpSpa, "registrados bajo los tipos ?A e NCC?")
Aadd( aHelpSpa, ", sean considerados en la generacion ")
Aadd( aHelpSpa, "del informe, o en caso contrario, ")
Aadd( aHelpSpa, "elija ?o?")                                  

Aadd( aHelpEng, "Select the option ?es?so that the ")     
Aadd( aHelpEng, "bills related to the advances ")
Aadd( aHelpEng, "registered under the types ?A and ")
Aadd( aHelpEng, "NCC?can be considered in the report")
Aadd( aHelpEng, " generation, or ?o? otherwise.")

PutHelp("P.FIN13026.",aHelpPor,aHelpEng,aHelpSpa,.T.)               

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

Aadd( aHelpPor, "Selecione a op?o '?im'?para que    " )
Aadd( aHelpPor, "sejam pesquisados movimentos em todas")
Aadd( aHelpPor, "filiais para procurar compensacoes  " )
Aadd( aHelpPor, "entre filiais. Caso nao tenha estes " )
Aadd( aHelpPor, "movimentos, seleciona 'N?'.        " )
Aadd( aHelpPor, "*Somente ambiente com SE5 exclusiva." )

Aadd( aHelpSpa, "Seleccione la opcion 'Si' para que  " )
Aadd( aHelpSpa, "se busquen los movimientos en todas " )
Aadd( aHelpSpa, "las sucursales para encontrar 		 " )
Aadd( aHelpSpa, "compensaciones entre sucursales.    " )
Aadd( aHelpSpa, "En caso de que existan estos        " )
Aadd( aHelpSpa, "movimientos, seleccione 'No'. Solo  ")
Aadd( aHelpSpa, "entorno con SE5 exclusiva." )

Aadd( aHelpEng, "Select option Yes so the transactions" )
Aadd( aHelpEng, "among branches as well as            " )
Aadd( aHelpEng, "compensations among branches are     " )
Aadd( aHelpEng, "searched. If there are no transactions" )
Aadd( aHelpEng, "select No. Only exclusive SES        " )
Aadd( aHelpEng, "environment.                         " )

PutSx1( "FIN130", "41","Compensa?o entre Filiais?","?Compensaciones sucursales?","Compensations branches?","mv_chx","N",1,0,2,"C","","","","",;
	"mv_par41","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
/*
GESTAO - inicio */
If SX1->(DbSeek(PadR("FIN130",Len(SX1->X1_GRUPO))+"21"))
	aHelpPor := {'Selecione a op?o "Sim" para que a','gera?o do relat?io considere as','filiais a serem informadas nos','par?etros seguintes, ou "N?",','caso contr?io. Esta pergunta n? ter?','efeito em ambientes TOPCONNECT /','TOTVSDBACCESS.'}
	aHelpSpa := {'Elija la opcion "Si" para que la','generacion del informe considere las','sucursales que se deben informar en los','siguientes parametros, o en caso','contrario, elija "No". Esta pregunta no','tendra efecto en el entorno TOPCONNECT/','TOTVSDBACCES.'}
	aHelpEng := {'Select the option "Yes" so that the','report generation can consider the','branches to be entered in the following','parameters. This question does not work','in TOPCONNECT/TOTVSDBACCESS environments'}
	PutSX1Help("P.FIN13021.",aHelpPor,aHelpEng,aHelpSpa,.T.)
Endif
If SX1->(DbSeek(PadR("FIN130",Len(SX1->X1_GRUPO))+"22"))
	aHelpPor := {'Informe o c?igo inicial do intervalo de',' filiais da sua empresa a serem',' consideradas na gera?o do relat?io,',' quando o par?etro anterior "Considera',' Filiais Abaixo?" estiver "Sim". Esta',' pergunta n? ter?efeito em ambientes',' TOPCONNECT / TOTVSDBACCESS.'}
	aHelpSpa := {'Digite el codigo inicial del intervalo','de sucursales de su empresa que se debe','considerar en la generacion del informe,','cuando el parametro anterior "?onsidera',' Siguientes Sucursales?" este "Si". Esta',' pregunta no tendra efecto en el',' entorno TOPCONNECT/TOTVSDBACCES.'} 
	aHelpEng := {'Enter the initial code of your company?',' branches interval to be considered in',' the report generation when the previous',' parameters ("Consider branches below?")','is marked with "Yes". This question does',' not work','in TOPCONNECT/TOTVSDBACCESS',' environments'}
	PutSX1Help("P.FIN13022.",aHelpPor,aHelpEng,aHelpSpa,.T.) 
Endif
If SX1->(DbSeek(PadR("FIN130",Len(SX1->X1_GRUPO))+"23"))
	aHelpPor := {'Informe o c?igo final do intervalo de','filiais da sua empresa a serem','consideradas na gera?o do relat?io,','quando o par?etro anterior "Considera','Filiais Abaixo?" estiver "Sim". Esta','pergunta n? ter?efeito em ambientes','TOPCONNECT / TOTVSDBACCESS.'} 
	aHelpSpa := {'Digite el codigo final del intervalo de','sucursales de su empresa que se debe','considerar en la generacion del informe,','cuando el parametro anterior "?onsidera','Siguientes Sucursales?" este "Si". Esta','pregunta no tendra efecto en el entorno','TOPCONNECT/TOTVSDBACCES.'}
	aHelpEng := {'Enter the final code of your company?','branches interval to be considered in','the report generation when the previous','parameters ("Consider branches below?")','is marked with "Yes". This question does','not work in TOPCONNECT/TOTVSDBACCESS.','environments.'}
	PutSX1Help("P.FIN13023.",aHelpPor,aHelpEng,aHelpSpa,.T.) 
Endif
If !(SX1->(DBSeek(PadR("FIN130",Len(SX1->X1_GRUPO))+"42")))
	aHelpPor := {"Escolha Sim se deseja selecionar ","as filiais. ","Esta pergunta somente ter?efeito em","ambiente TOTVSDBACCESS (TOPCONNECT) / ","TReport."}			
	aHelpEng := {"Enter Yes if you want to select ","the branches.","This question affects TOTVSDBACCESS","(TOPCONNECT) / TReport environment only."}
	aHelpSpa := {"La opci? S? permite seleccionar ","las sucursales.","Esta pregunta solo tendra efecto en el ","entorno TOTVSDBACCESS (TOPCONNECT) / ","TReport."}
	PutSx1( "FIN130", "42", "Seleciona Filiais?" ,"?elecciona sucursales?" ,"Select Branches?","mv_chW","N",1,0,2,"C","","","","S","mv_par42","Sim","Si ","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	PutSX1Help("P.FIN13042.",aHelpPor,aHelpEng,aHelpSpa,.T.)
Endif
/* GESTAO - fim 
*/
Return

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?FR130RetNat ?utor ?Gustavo Henrique  ?Data ?25/05/10   ??
???????????????????????????????????????
??escricao ?Retorna codigo e descricao da natureza para quebra do      ??
??         ?relatorio analitico por ordem de natureza.                 ??
???????????????????????????????????????
??arametros?EXPC1 - Codigo da natureza para pesquisa                   ??
???????????????????????????????????????
??so       ?Financeiro                                                 ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function FR130RetNat( cCodNat )

SED->( dbSetOrder( 1 ) )
SED->( MsSeek( xFilial("SED") + cCodNat ) )

Return( MascNat(SED->ED_CODIGO) + " - " + SED->ED_DESCRIC + If( mv_par21==1, cFilAnt + " - " + Alltrim(SM0->M0_FILIAL), "" ) )


/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?FR130TotSoma ?utor ?Gustavo Henrique ?Data ?05/26/10   ??
???????????????????????????????????????
??escricao ?Totaliza somatoria da coluna (Vencidos+A Vencer) quando    ??
??         ?selecionado relatorio por ordem de natureza e parametro    ??
??         ?MV_MULNATR ativado.                                        ??
???????????????????????????????????????
??so       ?Financeiro                                                 ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function FR130TotSoma( oTotCorr, oTotVenc, nTotVenc, nTotGeral, nOrdem )

nTotVenc	:= IIf(oTotCorr:GetValue() == NIL .OR. oTotVenc:GetValue() == NIL, nTotVenc, oTotCorr:GetValue() + oTotVenc:GetValue())

If nOrdem == 5 
	nTotGeral	+= nTotVenc
EndIf

Return .T.
/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??otina    ?r135Cond ?utor  ?laudio D. de Souza ?Data ? 28/08/01   ??
???????????????????????????????????????
??esc.     ?Avalia condicoes para filtrar os registros que serao       ??
??         ?impressos.                                                 ??
???????????????????????????????????????
??so       ?FINR135                                                    ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function Fr130Cond(cTipos)
Local lRet := .T.
Local dDtContab 
Local aArea		:= getArea()
Local aResult	:= {}
Local lProc		:= cAliasProc <> Nil

DEFAULT _nTamSEQ	:= TAMSX3('E5_SEQ')[1]
// dDtContab para casos em que o campo E1_EMIS1 esteja vazio
dDtContab := Iif(Empty(SE1->E1_EMIS1),SE1->E1_EMISSAO,SE1->E1_EMIS1)

//????????????????????????????????
//?Filtrar com base no Pto de entrada do Usuario...             ?
//??????????????Jose Lucas, Localiza?es Argentina?
Do Case
Case !Empty(SE1->E1_BAIXA)
	If mv_par20 == 2 .and. SE1->E1_SALDO == 0
		lRet := .F.
	Elseif SE1->E1_SALDO == 0

		If ( MV_PAR37 == 1 ) .and. SE1->E1_BAIXA <= dDataBase
			lRet := .F.
		ElseIf (cDBType != "DB2") .AND. ( ( MV_PAR37 == 2 ) .Or. ( MV_PAR37 == 3 ) )
			If cAliasProc == NIL
				cAliasProc	:= getNextAlias()
				#IFDEF TOP
					If TCSPExist( cAliasProc ) .And. !lProcCriad
						DelProc(cAliasProc)	
						lProcCriad := .T.					
					EndIf
									
					lProc := CriaProc(cAliasProc)
				#ENDIF
			Endif
			If lProc .AND. TCSPExist( cAliasProc )
				aResult := TCSPExec( cAliasProc , MV_PAR37, SE1->E1_FILIAL ,SE1->E1_PREFIXO ,SE1->E1_NUM ,;
								SE1->E1_PARCELA ,SE1->E1_TIPO ,SE1->E1_CLIENTE ,SE1->E1_LOJA )
		
				If !Empty(aResult)					
					lRet := Iif(StoD(aResult[1]) <= dDataBase, .F., .T.)
				Else
				    MsgInfo('Erro na execu?o da Stored Procedure : '+TcSqlError())
				    conout(TcSqlError())
				Endif
			Endif
		Endif
	Endif
//????????????????????????????
//?Verifica se trata-se de abatimento ou somente titulos?
//?at?a data base. 									 ?
//????????????????????????????
Case (MV_PAR33 == 3 .AND. SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT)
	lRet := .F.
//????????????????????????????
//?Verifica se ser?impresso titulos provis?ios		   ?
//????????????????????????????
Case SE1->E1_TIPO $ MVPROVIS .and. mv_par16 == 2
	lRet := .F.
//????????????????????????????
//?Verifica se ser?impresso titulos de Adiantamento	   ?
//????????????????????????????
Case SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .and. mv_par26 == 2
	lRet := .F.
Case !Empty(cTipos)
	If !(SE1->E1_TIPO $ cTipos)
	   lRet := .F.
	Endif
Case mv_par30 == 2 // nao imprime
	//?????????????????????
	//?Verifica se deve imprimir outras moedas?
	//?????????????????????
	If SE1->E1_MOEDA != mv_par15 // verifica moeda do campo=moeda parametro
		lRet := .F.
	Endif
EndCase

If !Empty(SE1->E1_BAIXA)
	//considera o abatimento do t?ulo, ap? a baixa 
	If !lRet .and. (MV_PAR37 == 2 .OR. MV_PAR37 == 3)  .and. mv_par26 == 1 .and. mv_par20 == 1 .and. allTrim(SE1->E1_TIPO) == "AB-" .and. SE1->E1_BAIXA >= dDataBase
		lRet := .T.	 	
	EndIf
EndIf

RestArea(aArea)
	
Return lRet
    
/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?040RETIMP?utor  ?Totvs              ?Data ? 30/07/12   ??
???????????????????????????????????????
??esc.     ?Efetua a validacao na exclusao do titulo                   ??
??         ?                                                           ??
???????????????????????????????????????
??so       ?AP                                                         ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/ 
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

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?TITPAI   ?utor Leandro Sousa         ?Data ? 12/23/11   ??
???????????????????????????????????????
??esc.     ?Caso algum titulo de abatimento tenho o campo E1_TITPAI em ??
??         ?branco a fun?o ira preencher para o relatorio ficar correto?
???????????????????????????????????????
??so       ?FINR130                                                   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/

Static Function FTITPAI()
Local aArea := GetArea()
Local aAreaSE1 := SE1->(GetArea())
Local cChave := xFilial("SE1")+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
Local cTitP 

DbSelectArea("__SE1")
dbSetOrder(2)
If DbSeek(cChave)
	While __SE1->(!Eof()) .and. cChave == xFilial("SE1")+__SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
		If ! __SE1->E1_TIPO $ MVABATIM +"/"+MVFUABT
			CTitP := PADR(__SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),TAMSX3('E1_TITPAI')[1])
			Exit
		EndIf	
	DbSkip()
	EndDo
EndIF

RestArea(aAreaSE1)            
RestArea(aArea)

Return cTitP

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?130TipoBA?utor  ?icrosiga           ?Data ? 13/08/12   ??
???????????????????????????????????????
??esc.     ?Rotina para buscar na SE5 quando titulo eh tipo RA para    ??
??         ?verificar a data de cancelamento que sera gravado no       ??
??         ?campo E5_HIST entre ###[AAAAMMDD]### a fim de compor o     ??
??         ?saldo adequadamente                                        ??
???????????????????????????????????????
??so       ?AP                                                         ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/


STATIC Function F130TipoBA()
Local nPosDtCanc := 0
Local nValor := 0
Local aArea := GetArea()
Local cChave := SE1->(E1_PREFIXO + E1_NUM +E1_PARCELA +E1_TIPO +E1_CLIENTE +E1_LOJA )

dbSelectArea("SE5")
dbSetOrder(7) // filial + prefixo + numero + parcela + tipo + clifor + loja + sequencia
If DbSeek(xFilial("SE5")+cChave)
	While SE5->(!EOF()) .and. cChave == SE5->(E5_PREFIXO + E5_NUMERO +E5_PARCELA +E5_TIPO +E5_CLIENTE +E5_LOJA )
		If SE5->E5_TIPODOC == "BA" .and. E5_SITUACA = 'C'
			If ( nPosDtCanc := At("###[", SE5->E5_HISTOR) ) > 0
				If  SE5->E5_DATA <= MV_PAR36 .And. STOD(SUBS(SE5->E5_HISTOR, nPosDtCanc+4,8)) > MV_PAR36
					nValor := SE5->E5_VALOR
					Exit
				EndIf
			EndIf
		Endif
		SE5->(dbSkip())
	EndDo
Endif

RestArea(aArea)

Return nValor

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?TITRAPAI ?utor  ?elso Carneiro      ?Data ? 15/08/12   ??
???????????????????????????????????????
??esc.     ?Verifica se o titulo de abatimento no campo E1_TITPAI e    ??
??         ?RA                                                         ??
???????????????????????????????????????
??so       ?FINR130                                                    ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/

Static Function FTITRAPAI(cTITPAI)
Local aArea    := GetArea()
Local lRet     := .T.
Local nTamPref := 0
Local nTamNum  := 0
Local nTamParc := 0
Local nTamTipo := 0
Local cTipo    := "" 
//Controla o Pis Cofins e Csll na RA (1 = Controla reten?o de impostos no RA; ou 2 = N? controla reten?o de impostos no RA(default))
Local lRaRtImp := If (FindFunction("FRaRtImp"),FRaRtImp(),.F.)

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
cQuery += "		and B.D_E_L_E_T_  = ' '  and B.E5_FILIAL  = SE1.E1_FILIAL  and B.E5_PREFIXO  = SE1.E1_PREFIXO  and B.E5_NUMERO  = SE1.E1_NUM " + CRLF 
cQuery += "		and B.E5_PARCELA  = SE1.E1_PARCELA  and B.E5_TIPO  = SE1.E1_TIPO  and B.E5_CLIFOR  = SE1.E1_CLIENTE  and B.E5_LOJA  = SE1.E1_LOJA " + CRLF				

cQuery += "	ELSE IF @IN_TIPDATA = 2 " + CRLF
cQuery += "		SELECT @cMaxDt = IsNull(MAX(B.E5_DTDISPO),' ') FROM " + RetSqlName("SE1") + " SE1," + RetSqlName("SE5") + " B " + CRLF
cQuery += "		WHERE SE1.E1_FILIAL  = @cFilial  and SE1.E1_PREFIXO  = @cPrefixo  and SE1.E1_NUM  = @cNumero  and SE1.E1_PARCELA  = @cParcela " + CRLF 
cQuery += "		and SE1.E1_TIPO  = @cTipo  and SE1.E1_CLIENTE  = @cCliente  and SE1.E1_LOJA  = @cLoja  and SE1.D_E_L_E_T_  = ' ' " + CRLF 
cQuery += "		and B.D_E_L_E_T_  = ' '  and B.E5_FILIAL  = SE1.E1_FILIAL  and B.E5_PREFIXO  = SE1.E1_PREFIXO  and B.E5_NUMERO  = SE1.E1_NUM " + CRLF 
cQuery += "		and B.E5_PARCELA  = SE1.E1_PARCELA  and B.E5_TIPO  = SE1.E1_TIPO  and B.E5_CLIFOR  = SE1.E1_CLIENTE  and B.E5_LOJA  = SE1.E1_LOJA " + CRLF		

cQuery += "	ELSE " + CRLF
cQuery += "		SELECT @cMaxDt = IsNull(MAX(B.E5_DTDIGIT),' ') FROM " + RetSqlName("SE1") + " SE1," + RetSqlName("SE5") + " B " + CRLF
cQuery += "		WHERE SE1.E1_FILIAL  = @cFilial  and SE1.E1_PREFIXO  = @cPrefixo  and SE1.E1_NUM  = @cNumero  and SE1.E1_PARCELA  = @cParcela " + CRLF 
cQuery += "		and SE1.E1_TIPO  = @cTipo  and SE1.E1_CLIENTE  = @cCliente  and SE1.E1_LOJA  = @cLoja  and SE1.D_E_L_E_T_  = ' ' " + CRLF 
cQuery += "		and B.D_E_L_E_T_  = ' '  and B.E5_FILIAL  = SE1.E1_FILIAL  and B.E5_PREFIXO  = SE1.E1_PREFIXO  and B.E5_NUMERO  = SE1.E1_NUM " + CRLF 
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
		UserException( "Erro na cria?o da procedure " + CRLF + TCSqlError()  + CRLF + cQuery )  //
	Endif
EndIf

Return lOk


Static Function FinSqlExec( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno := .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		#IFDEF TOP
			UserException( "Erro na instru?o de execu?o SQL" + CRLF + TCSqlError()  + CRLF + cStatement )  //
		#ENDIF
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
cQuery += " WHERE SE5.E5_FILIAL IN ('" + xFilial("SE1")  + "') " 
cQuery += " AND SE5.E5_PREFIXO = '" + SE1->E1_PREFIXO	 + "'"
cQuery += " AND SE5.E5_NUMERO = '"  + SE1->E1_NUM		 + "'"
cQuery += " AND SE5.E5_PARCELA = '" + SE1->E1_PARCELA	 + "'"
cQuery += " AND SE5.E5_TIPO = '" 	 + SE1->E1_TIPO	 	 + "'"
cQuery += " AND SE5.E5_CLIFOR = '"  + SE1->E1_CLIENTE	 + "'"
cQuery += " AND SE5.E5_LOJA = '"	 + SE1->E1_LOJA	 	 + "'"
cQuery += " AND SE5.E5_TIPODOC = 'VL'"
cQuery += " AND SE5.E5_DATA <= " + DTOS(dDataBase) 
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

@since 05/05/2014
@version P1180
 
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
