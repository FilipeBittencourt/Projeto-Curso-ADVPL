#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F440ABAS  �Autor  �Ranisses A. Corona  � Data �  05/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �Corrige base e oomiss�o para os titulos baixados como       ���
���          �como fatura.                                                ���
�������������������������������������������������������������������������͹��
���Uso       � Financeiro                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F440ABAS()
Local aBaseTmp := Paramixb
Local NX	   := 0

//If Alltrim(SE5->E5_MOTBX) == "FAT" .And. !CalcComis(SE5->E5_MOTBX) .And. !(SE1->E1_FATURA) $ "NOTFAT   #         "
//If !CalcComis(SE5->E5_MOTBX) .Or. ( Alltrim(SE5->E5_NATUREZ) == "1230" .And. Alltrim(SE5->E5_PARCELA) $ "1/A" )
If  Alltrim(SE5->E5_NATUREZ) == "1230" .And. Alltrim(SE5->E5_PARCELA) $ "1/A" 
	For NX := 1 To Len (aBaseTmp)	
		//aBaseTmp[1]  // vendedor
		aBaseTmp[NX][2] := 0
		aBaseTmp[NX][3] := 0
		aBaseTmp[NX][4] := 0
		aBaseTmp[NX][5] := 0
		aBaseTmp[NX][6] := 0		
		aBaseTmp[NX][7] := 0
	Next
EndIf

Return(aBaseTmp)

//Fun��o para Verificar se o Motivo da Baixa gera ou n�o comiss�o
Static Function CalcComis( cMotBx )
Local nPos,lRet := .F.
Local aMotBx := ReadMotBx()
 nPos := Ascan(aMotBx, {|x| Substr(x,1,3) == Upper(cMotBx) })
If nPos > 0
	lRet := Iif(Substr(aMotBx[nPos],26,1) == "S",.T.,.F.)
Endif
Return lRet