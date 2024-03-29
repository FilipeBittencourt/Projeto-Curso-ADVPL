#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia305()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("BREP,")

//BIA305.PRW - REDISTRIBUI O VOLUME DA META

  bRep := {|| cRepres == UZ8->UZ8_REP .AND. cMesAno == UZ8->UZ8_MESANO }

  DBSELECTAREA("UZ8")
  DBSETORDER(1)

  IF M->nVolume #M->nOldVol

     IF DBSEEK(XFILIAL("UZ8")+cRepres+cMesAno,.F.)
   
        WHILE !EOF() .AND. EVAL( bRep )

           RECLOCK("UZ8",.F.)

           UZ8->UZ8_VOLUME := ROUND( M->nVolume * UZ8->UZ8_PERCEN / 100, 2 )

           MSUNLOCK()
           DBSKIP()

        ENDDO

        DBCOMMITALL()
   
     ENDIF

  ENDIF

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __RETURN( .T. )
Return( .T. )        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

