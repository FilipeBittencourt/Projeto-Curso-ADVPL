#include "rwmake.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A460TUNI  �Autor  �Ranisses A. Corona  � Data � 17/03/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Corrige o valor unitario dos produtos em Terceiros         ���
���          � (5=EM TERCEIROS), de acordo com a tabela ZZA               ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function A460TUNI()

Local cSql		:= ""
Local cAlias	:= Paramixb[4]
Local dDtFech	:= ''
Local nFormat	:= ''
Local nFator 	:= ''

If dtos(Paramixb[3]) < "20121231" // Este filtro foi implementado em 22/01/13 por Marcos Alberto Soprani, porque a partir de 31/12/12 voltamos a usar o conceito padr�o do sistema. Inclu�do em 17/03/16
	
	If cempant == "01" .OR. cempant == "05"
		dDtFech	:= Dtos(Paramixb[3])
		nFormat	:= Posicione("SB1",1,xFilial("SB1")+PRODUTO,"B1_YFORMAT")
		nFator 	:= Posicione("SB1",1,xFilial("SB1")+PRODUTO,"B1_CONV")
		
		//����������������������������������������������������������������������������Ŀ
		//� SITUACAO: 1=ESTOQUE,2=PROCESSO,3=SEM SALDO,4=DE TERCEIROS,5=EM TERCEIROS,  �
		//�           6=DE TERCEIROS USADO EM ORDENS DE PRODUCAO                       �
		//������������������������������������������������������������������������������
		
		If (cAlias)->TIPO == "PA" //Somente para Produto Acabado
			
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				
				SELECT ZZA_FORMAT, ZZA_CONV, ZZA_TIPO, ZZA_QUANT, ZZA_CUSTO, (ZZA_CUSTO/ZZA_QUANT) ZZA_UNIT
				FROM %Table:ZZA% ZZA
				WHERE ZZA_FORMAT = %Exp:nFormat% AND ZZA_CONV = %Exp:nFator% AND ZZA_DATA = %Exp:dDtFech% AND ZZA_TIPO = 'IN' AND ZZA_QUANT > 0 AND %NOTDEL%
				
			EndSql
			
			Replace (cAlias)->VALOR_UNIT	With ROUND((cAliasTmp)->ZZA_UNIT,4)
			Replace (cAlias)->TOTAL				With ROUND((cAlias)->QUANTIDADE*(cAliasTmp)->ZZA_UNIT,2)
			
			(cAliasTmp)->(dbCloseArea())
			
		EndIf
	EndIf
	
EndIf

Return
