#include "protheus.ch" 
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia037()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CCADASTRO,AHEADER_XX,ACOLS_XX,AROTINA,AHEADER,ACOLS")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � BIA037   � Autor � SIGA Vitoria          � Data � 20/07/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao de romaneio                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFAT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Chama funcao markbrowse                                                  �
//����������������������������������������������������������������������������     

//EMRPESAS DESABILITADAS
IF AllTrim(cEmpAnt) $ "01/05"
	MsgAlert("ROTINA DESABILITADA PARA EMPRESA "+cEmpAnt+CRLF+"UTILIZAR CONTROLE DE CARGAS","ROMANEIO")
	Return
ENDIF

cCadastro := "Atualizacao de Romaneio"
aHeader_XX:= ACLONE(aHeader)
aCols_XX  := ACLONE(aCols)
aHeader_XX:= aHeader
aCols_XX  := aCols
aRotina := {{ "Pesquisar","AxPesqui"                       , 0, 1},;
            { "Incluir"  ,'ExecBlock("BIA038",.F.,.F.,"I")', 0, 2},;
            { "Alterar"  ,'ExecBlock("BIA038",.F.,.F.,"A")', 0, 2},;
            { "Imprimir" ,'ExecBlock("BIA041",.F.,.F.,"P")', 0, 2},;
            { "Impr.s/M2" ,'ExecBlock("BIA041A",.F.,.F.,"S")', 0, 2},;
            { "Excluir"  ,'ExecBlock("BIA038",.F.,.F.,"E")', 0, 2}}
            
mBrowse(6,1,22,75,"SC9",,'C9_BLCRED<>"  ".Or.SC9->C9_BLEST<>"  ".Or.SC9->C9_AGREG<>"    ".Or.SC9->C9_NFISCAL<>"     "')
//��������������������������������������������������������������������������Ŀ
//� Fim do programa                                                          �
//����������������������������������������������������������������������������
aHeader := aHeader_XX
aCols   := aCols_XX
Return