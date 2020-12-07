#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 16/05/02
#Include "PROTHEUS.CH"
#include "topconn.ch"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ BIAEC002   ≥ Autor ≥Fernando Rocha         ≥ Data ≥ 02.02.11 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Relatorio ESPELHO DE CARGA                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function BIAEC002()

Private nInpcOri:=0
Private oReport,oSection0, oSection1, oSection2, oSection3, oSection4, oSection5
Private aTotais:={}                    
             
Private cPerg := "BIEC02"
Private aRegs := {}

Private cQuery  :=  GetNextAlias()//"QUERY"

PRIVATE oFont06    := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
PRIVATE oFont07	   := TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
PRIVATE oFont07n   := TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
PRIVATE oFont08	   := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
PRIVATE oFont08n   := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
PRIVATE oFont09    := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)  
PRIVATE oFont09n   := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)  
PRIVATE oFont10    := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
PRIVATE oFont10n   := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
PRIVATE oFont11    := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
PRIVATE oFont12n   := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
PRIVATE oFont18N   := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)

oReport:=ReportDef()

ValPerg()
Pergunte(cPerg , .T. )

oReport:PrintDialog()  

Return

/*
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
*/
Static Function ReportDef()

Local cReport	:= "BIAEC002"
Local cAlias1	:= "ZZV"
Local cTitulo	:= "ESPELHO DE CARGA"
Local cDescri	:= "ESPELHO DE CARGA"
Local bReport	:= { |oReport|	oReport:SetTitle( oReport:Title() ),	ReportPrint( oReport ) }
Local aOrd 		:= {}
Local cEol		:= CHR(13)+CHR(10)

aOrd 			:= {}              

oReport  := TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
oReport:SetLandScape()
oReport:HideParamPage(.T.)


//CARGA
oSection1 := TRSection():New( oReport, "CABECALHO1", {cAlias1}, aOrd )
TRCell():New( oSection1, "ZZV_TICKET"	,,"TICKET"				,"@!",10 ,/*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New( oSection1, "ZZV_CARGA"	,,"CARGA"				,"@!",10 ,/*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New( oSection1, "ZZV_DATINC"	,,"DATA EMISSAO"		,"@!",10 ,/*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New( oSection1, "TRANSP"		,,"TRANSPORTADORA"		,"@!",400,/*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New( oSection1, "ZZV_PLACA"	,,"Placa"				,"@!",10 ,/*lPixel*/,/*{|| code-block de impressao }*/)   
TRCell():New( oSection1, "ZZV_MOTOR"	,,"Motorista"			,"@!",40 ,/*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New( oSection1, "ZZV_DOCMOT"	,,"Documento"			,"@!",30 ,/*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New( oSection1, "ZZV_OBS"		,,"ObservaÁ„o"			,"@!",400,/*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New( oSection1, "ZZV_CFRETE"	,,"Calc.Frete Autonomo?","@!",5  ,/*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New( oSection1, "ZZV_GALPAO"	,,"GALPAO"				,"@!",400,/*lPixel*/,/*{|| code-block de impressao }*/)  
oSection1:SetHeaderPage(.F.)
oSection1:SetHeaderBreak(.F.)
oSection1:SetHeaderSection(.F.)
oSection1:SetPageBreak(.T.)   
oSection1:SetLineStyle() 
oSection1:SetTotalInLine(.F.)

//CLIENTE
oSection2 := TRSection():New( oSection1, "CABECALHO2", {cAlias1}, aOrd )
TRCell():New( oSection2, "CLIENTE"     	,,"CLIENTE","@!",200,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "OBSCLI"     	,,"Obs.Cliente","@!",200,/*lPixel*/, {|| (cQuery)->OBSCLI  + IIF(!Empty((cQuery)->OBSEXP),' - '+(cQuery)->OBSEXP,'') } /*{|| code-block de impressao }*/)
oSection2:SetHeaderPage(.F.)
oSection2:SetHeaderBreak(.F.)
oSection2:SetHeaderSection(.T.)
oSection2:SetPageBreak(.F.)   
oSection2:SetLineStyle() 
 

//ITENS
If cEmpAnt == "13"
	oSection3 := TRSection():New( oSection2, "DETALHE", {cAlias1}, aOrd )
	TRCell():New( oSection3, "C9_PEDIDO"	,,"Pedido"		,"@!"				,10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "C9_ITEM"		,,"Item"		,"@!"				,4 ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "C9_PRODUTO"	,,"Produto"		,"@!"				,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "B1_DESC"		,,"DescriÁ„o"	,"@!"				,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "C9_LOTECTL"	,,"Lote"		,"@!"				,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "Z9_LOCALIZ"	,,"Local."		,"@!"				,8 ,/*lPixel*/,/*{|| code-block de impressao }*/)    
	TRCell():New( oSection3, "PALETE"   	,,"Pallets"		,"@!"				,15,/*lPixel*/,/*{|| code-block de impressao }*/)    
	TRCell():New( oSection3, "C9_QTDLIB"	,,"M2"			,"@E 999,999,999.99",16,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "C9_QTDLIB2"	,,"CAIXAS"		,"@E 999,999,999"	,16,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "C9_PRCVEN"	,,"Preco Un."	,"@E 999,999,999.99",16,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "PESOBR"		,,"PESO BR (Kg)","@E 999,999,999.99",16,/*lPixel*/,/*{|| code-block de impressao }*/)
Else
	oSection3 := TRSection():New( oSection2, "DETALHE", {cAlias1}, aOrd )
	TRCell():New( oSection3, "C9_PEDIDO"	,,"Pedido"		,"@!"				,12,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "C9_ITEM"		,,"Item"		,"@!"				,6 ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "C9_PRODUTO"	,,"Produto"		,"@!"				,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "B1_DESC"		,,"DescriÁ„o"	,"@!"				,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "TON"			,,"Ton."		,"@!"				,4 ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "TAM"			,,"Tam."		,"@!"				,4 ,/*lPixel*/,/*{|| code-block de impressao }*/)    
	TRCell():New( oSection3, "C9_QTDLIB"	,,"M2"			,"@E 999,999,999.99",18,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "C9_QTDLIB2"	,,"CAIXAS"		,"@E 999,999,999"	,18,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "C9_PRCVEN"	,,"Preco Un."	,"@E 999,999,999.99",18,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection3, "PESOBR"		,,"PESO BR (Kg)","@E 999,999,999.99",18,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf

oSection3:SetHeaderPage(.F.)
oSection3:SetHeaderBreak(.F.)
oSection3:SetHeaderSection(.T.)
oSection3:nLeftMargin := 5
                                  
TRFunction():New(oSection3:Cell("C9_QTDLIB"),,"SUM",,"M2",,,.T.,.F.)
TRFunction():New(oSection3:Cell("C9_QTDLIB2"),,"SUM",,"CAIXAS",,,.T.,.F.)
TRFunction():New(oSection3:Cell("PESO BR (Kg)"),,"SUM",,"PESO",,,.T.,.F.)
oSection3:SetTotalInLine(.F.)
oReport:SetTotalInLine(.F.)
oSection3:SetTotalText("TOTAIS")


oSection4 := TRSection():New(oReport, "Totais", "TEMP")    
TRCell():New( oSection4, "DESCRICAO"	,,"Forno"		,"@",40,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection4, "QUANT1"		,,"Quant. M2"	,"@",20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection4, "QUANT2"		,,"Caixas"		,"@",20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection4, "QUANT3"		,,"PESO BR (Kg)","@",20,/*lPixel*/,/*{|| code-block de impressao }*/)

//TRFunction():New(oSection4:Cell("QUANTIDADE"),,"SUM",,"QUANT",,,,.T.)
//oSection4:SetTotalInLine(.F.)
//oReport:SetTotalInLine(.F.)
	

  
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
Local cChave
Local nOrder  := oSection1:GetOrder() 
Local cExpWhere := ""
Local cExpOrder               
Local cExpCliente
Local cExpObsCli
Local cPalete
Local cEol	:= CHR(13)+CHR(10)
Local nSA1	:= RetSqlName("SA1")
Local nSC5	:= RetSqlName("SC5")
Local nCC2	:= RetSqlName("CC2")
Local nZ41	:= RetSqlName("Z41")

Local cCodCarga := ""
Local cCodCli 	:= ""
Local aTotaliza	:= {}


cExpCliente	:= "%  (SELECT A1_COD+'/'+A1_LOJA+' - '+RTRIM(A1_NOME)+' - ('+(SELECT TOP 1 RTRIM(Z41_DESCR) FROM "+nZ41+" Z41 WHERE Z41.D_E_L_E_T_ = '' AND Z41.Z41_TPSEG = SA1.A1_YTPSEG)+')' FROM "+nSA1+" SA1 (nolock) WHERE A1_COD+A1_LOJA = ISNULL((select C5_YCLIORI+C5_YLOJORI from "+nSC5+" SC5 (nolock) where C5_NUM = ZZW_PEDIDO AND SC5.C5_YCLIORI<>'' AND SC5.D_E_L_E_T_<>'*'),ZZW_CCLI+ZZW_LCLI) AND SA1.D_E_L_E_T_<>'*') "+;
				"+'      Municipio: '+(SELECT RTRIM(CC2_MUN) FROM "+nCC2+" CC2 (nolock) WHERE CC2_EST+CC2_CODMUN = (SELECT A1_EST+A1_COD_MUN FROM "+nSA1+" SA1 (nolock) WHERE A1_COD+A1_LOJA = ISNULL((select C5_YCLIORI+C5_YLOJORI from "+nSC5+" SC5 (nolock) where C5_NUM = ZZW_PEDIDO AND SC5.C5_YCLIORI<>'' AND SC5.D_E_L_E_T_<>'*'),ZZW_CCLI+ZZW_LCLI) AND SA1.D_E_L_E_T_<>'*') AND CC2.D_E_L_E_T_<>'*') "+;
				"+'      UF: '+(SELECT A1_EST FROM "+nSA1+" SA1 (nolock) WHERE A1_COD+A1_LOJA = ISNULL((select C5_YCLIORI+C5_YLOJORI from "+nSC5+" SC5 (nolock) where C5_NUM = ZZW_PEDIDO AND SC5.C5_YCLIORI<>'' AND SC5.D_E_L_E_T_<>'*'),ZZW_CCLI+ZZW_LCLI)  AND SA1.D_E_L_E_T_<>'*') CLIENTE   %"

cExpObsCli	:= "%  (SELECT A1_YOBSROM FROM "+nSA1+" SA1 (nolock) WHERE A1_COD+A1_LOJA = ISNULL((select C5_YCLIORI+C5_YLOJORI from "+nSC5+" SC5 (nolock) where C5_NUM = ZZW_PEDIDO AND SC5.C5_YCLIORI<>'' AND SC5.D_E_L_E_T_<>'*'),ZZW_CCLI+ZZW_LCLI) AND SA1.D_E_L_E_T_<>'*') OBSCLI %"

        
	oSection1:BeginQuery()
	If cEmpAnt == "13"

		BeginSql Alias cQuery       	
			%noparser%   
			SELECT
			ZZV_CARGA
			,ZZV_TICKET
			,ZZV_DATINC
			,ZZV_TRANSP+' - '+RTRIM(A4_NOME) TRANSP
			,ZZV_PLACA
			,ZZV_MOTOR 		
			,ZZV_DOCMOT  			
			,ZZV_OBS 
			,ZZV_CFRETE
			,ZZV_GALPAO
			
			,%Exp:cExpCliente%
			,%Exp:cExpObsCli%
					
			,OBSEXP = ''
			,C9_PEDIDO
			,C9_ITEM
			,C9_PRODUTO
			,B1_DESC
			,Z9_LOCALIZ 
			,LTRIM(RTRIM((SELECT dbo.FN_PALETE(C9_PRODUTO,Z9_QTDLIB,C9_LOTECTL)))) PALETE
			,C9_LOTECTL		
			,Z9_QTDLIB AS C9_QTDLIB
			,Z9_QTDLIB2 AS C9_QTDLIB2   
			,C9_PRCVEN 
			,PESOBR = CASE WHEN B1_TIPCONV = 'M'
				  THEN (Z9_QTDLIB  * 
					ISNULL((SELECT ZZ9_PESO FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))
					+ ((Z9_QTDLIB * B1_CONV) * 
					ISNULL((SELECT ZZ9_PESEMB FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB))
				  ELSE (Z9_QTDLIB  * ISNULL((SELECT ZZ9_PESO FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))
					 + ((Z9_QTDLIB / B1_CONV) * ISNULL((SELECT ZZ9_PESEMB FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB))
				  END
			
			FROM %Table:ZZW% ZZW (nolock)
			JOIN %Table:SC9% SC9 (nolock) ON C9_FILIAL = ZZW_FILIAL AND C9_PEDIDO = ZZW_PEDIDO AND C9_ITEM = ZZW_ITEM AND C9_SEQUEN = ZZW_SEQUEN AND SC9.D_E_L_E_T_ <> '*'
			JOIN %Table:SZ9% SZ9 (nolock) ON C9_PEDIDO = Z9_PEDIDO AND C9_PRODUTO = Z9_PRODUTO AND C9_ITEM	 = Z9_ITEM AND C9_SEQUEN = Z9_SEQUEN AND SZ9.D_E_L_E_T_ <> '*' 
			JOIN %Table:ZZV% ZZV (nolock) ON ZZV_FILIAL = ZZW_FILIAL AND ZZV_CARGA = ZZW_CARGA AND ZZV.D_E_L_E_T_<>'*'
			JOIN %Table:SB1% SB1 (nolock) ON SB1.B1_COD = SC9.C9_PRODUTO AND SB1.D_E_L_E_T_<>'*'
			LEFT JOIN %Table:SA4% SA4 (nolock) ON SA4.A4_COD = ZZV.ZZV_TRANSP AND SA4.D_E_L_E_T_<>'*'	
			
			WHERE
				ZZW.D_E_L_E_T_<>'*'
				AND ZZV.ZZV_FILIAL = '01'
				AND ZZV.ZZV_CARGA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND ZZV.D_E_L_E_T_<>'*'
			
			ORDER BY ZZV_CARGA, CLIENTE, C9_PEDIDO, C9_ITEM, C9_PRODUTO 
		EndSql  
	
  Else

		BeginSql Alias cQuery       	
			%noparser%   
			SELECT
			ZZV_CARGA
			,ZZV_TICKET
			,ZZV_DATINC
			,ZZV_TRANSP+' - '+RTRIM(A4_NOME) TRANSP
			,ZZV_PLACA  
			,ZZV_MOTOR 		
			,ZZV_DOCMOT			
			,ZZV_OBS 
			,ZZV_CFRETE
			,ZZV_GALPAO
			
			,%Exp:cExpCliente%
			,%Exp:cExpObsCli%
					
			,OBSEXP = case when exists (select 1 from ZZW010 X (nolock)
									join SC5010 X1 (nolock) on C5_NUM = ZZW_PEDIDO
									where X.ZZW_CARGA = ZZV_CARGA and X1.C5_YSUBTP = 'FE' and X1.C5_CLIENTE = '017151'
									and X1.D_E_L_E_T_='' and X.D_E_L_E_T_='')
						then 'Pedidos p/ExportaÁ„o - Filmar os Produtos' else '' end
			,C9_PEDIDO
			,C9_ITEM
			,C9_PRODUTO
			,B1_DESC
			,SUBSTRING(C9_LOTECTL,1,2) TON
			,SUBSTRING(C9_LOTECTL,3,3) TAM     
			,LTRIM(RTRIM((SELECT dbo.FN_PALETE(C9_PRODUTO,C9_QTDLIB,C9_LOTECTL)))) PALETE
			,C9_LOTECTL
			,C9_QTDLIB
			,C9_QTDLIB2   
			,C9_PRCVEN  
			,PESOBR = CASE WHEN B1_TIPCONV = 'M'
				  THEN (C9_QTDLIB  * 
					ISNULL((SELECT ZZ9_PESO FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))
					+ ((C9_QTDLIB * B1_CONV) * 
					ISNULL((SELECT ZZ9_PESEMB FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB))
				  ELSE (C9_QTDLIB  * ISNULL((SELECT ZZ9_PESO FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))
					 + ((C9_QTDLIB / B1_CONV) * ISNULL((SELECT ZZ9_PESEMB FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB))
				  END
			
			FROM %Table:ZZW% ZZW (nolock)
			JOIN %Table:SC9% SC9 (nolock) ON C9_FILIAL = ZZW_FILIAL AND C9_PEDIDO = ZZW_PEDIDO AND C9_ITEM = ZZW_ITEM AND C9_SEQUEN = ZZW_SEQUEN AND SC9.D_E_L_E_T_ <> '*'
			JOIN %Table:ZZV% ZZV (nolock) ON ZZV_FILIAL = ZZW_FILIAL AND ZZV_CARGA = ZZW_CARGA AND ZZV.D_E_L_E_T_<>'*'
			JOIN %Table:SB1% SB1 (nolock) ON SB1.B1_COD = SC9.C9_PRODUTO AND SB1.D_E_L_E_T_<>'*'
			LEFT JOIN %Table:SA4% SA4 (nolock) ON SA4.A4_COD = ZZV.ZZV_TRANSP AND SA4.D_E_L_E_T_<>'*'	
			
			WHERE
				ZZW.D_E_L_E_T_<>'*'
				AND ZZV.ZZV_FILIAL = '01'
				AND ZZV.ZZV_CARGA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND ZZV.D_E_L_E_T_<>'*'
			
			ORDER BY ZZV_CARGA, CLIENTE, C9_PEDIDO, C9_ITEM, C9_PRODUTO
		EndSql  


  EndIf

	/*MemoWrite("\BIAEC002.TXT", GetLastQuery()[2])    
	
	oSection1:Init()
	oSection2:Init()
	oSection3:Init()
	   
	
	While !(cQuery)->(EoF())
	    
	    oSection1:Cell("ZZV_TICKET"):SetValue((cQuery)->ZZV_TICKET)
	    oSection1:Cell("ZZV_CARGA"):SetValue((cQuery)->ZZV_CARGA)
	    oSection1:Cell("ZZV_DATINC"):SetValue((cQuery)->ZZV_DATINC)
	    oSection1:Cell("TRANSP"):SetValue((cQuery)->TRANSP)
	    oSection1:Cell("ZZV_PLACA"):SetValue((cQuery)->ZZV_PLACA)
	    oSection1:Cell("ZZV_MOTOR"):SetValue((cQuery)->ZZV_MOTOR)
	    oSection1:Cell("ZZV_DOCMOT"):SetValue((cQuery)->ZZV_DOCMOT)
	    oSection1:Cell("ZZV_OBS"):SetValue((cQuery)->ZZV_OBS)
	    oSection1:Cell("ZZV_CFRETE"):SetValue((cQuery)->ZZV_CFRETE)
	    
	    oSection1:PrintLine()
	    
	    cCodCli 	:= (cQuery)->CLIENTE
	    cCodCarga	:= (cQuery)->ZZV_CARGA
	    
	    While (!(cQuery)->(EoF()) .And. AllTrim((cQuery)->ZZV_CARGA) == AllTrim(cCodCarga))
	    	
	    	oSection2:Cell("CLIENTE"):SetValue((cQuery)->CLIENTE)
		    oSection2:Cell("OBSCLI"):SetValue((cQuery)->OBSCLI  + IIF(!Empty((cQuery)->OBSEXP),' - '+(cQuery)->OBSEXP,''))
		    oSection2:PrintLine()
		    
		    While !(cQuery)->(EoF()) .And. AllTrim((cQuery)->ZZV_CARGA)+AllTrim((cQuery)->CLIENTE) == AllTrim(cCodCarga)+AllTrim(cCodCli)
		    	
		    	If cEmpAnt == "13"
		    		
		    		oSection3:Cell("C9_PEDIDO"):SetValue((cQuery)->C9_PEDIDO)
		    		oSection3:Cell("C9_ITEM"):SetValue((cQuery)->C9_ITEM)
		    		oSection3:Cell("C9_PRODUTO"):SetValue((cQuery)->C9_PRODUTO)
		    		oSection3:Cell("B1_DESC"):SetValue((cQuery)->B1_DESC)
		    		oSection3:Cell("C9_LOTECTL"):SetValue((cQuery)->C9_LOTECTL)
		    		oSection3:Cell("Z9_LOCALIZ"):SetValue((cQuery)->Z9_LOCALIZ)
		    		oSection3:Cell("PALETE"):SetValue((cQuery)->PALETE)
		    		oSection3:Cell("C9_QTDLIB"):SetValue((cQuery)->C9_QTDLIB)
		    		oSection3:Cell("C9_QTDLIB2"):SetValue((cQuery)->C9_QTDLIB2)
		    		oSection3:Cell("C9_PRCVEN"):SetValue((cQuery)->C9_PRCVEN)
		    		oSection3:Cell("PESOBR"):SetValue((cQuery)->PESOBR)
		    		
				Else
					
					oSection3:Cell("C9_PEDIDO"):SetValue((cQuery)->C9_PEDIDO)
		    		oSection3:Cell("C9_ITEM"):SetValue((cQuery)->C9_ITEM)
		    		oSection3:Cell("C9_PRODUTO"):SetValue((cQuery)->C9_PRODUTO)
		    		oSection3:Cell("B1_DESC"):SetValue((cQuery)->B1_DESC)
		    		oSection3:Cell("TON"):SetValue((cQuery)->TON)
		    		oSection3:Cell("TAM"):SetValue((cQuery)->TAM)
		    		oSection3:Cell("C9_QTDLIB"):SetValue((cQuery)->C9_QTDLIB)
		    		oSection3:Cell("C9_QTDLIB2"):SetValue((cQuery)->C9_QTDLIB2)
		    		oSection3:Cell("C9_PRCVEN"):SetValue((cQuery)->C9_PRCVEN)
		    		oSection3:Cell("PESOBR"):SetValue((cQuery)->PESOBR)
					
				EndIf
		    	
		    	oSection3:PrintLine()
		    	(cQuery)->(DbSkip())
		    EndDo
		    
	    	
	    EndDo
	    
	    
	EndDo
	
	(cQuery)->(DbCloseArea())
	
	oSection3:Finish()	
    oSection2:Finish()	
    oSection1:Finish()	
    ImpTotal()
    
    */
    
    
	oSection1:EndQuery()    	
	MemoWrite("\BIAEC002.TXT", GetLastQuery()[2])                	
	
	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cQuery)->(ZZV_CARGA) ==  cParam },{|| (cQuery)->(ZZV_CARGA) })    
	
	oSection3:SetParentQuery()                                                                               
	oSection3:SetParentFilter({|cParam| (cQuery)->(ZZV_CARGA+CLIENTE) ==  cParam },{|| (cQuery)->(ZZV_CARGA+CLIENTE) })    
	
	oSection1:Print()
	
	ImpTotal()

Return Nil   

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±≥DescriáÖo ≥ Cria as perguntas do relatorio                             ≥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function ValPerg()      
Local i,j   
Local aTRegs := {}

cPerg := PADR(cPerg,10)

/*01*/aAdd(aTRegs,{"No Carga De?","C",4,0,0,"G","","","","","","",""})
/*01*/aAdd(aTRegs,{"No Carga Ate?","C",4,0,0,"G","","","","","","",""})

//Criar aRegs na ordem do vetor Temporario 
aRegs := {}
For I := 1 To Len(aTRegs)
	aAdd(aRegs,{cPerg,StrZero(I,2),aTRegs[I][1],aTRegs[I][1],aTRegs[I][1]	,"mv_ch"+Alltrim(Str(I)),aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],aTRegs[I][6],aTRegs[I][7],;
	"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","","",aTRegs[I][12],"","","",aTRegs[I][13],""})
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
	Endif
Next
Return

Static function ImpTotal()

	Local cAliasTrab	:= Nil
	Local cMQuery		:= ""
	Local nI			:= 0	
	Local aEmpresa		:= {"Baincogres", "Incesa"}
	Local aListaFor		:= {"F01/F02/F03", "F04/F05"}
	Local nSoma1		:= 0
	Local nSoma2		:= 0
	Local nSoma3		:= 0
	Local nSomaTot1		:= 0
	Local nSomaTot2		:= 0
	Local nSomaTot3		:= 0
	
	
	oSection4:Init()
	
	For nI:=1 To Len (aListaFor)
		
		cMQuery		:= MontaQuery(aListaFor[nI], 1)
		cAliasTrab 	:= GetNextAlias()
		
		TCQUERY cMQuery NEW ALIAS cAliasTrab	
		
		If !(cAliasTrab->(Eof()))
		
			oSection4:Cell("DESCRICAO"		):SetAlign(1)
			oSection4:Cell("QUANT1"		):SetAlign(1)
			oSection4:Cell("QUANT2"		):SetAlign(1)
			oSection4:Cell("QUANT2"		):SetAlign(1)
			
			oSection4:Cell("DESCRICAO"		):SetValue(aEmpresa[nI])
			oSection4:Cell("QUANT1"		):SetValue("")
			oSection4:Cell("QUANT2"		):SetValue("")
			oSection4:Cell("QUANT3"		):SetValue("")
			oSection4:PrintLine()	
				
			nSoma1 := 0
			nSoma2 := 0
			nSoma3 := 0
			While !(cAliasTrab->(Eof()))
		
				oSection4:Cell("DESCRICAO"		):SetValue(cvaltochar(cAliasTrab->DESCRICAO))
				oSection4:Cell("QUANT1"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT1,"@E 999,999,999.99")))
				oSection4:Cell("QUANT2"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT2,"@E 999,999,999.99")))
				oSection4:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT3,"@E 999,999,999.99")))
				oSection4:PrintLine()
				
				nSoma1 += cAliasTrab->QUANT1
				nSoma2 += cAliasTrab->QUANT2
				nSoma3 += cAliasTrab->QUANT3
				cAliasTrab->(DbSkip())
			EndDo
			
			nSomaTot1 += nSoma1
			nSomaTot2 += nSoma2
			nSomaTot3 += nSoma3
			
			If (nSoma1 > 0 .Or. nSoma2 > 0 .Or. nSoma3 > 0)
				oReport:SkipLine()
				oSection4:Cell("DESCRICAO"		):SetAlign(3)
				oSection4:Cell("DESCRICAO"		):SetValue("Total:")
				oSection4:Cell("QUANT1"		):SetAlign(1)
				oSection4:Cell("QUANT1"		):SetValue(cvaltochar(TRANSFORM(nSoma1,"@E 999,999,999.99")))
				oSection4:Cell("QUANT2"		):SetAlign(1)
				oSection4:Cell("QUANT2"		):SetValue(cvaltochar(TRANSFORM(nSoma2,"@E 999,999,999.99")))
				oSection4:Cell("QUANT3"		):SetAlign(1)
				oSection4:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(nSoma3,"@E 999,999,999.99")))
				
				oSection4:PrintLine()
				oReport:SkipLine()
			EndIf	
			
			oReport:SkipLine()
		EndIf
		
		cAliasTrab->(DbCloseArea())
	Next nI
	
	
	//Total por Categoria
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()
	
	
	cMQuery		:= MontaQuery("", 2)
	cAliasTrab 	:= GetNextAlias()
		
	TCQUERY cMQuery NEW ALIAS cAliasTrab	
	
	While !(cAliasTrab->(Eof()))
		
		oSection4:Cell("DESCRICAO"		):SetAlign(1)
		oSection4:Cell("DESCRICAO"	):SetValue(cvaltochar(cAliasTrab->DESCRICAO))
		oSection4:Cell("QUANT1"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT1,"@E 999,999,999.99")))
		oSection4:Cell("QUANT2"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT2,"@E 999,999,999.99")))
		oSection4:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT3,"@E 999,999,999.99")))
		oSection4:PrintLine()
		
		cAliasTrab->(DbSkip())
		
	EndDo
	cAliasTrab->(DbCloseArea())			
	//Fim total Categoria	
	
	
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()
	oSection4:Cell("DESCRICAO"		):SetAlign(3)
	oSection4:Cell("DESCRICAO"		):SetValue("Total:")
	oSection4:Cell("QUANT1"		):SetAlign(1)
	oSection4:Cell("QUANT1"		):SetValue(cvaltochar(TRANSFORM(nSomaTot1,"@E 999,999,999.99")))
	oSection4:Cell("QUANT2"		):SetAlign(1)
	oSection4:Cell("QUANT2"		):SetValue(cvaltochar(TRANSFORM(nSomaTot2,"@E 999,999,999.99")))
	oSection4:Cell("QUANT3"		):SetAlign(1)
	oSection4:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(nSomaTot3,"@E 999,999,999.99")))
	oSection4:PrintLine()
	
	
		
	
	oSection4:Finish()	

Return 

Static Function MontaQuery(cListaFo, cTipo)
	
	Local cMQuery	:= ""
	
	cMQuery += " WITH TAB AS (  	SELECT				"+CRLF	
	
	If(cTipo == 1)	
		cMQuery += "  DESCRICAO=ZZ6_FORNOP, 				"+CRLF	
	Else
		cMQuery += " DESCRICAO=RTRIM(Z41.Z41_DESCR)	,"+CRLF	
	EndIf
	
	cMQuery += " QUANT1=ISNULL(C9_QTDLIB , 0),			"+CRLF	
	cMQuery += " QUANT2=ISNULL(C9_QTDLIB2 , 0), 		"+CRLF
	
	cMQuery += " QUANT3=CASE WHEN B1_TIPCONV = 'M' 	"+CRLF
	cMQuery += " THEN (Z9_QTDLIB  * 					"+CRLF
	cMQuery += " ISNULL((SELECT ZZ9_PESO FROM "+RetSQLName("ZZ9")+" ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))									"+CRLF
	cMQuery += " + ((Z9_QTDLIB * B1_CONV) *  " +CRLF
	cMQuery += " ISNULL((SELECT ZZ9_PESEMB FROM "+RetSQLName("ZZ9")+" ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB))							"+CRLF
	cMQuery += " ELSE (Z9_QTDLIB  * ISNULL((SELECT ZZ9_PESO FROM "+RetSQLName("ZZ9")+" ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))				"+CRLF
	cMQuery += " + ((Z9_QTDLIB / B1_CONV) * ISNULL((SELECT ZZ9_PESEMB FROM "+RetSQLName("ZZ9")+" ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB)) 	"+CRLF
	cMQuery += " END  "+CRLF
	
			
	cMQuery += " FROM "+RetSQLName("ZZV")+" ZZV (nolock)                               	"+CRLF
	cMQuery += " JOIN "+RetSQLName("ZZW")+" ZZW (nolock) ON                             "+CRLF
	cMQuery += " 	ZZV_FILIAL = ZZW_FILIAL	AND                                         "+CRLF
	cMQuery += " 	ZZV_CARGA = ZZW_CARGA	AND                                         "+CRLF
	cMQuery += " 	ZZW.D_E_L_E_T_ <> '*'                                               "+CRLF
	cMQuery += " JOIN "+RetSQLName("SC9")+" SC9 (nolock) ON                             "+CRLF
	cMQuery += " 	C9_FILIAL = ZZW_FILIAL	AND                                         "+CRLF
	cMQuery += " 	C9_PEDIDO = ZZW_PEDIDO	AND                                         "+CRLF
	cMQuery += " 	C9_ITEM = ZZW_ITEM		AND                                         "+CRLF
	cMQuery += " 	C9_SEQUEN = ZZW_SEQUEN	AND                                         "+CRLF
	cMQuery += " 	SC9.D_E_L_E_T_ <> '*'                                               "+CRLF
	cMQuery += " JOIN "+RetSQLName("SZ9")+" SZ9 (nolock) ON                             "+CRLF
	cMQuery += " 	C9_PEDIDO = Z9_PEDIDO	AND                                         "+CRLF
	cMQuery += " 	C9_PRODUTO = Z9_PRODUTO	AND                                         "+CRLF
	cMQuery += " 	C9_ITEM	 = Z9_ITEM		AND                                         "+CRLF
	cMQuery += " 	C9_SEQUEN = Z9_SEQUEN	AND                                         "+CRLF
	cMQuery += " 	SZ9.D_E_L_E_T_ <> '*'                                               "+CRLF
	cMQuery += " JOIN "+RetSQLName("SB1")+" SB1 (nolock) ON                             "+CRLF
	cMQuery += " 	B1_FILIAL		= '  '			AND                                 "+CRLF
	cMQuery += " 	B1_COD			= Z9_PRODUTO	AND                                 "+CRLF
	cMQuery += " 	SB1.D_E_L_E_T_ <> '*'                                               "+CRLF
	cMQuery += " JOIN "+RetSQLName("ZZ6")+" ZZ6 (nolock) ON                             "+CRLF
	cMQuery += " 	ZZ6_FILIAL = '  '		AND                                         "+CRLF
	cMQuery += " 	ZZ6_COD = B1_YFORMAT	AND                                         "+CRLF
	cMQuery += " 	ZZ6.D_E_L_E_T_ <> '*'                                               "+CRLF
	
	cMQuery += " INNER JOIN "+RetSQLName("SA1")+" SA1  (nolock) ON A1_COD+A1_LOJA = 					"+CRLF
	cMQuery += " ISNULL((select C5_YCLIORI+C5_YLOJORI from "+RetSQLName("SC5")+" SC5 (nolock) 			"+CRLF 
	cMQuery += " WHERE C5_NUM = ZZW_PEDIDO AND SC5.C5_YCLIORI<>'' AND SC5.D_E_L_E_T_<>'*'),ZZW_CCLI+ZZW_LCLI) AND SA1.D_E_L_E_T_ = ''	"+CRLF	    

	cMQuery += " LEFT JOIN "+RetSQLName("Z41")+" Z41  (nolock) ON Z41.Z41_TPSEG = SA1.A1_YTPSEG AND Z41.D_E_L_E_T_ = '' 	    	 	"+CRLF	
 	
	cMQuery += " WHERE                                                                  "+CRLF
	cMQuery += " ZZV.D_E_L_E_T_			= ''                                            "+CRLF
	cMQuery += " AND ZZV.ZZV_FILIAL		= '01'                                          "+CRLF
	cMQuery += " AND ZZV.ZZV_CARGA BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR01+"'			"+CRLF
	
	If(cTipo == 1)
		cMQuery += " AND ZZ6_FORNOP			IN "+FormatIn(cListaFo,"/")+ "					"+CRLF
	EndIf
	cMQuery += ") 																		"+CRLF	
	
	cMQuery += "SELECT DESCRICAO, QUANT1=SUM(QUANT1), QUANT2=SUM(QUANT2), QUANT3=SUM(QUANT3)  FROM TAB GROUP BY DESCRICAO  "+CRLF
	
Return cMQuery