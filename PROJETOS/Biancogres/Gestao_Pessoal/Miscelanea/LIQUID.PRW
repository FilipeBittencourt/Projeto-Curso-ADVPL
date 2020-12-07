#INCLUDE "rwmake.CH"
#define STR0001  "Filial+Bco/Ag.+Mat"
#define STR0002  "Filial+Bco/Ag.+Cc+Mat"
#define STR0003  "Filial+Bco/Ag.+Nome"
#define STR0004  "Filial+Bco/Ag.+Cta"
#define STR0005  "Filial+Bco/Ag.+Cc+Nome"
#define STR0006  "Bco/Ag.+Mat"
#define STR0007  "Bco/Ag.+Cc+Mat"
#define STR0008  "Bco/Ag.+Nome"
#define STR0009  "Bco/Ag.+Cta"
#define STR0010  "Bco/Ag.+Cc+Nome"
#define STR0011  "Relacao de Liquidos."
#define STR0012  "Ser  impresso de acordo com os parametros solicitados pelo"
#define STR0013  "usuario."
#define STR0014  "Zebrado"
#define STR0015  "Administracao"
#define STR0016  "                                      -------  F U N C I O N A R I O  -------                                    "
#define STR0017  "FIL. BANCO      CCUSTO                 MATRIC.  NOME                              C.P.F.        C O N T A           V A L O R"
#define STR0018  "RELACAO DE LIQUIDOS"
#define STR0019  "RELACAO DE LIQUIDOS DO ADIANTAMENTO"
#define STR0020  "RELACAO DE LIQUIDOS DA FOLHA"
#define STR0021  "RELACAO DE LIQUIDOS DA 1a PARCELA DO 13o SALARIO  "
#define STR0022  "RELACAO DE LIQUIDOS DA 2a PARCELA DO 13o SALARIO  "
#define STR0023  "RELACAO DE LIQUIDOS DAS FERIAS  "
#define STR0024  "RELACAO DE LIQUIDOS DE VAL.EXTRAS "
#define STR0025  "TOTAL DA PAGINA"
#define STR0026  "QUANTIDADE.:"
#define STR0027  "TRANSPORTADO PAGINA ANTERIOR"
#define STR0028  "QUANTIDADE.:"
#define STR0029  "TOTAL DO C.CUSTO  "
#define STR0030  " QUANTIDADE.:"
#define STR0031  "TOTAL  AGENCIA  "
#define STR0032  "   QUANTIDADE.:"
#define STR0033  "TOTAL DO BANCO  "
#define STR0034  "   QUANTIDADE.:"
#define STR0035  "TOTAL DA FILIAL "
#define STR0036  "   QUANTIDADE.:"
#define STR0037  "TOTAL DA EMPRESA "
#define STR0038  "  QUANTIDADE.:"
#define STR0039  "Selecionando Registros..."
#define STR0040  "***  N o m e   Oculto   ***   "
#define STR0041  " ANALITICA "
#define STR0042  " SINTETICA "
#define STR0043  "                                                -------  B E N E F I C I A R I O  -------                                   "
#define STR0044  "                                    -------  F U N C I O N A R I O / B E N E F I C I A R I O  -------                       "
#define STR0045  "Func."
#define STR0046  "Benef."
#define STR0047  "Este Campo deve ser informado. Foi selecionado a opcao de impressao 'Com Conta Corrente' "

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER020  ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 03.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de Liquidos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER020(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Priscila R.³08/05/02³014139³Inclusao do numero do CPF do Funcionario  ³±±
±±³            ³--------³------³e Beneficiario.                           ³±±
±±³ Priscila R.³17/05/02³------³Ajuste no relatorio para que seja impresso³±±
±±³            ³--------³------³corretamente o C.C no tamanho 20.         ³±±
±±³ Priscila R.³09/08/02³------³Exclusao da Pergunta Taref. Mensalista que³±±
±±³            ³--------³------³nao estava sendo usada,ajustes nos mv_par.³±±
±±³ Emerson    ³21/08/02³------³Ajuste p/ quebrar corretamente por Filial.³±±
±±³ Emerson    ³08/11/02³------³Alterar pergunta "Data Ini.Ferias De/Ate" ³±±
±±³            ³--------³------³para "Data de Pagamento De/Ate".		  ³±±
±±³ Emerson    ³31/03/03³------³Passar a nao filtrar Bco/Age pelo SRA para³±±
±±³            ³--------³------³nao perder a impressao dos beneficiarios. ³±±
±±³ Priscila R.³28/07/03³------³Alt. p/listar Demitidos de acordo com o pa³±±
±±³            ³--------³------³rametro Data De/Ate.Inclus.Perg."Totaliza ³±±
±±³            ³--------³------³por Agencia".                             ³±±
±±³ Natie      ³17/05/04³------³Acerto Total Agencia e quebra de Pagina   ³±±
±±³ Natie      ³18/08/04³073420³Nao estava considerando Vlr do Benefic. no³±±
±±³            ³        ³      ³total do Rel. no modo Sintetico           ³±±
±±³ Natie      ³28/10/04³074506|Impr.somente de benefic Com/Sem Conta     ³±±
±±³            ³        ³074940|Retirada do DbSkip qdo testa func.Demitido³±±
±±³            ³        ³075738|Totaliza p/Agencia de acordo c/cTotAgen   ³±±
±±³            ³        ³074211|Totaliza p/Filial de acordo c/parametro   ³±±
±±³            ³        ³------|Validacao nos param. C.Corrente De/Ate    ³±±
±±³ Ricardo D. ³26/11/04³074506|Tratamento para impressao de Ambos ( Func+³±±
±±³            ³        ³------|Benef) Com ou Sem Conta Corrente.         ³±±
±±³ Ricardo D. ³14/02/05³077912|Ajuste no salto de pagina entre agencias  ³±±
±±³            ³        ³------|quando a pergunta Totaliza por Agencia es-³±±
±±³            ³        ³------|tava com "N".                             ³±±
±±³ Ricardo D. ³14/02/05³077913|Ajuste na impressao do total da agencia p/³±±
±±³            ³        ³------|imprimir o total na sequencia dos funciona³±±
±±³            ³        ³------|rios sempre que tiver espaco.             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function UGPER020()
Local cSavCur1,cSavRow1,cSavCol1,cSavCor1,cSavScr1,cSavScr2,CbTxt // Ambiente
Local aRegs	   	:= {}

Local cString :="SRA"        // alias do arquivo principal (Base)
Local aOrd	  :=	{	STR0001,;					//"Filial+Bco/Ag.+Mat"
			 			STR0002,;					//"Filial+Bco/Ag.+Cc+Mat"
						STR0003,;					//"Filial+Bco/Ag.+Nome"
						STR0004,;					//"Filial+Bco/Ag.+Cta"
						STR0005,;					//"Filial+Bco/Ag.+Cc+Nome"
						STR0006,;					//"Bco/Ag.+Mat"
						STR0007,;					//"Bco/Ag.+Cc+Mat"
						STR0008,;					//"Bco/Ag.+Nome"
						STR0009,;					//"Bco/Ag.+Cta"
						STR0010,;   				//"Bco/Ag.+Cc+Nome"						           
						"Filial+Matricula",; 		//"Filial+Matricula"
						"Filial+Nome",;				//"Filial+Nome"
						"Filial+C.Custo+Matricula",; //"Filial+C.Custo+Matricula"
						"Filial+C.Custo+Nome"}      //"Filial+C.Custo+Nome"
Local	cDesc1	:=		STR0011		//"Relacao de Liquidos."
Local	cDesc2	:=		STR0012		//"Ser  impresso de acordo com os parametros solicitados pelo"
Local	cDesc3	:=		STR0013		//"usuario."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCodigosAdt:={}
Local aHelpPor	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn := {STR0014, 1,STR0015, 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
Private nomeprog:="GPER020"
Private aLinha  := { },nLastKey := 0
Private cPerg   :="GPR020"
Private nExtra, AgeAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
private Quebloc := Quebloc1 := .T.
Private cIndCond
Private cFor
Private nOrdem
Private aInfo:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Titulo
Private AT_PRG  := "UGPER020"
Private cCabec
Private wCabec0 := 3
Private wCabec1:="                                                                                                                     "
Private wCabec2:=STR0016		//"                                     |-------  F U N C I O N A R I O  -------|                                   "
Private wCabec3:=Stuff(STR0017,At("C.P.F.",STR0017),6,PadR(RetTitle("RA_CIC"),6))		//"FIL. BANCO      CCUSTO      MATRIC. NOME                            C.P.F.     C O N T A          V A L O R"
Private CONTFL:=1
Private LI:=0
Private nTamanho:="M"

AADD(aHelpPor,"Informe se deseja que seja impresso no")
AADD(aHelpPor,"Relatorio os Totais por Agencia. ")
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³           Grupo  Ordem Pergunta Portugues     Pergunta Espanhol       Pergunta Ingles         Variavel 	Tipo  Tamanho Decimal Presel  GSC   Valid                              Var01     	 Def01      DefSPA1      DefEng1      Cnt01          					  Var02  Def02    	    DefSpa2          DefEng2	Cnt02  Var03 		Def03      DefSpa3    DefEng3  		Cnt03  Var04  Def04     DefSpa4    DefEng4  Cnt04 		 Var05  Def05       DefSpa5	 DefEng5   Cnt05  	XF3  GrgSxg   cPyme   aHelpPor  aHelpEng	 aHelpSpa    cHelp      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Aadd(aRegs,{cPerg,"19","Conta Corrente  De ?","¨De Cta.Corriente  ?","From Curr. Account ?",    "mv_chj","C"   ,12   	    ,0		,0	 ,"G"   ,"fChkConta(MV_PAR19)"						,"mv_par19"	,""		    ,""		    ,""			    ,""		                        ,""		,""			    ,""			    ,""		    ,""		,"" 		,""			,""			,""			,"" 	,"" 	,""			,""		,""		  ,""		,""		,""			,""		,""			,""		,""		,""		,""		,{}	        ,{}			,{}		,""})
Aadd(aRegs,{cPerg,"20","Conta Corrente  Ate?","¨A  Cta.Corriente  ?","To   Curr. Account ?",    "mv_chk","C"   ,12		    ,0		,0	 ,"G"   ,"fChkConta(MV_PAR20)"						,"mv_par20"	,""		    ,""		    ,""			    ,""		                        ,""		,""			    ,""			    ,""		    ,""		,"" 		,""			,""			,""			,"" 	,"" 	,""			,""		,""		  ,""		,""		,""			,""		,""			,""		,""		,""		,""		,{}	        ,{}			,{}		,""})
Aadd(aRegs,{cPerg,"25","Data de Pagto De   ?","¨De Fecha de Pago  ?","From Payment Date  ?"		,"mv_chp","D"	,	08		,0		,0	 ,"G" 	,"NaoVazio"							,"mv_par25"	,""			,""			,""				,""								,""		,""				,""				,""			,""		,""			,""			,""			,""			,""		,""		,""			,""		,""		  ,"" 		,""		,""			,""		,""			,""		,""		,""		,""		,{}			,{}			,{}		,""})
Aadd(aRegs,{cPerg,"26","Data de Pagto Ate  ?","¨A  Fecha de Pago  ?","To   Payment Date  ?"		,"mv_chq","D"	,	08		,0		,0	 ,"G"	,"NaoVazio"							,"mv_par26"	,""			,""			,""				,""								,""		,""				,""				,""			,""		,""			,""			,""			,""			,""		,""		,""			,""		,""		  ,"" 		,""		,""			,""		,""			,""		,""		,""		,""		,{}			,{}			,{}		,""})
Aadd(aRegs,{cPerg,"28","Totaliza p/ Agencia?","¨Totaliza p/Agencia?","Totaliza p/ Agencia?"		,"mv_chs","C"	,	01		,0		,1	 ,"C" 	,""									,"mv_par28"	,"Sim"		,"Si"		,"Yes"			,""								,""		,"Nao"			,"No"			,"No"		,""		,"" 		,""			,""			,""			,"" 	,"" 	,""			,""		,""		  ,""		,""		,""			,""		,""			,""		,""		,""		,""		,aHelpPor	,{}			,{}		,""})

//ValidPerg(aRegs,"GPR020",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui as Perguntas no SX1                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRegs	:= {}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³           Grupo  Ordem Pergunta Portugues     Pergunta Espanhol       Pergunta Ingles         Variavel 	Tipo  Tamanho Decimal Presel  GSC   Valid                              Var01     	 Def01      DefSPA1      DefEng1      Cnt01          					  Var02  Def02    	    DefSpa2          DefEng2	Cnt02  Var03 		Def03      DefSpa3    DefEng3  		Cnt03  Var04  Def04     DefSpa4    DefEng4  Cnt04 		 Var05  Def05       DefSpa5	 DefEng5   Cnt05  	XF3  GrgSxg   cPyme   aHelpPor  aHelpEng	 aHelpSpa    cHelp      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdd(aRegs,{cPerg,"31","Categorias         ?" ,"¨Categorias        ?","Categories         ?"	,"mv_chv","C"  ,	15		,0		,0	 ,"G"	,"fCategoria"						,"mv_par31" ,""			,""			,""				,""			 					, ""	,""				,""				,""			,""		 ,""		,""			,""			,""			,""		,""		,""			,""		,""		  ,""		,""		,""			,""		,""			,""		,""		,"S"	,""		,{}        	,{}			,{}		,".RHCATEG."})

//ValidPerg(aRegs,cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("GPR020",.F.)
cTit := STR0018		//"RELA€O DE LIQUIDOS"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="GPER020"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@cTit,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdem		:= aReturn[8]
lAdianta	:= If(mv_par01 == 1,.T.,.F.)		// Adiantamento
lFolha		:= If(mv_par02 == 1,.T.,.F.)		// Folha
lPrimeira	:= If(mv_par03 == 1,.T.,.F.)		// 1¦Parc. 13§ Sal rio
lSegunda	:= If(mv_par04 == 1,.T.,.F.)		// 2¦Parc. 13§ Sal rio
lFerias		:= If(mv_par05 == 1,.T.,.F.)		// F‚rias
lExtras		:= If(mv_par06 == 1,.T.,.F.)		// Extras
lRescisao   := .F. 								// Definida para utilizacao em fBuscaLiq()
Semana		:= mv_par07     				 	// Numero da Semana
ComConta	:= If(mv_par08 == 1,"C",(If(mv_par08 == 2,"S","A")))	//  Qto. a Conta Corrente
FilialDe	:= mv_par09							// Filial  De
FilialAte	:= mv_par10							// Filial  Ate
CcDe		:= mv_par11							// Centro de Custo De
CcAte		:= mv_par12							// Centro de Custo Ate
BcoDe		:= mv_par13							// Banco /Agencia De
BcoAte		:= mv_par14							// Banco /Agencia Ate
MatDe		:= mv_par15							// Matricula De
MatAte		:= mv_par16							// Matricula Ate
NomDe		:= mv_par17							// Nome De
NomAte		:= mv_par18							// Nome Ate
CtaDe		:= mv_par19							// Conta Corrente De
CtaAte		:= mv_par20							// Conta Corrente Ate
cSituacao	:= mv_par21							// Situacao
Quebloc		:= If(mv_par22 == 1,.T.,.F.)		// Totalizar por Filial
cSalta		:= If(mv_par23 == 1,"S","N")		// Imprime Filial em Outra Pagina
LstNome		:= If(mv_par24 == 1,"S","N")		// Mostrar Nomes dos Funcionarios
dDataDe		:= mv_par25							// Data Pagamento De
dDataAte	:= mv_par26							// Data Pagamento Ate
cSaltaAg	:= If(mv_par27 == 1,"S","N")		// Quebra Pagina p/Agencia   Sim,Nao
cTotAgen	:= If(mv_par28 == 1,"S","N")		// Totaliza por Agencia
cTipoRel	:= If(mv_par29 == 1, "A" , "S" )	// Tipo de Relacao:1-Analitica, 2-Sintetica
nFunBenAmb  := mv_par30  						// Imprimir : 1-Funcionarios  2-Beneficiarias  3-Ambos
cCategoria	:= mv_par31 						// Categorias
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Pega descricao da semana                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec := If(Semana # Space(2),fRetPer( Semana,dDataBase )," ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao imprime Quando Relacao Sintetica.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF cTipoRel == "S"
	wCabec2 := ""
EndIF

If lAdianta
	Titulo := STR0019 	//"RELACAO DE LIQUIDOS DO ADIANTAMENTO"
Elseif lFolha
	Titulo := STR0020		//"RELACAO DE LIQUIDOS DA FOLHA"
Elseif lPrimeira
	Titulo := STR0021		//"RELACAO DE LIQUIDOS DA 1a PARCELA DO 13o SALARIO  "
Elseif lSegunda
	Titulo := STR0022		//"RELACAO DE LIQUIDOS DA 2a PARCELA DO 13o SALARIO  "
Elseif lFerias
	Titulo := STR0023		//"RELACAO DE LIQUIDOS DAS FERIAS  "
Elseif lExtras
	Titulo := STR0024		//"RELACAO DE LIQUIDOS DE VAL.EXTRAS "
Else
   Titulo := " "
Endif

Titulo += " ("+StrZero( aReturn[8] , 2 )+")"+If(!Empty(cCabec)," - "+cCabec,"") + IF(cTipoRel="A",STR0041,STR0042) //Analitica###Sintetica

If LastKey() = 27 .Or. nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If LastKey() = 27 .OR. nLastKey = 27
	Return
Endif

RptStatus({|lEnd| R020Imp(@lEnd,wnRel,cString)},cTit)  // Chamada do Relatorio

Return

*------------------------------------------*
Static Function R020Imp(lEnd,WnRel,cString)
*------------------------------------------*
Local nTotregs,nMult,nPosAnt,nPosAtu,nPosCnt,cSav20,cSav7 //Regua
Local tamanho:="P"
Local limite := 80
Local aOrdBag    := {}
Local aValBenef  := {}
Local aBenefCop  := {}
Local cArqMov := cAliasMov := ""
Local cMesArqRef := StrZero(Month(dDataBase),2) + StrZero(Year(dDataBase),4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCodigosAdt := {}
Local aCodFol     := {}
Local nCntP
Private cPict1	:=	TM(99999999999,17,MsDecimais(1))// "@E  99,999,999,999.99"
Private cPict2	:=	TM(999999999999,18,MsDecimais(1))//"@E 999,999,999,999.99"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Acesso do Usuario                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cAcessaSR1	:= &( " { || " + ChkRH( "GPER020" , "SR1" , "2" ) + " } " )
Private cAcessaSRA	:= &( " { || " + ChkRH( "GPER020" , "SRA" , "2" ) + " } " )
Private cAcessaSRC	:= &( " { || " + ChkRH( "GPER020" , "SRC" , "2" ) + " } " )
Private cAcessaSRG	:= &( " { || " + ChkRH( "GPER020" , "SRG" , "2" ) + " } " )
Private cAcessaSRH	:= &( " { || " + ChkRH( "GPER020" , "SRH" , "2" ) + " } " )
Private cAcessaSRI	:= &( " { || " + ChkRH( "GPER020" , "SRI" , "2" ) + " } " )
Private cAcessaSRR	:= &( " { || " + ChkRH( "GPER020" , "SRR" , "2" ) + " } " )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define se devera ser impresso Funcionarios ou Beneficiarios  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SRQ" )
lImprFunci  := ( nFunBenAmb # 2 )
lImprBenef  := ( nFunBenAmb # 1 .And. FieldPos( "RQ_BCDEPBE" ) # 0 .And. FieldPos( "RQ_CTDEPBE" ) # 0 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informa a nao existencia dos campos de bco/age/conta corrente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFunBenAmb # 1 .And. !lImprBenef
	fAvisoBC()
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Muda cabecalho se impressao de beneficiarias                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lImprBenef
	If nFunBenAmb == 2
		wCabec2 := STR0043		//"                         -------  B E N E F I C I A R I O  -------                                   "
	Else
		wCabec2 := STR0044		//"                         -------  F U N C I O N A R I O / B E N E F I C I A R I O  -------                       "
	EndIf
EndIF

If !OpenSrc( cMesArqRef, @cAliasMov, @aOrdBag, @cArqMov, dDataBase )
	Return .f.
Endif

dbSelectArea("SRA")
If nOrdem == 1
	cIndCond:= "RA_FILIAL + RA_BCDEPSA + RA_MAT"
	cFor:= '(RA_FILIAL+RA_MAT >= "'+FilialDe+MatDe+'")'
	cFor+= '.And. (RA_FILIAL+RA_MAT <= "'+FilialAte+MatAte+'")'
ElseIf nOrdem == 2
	cIndCond:= "RA_FILIAL + RA_BCDEPSA + RA_CC + RA_MAT"
	cFor:='(RA_FILIAL+RA_CC+RA_MAT >= "'+FilialDe+CcDe+MatDe+'")'
	cFor+=' .And. (RA_FILIAL+RA_CC+RA_MAT <= "'+FilialAte+CcAte+MatAte+'")'
ElseIf nOrdem == 3
	cIndCond:= "RA_FILIAL + RA_BCDEPSA + RA_NOME"
	cFor:='(RA_FILIAL+RA_NOME >= "'+FilialDe+NomDe+'")'
	cFor+=' .And. (RA_FILIAL+RA_NOME <= "'+FilialAte+NomAte+'")'
Elseif nOrdem == 4
	cIndCond:= "RA_FILIAl + RA_BCDEPSA + RA_CTDEPSA"
	cFor:='(RA_FILIAL+RA_CTDEPSA >= "'+FilialDe+CtaDe+'")'
	cFor+=' .And. (RA_FILIAL+RA_CTDEPSA <= "'+FilialAte+CtaAte+'")'
ElseIf nOrdem == 5
	cIndCond:= "RA_FILIAL + RA_BCDEPSA + RA_CC + RA_NOME"
	cFor:='(RA_FILIAL+RA_CC+RA_NOME >= "'+FilialDe+CcDe+NomDe+'")'
	cFor+=' .And. (RA_FILIAL+RA_CC+RA_NOME <= "'+FilialAte+CcAte+NomAte+'")'
ElseIf nOrdem == 6
	cIndCond:= "RA_BCDEPSA + RA_MAT"
	cFor:='(RA_MAT >= "'+MatDe+'")'
	cFor+=' .And. (RA_MAT <= "'+MatAte+'")'
ElseIf nOrdem == 7
	cIndCond:= "RA_BCDEPSA + RA_CC + RA_Mat"
	cFor:='(RA_CC+RA_Mat >= "'+CcDe+MatDe+'")'
	cFor+=' .And. (RA_CC+RA_Mat <= "'+CcAte+MatAte+'")'
Elseif nOrdem == 8
	cIndCond:= "RA_BCDEPSA + RA_NOME"
	cFor:='(RA_NOME >= "'+NomDe+'")'
	cFor+=' .And. (RA_NOME <= "'+NomAte+'")'
ElseIf nOrdem == 9
	cIndCond:= "RA_BCDEPSA + RA_CTDEPSA"
	cFor := ''
ElseIf nOrdem == 10
	cIndCond:= "RA_BCDEPSA + RA_CC + RA_NOME"
	cFor:='(RA_CC+RA_NOME >= "'+CcDe+NomDe+'")'
	cFor+=' .And. (RA_CC+RA_NOME <= "'+CcAte+NomAte+'")'
ElseIf nOrdem == 11
	cIndCond:= "RA_FILIAL + RA_MAT"
	cFor:='(RA_FILIAL+RA_MAT >= "'+FilialDe+MatDe+'")'
	cFor+=' .And. (RA_FILIAL+RA_MAT <= "'+FilialAte+MatAte+'")'
ElseIf nOrdem == 12
	cIndCond:= "RA_FILIAL + RA_NOME"
	cFor:='(RA_FILIAL+RA_NOME >= "'+FilialDe+NomDe+'")'
	cFor+=' .And. (RA_FILIAL+RA_NOME <= "'+FilialAte+NomAte+'")'
ElseIf nOrdem == 13
	cIndCond:= "RA_FILIAL + RA_CC + RA_MAT"
	cFor:='(RA_FILIAL+RA_CC+RA_MAT >= "'+FilialDe+CcDe+MatDe+'")'
	cFor+=' .And. (RA_FILIAL+RA_CC+RA_MAT <= "'+FilialAte+CcAte+MatAte+'")'
ElseIf nOrdem == 14
	cIndCond:= "RA_FILIAL + RA_CC + RA_NOME"
	cFor:='(RA_FILIAL+RA_CC+RA_NOME >= "'+FilialDe+CcDe+NomDe+'")'
	cFor+=' .And. (RA_FILIAL+RA_CC+RA_NOME <= "'+FilialAte+CcAte+NomAte+'")'

Endif

cArqNtx  := CriaTrab(NIL,.F.)
IndRegua("SRA",cArqNtx,cIndCond,,cFor,STR0039)				//"Selecionando Registros..."
DbGoTop()

SetRegua(RecCount())   // Total de elementos da regua

FilAnt := "!!"
AgeAnt := Space(08)
BcoAnt := Space(03)
CcAnt  := Space(09)
CtaAnt := Space(12)
NomAnt := Space(30)

tEmpresa := tPAGINA  := tFilial := tBanco  := tAgencia := tCc := 0
tFunEmp  := tFunPag  := tFunFil := TFunAge := tFunBan  := tFunTcc := 0
nTransval:= nTransFun:= nFlag := 0
cPula :=" "

dbSelectArea( "SRA" )
While !EOF()

	IncRegua()  										//-- Anda a regua

	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	Endif

	nValor    := 0
	aValBenef := {}

	If SRA->RA_FILIAL # FilAnt
		If !Fp_CodFol(@aCodFol,SRA->RA_FILIAL) .Or. !fInfo(@aInfo,SRA->RA_FILIAL)
			Exit
		Endif
		FilAnt := SRA->RA_FILIAL
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Parametrizacao do Intervalo de Impressao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SRA->RA_NOME    < NomDe) .Or. (SRA->RA_NOME    > NomAte) .Or. ;
	   (SRA->RA_MAT     < MatDe) .Or. (SRA->RA_MAT     > MatAte) .Or. ;
	   (SRA->RA_FILIAL  < FilialDe) .Or. (SRA->RA_FILIAL> FilialAte) .Or. ;
	   (SRA->RA_CC      < CcDe ) .Or. (SRA->RA_CC      > CcAte )
       TestaTotal()
	   Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste controle de acessos e filiais validas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
		TestaTotal()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verif. se Demitido esta dentro da Data de Pagamento do Parametro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SRA->RA_SITFOLH =="D")
		dbSelectArea("SRG")
		If dbSeek( SRA->(RA_FILIAL + RA_MAT )  )
			While !( SRG->( Eof() ) )  .And. SRA->(RA_FILIAL + RA_MAT ) ==  SRG->(RG_FILIAL + RG_MAT )
				If SRG->RG_DATAHOM >= dDataDe .And. SRG->RG_DATAHOM <= dDataAte
					lRescisao := .T.
				EndIf
				SRG->( dbSkip())
			Enddo
		Else
			dbSelectArea("SRA")
			TestaTotal()
			Loop
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca os valores de Liquido e beneficios                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fBuscaLiq(@nValor,@aValBenef,aCodFol)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste parametros de banco e conta do funcionario			 ³
	//³ Se nFunBenAmb=2, apenas sera testado a Bco e conta do Benefic³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFunBenAmb # 2 	.and.  ;										//-- Se nao for Beneficiario, testa Bco e Conta do Funcionario
	   ((SRA->RA_BCDEPSA < BcoDe) .Or. (SRA->RA_BCDEPSA > BcoAte) .Or. ;
	    ( ComConta ="C" .and. ( SRA->RA_CTDEPSA < CtaDe) .Or. (SRA->RA_CTDEPSA > CtaAte)  ) .Or.;
		( COMCONTA = "C" .And. SRA->RA_CTDEPSA == SPACE(LEN(SRA->RA_CTDEPSA)) .and. nFunBenAmb # 2) .Or.;
		( COMCONTA = "S" .And. SRA->RA_CTDEPSA #  SPACE(LEN(SRA->RA_CTDEPSA)) .and. nFunBenAmb # 2) )
	   nValor := 0
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste parametros de banco e conta do beneficiario 		 ³
	//³ aValBenef: 1-Nome  2-Banco  3-Conta  4-Verba  5-Valor  6-CPF ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aValBenef) > 0
		aBenefCop  := ACLONE(aValBenef)
		aValBenef  := {}

		If ( nFunBenAmb == 2 .or. nFunBenAmb == 3)
			If ComConta="C" 					//-- Beneficiario e  com Conta, testo a Conta
				Aeval(aBenefCop, { |X| If( ( X[2] >= BcoDe .And. X[2] <= BcoAte ) .And. ;
							           ( X[3] >= CtaDe .And. X[3] <= CtaAte .and.;
							            !Empty(X[3]) ) ,  ;
						                AADD(aValBenef,X ), "" ) })

			ElseIf ComConta="S"				//-- Se for beneficiario,  sem  Conta
				Aeval(aBenefCop, { |X| If(( X[2] >= BcoDe .And. X[2] <= BcoAte    ) .And.  ;
							           ( X[3] = Space( TamSX3("RQ_CTDEPBE")[1] )) ,;
										 AADD(aValBenef,X ), ""  )  })
			ElseIf ComConta = "A"
				Aeval(aBenefCop, { |X| If( ( ( X[2] >= BcoDe .And. X[2] <= BcoAte ) .And. ;
							             ( X[3] >= CtaDe .And. X[3] <= CtaAte  ) ) .or. ;
				                       ( ( X[2] >= BcoDe .And. X[2] <= BcoAte  ) .And.  ;
							              ( X[3] = Space( TamSX3("RQ_CTDEPBE")[1] )) ), ;
										 AADD(aValBenef,X ), ""  )  })
			EndIf
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 1- Testa Situacao do Funcionario na Folha					 ³
    //³ 1- Testa Categoria do Funcionario na Folha					 ³
	//³ 2- Testa Com Conta											 ³
	//³ 3- Testa Sem Conta											 ³
	//³ 4- Testa se Valor == 0										 ³
	//³ 5- Testa se beneficiario e               					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !( SRA->RA_SITFOLH $ cSituacao ) .Or. !(SRA->RA_CATFUNC $ cCategoria) .Or.;
		( nValor == 0 .And. Len(aValBenef) == 0 ) .or. ;
		( nFunBenAmb == 2 .And. Len(aValBenef) == 0)
		TestaTotal()
		Loop
	Endif

	If cPula == "S"		// Imprime quebra de Pagina quando
		Impr(" ","P")	// existe mais um funcionario a ser
		cPula := " "		// impresso.
	ElseIf cPula == "N"	// Imprime uma linha em branco apos
		IMPR("","C")    // os totais.
		cPula := " "
	Endif

	nContador := If(nValor > 0, 1, 0)
	nValBenef := 0
	IF cTipoRel == "A"	//So Imprime Dados dos Funcionarios quando Relacao For Analitica.
		Det := SRA->RA_FILIAL+"   "+SRA->RA_BCDEPSA+"   "+SUBS(SRA->RA_CC+SPACE(20),1,20)+"   "+SRA->RA_MAT+"   "
		Det += Iif(lstnome="S",SUBS(SRA->RA_NOME,1,30),STR0040) +"   "+SRA->RA_CIC+"   "		//"***  N o m e   Oculto   ***   "## "CPF"
		Det += SRA->RA_CTDEPSA+" "+Transform(nValor,cPict1) + If(Len(aValBenef) > 0, "-" + STR0045, "") //##"Funcionario"
		IMPR(DET,"C")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao dos Beneficiarios                          		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntP := 1 To Len(aValBenef)
			If !Empty(aValBenef[nCntP,1]) .And. aValBenef[nCntP,5] > 0
				Det := SRA->RA_FILIAL+"   "+aValBenef[nCntP,2]+"   "+SUBS(SRA->RA_CC+space(20),1,20)+"   "+SRA->RA_MAT+"   "
				Det += Iif(lstnome="S",SUBS(aValBenef[nCntP,1],1,30),STR0040) +"   "+aValBenef[nCntP,6]+"   "		//"***  N o m e   Oculto   ***   "## C.P.F.
				Det += aValBenef[nCntP,3]+" "+Transform(aValBenef[nCntP,5],"@E 99,999,999,999.99") + "-" + STR0046 //##"Beneficiaria"
				IMPR(DET,"C")
			Endif
		Next nCntP
	Endif
	Aeval(aValBenef,{|x| nContador++ })
	Aeval(aValBenef,{|x| nValBenef+= x[5] })

	TfunPag   += nContador                 // Adicionando Funcionarios
	TfunFil   += nContador                 // Aos Contadores
	TfunAge   += nContador
	TfunBan   += nContador
	TfunTcc   += nContador
	TfunEmp   += nContador

	Tpagina   += ( nValor +nValBenef )    // Adicionando Valor aos
	Tfilial   += ( nValor +nValBenef )    // Acumuladores
	TAgencia  += ( nValor +nValBenef )
	Tbanco    += ( nValor +nValBenef )
	Tcc       += ( nValor +nValBenef )
	Tempresa  += ( nValor +nValBenef )

	If Li >= 53
		TotalPag()     // Quebra Pagina quando excede numero de linhas
		nFlag:=1
	Endif
	TestaTotal()
Enddo

If tFunEmp > 0
	TotalEmp()
	IMPR(" ","F")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cAliasMov )
	fFimArqMov( cAliasMov , aOrdBag , cArqMov )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SRI" )
dbSetOrder(1)
dbSelectArea("SRA")
Set Filter to
RetIndex("SRA")
dbSetOrder(1)
fErase( cArqNtx + OrdBagExt() )
Set Device To Screen
If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif
MS_FLUSH()
Return

*-------------------------*
Static Function TestaTotal  // Teste para totalizacao
*-------------------------*
dbSelectArea ( "SRA" )
FilAnt := SRA->RA_FILIAL    // Iguala Variaveis
AgeAnt := SubStr(SRA->RA_BCDEPSA,4,5)
BcoAnt := SubStr(SRA->RA_BCDEPSA,1,3)
CcAnt  := SRA->RA_CC
NomAnt := SRA->RA_NOME

SRA->( dbSkip() )

If (SRA->RA_FILIAL # FilAnt .Or. Eof()) .And. (nOrdem <= 5)
	TotalPag()
	TotalCc()
	If cTotAgen == "S"
		TotalAge()
	EndIf
	if (nOrdem <> 11 .and. nOrdem <> 12 .and. nOrdem <> 13)
		TotalBan()
	Endif	
	If Quebloc
		TotalFil()
	Endif
	cPula := "S"

Elseif (SRA->RA_FILIAL <> FilAnt .or. Eof()) .And. (nOrdem == 11 .or. nOrdem == 12)
	TotalPag()
	TotalCc()
	If cTotAgen == "S"
		TotalAge()
	EndIf
	//TotalBan()
	If Quebloc
		TotalFil()
	Endif
	cPula := "S"
	
Elseif (SRA->RA_CC # CcAnt .Or. Eof()) .And. (nOrdem == 2 .or. nOrdem == 5 .or. nOrdem == 7 .or. nOrdem == 10 .or. nOrdem == 13 .or. nOrdem == 14)
	TotalPag()
	TotalCc()
	If cTotAgen == "S"
		TotalAge()
    EndIf
	If SubStr(SRA->RA_BCDEPSA,1,3) # BcoAnt .and. (nOrdem < 11)
		TotalBan()
	Endif
	cPula :=  "S"
ElseIf (SubStr(SRA->RA_BCDEPSA,1,3)) # BcoAnt .and. (nOrdem < 11) .Or. Eof()
	TotalPag()
	TotalCc()
	If cTotAgen == "S"
		TotalAge()
	Endif
	TotalBan()
	cPula := cSaltaAg  // -- "S" OU "N"
ElseIf (SubStr(SRA->RA_BCDEPSA,4,5) # AgeAnt  .and. cTotAgen == "S" ) .Or. Eof()
	TotalPag()
	TotalCc()
	TotalAge()
	cPula := cSaltaAg  // -- "S" OU "N"
ElseIf (SubStr(SRA->RA_BCDEPSA,4,5) # AgeAnt  .and. cTotAgen == "N" ) .and. (nOrdem < 11) .Or. Eof()
	TotalPag()
	TotalCc()
	cPula := cSaltaAg  // -- "S" OU "N"

Endif

If nFlag == 0
	nTransFun:=nTransVal:=0      	// Zera total a transportar
Endif                           	// apenas quando houver uma quebra
Return

*-----------------------*
Static Function TotalPag		// Totalizador por Pagina
*-----------------------*
If tFunPag == 0
	Return Nil
Endif

IF cTipoRel == "S"				//Nao Imprime Total da Pagina Quando a Relacao for Sintetica.
	Return NIL
EndIF


DET = REPLICATE("-",132)
IMPR(DET,"C")
DET := SPACE(5)+STR0025+SPACE(68)+STR0026+TRANSFORM(TFUNPAG,"99999")		//"TOTAL DA PAGINA"###"QTDE. FUNC.:"
DET += SPACE(02)+TRANSFORM(TPAGINA,cPict2)
IMPR(DET,"C")

If nFlag == 1
	IF nTRANSVAL # 0
		DET = REPLICATE("-",132)
		IMPR(DET,"C")
		DET := SPACE(5)+STR0027+SPACE(53)+STR0038+TRANSFORM(nTRANSFUN,"99999")	//"TRANSPORTADO PAGINA ANTERIOR"###"QTDE. FUNC.:"
		DET += SPACE(02)+TRANSFORM(nTRANSVAL,cPict2)
		IMPR(DET,"C")
		nFlag	:= 0
	ENDIF
Endif
nTransfun 	+= tFunPag
nTransVal 	+= tPagina
tFunPag 	:= tPagina := 0
cPula := "S"

Return
*----------------------*
Static Function TotalCc  	// Totalizador Por Centro de Custo
*----------------------*
Local Desc_Cc:=Space(40)

If (nOrdem # 2 .And. nOrdem # 5 .And. nOrdem # 7 .And. nOrdem # 10) .Or. tFunTcc == 0
	Return Nil                                     // Consistencia de Opcoes
Endif

If (li + 2) >= 58
	Impr("","P")
Endif

Desc_Cc :=fDesc("SI3",CcAnt, "SI3->I3_DESC")  + Space(15)   // Procura Descricao do Centro de Custo

DET = REPLICATE("-",132)
IMPR(DET,"C")
DET := SPACE(5)+STR0029+substr(DESC_CC+space(64),1,64)+STR0030+TRANSFORM(TFUNTCC,"99999")	//"TOTAL DO C.CUSTO  "###" QTDE. FUNC.:"
DET += SPACE(02)+TRANSFORM(TCC,cPict2)
IMPR(DET,"C")
tFunTCC := Tcc := 0
Return

*-----------------------*
Static Function TotalAge  // Totalizador por Banco
*-----------------------*
Local DESC_AGE := Space(40)

If tFunAge == 0
	Return Nil
Endif

IF (li + 2) >= 58
	IMPR("","P")
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao Para Buscar Nome do Banco ( SA6 )                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Desc_Age :=AgeAnt + " " + DescBco(BcoAnt+AgeAnt,SRA->RA_FILIAL,40,.T.)

DET = REPLICATE("-",132)
IMPR(DET,"C")
DET := SPACE(5)+STR0031+DESC_AGE+SPACE(18)+STR0032+TRANSFORM(TFUNAGE,"99999")	//"TOTAL  AGENCIA  "###"   QTDE. FUNC.:"
DET += SPACE(02)+TRANSFORM(TAGENCIA,cPict2)
IMPR(DET,"C")

tFunAge 	:= tAgencia 	:= 0
tFunPag 	:= tPagina 		:= 0
nTransval	:= nTransFun	:= 0
If (li + 3) >= 58
	Impr("","P")
Endif

Return

*-----------------------*
Static Function TotalBan  // Totalizador por Banco
*-----------------------*
Local DESC_BCO := Space(40)

If tFunBan == 0
	Return Nil
Endif

If (li + 2) >= 58
	Impr("","P")
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao Para Buscar Nome do Banco ( SA6 )                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Desc_Bco := BcoAnt + " " + DescBco(BcoAnt,SRA->RA_FILIAL)

DET = REPLICATE("-",132)
IMPR(DET,"C")
DET := SPACE(5)+STR0033+DESC_BCO+SPACE(20)+STR0034+TRANSFORM(TFUNBAN,"99999")	//"TOTAL DO BANCO  "###"   QTDE. FUNC.:"
DET += SPACE(02)+TRANSFORM(TBANCO,cPict2)
IMPR(DET,"C")
tFunBan := tBanco := 0

Return

*-----------------------*
Static Function TotalFil  // Totalizador por Empresa
*-----------------------*
Local cDesc_Fil := FilAnt+ " "+ aInfo[1] + Space(22)

If tFunFil == 0 .Or. (nOrdem >= 6)
	Return Nil
Endif

IF cSALTA == "S" .or.  (li + 2) >= 58
	IMPR("","P")
ENDIF

DET = REPLICATE("-",132)
IMPR(DET,"C")

DET := SPACE(5)+STR0035+cDesc_Fil+SPACE(24)+STR0036+TRANSFORM(tFunFil,"99999")	//"TOTAL DA FILIAL "###"   QTDE. FUNC.:"
DET += SPACE(02)+TRANSFORM(TFilial ,cPict2)
IMPR(DET,"C")
DET = REPLICATE("-",132)
IMPR(DET,"C")

IF cSALTA == "S"
	IMPR("","P")
ENDIF

//-- Reinicializa valores para a proxima Filial
tFunFil	:= TFilial 	:= 0
tFunPag	:= Tpagina 	:= 0
TFunAge := TAgencia	:= 0
tFunBan := Tbanco  	:= 0
tFunTcc := Tcc		:= 0

Return

*-----------------------*
Static Function TotalEmp  // Totalizador Geral
*-----------------------*
Local cDesc_Emp 	:= aInfo[3]

If tEmpresa == 0
	Return Nil
Endif

IF cSALTA = "S"  .or.  (li + 2) >= 58
	IMPR("","P")
ENDIF

DET := REPLICATE("-",132)
IMPR(DET,"C")
DET := SPACE(5)+STR0037+cDesc_Emp+SPACE(24)+STR0038+TRANSFORM(tFunEmp,"99999")	//"TOTAL DA EMPRESA "###"  QTDE. FUNC.:"
DET += SPACE(02)+TRANSFORM(tEmpresa ,cPict2)
IMPR(DET,"C")
DET := REPLICATE("-",132)
IMPR(DET,"C")

tFunEmp := tEmpresa:= 0

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fChkConta ºAutor  ³Microsiga           º Data ³  11/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o campo de Conta Corrente (Func/Benef) de acordo com º±±
±±º          ³mv_par08 (Com Conta/Sem Conta)                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPER020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fChkConta( cConteudo )

If mv_par08 == 1 .and. Empty(cConteudo) 			//-- Com  conta Corrente, nao permite q cpo de Conta Corrente fique em  branco
	Alert(oemToAnsi(STR0047) ) 				     	//-- Este Campo deve ser informado. Foi selecionado a opcao "Com  Conta Corrente"
	Return(.F.)
Endif

Return(.T.)

/*
Regra : De Acordo com  o parametro nFunBenAmb e ComConta, fica determinado:
		Se nFunBenAmb =
			-Funcionario : Testa Banco/Ag e C.Corrente somente do Funcionario.  Não testa Bco/Ag. e C.Corrente do Beneficiario.
			-Beneficiario: Testa Banco/Ag e C.Corrente somente do Beneficiario. Nao testa Bco/Ag. e C.Corrente do Funcionario.
			-Ambos       : Testa Banco/Ag e C.Corrente de Ambos
*/
