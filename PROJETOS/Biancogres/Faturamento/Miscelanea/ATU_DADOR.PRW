#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���FUN��O    � ATU_DADOR        � AUTOR � BRUNO MADALENO        � DATA � 23/12/08  	���
�����������������������������������������������������������������������������������Ĵ��
���DESCRI��O � ESTA FUNCAO ATUALIZA OS DADOR DO ACOLS DA ROTINA DE ORCAMENTO DOS    ���
���          � REPRESENTANTES                                              					���
�����������������������������������������������������������������������������������Ĵ��
���USO       � AP8 - R4                                                    					���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
/*/
USER FUNCTION ATU_DADOR()
PRIVATE NDESCONTO := 0
PRIVATE wLinha		:= ""

If Funname() = "MATA415"	//Orcamento
	wLinha	:= Alltrim(M->CJ_YLINHA)
Else											//Pedido de Venda
	wLinha	:= Alltrim(M->C5_YLINHA)
EndIf

If wLinha == "1"				//BIANCOGRES
	CCTABELA := Tabela("ZF","1E")
ElseIf wLinha == "2"		//INCESA
	CCTABELA := Tabela("ZF","2E")
ElseIf wLinha == "3"		//BELLACASA
	CCTABELA := Tabela("ZF","3E")
ElseIf wLinha == "4"		//MUNDI
	CCTABELA := Tabela("ZF","4E")
EndIf

CCCEMP		:= IIF(CEMPANT="01","02","")
NDESCONTO	:= U_CALCULA_DESCONTO(TMP1->CK_PRODUTO, CCTABELA, M->CJ_CLIENTE, M->CJ_LOJA, TMP1->CK_PRCVEN, M->CJ_CONDPAG, CCCEMP, M->CJ_YVLRFRE ) 

If M->CJ_YDSCTOT == 0
	M->CJ_YDESC1  := nPolit
	M->CJ_YDSCTOT := nPolit
EndIf

RETURN(NDESCONTO)