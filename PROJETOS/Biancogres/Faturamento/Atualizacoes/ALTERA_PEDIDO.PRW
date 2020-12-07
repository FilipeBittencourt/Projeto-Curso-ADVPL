/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддддбддддддбддддддддд©╠╠
╠╠ЁFun┤┘o    ЁAltera_PedidoЁ Autor Ё Tulio /Adam           Ё Data Ё03/12/02 Ё╠╠
╠╠цддддддддддедддддддддддддадддддддадддддддддддддддддддддддаддддддаддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Alteracao codigo produto sem efetuar as validacoes do MATA410Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      ЁSIGAFAT                                                       Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

#command STORE HEADER <cA> TO <aH> [FOR <for>];
=> bForAux := { || (<for>) .And. (cNivel >= SX3->X3_NIVEL) .And. (X3Uso(SX3->X3_USADO)) };
;SX3->(dbSetOrder(1));SX3->(dbSeek(<cA>));<aH>:={};
;SX3->(DBEval({|| AaDd(<aH>,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,;
SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})},bForAux,{|| SX3->X3_ARQUIVO==Upper(<cA>)},,,.F.))

#command STORE COLS <cA> TO <aC>	FROM <aH>	[VETTRAB <aVet>]   		;
[FOR <for>]                                                    ;
[WHILE <while>]                                                ;
[NEXT <next>]                                                  ;
[RECORD <rec>]                                                 ;
[<rest:REST>]                                                  ;
[ALL]                                                          ;
=> cAO:=Alias();DbSelectArea(<cA>);<aC>:={}                       ;
;  DBEval({|| AaDd(<aC>,{}),aEval(<aH>,{|eH|                      ;
AaDd(<aC>\[len(<aC>)\],If(Empty(FieldPos(AllTrim(eH\[2\]))),CriaVar(AllTrim(eH\[2\])),FieldGet(FieldPos(AllTrim(eH\[2\])))))}),;
AaDd(<aC>\[len(<aC>)\],.f.), If(ValType(<aVet>)=="A",aadd(<aVet>,Recno()),nil) },;
<{for}>, <{while}>, <next>, <rec>, <.rest.>);
;	DbSelectArea(cAO)



#include "PROTHEUS.CH"

User Function AltPedido()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define variaveis PRIVATE...                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PRIVATE aRotina  := {  { "Pesquisar" ,'AxPesqui'    , 0 , 1  } ,; 
	{ "Alterar"   ,'U_ALTPdMv'   , 0 , 2   } }
	PRIVATE cCadastro := OemToAnsi("Pedido de Venda")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Chama a funcao de browse dos dados...                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SC5->(DbSeek(xFilial("SC5")))
	SC5->(mBrowse(06,01,22,75,"SC5"))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da Rotina Principal...                                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return


User Function ALTPdMv(cAlias,nReg,nOpc)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define variaveis LOCAL...                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	LOCAL nOpcA     := 0
	Local nFor

	MSGALERT("Esta rotina se destina a realizar alteracao no codigo do produto, para informacao de nova tonalidade. Demais alteracoes deverao ser realizadas atraves da rotina padrao.")

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define variaveis PRIVATE...                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PRIVATE oDlg
	PRIVATE aCols    := {}
	PRIVATE aHeader  := {}                                 
	PRIVATE aVetTrab := {}
	PRIVATE aChave   
	PRIVATE oEnchoice
	PRIVATE oGet                                                                                        
	PRIVATE aTela    := {}
	PRIVATE aGets    := {}
	PRIVATE nFor        
	PRIVATE aOldRot  := aRotina

	PRIVATE aRotina  := {  { "Pesquisar" ,'AxPesqui'    , 0 , 1  } ,; 
	{ "Alterar"   ,'U_ALTPdMv'   , 0 , 4   },;
	{ "Alterar"   ,'U_ALTPdMv'   , 0 , 4   },;
	{ "Alterar"   ,'U_ALTPdMv'   , 0 , 4   } }

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta aCols's e aHeader's da composicao de cobranca...                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RegToMemory("SC5",.F.)

	Store Header "SC6" TO aHeader For AllTrim(SX3->X3_CAMPO) $ "C6_ITEM,C6_PRODUTO,C6_UM,C6_QTDVEN,C6_PRCVEN,C6_VALOR,C6_QTDLIB,C6_TES,C6_CF,C6_LOCAL,C6_NUM"

	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))

	Store COLS "SC6" TO aCols FROM aHeader VETTRAB aVetTrab While SC5->(C5_FILIAL+C5_NUM) == xFilial("SC6")+SC6->C6_NUM
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicia a construcao do Dialogo com usuario...                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DEFINE MSDIALOG oDlg TITLE "Pedido Compra" FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta Enchoice...                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oEnchoice := MSMGET():New(cAlias,nReg,2,,,,,{015,001,140,355},,,,,,oDlg,,,.F.)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta GetDados ...                                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Altera := .T.
	Inclui := .F.
	oGet      := MsGetDados():New(142,001,197,355,4,"AllwaysTrue","AllwaysTrue",,.T.,,,,,,,,,oDlg)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ativa o Dialogo...                                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(aGets,aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,{})  })

	If nOpcA == 1            

		nPosPrd := Ascan(aHeader,{|x| x[2] == "C6_PRODUTO"})

		For nFor := 1 To Len(aVetTrab)

			SC6->(DbGoTo(aVetTrab[nFor]))
			SC6->(RecLock("SC6",.F.))
			SC6->C6_PRODUTO := aCols[nFor,nPosPrd]
			SC6->(MsUnLock())                     

			//Gravar nos relacionamentos, etc....

		Next

	Endif   

	aRotina := aOldRot

Return