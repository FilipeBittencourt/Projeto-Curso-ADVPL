#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function FI52001D()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,NVALOR,NCONTA,CPREF,CNUM,CPARC")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � 52101D   � Autor � Cesar Magnago         � Data � 23/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para permitir a contabilizacao do valor exato    ���
���          � dos Cheques que substituem os Titulos a Receber.           ���
���          � Lancamento Padronizado 52101 ( Conta a Debito  )           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico: INCESA                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
cAlias  := Alias()
nValor  := 0

If SE5->E5_PREFIXO <> "CHQ" 

   nConta := SA6->A6_CONTA
   DbSelectArea(cAlias)
Return(nConta)
// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==>    __Return(nValor)
//Return(nValor)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

EndIf

If AllTrim(SE5->E5_TIPO) == "CH"
   cPref   := SE5->E5_PREFIXO
   cNum    := SE5->E5_NUMERO
   cParc   := SE5->E5_PARCELA

   DbSelectArea("SE1")
   DbSetOrder(1)

   If DbSeek(xFilial("SE1")+cPref+cNum+cParc,.F.)
      cPref   := SE1->E1_YPREFOR
      cNum    := SE1->E1_YNUMOR
      cParc   := SE1->E1_YPARCOR
   EndIf

   If DbSeek(xFilial("SE1")+cPref+cNum+cParc,.F.)
      fAchaConta()
   Else
      nConta := SA6->A6_CONTA
   Endif

   DbSelectArea(cAlias)
EndIf

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(nConta)
Return(nConta)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> Function fAchaConta
Static Function fAchaConta()

   nConta := SA6->A6_CONTA
   If SE1->E1_SITUACA == "0" .And. !Empty(SE1->E1_PORTADO)
      nConta := "111010001"
   EndIf

Return
