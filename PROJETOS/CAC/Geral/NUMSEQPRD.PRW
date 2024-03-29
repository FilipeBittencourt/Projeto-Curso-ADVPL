#include "rwmake.ch"        
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NUMSEQPRD �Autor  �Fernando Rocha      � Data � 01/02/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilho para trazer automatico o numero do produto de      ���
���          � acordo com o grupo do produto.                             ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Produto                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function NUMSEQPRD() 
Local _cAliasTmp
Local _cGrupo

Private _cNumPrd	:= ""
Private _cRet		:= ""
Private aAreaSB1  := SB1->(Getarea()) 
   	  
   	_cGrupo := M->B1_GRUPO
   	
	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp
		%noparser%
		SELECT COD = CASE WHEN (SELECT COUNT(*) FROM %Table:SB1% WHERE SUBSTRING(B1_COD,1,4) = %EXP:_cGrupo% AND D_E_L_E_T_=' ') > 0
			  THEN (SELECT ISNULL(RIGHT('000000'+cast(convert(int, MAX(SUBSTRING(B1_COD,5,6)) )+1 as varchar(6)),6),'000001') FROM %Table:SB1% WHERE SUBSTRING(B1_COD,1,4) = %EXP:_cGrupo% AND D_E_L_E_T_=' ')
			  ELSE '000001'
			  END
	EndSql
	
	(_cAliasTmp)->(DbGoTop())
	_cNumPrd := (_cAliasTmp)->COD
	(_cAliasTmp)->(DbCloseArea())
	
	If Alltrim(_cNumPrd) = ""
		_cNumPrd := "000001"
	EndIf
	
	_cRet := M->B1_GRUPO+_cNumPrd

	//alterado por Rafael - 13/02/07
	//valida��o do c�digo a ser retornado para que n�o ocorre chave duplicada
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD                                                                                                                                                
	While SB1->(Dbseek(xFilial("SB1")+_cRet))
		_cNumPrd := Soma1(_cNumPrd,6)
		_cRet := M->B1_GRUPO+_cNumPrd		
	Enddo
	Restarea(aAreaSB1)

return(_cRet)

