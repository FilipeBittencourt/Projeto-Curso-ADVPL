/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un噮o    矨ltera_Pedido� Autor � Tulio /Adam           � Data �03/12/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri噭o � Alteracao codigo produto sem efetuar as validacoes do MATA410潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      砈IGAFAT                                                       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Define variaveis PRIVATE...                                              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	PRIVATE aRotina  := {  { "Pesquisar" ,'AxPesqui'    , 0 , 1  } ,; 
	{ "Alterar"   ,'U_ALTPdMv'   , 0 , 2   } }
	PRIVATE cCadastro := OemToAnsi("Pedido de Venda")
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Chama a funcao de browse dos dados...                                    �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	SC5->(DbSeek(xFilial("SC5")))
	SC5->(mBrowse(06,01,22,75,"SC5"))
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Fim da Rotina Principal...                                               �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return


User Function ALTPdMv(cAlias,nReg,nOpc)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Define variaveis LOCAL...                                                �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	LOCAL nOpcA     := 0
	Local nFor

	MSGALERT("Esta rotina se destina a realizar alteracao no codigo do produto, para informacao de nova tonalidade. Demais alteracoes deverao ser realizadas atraves da rotina padrao.")

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Define variaveis PRIVATE...                                              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta aCols's e aHeader's da composicao de cobranca...                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	RegToMemory("SC5",.F.)

	Store Header "SC6" TO aHeader For AllTrim(SX3->X3_CAMPO) $ "C6_ITEM,C6_PRODUTO,C6_UM,C6_QTDVEN,C6_PRCVEN,C6_VALOR,C6_QTDLIB,C6_TES,C6_CF,C6_LOCAL,C6_NUM"

	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))

	Store COLS "SC6" TO aCols FROM aHeader VETTRAB aVetTrab While SC5->(C5_FILIAL+C5_NUM) == xFilial("SC6")+SC6->C6_NUM
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Inicia a construcao do Dialogo com usuario...                            �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	DEFINE MSDIALOG oDlg TITLE "Pedido Compra" FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta Enchoice...                                                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	oEnchoice := MSMGET():New(cAlias,nReg,2,,,,,{015,001,140,355},,,,,,oDlg,,,.F.)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta GetDados ...                                                       �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Altera := .T.
	Inclui := .F.
	oGet      := MsGetDados():New(142,001,197,355,4,"AllwaysTrue","AllwaysTrue",,.T.,,,,,,,,,oDlg)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Ativa o Dialogo...                                                       �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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