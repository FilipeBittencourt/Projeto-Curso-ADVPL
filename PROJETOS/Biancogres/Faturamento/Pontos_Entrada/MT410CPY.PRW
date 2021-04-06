#include "TOTVS.CH"

/*/{Protheus.doc} MT410CPY
@description Ponto de Entrada do Pedido de Venda - Botao Copiar
@author Ranisses A. Corona
@since 02/07/2009
@version 1.0
@type function
@obs revisao em 19/10/2016 por Fernando Rocha
/*/
User Function MT410CPY()
Local i, j
Local aSC6Clear  //Campos do SC6 para limpar para pedidos de venda

Public _FROPCHVTEMPRES

aSC6Clear := {"C6_ENTREG","C6_YMOTIVO","C6_YDPAL","C6_YDCAT","C6_YDREG","C6_YDMIX","C6_YDNV","C6_YDESP","C6_YENTREG","C6_YVALOR","C6_YEORICH","C6_YPITCHA","C6_YRAVLOT","C6_YLOTBAS",;
"C6_YOSBAS","C6_YTPEST","C6_YMOTFRA","C6_YBLQLOT","C6_YQTDSUG","C6_YLOTSUG","C6_YLOTTOT","C6_YOBS","C6_YDTRESI","C6_YDESCLI","C6_LOTECTL","C6_YDESC","C6_YPERC"}

//variaveis para Copia
_FROPCHVTEMPRES := AllTrim(__CUSERID)+DTOS(dDataBase)+StrZero(Randomize(1,999999),6)  //Nova chave de reserva

//variaveis de valores para uso em gatilhos especificos para copia
public _FPCPYC5T1 := M->C5_TRANSP
public _FPCPYC5T2 := M->C5_TPFRETE


//Campo para salvar a chave temporaria usada para criar reservas - Fernando em 08/05/15 - para posterior uso para efetivar reservas com problema
If SC5->(FieldPos("C5_YCHVRES")) > 0
	If Type("M->C5_YCHVRES") <> "U"
		M->C5_YCHVRES := _FROPCHVTEMPRES
	EndIf
EndIf

//Limpar campos do cabecalho que nao podem ser copiados
M->C5_CONDPAG	:= CriaVar("C5_CONDPAG",.T.)
M->C5_YCONF 	:= "N"
M->C5_YNPRENG	:= CriaVar("C5_YNPRENG",.T.)
M->C5_YDIGP		:= CriaVar("C5_YDIGP",.T.)	
M->C5_YAPROV	:= CriaVar("C5_YAPROV",.T.)
M->C5_YAAPROV	:= CriaVar("C5_YAAPROV",.T.)
M->C5_YALTP		:= CriaVar("C5_YALTP",.T.)

For i := 1 to Len(aCols)
	Acols[i,aScan(aHeader,{|x| Alltrim(x[2])=="C6_YDTNECE" .Or. Alltrim(x[2])=="C6_YDTNERE"})] := U_FROPAD3U(dDataBase)
	
	//tipos de pedido que fazem reserva de estoque
	If M->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14"))) .And. M->C5_YLINHA <> "4"
	
		For j := 1 To Len(aSC6Clear)
		
			Acols[i,aScan(aHeader,{|x| Alltrim(x[2])==aSC6Clear[j]})] := CriaVar(aSC6Clear[j],.T.)
		
		Next j
		
	EndIf
Next i

Return()