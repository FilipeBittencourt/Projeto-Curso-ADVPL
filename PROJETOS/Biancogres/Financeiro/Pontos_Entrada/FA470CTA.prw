/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA470CTA  บAutor  ณIhorran Milholi     บ Data ณ  27/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada para concilia็ใo bancaria automatica       บฑฑ
ฑฑบ          ณImplementado para confrontar o codigo, agencia e conta do   บฑฑ
ฑฑบ          ณbanco lido no extrato com o cadastro no sistema			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFINA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FA470CTA()

//Recupera o parametro contenco o banco/agencia/conta corrente      
aRet := Paramixb

If AllTrim(aRet[2]) == '3511' .and. AllTrim(aRet[3]) == '0000000105996'
	aRet[2]	:= AllTrim(Paramixb[2])
	aRet[3] := '10.599-6'
ELSEIf AllTrim(aRet[2]) == '3431' .and. AllTrim(aRet[3]) == '000000550973'
	aRet[2]	:= AllTrim(Paramixb[2]) + "2"
	aRet[3] := '55.097-3'
ELSEIf AllTrim(aRet[2]) == '3431' .and. AllTrim(aRet[3]) == '00000055099X'
	aRet[2]	:= AllTrim(Paramixb[2]) + "2"
	aRet[3] := '55.099-X'
EndIf

Return(aRet)