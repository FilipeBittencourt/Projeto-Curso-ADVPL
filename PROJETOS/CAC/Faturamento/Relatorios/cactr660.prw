
#INCLUDE "PROTHEUS.CH"

#IFDEF SPANISH
         #define STR0001  "Resumen de las Ventas"
         #define STR0002  "Emisi¢n del Informe de Resumo de las Ventas, pudiendo el mismo"
         #define STR0003  "ser emitido por la orden del Tipo de Entrada/Salida, Grupo, Tipo"
         #define STR0004  "de Material o Cuenta Contable."
         #define STR0005  ""
         #define STR0006  "Administraci¢n"
         #define STR0007  "Por Tp de Salida"
         #define STR0008  "Por Tipo    "
         #define STR0009  "Por Grupo  "
         #define STR0010  "Por Ct.Contab"
         #define STR0011  "Por Producto "
			#define STR0012  "     TIPO SALIDA "
			#define STR0013  "   FACTURA/SERIE "
         #define STR0014  "      ORDEN      "
 			#define STR0015  "     TIPO SALIDA "
         #define STR0016  "   TIPO PRODUCTO "
         #define STR0017  "   TIPO PRODUCTO "
         #define STR0018  "    G R U P O    "
         #define STR0019  "  C U E N T A    "
         #define STR0020  "  P R O D U C T O"
         #define STR0021  "Seleccionando Registros..."
         #define STR0022  "                 F A C T U R A C I O N                     |           O T R O S   V A L O R E S          |"
			#define STR0023  "     CANTIDAD VALOR UNITARIO VALOR MERCADERIA        I V A |   CANTIDAD   VALOR UNITARIO VALOR MERCADERIA |"
			#define STR0024  "CANCELADO POR EL OPERADOR"
         #define STR0025  "TES: "
         #define STR0026  "GRUPO: "
         #define STR0027  "CUENTA: "
         #define STR0028  "TIPO DEL PRODUCTO: "
         #define STR0029  "PRODUCTO: "
         #define STR0030  "TOTAL DE LOS TES --->"
         #define STR0031  "TOTAL DEL GRUPO ---->"
         #define STR0032  "TOTAL DE LA CUENTA ->"
         #define STR0033  "TOTAL DEL TIPO ----->"
         #define STR0034  "TOTAL ->"
         #define STR0035  "T O T A L  -->"
#ELSE
   #IFDEF ENGLISH
         #define STR0001  "Resumo de Vendas"
         #define STR0002  "Emissao do Relatorio de Resumo de Vendas, podendo o mesmo"
         #define STR0003  "ser emitido por ordem de Tipo de Entrada/Saida, Grupo, Tipo"
         #define STR0004  "de Material ou Conta Cont bil."
         #define STR0005  "Zebrado"
         #define STR0006  "Administracao"
         #define STR0007  "Por Tp/Saida"
         #define STR0008  "Por Tipo    "
         #define STR0009  "Por Grupo  "
         #define STR0010  "P/Ct.Contab."
         #define STR0011  "Por Produto "
			#define STR0012  "     TIPO SAIDA  "
         #define STR0013  "NOTA FISCAL/SERIE"
			#define STR0014  "      ORDEM      "
 			#define STR0015  "     TIPO SAIDA  "
			#define STR0016  "   TIPO PRODUTO  "
         #define STR0017  "   TIPO PRODUTO  "
         #define STR0018  "    G R U P O    "
         #define STR0019  "    C O N T A    "
         #define STR0020  "  P R O D U T O  "
         #define STR0021  "Selecionando Registros..."
			#define STR0022  "                 F A T U R A M E N T O                     |         O U T R O S   V A L O R E S          |"
			#define STR0023  "   QUANTIDADE VALOR UNITARIO VALOR MERCADORIA    VALOR IPI | QUANTIDADE   VALOR UNITARIO VALOR MERCADORIA |"
         #define STR0024  "CANCELADO PELO OPERADOR"
         #define STR0025  "TES: "
         #define STR0026  "GRUPO: "
         #define STR0027  "CONTA: "
         #define STR0028  "TIPO DE PRODUTO: "
         #define STR0029  "PRODUTO: "
         #define STR0030  "TOTAL DA TES --->"
         #define STR0031  "TOTAL DO GRUPO ->"
         #define STR0032  "TOTAL DA CONTA ->"
         #define STR0033  "TOTAL DO TIPO -->"
         #define STR0034  "TOTAL DO PRODUTO -->"
         #define STR0035  "T O T A L  -->"
   #ELSE
         #define STR0001  "Resumo de Vendas"
         #define STR0002  "Emissao do Relatorio de Resumo de Vendas, podendo o mesmo"
         #define STR0003  "ser emitido por ordem de Tipo de Entrada/Saida, Grupo, Tipo"
         #define STR0004  "de Material ou Conta Cont bil."
         #define STR0005  "Zebrado"
         #define STR0006  "Administracao"
         #define STR0007  "Por Tp/Saida"
         #define STR0008  "Por Tipo    "
         #define STR0009  "Por Grupo  "
         #define STR0010  "P/Ct.Contab."
         #define STR0011  "Por Produto "
			#define STR0012  "   TIPO SAIDA    "
         #define STR0013  "NOTA FISCAL/SERIE"
         #define STR0014  "      ORDEM      "
			#define STR0015  "     TIPO SAIDA  "
         #define STR0016  "   TIPO PRODUTO  "
         #define STR0017  "   TIPO PRODUTO  "
         #define STR0018  "    G R U P O    "
         #define STR0019  "    C O N T A    "
         #define STR0020  "  P R O D U T O  "
         #define STR0021  "Selecionando Registros..."
			#define STR0022  "                 F A T U R A M E N T O                 |               O U T R O S   V A L O R E S              |"
			#define STR0023  "   QUANT.     VAL. UNIT.    VAL.MERCAD.     VALOR IPI  | QUANTIDADE  VALOR UNITARIO  VALOR MERCADORIA  VALOR IPI|"
			#define STR0024  "CANCELADO PELO OPERADOR"
         #define STR0025  "TES: "
         #define STR0026  "GRUPO: "
         #define STR0027  "CONTA: "
         #define STR0028  "TIPO DE PRODUTO: "
         #define STR0029  "PRODUTO: "
         #define STR0030  "TOTAL DA TES --->"
         #define STR0031  "TOTAL DO GRUPO ->"
         #define STR0032  "TOTAL DA CONTA ->"
         #define STR0033  "TOTAL DO TIPO -->"
         #define STR0034  "TOTAL DO PRODUTO -->"
         #define STR0035  "T O T A L  -->"
         #define STR0036  ""
         #define STR0037  ""
         #define STR0038  ""
         #define STR0039 ""
         #define STR0040 ""
         #define STR0041 ""
         #define STR0042 ""
         #define STR0043 ""
         #define STR0044 ""
         #define STR0045 ""
         #define STR0046 ""
         #define STR0047 ""
         #define STR0048 ""
         #define STR0049 ""
         #define STR0050 ""
         #define STR0051 ""
         
         #define STR0052 ""
         #define STR0053 ""
         #define STR0054 ""
         #define STR0055 ""
         #define STR0056 ""
         #define STR0057 ""
         #define STR0058 ""
         #define STR0059 ""
         
   #ENDIF
#ENDIF

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATR660  ³ Autor ³ Marco Bianchi         ³ Data ³ 03/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Resumo de Vendas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   
// ALFONSO 2018AGO06
// relatorio padrao FATURAMENTO , mas a partir deste criar novo
// incluir PODER ORDEM POR NF Y gerar total Valor por nota.

USER Function CACTR660()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	CAC660R3()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Marco Bianchi         ³ Data ³ 03/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local cColuna	:= ""
Local cTitulo	:= STR0050		// "Nota Fiscal/Serie"
Local nQuant	:= 0
Local nPrcVen	:= 0
Local nTotal	:= 0
Local nValIpi	:= 0
Local nQuant1	:= 0
Local nPrcVen1	:= 0
Local nTotal1	:= 0
Local nValIpi1	:= 0
Local lValadi	:= cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0 //  Adiantamentos Mexico
Local cAliasTemp := GetNextAlias()

Private cPerg   :="MTR660    "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New("MATR660",STR0039,"MTR660", {|oReport| ReportPrint(oReport,cAliasTemp)},STR0040 + " " + STR0041 + " " + STR0042)	// "Resumo de Vendas"###"Emissao do Relatorio de Resumo de Vendas, podendo o mesmo"###"ser emitido por ordem de Tipo de Entrada/Saida, Grupo, Tipo"###"de Material ou Conta Contábil."
oReport:SetPortrait(.T.) 
oReport:SetTotalInLine(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oResumoVen := TRSection():New(oReport,STR0054,{cAliasTemp},{STR0043,STR0044,STR0045,STR0046,STR0047,STR0048},/*Campos do SX3*/,/*Campos do SIX*/)	// "Resumo"###"Por Tp/Saida + Produto"###"Por Tipo"###"Por Grupo"###"P/Ct.Contab."###"Por Produto"###"Por Tp/Salida + Serie + Nota"
oResumoVen:SetTotalInLine(.F.)


TRCell():New(oResumoVen,"CCOLUNA" ,/*Tabela*/,cTitulo								,/*Picture*/	 			 ,TamSx3("D2_DOC"    )[1]+SerieNfId("SD2",6,"D2_SERIE")+3,/*lPixel*/,{|| cColuna  })	
TRCell():New(oResumoVen,"NQUANT"  ,/*Tabela*/,"|"+CRLF+"|"+RetTitle("D2_QUANT"	)	,PesqPict("SD2","D2_QUANT"	),TamSx3("D2_QUANT"  )[1],/*lPixel*/,{|| nQuant   },,,"RIGHT")	// FATURAMENTO:		Quantidade
TRCell():New(oResumoVen,"NPRCVEN" ,/*Tabela*/,STR0052+CRLF+RetTitle("D2_PRCVEN")	,PesqPict("SD2","D2_PRCVEN"	),TamSx3("D2_PRCVEN" )[1],/*lPixel*/,{|| nPrcVen  },,,"RIGHT")	// FATURAMENTO:		Preco Unitario
If lValadi
	TRCell():New(oResumoVen,"NVALADI" ,/*Tabela*/,CRLF+Substr(RetTitle("D2_VALADI"),1,10)	,PesqPict("SD2","D2_VALADI"	),TamSx3("D2_VALADI" )[1],/*lPixel*/,{|| nValadi  },,,"RIGHT")	// OUTROS VALORES: ADIANTAMENTO
EndIf
TRCell():New(oResumoVen,"NTOTAL"  ,/*Tabela*/,CRLF+RetTitle("D2_TOTAL"	)			,PesqPict("SD2","D2_TOTAL"	),TamSx3("D2_TOTAL"  )[1],/*lPixel*/,{|| nTotal   },,,"RIGHT")	// FATURAMENTO:		Valot Total
If cPaisloc == "BRA"
	TRCell():New(oResumoVen,"NVALIPI" ,/*Tabela*/,CRLF+RetTitle("D2_VALIPI"	)	,PesqPict("SD2","D2_VALIPI"	),TamSx3("D2_VALIPI" )[1],/*lPixel*/,{|| nValIPI  },,,"RIGHT")	// FATURAMENTO:		Valor IPI
Else	
	TRCell():New(oResumoVen,"NVALIPI" ,/*Tabela*/,CRLF+Substr(RetTitle("D2_VALIMP1"),1,10)	,PesqPict("SD2","D2_VALIPI"	),TamSx3("D2_VALIPI" )[1],/*lPixel*/,{|| nValIPI  },,,"RIGHT")	// FATURAMENTO:		Valor IPI
EndIf	
TRCell():New(oResumoVen,"NQUANT1" ,/*Tabela*/,"|"+CRLF+"|"+RetTitle("D2_QUANT"	)	,PesqPict("SD2","D2_QUANT"	),TamSx3("D2_QUANT"  )[1],/*lPixel*/,{|| nQuant1  },,,"RIGHT")	// OUTROS VALORES:	Quantidade
TRCell():New(oResumoVen,"NPRCVEN1",/*Tabela*/,STR0053+CRLF+RetTitle("D2_PRCVEN")	,PesqPict("SD2","D2_PRCVEN"	),TamSx3("D2_PRCVEN" )[1],/*lPixel*/,{|| nPrcVen1 },,,"RIGHT")	// OUTROS VALORES:	Preco Unitario
TRCell():New(oResumoVen,"NTOTAL1" ,/*Tabela*/,CRLF+RetTitle("D2_TOTAL"	)			,PesqPict("SD2","D2_TOTAL"		),TamSx3("D2_TOTAL"  )[1],/*lPixel*/,{|| nTotal1  },,,"RIGHT")	// OUTROS VALORES:	Valor Total
If cPaisloc == "BRA"
	TRCell():New(oResumoVen,"NVALIPI1",/*Tabela*/,CRLF+AllTrim(RetTitle("D2_VALIPI"))+"|",PesqPict("SD2","D2_VALIPI"	),TamSx3("D2_VALIPI" )[1],/*lPixel*/,{|| nValIPI1 },,,"RIGHT")	// OUTROS VALORES:	Valor do IPI
Else
	TRCell():New(oResumoVen,"NVALIPI1",/*Tabela*/,CRLF+Substr(RetTitle("D2_VALIMP1"),1,10)+"|"					 ,PesqPict("SD2","D2_VALIPI"	),TamSx3("D2_VALIPI" )[1],/*lPixel*/,{|| nValIPI1 },,,"RIGHT")	// OUTROS VALORES:	Valor do IPI
EndIf



TRFunction():New(oResumoVen:Cell("NQUANT"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
If lValadi
	TRFunction():New(oResumoVen:Cell("NVALADI"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
EndIf
TRFunction():New(oResumoVen:Cell("NTOTAL"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResumoVen:Cell("NVALIPI"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResumoVen:Cell("NQUANT1"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResumoVen:Cell("NTOTAL1"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResumoVen:Cell("NVALIPI1"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
                                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estas Secoes servem apenas para receber as Querys do SD1 e SD2         ³
//³ que nao sao as tabelas da Section Principal. A tabela para impressao   ³
//³ e a TRB. Se deixamos o filtro de SD1 e SD2 na section principal,	   ³
//³ no momento do filtro do SD2 o sistema fecha o filtro do SD1 nao        ³
//³ reconhecendo o alias.											       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTemp1 := TRSection():New(oReport,STR0055,{"SD1"},{STR0043,STR0044,STR0045,STR0046,STR0047,STR0048},/*Campos do SX3*/,/*Campos do SIX*/)	// "Itens - Notas Fiscais Entrada"###"Por Tp/Saida + Produto"###"Por Tipo"###"Por Grupo"###"P/Ct.Contab."###"Por Produto"###"Por Tp/Salida + Serie + Nota"
oTemp1:SetTotalInLine(.F.)

oTemp2 := TRSection():New(oReport,STR0056,{"SD2","SF2"},{STR0043,STR0044,STR0045,STR0046,STR0047,STR0048},/*Campos do SX3*/,/*Campos do SIX*/)	// "Itens - Notas Fiscais Saida"###"Por Tp/Saida + Produto"###"Por Tipo"###"Por Grupo"###"P/Ct.Contab."###"Por Produto"###"Por Tp/Salida + Serie + Nota"
oTemp2:SetTotalInLine(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Cabecalho no top da pagina                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):SetHeaderPage()     

oReport:Section(2):SetEdit(.F.)
oReport:Section(2):SetEditCell(.F.)
oReport:Section(3):SetEditCell(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas 									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(oReport:uParam,.F.)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³ Marco Bianchi         ³ Data ³ 03/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasTemp)

Local cAliasSD1 := ""
Local cAliasSD2 := ""
Local cAliasSF2 := ""
Local cOrder	:= ""
Local nCntFor 	:= 0
Local nVend		:= fa440CntVen()
Local lImprime 	:= .T.
Local cTexto	:= ""
Local cCampo	:= ""
Local nY		:= 0
Local aCampos	:= {}
Local cIndice 	:= ""
Local cIndTrab 	:= ""
Local lVend		:= .F.
Local cVend		:= "1"
Local cEstoq 	:= If( (MV_PAR05 == 1),"S",If( (MV_PAR05 == 2),"N","SN" ) )
Local cDupli 	:= If( (MV_PAR06 == 1),"S",If( (MV_PAR06 == 2),"N","SN" ) )
Local cCondicao := ""
Local cFilSF2   := ""
Local cFilSD2   := ""
Local nImpInc   := 0
Local nAuxImp	 	:= 0
Local lValadi	 	:= cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0 //  Adiantamentos Mexico
Local cExpAdi	 	:= Iif(lValadi,"D2_VALADI,","") 
Local cCposSD2 		:= ""
Local cSelect  		:= ""
Local cSelectD2		:= "" 
Local aIndex		:= {}
Local cIndex		:= ""
Local oTempTable	:= NIL
Local cNota			:= ""
Local cNotaAux		:= ""

Local cWhere	:= ""
Local cAliasSD1	:= ""

Private nDecs:=msdecimais(mv_par08)
                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetBlock: faz com que as variaveis locais possam ser                   ³
//³ utilizadas em outras funcoes nao precisando declara-las                ³
//³ como private.                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):Cell("CCOLUNA" 	):SetBlock({|| cColuna		})
oReport:Section(1):Cell("NQUANT" 	):SetBlock({|| nQuant		})
oReport:Section(1):Cell("NPRCVEN" 	):SetBlock({|| nPrcVen		})
oReport:Section(1):Cell("NTOTAL" 	):SetBlock({|| nTotal		})
oReport:Section(1):Cell("NVALIPI" 	):SetBlock({|| nValIpi		})
oReport:Section(1):Cell("NQUANT1" 	):SetBlock({|| nQuant1		})
oReport:Section(1):Cell("NPRCVEN1" 	):SetBlock({|| nPrcVen1		})
oReport:Section(1):Cell("NTOTAL1" 	):SetBlock({|| nTotal1		})
oReport:Section(1):Cell("NVALIPI1" 	):SetBlock({|| nValIpi1		})
If lValadi
	oReport:Section(1):Cell("NVALADI"):SetBlock({|| nValadi		})
EndIf
cColuna		:= ""
nQuant		:= 0
nPrcVen		:= 0
nTotal		:= 0
nValIpi		:= 0
nQuant1		:= 0
nPrcVen1	:= 0
nTotal1		:= 0
nValIpi1	:= 0
nValadi		:= 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera o Titulo do Relatorio de acordo com parametros	 	           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetTitle(oReport:Title() + " - " + IIf(oReport:Section(1):GetOrder() == 1,STR0043,IIF(oReport:Section(1):GetOrder()==2,STR0044,IIF(oReport:Section(1):GetOrder()==3,STR0045,IIF(oReport:Section(1):GetOrder()==4,STR0046,IIF(oReport:Section(1):GetOrder()==5,STR0047,STR0048))))) + " - " + GetMv("MV_MOEDA"+STR(mv_par08,1)) )	// "Resumo de Vendas"###"Por Tp/Saida + Produto"###"Por Tipo"###"Por Grupo"###"P/Ct.Contab."###"Por Produto"###"Por Tp/Salida + Serie + Nota"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona SB1 para antes da impressao                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oReport:Section(1),"SB1",1,{|| xFilial("SB1") + (cAliasTemp)->D2_COD })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//³Obs: Utilizamos SetFilter no SD1 e nao Query pois e dado dbSeek         ³
//³no SD1 na funcao CALCDEVR4.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui Devolucao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cWhere := "%"
//Adicao de filtro para nao considerar REMITOS
If cPaisLoc<>"BRA"
	cWhere += " AND NOT ("+IsRemito(2,"D1_TIPODOC")+")"
Endif
cWhere += "%"

If Alltrim(SerieNfId("SD1",3,"D1_SERIE"))<> "D1_SERIE"
	cSelect:="%D1_FILIAL,D1_COD,"+SerieNfId("SD1",3,"D1_SERIORI")+", D1_SERIORI,D1_NFORI,D1_ITEMORI,D1_FORNECE,D1_LOJA,D1_DOC,"
	cSelect+= SerieNfId("SD1",3,"D1_SERIE")+", D1_SERIE,D1_LOCAL,D1_TES,D1_TP,D1_GRUPO,D1_CONTA,D1_DTDIGIT,D1_TIPO,D1_QUANT,D1_TOTAL,D1_VALDESC, "
	cSelect+="D1_VALIPI,D1_ITEM,D1_VALIMP1,D1_VUNIT%"
Else
	cSelect:="%D1_FILIAL,D1_COD,D1_SERIORI,D1_NFORI,D1_ITEMORI,D1_FORNECE,D1_LOJA,D1_DOC, "
	cSelect+="D1_SERIE,D1_LOCAL,D1_TES,D1_TP,D1_GRUPO,D1_CONTA,D1_DTDIGIT,D1_TIPO,D1_QUANT,D1_TOTAL,D1_VALDESC, "
	cSelect+="D1_VALIPI,D1_ITEM,D1_VALIMP1,D1_VUNIT%"
Endif

cAliasSD1 := GetNextAlias()    

oReport:Section(2):BeginQuery()		

BeginSql Alias cAliasSD1

	SELECT %Exp:cSelect%
	FROM %table:SD1% SD1
		
	WHERE	D1_FILIAL   = %xFilial:SD1% AND 
			D1_TIPO     = 'D' AND
			D1_COD      >= %Exp:MV_PAR13% AND
			D1_COD   	<= %Exp:MV_PAR14% AND 											
			D1_DTDIGIT >= %Exp:Dtos(MV_PAR01)% AND 
			D1_DTDIGIT <= %Exp:Dtos(MV_PAR02)% AND 
			SD1.%NotDel%
			%Exp:cWhere%					
					
EndSql 
oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)

cOrder	 := ""
cCondicao:= ""
If mv_par04 # 3
	cAliasSD1 := "SD1"
	dbSelectArea(cAliasSD1)
	dbSetOrder(2)
	cOrder := "D1_FILIAL+D1_COD+D1_SERIORI+D1_NFORI+D1_ITEMORI"
	cCondicao := 'D1_FILIAL=="'+xFilial("SD1")+'".And.D1_TIPO=="D"'
	cCondicao += ".And. D1_COD>='"+MV_PAR13+"'.And. D1_COD<='"+MV_PAR14+"'"
	cCondicao += '.And. !('+IsRemito(2,'D1_TIPODOC')+')'
	If (MV_PAR04 == 2)
		cCondicao +=".And.DTOS(D1_DTDIGIT)>='"+DTOS(MV_PAR01)+"'.And.DTOS(D1_DTDIGIT)<='"+DTOS(MV_PAR02)+"'"
	EndIf
	dbSelectArea(cAliasSD1)
	oReport:Section(2):SetFilter(cCondicao,cOrder)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Indice da Nota Fiscal de Saida                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasSF2 := "SF2"
dbSelectArea(cAliasSF2)
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra Itens de Venda da Nota Fiscal                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasSD2 := GetNextAlias()
dbSelectArea("SD2")
cWhere := ""
cWhere := "% AND NOT ("+IsRemito(2,'D2_TIPODOC')+")"
If mv_par04 == 3 .Or. mv_par11 == 2
	cWhere += " AND D2_TIPO NOT IN ('B','D','I')"
Else
	cWhere += " AND D2_TIPO NOT IN ('B','I')"
EndIf		
cWhere += "%"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha necessidade de Indexacao no SD2               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oReport:Section(1):GetOrder() = 1 .Or. oReport:Section(1):GetOrder() = 6	// Por Tes
	cOrder := "%D2_FILIAL,D2_TES,"+IIf(oReport:Section(1):GetOrder()==1,"D2_COD","D2_SERIE,D2_DOC") + "%"
ElseIF oReport:Section(1):GetOrder() = 2			// Por Tipo
	SD2->(dbSetOrder(2))							// Tipo do Produto, Codigo do Produto)
	cOrder := "%" + IndexKey() + "%"
ElseIF oReport:Section(1):GetOrder() = 3			// Por Grupo
	cOrder := "%D2_FILIAL,D2_GRUPO,D2_COD%"
ElseIF oReport:Section(1):GetOrder() = 4			// Por Conta Contabil
	cOrder := "%D2_FILIAL,D2_CONTA,D2_COD%"
Else						  						// Por Produto
	cOrder := "%D2_FILIAL,D2_COD,D2_LOCAL,D2_SERIE,D2_DOC%"
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os campos referentes aos impostos D2_VALIMP.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCposSD2 := "%"
dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek("D2_VALIMP")
	While SX3->(!Eof()) .And. SubStr(SX3->X3_CAMPO,1,9) == "D2_VALIMP"
		cCposSD2 += ", "+AllTrim(SX3->X3_CAMPO)
		SX3->(dbSkip())
	EndDo
EndIf
cCposSD2 += "%"

If Alltrim(SerieNfId("SD2",3,"D2_SERIE"))<>"D2_SERIE"
	cSelectD2:= "%D2_FILIAL,D2_COD,D2_LOCAL,"+SerieNfId("SD2",3,"D2_SERIE")+", D2_SERIE,D2_TES,D2_TP,D2_GRUPO,D2_CONTA,D2_EMISSAO,D2_TIPO,D2_DOC,D2_QUANT,D2_TOTAL, "
Else
	cSelectD2:= "%D2_FILIAL,D2_COD,D2_LOCAL,D2_SERIE,D2_TES,D2_TP,D2_GRUPO,D2_CONTA,D2_EMISSAO,D2_TIPO,D2_DOC,D2_QUANT,D2_TOTAL, "
Endif		
cSelectD2+=cExpAdi+"%"
		
oReport:Section(3):BeginQuery()	
BeginSql Alias cAliasSD2
SELECT %Exp:cSelectD2% D2_VALIPI,D2_PRCVEN,D2_ITEM,D2_CLIENTE,D2_LOJA,F2_MOEDA,F2_TXMOEDA %Exp:cCposSD2% 
FROM %Table:SD2% SD2,%table:SF2% SF2
WHERE D2_FILIAL = %xFilial:SD2%
	AND D2_EMISSAO >= %Exp:DtoS(mv_par01)% AND D2_EMISSAO <= %Exp:DtoS(mv_par02)%
	AND D2_COD >= %Exp:mv_par13% AND D2_COD <= %Exp:mv_par14%
	AND D2_ORIGLAN <> 'LF'
	AND SF2.F2_FILIAL    = %xFilial:SF2% 
	AND	SF2.F2_DOC       = SD2.D2_DOC
	AND	SF2.F2_SERIE     = SD2.D2_SERIE 
	AND	SF2.F2_CLIENTE   = SD2.D2_CLIENTE
	AND	SF2.F2_LOJA      = SD2.D2_LOJA
	AND SD2.%NotDel%
	AND SF2.%NotDel%
	%Exp:cWhere%	
ORDER BY %Exp:cOrder%
EndSql 
oReport:Section(3):EndQuery(/*Array com os parametros do tipo Range*/)
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria tabela temporaria                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndice := CriaTrab("",.F.)
cIndTrab := SubStr(cIndice,1,7)+"A"
dbSelectArea("SD2")
aTam := TamSx3("D2_FILIAL")
Aadd(aCampos,{"D2_FILIAL","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_COD")
Aadd(aCampos,{"D2_COD","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_LOCAL")
Aadd(aCampos,{"D2_LOCAL","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_SERIE")
Aadd(aCampos,{"D2_SERIE","C",aTam[1],aTam[2]})
If Alltrim(SerieNfId("SD2",3,"D2_SERIE"))<> "D2_SERIE"
	aTam := TamSx3("D2_SDOC")
	Aadd(aCampos,{"D2_SDOC","C",aTam[1],aTam[2]})
EndIf
aTam := TamSx3("D2_TES")
Aadd(aCampos,{"D2_TES","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_TP")
Aadd(aCampos,{"D2_TP","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_GRUPO")
Aadd(aCampos,{"D2_GRUPO","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_CONTA")
Aadd(aCampos,{"D2_CONTA","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_EMISSAO")
Aadd(aCampos,{"D2_EMISSAO","D",aTam[1],aTam[2]})
aTam := TamSx3("D2_TIPO")
Aadd(aCampos,{"D2_TIPO","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_DOC")
Aadd(aCampos,{"D2_DOC","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_QUANT")
Aadd(aCampos,{"D2_QUANT","N",aTam[1],aTam[2]})
aTam := TamSx3("D2_TOTAL")
Aadd(aCampos,{"D2_TOTAL","N",aTam[1],aTam[2]})
If lValadi
	aTam := TamSx3("D2_VALADI")
	Aadd(aCampos,{"D2_VALADI","N",aTam[1],aTam[2]})
EndIf

If cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
	aTam := TamSx3("D2_VALIMP1")
	Aadd(aCampos,{"D2_VALIMP1","N",aTam[1],aTam[2]})
else
	aTam := TamSx3("D2_VALIPI")
	Aadd(aCampos,{"D2_VALIPI","N",aTam[1],aTam[2]})
EndIf

aTam := TamSx3("D2_PRCVEN")
Aadd(aCampos,{"D2_PRCVEN","N",aTam[1],aTam[2]})
aTam := TamSx3("D2_ITEM")
Aadd(aCampos,{"D2_ITEM","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_CLIENTE")
Aadd(aCampos,{"D2_CLIENTE","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_LOJA")
Aadd(aCampos,{"D2_LOJA","C",aTam[1],aTam[2]})

//Campos para guardar a moeda/taxa da nota para a conversao durante a impressao
aTam := TamSx3("F2_MOEDA")
Aadd(aCampos,{"D2_MOEDA","N",aTam[1],aTam[2]})
aTam := TamSx3("F2_TXMOEDA")
Aadd(aCampos,{"D2_TXMOEDA","N",aTam[1],aTam[2]})

//-------------------------------------------------------------------
// Instancia tabela temporária.  
//-------------------------------------------------------------------

oTempTable	:= FWTemporaryTable():New( cAliasTemp )

//-------------------------------------------------------------------
// Atribui o  os índices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aCampos )


If oReport:Section(1):GetOrder() = 1 .Or. oReport:Section(1):GetOrder() = 6							// Por Tes	
	cVaria := "D2_TES"

	 cIndex := "D2_FILIAL+D2_TES+"+IIf(oReport:Section(1):GetOrder()==1,"D2_COD","D2_SERIE+D2_DOC")
	 aIndex := StrTokArr(cIndex,"+")

ElseIF oReport:Section(1):GetOrder() = 2																// Por Tipo
	cVaria := "D2_TP"
	
	 cIndex := SD2->(IndexKey(2))
	 aIndex := StrTokArr(cIndex,"+")

ElseIF oReport:Section(1):GetOrder() = 3																// Por Grupo
	cVaria := "D2_GRUPO"
	
	cIndex := "D2_FILIAL+D2_GRUPO+D2_COD"
	aIndex := StrTokArr(cIndex,"+")

ElseIF oReport:Section(1):GetOrder() = 4																// Por Conta Contabil
	cVaria := "D2_CONTA"

	cIndex := "D2_FILIAL+D2_CONTA+D2_COD"
	aIndex := StrTokArr(cIndex,"+")
	
Else																									// Por Produto
	cVaria := "D2_COD"
     		
	cIndex := "D2_FILIAL+D2_COD+D2_LOCAL+D2_SERIE+D2_DOC"
	aIndex := StrTokArr(cIndex,"+")
	
EndIF
oTempTable:AddIndex("1",aIndex)
//------------------
//Criação da tabela
//------------------
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Arquivo Temporario                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Notas de Saida                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Busca filtro do usuario do SF2
If len(oReport:Section(3):GetAdvplExp("SF2")) > 0
	cFilSF2 := oReport:Section(3):GetAdvplExp("SF2")
EndIf
// Busca filtro do usuario do SD2
If len(oReport:Section(3):GetAdvplExp("SD2")) > 0
	cFilSD2 := oReport:Section(3):GetAdvplExp("SD2")
EndIf

dbSelectArea(cAliasSD2)
dbGoTop()
oReport:SetMeter(RecCount())
While !oReport:Cancel() .And. !(cAliasSD2)->(Eof()) .And. D2_FILIAL == xFilial("SD2")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica vendedor no SF2                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		// Verifica filtro do usuario
		dbSelectArea("SF2")
		If !Empty(cFilSF2) .And. !(&cFilSF2)
	   		dbSkip()
			Loop
		EndIf	

		dbselectarea(cAliasSF2)
		dbSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
		dbSelectArea(cAliasSD2)
		
		
		For nCntFor := 1 To nVend
			cVendedor := (cAliasSF2)->(FieldGet((cAliasSF2)->(FieldPos("F2_VEND"+cVend))))
			If cVendedor >= mv_par09 .and. cVendedor <= mv_par10
				lVend := .T.
				Exit
			EndIf
			cVend := Soma1(cVend,1)
		Next nCntFor
		cVend := "1"
		
		If lVend
			dbSelectArea(cAliasTemp)
			Reclock(cAliasTemp,.T.)
			Replace (cAliasTemp)->D2_FILIAL  With (cAliasSD2)->D2_FILIAL
			Replace (cAliasTemp)->D2_COD     With (cAliasSD2)->D2_COD
			Replace (cAliasTemp)->D2_LOCAL   With (cAliasSD2)->D2_LOCAL
			Replace (cAliasTemp)->D2_SERIE   With (cAliasSD2)->D2_SERIE
			If Alltrim(SerieNfId("SD2",3,"D2_SERIE"))<> "D2_SERIE"
				Replace (cAliasTemp)->D2_SDOC   With (cAliasSD2)->D2_SDOC
			Endif
			Replace (cAliasTemp)->D2_TES     With (cAliasSD2)->D2_TES
			Replace (cAliasTemp)->D2_TP      With (cAliasSD2)->D2_TP
			Replace (cAliasTemp)->D2_GRUPO   With (cAliasSD2)->D2_GRUPO
			Replace (cAliasTemp)->D2_CONTA   With (cAliasSD2)->D2_CONTA
			Replace (cAliasTemp)->D2_EMISSAO With (cAliasSD2)->D2_EMISSAO
			Replace (cAliasTemp)->D2_TIPO    With (cAliasSD2)->D2_TIPO
			Replace (cAliasTemp)->D2_DOC     With (cAliasSD2)->D2_DOC
			Replace (cAliasTemp)->D2_QUANT   With (cAliasSD2)->D2_QUANT
			
			if cPaisloc<>"BRA" // Localizado para imprimir o IVA 24/05/00
			    Replace (cAliasTemp)->D2_PRCVEN  With (cAliasSD2)->D2_PRCVEN
                Replace (cAliasTemp)->D2_TOTAL   With ((cAliasSD2)->D2_TOTAL - Iif(lValadi,(cAliasSD2)->D2_VALADI,0))
                If lValadi
                	Replace (cAliasTemp)->D2_VALADI  With ((cAliasSD2)->D2_VALADI)
                EndIf

				aImpostos:=TesImpInf((cAliasSD2)->D2_TES)
	
				For nY:=1 to Len(aImpostos)
					cCampImp:=(cAliasSD2) + "->" + (aImpostos[nY][2])
					If ( aImpostos[nY][3]=="1" )
						nImpInc     += &cCampImp
					EndIf
				Next
	
				Replace (cAliasTemp)->D2_VALImP1  With nImpInc
				nImpInc:=0
			else
			    If (cAliasSD2)->D2_TIPO <> "P" //Complemento de IPI
			       Replace (cAliasTemp)->D2_PRCVEN  With (cAliasSD2)->D2_PRCVEN
			       Replace (cAliasTemp)->D2_TOTAL   With (cAliasSD2)->D2_TOTAL
                Endif
				Replace (cAliasTemp)->D2_VALIPI  With (cAliasSD2)->D2_VALIPI
			endif
			
			Replace (cAliasTemp)->D2_ITEM    With (cAliasSD2)->D2_ITEM
			Replace (cAliasTemp)->D2_CLIENTE With (cAliasSD2)->D2_CLIENTE
			Replace (cAliasTemp)->D2_LOJA    With (cAliasSD2)->D2_LOJA
			
			//--------- Grava a moeda/taxa da nota para a conversao durante a impressao
			Replace (cAliasTemp)->D2_MOEDA   With (cAliasSF2)->F2_MOEDA
			Replace (cAliasTemp)->D2_TXMOEDA With (cAliasSF2)->F2_TXMOEDA
			
			MsUnlock()
			lVend := .F.
		EndIf
	dbSelectArea(cAliasSD2)
	dbSkip()
	oReport:IncMeter()
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nota de Devolucao                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par04 == 2
	
	SF1->(dbsetorder(1))
	
	dbSelectArea(cAliasSD1)
	dbGoTop()
	oReport:SetMeter(RecCount())
	While !oReport:Cancel() .And. !(cAliasSD1)->(Eof()) .And. D1_FILIAL == xFilial("SD1")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica nota fiscal de origem e vendedor no SF2             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    dbselectarea(cAliasSF2)
            If cPaisLoc == "BRA"
            	dbSeek(xFilial()+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI)
		    Else
		    	dbSeek(xFilial()+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
			EndIf
			
			// Verifica filtro do usuario
			If !Empty(cFilSF2) .And. !(&cFilSF2)
				dbSelectArea(cAliasSD1)
		   		dbSkip()
				Loop
			EndIf	
			
			// Verifica filtro do usuario no SD2     
			If !Empty(cFilSD2)
				dbSelectArea("SD2")
				dbSetOrder(3)
				If dbseek(xFilial()+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEMORI)
					If !(&cFilSD2)
						dbSelectArea(cAliasSD1)
		   				dbSkip()
						Loop
					EndIf	
				EndIf	
			EndIf	
            //Somente busca o vendedor, se realmente foi encontrado a nota fiscal de origem
			If (cAliasSF2)->(Found())
				For nCntFor := 1 To nVend
					cVendedor := (cAliasSF2)->(FieldGet((cAliasSF2)->(FieldPos("F2_VEND"+cVend))))
					If cVendedor >= mv_par09 .and. cVendedor <= mv_par10
						lVend := .T.
						Exit
					EndIf
					cVend := Soma1(cVend,1)
				Next nCntFor
				cVend := "1"
            EndIf
            
			If lVend
				SF1->(dbseek((cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
		        dbSelectArea(cAliasTemp)
				Reclock(cAliasTemp,.T.)
				Replace (cAliasTemp)->D2_FILIAL	With (cAliasSD1)->D1_FILIAL
				Replace (cAliasTemp)->D2_COD 	With (cAliasSD1)->D1_COD
				Replace (cAliasTemp)->D2_LOCAL 	With (cAliasSD1)->D1_LOCAL
				Replace (cAliasTemp)->D2_SERIE 	With If(mv_par12==1,(cAliasSD1)->D1_SERIORI,(cAliasSD1)->D1_SERIE)
				If Alltrim(SerieNfId("SD2",3,"D2_SERIE"))<> "D2_SERIE"
					Replace (cAliasTemp)->D2_SDOC   With If(mv_par12==1,(cAliasSD1)->D1_SDOCORI,(cAliasSD1)->D1_SDOC)
				Endif
				Replace (cAliasTemp)->D2_TES 	With (cAliasSD1)->D1_TES
				Replace (cAliasTemp)->D2_TP 		With (cAliasSD1)->D1_TP
				Replace (cAliasTemp)->D2_GRUPO 	With (cAliasSD1)->D1_GRUPO
				Replace (cAliasTemp)->D2_CONTA 	With (cAliasSD1)->D1_CONTA
				Replace (cAliasTemp)->D2_EMISSAO With (cAliasSD1)->D1_DTDIGIT
				Replace (cAliasTemp)->D2_TIPO 	With (cAliasSD1)->D1_TIPO
				Replace (cAliasTemp)->D2_DOC 	With If(mv_par12==1,(cAliasSD1)->D1_NFORI,(cAliasSD1)->D1_DOC)
				Replace (cAliasTemp)->D2_QUANT 	With -(cAliasSD1)->D1_QUANT
				Replace (cAliasTemp)->D2_TOTAL 	With -((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC)
				If lValadi
					Replace (cAliasTemp)->D2_VALADI 	With 0
				EndIf
				
				If cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
					Replace (cAliasTemp)->D2_VALIMP1 With - (cAliasSD1)->D1_VALIMP1
				Else
					Replace (cAliasTemp)->D2_VALIPI With - (cAliasSD1)->D1_VALIPI
				Endif
				
				Replace (cAliasTemp)->D2_PRCVEN  With (cAliasSD1)->D1_VUNIT
				Replace (cAliasTemp)->D2_ITEM 	With (cAliasSD1)->D1_ITEM
				Replace (cAliasTemp)->D2_CLIENTE With (cAliasSD1)->D1_FORNECE
				Replace (cAliasTemp)->D2_LOJA 	With (cAliasSD1)->D1_LOJA
				
				//--------- Grava a moeda/taxa da nota para a conversao durante a impressao
				Replace (cAliasTemp)->D2_MOEDA   With SF1->F1_MOEDA
				Replace (cAliasTemp)->D2_TXMOEDA With SF1->F1_TXMOEDA
				
				MsUnlock()
				lVend := .F.
			EndIf
		dbSelectArea(cAliasSD1)
		dbSkip()
		oReport:IncMeter()
	EndDo
EndIf


dbSelectArea(cAliasTemp)
dbGoTop()
oReport:Section(1):Init()
oReport:SetMeter(RecCount())  														// Total de Elementos da regua
While !oReport:Cancel() .And. !(cAliasTemp)->(Eof()) .And. lImprime
	
	
	cColuna := (cAliasTemp)->D2_DOC + "/" + Alltrim((cAliasTemp)->&(SerieNfId("SD2",3,"D2_SERIE")))
	cNota := cColuna
	
	cTexto	:= ""
	If oReport:Section(1):GetOrder() = 1 .Or. oReport:Section(1):GetOrder() = 6	// Por Tes
		dbSelectArea("SF4")
		dbSeek(xFilial()+(cAliasTemp)->D2_TES)
		dbSelectArea(cAliasTemp)
		If mv_par07 == 1															// Analitico
			cTexto  := "TES: " + (cAliasTemp)->D2_TES + " - " +  SF4->F4_TEXTO
		Else																		// Sintetico
			cColuna := (cAliasTemp)->D2_TES + " - " +  SF4->F4_TEXTO
		EndIf
		dbSelectArea(cAliasTemp)
		cCpo := (cAliasTemp)->D2_TES
	Elseif oReport:Section(1):GetOrder() = 2					   					// Por Tipo
		If mv_par07 == 1															// Analitico
			cTexto  := "TIPO DE PRODUTO: " + (cAliasTemp)->D2_TP
		Else																		// Sintetico
			cColuna := (cAliasTemp)->D2_TP
		EndIf
		cCpo := (cAliasTemp)->D2_TP		
	Elseif oReport:Section(1):GetOrder() = 3										// Por Grupo
		dbSelectArea("SBM")
		dbSeek(xFilial()+(cAliasTemp)->D2_GRUPO)
		dbSelectArea(cAliasTemp)
		If mv_par07 == 1															// Analitico
			cTexto  := "GRUPO: " + (cAliasTemp)->D2_GRUPO + " - " + SBM->BM_DESC 
		Else																		// Sintetico
			cColuna := (cAliasTemp)->D2_GRUPO + " - " + SBM->BM_DESC
		EndIf
		cCpo := (cAliasTemp)->D2_GRUPO		
	Elseif oReport:Section(1):GetOrder() = 4		  								// Por Conta Contabil
		dbSelectArea("SI1")
		dbSetOrder(1)
		dbSeek(xFilial()+(cAliasTemp)->D2_CONTA)
		dbSelectArea(cAliasTemp)		
		If mv_par07 == 1															// Analitico
			cTexto  := "CONTA: " + (cAliasTemp)->D2_CONTA + SI1->I1_DESC
		Else																		// Sintetico
			cColuna := (cAliasTemp)->D2_CONTA
		EndIf           
		cCpo := (cAliasTemp)->D2_CONTA
	Else																			// Por Produto
		DbSelectArea("SB1")
		DbSetOrder(1)
		SB1->(DbSeek(xFilial("SB1")+(cAliasTemp)->D2_COD))
		DbSelectArea(cAliasTemp)
		If mv_par07 == 1															// Analitico
			cTexto  := "PRODUTO: " + (cAliasTemp)->D2_COD + " " + SB1->B1_DESC
		Else																		// Sintetico
			cColuna := (cAliasTemp)->D2_COD
		EndIf
		cCpo := (cAliasTemp)->D2_COD
	Endif
	cCampo 	:= "cCpo"
	nQuant	:=0;nTotal:=0;nValIpi:=0;nValadi:=0
	nQuant1	:=0;nTotal1:=0;nValIpi1:=0;
	
	If mv_par07 == 1			// Analitico
		oReport:PrintText(cTexto)
	EndIf
	
	dbSelectArea(cAliasTemp)
	While &cCampo = &cVaria .And. !Eof() .And. lImprime
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trato a Devolu‡„o de Vendas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDevQtd	:=0;nDevVal:=0;nDevIPI:=0
		nDevQtd1:=0;nDevVal1:=0;
		
		If mv_par04 == 1  //Devolucao pela NF Original
			CalcDevR4(cDupli,cEstoq,cAliasTemp)
		EndIf
		
		dbSelectArea(cAliasTemp)
		If AvalTes((cAliasTemp)->D2_TES,cEstoq,cDupli)
			oReport:Section(1):Cell("NQUANT"	):Show()
			oReport:Section(1):Cell("NTOTAL"	):Show()
			oReport:Section(1):Cell("NVALIPI"	):Show()
			
			If mv_par07 == 1		// Analitico
				oReport:Section(1):Cell("NPRCVEN"	):Show()
				oReport:Section(1):Cell("NQUANT1"	):Hide()
				oReport:Section(1):Cell("NPRCVEN1"	):Hide()
				oReport:Section(1):Cell("NTOTAL1"	):Hide()
				oReport:Section(1):Cell("NVALIPI1"	):Hide()
				
				cColuna := (cAliasTemp)->D2_DOC + "/" + Alltrim((cAliasTemp)->&(SerieNfId("SD2",3,"D2_SERIE")))
				nQuant 	:= (cAliasTemp)->D2_QUANT - nDevQtd
				nTotal 	:= xMoeda((cAliasTemp)->D2_TOTAL,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA)  - nDevVal
				nQuant1 := nPrcVen1 := nTotal1 := nValIPI1 := nValadi := 0 
			Else					// Sintetico
				oReport:Section(1):Cell("NPRCVEN"	):Hide()
				oReport:Section(1):Cell("NQUANT1"	):Show()
				oReport:Section(1):Cell("NPRCVEN1"	):Hide()
				oReport:Section(1):Cell("NTOTAL1"	):Show()
				oReport:Section(1):Cell("NVALIPI1"	):Show()
				
				nQuant 	+= ((cAliasTemp)->D2_QUANT - nDevQtd)
				nTotal 	+= (xMoeda((cAliasTemp)->D2_TOTAL,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA)  - nDevVal)
			EndIf	
			
			nPrcVen := xMoeda((cAliasTemp)->D2_PRCVEN,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA)
			If cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
				nValIPI  += xMoeda((cAliasTemp)->D2_VALIMP1,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA)  - nDevIpi
			Else
				nValIPI  += xMoeda((cAliasTemp)->D2_VALIPI ,1,mv_par08,(cAliasTemp)->D2_EMISSAO) -  nDevIpi
			Endif
			
			If mv_par07 == 1				// Analitico
				If cPaisloc<>"BRA"			// Localizado para imprimir o IVA 24/05/00
					nValIPI := xMoeda((cAliasTemp)->D2_VALIMP1 ,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA) - nDevIpi
				Else
					nValIPI :=  xMoeda((cAliasTemp)->D2_VALIPI,1,mv_par08,(cAliasTemp)->D2_EMISSAO)- nDevIpi
				Endif
			EndIf
			
		Else
		
			If mv_par07 == 1		// Analitico
				oReport:Section(1):Cell("NQUANT"	):Hide()
				oReport:Section(1):Cell("NTOTAL"	):Hide()
				oReport:Section(1):Cell("NVALIPI"	):Hide()
				oReport:Section(1):Cell("NPRCVEN1"	):Show()				
				
				cColuna := (cAliasTemp)->D2_DOC + "/" + Alltrim((cAliasTemp)->&(SerieNfId("SD2",3,"D2_SERIE")))
				nQuant1 := (cAliasTemp)->D2_QUANT - nDevQtd1
				nQuant := nPrcVen := nTotal := nValIPI := nValadi := 0
			Else	
				oReport:Section(1):Cell("NQUANT"	):Show()
				oReport:Section(1):Cell("NTOTAL"	):Show()
				oReport:Section(1):Cell("NVALIPI"	):Show()
				oReport:Section(1):Cell("NPRCVEN1"	):Hide()
				
				nQuant1 += ((cAliasTemp)->D2_QUANT - nDevQtd1)
			EndIf
			oReport:Section(1):Cell("NPRCVEN"	):Hide()
			oReport:Section(1):Cell("NQUANT1"	):Show()			
			oReport:Section(1):Cell("NTOTAL1"	):Show()
			oReport:Section(1):Cell("NVALIPI1"	):Show()
			
			If D2_TIPO <> "P" //Complemento de IPI
				nTotal1  += xMoeda((cAliasTemp)->D2_TOTAL,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA) - nDevVal1
			EndIf
	
			If cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
				nValIPI1 += xMoeda((cAliasTemp)->D2_VALIMP1,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA) - nDevIpi				
			Else
				nValIPI1 += xMoeda((cAliasTemp)->D2_VALIPI,1,mv_par08,(cAliasTemp)->D2_EMISSAO) - nDevIpi
			Endif
			
			If mv_par07 == 1				// Analitico
				If D2_TIPO <> "P" //Complemento de IPI
					nPrcVen1 := xMoeda((cAliasTemp)->D2_PRCVEN,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA) 		
					nTotal1  := xMoeda((cAliasTemp)->D2_TOTAL,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA)- nDevVal1
				Else
					nPrcVen1 := 0
					nTotal1  := 0
				EndIf
				
				If cPaisloc<>"BRA" // Localizado para imprimir o IVA 24/05/00
					nValIPI1 := xMoeda((cAliasTemp)->D2_VALIMP1,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA) - nDevIpi 
				Else
					nValIPI1 := xMoeda((cAliasTemp)->D2_VALIPI,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO) - nDevIpi 
				Endif
			EndIf
		EndIf
		
		If lValadi
			nValadi	+= xMoeda((cAliasTemp)->D2_VALADI,(cAliasTemp)->D2_MOEDA,mv_par08,(cAliasTemp)->D2_EMISSAO,nDecs+1,(cAliasTemp)->D2_TXMOEDA)
		EndIf		
		
		If mv_par07 == 1		// Analitico
			oReport:Section(1):PrintLine()			
		EndIf			
		
		dbSelectArea(cAliasTemp)
		dbSkip()
		oReport:IncMeter()
		
	End	
	
	If mv_par07 == 1		// Analitico
		oReport:Section(1):SetTotalText(STR0051 + " " + AllTrim(RetTitle(cVaria)) + " " + &cCampo)		// "TOTAL"
		oReport:Section(1):Finish()
		oReport:Section(1):Init()
	Else
		oReport:Section(1):PrintLine()			
		oReport:ThinLine()
	EndIf	
	
	If (!Empty(ALLTRIM(cNotaAux)) .And. (ALLTRIM(cNota) != ALLTRIM(cNotaAux)))
		oReport:PrintText("Total:	")
	EndIf
	cNotaAux := cNota

	dbSelectArea(cAliasTemp)
End

oReport:Section(1):SetPageBreak()


If mv_par04 # 3
	(cAliasSD1)->(dbCloseArea())
EndIf
(cAliasSF2)->(dbCloseArea())
(cAliasSD2)->(dbCloseArea())
If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)
	oTempTable := nil
EndIf


Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CalcDevR4³ Autor ³     Marcos Simidu     ³ Data ³ 17.02.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo de Devolucoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR660                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcDevR4(cDup,cEst,cAliasTemp)

dbSelectArea("SD1")
If dbSeek(xFilial()+(cAliasTemp)->D2_COD+(cAliasTemp)->D2_SERIE+(cAliasTemp)->D2_DOC+(cAliasTemp)->D2_ITEM)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Soma Devolucoes          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasTemp)->D2_CLIENTE+(cAliasTemp)->D2_LOJA == D1_FORNECE+D1_LOJA
		If !(D1_ORIGLAN == "LF")
			If AvalTes(D1_TES,cEst,cDup)
				If AvalTes(D1_TES,cEst) .And. (cEst == "S" .Or. cEst == "SN" )
					nDevQtd+= D1_QUANT
				Endif
				nDevVal +=xMoeda((D1_TOTAL-D1_VALDESC),(cAliasTemp)->D2_MOEDA,mv_par08,D1_DTDIGIT,nDecs+1,(cAliasTemp)->D2_TXMOEDA)
				If cPaisLoc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
					nDevipi += xMoeda(D1_VALIMP1,(cAliasTemp)->D2_MOEDA,mv_par08,D1_DTDIGIT,nDecs+1,(cAliasTemp)->D2_TXMOEDA)
				Else
					nDevipi += xMoeda(D1_VALIPI,1,mv_par08,D1_DTDIGIT)
				Endif
			Else
				If AvalTes(D1_TES,cEst) .And. (cEst == "S" .Or. cEst == "SN" )
					nDevQtd1+= D1_QUANT
				Endif
				nDevVal1 +=xMoeda((D1_TOTAL-D1_VALDESC),(cAliasTemp)->D2_MOEDA,mv_par08,D1_DTDIGIT,nDecs+1,(cAliasTemp)->D2_TXMOEDA)
			Endif
		Endif
	Endif
Endif
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR660R3³ Autor ³ Wagner Xavier         ³ Data ³ 05.09.91  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Resumo de Vendas                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR660(void)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Verificar indexacao dentro de programa (provisoria)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Paulo Augusto³24/05/00³Melhor³ Alterado a impressao do IPI para Iva nas³±±
±±³              ³        ³      ³ Localizacoes                            ³±±
±±³ Marcello     ³26/08/00³oooooo³Impressao de casas decimais de acordo    ³±±
±±³              ³        ³      ³com a moeda selecionada.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function CAC660R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL CbTxt
LOCAL cString:= "SD2"
LOCAL CbCont,cabec1,cabec2,wnrel
LOCAL titulo := OemToAnsi(STR0001)	//"Resumo de Vendas"
LOCAL cDesc1 := OemToAnsi(STR0002)	//"Emissao do Relatorio de Resumo de Vendas, podendo o mesmo"
LOCAL cDesc2 := OemToAnsi(STR0003)	//"ser emitido por ordem de Tipo de Entrada/Saida, Grupo, Tipo"
LOCAL cDesc3 := OemToAnsi(STR0004)	//"de Material ou Conta Cont bil."
LOCAL tamanho:= "M"
LOCAL limite := 132
LOCAL lImprime := .T.
cGrtxt := SPACE(11)
PRIVATE aReturn := { STR0005, 1,STR0006, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog:="MATR660"
PRIVATE nLastKey := 0
PRIVATE cPerg   :="MTR660    "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 00
li       := 80
m_pag    := 01
If cPaisloc == "MEX"
	tamanho:= "G"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTR660",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01      A partir de                                    ³
//³ mv_par02      Ate a Data                                     ³
//³ mv_par03      Juros p/valor presente                         ³
//³ mv_par04      Considera Devolucao NF Orig/NF Devl/Nao Cons.  ³
//³ mv_par05      Tes Qto Estoque  Mov. X Nao Mov. X Ambas       ³
//³ mv_par06      Tes Qto Duplicata Gera X Nao Gera X Ambas      ³
//³ mv_par07      Tipo de Relatorio 1 Analitico 2 Sintetico      ³
//³ mv_par08      Qual Moeda                                     ³
//³ mv_par09      Vendedor de                                    ³
//³ mv_par10      Vendedor ate                                   ³
//³ mv_par11      Considera devolucao de compras                 ³
//³ mv_par12      Imprimir documento: original/devolucao         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="MATR660"            //Nome Default do relatorio em Disco

//
aOrd :={STR0007,STR0008,STR0009,STR0010,STR0011,STR0036}		//"Por Tp/Saida+Produto"###"Por Tipo    "###"Por Grupo  "###"P/Ct.Contab."###"Por Produto " ### "Por Tp Saida + Serie + Nota "

wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey==27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C660Imp(@lEnd,wnRel,cString)},Titulo)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C660IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR660                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C660Imp(lEnd,WnRel,cString)

LOCAL CbCont,cabec1,cabec2
LOCAL titulo := OemToAnsi(STR0001)	//"Resumo de Vendas"
LOCAL cDesc1 := OemToAnsi(STR0002)	//"Emissao do Relatorio de Resumo de Vendas, podendo o mesmo"
LOCAL cDesc2 := OemToAnsi(STR0003)	//"ser emitido por ordem de Tipo de Entrada/Saida, Grupo, Tipo"
LOCAL cDesc3 := OemToAnsi(STR0004)	//"de Material ou Conta Cont bil."
LOCAL tamanho:= "M"
LOCAL limite := 132
LOCAL lImprime := .T.
LOCAL lContinua:=.T.
LOCAL nQuant1:=0,nValor1:=0,nValIpi:=0
LOCAL nTotQtd1:=0,nTotVal1:=0,nTotIpi:=0
LOCAL nQuant2:=0,nValor2:=0,nValIpi2:=0
LOCAL nTotQtd2:=0,nTotVal2:=0,nTotIpi2:=0,nIndex:=0
LOCAL lColGrup:=.T.
LOCAL lFirst:=.T.
Local cArqSD1,cKeySD1,cFilSD1,cFilSD2:=""
Local cEstoq := If( (MV_PAR05 == 1),"S",If( (MV_PAR05 == 2),"N","SN" ) )
Local cDupli := If( (MV_PAR06 == 1),"S",If( (MV_PAR06 == 2),"N","SN" ) )
Local cIndTrab
Local aCampos := {}, aTam := {}
Local nVend:= fa440CntVen()
Local lVend:= .F.
Local cVend:= "1"
Local cVendedor := ""
Local nCntFor := 1
Local cIndice := ""
Local nImpInc:=0
Local nY:=0
Local cCampImp := ""
Local aImpostos:={}
Local aColuna  := Iif(cPaisloc <> "MEX",{18,19,31,44,61,74,131,18,74,76,88,101,119,131,42,99},{27,28,40,53,70,83,140,27,83,85,97,111,128,140,51,109})
Local lValadi  := cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0 //  Adiantamentos Mexico 
Local oTempTable	:= NIL
Local aIndex		:= {}
Local cIndex		:= ""
Local cAliasTmp 	:= GetNextAlias()

PRIVATE nDevQtd1:=0,nDevVal1:=0,nDevIPI :=0
PRIVATE nDevQtd2:=0,nDevVal2:=0

Private nDecs:=msdecimais(mv_par08)

nOrdem := aReturn[8]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 00
li       := 80
m_pag    := 01
If cPaisloc == "MEX"
	tamanho:= "G"
EndIf

IF nOrdem = 1 .Or. nOrdem = 6 	// Tes
	cVaria := "D2_TES"
	If mv_par07 == 1			// Analitico
		cDescr1 := STR0012	//"    TIPO SAIDA   "
		cDescr2 := STR0013	//"NOTA FISCAL/SERIE"
	Else							// Sintetico
		cDescr1 := STR0014	//"      ORDEM      "
		cDescr2 := STR0015	//"    TIPO SAIDA   "
	EndIf
ElseIF nOrdem = 2	  			// Por Tipo
	cVaria := "D2_TP"
	If mv_par07 == 1        // Analitico
		cDescr1 := STR0016	//"   TIPO PRODUTO  "
		cDescr2 := STR0013	//"NOTA FISCAL/SERIE"
	Else							// Sintetico
		cDescr1 := STR0014	//"      ORDEM      "
		cDescr2 := STR0017	//"   TIPO PRODUTO  "
	EndIf
ElseIF nOrdem = 3				// Por Grupo
	cVaria := "D2_GRUPO"
	If mv_par07 == 1        // Analitico
		cDescr1 := STR0018	//"    G R U P O    "
		cDescr2 := STR0013	//"NOTA FISCAL/SERIE"
	Else                    // Analitico
		cDescr1 := STR0014	//"      ORDEM      "
		cDescr2 := STR0018	//"    G R U P O    "
	EndIf
ElseIF nOrdem = 4				// Por Conta Contabil
	cVaria := "D2_CONTA"
	If mv_par07 == 1        // Analitico
		cDescr1 := STR0019	//"    C O N T A    "
		cDescr2 := STR0013	//"NOTA FISCAL/SERIE"
	Else							// Sintetico
		cDescr1 := STR0014	//"      ORDEM      "
		cDescr2 := STR0019	//"    C O N T A    "
	EndIf
Else
	cVaria := "D2_COD"		// Ordem por produto
	If mv_par07 == 1        // Analitico
		cDescr1 := STR0020	//"  P R O D U T O  "
		cDescr2 := STR0013	//"NOTA FISCAL/SERIE"
	Else							// Sintetico
		cDescr1 := STR0014	//"      ORDEM      "
		cDescr2 := STR0020	//"  P R O D U T O  "
	EndIf
EndIF

If mv_par04 # 3
	dbSelectArea( "SD1" )
	cArqSD1 := CriaTrab( NIL,.F. )
	cKeySD1 := "D1_FILIAL+D1_COD+D1_SERIORI+D1_NFORI+D1_ITEMORI"
	cFilSD1 := 'D1_FILIAL=="'+xFilial("SD1")+'".And.D1_TIPO=="D"'
	cFilSD1 += ".And. D1_COD>='"+MV_PAR13+"'.And. D1_COD<='"+MV_PAR14+"'"
	cFilSD1 += '.And. !('+IsRemito(2,'D1_TIPODOC')+')'			
	If (MV_PAR04 == 2)
		cFilSD1 +=".And.DTOS(D1_DTDIGIT)>='"+DTOS(MV_PAR01)+"'.And.DTOS(D1_DTDIGIT)<='"+DTOS(MV_PAR02)+"'"
	EndIf	
	IndRegua("SD1",cArqSD1,cKeySD1,,cFilSD1,STR0021)		//"Selecionando Registros..."
	nIndex := RetIndex("SD1")

	dbSetOrder(nIndex+1)
	SetRegua(RecCount())
	dbGotop()	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Indice da Nota Fiscal de Saida                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF2")
dbSetOrder(1)

dbSelectArea("SD2")
aTam := TamSx3("D2_FILIAL")
Aadd(aCampos,{"D2_FILIAL","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_COD")
Aadd(aCampos,{"D2_COD","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_LOCAL")
Aadd(aCampos,{"D2_LOCAL","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_SERIE")
Aadd(aCampos,{"D2_SERIE","C",aTam[1],aTam[2]})
If Alltrim(SerieNfId("SD2",3,"D2_SERIE"))<> "D2_SERIE"
	aTam := TamSx3("D2_SDOC")
	Aadd(aCampos,{"D2_SDOC","C",aTam[1],aTam[2]})
EndIf
aTam := TamSx3("D2_TES")
Aadd(aCampos,{"D2_TES","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_TP")
Aadd(aCampos,{"D2_TP","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_GRUPO")
Aadd(aCampos,{"D2_GRUPO","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_CONTA")
Aadd(aCampos,{"D2_CONTA","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_EMISSAO")
Aadd(aCampos,{"D2_EMISSAO","D",aTam[1],aTam[2]})
aTam := TamSx3("D2_TIPO")
Aadd(aCampos,{"D2_TIPO","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_DOC")
Aadd(aCampos,{"D2_DOC","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_QUANT")
Aadd(aCampos,{"D2_QUANT","N",aTam[1],aTam[2]})
aTam := TamSx3("D2_TOTAL")
Aadd(aCampos,{"D2_TOTAL","N",aTam[1],aTam[2]})

if cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
	aTam := TamSx3("D2_VALIMP1")
	Aadd(aCampos,{"D2_VALIMP1","N",aTam[1],aTam[2]})
else
	aTam := TamSx3("D2_VALIPI")
	Aadd(aCampos,{"D2_VALIPI","N",aTam[1],aTam[2]})
endif

aTam := TamSx3("D2_PRCVEN")
Aadd(aCampos,{"D2_PRCVEN","N",aTam[1],aTam[2]})
aTam := TamSx3("D2_ITEM")
Aadd(aCampos,{"D2_ITEM","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_CLIENTE")
Aadd(aCampos,{"D2_CLIENTE","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_LOJA")
Aadd(aCampos,{"D2_LOJA","C",aTam[1],aTam[2]})

//Campos para guardar a moeda/taxa da nota para a conversao durante a impressao
aTam := TamSx3("F2_MOEDA")
Aadd(aCampos,{"D2_MOEDA","N",aTam[1],aTam[2]})
aTam := TamSx3("F2_TXMOEDA")
Aadd(aCampos,{"D2_TXMOEDA","N",aTam[1],aTam[2]})

//-------------------------------------------------------------------
// Instancia tabela temporária.  
//-------------------------------------------------------------------
oTempTable	:= FWTemporaryTable():New( cAliasTmp )

//-------------------------------------------------------------------
// Atribui o  os índices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aCampos )

DbSelectArea("SD2")
If !Empty(DbFilter())
	cFilSD2 :="("+DbFilter()+").And."
EndIf
cFilSD2 += "D2_FILIAL == '"+xFilial("SD2")+"'.And."
cFilSD2 += "DTOS(D2_EMISSAO) >='"+DTOS(mv_par01)+"'.And.DTOS(D2_EMISSAO)<='"+DTOS(mv_par02)+"'"
cFilSD2 += ".And. D2_COD>='"+MV_PAR13+"'.And. D2_COD<='"+MV_PAR14+"'"
cFilSD2 += '.And. !('+IsRemito(2,'D2_TIPODOC')+')'		
cFilSD2 += ".And.!(D2_ORIGLAN$'LF')"
If mv_par04==3 .Or. mv_par11 == 2
	cFilSD2 += ".And.!(D2_TIPO$'BDI')"
Else
	cFilSD2 += ".And.!(D2_TIPO$'BI')"
EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha necessidade de Indexacao no SD2               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndice := CriaTrab("",.F.)
If nOrdem = 1 .Or. nOrdem = 6	// Por Tes
	
	cIndTrab := SubStr(cIndice,1,7)+"A"
	
	cIndex := "D2_FILIAL+D2_TES+"+IIf(nOrdem==1,"D2_COD","D2_SERIE+D2_DOC")
	aIndex := StrTokArr(cIndex,"+")
		
ElseIF nOrdem = 2			// Por Tipo
	dbSetOrder(2)
	cIndTrab := SubStr(cIndice,1,7)+"A"
	
	cIndex := SD2->(IndexKey())
	aIndex := StrTokArr(cIndex,"+")
	
ElseIF nOrdem = 3			// Por Grupo
	
	cIndTrab := SubStr(cIndice,1,7)+"A"
	
	cIndex := "D2_FILIAL+D2_GRUPO+D2_COD"
	aIndex := StrTokArr(cIndex,"+")
	
ElseIF nOrdem = 4			// Por Conta Contabil
	
	cIndTrab := SubStr(cIndice,1,7)+"A"
	
	cIndex := "D2_FILIAL+D2_CONTA+D2_COD"
	aIndex := StrTokArr(cIndex,"+")
	
Else							// Por Produto
	
	cIndTrab := SubStr(cIndice,1,7)+"A"
	
	cIndex := "D2_FILIAL+D2_COD+D2_LOCAL+D2_SERIE+D2_DOC"
	aIndex := StrTokArr(cIndex,"+")
	
EndIF

oTempTable:AddIndex("1",aIndex)
//------------------
//Criação da tabela
//------------------
oTempTable:Create()

IndRegua("SD2",cIndice,cIndex,,cFilSD2,STR0049)
	
nIndex := RetIndex("SD2")

If nOrdem <> 2
	dbSetOrder(nIndex+1)
EndIf
SetRegua(RecCount())
dbGoTop()

While !Eof() .And. D2_FILIAL == xFilial("SD2")
		
		IF nOrdem = 2 .and. !(&cFILSD2)
			dbSkip()
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica vendedor no SF2                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbselectarea("SF2")
		dbSeek(xFilial()+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)

		For nCntFor := 1 To nVend
			cVendedor := SF2->(FieldGet(SF2->(FieldPos("F2_VEND"+cVend))))
			If cVendedor >= mv_par09 .and. cVendedor <= mv_par10
				lVend := .T.
				Exit
			EndIf
			cVend := Soma1(cVend,1)
		Next nCntFor
		cVend := "1"
		
		If lVend
			Reclock(cAliasTmp,.T.)
			Replace ( cAliasTmp )->D2_FILIAL  With SD2->D2_FILIAL
			Replace ( cAliasTmp )->D2_COD     With SD2->D2_COD
			Replace ( cAliasTmp )->D2_LOCAL   With SD2->D2_LOCAL
			If Alltrim(SerieNfId("SD2",3,"D2_SERIE"))<> "D2_SERIE"
				Replace ( cAliasTmp )->D2_SDOC With SD2->D2_SDOC
			EndIf
			Replace ( cAliasTmp )->D2_SERIE   With SD2->D2_SERIE
			Replace ( cAliasTmp )->D2_TES     With SD2->D2_TES
			Replace ( cAliasTmp )->D2_TP      With SD2->D2_TP
			Replace ( cAliasTmp )->D2_GRUPO   With SD2->D2_GRUPO
			Replace ( cAliasTmp )->D2_CONTA   With SD2->D2_CONTA
			Replace ( cAliasTmp )->D2_EMISSAO With SD2->D2_EMISSAO
			Replace ( cAliasTmp )->D2_TIPO    With SD2->D2_TIPO
			Replace ( cAliasTmp )->D2_DOC     With SD2->D2_DOC
			Replace ( cAliasTmp )->D2_QUANT   With SD2->D2_QUANT
			

			if cPaisloc<>"BRA" // Localizado para imprimir o IVA 24/05/00
			    Replace ( cAliasTmp )->D2_PRCVEN  With SD2->D2_PRCVEN
                Replace ( cAliasTmp )->D2_TOTAL   With SD2->D2_TOTAL-Iif(lValadi,SD2->D2_VALADI,0)

				aImpostos:=TesImpInf(SD2->D2_TES)
	
				For nY:=1 to Len(aImpostos)
					cCampImp:="SD2->"+(aImpostos[nY][2])
					If ( aImpostos[nY][3]=="1" )
						nImpInc     += &cCampImp
					EndIf
				Next
	
				Replace ( cAliasTmp )->D2_VALImP1  With nImpInc
				nImpInc:=0
			else
			    If D2_TIPO <> "P" //Complemento de IPI
			       Replace ( cAliasTmp )->D2_PRCVEN  With SD2->D2_PRCVEN
			       Replace ( cAliasTmp )->D2_TOTAL   With SD2->D2_TOTAL
                Endif
				Replace ( cAliasTmp )->D2_VALIPI  With SD2->D2_VALIPI
			endif
			
			Replace ( cAliasTmp )->D2_ITEM    With SD2->D2_ITEM
			Replace ( cAliasTmp )->D2_CLIENTE With SD2->D2_CLIENTE
			Replace ( cAliasTmp )->D2_LOJA    With SD2->D2_LOJA
			
			//--------- Grava a moeda/taxa da nota para a conversao durante a impressao
			Replace ( cAliasTmp )->D2_MOEDA   With SF2->F2_MOEDA
			Replace ( cAliasTmp )->D2_TXMOEDA With SF2->F2_TXMOEDA
			
			MsUnlock()
			lVend := .F.
		EndIf
	dbSelectArea("SD2")
	dbSkip()
EndDo

If mv_par04 == 2
	// elimina filtro para pesquisar nota original (SD2) a partir da devolucao de venda (SD1)
	dbSelectArea("SD2")
	RetIndex("SD2")
	dbClearFilter()    
	
	// Busca filtro do usuario      
	cFilSD2 :=""
	If !Empty(DbFilter())
		cFilSD2 :="("+DbFilter()+")"
	EndIf
	SF1->(dbsetorder(1))
	dbSelectArea("SD1")
	dbGoTop()
	While !Eof() .And. D1_FILIAL == xFilial("SD1")

			// Verifica filtro do usuario no SD2
			If !Empty(cFilSD2)			
				dbSelectArea("SD2")
				dbSetOrder(3)
				If dbseek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI)
					If !(&cFILSD2)
						dbSelectArea("SD1")
		   				dbSkip()
						Loop
					EndIf	
				EndIf	
			EndIf			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica nota fiscal de origem e vendedor no SF2             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    dbselectarea("SF2")
            If cPaisLoc == "BRA"
            	dbSeek(xFilial()+SD1->D1_NFORI+SD1->D1_SERIORI)
		    Else
		    	dbSeek(xFilial()+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA)
			EndIf
			
            //Somente busca o vendedor, se realmente foi encontrado a nota fiscal de origem
			If SF2->(Found())
				For nCntFor := 1 To nVend
					cVendedor := SF2->(FieldGet(SF2->(FieldPos("F2_VEND"+cVend))))
					If cVendedor >= mv_par09 .and. cVendedor <= mv_par10
						lVend := .T.
						Exit
					EndIf
					cVend := Soma1(cVend,1)
				Next nCntFor
				cVend := "1"
			EndIf

	        dbSelectArea("SD1")

			If lVend
				SF1->(dbseek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
				Reclock(( cAliasTmp ),.T.)
				Replace ( cAliasTmp )->D2_FILIAL  With SD1->D1_FILIAL
				Replace ( cAliasTmp )->D2_COD     With SD1->D1_COD
				Replace ( cAliasTmp )->D2_LOCAL   With SD1->D1_LOCAL
				If Alltrim(SerieNfId("SD2",3,"D2_SERIE"))<> "D2_SERIE"
					Replace ( cAliasTmp )->D2_SDOC With If(mv_par12==1,SD1->D1_SDOCORI,SD1->D1_SDOC)
				EndIf
				Replace ( cAliasTmp )->D2_SERIE   With If(mv_par12==1,SD1->D1_SERIORI,SD1->D1_SERIE)
				Replace ( cAliasTmp )->D2_TES     With SD1->D1_TES
				Replace ( cAliasTmp )->D2_TP      With SD1->D1_TP
				Replace ( cAliasTmp )->D2_GRUPO   With SD1->D1_GRUPO
				Replace ( cAliasTmp )->D2_CONTA   With SD1->D1_CONTA
				Replace ( cAliasTmp )->D2_EMISSAO With SD1->D1_DTDIGIT
				Replace ( cAliasTmp )->D2_TIPO    With SD1->D1_TIPO
				Replace ( cAliasTmp )->D2_DOC     With If(mv_par12==1,SD1->D1_NFORI,SD1->D1_DOC)
				Replace ( cAliasTmp )->D2_QUANT   With -SD1->D1_QUANT
				Replace ( cAliasTmp )->D2_TOTAL   With -(SD1->D1_TOTAL-SD1->D1_VALDESC)
				
				If cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
					Replace ( cAliasTmp )->D2_VALIMP1 With - SD1->D1_VALIMP1
				Else
					Replace ( cAliasTmp )->D2_VALIPI With -SD1->D1_VALIPI
				Endif
				
				Replace ( cAliasTmp )->D2_PRCVEN  With SD1->D1_VUNIT
				Replace ( cAliasTmp )->D2_ITEM With SD1->D1_ITEM
				Replace ( cAliasTmp )->D2_CLIENTE With SD1->D1_FORNECE
				Replace ( cAliasTmp )->D2_LOJA With SD1->D1_LOJA
				
				//--------- Grava a moeda/taxa da nota para a conversao durante a impressao
				Replace ( cAliasTmp )->D2_MOEDA   With SF1->F1_MOEDA
				Replace ( cAliasTmp )->D2_TXMOEDA With SF1->F1_TXMOEDA
				
				MsUnlock()
				lVend := .F.
			EndIf
		dbSelectArea("SD1")
		dbSkip()
	EndDo
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de Titulos e Cabecalhos de acordo com a opcao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,GetMV("MV_COMP"),GetMV("MV_NORM"))

titulo := STR0001 + " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))
If cPaisLoc == "BRA"
	cabec1 := " " + cDescr1 + "|" + STR0022		//"                 F A T U R A M E N T O                    |            O U T R O S   V A L O R E S          |"
	cabec2 := " " + cDescr2 + "|" + STR0023		//"  QUANT.     VAL.  UNIT.    VAL.  MERCAD.       VALOR IPI |    QUANTIDADE   VALOR UNITARIO VALOR MERCADORIA |"
Else
	If cPaisLoc <> "MEX"
		cabec1 := " " + cDescr1 + "|" + STR0037		//"                 F A T U R A M E N T O                    |            O U T R O S   V A L O R E S          |"
		cabec2 := " " + cDescr2 + "|" + STR0038		//"  QUANT.     VAL.  UNIT.    VAL.  MERCAD.       VALOR IMP |    QUANTIDADE   VALOR UNITARIO VALOR MERCADORIA |"		
	Else 
		cabec1 := " " + cDescr1 + "         |" + STR0037		//"                 F A T U R A M E N T O                    |            O U T R O S   V A L O R E S          |"
		cabec2 := " " + cDescr2 + "         |" + STR0038		//"  QUANT.     VAL.  UNIT.    VAL.  MERCAD.       VALOR IMP |    QUANTIDADE   VALOR UNITARIO VALOR MERCADORIA |"
	EndIf
EndIf
dbSelectArea(( cAliasTmp ))
dbGoTop()

SetRegua(RecCount())		// Total de Elementos da regua

While !Eof() .And. lImprime
	
	IncRegua()
	
	IF lEnd
		@PROW()+1,001 PSay STR0024	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	IF nOrdem = 1 .Or. nOrdem = 6		// Por Tes
		cTesalfa := D2_TES
		dbSelectArea("SF4")
		dbSeek(xFilial()+( cAliasTmp )->D2_TES)
		If mv_par07 == 1 					// Analitico
			cCfText := F4_TEXTO
		Else									// Sintetico
			cCfText := Subs(F4_TEXTO,1,13)
		EndIf
		dbSelectArea(( cAliasTmp ))
		cTesa := cTesalfa
		cCampo:= "cTesa"
	Elseif nOrdem = 2						// Por Tipo
		cTpProd := D2_TP
		cCampo  := "cTpProd"
	Elseif nOrdem = 3						// Por Grupo
		cSubtot := SubStr(D2_GRUPO,1,4)
		cTotal  := SubStr(D2_GRUPO,1,1)
		cGrupo  := D2_GRUPO
		cCampo  := "cGrupo"
		dbSelectArea("SBM")
		dbSeek(xFilial()+( cAliasTmp )->D2_GRUPO)
		If mv_par07 == 1  						// Analitico
			IF Found()
				cGrTxt := Substr(Trim(SBM->BM_DESC),1,16)
			Else
				cGrTxt := SPACE(11)
			Endif
		Else											// Sintetico
			IF Found()
				cGrTxt := Trim(SBM->BM_DESC)
			Else
				cGrTxt := SPACE(11)
			Endif
		EndIf
		dbSelectArea(( cAliasTmp ))
	Elseif nOrdem = 4								// Por Conta Contabil
		cSubtot := SubStr(D2_CONTA,1,4)
		cTotal  := SubStr(D2_CONTA,1,1)
		cConta  := D2_CONTA
		dbSelectArea("SI1")
		dbSetOrder(1)
		dbSeek(xFilial()+( cAliasTmp )->D2_CONTA)
		cCampo  := "cConta"
	Else
		cCodPro := D2_COD
		cCampo  := "cCodPro"
	Endif
	
	nQuant1:=0;nValor1:=0;nValIpi:=0
	nQuant2:=0;nValor2:=0;nValIpi2:=0
	lFirst:=.T.
	
	dbSelectArea(( cAliasTmp ))
	
	While &cCampo = &cVaria .And. !Eof() .And. lImprime
		
		IF lEnd
			@PROW()+1,001 PSay STR0024	//"CANCELADO PELO OPERADOR"
			lImprime := .F.
			Exit
		Endif
		
		IncRegua()
		
		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trato a Devolu‡„o de Vendas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDevQtd1:=0;nDevVal1:=0;nDevIPI:=0
		nDevQtd2:=0;nDevVal2:=0;
		
		If mv_par04 == 1  //Devolucao pela NF Original
			CalcDev(cDupli,cEstoq, cAliasTmp)
		EndIf
		
		dbSelectArea(( cAliasTmp ))
		
		nQuant1 -=nDevQtd1
		nQuant2 -=nDevQtd2
		If mv_par07 == 1 .And. lFirst    // Analitico
			lFirst:=.F.
			If nOrdem = 1 .Or. nOrdem = 6		// Por Tes
				@ li,000 PSay STR0025	//"TES: "
				@ li,005 PSay cTesa
				@ li,008 PSay "-"
				@ li,009 PSay AllTrim(cCftext)
			Elseif nOrdem = 3	 				// Por Grupo
				@ li,000 PSay STR0026	//"GRUPO: "
				@ li,007 PSay cGrupo
				@ li,012 PSay "-"
				@ li,013 PSay Substr(cGrTxt,1,12)
			ElseIf nOrdem = 4					// Por Conta Contabil
				@ li,000 PSay STR0027	//"CONTA: "
				@ li,008 PSay TRIM(cConta)
				@ li,030 PSay AllTrim(SI1->I1_DESC)
			Elseif nOrdem = 2					// Por Tipo de Produto
				@ li,000 PSay STR0028	//"TIPO DE PRODUTO: "
				@ li,017 PSay cTpprod
			Else					 			// Por Produto
				@ li,000 PSay STR0029	//"PRODUTO: "
				SB1->(dbSeek(xFilial("SB1")+cCodPro))
				@ li,011 PSay Trim(cCodPro) + " " + SB1->B1_DESC
			EndIf
		Endif
		
		If AvalTes(D2_TES,cEstoq,cDupli)
			lColGrup:=.T.
			If mv_par07 == 1				// Analitico
				li++
				@ li,000 PSay D2_DOC+" / "+ SerieNfId("SD2",2,"D2_SERIE")
				@ li,aColuna[1] PSay "|"
				@ li,aColuna[2] PSay (D2_QUANT - nDevQtd1)	Picture PesqPictQt("D2_QUANT",11)
			EndIf
			
			nQuant1  += D2_QUANT
			
			nValor1  += xMoeda(D2_TOTAL ,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA)- nDevVal1
			
			If cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
				nValIPI  += xMoeda(D2_VALImp1,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA)  - nDevIpi
			Else
				nValIPI  += xMoeda(D2_VALIPI ,1,mv_par08,D2_EMISSAO) -  nDevIpi
			Endif
			
			If mv_par07 == 1				// Analitico

				@ li,aColuna[3] PSay xMoeda(D2_PRCVEN,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA) 		Picture PesqPict("SD2","D2_TOTAL",12,mv_par08)
				@ li,aColuna[4] PSay xMoeda(D2_TOTAL ,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA)  - nDevVal1 Picture PesqPict("SD2","D2_TOTAL",16,mv_par08)
	
				If cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
					@ li,aColuna[5] PSay xMoeda(D2_VALIMP1 ,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA) - nDevIpi      PicTure PesqPict("SD2","D2_VALIMP1",12,mv_par08)
				Else
					@ li,aColuna[5] PSay xMoeda(D2_VALIPI,1,mv_par08,D2_EMISSAO)- nDevIpi 	PicTure PesqPict("SD2","D2_VALIPI",11)
				Endif
				
				@ li,aColuna[6] PSay "|"
				@ li,aColuna[7] PSay "|"
			EndIf
		Else
			lColGrup:=.F.
			If mv_par07 == 1 				// Analitico
				li++
				@ li,000 PSay D2_DOC+" / "+ SerieNfId("SD2",2,"D2_SERIE")
				@ li,aColuna[8] PSay "|"
				@ li,aColuna[9] PSay "|"
				@ li,aColuna[10] PSay (D2_QUANT - nDevQtd2)	Picture PesqPictQt("D2_QUANT",11)
			EndIf
			
			nQuant2  += D2_QUANT

			If D2_TIPO <> "P" //Complemento de IPI
				nValor2  += xMoeda(D2_TOTAL   ,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA) - nDevVal2
			EndIf
	
			If cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
				nValIPI2 += xMoeda(D2_VALIMP1 ,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA) - nDevIpi
			Else
				nValIPI2 += xMoeda(D2_VALIPI,1,mv_par08,D2_EMISSAO) - nDevIpi
			Endif
			
			If mv_par07 == 1				// Analitico
				If D2_TIPO <> "P" //Complemento de IPI
					@ li,aColuna[11] PSay xMoeda(D2_PRCVEN,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA) 				Picture PesqPict("SD2","D2_TOTAL",12,mv_par08)
					@ li,aColuna[12] PSay xMoeda(D2_TOTAL ,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA)- nDevVal2 Picture PesqPict("SD2","D2_TOTAL",16,mv_par08)
				Else
					@ li,aColuna[3] PSay 0 Picture PesqPict("SD2","D2_TOTAL",12,mv_par08)
					@ li,aColuna[4] PSay 0 Picture PesqPict("SD2","D2_TOTAL",16,mv_par08)
				EndIf
				
				If cPaisloc<>"BRA" // Localizado para imprimir o IVA 24/05/00
					@ li,aColuna[13] PSay xMoeda(D2_VALIMP1,D2_MOEDA,mv_par08,D2_EMISSAO,nDecs+1,D2_TXMOEDA) - nDevIpi Picture PesqPict("SD2","D2_VALIMP1",12,mv_par08)
				Else
					@ li,aColuna[13] PSay xMoeda(D2_VALIPI ,D2_MOEDA,mv_par08,D2_EMISSAO) - nDevIpi 	Picture PesqPict("SD2","D2_VALIPI",11,mv_par08)
				Endif
				
				@ li,aColuna[14] PSay "|"
			EndIf
		EndIf
		dbSkip()
		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		Endif
	End
	dbSelectArea(( cAliasTmp ))
	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	If nQuant1 # 0 .Or. nQuant2 # 0 .Or. nValor1 # 0 .Or. nValor2 # 0 .Or. &cCampo <> &cVaria
		If !lFirst
			li++
		EndIf
		
		IF nOrdem = 1.Or. nOrdem = 6		// TES
			If mv_par07 == 1 				// ANALITICO
				@ li,000 PSay STR0030	//"TOTAL DA TES --->"
			Else								//SINTETICO
				@ li,000 PSay cTesa
				@ li,003 PSay "-"
				@ li,004 PSay AllTrim(cCftext)
			EndIf
		Elseif nOrdem = 3				  	// GRUPO
			If mv_par07 == 1				// ANALITICO
				@ li,000 PSay STR0031	//"TOTAL DO GRUPO ->"
			Else								//SINTETICO
				@ li,000 PSay cGrupo
				@ li,005 PSay "-"
				If nOrdem = 3				// GRUPO
					@ li,006 PSay Substr(cGrTxt,1,12)
				Endif
			EndIf
		ElseIf nOrdem = 4		 			// Por Conta Contabil
			If mv_par07 == 1           // Analitico
				@ li,000 PSay STR0032	//"TOTAL DA CONTA ->"
			Else								// Sintetico
				@ li,000 PSay cConta
			EndIf
		Elseif nOrdem = 2
			If mv_par07 == 1           // Analitico
				@ li,000 PSay STR0033	//"TOTAL DO TIPO -->"
			Else								// Sintetico
				@ li,009 PSay cTpprod
			EndIf
		Else
			If mv_par07 == 1           // Analitico
				@ li,000 PSay STR0034	//"TOTAL DO PRODUTO -->"
			Else								// Sintetico
				@ li,000 PSay cCodPro
			EndIf
		Endif
		If mv_par07 == 2 					// Sintetico
			@li,aColuna[1] PSay "|"
		EndIf
		If nOrdem = 1						// Por Tes
			If lColGrup
				If nQuant1 # 0
					@ li,aColuna[2] PSay nQuant1		Picture PesqPictQt("D2_QUANT",11)
				EndIf

				@ li,aColuna[15] PSay nValor1                   Picture PesqPict("SD2","D2_TOTAL",18,mv_par08)
				
				If cPaisLoc<>"BRA" // Localizado para imprimir o IVA 24/05/00
					@ li,aColuna[5] PSay nValIpi         PicTure PesqPict("SD2","D2_VALIMP1",12,mv_par08)
				Else
					@ li,aColuna[5] PSay nValIpi			PicTure PesqPict("SD2","D2_VALIPI",11)
				Endif
				@ li,aColuna[6] PSay "|"
			Else
				@ li,aColuna[6] PSay "|"
				If nQuant2 # 0
					@ li,aColuna[10] PSay nQuant2		Picture PesqPictQt("D2_QUANT",11)
				EndIf
				@ li,aColuna[16] PSay nValor2                   Picture PesqPict("SD2","D2_TOTAL",18,mv_par08)
				
				If cPaisloc<>"BRA" // Localizado para imprimir o IVA 24/05/00
					@ li,aColuna[13] PSay nValIpi2        PicTure PesqPict("SD2","D2_VALIMP1",12,mv_par08)
				Else
					@ li,aColuna[13] PSay nValIpi2     	PicTure PesqPict("SD2","D2_VALIPI",11)
				Endif
				
			EndIf
		Else
			If nQuant1 # 0
				@ li,aColuna[2] PSay nQuant1		Picture PesqPictQt("D2_QUANT",11)
			EndIf
			@ li,aColuna[15] PSay nValor1         Picture PesqPict("SD2","D2_TOTAL",18,mv_par08)
			
			If cPaisLoc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
				@ li,aColuna[5] PSay nValIpi      PicTure PesqPict("SD2","D2_VALIMP1",12,mv_par08)
			Else
				@ li,aColuna[5] PSay nValIpi		PicTure PesqPict("SD2","D2_VALIPI",11)
			Endif
			
			@ li,aColuna[6] PSay "|"
			If nQuant2 # 0
				@ li,aColuna[10] PSay nQuant2		Picture PesqPictQt("D2_QUANT",11)
			EndIf
			@ li,aColuna[16] PSay nValor2         Picture PesqPict("SD2","D2_TOTAL",18,mv_par08)
			
			If cpaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
				@ li,aColuna[13] PSay nValIpi2   	PicTure PesqPict("SD2","D2_VALIMP1",12,mv_par08)
			Else
				@ li,aColuna[13] PSay nValIpi2  	PicTure PesqPict("SD2","D2_VALIPI",11)
			Endif
			
		EndIf
		@ li,aColuna[14] PSay "|"
		li++
		@ li,000 PSay __PrtFatLine()
		li++
		nTotQtd1  += nQuant1
		nTotVal1  += nValor1
		nTotIpi   += nValIpi
		nTotQtd2  += nQuant2
		nTotVal2  += nValor2
		nTotIpi2  += nValIpi2
		
	Endif
	dbSelectArea(( cAliasTmp ))
End

If li != 80
	li++
	@ li,000 PSay STR0035 	//"T O T A L  -->"
	@ li,aColuna[1] PSay "|"
	@ li,aColuna[2] PSay nTotQtd1 Picture PesqPictQt("D2_QUANT",11)
	
	If cPaisloc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
		@ li,aColuna[15] PSay nTotVal1 Picture PesqPict("SD2","D2_TOTAL",18,mv_par08)
		@ li,aColuna[5] PSay nTotIpi  Picture PesqPict("SD2","D2_VALIMP1",12,mv_par08)
	Else
		@ li,aColuna[15] PSay nTotVal1 Picture PesqPict("SD2","D2_TOTAL",18)
		@ li,aColuna[5] PSay nTotIpi  Picture PesqPict("SD2","D2_VALIPI",12)
	Endif
	
	@ li,aColuna[9] PSay "|"
	@ li,aColuna[10] PSay nTotQtd2 Picture PesqPictQt("D2_QUANT",11)
	@ li,aColuna[16]  PSay nTotVal2 Picture PesqPict("SD2","D2_TOTAL",18,mv_par08)
	
	If cPaisLoc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
		@ li,aColuna[13] PSay nTotIpi2 Picture PesqPict("SD2","D2_VALIMP1",12,mv_par08)
	Else
		@ li,aColuna[13] PSay nTotIpi2 Picture PesqPict("SD2","D2_VALIPI",11)
	Endif
	
	@ li,aColuna[14] PSay "|"
	li++
	@ li,00 PSay __PrtFatLine()
	
	roda(cbcont,cbtxt,tamanho)
EndIF


IF nOrdem != 2	// Nao for por tipo
	RetIndex("SD2")
	dbClearFilter()
	IF File(cIndice+OrdBagExt())
		Ferase(cIndice+OrdBagExt())
	Endif
Endif

If mv_par04 <> 3
	dbSelectArea( "SD1" )
	RetIndex("SD1")
	dbClearFilter()
	IF File(cArqSD1+OrdBagExt())
		Ferase(cArqSD1+OrdBagExt())
	Endif
	dbSetOrder(1)
Endif

dbSelectArea(( cAliasTmp ))
cExt := OrdBagExt()
If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)
	oTempTable := nil
EndIf

If File(cIndTrab + cExt)
	FErase(cIndTrab+cExt)	 //indice gerado
Endif

dbSelectArea("SD1")
dbClearFilter()
dbSetOrder(1)
dbSelectArea("SD2")
dbClearFilter()
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CalcDev  ³ Autor ³     Marcos Simidu     ³ Data ³ 17.02.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo de Devolucoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR660                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcDev(cDup,cEst,cAliasTmp)

dbSelectArea("SD1")
If dbSeek(xFilial()+( cAliasTmp )->D2_COD+( cAliasTmp )->D2_SERIE+( cAliasTmp )->D2_DOC+( cAliasTmp )->D2_ITEM)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Soma Devolucoes          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( cAliasTmp )->D2_CLIENTE+( cAliasTmp )->D2_LOJA == D1_FORNECE+D1_LOJA
		If !(D1_ORIGLAN == "LF")
			If AvalTes(D1_TES,cEst,cDup)
				If AvalTes(D1_TES,cEst) .And. (cEst == "S" .Or. cEst == "SN" )
					nDevQtd1+= D1_QUANT
				Endif
				nDevVal1 +=xMoeda((D1_TOTAL-D1_VALDESC),( cAliasTmp )->D2_MOEDA,mv_par08,D1_DTDIGIT,nDecs+1,( cAliasTmp )->D2_TXMOEDA)
				If cPaisLoc<>"BRA"  // Localizado para imprimir o IVA 24/05/00
					nDevipi += xMoeda(D1_VALIMP1,( cAliasTmp )->D2_MOEDA,mv_par08,D1_DTDIGIT,nDecs+1,( cAliasTmp )->D2_TXMOEDA)
				Else
					nDevipi += xMoeda(D1_VALIPI,1,mv_par08,D1_DTDIGIT)
				Endif
				
			Else
				If AvalTes(D1_TES,cEst) .And. (cEst == "S" .Or. cEst == "SN" )
					nDevQtd2+= D1_QUANT
				Endif
				nDevVal2 +=xMoeda((D1_TOTAL-D1_VALDESC),( cAliasTmp )->D2_MOEDA,mv_par08,D1_DTDIGIT,nDecs+1,( cAliasTmp )->D2_TXMOEDA)
			Endif
		Endif
	Endif
Endif
Return .T.