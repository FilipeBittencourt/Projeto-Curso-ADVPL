#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲UN噮O    � GRUP_SEG	  � AUTOR � BRUNO MADALENO        � DATA � 03/06/09 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰ESCRI噭O � GATILHO NO CLIENTE PARA GRAVACAO DO GRUPO NO ORCAMENTO       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � FATURAMENTO                                                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

USER FUNCTION GRUP_SEG()

CSQL := "SELECT ZZG_GRUPO, A1_SATIV1 "
CSQL += "FROM "+RETSQLNAME("SA1")+" SA1, "+RETSQLNAME("ZZG")+" ZZG "
CSQL += "WHERE	ZZG_SEG =  A1_SATIV1 AND "
CSQL += "		A1_COD = '"+M->CJ_CLIENTE+"' AND "
CSQL += "		A1_LOJA = '"+M->CJ_LOJA+"' AND "
CSQL += "		SA1.D_E_L_E_T_ = '' AND "
CSQL += "		ZZG.D_E_L_E_T_ = ''  "
IF CHKFILE("_TRAB")
	DBSELECTAREA("_TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TRAB" NEW
IF _TRAB->(EOF())
	GRUP_SEG := "" 
ELSE
	GRUP_SEG := _TRAB->ZZG_GRUPO
END IF


RETURN(	GRUP_SEG )