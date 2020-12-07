#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FOLH_DIRETOR   ºAUTOR  ³ BRUNO MADALENO     º DATA ³  22/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ RELATORIO EM CRYSTAL PARA AUTORIZACAO DE FOLHA DE PAGAMENTO      º±±
±±º          ³																	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ MP8 - R4                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION FOLH_DIRETOR()
PRIVATE CSQL 	:= ""
PRIVATE ENTER	:= CHR(13)+CHR(10)


// DELETANDO A TABELA TEMPORARIA
CSQL := " DELETE REL_FOLHA "
TCSQLEXEC(CSQL)


// SELECIONANDO TODAAS AS CATEGORIAS
CSQL := "SELECT * FROM SZY010 WHERE D_E_L_E_T_ = '' "
IF CHKFILE("_CATE")
	DBSELECTAREA("_CATE")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_CATE" NEW 


DO WHILE ! _CATE->(EOF())
	
	CCODATUAL := _CATE->ZY_COD
	
	DO CASE
		CASE CCODATUAL = "01"
			ATIPOFUNC	:= "('M','E')"		// {"M","E"}
			
		CASE CCODATUAL = "02"
			ATIPOFUNC	:= "('P')"  		// {"P"}
			
		CASE CCODATUAL = "03"
			ATIPOFUNC	:= "('P')"  		// {"P"}
			
		CASE CCODATUAL = "04"
			ATIPOFUNC	:= "('M','E','A')"  // {"M","E","A"}
			
		CASE CCODATUAL = "05"
			ATIPOFUNC	:= "('P')"  		// {"P"}	
			
		CASE CCODATUAL = "06"
			ATIPOFUNC	:= "('M','E')"  // {"M","E","A"}
			
		CASE CCODATUAL = "07"
			ATIPOFUNC	:= "('M')"  	// {"M","A"}
			
		CASE CCODATUAL = "08"
			ATIPOFUNC	:= "('P')"  		// {"P"}
			
		CASE CCODATUAL = "09"
			ATIPOFUNC	:= "('M','E')"  	// {"M","E","P"}
			
		CASE CCODATUAL = "10"
			ATIPOFUNC	:= "('M','P')"  	// {"M","P"}			
			
		CASE CCODATUAL = "11"
			ATIPOFUNC	:= "('M','P')"  	// {"M","P"}
			
		CASE CCODATUAL = "12" 
			ATIPOFUNC	:= "('M','P','E')"  // {"M","P","E"}
			
		CASE CCODATUAL = "13"
			ATIPOFUNC	:= "('M')"  		// {"M"}

		CASE CCODATUAL = "14"
			ATIPOFUNC	:= "('M')"  		// {"M"}
			
		CASE CCODATUAL = "15"
			ATIPOFUNC	:= "('M')"  		// {"M"}

		CASE CCODATUAL = "16"
			ATIPOFUNC	:= "('M')"  		// {"M"}
			                                        
		CASE CCODATUAL = "17"
			ATIPOFUNC	:= "('M','E')" 		// {"M"}
			
		CASE CCODATUAL = "18"
			ATIPOFUNC	:= "('M')"  		// {"M"}						

		CASE CCODATUAL = "19"
			ATIPOFUNC	:= "('M')"  		// {"M"}
									
	ENDCASE


	//GRAVANDO A INFORMACAO NA TABELA PARA GERAR O RELATORIO
	CSQL := "INSERT INTO REL_FOLHA " + ENTER
	CSQL += "	SELECT	'"+CCODATUAL+"' AS CATEG, " + ENTER
	CSQL += "			RC_CC, " + ENTER
	CSQL += "			SUM(VALOR) AS VALOR " + ENTER

	CSQL += "	FROM  " + ENTER
	CSQL += "	(SELECT RC_CC, VALOR = CASE WHEN RC_PD = '129' THEN (RC_VALOR*-1) ELSE RC_VALOR END " + ENTER

	CSQL += "	FROM "+RETSQLNAME("SRA")+" SRA, "+RETSQLNAME("SRC")+" SRC " + ENTER
	CSQL += "	WHERE	RA_MAT = RC_MAT AND " + ENTER
	CSQL += "			RA_CATFUNC IN "+ATIPOFUNC+" AND   " + ENTER
	CSQL += "			SRC.RC_PD IN (SELECT RV_COD FROM "+RETSQLNAME("SRV")+" AS SRV WHERE (SRV.RV_YAP LIKE '%' + '"+CCODATUAL+"' + '%' OR SRV.RV_YDEDUZ LIKE '%' + '"+CCODATUAL+"' + '%' ) AND D_E_L_E_T_ = '') AND  " + ENTER
	CSQL += "			SRA.D_E_L_E_T_ = '' AND  " + ENTER
	CSQL += "			SRC.D_E_L_E_T_ = ''  ) AS SSS " + ENTER



	CSQL += "	GROUP BY RC_CC  " + ENTER
	TCSQLEXEC(CSQL)

	_CATE->(DBSKIP())
END DO

//PARAMETROS CRYSTAL EM DISCO
PRIVATE COPCAO:="1;0;1;ANALISE"
CALLCRYS("FOL_PAGT",CEMPANT,COPCAO)

RETURN