#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BIA777    � Autor � AP5 IDE            � Data �  30/04/03   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP5 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function BIA777()                         

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Reserva x Empenho"
Local Cabec1       := "Produto          Doc.     Reserva (SC0)   Empenho (SDC) "
Private ctrabalho
NLIN := 10
wnrel       :="BIA777"
Tamanho     := "G"
titulo      := "Reserva x Empenho"
cString     := "SC0"
aReturn     := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
aLinha      := { }
nLastKey    := 0
cPerg       :="BIA777"
aDriver     := ReadDriver()
lAbortPrint := .F.
nomeprog    := "BIA777"
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt := SPACE(10)
cbcont:= 0
li    := 1
m_pag := 1
Cabec2:= ""

//�������������������������������������������������������������������Ŀ
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//���������������������������������������������������������������������
nTipo  := IIF(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.f.,Tamanho)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
   Return
Endif
nTipo := If(aReturn[4]==1,15,18)
//���������������������������������������������������������������������Ŀ
//� Montar arquivo com diferencas										�
//�����������������������������������������������������������������������
Processa({|| fgera() })
//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �FGERA     � Autor � AP5 IDE            � Data �  30/04/03   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/              
Static function fgera                      
Local _aCampos, cquery
ProcRegua(5)
_aCampos := {   {"PRODUTO" , "C", 15, 0},;
		{"RESERVA"  , "C", 06, 0},;
		{"LOCALIZ"  , "C", 15, 0},;
		{"NSDC"  , "N", 12, 2},;
	    {"NSC0 " , "N", 12, 2}}
ctrabalho := CriaTrab(_aCampos)
DbUseArea(.T.,,ctrabalho,"ctrabalho")
DbCreateInd(ctrabalho,"PRODUTO+LOCALIZ+RESERVA",{||PRODUTO+LOCALIZ+RESERVA})

cQuery := "SELECT C0_PRODUTO,C0_NUM,C0_LOCALIZ,SUM(C0_QUANT) RESERVA"
cQuery += " FROM " + retsqlname("SC0")
cQuery += " WHERE "
cQuery += " D_E_L_E_T_ = ''"
cQuery += "  GROUP BY C0_PRODUTO,C0_NUM,C0_LOCALIZ"
cQuery += "  ORDER BY C0_PRODUTO,C0_NUM"
TCQUERY cQuery NEW ALIAS "TRBSC0" 
IncProc()

cQuery := "SELECT DC_PRODUTO,DC_PEDIDO,DC_LOCALIZ,SUM(DC_QUANT) EMPENHO"
cQuery += " FROM " + retsqlname("SDC")
cQuery += " WHERE "
cQuery += " D_E_L_E_T_ = ''"
cQuery += " AND DC_ORIGEM = 'SC0'"
cQuery += "  GROUP BY DC_PRODUTO,DC_PEDIDO,DC_LOCALIZ"
cQuery += "  ORDER BY DC_PRODUTO,DC_PEDIDO"
TCQUERY cQuery NEW ALIAS "TRBSDC" 
IncProc()

DbSelectArea("TRBSC0")
DbGotop()
Do while !Eof()
   DbSelectArea("ctrabalho")
   If Reclock("ctrabalho",.t.)
      ctrabalho->PRODUTO := TRBSC0->C0_PRODUTO
      ctrabalho->RESERVA := TRBSC0->C0_NUM
      ctrabalho->LOCALIZ := TRBSC0->C0_LOCALIZ
      ctrabalho->NSC0    := TRBSC0->RESERVA
      MsUnlock()
   EndIf
   DbSelectArea("TRBSC0")
   DbSkip()
EndDo
IncProc()

DbSelectArea("TRBSDC")
DbGotop()
Do while !Eof()
   DbSelectArea("ctrabalho")
   DbSetOrder(1)
   If DbSeek(TRBSDC->DC_PRODUTO+TRBSDC->DC_LOCALIZ+TRBSDC->DC_PEDIDO)
	   Reclock("ctrabalho",.f.)
   Else
       Reclock("ctrabalho",.t.)
       ctrabalho->PRODUTO := TRBSDC->DC_PRODUTO
       ctrabalho->RESERVA := TRBSDC->DC_PEDIDO
       ctrabalho->LOCALIZ := TRBSDC->DC_LOCALIZ
   EndIf
   ctrabalho->NSDC    := TRBSDC->EMPENHO
   MsUnlock()
   DbSelectArea("TRBSDC")
   DbSkip()
EndDo                  
DbCloseArea("TRBSC0")
DbCloseArea("TRBSDC")
IncProc()
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP5 IDE            � Data �  30/04/03   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

dbSelectArea("ctrabalho")
Set filter to NSC0 <> NSDC
dbSetOrder(1)
SetRegua(RecCount())
dbGoTop()
While !EOF()
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   While !Eof() .and. prow() <= 55
      IncRegua()
   	  If lAbortPrint
         @prow()+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
         Exit
      Endif       
      @ Prow()+1, 1 Psay ctrabalho->PRODUTO
      @ Prow(),Pcol()+2 Psay ctrabalho->RESERVA
      @ Prow(),Pcol()+2 Psay Transform(ctrabalho->NSC0,"@E 999,999,999.99")
      @ Prow(),Pcol()+2 Psay Transform(ctrabalho->NSDC,"@E 999,999,999.99")
      dbSkip() // Avanca o ponteiro do registro no arquivo
   EndDo   
EndDo
DbCloseArea()
//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
