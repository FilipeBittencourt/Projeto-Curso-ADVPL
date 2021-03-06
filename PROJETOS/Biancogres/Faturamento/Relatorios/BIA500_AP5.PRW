#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 21/07/03
#IFDEF WINDOWS
	#DEFINE SAY PSAY
#ENDIF
#INCLUDE "TOPCONN.CH"

User Function BIA500()        // incluido pelo assistente de conversao do AP5 IDE em 21/07/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CSTRING,CDESC1,CDESC2,CDESC3,TAMANHO,ARETURN")
SetPrvt("NOMEPROG,NLASTKEY,CPERG,LABORTPRINT,NBEGIN,CDESCRI")
SetPrvt("NLINHA,CABEC1,CABEC2,LIMITE,LCONTINUA,LFLAG")
SetPrvt("NKEY,CBTXT,CBCONT,LI,M_PAG,LFIRST")
SetPrvt("TITULO,WNREL,ACAMPOS,CQUERY,CARQ,WMEDIA")
SetPrvt("WDIASPED,WNONF,WD2EMISSAO,WC6ENTREG,")

#IFDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 21/07/03 ==>    #DEFINE SAY PSAY
#ENDIF
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 21/07/03 ==> #INCLUDE "TOPCONN.CH"
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � BIA500   � Autor � Gustav Koblinger Jr   � Data �14.06.2000낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Estatisticas de atendimento de Pedidos                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe e � BIA500                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� BIA500                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � SIGAEST                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
//旼컴컴컴컴컴컴컴컴커
//� Define Variaveis �
//읕컴컴컴컴컴컴컴컴켸
cString   := "SC5"
cDesc1    := "Estatisticas de atendimento de Pedidos"
cDesc2    := ""
cDesc3    := " "
tamanho   := "M"
aReturn   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog  := "BIA500"
nLastKey  := 0
cPerg     := "BIA500"
lAbortPrint := .F.
nBegin    := 0
cDescri   := ""
nLinha    := 0
cabec1    := " - "
cabec2    := Replicate(" ", 220 )
limite    := 80
lContinua := .T.
lFlag     := .T.
nKey      := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Cbtxt     := ""
cbcont    := 0
li        := 80
m_pag     := 1
lFirst    := .T.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Variaveis utilizadas para parametros        �
//� mv_par01      //    Data De                 �
//� mv_par02      //    Data Ate                �
//� mv_par03      //    Serie De                �
//� mv_par04      //    Serie Ate               �
//� mv_par05      //    Filial De               �
//� mv_par06      //    Filial Ate              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//旼컴컴컴컴컴컴컴컴컴컴컴컴커
//� Definicao dos cabecalhos �
//읕컴컴컴컴컴컴컴컴컴컴컴컴켸
titulo  := "Estatisticas de atendimento de Pedidos"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Envia controle para a funcao SETPRINT �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
wnrel := "BIA500"            //Nome Default do relatorio em Disco

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,.F.)
//SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Pergunte("BIA500",.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴커
//� Definicao dos cabecalhos �
//읕컴컴컴컴컴컴컴컴컴컴컴컴켸
titulo  := titulo  + " Periodo de "+DtoC(MV_PAR01)+ " a "+DtoC(MV_PAR02)

RptStatus({|| BIA500IMP()})// Substituido pelo assistente de conversao do AP5 IDE em 21/07/03 ==> RptStatus({|| Execute(BIA500IMP)})

Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    쿍IA500IMP � Autor � Ary Medeiros          � Data � 15.02.96 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o 쿔mpressao do corpo do relatorio                             낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
// Substituido pelo assistente de conversao do AP5 IDE em 21/07/03 ==> Function BIA500IMP
Static Function BIA500IMP()
DbSelectArea("SC5")
DbSetOrder(1)

DbSelectArea("SF2")
DbSetOrder(1)

aCampos := {}
AADD(aCampos,{"C6_NUM"    , "Numero Pedido"  ,"@!"})
AADD(aCampos,{"C6_NOTA"   , "Nota Fiscal"    ,"@!"})
AADD(aCampos,{"C6_SERIE"  , "Serie NF"       ,"@!"})
AADD(aCampos,{"C6_CLI"    , "Cliente"        ,"@!"})
AADD(aCampos,{"C6_LOJA"   , "Loja"           ,"@!"})
AADD(aCampos,{"C6_ENTREG" , "Emissao"        ,"@D"})

AADD(aCampos,{"D2_DOC"    , "Nota Fiscal D2" ,"@!"})
AADD(aCampos,{"D2_SERIE"  , "Serie D2"       ,"@!"})
AADD(aCampos,{"D2_CLIENTE", "Cliente D2"     ,"@!"})
AADD(aCampos,{"D2_LOJA"   , "Loja D2"        ,"@!"})
AADD(aCampos,{"D2_EMISSAO", "Emissao D2"     ,"@D"})

cQuery := "SELECT "
cQuery := cQuery + "  A.C5_NUM, B.F2_DOC, B.F2_SERIE, A.C5_CLIENTE, A.C5_LOJACLI, A.C5_EMISSAO, "
cQuery := cQuery + "  B.F2_DOC, B.F2_SERIE, B.F2_CLIENTE, B.F2_LOJA, B.F2_EMISSAO  "
cQuery := cQuery + "  FROM " + retsqlname("SC5") + " A, " + retsqlname("SF2") + " B "
cQuery := cQuery + "  WHERE "
cQuery := cQuery + "  A.C5_FILIAL  >= '" + MV_PAR05 + "' AND "
cQuery := cQuery + "  A.C5_FILIAL  <= '" + MV_PAR06 + "' AND "
cQuery := cQuery + "  B.F2_SERIE   >= '" + MV_PAR03 + "' AND "
cQuery := cQuery + "  B.F2_SERIE   <= '" + MV_PAR04 + "' AND "
cQuery := cQuery + "  B.F2_EMISSAO >= '" + DTOS(MV_PAR01) + "' AND "
cQuery := cQuery + "  B.F2_EMISSAO <= '" + DTOS(MV_PAR02) + "' AND "
cQuery := cQuery + "  B.F2_FILIAL  = A.C5_FILIAL         AND "
cQuery := cQuery + "  B.F2_YPEDIDO = A.C5_NUM            AND "
cQuery := cQuery + "  B.F2_CLIENTE = A.C5_CLIENTE        AND "
cQuery := cQuery + "  B.F2_LOJA    = A.C5_LOJACLI        AND "
cQuery := cQuery + "  A.D_E_L_E_T_ <> '*' AND "
cQuery := cQuery + "  B.D_E_L_E_T_ <> '*' "
//   cQuery := cQuery + "  ORDER BY A.C6_NUM "

TCQUERY cQuery ALIAS "TRB" NEW

cArq := CriaTrab(NIL,.F.)
Copy To &cArq

dbSelectArea("TRB")
dbCloseArea()

dbUseArea(.T.,,cArq,"TRB",.T.)

dbSelectArea("TRB")
SetRegua(RecCount())

wMedia   := 0
wDiasPed := 0
wNoNf    := 0

While !Eof()
	
	IncRegua()
	
	IF  Interrupcao(@lAbortPrint)
		Exit
	EndIf
	
	If  li >= 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	End
	
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+TRB->F2_DOC+TRB->F2_SERIE+TRB->F2_CLIENTE+TRB->F2_LOJA,.T.)
	
	IF SD2->D2_COD >= 'A'
		wD2Emissao := CtoD(Subs(TRB->F2_EMISSAO,7,2)+"/"+Subs(TRB->F2_EMISSAO,5,2)+"/"+Subs(TRB->F2_EMISSAO,3,2))
		wC6Entreg  := CtoD(Subs(TRB->C5_EMISSAO,7,2)+"/"+Subs(TRB->C5_EMISSAO,5,2)+"/"+Subs(TRB->C5_EMISSAO,3,2))
		wDiasPed   := wDiasPed + (wD2Emissao - wC6Entreg)
		wNoNf      := wNoNf + 1
	ENDIF
	 
    DbSelectArea("TRB")
	DbSkip()
End
wMedia  := wDiasPed / wNoNf                                              
@ li,000 SAY "Numero de Notas Fiscais"+str(wNoNf,10,2)
li := li + 1
@ li,000 SAY "Media de dias para atendimento de pedidos"+str(wMedia,10,2)


Roda(0,"","P")
Set Filter To

If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()

dbSelectArea("SC5")
Set Filter to
RetIndex("SC5")

dbSelectArea("SF2")
Set Filter to
RetIndex("SF2")

DbSelectArea("TRB")
DbCloseArea()
If file(cArq+".DBF")
	ferase(cArq+".DBF")
Endif

Return
