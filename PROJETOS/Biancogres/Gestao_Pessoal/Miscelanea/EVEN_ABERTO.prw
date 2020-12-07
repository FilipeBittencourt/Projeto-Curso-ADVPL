#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "JPEG.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "AP5MAIL.CH"
#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ EVEN_ABERTO    ºAUTOR  ³BRUNO MADALENO      º DATA ³  18/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ RELATORIOS PARA LISTAR QUANTO QUE OS FUNCIONARIOS AFASTADOS      º±±
±±º          ³ ESTAO DEVENDO A BIANCOGRES E INCESA                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ AP 8 - R4                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION EVEN_ABERTO()
PRIVATE ENTER := CHR(13)+CHR(10)
PRIVATE CSQL := ""
PRIVATE CSQL
PRIVATE ENTER := CHR(13)+CHR(10)

PRIVATE VAL_406   := 0
PRIVATE VAL_411   := 0
PRIVATE VAL_423   := 0
PRIVATE VAL_OUT   := 0
PRIVATE A_VAL_406 := 0
PRIVATE A_VAL_411 := 0
PRIVATE A_VAL_423 := 0
PRIVATE A_VAL_OUT := 0
PRIVATE Sld_411   := 0
PRIVATE Sld_406   := 0
PRIVATE Sld_423   := 0
PRIVATE Sld_Out   := 0
PRIVATE Difer     := 0
PRIVATE _SldAtu   := 0
PRIVATE _SldAnt   := 0

lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Informaçoes de emprestimos e compra de pisos"
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "EVEAB2"
cPerg      := "EVE_AB"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Informaçoes sobre eventos em aberto"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1
wnrel      := "EVEAB2"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.

pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
//Cancela a impressao
If nLastKey == 27
	Return
Endif

CSQL := "DELETE FROM EVEN_ABERTO"
TCSQLEXEC(CSQL)

CSQL := "SELECT RA_MAT, RA_NOME, RA_CC, SR8.* " + ENTER
CSQL += "FROM "+RETSQLNAME("SR8")+" SR8, "+RETSQLNAME("SRA")+" SRA " + ENTER
CSQL += "WHERE	R8_FILIAL = '01' AND  " + ENTER
CSQL += "		R8_MAT = RA_MAT AND  " + ENTER
CSQL += "		((R8_DATAFIM = '' AND SUBSTRING(R8_DATAINI,1,6) <= '"+SUBSTR(DTOS(MV_PAR01-1),1,6)+"')  " + ENTER 
CSQL += "		OR (R8_TIPO = 'F' AND SUBSTRING(R8_DATAINI,1,6) = '"+SUBSTR(DTOS(MV_PAR01-1),1,6)+"' AND R8_MAT NOT IN ('000133')) OR " + ENTER
CSQL += "		                    (R8_TIPO = 'F' AND SUBSTRING(R8_DATAFIM,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"'    AND R8_MAT NOT IN ('000133')) OR " + ENTER
CSQL += "		                    (R8_TIPO = 'O' AND SUBSTRING(R8_DATAFIM,1,6) = '"+SUBSTR(DTOS(MV_PAR01+1),1,6)+"'  AND R8_MAT NOT IN ('000133')) OR  " + ENTER
CSQL += "		                    (R8_TIPO = 'O' AND SUBSTRING(R8_DATAFIM,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"'  AND R8_MAT IN ('000562')) OR  " + ENTER 
//CSQL += "		                    (R8_TIPO = 'P' AND SUBSTRING(R8_DATAFIM,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' AND R8_DURACAO > 15 )) AND " + ENTER 
CSQL += "		                    (R8_TIPO = 'P' AND SUBSTRING(R8_DATAFIM,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' AND (R8_DURACAO > 15 OR R8_MAT = '001026') )) AND " + ENTER
CSQL += "		SR8.D_E_L_E_T_ = '' AND " + ENTER
CSQL += "		SRA.D_E_L_E_T_ = ''  " + ENTER
IF CHKFILE("_FUNCIONARIOS")
	DBSELECTAREA("_FUNCIONARIOS")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_FUNCIONARIOS" NEW

DO WHILE ! _FUNCIONARIOS->(EOF())
	
	IF _FUNCIONARIOS->RA_MAT == "001296" .AND. _FUNCIONARIOS->R8_DATAFIM == "20150412"
		DBSELECTAREA("_FUNCIONARIOS")
		DbSkip()
		Loop
		LOKK := .T.
	ENDIF
	
	IF ALLTRIM(_FUNCIONARIOS->RA_MAT) == "000445"
	   lWW := .T.
	ENDIF
	
	VAL_406   := 0
	VAL_411   := 0
	VAL_423   := 0
	
	A_VAL_406 := 0
	A_VAL_411 := 0
	A_VAL_423 := 0
	A_VAL_OUT := 0
	
	Sld_406   := 0
	Sld_411   := 0
	Sld_423   := 0
	Sld_Out   := 0
	
	_SldAnt   := 0
	_SldAtu   := 0
	_Difer    := 0
	
	MES_ := ANTE_MES(SUBSTR(DTOS(MV_PAR01),1,6))
	
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	// CALCULANDO DESCONTOS DOS EVENTOS EM ABERTO
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	CSQL := "SELECT *  " + ENTER
	CSQL += "FROM "+RETSQLNAME("SRD")+" SRD " + ENTER
	CSQL += "WHERE	SRD.RD_MAT = '"+_FUNCIONARIOS->RA_MAT+"' AND " + ENTER
	CSQL += "		SRD.RD_DATARQ = '"+MES_+"' AND " + ENTER
	CSQL += "		RD_PD IN ('416','124','198','498','489','799','411','423','531','532','533','534','535','536','537','538','543','544','545','546','547','548','549','550','551','552','553','554','555','556','557','558','559','560','561','562','563','564','565','566')  AND " + ENTER
	CSQL += "		D_E_L_E_T_ = ''   " + ENTER
	IF CHKFILE("_LANCAMENTOS")
		DBSELECTAREA("_LANCAMENTOS")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_LANCAMENTOS" NEW
	
	DO WHILE ! _LANCAMENTOS->(EOF())
		DO CASE
			CASE _LANCAMENTOS->RD_PD = '489'													//Saldo Anterior
				_SldAnt += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD == '124'													//Saldo Atual
				_SldAtu += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD == '411'													//Farmácia
				A_VAL_411 += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD == '423' 			       									//Utilização do Plano de saúde
				A_VAL_423 += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD $ '534/538' .AND. cEmpAnt == '05'							//Utilização do Plano de saúde + Arredondamento
				A_VAL_423 += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD $ '498/533/538' .AND. cEmpAnt == '01'				        //Utilização do Plano de saúde + Arredondamento
				A_VAL_423 += _LANCAMENTOS->RD_VALOR
			//CASE _LANCAMENTOS->RD_PD $ '531/532/533/535/536/537/543/544/545/546/547/548/549/550/551/552/553/554/555/556/557/558/559/560/561/562/563/564/565/566' .AND. cEmpAnt == '05'  //Assistencia Medica / Mensalidade do Plano de saúde
			CASE _LANCAMENTOS->RD_PD $ '532/533/535/536/537/543/544/545/546/547/548/549/550/551/552/553/554/555/556/557/558/559/560/561/562/563/564/565/566/568/569/570' .AND. cEmpAnt == '05'  //Assistencia Medica / Mensalidade do Plano de saúde			
				A_VAL_406 += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD $ '531/532/535/536/537/543/544/545/546/547/548/549/550/551/552/553/554/555/556/557/558/559/560/561/562/563/564/565/566/568/569/570/571/577' .AND. cEmpAnt == '01'		//Assistencia Medica / Mensalidade do Plano de saúde
				A_VAL_406 += _LANCAMENTOS->RD_VALOR
		ENDCASE
		_LANCAMENTOS->(DBSKIP())
	END DO
	
	_Difer    := _SldAtu - _SldAnt
	A_VAL_OUT := _Difer  - 	A_VAL_411 - A_VAL_423 - A_VAL_406
	
	IF _Difer > 0 .AND. A_VAL_406 > 0
		// VERBA 406
		IF A_VAL_406 > _Difer
			Sld_406 := _SldAnt + _Difer
		ELSE
			Sld_406 := _SldAnt + A_VAL_406
		ENDIF
		_Difer := _Difer - A_VAL_406
	ENDIF
	
	IF _Difer > 0 .AND. A_VAL_411 > 0
		// VERBA 411
		IF A_VAL_411 > _Difer
			Sld_411 := _SldAnt + _Difer
		ELSE
			Sld_411 := _SldAnt + A_VAL_411
		ENDIF
		_Difer := _Difer - A_VAL_411
	ENDIF
	
	IF _Difer > 0 .AND. A_VAL_423 > 0
		// VERBA 423
		IF A_VAL_423 > _Difer
			Sld_423 := _SldAnt + _Difer
		ELSE
			Sld_423 := _SldAnt + A_VAL_423
		ENDIF
		_Difer := _Difer - A_VAL_423
	ENDIF
	
	IF _Difer > 0	.AND. A_VAL_OUT > 0
		IF A_VAL_OUT > _Difer
			Sld_Out := _SldAnt + _Difer
		ELSE
			Sld_Out := _SldAnt + A_VAL_OUT
		ENDIF
		_Difer := _Difer - A_VAL_OUT
	ENDIF
	
	IF _Difer <> 0
		//MSGBOX("Diferença de Saldo Atual na Matrícula: "+_FUNCIONARIOS->RA_MAT+" - "+_FUNCIONARIOS->RA_NOME,"STOP")
	ENDIF
	
	//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	VAL_406 := 0
	VAL_411 := 0
	VAL_423 := 0
	
	_SldAnt := 0
	_SldAtu := 0
	_Difer  := 0
	
	MES_    := SUBSTR(DTOS(MV_PAR01),1,6)
	
	
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	// CALCULANDO DESCONTOS DOS EVENTOS EM ABERTO
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	CSQL := "SELECT *  " + ENTER
	CSQL += "FROM "+RETSQLNAME("SRD")+" SRD " + ENTER
	CSQL += "WHERE	SRD.RD_MAT = '"+_FUNCIONARIOS->RA_MAT+"' AND " + ENTER
	CSQL += "		SRD.RD_DATARQ = '"+MES_+"' AND " + ENTER
	CSQL += "		RD_PD IN ('416','124','198','498','489','799','411','423','531','532','533','534','535','536','537','538','543','544','545','546','547','548','549','550','551','552','553','554','555','556','557','558','559','560','561','562','563','564','565','566','568','569','570','571','577')  AND " + ENTER
	CSQL += "		D_E_L_E_T_ = ''   " + ENTER
	IF CHKFILE("_LANCAMENTOS")
		DBSELECTAREA("_LANCAMENTOS")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_LANCAMENTOS" NEW
	
	DO WHILE ! _LANCAMENTOS->(EOF())
		DO CASE
			CASE _LANCAMENTOS->RD_PD = '489'													//Saldo Anterior
				_SldAnt += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD == '124'													//Saldo Atual
				_SldAtu += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD == '411'													//Farmácia
				VAL_411 += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD == '423' 			       									//Utilização do Plano de saúde
				VAL_423 += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD $ '534/538' .AND. cEmpAnt == '05'							//Utilização do Plano de saúde + Arredondamento
				VAL_423 += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD $ '498/533/538' .AND. cEmpAnt == '01'					    //Utilização do Plano de saúde + Arredondamento
				VAL_423 += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD $ '532/533/535/536/537/543/544/545/546/547/548/549/550/551/552/553/554/555/556/557/558/559/560/561/562/563/564/565/566/568/569/570' .AND. cEmpAnt == '05'  //Assistencia Medica / Mensalidade do Plano de saúde			
				VAL_406 += _LANCAMENTOS->RD_VALOR
			CASE _LANCAMENTOS->RD_PD $ '531/532/535/536/537/543/544/545/546/547/548/549/550/551/552/553/554/555/556/557/558/559/560/561/562/563/564/565/566/568/569/570/571/577' .AND. cEmpAnt == '01'		//Assistencia Medica / Mensalidade do Plano de saúde
				VAL_406 += _LANCAMENTOS->RD_VALOR
		ENDCASE
		_LANCAMENTOS->(DBSKIP())
	END DO
	
	IF _SldAtu >= _SldAnt          
		//MSGBOX("Diferença de Saldo Atual na Matrícula: "+_FUNCIONARIOS->RA_MAT+" - "+_FUNCIONARIOS->RA_NOME,"STOP")	
		_Difer   := _SldAtu - _SldAnt
		VAL_OUT  := _Difer - 	VAL_411 - VAL_423 - VAL_406
		Sld_406 := VAL_406/_Difer * _SldAnt
		Sld_411 := VAL_411/_Difer * _SldAnt
		Sld_423 := VAL_423/_Difer * _SldAnt
		Sld_Out := VAL_OUT/_Difer * _SldAnt
		
		IF (_FUNCIONARIOS->RA_MAT == "000133" .AND.	MES_ == "201205") .OR.;
		   (_FUNCIONARIOS->RA_MAT == "001001" .AND. MES_ == "201207") .OR.;
		   (_FUNCIONARIOS->RA_MAT == "001122" .AND.	MES_ == "201410") .OR.;
		   (_FUNCIONARIOS->RA_MAT == "001122" .AND.	MES_ == "201411") .OR.;
		   (_FUNCIONARIOS->RA_MAT == "000445" .AND.	MES_ == "201707") .OR.;
		   (_FUNCIONARIOS->RA_MAT == "000562" .AND. MES_ == "201703")
			Sld_406 := VAL_406/(VAL_411 + VAL_423 + VAL_406) * _SldAnt
			Sld_411 := VAL_411/(VAL_411 + VAL_423 + VAL_406) * _SldAnt
			Sld_423 := VAL_423/(VAL_411 + VAL_423 + VAL_406) * _SldAnt
			Sld_Out := 0
		ENDIF
	ELSE
		//Tratamento do saldo atual menor do que o saldo anterior
		_Difer  := _SldAtu
		VAL_OUT  := _Difer - 	VAL_411 - VAL_423 - VAL_406
		IF VAL_OUT < 0
			VAL_OUT := 0
		ENDIF
		
		_Total   := VAL_406 + VAL_411 + VAL_423 + VAL_OUT
		_SldAnt2 := _SldAnt
		_SldAtu2 := _SldAtu
		IF VAL_406 > _SldAtu2
			Sld_406  := _SldAnt2
			_SldAnt2 := 0
		ELSE
			Sld_406  := VAL_406/_Total * _SldAnt
			_SldAtu2 := _SldAtu2 - VAL_406
			_SldAnt2 := _SldAnt2 - Sld_406
		ENDIF
		IF VAL_411 > _SldAtu2
			Sld_411  := _SldAnt2
			_SldAnt2 := 0
		ELSE
			Sld_411  := VAL_411/_Total * _SldAnt
			_SldAtu2 := _SldAtu2 - VAL_411
			_SldAnt2 := _SldAnt2 - Sld_411
		ENDIF
		IF VAL_423 > _SldAtu2
			Sld_423  := _SldAnt2
			_SldAnt2 := 0
		ELSE
			Sld_423  := VAL_423/_Total * _SldAnt
			_SldAtu2 := _SldAtu2 - VAL_423
			_SldAnt2 := _SldAnt2 - Sld_423
		ENDIF
		IF VAL_OUT > _SldAtu2
			Sld_OUT  := _SldAnt2
			_SldAnt2 := 0
		ELSE
			Sld_OUT  := VAL_OUT/_Total * _SldAnt
			_SldAtu2 := _SldAtu2 - VAL_OUT
			_SldAnt2 := _SldAnt2 - Sld_OUT
		ENDIF
	ENDIF
	
	IF _Difer > 0 .AND. VAL_406 > 0
		// VERBA 406
		IF VAL_406 > _Difer
			IF _SldAtu >= _SldAnt
				_Saldo := _SldAnt + _Difer
			ELSE
				_Saldo := _Difer
			ENDIF
		ELSE
			IF _SldAtu >= _SldAnt
				_Saldo := Sld_406 + VAL_406
				IF (_FUNCIONARIOS->RA_MAT == "000133" .AND. 	MES_ == "201205") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001001" .AND. 	MES_ == "201207") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001122" .AND. 	MES_ == "201410") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001122" .AND. 	MES_ == "201411") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "000445" .AND.	    MES_ == "201707") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "000562" .AND. 	MES_ == "201703")
					_Saldo := VAL_406
				ENDIF
			ELSE
				_Saldo := VAL_406
			ENDIF
		ENDIF
		
		CSQL := "INSERT INTO EVEN_ABERTO(MATRICULA, NOME, CC, VERBA, DATA, VALOR_MES_ANT, VALOR, DATA_REF, DATA_AFAS) " + ENTER
		CSQL += "VALUES('"+_FUNCIONARIOS->RA_MAT+"', '"+_FUNCIONARIOS->RA_NOME+"', '"+_FUNCIONARIOS->RA_CC+"',  " + ENTER
		CSQL += "		'406', '"+MES_+"', '"+ STRTRAN(   ALLTRIM(STR(Sld_406))  ,  "." ,  "," )  +"', '"+ STRTRAN(   ALLTRIM(STR(_Saldo))  ,  "." ,  "," )  +"', CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112), CONVERT(DATETIME, '"+  _FUNCIONARIOS->R8_DATAINI +"', 112) ) " + ENTER
		TCSQLEXEC(CSQL)
		_Difer := _Difer - VAL_406
	END IF
	
	IF _Difer > 0 .AND. VAL_411 > 0
		// VERBA 411
		IF VAL_411 > _Difer
			IF _SldAtu >= _SldAnt
				_Saldo := _SldAnt + _Difer
			ELSE
				_Saldo := _Difer
			ENDIF
		ELSE
			IF _SldAtu >= _SldAnt
				_Saldo := Sld_411 + VAL_411
				IF (_FUNCIONARIOS->RA_MAT == "000133" .AND. 	MES_ == "201205") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001001" .AND. 	MES_ == "201207") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001122" .AND. 	MES_ == "201410") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001122" .AND. 	MES_ == "201411") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "000445" .AND.	    MES_ == "201707") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "000562" .AND. 	MES_ == "201703")
					_Saldo := VAL_411
				ENDIF
			ELSE
				_Saldo := VAL_411
			ENDIF
		ENDIF
		
		CSQL := "INSERT INTO EVEN_ABERTO(MATRICULA, NOME, CC, VERBA, DATA, VALOR_MES_ANT, VALOR, DATA_REF, DATA_AFAS) " + ENTER
		CSQL += "VALUES('"+_FUNCIONARIOS->RA_MAT+"', '"+_FUNCIONARIOS->RA_NOME+"', '"+_FUNCIONARIOS->RA_CC+"',  " + ENTER
		CSQL += "		'411', '"+MES_+"', '"+ STRTRAN(   ALLTRIM(STR(Sld_411))  ,  "." ,  "," )  +"', '"+ STRTRAN(   ALLTRIM(STR(_Saldo))  ,  "." ,  "," )  +"', CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112), CONVERT(DATETIME, '"+  _FUNCIONARIOS->R8_DATAINI +"', 112) ) " + ENTER
		TCSQLEXEC(CSQL)
		_Difer := _Difer - VAL_411
	ENDIF
	
	IF _Difer > 0 .AND. VAL_423 > 0
		// VERBA 423
		IF VAL_423 > _Difer
			IF _SldAtu >= _SldAnt
				_Saldo := _SldAnt + _Difer
			ELSE
				_Saldo := _Difer
			ENDIF
		ELSE
			IF _SldAtu >= _SldAnt
				_Saldo := Sld_423 + VAL_423
				IF (_FUNCIONARIOS->RA_MAT == "000133" .AND. 	MES_ == "201205") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001001" .AND. 	MES_ == "201207") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001122" .AND. 	MES_ == "201410") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001122" .AND. 	MES_ == "201411") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "000445" .AND.	    MES_ == "201707") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "000562" .AND. 	MES_ == "201703")
					_Saldo := VAL_423
				ENDIF
			ELSE
				_Saldo := VAL_423
			ENDIF
		ENDIF
		
		CSQL := "INSERT INTO EVEN_ABERTO(MATRICULA, NOME, CC, VERBA, DATA, VALOR_MES_ANT, VALOR, DATA_REF, DATA_AFAS) " + ENTER
		CSQL += "VALUES('"+_FUNCIONARIOS->RA_MAT+"', '"+_FUNCIONARIOS->RA_NOME+"', '"+_FUNCIONARIOS->RA_CC+"',  " + ENTER
		CSQL += "		'423', '"+MES_+"', '"+ STRTRAN(   ALLTRIM(STR(Sld_423))  ,  "." ,  "," )  +"', '"+ STRTRAN(   ALLTRIM(STR(_Saldo))  ,  "." ,  "," )  +"', CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112), CONVERT(DATETIME, '"+  _FUNCIONARIOS->R8_DATAINI +"', 112)  ) " + ENTER
		TCSQLEXEC(CSQL)
		_Difer := _Difer - VAL_423
	ENDIF
	
	IF _Difer > 0	.AND. VAL_OUT > 0
		IF VAL_OUT > _Difer
			IF _SldAtu >= _SldAnt
				_Saldo := _SldAnt + _Difer
			ELSE
				_Saldo := _Difer
			ENDIF
		ELSE
			IF _SldAtu >= _SldAnt
				_Saldo := Sld_OUT + VAL_OUT
				IF (_FUNCIONARIOS->RA_MAT == "000133" .AND. 	MES_ == "201205") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001001" .AND. 	MES_ == "201207") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001122" .AND. 	MES_ == "201410") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "001122" .AND. 	MES_ == "201411") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "000445" .AND.	    MES_ == "201707") .OR.;
				   (_FUNCIONARIOS->RA_MAT == "000562" .AND. 	MES_ == "201703")
					_Saldo := VAL_OUT
				ENDIF
			ELSE
				_Saldo := VAL_OUT
			ENDIF
		ENDIF
		
		CSQL := "INSERT INTO EVEN_ABERTO(MATRICULA, NOME, CC, VERBA, DATA, VALOR_MES_ANT, VALOR, DATA_REF, DATA_AFAS) " + ENTER
		CSQL += "VALUES('"+_FUNCIONARIOS->RA_MAT+"', '"+_FUNCIONARIOS->RA_NOME+"', '"+_FUNCIONARIOS->RA_CC+"',  " + ENTER
		CSQL += "		'OUT', '"+MES_+"', '"+ STRTRAN(   ALLTRIM(STR(Sld_Out))  ,  "." ,  "," )  +"', '"+ STRTRAN(   ALLTRIM(STR(_Saldo))  ,  "." ,  "," )  +"', CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112), CONVERT(DATETIME, '"+  _FUNCIONARIOS->R8_DATAINI +"', 112) ) " + ENTER
		TCSQLEXEC(CSQL)
		_Difer := _Difer - VAL_OUT
	ENDIF
	
	IF (Sld_406	> 0 .AND.  VAL_406 = 0) .OR. (_FUNCIONARIOS->RA_MAT == "000445" .AND. MES_ == "201707" .AND. Sld_406 > 0)
		CSQL := "INSERT INTO EVEN_ABERTO(MATRICULA, NOME, CC, VERBA, DATA, VALOR_MES_ANT, VALOR, DATA_REF, DATA_AFAS) " + ENTER
		CSQL += "VALUES('"+_FUNCIONARIOS->RA_MAT+"', '"+_FUNCIONARIOS->RA_NOME+"', '"+_FUNCIONARIOS->RA_CC+"',  " + ENTER
		CSQL += "		'OUT', '"+MES_+"', '"+ STRTRAN(   ALLTRIM(STR(Sld_406))  ,  "." ,  "," )  +"', '"+ STRTRAN(   ALLTRIM(STR(VAL_406))  ,  "." ,  "," )  +"', CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112), CONVERT(DATETIME, '"+  _FUNCIONARIOS->R8_DATAINI +"', 112) ) " + ENTER
		TCSQLEXEC(CSQL)
	ENDIF
	
	IF Sld_411	> 0 .AND.  VAL_411 = 0
		CSQL := "INSERT INTO EVEN_ABERTO(MATRICULA, NOME, CC, VERBA, DATA, VALOR_MES_ANT, VALOR, DATA_REF, DATA_AFAS) " + ENTER
		CSQL += "VALUES('"+_FUNCIONARIOS->RA_MAT+"', '"+_FUNCIONARIOS->RA_NOME+"', '"+_FUNCIONARIOS->RA_CC+"',  " + ENTER
		CSQL += "		'OUT', '"+MES_+"', '"+ STRTRAN(   ALLTRIM(STR(Sld_411))  ,  "." ,  "," )  +"', '"+ STRTRAN(   ALLTRIM(STR(VAL_411))  ,  "." ,  "," )  +"', CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112), CONVERT(DATETIME, '"+  _FUNCIONARIOS->R8_DATAINI +"', 112) ) " + ENTER
		TCSQLEXEC(CSQL)
	ENDIF
	
	IF Sld_423	> 0 .AND.  VAL_423 = 0
		CSQL := "INSERT INTO EVEN_ABERTO(MATRICULA, NOME, CC, VERBA, DATA, VALOR_MES_ANT, VALOR, DATA_REF, DATA_AFAS) " + ENTER
		CSQL += "VALUES('"+_FUNCIONARIOS->RA_MAT+"', '"+_FUNCIONARIOS->RA_NOME+"', '"+_FUNCIONARIOS->RA_CC+"',  " + ENTER
		CSQL += "		'OUT', '"+MES_+"', '"+ STRTRAN(   ALLTRIM(STR(Sld_423))  ,  "." ,  "," )  +"', '"+ STRTRAN(   ALLTRIM(STR(VAL_423))  ,  "." ,  "," )  +"', CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112), CONVERT(DATETIME, '"+  _FUNCIONARIOS->R8_DATAINI +"', 112) ) " + ENTER
		TCSQLEXEC(CSQL)
	ENDIF
	
	IF Sld_Out	> 0 .AND.  VAL_OUT = 0
		CSQL := "INSERT INTO EVEN_ABERTO(MATRICULA, NOME, CC, VERBA, DATA, VALOR_MES_ANT, VALOR, DATA_REF, DATA_AFAS) " + ENTER
		CSQL += "VALUES('"+_FUNCIONARIOS->RA_MAT+"', '"+_FUNCIONARIOS->RA_NOME+"', '"+_FUNCIONARIOS->RA_CC+"',  " + ENTER
		CSQL += "		'OUT', '"+MES_+"', '"+ STRTRAN(   ALLTRIM(STR(Sld_Out))  ,  "." ,  "," )  +"', '"+ STRTRAN(   ALLTRIM(STR(VAL_OUT))  ,  "." ,  "," )  +"', CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112), CONVERT(DATETIME, '"+  _FUNCIONARIOS->R8_DATAINI +"', 112) ) " + ENTER
		TCSQLEXEC(CSQL)
	ENDIF
	
	IF _SldAtu = _SldAnt .AND. _SldAtu <> 0 .AND. _SldAnt <> 0 .AND. VAL_OUT = 0 .AND. Sld_406 = 0 .AND. Sld_411 = 0 .AND. Sld_423 = 0 .AND. Sld_Out = 0
		//IF _FUNCIONARIOS->RA_MAT $ '000021/000651'
		CSQL := "INSERT INTO EVEN_ABERTO(MATRICULA, NOME, CC, VERBA, DATA, VALOR_MES_ANT, VALOR, DATA_REF, DATA_AFAS) " + ENTER
		CSQL += "VALUES('"+_FUNCIONARIOS->RA_MAT+"', '"+_FUNCIONARIOS->RA_NOME+"', '"+_FUNCIONARIOS->RA_CC+"',  " + ENTER
		CSQL += "		'OUT', '"+MES_+"', '"+ STRTRAN(   ALLTRIM(STR(_SldAnt))  ,  "." ,  "," )  +"', '"+ STRTRAN(   ALLTRIM(STR(_SldAtu))  ,  "." ,  "," )  +"', CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112), CONVERT(DATETIME, '"+  _FUNCIONARIOS->R8_DATAINI +"', 112) ) " + ENTER
		TCSQLEXEC(CSQL)
		//ENDIF
	ENDIF
	
	IF _Difer <> 0
		//MSGBOX("Diferença de Saldo Atual na Matrícula: "+_FUNCIONARIOS->RA_MAT+" - "+_FUNCIONARIOS->RA_NOME,"STOP")
	END IF
	
	_FUNCIONARIOS->(DBSKIP())
END DO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	//Parametros Crystal Em Disco                   
	//Private cOpcao:="1;0;1;Apuracao"
	Private cOpcao:="6;0;1;Apuracao"
Else
	//Direto Impressora
	Private cOpcao:="3;0;1;Apuracao"              
	//Private cOpcao:="6;0;1;Apuracao"
Endif
//AtivaRel()
callcrys("EVEN_ABERTO",cEmpant,cOpcao,.T.,.T.,.T.,.F.)

RETURN

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
BUSCA O PROXIMO MES
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION PROX_MES(WW_MES)

MES := SUBSTR(WW_MES,5,2)
ANO := SUBSTR(WW_MES,1,4)

MES := SOMA1(MES)
IF MES = "13"
	ANO := SOMA1(ANO)
	MES := "01"
END IF

RETURN(ANO + MES)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
BUSCA O MES ANTERIOR
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION ANTE_MES(WW_MES)

MES := SUBSTR(WW_MES,5,2)
ANO := SUBSTR(WW_MES,1,4)

MES := (VAL(MES)-1)
IF MES = 0
	RETURN(ALLTRIM(STR((VAL(ANO)-1))) + "12")
ELSE
	IF LEN(ALLTRIM(STR(MES))) = 1
		RETURN(ANO + "0" + ALLTRIM(STR(MES)) )
	ELSE
		RETURN(ANO + ALLTRIM(STR(MES)) )
	END IF
END IF

RETURN(ANO + MES)