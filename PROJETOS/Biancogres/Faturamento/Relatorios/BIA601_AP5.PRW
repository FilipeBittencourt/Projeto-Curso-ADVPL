#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#include "topconn.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function Bia601()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CSTRING,CDESC1,CDESC2,CDESC3,TAMANHO,ARETURN")
SetPrvt("NOMEPROG,ALINHA,NLASTKEY,TITULO,CABEC1,CABEC2")
SetPrvt("CCANCEL,M_PAG,WNREL,LRODAPE,LCONTINUA,NQTDM2")
SetPrvt("NQTDCX,NQTDTOTM2,NQTDTOTCX,CBTXT,CBCONT,LI")
SetPrvt("LIMITE,NTIPO,WFILIAL,CB_COND0,CB_COND1,CB_COND2")
SetPrvt("CB_COND3,CB_COND4,CSF2IND,CCHAVE,CFILTRO,LEND")
SetPrvt("LEXISTE,WCLIENTE,NTOTREGS,CWHERE,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA601   � Autor � Cesar Magnago         � Data � 12/12/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio das Notas Fiscais Expedidas no Periodo           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Faturamento                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                     �
//����������������������������������������������������������������������������
cString  := "SZ1"
cDesc1   := "Este programa ira emitir a Tabela de Preco dos Prod. Acabados"
cDesc2   := ""
cDesc3   := ""
tamanho  := "P"
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "BIA601"
aLinha   := { }
nLastKey := 0
titulo   := "Tabela de Preco dos Prod. Acabados"
cabec1   := "Referencia                        Est  Classe             Preco"
cabec2   := ""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 1                                    // numero da pagina
wnrel    := "BIA601"                             // relatorio em disco
lRodape  := .F.
lContinua:= .T.

//��������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape                �
//����������������������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
limite   := 132
nTotResg := 0
m_pag    := 1
nTipo    := IIF(aReturn[4]==1,15,18)

//��������������������������������������������������������������������������Ŀ
//� Exibe janela padrao de relatorios                                        �
//����������������������������������������������������������������������������
WnRel := SetPrint(cString,wnrel,"BIA601",titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)
If  nLastKey == 27
	Set Filter To
	Return
End
//�������������������������������������������������������������Ŀ
//� Aceita par�metros e faz ajustes necess�rios 					 �
//���������������������������������������������������������������
SetDefault(aReturn,cString)
if lastkey()==27
	Return
endif

//��������������������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                                       �
//����������������������������������������������������������������������������
pergunte("BIA601",.F.)
//��������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                     �
//� mv_par01              Da Referencia                                      �
//� mv_par02              Ate Referencia                                     �
//����������������������������������������������������������������������������

//��������������������������������������������������������������������������Ŀ
//� Executa Filtro no arquivo SZ1                                            �
//����������������������������������������������������������������������������
Processa({|| _TempSZ1() })

//��������������������������������������������������������������������������Ŀ
//� Imprime Arquivo                                                          �
//����������������������������������������������������������������������������
If nTotRegs > 0
	Processa({|| ImpDados() })
EndIf
//��������������������������������������������������������������������������Ŀ
//� Restaura a Integridade dos dados                                         �
//����������������������������������������������������������������������������
dbCloseArea("QRY")

//������������������������������������������������������������������������Ŀ
//� Se impress�o em Disco, chama SPOOL 												�
//��������������������������������������������������������������������������
IF aReturn[5] == 1		// disco
	Set Printer TO
	Commit					//grava em disco
	ourspool(wnrel)
ENDIF

//������������������������������������������������������������������������Ŀ
//� Libera relat�rio para Spool da Rede												�
//��������������������������������������������������������������������������
FT_PFLUSH()

//��������������������������������������������������������������������������Ŀ
//� Fim do Programa                                                          �
//����������������������������������������������������������������������������
SET DEVICE TO SCREEN
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� _TempSF2   � Cria indice temporario SZ1                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function _TempSZ1()
cWhere  := ""
cQuery  := ""
cQuery  += "SELECT COUNT(SZ1.Z1_REFER) AS TOTREGS "
cWhere  += "FROM "+RetSqlName("SZ1")+" SZ1 "
cWhere  += "WHERE "
cWhere  += "SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"' AND "
cWhere  += "SZ1.Z1_REFER BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cWhere  += "SZ1.D_E_L_E_T_ = '' "
cQuery  += cWhere
TcQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

if nTotRegs > 0
	cQuery  := ""
	cQuery  += "SELECT "
	cQuery  += "Z1_REFER, "
	cQuery  += "Z1_EST, "
	cQuery  += "Z1_CLASSE, "
	cQuery  += "Z1_VALOR "
	cQuery  += cWhere
	TcQuery cQuery Alias "QRY" New
endif

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
��� ImpDados   � Imprime o relatorio                                      ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ImpDados()

DbSelectArea("QRY")
DbGoTop()
ProcRegua(nTotRegs)
wsRefer := QRY->Z1_REFER

While !Eof()
	
	IncProc("Processando Tabela de Precos")
	
	if li > 65
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	endif
   
   If wsRefer <> QRY->Z1_REFER
      li := li + 1
      wsRefer := QRY->Z1_REFER
   EndIf
   
	@li,000 	PSAY QRY->Z1_REFER                        
	@li,035 	PSAY QRY->Z1_EST                                             
	@li,041	PSAY QRY->Z1_CLASSE
	@li,046 	PSAY QRY->Z1_VALOR  Picture "@E 99,999,999,999.99"
	li := li + 1
	
	dbSelectArea("QRY")
	dbSkip()
EndDo

return