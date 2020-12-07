/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |WFRSP3     | Autor | Marcelo Sousa        | Data | 31.07.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |MENU PARA CRIAгцO DOS ACESSOS DE USUаRIOS AOS MENUS DE        |
|          |CADASTRO DE VAGAS E CURRмCULOS.  						      |
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEгцO                                        |
+----------+-------------------------------------------------------------*/
#include 'protheus.ch'
#include 'parmtype.ch'

user function BIAFM007()

	Local i

	/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠ DeclaraГЦo de Variaveis Private dos Objetos                             ╠╠
	ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
	cUsrtst  := __cUserID
	aUsrtst2 := UsrRetGrp(cUsrtst)
	lAlt 	 := .F.
	lCria 	 := .F.
	lAprov   := .F.
	aUsr     := cUserName

	/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠ Verifiando se usuАrio possui acesso ao grupo de recrutamento.           ╠╠
	ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
	For i:=1 to Len(aUsrtst2)

		IF aUsrtst2[i] == '000006'
			lAlt := .T.
		ENDIF

	Next

	/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠ Disparando tela de cadastro dos acessos.                                ╠╠
	ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
	IF lAlt
		AxCadastro("ZR3", "Acessos para Recrutamento",)
	ELSE 
		Alert("VocЙ nЦo possui permissЦo para este menu. Favor procurar equipe de Recrutamento.")
	ENDIF

return