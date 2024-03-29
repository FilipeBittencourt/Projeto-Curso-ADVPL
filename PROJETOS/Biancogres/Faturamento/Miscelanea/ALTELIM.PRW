#Include "RwMake.ch"
#Include "topconn.ch"
/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Funcao   � 	ALTELIM     � Autor �BRUNO MADALENO        � Data � 13/04/06   ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � ALTERA VENCIMENTO DO LIMITE DE CREDITO                          ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
User Function ALTELIM()
Private aCampos
Private aCampos1
Private aCampos2
Private aCampos3
Private cSql
Private lop,cnum,ocheck,cmarkbr

_aCampos :=	{{"CODIGO"  	,"C",06,0},;
			 {"NOME"		,"C",70,0},;
			 {"VENCLIM"		,"C",10,0}}

_trabalho := CriaTrab(_aCampos)
dbUseArea(.T.,,_trabalho,"_trabalho",.t.)
dbCreateInd(_trabalho,"CODIGO",{||CODIGO})

//
cSql := ""
cSql := "SELECT A1_COD AS CODIGO, A1_NOME AS NOME, A1_VENCLC AS VENCLIM  "
cSql += "FROM " + RETSQLNAME("SA1") + " "
cSql += "WHERE A1_VENCLC = '18000601' "
TCQUERY cSql ALIAS "c_CONS" NEW
c_CONS->(DbGoTop())

While !c_CONS->(EOF())
	RecLock("_trabalho",.t.)
	_trabalho->CODIGO		:= c_CONS->CODIGO
	_trabalho->NOME			:= c_CONS->NOME
	_trabalho->VENCLIM		:= substr(c_CONS->VENCLIM,7,2)+"/"+substr(c_CONS->VENCLIM,5,2)+"/"+substr(c_CONS->VENCLIM,1,4) //c_CONS->VENCLIM
	MsUnlock()
	c_CONS->(DbSkip())
EndDo
DbSelectArea("c_CONS")
DbCloseArea()

aCampos := {}
AADD(aCampos,{"CODIGO" 	,"CODIGO" ,2})
AADD(aCampos,{"NOME"	, "NOME DO CLIENTE" ,70})
AADD(aCampos,{"VENCLIM"	, "VENCIMENTO DO LIMITE DE CR�DITO" ,10})
Markbrow()
Return
/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Funcao   � 	MARKBROW    � Autor �BRUNO MADALENO        � Data � 21/10/05   ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � MONTA O OBROWSE PARA LISTAS OS TITULOS BLOQUEADOS               ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function Markbrow()
Private DtLimite := CTOD("")
Private DtAltera := CTOD("")
nMarcados := 0
lInverte  := .F.

@ 10,10		To 535,800 Dialog oDlg1 Title "Consulta Estoque"
@ 5,6		To 260,390
@ 15,10		SAY "ALTERAR A DATA DO LIMITE DE CR�DITO DE:                          PARA : "
@ 13,124 	GET DtLimite SIZE 35,20 PICTURE "@D"
@ 13,180 	GET DtAltera SIZE 35,20 PICTURE "@D"
@ 12,220	Button "Simular" Size 30,15 Action SQL_Simula()
@ 243,100	Button "Confirmar Altera��o da data do limite de cr�dito" Size 180,15 Action SQL_ALTERA()
@ 243,360	BmpButton Type 2 Action Close(oDlg1)

//��������������������������������������������������������������������������Ŀ
//� Monta MarkBrowse...                                                      �
//����������������������������������������������������������������������������
oBrowse := IW_Browse(032,010,240,385,"_trabalho",,,acampos)

ACTIVATE DIALOG oDlg1 ON INIT Eval({|| MsAguarde(), _trabalho->(DbGoTop()), oBrowse:oBrowse:Refresh(), }) Centered

DbSelectArea("_trabalho")
DbCloseArea()
Ferase(_trabalho+".DBF")
Ferase(_trabalho+".CDX")
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Funcao   � SQL_FILTROS  � Autor �BRUNO MADALENO        � Data � 21/10/05   ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � SELECIONANDO OS CLIENTES DE ACORDOCOM O FILTRO 				   ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function SQL_Simula()
cSQL := ""
cSql := "SELECT A1_COD AS CODIGO, A1_NOME AS NOME, A1_VENCLC AS VENCLIM  "
cSql += "FROM " + RETSQLNAME("SA1") + " "
cSql += "WHERE A1_VENCLC = '" + dtos(DtLimite) + "' "
AtualizaBrowse()
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Funcao   �AtualizaBrowse� Autor �BRUNO MADALENO        � Data � 21/10/05   ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � ATUALIZA O BOWSE CONFOR O FILTRO SELECIONADO                    ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static function AtualizaBrowse()
dbSelectArea("_trabalho")
dbCloseArea()

_aCampos :=	{{"CODIGO"  	,"C",06,0},;
{"NOME"		,"C",100,0},;
{"VENCLIM"		,"C",10,0}}

_trabalho := CriaTrab(_aCampos)
dbUseArea(.T.,,_trabalho,"_trabalho",.t.)
dbCreateInd(_trabalho,"CODIGO",{||CODIGO})

//Selecionando todos os produtos e suas quantidades em estoque
TCQUERY cSql ALIAS "c_CONS" NEW
c_CONS->(DbGoTop())

While !c_CONS->(EOF())
	RecLock("_trabalho",.t.)
	_trabalho->CODIGO		:= c_CONS->CODIGO
	_trabalho->NOME			:= c_CONS->NOME
	_trabalho->VENCLIM		:= substr(c_CONS->VENCLIM,7,2)+"/"+substr(c_CONS->VENCLIM,5,2)+"/"+substr(c_CONS->VENCLIM,1,4) //c_CONS->VENCLIM
	MsUnlock()
	c_CONS->(DbSkip())
EndDo
DbSelectArea("c_CONS")
DbCloseArea()

_trabalho->(DbGoTop())
oBrowse:oBrowse:Refresh()
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Funcao   � SQL_FILTROS  � Autor �BRUNO MADALENO        � Data � 21/10/05   ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � SELECIONANDO OS CLIENTES DE ACORDOCOM O FILTRO 				   ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function SQL_ALTERA()
IF empty(DTOS(DtLimite)) .OR. empty(DTOS(DtAltera)) 
	MSGBOX("FAVOR PREENCHER TODOS OS CAMPOS")
else
	wDeseja := MsgBox("CONFIRMA A ALTERA��O DA DATA DO LIMITE " + CHR(13) + CHR(10) +  "DE CR�DITO DE: " + DtLimite + " PARA: " + DtAltera + " ? ","Quanto ao Custeio","YESNO")
	
	If wDeseja
		
		cSQL := ""
		cSql := "UPDATE SA1010 SET A1_VENCLC = '"+ DTOS(DtAltera) +"', A1_MSEXP = '' WHERE A1_VENCLC = '"+ DTOS(DtLimite) +"' "
		TCSQLEXEC(cSql)
		
		cSQL := ""
		cSql := "UPDATE SA1050 SET A1_VENCLC = '"+ DTOS(DtAltera) +"', A1_MSEXP = '' WHERE A1_VENCLC = '"+ DTOS(DtLimite) +"' "
		TCSQLEXEC(cSql)
		Close(oDlg1)
		
	EndIF
end if
Return
