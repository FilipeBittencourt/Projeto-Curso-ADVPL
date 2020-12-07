#INCLUDE "RWMAKE.CH"

USER FUNCTION TAM_CO()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜ROGRAMA  � TAM_CO         篈UTOR  � BRUNO MADALENO     � DATA �  29/10/08   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋ESC.     � VALIDACAO PARA EXECUTAR A VALIDACAO NO NUMERO DA NOTA            罕�
北�          �	PARA NAO PERMITIR NUMERO DA NOTA MENOR QUE 6 DIGITOS            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣SO       � AP 8                                                             罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Local LLRET := .T.

//Tratamento para Totvs Colaboracao 2.0
If GetMv("MV_COMCOL1") <> 2 .And. Upper(Alltrim(FUNNAME())) == "SCHEDCOMCOL"  
	Return(LLRET)	
EndIf

If Dtos(Date()) >= "20121015" 
	CNFISCAL := strzero(val(CNFISCAL),9,0)
EndIf

IF LEN(ALLTRIM(CNFISCAL)) <> 9 .and. !Empty(cNFiscal)
	msgBox("N贛ERO DA NOTA FISCAL INV罫IDO. O N鷐ero da NF deve conter 9 caracteres.","Documento Entrada","ALERT")
	LLRET := .F.
ENDIF	

/*If cEmpAnt == "02" .And. Dtos(Date()) >= "20120901" 
	CNFISCAL := strzero(val(CNFISCAL),9,0)
Else
	IF LEN(ALLTRIM(CNFISCAL)) <> 6 .and. !Empty(cNFiscal)
		msgBox("N贛ERO DA NOTA FISCAL INV罫IDO. O N鷐ero da NF deve conter 6 caracteres.","Documento Entrada","ALERT")
		LLRET := .F.
	ENDIF	
EndIf*/

RETURN(LLRET)