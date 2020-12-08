#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 10/09/03

User Function BIA333F()        // incluido pelo assistente de conversao do AP5 IDE em 10/09/03

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_LFLAG,_NCOLUNA,_CCAMPO,")

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o     � BIA333F  � Autor � MICROSIGA Vit�ria     � Data � 18/07/00 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o  � Validacao do campo da rotina de cadastro de catalogos      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Inicializar variaveis                                                    �
//����������������������������������������������������������������������������
_lFLAG   := .T.
_nCOLUNA := ASCAN(AHEADER,{|x| x[2]==SX3->X3_CAMPO})
_cCAMPO  := "M->"+ALLTRIM(SX3->X3_CAMPO)
//��������������������������������������������������������������������������Ŀ
//� Verificar titulo                                                         �
//����������������������������������������������������������������������������
IF _cCAMPO == "M->UZ6_COD"
   IF EMPTY(&(_cCAMPO)) .AND. ! ACOLS[N,LEN(AHEADER)+1]
      MSGBOX("Produto nao pode ser vazio","Produto","STOP")
      _lFLAG :=.F.
   ENDIF
ENDIF

//��������������������������������������������������������������������������Ŀ
//� Verificar Tipo                                                           �
//����������������������������������������������������������������������������
IF _cCAMPO == "M->UZ6_QTDPRO"
   IF &(_cCAMPO) == 0 .AND. ! ACOLS[N,LEN(AHEADER)+1]
      MSGBOX("Informe a quantidade liberada","Quantidade","STOP")
      _lFLAG :=.F.
   ENDIF
ENDIF
//��������������������������������������������������������������������������Ŀ
//� Retorno da rotina                                                        �
//����������������������������������������������������������������������������
// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> __RETURN(_lFLAG)
Return(_lFLAG)        // incluido pelo assistente de conversao do AP5 IDE em 10/09/03