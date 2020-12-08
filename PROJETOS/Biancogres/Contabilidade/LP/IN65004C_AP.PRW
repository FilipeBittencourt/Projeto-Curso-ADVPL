#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function IN65004C()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("WALIAS,CPROD,CCLVL,CCONTA,CARQSB1,CINDSB1")
SetPrvt("CREGSB1,CARQCTH,CINDCTH,CREGCTH,")

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IN65004C � Autor � MICROSIGA - VITORIA   � Data � 28/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lancto 650 - NF ENTRADA - ESTOQUE / RESULTADO PRODUTO      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
wAlias   := Alias()

cProd    := SD1->D1_COD
cCLVL    := SD1->D1_CLVL
cConta   :=  ""

dbSelectArea("SB1")
cArqSB1 := Alias()
cIndSB1 := IndexOrd()
cRegSB1 := Recno()
dbSetOrder(1)
dbSeek(xFilial("SB1")+cProd,.F.)

If Subs(cProd,1,3) == "GEN"
   dbSelectArea("CTH")
   cArqCTH := Alias()
   cIndCTH := IndexOrd()
   cRegCTH := Recno()
   dbSeek(xFilial("CTH")+cCLVL,.F.)
   If SUBSTR(CTH->CTH_CLVL,1,1) == "1"
      cConta := SB1->B1_YCTARES
   Else
      If SUBSTR(CTH->CTH_CLVL,1,1) == "3"
          cConta := SB1->B1_YCTRESP
      Else
          cConta := SB1->B1_YCTRESC
      EndIf
   EndIf
   cConta := ALLTRIM(cConta) + ALLTRIM(cCLVL)
Else
   If Empty(SB1->B1_YCNTEST)
      cConta := "113030010"
   Else
      cConta := SB1->B1_YCNTEST
   EndIf
EndIf

dbSelectArea(wAlias)
Return(cConta)