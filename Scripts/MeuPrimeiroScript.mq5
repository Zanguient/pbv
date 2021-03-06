//+------------------------------------------------------------------+
//|                                            MeuPrimeiroScript.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//
   /*
      Considerando os dados do exercício 10 da prova faça um script
      para calcular qual seria o lucro/prejuízo da operação não
      levando em consideração as taxas cobradas pela bolsa e corretora.
   */

   double entrada = 4091.000 ;
   double saida   = 4109.500 ;
   int    volume  = 4 ;
   int lotePadrao = 1 ;
   int valorTick  = 5 ;
   double tick    = 0.500 ;

   double resultado = (saida - entrada) * (volume / lotePadrao) * 10 ;

   datetime DataAtual = TimeCurrent();
   Print("Data formatada: ", TimeToString( DataAtual, TIME_DATE) );


}
//+------------------------------------------------------------------+
