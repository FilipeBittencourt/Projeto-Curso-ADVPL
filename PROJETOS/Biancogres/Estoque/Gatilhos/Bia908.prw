#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	   � BIA908	    � Autor � Ranisses A. Corona    | Data � 16/06/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Define o valor do campo Empresa Destino (ZJ_EMPDEST)         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		   � SigaEst														                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/
User Function BIA908()
Local cEmpresa	:= cEmpAnt
Local cCod			:= aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_COD'})]
Local cLocal		:= aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_LOCAL'})]

cEmpresa := cEmpAnt//U_EstoqueEmpresa(cCod,cLocal)

If Empty(Alltrim(cEmpresa))
			aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_QUANT'})]		:= 0
			aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_VLRTOT'})]	:= 0
			Msgbox("O produto n鉶 possui saldo no almoxarido "+cLocal+". Favor verificar!","Aviso","INFO")			
EndIf

Return(cEmpresa)